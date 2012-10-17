//
//  MBCRSubwayAlertsView.h
//  MBCR
//
//  Created by Alex Rouse on 8/7/12.
//
//

#import <UIKit/UIKit.h>

@interface MBCRSubwayAlertsView : UIView <UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate>

@property(nonatomic, weak) IBOutlet UITableView* alertsTableView;
@property(nonatomic, weak) IBOutlet UISegmentedControl* segmentedControl;
@property(nonatomic, weak) UIViewController* containedInViewController;
@property (nonatomic, strong) NSFetchedResultsController* subwayAlertsFetchedResultsController;

- (IBAction)segmentedControlChanged:(id)sender;
- (void)viewWillShow;

@end
