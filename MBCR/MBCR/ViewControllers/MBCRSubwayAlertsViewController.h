//
//  MBCRSubwayAlertsViewController.h
//  MBCR
//
//  Created by Alex Rouse on 6/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MBCRSubwayAlertsViewController  : UIViewController <UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate>

@property(nonatomic, weak) IBOutlet UITableView* alertsTableView;
@property(nonatomic, weak) IBOutlet UISegmentedControl* segmentedControl;

- (IBAction)segmentedControlChanged:(id)sender;
@end
