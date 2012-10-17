//
//  MBCRReferenceCell.h
//  MBCR
//
//  Created by Alex Rouse on 7/3/12.
//  Copyright (c) 2012 Raizlabs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MBCRReferenceCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel* cellTitle;
@property (nonatomic, weak) IBOutlet UIView* unreadIndicatorView;
@property (nonatomic, weak) IBOutlet UILabel* unreadIndicatorLabel;
@property (weak, nonatomic) IBOutlet UIImageView *unreadIndicatorBackgroundImage;


- (void)setUnreadCount:(NSInteger)count;

@end
