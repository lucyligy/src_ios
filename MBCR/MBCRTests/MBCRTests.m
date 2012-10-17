//
//  MBCRTests.m
//  MBCRTests
//
//  Created by Alex Rouse on 6/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MBCRTests.h"
#import "NSString+HMAC.h"

#define kWebserviceTimeout 15.0
NSString* const authMessage = @"MBCRestDataService";
NSString* const authKey     = @"Hello";

@interface MBCRTests ()
@property (nonatomic, assign)BOOL done;
@property (nonatomic, strong) NSString* hashAuthToken;

- (void)checkTAlertObject:(NSDictionary *) alert;

@end

@implementation MBCRTests
@synthesize manager = _manager;
@synthesize testDelegate = _testDelegate;
@synthesize hashAuthToken = _hashAuthToken;

@synthesize done;

- (void)setUp
{
    self.manager = [[RZWebServiceManager alloc] initWithCallsPath:[[NSBundle mainBundle] pathForResource:@"MBCR-WebServices" ofType:@"plist"]];
    self.testDelegate = [[MBCRTestDelegate alloc] init];
    self.hashAuthToken = [authMessage Base64HMACWithSecret:authKey];

    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testTAlertService {
    NSLog(@"Checking T Alert Service");
    RZWebServiceRequest * request = [self.manager makeRequestWithKey:@"getTAlerts" andTarget:self.testDelegate  enqueue:NO];
    request.headers = [NSDictionary dictionaryWithObject:self.hashAuthToken forKey:@"Authorization"];
    [self.manager enqueueRequest:request];
    STAssertTrue([self waitForCompletion:kWebserviceTimeout] ,@"Timeout");
    STAssertTrue([self.testDelegate.serverResponse isKindOfClass:[NSDictionary class]],@"We Recieved a NON JSON Response");
    NSDictionary *json = (NSDictionary *)self.testDelegate.serverResponse;
    NSDictionary *errorDictionary = [json objectForKey:kResponseStatusKey];
    int successStatus = [[errorDictionary objectForKey:kResponseSuccess] intValue];
    STAssertTrue((successStatus == 1), @"Success Was Not Equal to 1");
    NSArray* tAlertArray = [json objectForKey:kResponseDataKey];
    STAssertTrue(([tAlertArray count] > 0), @"There are no Alerts Returned" );
    NSLog(@"We recieved:%d Alerts from the TAlert request",[tAlertArray count]);
    [self checkTAlertObject:[tAlertArray objectAtIndex:0]];
}

- (void)checkTAlertObject:(NSDictionary *)alert {
    NSLog(@"Checking TAlert Object: %@",alert);

    STAssertNotNil(alert,@"TAlert is Nil or there are no Alerts");
    STAssertNotNil([alert objectForKey:kTAlertsLine],@"Line is Nil");
    STAssertNotNil([alert objectForKey:kTAlertsMessage],@"Message is Nil");
    STAssertNotNil([alert objectForKey:kTAlertsReceivedOn],@"ReceivedOn is Nil");
    STAssertNotNil([alert objectForKey:kTAlertsSender],@"Sender is Nil");
    STAssertNotNil([alert objectForKey:kTAlertsSenderEmail],@"SenderEmail is Nil");
    STAssertNotNil([alert objectForKey:kTAlertsSubject],@"Subject is Nil");
    STAssertNotNil([alert objectForKey:kTAlertsTrainNo],@"TrainNo is Nil");
}

- (void)testSubwayAlertService {
    NSLog(@"Checking Subway Alert Service");
    RZWebServiceRequest * request = [self.manager makeRequestWithKey:@"getSubwayAlerts" andTarget:self.testDelegate enqueue:NO];
    request.headers = [NSDictionary dictionaryWithObject:self.hashAuthToken forKey:@"Authorization"];
    [self.manager enqueueRequest:request];
    STAssertTrue([self waitForCompletion:kWebserviceTimeout], @"Timeout");
    STAssertTrue([self.testDelegate.serverResponse isKindOfClass:[NSDictionary class]], @"We received a NON JSON Response");
    NSDictionary* json = (NSDictionary *)self.testDelegate.serverResponse;
    NSDictionary* errorDictionary = [json objectForKey:kResponseStatusKey];
    int successStatus = [[errorDictionary objectForKey:kResponseSuccess] intValue];
    STAssertTrue((successStatus == 1), @"Success was not equals to 1");
    NSArray* rtAlertArray = [json objectForKey:kResponseDataKey];
    STAssertTrue(([rtAlertArray count] > 0), @"There are no Alerts returned");
    NSLog(@"We recieved:%d Alerts from the subway request",[rtAlertArray count]);
    [self checkSubwayAlertObject:[rtAlertArray objectAtIndex:0]];
}

- (void)checkSubwayAlertObject:(NSDictionary *)alert {
    NSLog(@"Checking Subway alert object %@", alert);
    STAssertNotNil(alert,@"RTAlert is Nil or there are no Alerts");
    STAssertNotNil([alert objectForKey:kSubwayAlertsGuid],@"GUID is Nil");
    STAssertNotNil([alert objectForKey:kSubwayAlertsMessage],@"Message is Nil");
    STAssertNotNil([alert objectForKey:kSubwayAlertsRecievedOn],@"RecievedOn is NIL");
    STAssertNotNil([alert objectForKey:kSubwayAlertsSender],@"Sender is Nil");
    STAssertNotNil([alert objectForKey:kSubwayAlertsSenderEmail],@"SenderEmail is NIl");
    STAssertNotNil([alert objectForKey:kSubwayAlertsSubject],@"Subject is NIL");
    STAssertNotNil([alert objectForKey:kSubwayAlertsTrainNo],@"Train no is Nil");
    STAssertNotNil([alert objectForKey:kSubwayAlertsLine],@"Line is Nil");
    STAssertNotNil([alert objectForKey:kSubwayAlertsDivision],@"Divison is Nil");
    STAssertNotNil([alert objectForKey:kSubwayAlertsService],@"Service is Nil");
    
}

- (void)testAllPageAlertService {
    NSLog(@"Checking AllPage Alerts Service");
    RZWebServiceRequest * request = [self.manager makeRequestWithKey:@"getAllPageAlerts" andTarget:self.testDelegate  enqueue:NO];
    request.headers = [NSDictionary dictionaryWithObject:self.hashAuthToken forKey:@"Authorization"];
    [self.manager enqueueRequest:request];
    STAssertTrue([self waitForCompletion:kWebserviceTimeout] ,@"Timeout");
    STAssertTrue([self.testDelegate.serverResponse isKindOfClass:[NSDictionary class]],@"We Recieved a NON JSON Response");
    NSDictionary *json = (NSDictionary *)self.testDelegate.serverResponse;
    NSDictionary *errorDictionary = [json objectForKey:kResponseStatusKey];
    int successStatus = [[errorDictionary objectForKey:kResponseSuccess] intValue];
    STAssertTrue((successStatus == 1), @"Success Was Not Equal to 1");
    NSArray* allPageAlertArray = [json objectForKey:kResponseDataKey];
    STAssertTrue(([allPageAlertArray count] > 0), @"There are no Alerts Returned" );
    NSLog(@"We recieved:%d Alerts from the AllPage request",[allPageAlertArray count]);
    [self checkAllPageAlertObject:[allPageAlertArray objectAtIndex:0]];
}

- (void)checkAllPageAlertObject:(NSDictionary *)alert {
    NSLog(@"Checking AllPage Alert Object: %@",alert);
    STAssertNotNil(alert,@"AllPageAlert is Nil or there are no Alerts");
    STAssertNotNil([alert objectForKey:kAllPageAlertsMessage],@"Message is Nil");  
    STAssertNotNil([alert objectForKey:kAllPageAlertsReceivedOn],@"ReceivedOn is Nil");
    STAssertNotNil([alert objectForKey:kAllPageAlertsSender],@"Sender is Nil");
    STAssertNotNil([alert objectForKey:kAllPageAlertsSenderEmail],@"SenderEmail is Nil");
    STAssertNotNil([alert objectForKey:kAllPageAlertsSentOn],@"SentOn is Nil");
}

- (void)testLineRequestService {
    NSLog(@"Checking Line Service");
    RZWebServiceRequest * request = [self.manager makeRequestWithKey:@"getLineList" andTarget:self.testDelegate  enqueue:NO];
    request.headers = [NSDictionary dictionaryWithObject:self.hashAuthToken forKey:@"Authorization"];
    [self.manager enqueueRequest:request];
    STAssertTrue([self waitForCompletion:kWebserviceTimeout] ,@"Timeout");
    STAssertTrue([self.testDelegate.serverResponse isKindOfClass:[NSDictionary class]],@"We Recieved a NON JSON Response");
    NSDictionary *json = (NSDictionary *)self.testDelegate.serverResponse;
    NSDictionary *errorDictionary = [json objectForKey:kResponseStatusKey];
    int successStatus = [[errorDictionary objectForKey:kResponseSuccess] intValue];
    STAssertTrue((successStatus == 1), @"Success Was Not Equal to 1");
    NSArray* line = [json objectForKey:kResponseDataKey];
    STAssertTrue(([line count] > 0), @"There are no Lines Returned" );
    NSLog(@"We recieved:%d Lines from the Line request",[line count]);
    [self checkLineObject:[line objectAtIndex:0]];
}

- (void)checkLineObject:(NSDictionary *)line {
    NSLog(@"Checking Line Object: %@",line);
    STAssertNotNil(line,@"Line is Nil or there are no Lines");
    STAssertNotNil([line objectForKey:kLineDescription],@"Line Description is Nil");  
    STAssertNotNil([line objectForKey:kLineID],@"Line ID is Nil");  
}

- (void)testDepartureInfoRequestService {
    NSLog(@"Checking DepartureInfo Service");
    RZWebServiceRequest * request = [self.manager makeRequestWithKey:@"getDepartureInformation" andTarget:self.testDelegate  enqueue:NO];
    request.headers = [NSDictionary dictionaryWithObject:self.hashAuthToken forKey:@"Authorization"];
    [self.manager enqueueRequest:request];
    STAssertTrue([self waitForCompletion:kWebserviceTimeout] ,@"Timeout");
    STAssertTrue([self.testDelegate.serverResponse isKindOfClass:[NSDictionary class]],@"We Recieved a NON JSON Response: %@", self.testDelegate.serverResponse);
    NSDictionary *json = (NSDictionary *)self.testDelegate.serverResponse;
    NSDictionary *errorDictionary = [json objectForKey:kResponseStatusKey];
    int successStatus = [[errorDictionary objectForKey:kResponseSuccess] intValue];
    STAssertTrue((successStatus == 1), @"Success Was Not Equal to 1");
    NSArray* line = [json objectForKey:kResponseDataKey];
    STAssertTrue(([line count] > 0), @"There is no DepartureInformation Returned" );
    NSLog(@"We recieved:%d Trips from the Departure Info request",[line count]);
    [self checkDepartureInfoObject:[line objectAtIndex:0]];
}

- (void)checkDepartureInfoObject:(NSDictionary *)info {
    NSLog(@"Checking DepartureInfo Object: %@",info);
    STAssertNotNil(info,@"AllPageAlert is Nil or there are no Alerts");
    STAssertNotNil([info objectForKey:kDepartureInfoCarrier],@"Carrier is Nil");  
    STAssertNotNil([info objectForKey:kDepartureInfoTrain],@"Train is Nil");
    STAssertNotNil([info objectForKey:kDepartureInfoTime],@"Time is Nil");
    STAssertNotNil([info objectForKey:kDepartureInfoPredTime],@"PredictedTime is Nil");
    STAssertNotNil([info objectForKey:kDepartureInfoOrigin],@"Origin is Nil");
    STAssertNotNil([info objectForKey:kDepartureInfoDestination],@"Destination is Nil");
    STAssertNotNil([info objectForKey:kDepartureInfoTrack],@"Track is Nil");
    STAssertNotNil([info objectForKey:kDepartureInfoStatus],@"Status is Nil");
}

- (void)testDocsRequestService {
    NSLog(@"Checking Docs Service");
    RZWebServiceRequest * request = [self.manager makeRequestWithKey:@"getDocumentList" andTarget:self.testDelegate  enqueue:NO];
    request.headers = [NSDictionary dictionaryWithObject:self.hashAuthToken forKey:@"Authorization"];
    [self.manager enqueueRequest:request];
    STAssertTrue([self waitForCompletion:kWebserviceTimeout] ,@"Timeout");
    STAssertTrue([self.testDelegate.serverResponse isKindOfClass:[NSDictionary class]],@"We Recieved a NON JSON Response");
    NSDictionary *json = (NSDictionary *)self.testDelegate.serverResponse;
    NSDictionary *errorDictionary = [json objectForKey:kResponseStatusKey];
    int successStatus = [[errorDictionary objectForKey:kResponseSuccess] intValue];
    STAssertTrue((successStatus == 1), @"Success Was Not Equal to 1");
    NSArray* line = [json objectForKey:kResponseDataKey];
    STAssertTrue(([line count] > 0), @"There are no Docs Returned" );
    NSLog(@"We recieved:%d Docs from the Doc Info request",[line count]);

    [self checkDocumentObject:[line objectAtIndex:0]];
}

- (void)checkDocumentObject:(NSDictionary *)doc {
    NSLog(@"Checking Doc Object: %@",doc);
    STAssertNotNil(doc,@"Line is Nil or there are no Lines");
    STAssertNotNil([doc objectForKey:kDocumentLastUpdated],@"doc Description is Nil");  
    STAssertNotNil([doc objectForKey:kDocumentTitle],@"doc title is Nil");  
     STAssertNotNil([doc objectForKey:kDocumentURL],@"doc url is Nil"); 
}
- (BOOL)waitForCompletion:(NSTimeInterval)timeoutSecs {
    NSDate *timeoutDate = [NSDate dateWithTimeIntervalSinceNow:timeoutSecs];
    
    do {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:timeoutDate];
        if([timeoutDate timeIntervalSinceNow] < 0.0)
            break;
    } while (!self.testDelegate.done);
    
    return self.testDelegate.done;
}


@end
