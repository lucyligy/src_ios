//
//  Line+Display.m
//  MBCR
//
//  Created by Alex Rouse on 6/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Line+Display.h"

@implementation Line (Display)

- (NSArray *)allTrains {
    return [self.trains sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"trainNo" ascending:YES]]];
}

@end
