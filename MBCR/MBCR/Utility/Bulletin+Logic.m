//
//  Bulletin+Logic.m
//  MBCR
//
//  Created by Alex Rouse on 7/10/12.
//  Copyright (c) 2012 Raizlabs. All rights reserved.
//

#import "Bulletin+Logic.h"

@implementation Bulletin (Logic)


- (BOOL)isRead {
    return ([self.lastOpened compare:self.downloadDate] == (NSOrderedDescending || NSOrderedSame));
}

- (BOOL)isDownloaded {
    return (self.downloadDate != nil && [self.downloadDate compare:self.modifyDate] == NSOrderedDescending);
}

@end
