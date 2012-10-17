//
//  MBCRReferenceCell.m
//  MBCR
//
//  Created by Alex Rouse on 7/3/12.
//  Copyright (c) 2012 Raizlabs. All rights reserved.
//

#import "MBCRReferenceCell.h"

@implementation MBCRReferenceCell

@synthesize cellTitle = _cellTitle;
@synthesize unreadIndicatorView = _unreadIndicatorView;
@synthesize unreadIndicatorLabel = _unreadIndicatorLabel;
@synthesize unreadIndicatorBackgroundImage = _unreadIndicatorBackgroundImage;

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

- (void)setUnreadCount:(NSInteger)count {
    if (count > 0) {
        self.unreadIndicatorView.hidden = NO;
        self.unreadIndicatorBackgroundImage.image = [[UIImage imageNamed:@"indicator_bg_bulletins_notices_stretchable"] stretchableImageWithLeftCapWidth:14 topCapHeight:13];
        NSString* countStr = [NSString stringWithFormat:@"%d",count];
        CGSize s = [countStr sizeWithFont:self.unreadIndicatorLabel.font];
        CGRect f = self.unreadIndicatorView.frame;
        f.size.width = s.width + 15;
        f.origin.x = self.frame.size.width - (f.size.width + 25);
        self.unreadIndicatorView.frame = f;
        self.unreadIndicatorLabel.text = countStr;
    } else {
        self.unreadIndicatorView.hidden = YES;
    }
}
@end
