//
//  MBCRTrackAssignmentsViewController.m
//  MBCR
//
//  Created by Joe Mahon on 6/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MBCRTrackAssignmentsViewController.h"
#import "MBCRDataManager.h"
#import "MBCRAppDelegate.h"
#import "MBCRServiceManager.h"
#import "MBCRTrackAssignmentCell.h"
#import "TrackAssignment.h"
#import "UIViewFactory.h"
#import "NSDate+Formatter.h"
#import "MBCRTrackAssignmentDetailsViewController.h"

#define kTrackPollTimer     15.0

@interface MBCRTrackAssignmentsViewController ()
@property (nonatomic, strong) NSFetchedResultsController* trackAssignmentsFetchedResultsController;
@property (nonatomic, strong) NSString* selectedStation;
@property (nonatomic, strong) NSDate* lastUpdateDate;
@property (nonatomic, readonly) BOOL isShowingSouthStation;
@property (nonatomic, strong) NSTimer* pollTimer;

@end

@implementation MBCRTrackAssignmentsViewController

@synthesize trackAssignmentsTableView = _trackAssignmentsTableView;
@synthesize tableHeader = _tableHeader;
@synthesize stationLabel = _stationLabel;
@synthesize headerUpdated = _headerUpdated;
@synthesize trackAssignmentsFetchedResultsController = _trackAssignmentsFetchedResultsController;
@synthesize selectedStation = _selectedStation;
@synthesize lastUpdateDate = _lastUpdateDate;
@synthesize pollTimer = _pollTimer;

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
    self.navigationItem.title = @"Assignments";
    self.navigationItem.leftBarButtonItem = [((MBCRAppDelegate *)[[UIApplication sharedApplication] delegate]) createLeftBarImage];
    self.selectedStation = kStationSouthStationKey;
}

- (void)viewDidUnload
{
    [self setTableHeader:nil];
    [self setStationLabel:nil];
    [self setHeaderUpdated:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewDidAppear:(BOOL)animated
{
    [[MBCRServiceManager shared] downloadTrackAssignments];
    self.pollTimer = [NSTimer scheduledTimerWithTimeInterval:kTrackPollTimer target:self selector:@selector(pollFired) userInfo:nil repeats:YES];
    [[LocalyticsSession sharedLocalyticsSession] tagScreen:kLocalScreenTrackSouth];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.pollTimer invalidate];
    self.pollTimer = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)pollFired {
    [[MBCRServiceManager shared] downloadTrackAssignments];
}

- (void)setTrackAssignmentsFetchedResultsController:(NSFetchedResultsController *)trackAssignmentsFetchedResultsController
{
    //fetch the objects
    NSError *error;
    if ([trackAssignmentsFetchedResultsController performFetch:&error]) {
        _trackAssignmentsFetchedResultsController.delegate = nil;
        trackAssignmentsFetchedResultsController.delegate = self;
        _trackAssignmentsFetchedResultsController = trackAssignmentsFetchedResultsController;
                
        NSIndexPath* index = [NSIndexPath indexPathForRow:0 inSection:0];
        if([[trackAssignmentsFetchedResultsController fetchedObjects] count] > 0 ) {
            TrackAssignment* trackAssignment = [trackAssignmentsFetchedResultsController objectAtIndexPath:index];
            if (self.lastUpdateDate == nil || [self.lastUpdateDate compare:trackAssignment.lastUpdate] == NSOrderedAscending) {
                self.lastUpdateDate = trackAssignment.lastUpdate;
            }
        }
        [self.trackAssignmentsTableView reloadData];
    } else {
        RZError(@"Unresolved error in MBCRTrackAssignmentsVC %@, %@", error, [error userInfo]);
    }
}


- (void)dismissTrackAssignments {
    [self dismissModalViewControllerAnimated:YES];
}

- (void)switchStation {
    if([self isShowingSouthStation]) {
        self.selectedStation = kStationNorthStationKey;
    } else {
        self.selectedStation = kStationSouthStationKey;
    }
}

- (BOOL)isShowingSouthStation {
    return ([self.selectedStation isEqualToString:kStationSouthStationKey]);
}

- (void)setSelectedStation:(NSString *)selectedStation {
    _selectedStation = selectedStation;
    
    if([self isShowingSouthStation]) {
        self.stationLabel.text = [NSString stringWithFormat:@"%@ Station",@"South"];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"North" style:UIBarButtonItemStyleDone target:self action:@selector(switchStation)];
        [[LocalyticsSession sharedLocalyticsSession] tagScreen:kLocalScreenTrackSouth];

    } else {
        self.stationLabel.text = [NSString stringWithFormat:@"%@ Station",@"North"];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"South" style:UIBarButtonItemStyleDone target:self action:@selector(switchStation)];
        [[LocalyticsSession sharedLocalyticsSession] tagScreen:kLocalScreenTrackNorth];

    }
    
    UIViewAnimationOptions options = ([self isShowingSouthStation]) ? UIViewAnimationOptionTransitionFlipFromLeft : UIViewAnimationOptionTransitionFlipFromRight;
    
    [UIView transitionWithView:self.view duration:kViewFlipDuration options:options animations:^{
        self.navigationItem.rightBarButtonItem.enabled = NO;
    } completion:^(BOOL finished) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }];

    self.trackAssignmentsFetchedResultsController = [[MBCRDataManager shared] stationTrackAssignmentsFetchResultsController:selectedStation];
}

