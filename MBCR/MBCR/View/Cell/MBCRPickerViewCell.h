//
//  MBCRPickerViewCell.h
//  MBCR
//
//  Created by Alex Rouse on 7/30/12.
//  Copyright (c) 2012 Raizlabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Line.h"
#import "Train.h"

@protocol MBCRPickerViewCellDelegate <NSObject>
- (BOOL)shouldUpdateCell:(id)cell;

@end

//TODO: Remove this and go off the Definition in MBCRPickerView
typedef enum {
    RegionFilterTypeNorthForCell = 0,
    RegionFilterTypeSouthForCell
} MBCRRegionFilterTypeForCell;


@interface MBCRPickerViewCell : UIView
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (weak, nonatomic) IBOutlet UIImageView *checkImage;
@property (weak, nonatomic) IBOutlet UITapGestureRecognizer *pressGestureRecongnizer;
@property (weak, nonatomic) id<MBCRPickerViewCellDelegate> delegate;

@property (strong, nonatomic) Train* currentTrain;
@property (strong, nonatomic) Line* currentLine;
@property (nonatomic, assign) MBCRRegionFilterTypeForCell currentRegion;

- (IBAction)gestureFired:(id)sender;
- (void)updateImage;
@end
