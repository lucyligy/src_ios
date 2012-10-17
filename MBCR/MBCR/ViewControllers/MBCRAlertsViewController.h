//
//  MBCRAlertsViewController.h
//  MBCR
//
//  Created by Alex Rouse on 6/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBCRPickerView.h"
#import "MBCRFilterSegmentedControl.h"


@interface MBCRAlertsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate, MBCRPickerViewDelegate>

@property(nonatomic, strong) IBOutlet UITableView* alertsTableView;
@property(nonatomic, weak) IBOutlet MBCRFilterSegmentedControl* filterControl;
@property (strong, nonatomic) IBOutlet UIView *tableHeader;
@property (weak, nonatomic) IBOutlet UILabel *tableTitle;
@property (strong, nonatomic) IBOutlet UIView *mbcrAlertsView;
@property(nonatomic, strong) MBCRPickerView* pickerView;

@property(nonatomic, assign) MBCRRegionFilterType regionFilter;

- (IBAction)filterControlChanged:(id)sender;

@end
