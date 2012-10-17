//
//  TAlert.h
//  MBCR
//
//  Created by Alex Rouse on 8/1/12.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "MBCRAlert.h"


@interface TAlert : MBCRAlert

@property (nonatomic, retain) NSString * alertId;
@property (nonatomic, retain) NSString * sender;
@property (nonatomic, retain) NSString * senderEmail;
@property (nonatomic, retain) NSDate * sentOn;
@property (nonatomic, retain) NSString * subject;

@end
