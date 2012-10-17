//
//  NSDate+Formatter.m
//  MBCR
//
//  Created by Alex Rouse on 6/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NSDate+Formatter.h"
#include <tgmath.h>
@implementation NSDate (Formatter)

+ (NSDate*)dateFromDotNetString:(NSString*)dotNetDateString
{
    static NSRegularExpression *dateRegEx = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateRegEx = [NSRegularExpression regularExpressionWithPattern:@"\\/Date\\((-?\\d+)((?:[\\+\\-]\\d+)?)\\)\\/" options:NSRegularExpressionCaseInsensitive error:NULL];
    });
    
    if (dotNetDateString == nil) {
        return nil;
    }
    
    NSTextCheckingResult *match = [dateRegEx firstMatchInString:dotNetDateString options:NSRegularExpressionCaseInsensitive range:NSMakeRange(0, [dotNetDateString length])];
    
    NSDate *date = nil;
    
    if (match)
    {
        NSRange millisecondsRange = [match rangeAtIndex:1];
        
        if (!NSEqualRanges(millisecondsRange, NSMakeRange(NSNotFound, 0)))
        {
            NSString *dateTime = [dotNetDateString substringWithRange:millisecondsRange];
            NSTimeInterval secondsInterval = [dateTime doubleValue]/1000.0;
            
            date = [NSDate dateWithTimeIntervalSince1970:secondsInterval];
        }
    }
    
    return date;
}

//Returns time in the format 8:42AM
- (NSString *)clockTimeFormat {
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"h:mma"];
    NSString *dateString = [format stringFromDate:self];
    return dateString;
}

//Returns time in format 08/14/12 - 3:48AM
- (NSString *)fullTimeFormat {
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"MM/dd/yy - h:mma"];
    NSString *dateString = [format stringFromDate:self];
    return dateString;
}

- (NSString *)displayTimeSinceNow {
    int secondsBetween = [self secondsBeforeNow];
    if (secondsBetween < 60) {
        return [NSString stringWithFormat:@"Right Now"];
    }
    else if (secondsBetween < 120) {
        return [NSString stringWithFormat:@"%d Minute Ago",(int)(secondsBetween/60)];
    }
    else if (secondsBetween < 3600) {
        return [NSString stringWithFormat:@"%d Minutes Ago",(int)(secondsBetween/60)];
    }
    else if(secondsBetween < 7200) {
        return [NSString stringWithFormat:@"%d Hour Ago",(int)(secondsBetween/3600.0f)];
    }
    else if(secondsBetween < 86400) {
        return [NSString stringWithFormat:@"%d Hours Ago",(int)(secondsBetween/3600.0f)];
    }
    else if(secondsBetween < 172800) {
        return [NSString stringWithFormat:@"%d Day Ago",(int)(secondsBetween/86400)];
    }
    else {
        return [NSString stringWithFormat:@"%d Days Ago",(int)(secondsBetween/86400)];
    }
}

- (int) secondsBeforeNow {
    return (int)[[NSDate date] timeIntervalSinceDate:self];
}


- (BOOL)isOlderThan24Hours {
    return ([self compare:[[NSDate date] dateByAddingTimeInterval: -kSecondsInDay]] == NSOrderedAscending);
}
- (BOOL)isOlderThen15Minutes {    
    return ([self compare:[[NSDate date] dateByAddingTimeInterval: -kSecondsIn15Minutes]] == NSOrderedAscending);
}
- (BOOL)isOlderThen5Minutes {
    return ([self compare:[[NSDate date] dateByAddingTimeInterval: -kSecondsIn5Minutes]] == NSOrderedAscending);
}
- (BOOL)isOlderThenNow {
    return ([self compare:[[NSDate date] dateByAddingTimeInterval: 0]] == NSOrderedAscending);
}

+ (NSDate *)yesterdaysDate {
    return [[NSDate date] dateByAddingTimeInterval:-kSecondsInDay];
}


- (BOOL)isDateToday {
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:(NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit) fromDate:[NSDate date]];
    NSDate *today = [cal dateFromComponents:components];
    components = [cal components:(NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit) fromDate:self];
    NSDate *otherDate = [cal dateFromComponents:components];
    
    if([today isEqualToDate:otherDate]) {
        return YES;
    }
    return NO;
}



@end
