//
//  MBCRServiceManager.m
//  MBCR
//
//  Created by Alex Rouse on 6/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MBCRServiceManager.h"
#import "MBCRDataManager.h"
#import "NSString+HMAC.h"
#import "RZFileManager.h"
#import "NSDate+Formatter.h"
#import "MBCRAppDelegate.h"

#define kMaxConcurentRequests       4
#define kMaxTimeout                 15
static MBCRServiceManager *s_serviceManager;

//These are Hashed and used for the authorization header of all MBCR requests.
NSString* const authMessage = @"MBCRestDataService";
NSString* const authKey     = @"Hello";

@interface MBCRServiceManager ()
@property (nonatomic, strong) RZWebServiceManager* webManger;
@property (nonatomic, strong) NSString* hashAuthToken;
@property (nonatomic, assign) NSInteger openRequests;
@property (nonatomic, retain) NSDate *otpDate;
@end

@implementation MBCRServiceManager
@synthesize webManger = _webManger;
@synthesize hashAuthToken = _hashAuthToken;
@synthesize openRequests = _openRequests;
@synthesize otpDate = _otpDate;

+ (MBCRServiceManager*)shared
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_serviceManager = [[MBCRServiceManager alloc] init];
        
    });
    
    return s_serviceManager;
}

- (id)init {
    self = [super init];
    if (self) {
        self.webManger = [[RZWebServiceManager alloc] initWithCallsPath:[[NSBundle mainBundle] pathForResource:@"MBCR-WebServices" ofType:@"plist"]];
        self.hashAuthToken = [authMessage Base64HMACWithSecret:authKey];
        [self.webManger setMaximumConcurrentRequests:kMaxConcurentRequests];
        RZFileManager* rzfileManager = [RZFileManager defaultManager];
        rzfileManager.webManager = self.webManger;
        self.openRequests = 0;
    }
    return self;
}

#pragma mark - TAlerts
- (void)downloadTAlerts {
    [self updateStatusIndicatorWithNewRequest:YES];
    
    RZLog(@"Downloading T Alerts");
    RZWebServiceRequest * request = [self.webManger makeRequestWithKey:@"getTAlerts" andTarget:self  enqueue:NO];
    request.timeoutInterval = kMaxTimeout;
    request.headers = [NSDictionary dictionaryWithObject:self.hashAuthToken forKey:@"Authorization"];
    [self.webManger enqueueRequest:request];
}


- (void)tAlertsDownloadComplete:(id)userData {
    NSDictionary *json = (NSDictionary *)userData;
    NSDictionary *errorDictionary = [json objectForKey:kResponseStatusKey];
    int successStatus = [[errorDictionary objectForKey:kResponseSuccess] intValue];
    if(successStatus != 1) {
        [self tAlertsDownloadFailed:nil];
    }
    NSArray* tAlertArray = [json objectForKey:kResponseDataKey];
    if([tAlertArray count] <= 0) {
        [self tAlertsDownloadFailed:nil];
    }
    [[MBCRDataManager shared] importTAlerts:tAlertArray];
    [self updateStatusIndicatorWithNewRequest:NO];
}
- (void)tAlertsDownloadFailed:(NSError *)error {
    RZError(@"TAlerts Download Failed: %@",(error) ? error: @"There was a parsing problem with the data");
    [self updateStatusIndicatorWithNewRequest:NO];
}

#pragma mark - SubwayAlerts

- (void)downloadSubwayAlerts {
    [self updateStatusIndicatorWithNewRequest:YES];
    
    RZLog(@"Downloading Subway Alerts");
    RZWebServiceRequest * request = [self.webManger makeRequestWithKey:@"getSubwayAlerts" andTarget:self enqueue:NO];
    request.timeoutInterval = kMaxTimeout;
    request.headers = [NSDictionary dictionaryWithObject:self.hashAuthToken forKey:@"Authorization"];
    [self.webManger enqueueRequest:request];
}

