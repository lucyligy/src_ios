//
//  MBCRPickerView.m
//  MBCR
//
//  Created by Alex Rouse on 7/2/12.
//  Copyright (c) 2012 Raizlabs. All rights reserved.
//

#import "MBCRPickerView.h"



@interface MBCRPickerView ()

@end

NSString* const kRegionHeaderText   = @"View Messages for Region Only";
NSString* const kRegionBodyText     = @"Choose North or South to recieve messages for only one region.";

NSString* const kLineHeaderText     = @"View Messages for Multiple Lines";
NSString* const kLineBodyText       = @"Scroll through and tap to select the lines for which you would like to recieve messages.";

NSString* const kTrainHeaderText    = @"Select Your Train";
NSString* const kTrainBodyText      = @"Choose a line in the left column and then a train number in the right.";

NSString* const kErrorHeaderText    = @"There was an error getting information";
NSString* const kErrorBodyText      = @"Check your internet connection and try again.";

#define kAnimationAppearInterval    0.5
#define kRightPickerWidth           100

@implementation MBCRPickerView
@synthesize picker = _picker;
@synthesize textHeader = _textHeader;
@synthesize textBody = _textBody;
@synthesize backgroundView = _backgroundView;
@synthesize pickerContainer = _pickerContainer;
@synthesize cancelButton = _cancelButton;
@synthesize doneButton = _doneButton;
@synthesize resultsController = _resultsController;
@synthesize pickerViewType = _pickerViewType;
@synthesize delegate = _delegate;

@synthesize selectedLine = _selectedLine;
@synthesize selectedTrain = _selectedTrain;
@synthesize selectedRegion = _selectedRegion;
@synthesize selectedLines = _selectedLines;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}


- (void)showView {
    
    [self.doneButton setBackgroundImage:[[UIImage imageNamed:@"navbar_button_up"] resizableImageWithCapInsets:UIEdgeInsetsMake(15, 10, 10, 10)] forState:UIControlStateNormal];
    [self.doneButton setBackgroundImage:[[UIImage imageNamed:@"navbar_button_down"] resizableImageWithCapInsets:UIEdgeInsetsMake(15, 10, 10, 10)] forState:UIControlStateSelected];
    
    [self.cancelButton setBackgroundImage:[[UIImage imageNamed:@"navbar_button_gray_up"] resizableImageWithCapInsets:UIEdgeInsetsMake(15, 10, 10, 10)] forState:UIControlStateNormal];
    [self.cancelButton setBackgroundImage:[[UIImage imageNamed:@"navbar_button_gray_down"] resizableImageWithCapInsets:UIEdgeInsetsMake(15, 10, 10, 10)] forState:UIControlStateSelected];
    
    
    self.backgroundView.alpha = 0.0;
    CGRect endFrame = self.pickerContainer.frame;
    self.pickerContainer.frame = CGRectMake(0,self.frame.size.height,endFrame.size.width,endFrame.size.height);
    [UIView animateWithDuration:kAnimationAppearInterval delay:0.0f options:UIViewAnimationCurveEaseInOut animations:^{
        self.backgroundView.alpha = 1.0;
        self.pickerContainer.frame = endFrame;
    } completion:^(BOOL finished) {
        
    }];
    switch (self.pickerViewType) {
        case PickerTypeRegion: {
            self.textHeader.text = kRegionHeaderText;
            self.textBody.text = kRegionBodyText;
        } break;
        case PickerTypeLine: {
            if ([[self.resultsController fetchedObjects] count] > 0) {
                self.textHeader.text = kLineHeaderText;
                self.textBody.text = kLineBodyText;
            }else {
                self.doneButton.enabled = NO;
                self.textHeader.text = kErrorHeaderText;
                self.textBody.text = kErrorBodyText;
            }
        } break;
        case PickerTypeTrain: {
            self.textHeader.text = kTrainHeaderText;
            self.textBody.text = kTrainBodyText;
            [self selectRowForLine:self.selectedLine];
        } break;
        case PickerTypeAVLFilteredTrain: {
            self.textHeader.text = kTrainHeaderText;
            self.textBody.text = kTrainBodyText;
            [self selectRowForLine:self.selectedLine];
        } break;
        default:
            break;
    }
}

