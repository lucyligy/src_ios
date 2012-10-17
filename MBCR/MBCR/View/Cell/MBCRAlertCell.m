//
//  MBCRAlertCell.m
//  MBCR
//
//  Created by Alex Rouse on 6/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MBCRAlertCell.h"
#import "Line.h"
#import "Train.h"
#import "NSDate+Formatter.h"
#import "UIColor+MBCRColors.h"

#define kAlertDefaultFrame  CGRectMake(38,32,277,42)
#define kAlertNoLineFrame   CGRectMake(38,6,277,64)
#define kAlertTwoLineFrame  CGRectMake(38,6,277,42)

@implementation MBCRAlertCell
@synthesize tAlertView = _tAlertView;
@synthesize dateLabel = _dateLabel;
@synthesize lineLabel = _lineLabel;
@synthesize descriptionLabel = _descriptionLabel;
@synthesize alertTypeView = _alertTypeView;
@synthesize iconIndicator = _iconIndicator;
@synthesize backgroundImageView = _backgroundImageView;
@synthesize alert = _alert;
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

- (void)setHighlighted:(BOOL)highlighted {
    
    [super setHighlighted:highlighted];
}
- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    if([self.alert isKindOfClass:[AllPageAlert class]]) {
        self.backgroundImageView.hidden = highlighted;
    }
    [super setHighlighted:highlighted animated:animated];
}


- (void)setAlert:(MBCRAlert *)alert {
    _alert = alert;
    if([alert isKindOfClass:[TAlert class]]) {
        TAlert* tAlert = (TAlert *)alert;
        self.lineLabel.hidden = NO;
        self.lineLabel.text = [NSString stringWithFormat:@"%@ %@", ((Line *)[tAlert.line anyObject]).lineDescription, (tAlert.train && tAlert.train.count > 0) ? ((Train *)[tAlert.train anyObject]).trainNo : @""];
        self.descriptionLabel.text = tAlert.message;
        self.dateLabel.text = [tAlert.receivedOn displayTimeSinceNow];
        self.iconIndicator.image = [UIImage imageNamed:@"icon_t_alert"];
        self.backgroundImageView.hidden = YES;
        self.descriptionLabel.frame = kAlertDefaultFrame;
    } else if([alert isKindOfClass:[AllPageAlert class]]) {
        AllPageAlert* allAlert = (AllPageAlert *)alert;
        if(allAlert.line != nil && allAlert.line.count > 0) {
            self.lineLabel.hidden = NO;
            self.lineLabel.text = [NSString stringWithFormat:@"%@ %@", ((Line *)[allAlert.line anyObject]).lineDescription, (allAlert.train && allAlert.train.count > 0) ? ((Train *)[allAlert.train anyObject]).trainNo : @""];
            self.descriptionLabel.frame = kAlertDefaultFrame;
        } else {
            self.lineLabel.hidden = YES;
            CGSize s = [allAlert.message sizeWithFont:self.descriptionLabel.font];
            if(s.width <= self.descriptionLabel.frame.size.width*2) {
                self.descriptionLabel.frame = kAlertTwoLineFrame;

            } else {
                self.descriptionLabel.frame = kAlertNoLineFrame;
            }
        }
        self.descriptionLabel.text = allAlert.message;
        self.dateLabel.text = [allAlert.receivedOn displayTimeSinceNow];
        self.iconIndicator.image = [UIImage imageNamed:@"icon_all_page"];
        self.backgroundImageView.hidden = NO;
    }
}

@end
