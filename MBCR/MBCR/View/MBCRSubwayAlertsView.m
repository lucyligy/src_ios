//
//  MBCRSubwayAlertsView.m
//  MBCR
//
//  Created by Alex Rouse on 8/7/12.
//
//

#import "MBCRSubwayAlertsView.h"
#import "MBCRSubwayAlertCell.h"
#import "SubwayAlert.h"
#import "MBCRDataManager.h"
#import "MBCRServiceManager.h"
#import "UIViewFactory.h"
#import "MBCRAppDelegate.h"
#import "MBCRNoDataView.h"
#import "MBCRAlertDetailsViewController.h"

@interface MBCRSubwayAlertsView ()
@end

@implementation MBCRSubwayAlertsView
@synthesize alertsTableView = _alertsTableView;
@synthesize segmentedControl = _segmentedControl;
@synthesize containedInViewController = _containedInViewController;
@synthesize subwayAlertsFetchedResultsController = _subwayAlertsFetchedResultsController;

- (id)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib {
    [[MBCRServiceManager shared] downloadSubwayAlerts];
}

- (void)viewWillShow {
    [[MBCRServiceManager shared] downloadSubwayAlerts];
    if(self.subwayAlertsFetchedResultsController == nil) {
        self.subwayAlertsFetchedResultsController = [[MBCRDataManager shared] subwayAlertsFetchResultsController];
    } else {
        self.subwayAlertsFetchedResultsController = self.subwayAlertsFetchedResultsController;
    }
}


- (void) setSubwayAlertsFetchedResultsController:(NSFetchedResultsController *)subwayAlertsFetchedResultsController
{
    [self.alertsTableView beginUpdates];
    NSError* error;
    if ([subwayAlertsFetchedResultsController performFetch:&error]) {
        _subwayAlertsFetchedResultsController.delegate = nil;
        subwayAlertsFetchedResultsController.delegate = self;
        _subwayAlertsFetchedResultsController = subwayAlertsFetchedResultsController;
        [self.alertsTableView deleteSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
        [self.alertsTableView insertSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
        
//        [self.alertsTableView reloadData];
    } else {
        RZLog(@"Unresolved error in MBCRSubwayAlertsViewController %@, %@", error, [error userInfo]);
    }
    [self.alertsTableView endUpdates];

}


- (IBAction)segmentedControlChanged:(id)sender {
    NSString* line = @"";
    switch (self.segmentedControl.selectedSegmentIndex) {
        case 0: {
        }break;
        case 1: {
            line = kSubwayBlueLineKey;
        }break;
        case 2: {
            line = kSubwayGreenLineKey;
        }break;
        case 3: {
            line = kSubwayRedLineKey;
        }break;
        case 4: {
            line = kSubwayOrangeLineKey;
        }break;
        default:
            break;
    }
    if(line.length < 1) {
        self.subwayAlertsFetchedResultsController = [[MBCRDataManager shared] subwayAlertsFetchResultsController];
        NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                    @"All", kLocalAttributeLine,
                                    nil];
        [[LocalyticsSession sharedLocalyticsSession] tagEvent:kLocalActionSubwayFilter attributes:dictionary];
    } else {
        self.subwayAlertsFetchedResultsController = [[MBCRDataManager shared] subwayAlertsFetchResultsControllerFilterByLine:line];
        NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                    line, kLocalAttributeLine,
                                    nil];
        [[LocalyticsSession sharedLocalyticsSession] tagEvent:kLocalActionSubwayFilter attributes:dictionary];
    }
    
    
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    SubwayAlert* alert = [self.subwayAlertsFetchedResultsController objectAtIndexPath:indexPath];
    MBCRAlertDetailsViewController* detailsVC = [[MBCRAlertDetailsViewController alloc] init];
    [self.containedInViewController.navigationController pushViewController:detailsVC animated:YES];
    [detailsVC updateViewWithSubwayAlert:alert];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 95.0f;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.subwayAlertsFetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.subwayAlertsFetchedResultsController sections] objectAtIndex:section];
    if ([sectionInfo numberOfObjects] < 1) {
        return self.alertsTableView.frame.size.height;
    } else {
        return 0;
    }
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    MBCRNoDataView* v = (MBCRNoDataView *)[MBCRNoDataView view];
    return v;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* cellIdentifier = @"rtAlertsIdentifier";
    
    MBCRSubwayAlertCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = (MBCRSubwayAlertCell *)[MBCRSubwayAlertCell view];
    }
    
    SubwayAlert* alert = [self.subwayAlertsFetchedResultsController objectAtIndexPath:indexPath];
    [cell setAlert:alert];
    return cell;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.subwayAlertsFetchedResultsController sections] count];
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.subwayAlertsFetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo name];
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.alertsTableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type
{
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [self.alertsTableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete:
            [self.alertsTableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
        default:
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.alertsTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete:
            [self.alertsTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeMove:
            [self.alertsTableView moveRowAtIndexPath:indexPath toIndexPath:newIndexPath];
            break;
        case NSFetchedResultsChangeUpdate:
        {
            MBCRSubwayAlertCell *cell = (MBCRSubwayAlertCell*)[self.alertsTableView cellForRowAtIndexPath:indexPath];
            [cell setAlert:(SubwayAlert *)anObject];
        }
            break;
        default:
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.alertsTableView endUpdates];
}

@end