- (void)subwayAlertsDownloadComplete:(id)userData {
    NSDictionary *json = (NSDictionary *)userData;
    RZWebLog(@"%@",userData);
    NSDictionary *errorDictionary = [json objectForKey:kResponseStatusKey];
    int successStatus = [[errorDictionary objectForKey:kResponseSuccess] intValue];
    if (successStatus != 1) {
        [self subwayAlertsDownloadFailed:nil];
    }
    NSArray* subwayAlertArray = [json objectForKey:kResponseDataKey];
    if ([subwayAlertArray count] <= 0) {
        [self subwayAlertsDownloadFailed:nil];
    }
    [[MBCRDataManager shared] importSubwayAlerts:subwayAlertArray];

    [self updateStatusIndicatorWithNewRequest:NO];
}
- (void)subwayAlertsDownloadFailed:(NSError *)error {
    RZError(@"Subway Download Failed: %@",(error) ? error: @"There was a parsing problem with the data");
    [self updateStatusIndicatorWithNewRequest:NO];
}


#pragma mark - AllPage Alerts
- (void)downloadAllPageAlerts {
    [self updateStatusIndicatorWithNewRequest:YES];
    RZLog(@"Downloading AllPage Alerts");
    RZWebServiceRequest * request = [self.webManger makeRequestWithKey:@"getAllPageAlerts" andTarget:self  enqueue:NO];
    request.timeoutInterval = kMaxTimeout;
    request.headers = [NSDictionary dictionaryWithObject:self.hashAuthToken forKey:@"Authorization"];
    [self.webManger enqueueRequest:request];
}

- (void)allPageAlertsDownloadComplete:(id)userData {
    NSDictionary *json = (NSDictionary *)userData;
    RZWebLog(@"%@",userData);
    NSDictionary *errorDictionary = [json objectForKey:kResponseStatusKey];
    int successStatus = [[errorDictionary objectForKey:kResponseSuccess] intValue];
    if(successStatus != 1) {
        [self allPageAlertsDownloadFailed:nil];
    }
    NSArray* allPageArray = [json objectForKey:kResponseDataKey];
    if([allPageArray count] <= 0) {
        [self allPageAlertsDownloadFailed:nil];
    }
    [[MBCRDataManager shared] importAllPageAlerts:allPageArray];
    [self updateStatusIndicatorWithNewRequest:NO];
}

- (void)allPageAlertsDownloadFailed:(NSError *)error {
    RZError(@"AllPage Download Failed: %@",(error) ? error: @"There was a parsing problem with the data");
    [self updateStatusIndicatorWithNewRequest:NO];
}

#pragma mark - Line Requests

- (void)downloadLineList {
    [self updateStatusIndicatorWithNewRequest:YES];
    RZLog(@"Downloading Line List")
    RZWebServiceRequest * request = [self.webManger makeRequestWithKey:@"getLineList" andTarget:self  enqueue:NO];
    request.timeoutInterval = kMaxTimeout;
    request.headers = [NSDictionary dictionaryWithObject:self.hashAuthToken forKey:@"Authorization"];
    [self.webManger enqueueRequest:request];
}

- (void)lineRequestDownloadComplete:(id)userData {
    NSDictionary *json = (NSDictionary *)userData;
    RZWebLog(@"%@",userData);
    NSDictionary *errorDictionary = [json objectForKey:kResponseStatusKey];
    int successStatus = [[errorDictionary objectForKey:kResponseSuccess] intValue];
    if(successStatus != 1) {
        [self lineRequestDownloadFailed:nil];
        return;
    }
    NSArray* lineArray = [json objectForKey:kResponseDataKey];
    if([lineArray count] <= 0) {
        [self lineRequestDownloadFailed:nil];
        return;
    }
    [[MBCRDataManager shared] importLineList:lineArray];
    [self updateStatusIndicatorWithNewRequest:NO];
    [((MBCRAppDelegate *)[[UIApplication sharedApplication] delegate]) updateLastUpdateForKey:kLastLineUpdate];
}
- (void)lineRequestDownloadFailed:(NSError *)error {

    RZError(@"Line List Download Failed: %@",(error) ? error: @"There was a parsing problem with the data");
    [self updateStatusIndicatorWithNewRequest:NO];
}

