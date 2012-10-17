//
//  AVL.h
//  MBCR
//
//  Created by Alex Rouse on 8/1/12.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Train;

@interface AVL : NSManagedObject

@property (nonatomic, retain) NSString * destination;
@property (nonatomic, retain) NSString * flag;
@property (nonatomic, retain) NSNumber * heading;
@property (nonatomic, retain) NSString * lateness;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSDate * scheduled;
@property (nonatomic, retain) NSDate * serverTime;
@property (nonatomic, retain) NSNumber * speed;
@property (nonatomic, retain) NSString * stop;
@property (nonatomic, retain) NSDate * timestamp;
@property (nonatomic, retain) NSNumber * trip;
@property (nonatomic, retain) NSString * vehicle;
@property (nonatomic, retain) Train *train;

@end