- (void)removeView {
    self.backgroundView.alpha = 1.0;
    CGRect endFrame = self.pickerContainer.frame;
    [UIView animateWithDuration:kAnimationAppearInterval delay:0.0f options:UIViewAnimationCurveEaseInOut animations:^{
        self.backgroundView.alpha = 0.0;
        self.pickerContainer.frame =  CGRectMake(0,self.frame.size.height,endFrame.size.width,endFrame.size.height);;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
 
}

- (IBAction)donePressed:(id)sender {
    [self.delegate pickerViewDidPickValue:self];
    [self removeView];
}
- (IBAction)cancelPressed:(id)sender {
    [self.delegate pickerViewDidCancel:self];
    [self removeView];
}

- (void)selectRowForRegionType:(MBCRRegionFilterType)type {
    switch (type) {
        case RegionFilterTypeNorth:
            [self.picker selectRow:0 inComponent:0 animated:YES];
            break;
        case RegionFilterTypeSouth:
            [self.picker selectRow:1 inComponent:0 animated:YES];
        default:
            break;
    }
}

- (void)selectRowForLine:(Line *)line {
    if ([[self.resultsController fetchedObjects] count] > 0) {
        if (self.selectedLine != nil) {
            for (int i=0; i<[self.picker numberOfRowsInComponent:0]; i++) {
                Line* oldLine =((Line *)[self.resultsController objectAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]]);
                if ([oldLine.lineId intValue] == [line.lineId intValue]) {
                    [self.picker selectRow:i inComponent:0 animated:NO];
                    [self pickerView:self.picker didSelectRow:i inComponent:0];
                    return;
                }
            }
        }
        self.selectedLine = ((Line *)[self.resultsController objectAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]]);
        [self.picker selectRow:0 inComponent:0 animated:NO];
        [self pickerView:self.picker didSelectRow:0 inComponent:0];
        [self.picker selectRow:0 inComponent:1 animated:NO];
        [self pickerView:self.picker didSelectRow:0 inComponent:1];
    } else {
        self.doneButton.enabled = NO;
        self.textHeader.text = kErrorHeaderText;
        self.textBody.text = kErrorBodyText;
    }

}

-(void)setResultsController:(NSFetchedResultsController *)resultsController
{
    //fetch the objects
    NSError *error;
	if ([resultsController performFetch:&error])
    {
        _resultsController.delegate = nil;
        resultsController.delegate = self;
        _resultsController = resultsController;
        
        [self.picker reloadAllComponents];
        self.selectedLines = [[NSMutableArray alloc] init];
    }
    else
    {
		// Update to handle the error appropriately.
		RZLog(@"Unresolved error in MBCRPickerView %@, %@", error, [error userInfo]);
	}

}


#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    
}