#pragma mark - TrackAssignments Requests

- (void)downloadTrackAssignments {
    [self updateStatusIndicatorWithNewRequest:YES];
    RZLog(@"Downloading Track Assignments");
    
    RZWebServiceRequest * request = [self.webManger makeRequestWithKey:@"getDepartureInformation" andTarget:self  enqueue:NO];
    request.timeoutInterval = kMaxTimeout;
    request.headers = [NSDictionary dictionaryWithObject:self.hashAuthToken forKey:@"Authorization"];
    [self.webManger enqueueRequest:request];
}

- (void)departureInformationCompleted:(id)userData {
    RZWebLog(@"%@",userData);
    NSDictionary *json = (NSDictionary *)userData;
    NSDictionary *errorDictionary = [json objectForKey:kResponseStatusKey];
    int successStatus = [[errorDictionary objectForKey:kResponseSuccess] intValue];
    if(successStatus != 1) {
        [self departureInformationFailed:nil];
    }
    NSDate* timestamp = [NSDate dateFromDotNetString:[errorDictionary objectForKey:KResponseTimestamp]];
    NSArray* assignments = [json objectForKey:kResponseDataKey];
    if([assignments count] <= 0) {
        [self departureInformationFailed:nil];
    }
    [[MBCRDataManager shared] importTrackAssignments:assignments withTime:timestamp];
    [self updateStatusIndicatorWithNewRequest:NO];    
}
- (void)departureInformationFailed:(NSError *)error {
    RZError(@"Track Assignments Download Failed: %@",(error) ? error: @"There was a parsing problem with the data");
    [self updateStatusIndicatorWithNewRequest:NO];
}

#pragma mark - Manual/Documents Requests

- (void)downloadDocumentList {
    [self updateStatusIndicatorWithNewRequest:YES];
    
    RZLog(@"Downloading Document List");
    RZWebServiceRequest * request = [self.webManger makeRequestWithKey:@"getDocumentList" andTarget:self  enqueue:NO];
    request.timeoutInterval = kMaxTimeout;
    request.headers = [NSDictionary dictionaryWithObject:self.hashAuthToken forKey:@"Authorization"];
    [self.webManger enqueueRequest:request];
}

- (void)documentListCompleted:(id)userData {
    RZWebLog(@"%@",userData);
    NSDictionary *json = (NSDictionary *)userData;
    NSDictionary *errorDictionary = [json objectForKey:kResponseStatusKey];
    int successStatus = [[errorDictionary objectForKey:kResponseSuccess] intValue];
    if(successStatus != 1) {
        [self documentListFailed:nil];
    }
    
    NSArray* assignments = [json objectForKey:kResponseDataKey];
    if([assignments count] <= 0) {
        [self documentListFailed:nil];
    }
    [[MBCRDataManager shared] importDocumentList:assignments];
    [self updateStatusIndicatorWithNewRequest:NO];
}
- (void)documentListFailed:(NSError *)error {
    RZError(@"Document List Download Failed: %@",(error) ? error: @"There was a parsing problem with the data");
    [self updateStatusIndicatorWithNewRequest:NO];
}


#pragma mark - AVL Requests


