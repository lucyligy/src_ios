//
//  TrackAssignment.h
//  MBCR
//
//  Created by Alex Rouse on 8/6/12.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Train;

@interface TrackAssignment : NSManagedObject

@property (nonatomic, retain) NSString * carrier;
@property (nonatomic, retain) NSDate * departureTime;
@property (nonatomic, retain) NSString * destination;
@property (nonatomic, retain) NSString * origin;
@property (nonatomic, retain) NSDate * predictedDepartureTime;
@property (nonatomic, retain) NSString * status;
@property (nonatomic, retain) NSNumber * track;
@property (nonatomic, retain) NSString * trainNo;
@property (nonatomic, retain) NSDate * lastUpdate;
@property (nonatomic, retain) Train *train;

@end
