//
//  MBCRAlertDetailsViewController.h
//  MBCR
//
//  Created by Alex Rouse on 6/15/12.
//  Copyright (c) 2012 Raizlabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBCRAlert.h"
#import "SubwayAlert.h"

@interface MBCRAlertDetailsViewController : UIViewController
@property (nonatomic, weak) IBOutlet UITextView* messageTextView;
@property (nonatomic, weak) IBOutlet UILabel* sentDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *lineLabel;
@property (weak, nonatomic) IBOutlet UIView *alertTypeView;
@property (weak, nonatomic) IBOutlet UIImageView *alertColor;

- (void)updateViewWithAlert:(MBCRAlert *)alert;
- (void)updateViewWithSubwayAlert:(SubwayAlert *)alert;

@end