- (void)downloadAVLInformation {
    [self downloadAVLInformationWithDelegate:nil];
}
- (void)downloadAVLInformationWithDelegate:(id<ServiceManagerDelegate>)delegate 
{
    [self updateStatusIndicatorWithNewRequest:YES];
    RZLog(@"Downloading AVL Information");
    RZWebServiceRequest * request = [self.webManger makeRequestWithKey:@"getAVL" andTarget:self  enqueue:NO];
    request.timeoutInterval = kMaxTimeout;
    if (delegate)
        request.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:delegate, kWebserviceCompletionDelegate, nil];
    request.headers = [NSDictionary dictionaryWithObject:self.hashAuthToken forKey:@"Authorization"];

    [self.webManger enqueueRequest:request];
}

- (void)avlDownloadComplete:(id)userData request:(RZWebServiceRequest *)request {
    
    id<ServiceManagerDelegate> delegate = [request.userInfo objectForKey:kWebserviceCompletionDelegate];
    if ([delegate respondsToSelector:@selector(webRequestSucceeded:request:)])
    {
        [delegate webRequestSucceeded:userData request:request];
    }
    
    RZLog(@"AVL Download Complete");
    RZWebLog(@"%@",userData);
    NSDictionary *json = (NSDictionary *)userData;
    NSDictionary *errorDictionary = [json objectForKey:kResponseStatusKey];
    int successStatus = [[errorDictionary objectForKey:kResponseSuccess] intValue];
    if(successStatus != 1) {
        [self departureInformationFailed:nil];
    }
    NSDate* timestamp = [NSDate dateFromDotNetString:[errorDictionary objectForKey:KResponseTimestamp]];
    NSArray* avl = [json objectForKey:kResponseDataKey];
    if([avl isKindOfClass:[NSNull class]] || [avl count] <= 0) {
        [self avlDownloadFailed:nil request:nil];
    }

    [[MBCRDataManager shared] importAVLInformation:avl withTime:timestamp];
    [self updateStatusIndicatorWithNewRequest:NO];
}

- (void)avlDownloadFailed:(NSError *)error request:(RZWebServiceRequest *)request {
    RZError(@"AVL Download Failed: %@",(error) ? error: @"There was a parsing problem with the data");
    id<ServiceManagerDelegate> delegate = [request.userInfo objectForKey:kWebserviceCompletionDelegate];
    if ([delegate respondsToSelector:@selector(webRequestFailed:request:)])
    {
        [delegate webRequestFailed:error request:request];
    }
    [self updateStatusIndicatorWithNewRequest:NO];}

#pragma mark - Train Requests

- (void)downloadTrainInformation {
    [self updateStatusIndicatorWithNewRequest:YES];
    RZLog(@"Downloading Train Information");
    RZWebServiceRequest* request = [self.webManger makeRequestWithKey:@"getTrains" andTarget:self enqueue:NO];
    request.timeoutInterval = kMaxTimeout;
    request.headers = [NSDictionary dictionaryWithObject:self.hashAuthToken forKey:@"Authorization"];
    [self.webManger enqueueRequest:request];
}

- (void)trainsDownloadCompleted:(id)userData {

    RZLog(@"Train Infromation download Complete");
    RZWebLog(@"%@",userData);
    NSDictionary *json = (NSDictionary *)userData;
    NSDictionary *errorDictionary = [json objectForKey:kResponseStatusKey];
    int successStatus = [[errorDictionary objectForKey:kResponseSuccess] intValue];
    if(successStatus != 1) {
        [self trainsDownloadFailed:nil];
        return;
    }
    NSDate* timestamp = [NSDate dateFromDotNetString:[errorDictionary objectForKey:KResponseTimestamp]];
    NSArray* trains = [json objectForKey:kResponseDataKey];
    if([trains count] <= 0) {
        [self trainsDownloadFailed:nil];
        return;
    }
    
    [[MBCRDataManager shared] importTrains:trains withTime:timestamp];
    [self updateStatusIndicatorWithNewRequest:NO];
    [((MBCRAppDelegate *)[[UIApplication sharedApplication] delegate]) updateLastUpdateForKey:kLastTrainupdate];
}

