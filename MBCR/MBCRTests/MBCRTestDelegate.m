//
//  MBCRTestDelegate.m
//  MBCR
//
//  Created by Alex Rouse on 6/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MBCRTestDelegate.h"

@implementation MBCRTestDelegate
@synthesize done = _done;
@synthesize serverResponse = _serverResponse;

#pragma mark - WebServiceMangerDelegate

- (void)tAlertsDownloadComplete:(id)userData {
    self.serverResponse = userData;
    self.done = YES;
}
- (void)tAlertsDownloadFailed:(NSError *)error {
    self.done = YES;
}

- (void)subwayAlertsDownloadComplete:(id)userData {
    self.serverResponse = userData;
    self.done = YES;
}
- (void)subwayAlertsDownloadFailed:(NSError *)error {
    self.done = YES;
}

- (void)allPageAlertsDownloadComplete:(id)userData {
    self.serverResponse = userData;
    self.done = YES;
}
- (void)allPageAlertsDownloadFailed:(NSError *)error {
    self.done = YES;
}

- (void)lineRequestDownloadComplete:(id)userData {
    self.serverResponse = userData;
    self.done = YES;
}
- (void)lineRequestDownloadFailed:(NSError *)error {
    self.done = YES;
}
- (void)departureInformationCompleted:(id)userData {
    self.serverResponse = userData;
    self.done = YES;
}

- (void)departureInformationFailed:(NSError *)error {
    self.done = YES;
}

- (void)documentListCompleted:(id)userData {
    self.serverResponse = userData;
    self.done = YES;
}
- (void)documentListFailed:(NSError*)error {
    self.done = YES;
}

@end