- (void)setLastUpdateDate:(NSDate *)lastUpdateDate {
    _lastUpdateDate = lastUpdateDate;
    
    self.headerUpdated.text = [NSString stringWithFormat:@"Updated %@", [lastUpdateDate clockTimeFormat]];
    
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 115.0f;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.trackAssignmentsFetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* cellIdentifier = @"trackAssignmentIdentifier";
    
    MBCRTrackAssignmentCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = (MBCRTrackAssignmentCell *)[MBCRTrackAssignmentCell view];
    }
    
    TrackAssignment* trackAssignment = [self.trackAssignmentsFetchedResultsController objectAtIndexPath:indexPath];
    [cell setTrackAssignment:trackAssignment];
    return cell;
}

-  (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return self.tableHeader;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return ([self isShowingSouthStation]) ? @"South Station" : @"North Station";
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.trackAssignmentsTableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo 
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [self.trackAssignmentsTableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] 
                                          withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete:
            [self.trackAssignmentsTableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
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
    switch (type) {
        case NSFetchedResultsChangeInsert: {
            TrackAssignment* trackAssignment = (TrackAssignment *)anObject;
            if (self.lastUpdateDate == nil || [self.lastUpdateDate compare:trackAssignment.lastUpdate] == NSOrderedAscending) {
                self.lastUpdateDate = trackAssignment.lastUpdate;
            }
            [self.trackAssignmentsTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
        } break;
        case NSFetchedResultsChangeDelete:
            [self.trackAssignmentsTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeMove:
            [self.trackAssignmentsTableView moveRowAtIndexPath:indexPath toIndexPath:newIndexPath];
            break;
        case NSFetchedResultsChangeUpdate:
        {
            MBCRTrackAssignmentCell* cell = (MBCRTrackAssignmentCell*)[self.trackAssignmentsTableView cellForRowAtIndexPath:indexPath];
            TrackAssignment* assignment = (TrackAssignment *)anObject;
            if ([self.lastUpdateDate compare:assignment.lastUpdate] == NSOrderedAscending) {
                self.lastUpdateDate = assignment.lastUpdate;
            }
            [cell setTrackAssignment:assignment];
        }
            break;
        default:
            //nothing else should occur
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.trackAssignmentsTableView endUpdates];
    [self.trackAssignmentsTableView reloadData];
}




@end