- (void)trainsDownloadFailed:(NSError *)error {
    [self updateStatusIndicatorWithNewRequest:NO];
    RZError(@"Trains Download Failed: %@",(error) ? error: @"There was a parsing problem with the data");
}


#pragma mark - Bulletin List Request

- (void)downloadBulletinList {
    [self updateStatusIndicatorWithNewRequest:YES];
    RZLog(@"Downloading Bulletin List");
    RZWebServiceRequest * request = [self.webManger makeRequestWithKey:@"getBulletins" andTarget:self  enqueue:NO];
    request.timeoutInterval = kMaxTimeout;
    request.headers = [NSDictionary dictionaryWithObject:self.hashAuthToken forKey:@"Authorization"];
    [self.webManger enqueueRequest:request];
}

- (void)bulletinDownloadCompleted:(id)userData {
    
    RZWebLog(@"%@",userData);
    NSDictionary *json = (NSDictionary *)userData;
    NSDictionary *errorDictionary = [json objectForKey:kResponseStatusKey];
    int successStatus = [[errorDictionary objectForKey:kResponseSuccess] intValue];
    if(successStatus != 1) {
        [self bulletinDownloadFailed:nil];
    }
    NSArray* assignments = [json objectForKey:kResponseDataKey];
    if([assignments count] <= 0) {
        [self bulletinDownloadFailed:nil];
    }
    [[MBCRDataManager shared] importBulletinList:assignments];
    [self updateStatusIndicatorWithNewRequest:NO];
}

- (void)bulletinDownloadFailed:(NSError *)error {
    [self updateStatusIndicatorWithNewRequest:NO];
    RZError(@"Bulletins Download Failed: %@",(error) ? error: @"There was a parsing problem with the data");
}


#pragma mark - OTP Request
- (void)downloadOTPData:(NSDate *)date {
    [self updateStatusIndicatorWithNewRequest:YES];
    _otpDate = date;
    RZLog(@"Download OTP Data");
//    NSArray *value = [[NSArray alloc] initWithObjects:date, nil];
//    NSArray *key = [[NSArray alloc] initWithObjects:@"Date", nil];
    
//    NSDictionary *param = [NSDictionary dictionaryWithObjects:value forKeys:key];
    
    RZWebServiceRequest *request =[self.webManger makeRequestWithKey:@"getOTP" andTarget:self enqueue:NO];
    
    request.timeoutInterval = kMaxTimeout;
    request.headers = [NSDictionary dictionaryWithObject:self.hashAuthToken forKey:@"Authorization"];
    [self.webManger enqueueRequest:request];
}

- (void)otpDownloadCompleted:(id)userData {
    
    RZWebLog(@"%@",userData);
    NSDictionary *json = (NSDictionary *)userData;
    NSDictionary *errorDictionary = [json objectForKey:kResponseStatusKey];
    int successStatus = [[errorDictionary objectForKey:kResponseSuccess] intValue];
    if(successStatus != 1) {
        [self otpDownloadFailed:nil];
    }
    NSArray* otp = [json objectForKey:kResponseDataKey];
    if([otp count] <= 0) {
        [self otpDownloadFailed:nil];
    }
    
    [[MBCRDataManager shared] importOTP: otp];
    
    [self updateStatusIndicatorWithNewRequest:NO];
}

- (void)otpDownloadFailed:(NSError *)error {
    [self updateStatusIndicatorWithNewRequest:NO];
    RZError(@"OPT Download Failed: %@",(error) ? error: @"There was a parsing problem with the data");
}

- (void)updateStatusIndicatorWithNewRequest:(BOOL)newRequest {
    if (newRequest) {
        self.openRequests ++;
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    } else {
        self.openRequests --;
        [((MBCRAppDelegate *)[[UIApplication sharedApplication] delegate]) requestCompleted];
        if (self.openRequests <= 0) {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            self.openRequests = 0;
        }
    }
}


@end

