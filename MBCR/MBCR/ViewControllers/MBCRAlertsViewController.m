//
//  MBCRAlertsViewController.m
//  MBCR
//
//  Created by Alex Rouse on 6/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MBCRAlertsViewController.h"
#import "MBCRAlert.h"
#import "TAlert.h"
#import "Line.h"
#import "AllPageAlert.h"
#import "MBCRDataManager.h"
#import "MBCRServiceManager.h"
#import "MBCRAlertCell.h"
#import "MBCRNoDataView.h"
#import "UIViewFactory.h"
#import "MBCRSubwayAlertsViewController.h"
#import "MBCRAlertDetailsViewController.h"
#import "MBCRAppDelegate.h"
#import "MBCRSubwayAlertsView.h"
#import "UAPush.h"

#define kUAAllTag   @"All"

@interface MBCRAlertsViewController ()

@property (nonatomic, strong) NSFetchedResultsController* alertsFetchedResultsController;
@property (nonatomic, strong) NSArray* selectedLines;
@property (nonatomic, strong) Train* selectedTrain;
@property (nonatomic, assign) MBCRRegionFilterType selectedRegion;
@property (nonatomic, strong) Line* selectedLine;
@property (nonatomic, strong) NSString* filterString;
@property (nonatomic, strong) MBCRSubwayAlertsView* subwayView;
@property (nonatomic, assign) BOOL showingSubwayPage;
@property (nonatomic, assign) NSUInteger oldFilterIndex;
@end

@implementation MBCRAlertsViewController
@synthesize alertsTableView = _alertsTableView;
@synthesize filterControl = _filterControl;
@synthesize tableHeader = _tableHeader;
@synthesize tableTitle = _tableTitle;
@synthesize mbcrAlertsView = _mbcrAlertsView;
@synthesize pickerView = _pickerView;
@synthesize regionFilter = _regionFilter;

@synthesize alertsFetchedResultsController = _alertsFetchedResultsController;

@synthesize selectedLines = _selectedLines;
@synthesize selectedTrain = _selectedTrain;
@synthesize selectedRegion = _selectedRegion;
@synthesize selectedLine = _selectedLine;
@synthesize filterString = _filterString;
@synthesize subwayView = _subwayView;
@synthesize showingSubwayPage = _showingSubwayPage;
@synthesize oldFilterIndex = _oldFilterIndex;

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
    self.subwayView = (MBCRSubwayAlertsView *)[MBCRSubwayAlertsView view];
    self.subwayView.containedInViewController = self;
    self.subwayView.subwayAlertsFetchedResultsController = [[MBCRDataManager shared] subwayAlertsFetchResultsController];

    self.alertsFetchedResultsController = [[MBCRDataManager shared] alertsFetchResultsController];
    self.navigationItem.rightBarButtonItem  = [[UIBarButtonItem alloc] initWithTitle:@"Subway" style:UIBarButtonItemStylePlain target:self action:@selector(showSubwayInformation)];
    self.navigationItem.leftBarButtonItem = [((MBCRAppDelegate *)[[UIApplication sharedApplication] delegate]) createLeftBarImage];
    self.filterString = @"All";
    self.oldFilterIndex = 0;
    
}

- (void)viewDidUnload
{
    [self setTableHeader:nil];
    [self setTableTitle:nil];
    [self setMbcrAlertsView:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self viewWillShow];
    [((MBCRAppDelegate *)[[UIApplication sharedApplication] delegate]) updateAlertsTabBarImage];
}

