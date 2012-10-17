//
//  MBCRAlert.h
//  MBCR
//
//  Created by Alex Rouse on 8/1/12.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Line, Train;

@interface MBCRAlert : NSManagedObject

@property (nonatomic, retain) NSString * guid;
@property (nonatomic, retain) NSNumber * lineId;
@property (nonatomic, retain) NSString * message;
@property (nonatomic, retain) NSDate * receivedOn;
@property (nonatomic, retain) NSString * region;
@property (nonatomic, retain) NSSet *line;
@property (nonatomic, retain) NSSet *train;
@end

@interface MBCRAlert (CoreDataGeneratedAccessors)

- (void)addLineObject:(Line *)value;
- (void)removeLineObject:(Line *)value;
- (void)addLine:(NSSet *)values;
- (void)removeLine:(NSSet *)values;

- (void)addTrainObject:(Train *)value;
- (void)removeTrainObject:(Train *)value;
- (void)addTrain:(NSSet *)values;
- (void)removeTrain:(NSSet *)values;

@end
