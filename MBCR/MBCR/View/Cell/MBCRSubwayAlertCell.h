//
//  MBCRSubwayAlertCell.h
//  MBCR
//
//  Created by Joe Mahon on 6/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SubwayAlert.h"

@interface MBCRSubwayAlertCell : UITableViewCell

@property (nonatomic, weak)IBOutlet UILabel* pubDateLabel;
@property (nonatomic, weak)IBOutlet UILabel* descriptionLabel;
@property (nonatomic, weak)IBOutlet UIView* rtAlertView;
@property (weak, nonatomic) IBOutlet UILabel *lineLabel;
@property (weak, nonatomic) IBOutlet UIImageView *lineColorImage;

- (void)setAlert:(SubwayAlert *)alert;

@end
