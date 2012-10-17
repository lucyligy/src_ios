//
//  MBCRPickerViewCell.m
//  MBCR
//
//  Created by Alex Rouse on 7/30/12.
//  Copyright (c) 2012 Raizlabs. All rights reserved.
//

#import "MBCRPickerViewCell.h"

@implementation MBCRPickerViewCell
@synthesize infoLabel = _infoLabel;
@synthesize checkImage = _checkImage;
@synthesize pressGestureRecongnizer = _pressGestureRecongnizer;
@synthesize delegate = _delegate;
@synthesize currentLine = _currentLine;
@synthesize currentTrain = _currentTrain;
@synthesize currentRegion = _currentRegion;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)updateImage {
    [self.checkImage setHidden:!self.checkImage.hidden]; 
}

- (IBAction)gestureFired:(UIGestureRecognizer *)sender {
    if ([self.delegate shouldUpdateCell:self]) {
        [self updateImage];
    }
}


@end