- (void)viewWillShow {
    [[MBCRServiceManager shared] downloadTAlerts];
    [[MBCRServiceManager shared] downloadAllPageAlerts];
    [[LocalyticsSession sharedLocalyticsSession] tagScreen:kLocalScreenMBCRMessage];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


-(void)setAlertsFetchedResultsController:(NSFetchedResultsController *)alertsFetchedResultsController
{
    //fetch the objects
    NSError *error;
	if ([alertsFetchedResultsController performFetch:&error])
    {
        _alertsFetchedResultsController.delegate = nil;
        alertsFetchedResultsController.delegate = self;
        _alertsFetchedResultsController = alertsFetchedResultsController;
        
        [self.alertsTableView reloadData];
    }
    else
    {
		// Update to handle the error appropriately.
		RZLog(@"Unresolved error in MBCRAlertsViewController %@, %@", error, [error userInfo]);
	}
}

- (void)showSubwayInformation {
    self.navigationItem.rightBarButtonItem.enabled = NO;
    self.navigationItem.rightBarButtonItem.title = (self.showingSubwayPage) ? @"Subway" : @" MBCR ";
    UIViewAnimationOptions options = (self.showingSubwayPage) ? UIViewAnimationOptionTransitionFlipFromLeft : UIViewAnimationOptionTransitionFlipFromRight;
    [UIView transitionWithView:self.view duration:kViewFlipDuration options:options animations:^{
        if (!self.showingSubwayPage) {
            [self.mbcrAlertsView removeFromSuperview];
            [self.view addSubview:self.subwayView];
            [self.subwayView viewWillShow];
        } else {
            [self.subwayView removeFromSuperview];
            [self.view addSubview:self.mbcrAlertsView];
            [self viewWillShow];
        }
    } completion:^(BOOL finished) {
        self.showingSubwayPage = ! self.showingSubwayPage;
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }];
}

- (IBAction)filterControlChanged:(id)sender {

    RZLog(@"FilterSet:%d",self.filterControl.selectedSegmentIndex);
    switch (self.filterControl.selectedSegmentIndex) {
        case 0: {
            self.filterString = @"All";
            self.alertsFetchedResultsController = [[MBCRDataManager shared] alertsFetchResultsController];
            [[UAPush shared] setTags:[NSMutableArray arrayWithObjects:kUAAllTag,@"North",@"South", nil]];
            [[UAPush shared] updateRegistration];
            NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                        @"All", kLocalAttributeType,
                                        nil];
            [[LocalyticsSession sharedLocalyticsSession] tagEvent:kLocalActionMessageFilter attributes:dictionary];
        }
            break;
        case 1: {
            self.pickerView = [((MBCRAppDelegate *)[[UIApplication sharedApplication] delegate]) createPickerView];
            [self.pickerView setPickerViewType:PickerTypeRegion];
            self.pickerView.delegate = self;
            [self.pickerView.picker setShowsSelectionIndicator:YES];
            self.pickerView.selectedRegion = self.selectedRegion;
            [self.pickerView showView];
            [self.pickerView selectRowForRegionType:self.selectedRegion];
        }break;
        case 2: {
            self.pickerView = [((MBCRAppDelegate *)[[UIApplication sharedApplication] delegate]) createPickerView];
            [self.pickerView setPickerViewType:PickerTypeLine];
            [self.pickerView setResultsController:[[MBCRDataManager shared] lineFetchResultsController]];
            [self.pickerView showView];
            self.pickerView.selectedLines = [NSMutableArray arrayWithArray:self.selectedLines];
            self.pickerView.delegate = self;
        }break;
        case 3: {
            
            self.pickerView = [((MBCRAppDelegate *)[[UIApplication sharedApplication] delegate]) createPickerView];
            self.pickerView.selectedTrain = self.selectedTrain;
            self.pickerView.selectedLine = self.selectedLine;
            [self.pickerView setPickerViewType:PickerTypeTrain];
            [self.pickerView setResultsController:[[MBCRDataManager shared] lineFetchResultsController]];
            [self.pickerView.picker setShowsSelectionIndicator:YES];
            
            [self.pickerView showView];

            self.pickerView.delegate = self;
        }
    }
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    MBCRAlert* alert = [self.alertsFetchedResultsController objectAtIndexPath:indexPath];
    MBCRAlertDetailsViewController* detailsVC = [[MBCRAlertDetailsViewController alloc] init];
    [self.navigationController pushViewController:detailsVC animated:YES];
    [detailsVC updateViewWithAlert:alert];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 98.0f;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.alertsFetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* cellIdentifier = @"alertsIdentifier";

    MBCRAlertCell*cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = (MBCRAlertCell *)[MBCRAlertCell view];
    }
    
    MBCRAlert* alert = [self.alertsFetchedResultsController objectAtIndexPath:indexPath];
    [cell setAlert:alert];
    return cell;
}



- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.alertsFetchedResultsController sections] objectAtIndex:section];
    if ([sectionInfo numberOfObjects] < 1) {
        return self.alertsTableView.frame.size.height;
    } else {
        return 23.0;
    }
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.alertsFetchedResultsController sections] objectAtIndex:section];
    if ([sectionInfo numberOfObjects] < 1) {
        MBCRNoDataView* v = (MBCRNoDataView *)[MBCRNoDataView view];
        return v;
    } else {
        self.tableTitle.text = self.filterString;
        return self.tableHeader;
    }
}


