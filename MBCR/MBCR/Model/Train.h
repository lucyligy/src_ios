//
//  Train.h
//  MBCR
//
//  Created by Alex Rouse on 8/1/12.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class AVL, Line, MBCRAlert, TrackAssignment;

@interface Train : NSManagedObject

@property (nonatomic, retain) NSDate * lastUpdate;
@property (nonatomic, retain) NSNumber * trainId;
@property (nonatomic, retain) NSString * trainNo;
@property (nonatomic, retain) NSSet *alerts;
@property (nonatomic, retain) AVL *avl;
@property (nonatomic, retain) Line *line;
@property (nonatomic, retain) TrackAssignment *trackAssignment;
@end

@interface Train (CoreDataGeneratedAccessors)

- (void)addAlertsObject:(MBCRAlert *)value;
- (void)removeAlertsObject:(MBCRAlert *)value;
- (void)addAlerts:(NSSet *)values;
- (void)removeAlerts:(NSSet *)values;

@end
