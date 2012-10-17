//
//  MBCRTrackAssignmentCell.m
//  MBCR
//
//  Created by Joe Mahon on 6/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MBCRTrackAssignmentCell.h"
#import "NSDate+Formatter.h"
#import "Line.h"
#import "Train.h"
#import "UIColor+MBCRColors.h"

@implementation MBCRTrackAssignmentCell
@synthesize trackLabel = _trackLabel;
@synthesize departureLabel = _departureLabel;
@synthesize lineLabel = _lineLabel;
@synthesize statusLabel = _statusLabel;
@synthesize trackAssignmentView = _trackAssignmentView;
@synthesize lightImage = _lightImage;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (void)setTrackAssignment:(TrackAssignment *)assignment
{
    if (assignment.train != nil) {
        self.lineLabel.text = [NSString stringWithFormat:@"%@ %@",[assignment.train.line.lineDescription uppercaseString], assignment.train.trainNo];
    } else {
        self.lineLabel.text = [NSString stringWithFormat:@"%@ %@",assignment.carrier, assignment.trainNo];
    }
    if ([assignment.track intValue] > 0) {
        self.trackLabel.text = [NSString stringWithFormat:@"TRACK %@",[assignment.track stringValue]];
    } else {
        self.trackLabel.text = @"TBA";
    }
    self.departureLabel.text = [assignment.predictedDepartureTime clockTimeFormat];
    if ([assignment.status isEqualToString:@"ALL ABOARD"]) {
        self.lightImage.image = [UIImage imageNamed:@"track_assignment_boarding_light_red"];
    } else if ([assignment.status isEqualToString:@"NOW BOARDING"]) {
        self.lightImage.image = [UIImage imageNamed:@"track_assignment_boarding_light_green"];
    } else {
        self.lightImage.image = [UIImage imageNamed:@"track_assignment_boarding_light_unlit"];
    }
    self.statusLabel.text = assignment.status;
    if ([assignment.departureTime compare:[NSDate date]] == NSOrderedAscending) {
        self.statusLabel.text = @"ALL ABOARD";
        self.lightImage.image = [UIImage imageNamed:@"track_assignment_boarding_light_red"];
    }
}


@end
