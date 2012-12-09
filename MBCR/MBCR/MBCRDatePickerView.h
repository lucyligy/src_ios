//
//  MBCRDatePicker.h
//  MBCR
//
//  Created by Lucy Li on 12/3/12.
//
//

#import <UIKit/UIKit.h>

@protocol MBCRDatePickerViewDelegate;


@interface MBCRDatePickerView : UIViewController

@property (nonatomic, weak) id<MBCRDatePickerViewDelegate> delegate;
@property (nonatomic, weak) IBOutlet UIDatePicker *datePicker;

-(IBAction)done:(id)sender;
-(IBAction)cancel:(id)sender;

@end

@protocol MBCRDatePickerViewDelegate <NSObject>

-(void) mbcrDatePickerView:(MBCRDatePickerView *)datePicker didPickDate: (NSDate *) date;

@end
