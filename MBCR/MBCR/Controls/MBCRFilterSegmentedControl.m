//
//  MBCRFilterSegmentedControl.m
//  MBCR
//
//  Created by Alex Rouse on 8/8/12.
//
//

#import "MBCRFilterSegmentedControl.h"

@implementation MBCRFilterSegmentedControl

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSInteger current = self.selectedSegmentIndex;
    [super touchesBegan:touches withEvent:event];
    
    if (current == self.selectedSegmentIndex) {
        [self setSelectedSegmentIndex:current];
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
}

@end
