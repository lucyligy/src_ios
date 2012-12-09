//
//  MBCROTPViewController.m
//  MBCR
//
//  Created by Lucy Li on 11/26/12.
//
//

#import "MBCROTPViewController.h"
#import "MBCRAppDelegate.h"

@interface MBCROTPViewController ()

@end

@implementation MBCROTPViewController



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

//    MBCRAppDelegate *appDelegate = (MBCRAppDelegate *)[[UIApplication sharedApplication] delegate];
//    self.navigationItem.rightBarButtonItem = [appDelegate createLeftBarImage];
    _dateFormatter = [[NSDateFormatter alloc] init];
    [_dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    [_dateFormatter setDateFormat:@"M/d/yyyy"];
    
   // _date = [[NSDate alloc]initWithTimeIntervalSince1970:_datePicker.date.timeIntervalSince1970];
    _date = [NSDate date];
    
    UIBarButtonItem *navButton= [[UIBarButtonItem alloc] initWithTitle:[_dateFormatter stringFromDate:_date]
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:self
                                                                 action: @selector(changeDate)];    
    
    self.navigationItem.rightBarButtonItem = navButton;
    
    //NSString *theTitle = [NSString stringWithFormat:@"OTP: %@", [_dateFormatter stringFromDate:_date]];
    self.title = @"OTP";
 
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) changeDate
{
    MBCRDatePickerView *datePicker = [[MBCRDatePickerView alloc] initWithNibName:nil bundle:nil];
    datePicker.delegate = self;
    [self presentModalViewController: datePicker  animated:YES];
}


# pragma -mark - picker view delegate
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel* tView = (UILabel*)view;
    if (!tView){
        tView = [[UILabel alloc] init];
        
        // Add label.text which is the picker value for the row (for that component)
        
        // set the font for the label as black.
        tView.font = [UIFont boldSystemFontOfSize:14];        
    }
    
    return view;
}

# pragma -mark - MBCRDatePicker delegate
- (void) mbcrDatePickerView:(MBCRDatePickerView *)datePicker didPickDate:(NSDate *)date
{
    _date = date;
    self.navigationItem.rightBarButtonItem.title = [_dateFormatter stringFromDate:_date];
}
@end
