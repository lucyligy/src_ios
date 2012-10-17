//
//  MBCRPickerView.h
//  MBCR
//
//  Created by Alex Rouse on 7/2/12.
//  Copyright (c) 2012 Raizlabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewFactory.h"
#import "Line+Display.h"
#import "Train.h"
#import "MBCRPickerViewCell.h"

@class MBCRPickerView;
@protocol MBCRPickerViewDelegate <NSObject>
- (void)pickerViewDidPickValue:(MBCRPickerView *)picker;
- (void)pickerViewDidCancel:(MBCRPickerView *)picker;

@end

typedef enum{
	PickerTypeRegion = 0,
    PickerTypeLine,
    PickerTypeTrain,
    PickerTypeAVLFilteredTrain
} PickerViewType;

typedef enum {
    RegionFilterTypeNorth = 0,
    RegionFilterTypeSouth
} MBCRRegionFilterType;


@interface MBCRPickerView : UIView <UIPickerViewDelegate, NSFetchedResultsControllerDelegate, MBCRPickerViewCellDelegate>


@property (nonatomic, weak) IBOutlet UIPickerView* picker;
@property (weak, nonatomic) IBOutlet UILabel *textHeader;
@property (weak, nonatomic) IBOutlet UILabel *textBody;
@property (weak, nonatomic) IBOutlet UIView *backgroundView;
@property (weak, nonatomic) IBOutlet UIView *pickerContainer;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (nonatomic, strong) NSFetchedResultsController* resultsController;
@property (nonatomic, assign) PickerViewType pickerViewType;
@property (nonatomic, weak)   id<MBCRPickerViewDelegate> delegate;

@property (nonatomic, strong) Line* selectedLine;
@property (nonatomic, strong) Train* selectedTrain;
@property (nonatomic, assign) MBCRRegionFilterType selectedRegion;
@property (nonatomic, strong) NSMutableArray* selectedLines;

- (IBAction)donePressed:(id)sender;
- (IBAction)cancelPressed:(id)sender;
- (void)selectRowForRegionType:(MBCRRegionFilterType)type;
- (void)showView;
- (void)removeView;
@end
