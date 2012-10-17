//
//  Bulletin.h
//  MBCR
//
//  Created by Alex Rouse on 8/1/12.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Bulletin : NSManagedObject

@property (nonatomic, retain) NSDate * downloadDate;
@property (nonatomic, retain) NSDate * expireDate;
@property (nonatomic, retain) NSDate * lastOpened;
@property (nonatomic, retain) NSDate * lastSeen;
@property (nonatomic, retain) NSDate * modifyDate;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSDate * startDate;
@property (nonatomic, retain) NSString * url;

@end
