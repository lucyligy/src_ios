//
//  OTP.h
//  MBCR
//
//  Created by Lucy Li on 12/5/12.
//
//

#import <Foundation/Foundation.h>

@interface OTP : NSObject
@property (nonatomic, retain) NSString * divisionName;
@property (nonatomic, retain) NSString * routeName;
@property (nonatomic, retain) NSNumber * dayPassengerCount;
@property (nonatomic, retain) NSNumber * dayTrainCount;
@property (nonatomic, retain) NSNumber * dayOnTimeTrainCount;
@property (nonatomic, retain) NSNumber * dayOTP;
@property (nonatomic, retain) NSNumber * mtdPassengerCount;
@property (nonatomic, retain) NSNumber * mtdTrainCount;
@property (nonatomic, retain) NSNumber * mtdOnTimeTrainCount;
@property (nonatomic, retain) NSNumber * mtdOTP;
@property (nonatomic, retain) NSNumber * monthOTP;
@property (nonatomic, retain) NSNumber * prevMonthPassengerCount;
@property (nonatomic, retain) NSNumber * prevMonthTrainCount;
@property (nonatomic, retain) NSNumber * prevMonthOnTimeTrainCount;
@property (nonatomic, retain) NSNumber * prevMonthOTP;
@property (nonatomic, retain) NSNumber * routeID;
@property (nonatomic, retain) NSNumber * divisionID;
@property (nonatomic, retain) NSDate   * date;
@end
