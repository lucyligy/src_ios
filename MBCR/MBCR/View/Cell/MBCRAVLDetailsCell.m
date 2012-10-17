//
//  MBCRAVLDetailsCell.m
//  MBCR
//
//  Created by Alex Rouse on 7/27/12.
//  Copyright (c) 2012 Raizlabs. All rights reserved.
//

#import "MBCRAVLDetailsCell.h"

@implementation MBCRAVLDetailsCell
@synthesize fieldLabel = _fieldLabel;
@synthesize valueLabel = _valueLabel;

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

@end
