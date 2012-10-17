//
//  AVL+Logic.m
//  MBCR
//
//  Created by Alex Rouse on 7/27/12.
//  Copyright (c) 2012 Raizlabs. All rights reserved.
//

#import "AVL+Logic.h"

@implementation AVL (Logic)

-(NSString *)displayLateness {
    if ([self.lateness intValue] > 1) {
        return [NSString stringWithFormat:@"%d mins late", [self.lateness intValue]/60];
    } else if([self.lateness intValue] >0) {
        return [NSString stringWithFormat:@"%d min late", [self.lateness intValue]/60];
    }else {
        return @"On Time";
    }
}

@end
