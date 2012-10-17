//
//  MBCRAVLDetailsViewController.m
//  MBCR
//
//  Created by Alex Rouse on 7/27/12.
//  Copyright (c) 2012 Raizlabs. All rights reserved.
//

#import "MBCRAVLDetailsViewController.h"
#import "MBCRAppDelegate.h"
#import "MBCRAVLDetailsCell.h"
#import "UIViewFactory.h"
#import "Train.h"
#import "NSDate+Formatter.h"

#define kAVLRows            11

@interface MBCRAVLDetailsViewController ()
@property (strong, nonatomic) NSArray* labelTitles;
@property (strong, nonatomic) NSArray* avlValues;
@end

@implementation MBCRAVLDetailsViewController
@synthesize tableView = _tableView;
@synthesize avl = _avl;

@synthesize labelTitles = _labelTitles;
@synthesize avlValues = _avlValues;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)awakeFromNib {
    self.navigationController.hidesBottomBarWhenPushed = YES;
}

- (void)viewDidLoad
{
    self.labelTitles = [NSArray arrayWithObjects:@"Timestamp",@"Train",@"Destination",@"Stop",@"Scheduled",@"Flag",@"Vehicle",@"Lateness",@"Latitude",@"Longitude",@"Heading", nil];
    self.title = [NSString stringWithFormat:@"%@ AVL",self.avl.train.trainNo];
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [self setTableView:nil];
    [super viewDidUnload];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[LocalyticsSession sharedLocalyticsSession] tagScreen:kLocalScreenLocationDetails];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)setAvl:(AVL *)avl {
    _avl = avl;
    self.avlValues = [NSArray arrayWithObjects:[avl.timestamp fullTimeFormat],(avl.train) ? avl.train.trainNo : [avl.trip description] ,avl.destination,avl.stop,[avl.scheduled clockTimeFormat],avl.flag,[avl.vehicle description],[avl.lateness description],[avl.latitude description],[avl.longitude description], [avl.heading description], nil];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MBCRAVLDetailsCell* cell = [tableView dequeueReusableCellWithIdentifier:@"avldetails"];
    if (cell == nil ) {
        cell = (MBCRAVLDetailsCell *)[MBCRAVLDetailsCell view];
    }
    cell.valueLabel.text = [self.avlValues objectAtIndex:indexPath.row];
    cell.fieldLabel.text = [self.labelTitles objectAtIndex:indexPath.row];
    return cell;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return kAVLRows;
}
@end
