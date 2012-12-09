//
//  MBCRDatePicker.m
//  MBCR
//
//  Created by Lucy Li on 12/3/12.
//
//

#import "MBCRDatePickerView.h"

@interface MBCRDatePickerView ()

@end


@implementation MBCRDatePickerView

@synthesize datePicker = _datePicker;
@synthesize delegate = _delegate;

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)done:(id)sender
{
    if ([_delegate respondsToSelector:@selector(mbcrDatePickerView:didPickDate:)])
    {
        [_delegate mbcrDatePickerView:self didPickDate:_datePicker.date];

    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

-(IBAction)cancel:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];    
}
@end
