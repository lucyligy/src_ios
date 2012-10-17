//
//  MBCRSubwayAlertsViewController.m
//  MBCR
//
//  Created by Alex Rouse on 6/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MBCRSubwayAlertsViewController.h"
#import "MBCRSubwayAlertCell.h"
#import "SubwayAlert.h"
#import "MBCRDataManager.h"
#import "MBCRServiceManager.h"
#import "UIViewFactory.h"
#import "MBCRAppDelegate.h"
#import "MBCRNoDataView.h"
#import "MBCRAlertDetailsViewController.h"

@interface MBCRSubwayAlertsViewController ()
@property (nonatomic, strong) NSFetchedResultsController* subwayAlertsFetchedResultsController;
@end

@implementation MBCRSubwayAlertsViewController

@synthesize alertsTableView = _alertsTableView;
@synthesize segmentedControl = _segmentedControl;

@synthesize subwayAlertsFetchedResultsController = _subwayAlertsFetchedResultsController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.subwayAlertsFetchedResultsController = [[MBCRDataManager shared] subwayAlertsFetchResultsController];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"MBCR" style:UIBarButtonItemStylePlain target:self action:@selector(dismissSubwayInformation)];
    self.navigationItem.leftBarButtonItem = [((MBCRAppDelegate *)[[UIApplication sharedApplication] delegate]) createLeftBarImage];

    self.navigationItem.title = @"Messages";
}

- (void)viewDidAppear:(BOOL)animated
{
    [[MBCRServiceManager shared] downloadSubwayAlerts];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void) setSubwayAlertsFetchedResultsController:(NSFetchedResultsController *)subwayAlertsFetchedResultsController
{
    NSError* error;
    if ([subwayAlertsFetchedResultsController performFetch:&error]) {
        _subwayAlertsFetchedResultsController.delegate = nil;
        subwayAlertsFetchedResultsController.delegate = self;
        _subwayAlertsFetchedResultsController = subwayAlertsFetchedResultsController;
        
        [self.alertsTableView reloadData];
    } else {
        RZLog(@"Unresolved error in MBCRSubwayAlertsViewController %@, %@", error, [error userInfo]);
    }
}


- (void)dismissSubwayInformation {
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)segmentedControlChanged:(id)sender {
    switch (self.segmentedControl.selectedSegmentIndex) {
        case 0: {
            self.subwayAlertsFetchedResultsController = [[MBCRDataManager shared] subwayAlertsFetchResultsController];
        }break;
        case 1: {
            self.subwayAlertsFetchedResultsController = [[MBCRDataManager shared] subwayAlertsFetchResultsControllerFilterByLine:kSubwayBlueLineKey];
        }break;
        case 2: {
            self.subwayAlertsFetchedResultsController = [[MBCRDataManager shared] subwayAlertsFetchResultsControllerFilterByLine:kSubwayGreenLineKey];
        }break;
        case 3: {
            self.subwayAlertsFetchedResultsController = [[MBCRDataManager shared] subwayAlertsFetchResultsControllerFilterByLine:kSubwayRedLineKey];
        }break;
        case 4: {
            self.subwayAlertsFetchedResultsController = [[MBCRDataManager shared] subwayAlertsFetchResultsControllerFilterByLine:kSubwayOrangeLineKey];
        }break;
        default:
            break;
    }

}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    SubwayAlert* alert = [self.subwayAlertsFetchedResultsController objectAtIndexPath:indexPath];
    MBCRAlertDetailsViewController* detailsVC = [[MBCRAlertDetailsViewController alloc] init];
    [self.navigationController pushViewController:detailsVC animated:YES];
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
