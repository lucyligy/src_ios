//
//  MBCRTests.h
//  MBCRTests
//
//  Created by Alex Rouse on 6/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "RZWebServiceManager.h"
#import "RZWebServiceRequest.h"
#import "MBCRTestDelegate.h"


@interface MBCRTests : SenTestCase
@property (nonatomic, strong) RZWebServiceManager* manager;
@property (nonatomic, strong) MBCRTestDelegate* testDelegate;
@end
