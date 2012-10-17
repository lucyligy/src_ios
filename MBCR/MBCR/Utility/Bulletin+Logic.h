//
//  Bulletin+Logic.h
//  MBCR
//
//  Created by Alex Rouse on 7/10/12.
//  Copyright (c) 2012 Raizlabs. All rights reserved.
//

#import "Bulletin.h"

@interface Bulletin (Logic)
@property (nonatomic, readonly) BOOL isRead;
@property (nonatomic, readonly) BOOL isDownloaded;

@end