#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.alertsTableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller 
  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex 
     forChangeType:(NSFetchedResultsChangeType)type {
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.alertsTableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete:
            [self.alertsTableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    
    switch(type) {
        case NSFetchedResultsChangeInsert: {
            [self.alertsTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
        } break;
        case NSFetchedResultsChangeDelete: {
            [self.alertsTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        } break;
        case NSFetchedResultsChangeMove: {
            [self.alertsTableView moveRowAtIndexPath:indexPath toIndexPath:newIndexPath];
        } break;
        case NSFetchedResultsChangeUpdate: {
            MBCRAlertCell *cell = (MBCRAlertCell*)[self.alertsTableView cellForRowAtIndexPath:indexPath];
            [cell setAlert:(MBCRAlert *)anObject];
        } break;
        default:
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.alertsTableView endUpdates];
    
    //For some reason when we update an AllPageAlert the delete gets called on that instead of Update.
    //Setting this refreshes the Fetch and updates the Table.  Finding a fix for this would be good, but Im not making any progress now.
    self.alertsFetchedResultsController = self.alertsFetchedResultsController;
}

#pragma mark - PickerView Methods
- (void)pickerViewDidCancel:(MBCRPickerView *)picker {
    self.filterControl.selectedSegmentIndex = self.oldFilterIndex;
}
- (void)pickerViewDidPickValue:(MBCRPickerView *)picker {
    switch (picker.pickerViewType) {
        case PickerTypeRegion: {
            self.selectedRegion = picker.selectedRegion;
            self.filterString = (self.selectedRegion == RegionFilterTypeNorth) ? @"North" : @"South";
            self.alertsFetchedResultsController = [[MBCRDataManager shared] alertsFetchResultsControllerFilterByRegion:self.filterString];
            [[UAPush shared] setTags:[NSMutableArray arrayWithObjects:self.filterString,kUAAllTag, nil]];
            [[UAPush shared] updateRegistration];
            NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                        self.filterString, kLocalAttributeRegion,
                                        @"Region", kLocalAttributeType,
                                        nil];
            [[LocalyticsSession sharedLocalyticsSession] tagEvent:kLocalActionMessageFilter attributes:dictionary];
            
        } break;
        case PickerTypeLine: {
            self.selectedLines = picker.selectedLines;

            NSMutableString* header = [[NSMutableString alloc] init];
            NSMutableArray* lineIds = [[NSMutableArray alloc] initWithCapacity:self.selectedLines.count];
            if (self.selectedLines.count > 0) {
                for (Line * line in self.selectedLines) {
                    [header appendFormat:@"%@, ",line.lineDescription];
                    [lineIds addObject:[NSString stringWithFormat:@"%@",line.lineId]];
                }
                [lineIds addObject:kUAAllTag];
                self.filterString = [header substringToIndex:[header length] - 2];
                self.alertsFetchedResultsController = [[MBCRDataManager shared] alertsFetchResultsControllerFilterByLines:picker.selectedLines];
                [[UAPush shared] setTags:lineIds];
                [[UAPush shared] updateRegistration];
                NSDictionary *dictionary;
                if(self.selectedLines.count < 2) {
                    Line* line = [self.selectedLines objectAtIndex:0];
                    dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                  line.region, kLocalAttributeRegion,
                                  line.lineDescription, kLocalAttributeLine,
                                  @"Line", kLocalAttributeType,
                                  nil];
                }
                [[LocalyticsSession sharedLocalyticsSession] tagEvent:kLocalActionMessageFilter attributes:dictionary];
            } else {
                self.filterString = @"None";
            }
            
        } break;
        case PickerTypeTrain: {
            self.selectedTrain = picker.selectedTrain;
            self.selectedLine = picker.selectedLine;
            self.filterString = [NSString stringWithFormat:@"%@ %@",picker.selectedLine.lineDescription, picker.selectedTrain.trainNo];
            self.alertsFetchedResultsController = [[MBCRDataManager shared] alertsFetchResultsControllerFilterByTrain:picker.selectedTrain];
            [[UAPush shared] setTags:[NSMutableArray arrayWithObjects:[NSString stringWithFormat:@"%@",picker.selectedLine.lineId],kUAAllTag,nil]];
            [[UAPush shared] updateRegistration];
            NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                        self.selectedTrain.line.region, kLocalAttributeRegion,
                                        self.selectedTrain.line.lineDescription, kLocalAttributeLine,
                                        @"Train", kLocalAttributeType,
                                        nil];
            [[LocalyticsSession sharedLocalyticsSession] tagEvent:kLocalActionMessageFilter attributes:dictionary];
        } break;
        case PickerTypeAVLFilteredTrain: {
            self.selectedTrain = picker.selectedTrain;
            self.selectedLine = picker.selectedLine;
            self.filterString = [NSString stringWithFormat:@"%@ %@",picker.selectedLine.lineDescription, picker.selectedTrain.trainNo];
            self.alertsFetchedResultsController = [[MBCRDataManager shared] alertsFetchResultsControllerFilterByTrain:picker.selectedTrain];
            NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                        self.selectedTrain.line.region, kLocalAttributeRegion,
                                        self.selectedTrain.line.lineDescription, kLocalAttributeLine,
                                        @"Train", kLocalAttributeType,
                                        nil];
            [[LocalyticsSession sharedLocalyticsSession] tagEvent:kLocalActionMessageFilter attributes:dictionary];
        } break;
    }
    self.oldFilterIndex = self.filterControl.selectedSegmentIndex;
}

@end
