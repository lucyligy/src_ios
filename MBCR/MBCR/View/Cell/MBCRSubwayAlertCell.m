//
//  MBCRSubwayAlertCell.m
//  MBCR
//
//  Created by Joe Mahon on 6/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MBCRSubwayAlertCell.h"
#import "NSDate+Formatter.h"
#import "UIColor+MBCRColors.h"


@implementation MBCRSubwayAlertCell

@synthesize descriptionLabel = _descriptionLabel;
@synthesize pubDateLabel = _pubDateLabel;
@synthesize rtAlertView = _rtAlertView;
@synthesize lineLabel = _lineLabel;
@synthesize lineColorImage = _lineColorImage;


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

- (void)setAlert:(SubwayAlert *)alert
{
    //self.titleLabel.text = alert.title;
    self.descriptionLabel.lineBreakMode = UILineBreakModeWordWrap | UILineBreakModeTailTruncation;
    self.pubDateLabel.text = [alert.receivedOn displayTimeSinceNow];
    self.descriptionLabel.text = alert.message;
    if (alert.line != nil && alert.line.length > 0) {
        self.lineLabel.hidden = NO;
        self.lineLabel.text = [NSString stringWithFormat:@"%@ Line",alert.line];
    } else {
        self.lineLabel.hidden = YES;
    }
    if ([alert.line isEqualToString:kSubwayGreenLineKey]) {
        self.lineColorImage.image = [UIImage imageNamed:@"green_line_cell_indicator"];
    } else if ([alert.line isEqualToString:kSubwayRedLineKey]) {
        self.lineColorImage.image = [UIImage imageNamed:@"red_line_cell_indicator"];
    } else if ([alert.line isEqualToString:kSubwayBlueLineKey]) {
        self.lineColorImage.image = [UIImage imageNamed:@"blue_line_cell_indicator"];
    } else if ([alert.line isEqualToString:kSubwayOrangeLineKey]) {
        self.lineColorImage.image = [UIImage imageNamed:@"orange_line_cell_indicator"];
    } else if ([alert.line isEqualToString:kSubwaySilverLineKey]) {
        self.lineColorImage.image = [UIImage imageNamed:@"silver_line_cell_indicator"];
    } else {
        self.lineColorImage.image = nil;
    }
}

@end
