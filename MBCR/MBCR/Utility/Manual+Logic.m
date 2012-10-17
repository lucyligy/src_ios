//
//  Manual+Logic.m
//  MBCR
//
//  Created by Alex Rouse on 7/11/12.
//  Copyright (c) 2012 Raizlabs. All rights reserved.
//

#import "Manual+Logic.h"

@implementation Manual (Logic)


- (BOOL)isDownloaded {
    return (self.downloadDate != nil && [self.downloadDate compare:self.modifyDate] == NSOrderedDescending);
}

@end
