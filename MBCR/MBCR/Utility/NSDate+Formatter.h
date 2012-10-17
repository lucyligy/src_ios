//
//  NSDate+Formatter.h
//  MBCR
//
//  Created by Alex Rouse on 6/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Formatter)

+ (NSDate*)dateFromDotNetString:(NSString*)dotNetDateString;
+ (NSDate *)yesterdaysDate;

- (NSString *)fullTimeFormat;
- (NSString *)clockTimeFormat;
- (NSString *)displayTimeSinceNow;
- (BOOL)isOlderThan24Hours;
- (BOOL)isDateToday;

- (BOOL)isOlderThen15Minutes;
- (BOOL)isOlderThen5Minutes;
- (BOOL)isOlderThenNow;

@end
