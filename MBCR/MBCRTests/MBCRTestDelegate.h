//
//  MBCRTestDelegate.h
//  MBCR
//
//  Created by Alex Rouse on 6/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MBCRTestDelegate : NSObject
@property (nonatomic, assign)BOOL done;
@property (nonatomic, strong)id serverResponse;

- (void)tAlertsDownloadComplete:(id)userData;
- (void)tAlertsDownloadComplete;
@end