- (void)controller:(NSFetchedResultsController *)controller 
  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex 
     forChangeType:(NSFetchedResultsChangeType)type {
    switch(type) {
        case NSFetchedResultsChangeInsert:
            break;
        case NSFetchedResultsChangeDelete:
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            break;
        case NSFetchedResultsChangeDelete:
            break;
        case NSFetchedResultsChangeMove:
            break;
        case NSFetchedResultsChangeUpdate:
        {

        }
            break;
        default:
            //We dont really care about any other situations.
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
}




#pragma mark - UIPickerViewControllerDelegate
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    switch (self.pickerViewType) {
        case PickerTypeRegion:
            if (row==RegionFilterTypeNorth) {
                self.selectedRegion = RegionFilterTypeNorth;
                ((MBCRPickerViewCell *)[pickerView viewForRow:row+1 forComponent:component]).checkImage.hidden = YES;
            } else {
                self.selectedRegion = RegionFilterTypeSouth;
                ((MBCRPickerViewCell *)[pickerView viewForRow:row-1 forComponent:component]).checkImage.hidden = YES; 
            }
            ((MBCRPickerViewCell *)[pickerView viewForRow:row forComponent:component]).checkImage.hidden = NO;
                
            break;
        case PickerTypeLine: {
            //This case is handled by the tap recognizer.
        } break;
        case PickerTypeTrain:
            if (component == 0) {
                self.selectedLine = (Line *)[self.resultsController objectAtIndexPath:[NSIndexPath indexPathForRow:row inSection:component]];
                [pickerView reloadComponent:1];
                if([[self.selectedLine allTrains] count] > 0) {
                    [self.picker selectRow:0 inComponent:1 animated:YES];
                    self.selectedTrain = [[self.selectedLine allTrains] objectAtIndex:0];
                    self.doneButton.enabled = YES;
                } else {
                    self.doneButton.enabled = NO;
                }
            } else {
                Train* train = [[self.selectedLine allTrains] objectAtIndex:row];
                if (train != nil) {
                    self.selectedTrain =train;
                    self.doneButton.enabled = YES;
                } else {
                    self.doneButton.enabled = NO;
                }
            }
            break;
        case PickerTypeAVLFilteredTrain:
            if (component == 0) {
                self.selectedLine = (Line *)[self.resultsController objectAtIndexPath:[NSIndexPath indexPathForRow:row inSection:component]];
                [pickerView reloadComponent:1];
                NSArray* filteredTrains = [[self.selectedLine allTrains] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"avl != nil"]];
                if([filteredTrains count] > 0) {
                    [self.picker selectRow:0 inComponent:1 animated:YES];
                    self.selectedTrain = [filteredTrains objectAtIndex:0];
                    self.doneButton.enabled = YES;
                }else {
                    self.doneButton.enabled = NO;
                }
            } else {
                NSArray* filteredTrains = [[self.selectedLine allTrains] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"avl != nil"]];
                if (filteredTrains.count > 0) {
                    Train* train = [filteredTrains objectAtIndex:row];
                    if (train != nil) {
                        self.selectedTrain =train;
                        self.doneButton.enabled = YES;
                    } else {
                        self.doneButton.enabled = NO;
                    }
                } else {
                    
                }
            } break;
        default:
            break;
    }
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    if (self.pickerViewType == PickerTypeTrain || self.pickerViewType == PickerTypeAVLFilteredTrain) {
        if (component == 1) {
            return kRightPickerWidth;
        } else {
            return self.picker.frame.size.width- kRightPickerWidth;
        }
    }
    return self.picker.frame.size.width-10;
}
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    if (self.pickerViewType == PickerTypeTrain || self.pickerViewType == PickerTypeAVLFilteredTrain) {
        return 2;
    }
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    switch (self.pickerViewType) {
        case PickerTypeRegion: {
            return 2;
        }
        case PickerTypeLine: {
            id <NSFetchedResultsSectionInfo> sectionInfo = [[self.resultsController sections] objectAtIndex:component];
            return [sectionInfo numberOfObjects];
        }
        case PickerTypeTrain: {
            if (component == 0 ){
                id <NSFetchedResultsSectionInfo> sectionInfo = [[self.resultsController sections] objectAtIndex:component];
                return [sectionInfo numberOfObjects];
            } else {
                if (self.selectedLine != nil) {
                    return [[self.selectedLine allTrains] count];
                } else {
                    return 0;
                }
            }
            return 0;
        }
        case PickerTypeAVLFilteredTrain: {
            if (component == 0 ){
                id <NSFetchedResultsSectionInfo> sectionInfo = [[self.resultsController sections] objectAtIndex:component];
                return [sectionInfo numberOfObjects];
            } else {
                if (self.selectedLine != nil) {
                    NSArray* filteredTrains = [[self.selectedLine allTrains] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"avl != nil"]];
                    return [filteredTrains count];
                } else {
                    return 0;
                }
                
            }
            return 0;
        }

    }
    return 0;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    
    MBCRPickerViewCell* cell = (MBCRPickerViewCell *)((view != nil) ? view : [MBCRPickerViewCell view]);
    cell.checkImage.hidden = YES;
    switch (self.pickerViewType) {
            
        case PickerTypeRegion:
            if (row==RegionFilterTypeNorth) {
                cell.currentRegion = RegionFilterTypeNorth;
                cell.infoLabel.text = @"North";
            } else {
                cell.currentRegion = RegionFilterTypeSouth;
                cell.infoLabel.text = @"South";
            }
            if (cell.currentRegion == self.selectedRegion) {
                cell.checkImage.hidden = NO;
            }
            [cell removeGestureRecognizer:cell.pressGestureRecongnizer];
            cell.pressGestureRecongnizer = nil;
            break;
            
        case PickerTypeLine:
            cell.currentLine = ((Line *)[self.resultsController objectAtIndexPath:[NSIndexPath indexPathForRow:row inSection:component]]);
            if ([self.selectedLines containsObject:cell.currentLine]) {
                [cell updateImage];
            }
            cell.infoLabel.text = cell.currentLine.lineDescription;
            break;
            
        case PickerTypeTrain: {
            if (component == 1) {
                if (self.selectedLine != nil) {
                    cell.frame = CGRectMake(0,0,kRightPickerWidth,cell.frame.size.height);
                    cell.currentTrain = ((Train *)[[self.selectedLine allTrains] objectAtIndex:row]);
                    cell.infoLabel.text =  [cell.currentTrain.trainNo description];
                } else {
                    cell.infoLabel.text =  @" No Trains";
                }
            } else {
                cell.currentLine = ((Line *)[self.resultsController objectAtIndexPath:[NSIndexPath indexPathForRow:row inSection:component]]);
                cell.infoLabel.text = ((Line *)[self.resultsController objectAtIndexPath:[NSIndexPath indexPathForRow:row inSection:component]]).lineDescription;
            }
            [cell removeGestureRecognizer:cell.pressGestureRecongnizer];
            cell.pressGestureRecongnizer = nil;
        }break;
            
        case PickerTypeAVLFilteredTrain: {
            if (component == 1) {
                cell.frame = CGRectMake(0,0,kRightPickerWidth,cell.frame.size.height);
                if (self.selectedLine != nil) {
                    NSArray* filteredTrains = [[self.selectedLine allTrains] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"avl != nil"]];
                    cell.currentTrain = ((Train *)[filteredTrains objectAtIndex:row]);
                    cell.infoLabel.text =  [cell.currentTrain.trainNo description];
                } else {
                    cell.infoLabel.text =  @" No Trains";
                }
            } else {
                cell.infoLabel.text = ((Line *)[self.resultsController objectAtIndexPath:[NSIndexPath indexPathForRow:row inSection:component]]).lineDescription;
            }
            [cell removeGestureRecognizer:cell.pressGestureRecongnizer];
            cell.pressGestureRecongnizer = nil;
        }break;
        default:
            break;
    }
    
    
    cell.delegate = self;
    
    return cell;
}

#pragma mark - MBCRPickerViewCellDelegate

- (BOOL)shouldUpdateCell:(MBCRPickerViewCell *)cell {
    
    switch (self.pickerViewType) {
        case PickerTypeRegion: {
            return NO;
        }break;
        case PickerTypeLine: {
            if ([self.selectedLines containsObject:cell.currentLine]) {
                [self.selectedLines removeObject:cell.currentLine];
            } else {
                [self.selectedLines addObject:cell.currentLine];
            }
            return YES;
        }break;
        case PickerTypeTrain: {
            self.selectedTrain = cell.currentTrain;
            return NO;
        }break;
        case PickerTypeAVLFilteredTrain: {
            self.selectedTrain = cell.currentTrain;
            return NO;
        }break;
    }
    return NO;
}



@end
