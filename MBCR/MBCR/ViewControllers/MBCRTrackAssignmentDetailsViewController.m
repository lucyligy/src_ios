//
//  MBCRTrackAssignmentDetailsViewController.m
//  MBCR
//
//  Created by Alex Rouse on 7/13/12.
//  Copyright (c) 2012 Raizlabs. All rights reserved.
//

#import "MBCRTrackAssignmentDetailsViewController.h"
#import "NSDate+Formatter.h"

@interface MBCRTrackAssignmentDetailsViewController ()

@end

@implementation MBCRTrackAssignmentDetailsViewController
@synthesize trackNumberLabel = _trackNumberLabel;
@synthesize departureTimeLabel = _departureTimeLabel;

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
	// Do any additional setup after loading the view.
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

- (void)updateViewWithTrackAssignment:(TrackAssignment *)assignment 
{
    self.trackNumberLabel.text = [assignment.track description];
    self.departureTimeLabel.text = [assignment.departureTime clockTimeFormat];
}

@end
