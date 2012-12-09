//
//  MBCRServiceManager.h
//  MBCR
//
//  Created by Alex Rouse on 6/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RZWebServiceManager.h"

@protocol ServiceManagerDelegate <NSObject>
-(void)webRequestSucceeded:(id)data request:(RZWebServiceRequest *)request;
-(void)webRequestFailed:(NSError *)error request:(RZWebServiceRequest *)request;

@end

@interface MBCRServiceManager : NSObject


+ (MBCRServiceManager*)shared;

- (void)downloadTAlerts;
- (void)downloadSubwayAlerts;
- (void)downloadAllPageAlerts;
- (void)downloadLineList;
- (void)downloadTrackAssignments;
- (void)downloadDocumentList;
- (void)downloadBulletinList;
- (void)downloadAVLInformation;
- (void)downloadAVLInformationWithDelegate:(id<ServiceManagerDelegate>)delegate;
- (void)downloadTrainInformation;
- (void)downloadOTPData:(NSDate *) date;

@end
