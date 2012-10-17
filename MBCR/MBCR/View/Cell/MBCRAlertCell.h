//
//  MBCRAlertCell.h
//  MBCR
//
//  Created by Alex Rouse on 6/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBCRAlert.h"
#import "TAlert.h"
#import "AllPageAlert.h"

@interface MBCRAlertCell : UITableViewCell

@property(nonatomic, weak)IBOutlet UIView* tAlertView;
@property(nonatomic, weak)IBOutlet UILabel* dateLabel;
@property(nonatomic, weak)IBOutlet UILabel* lineLabel;
@property(nonatomic, weak)IBOutlet UILabel* descriptionLabel;
@property(nonatomic, weak)IBOutlet UIView* alertTypeView;
@property (weak, nonatomic) IBOutlet UIImageView *iconIndicator;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (strong, nonatomic) MBCRAlert* alert;
- (void)setAlert:(MBCRAlert *)alert;
@end
