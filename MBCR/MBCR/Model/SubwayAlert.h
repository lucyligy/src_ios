//
//  SubwayAlert.h
//  MBCR
//
//  Created by Alex Rouse on 8/1/12.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface SubwayAlert : NSManagedObject

@property (nonatomic, retain) NSString * guid;
@property (nonatomic, retain) NSString * line;
@property (nonatomic, retain) NSString * message;
@property (nonatomic, retain) NSDate * receivedOn;
@property (nonatomic, retain) NSString * region;
@property (nonatomic, retain) NSString * sender;
@property (nonatomic, retain) NSString * senderEmail;
@property (nonatomic, retain) NSString * service;
@property (nonatomic, retain) NSString * subject;
@property (nonatomic, retain) NSNumber * trainNumber;

@end
