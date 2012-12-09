//
//  MBCROTPViewController.h
//  MBCR
//
//  Created by Lucy Li on 11/26/12.
//
//

#import <UIKit/UIKit.h>
#import "MBCRDatePickerView.h"

@interface MBCROTPViewController : UIViewController<NSFetchedResultsControllerDelegate, UIPickerViewDelegate, MBCRDatePickerViewDelegate>
{
    NSDate *_date;
    NSDateFormatter *_dateFormatter;
}
@end
