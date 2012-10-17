//
//  MBCRTrackAssignmentDetailsViewController.h
//  MBCR
//
//  Created by Alex Rouse on 7/13/12.
//  Copyright (c) 2012 Raizlabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TrackAssignment.h"

@interface MBCRTrackAssignmentDetailsViewController : UIViewController
@property (nonatomic, weak) IBOutlet UILabel* trackNumberLabel;
@property (nonatomic, weak) IBOutlet UILabel* departureTimeLabel;

- (void)updateViewWithTrackAssignment:(TrackAssignment *)assignment;

@end
