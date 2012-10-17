//
//  Line.h
//  MBCR
//
//  Created by Alex Rouse on 8/1/12.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MBCRAlert, Train;

@interface Line : NSManagedObject

@property (nonatomic, retain) NSString * lineDescription;
@property (nonatomic, retain) NSNumber * lineId;
@property (nonatomic, retain) NSString * region;
@property (nonatomic, retain) NSSet *alerts;
@property (nonatomic, retain) NSSet *trains;
@end

@interface Line (CoreDataGeneratedAccessors)

- (void)addAlertsObject:(MBCRAlert *)value;
- (void)removeAlertsObject:(MBCRAlert *)value;
- (void)addAlerts:(NSSet *)values;
- (void)removeAlerts:(NSSet *)values;

- (void)addTrainsObject:(Train *)value;
- (void)removeTrainsObject:(Train *)value;
- (void)addTrains:(NSSet *)values;
- (void)removeTrains:(NSSet *)values;

@end
