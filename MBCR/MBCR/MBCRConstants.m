//
//  MBCRConstants.m
//  MBCR
//
//  Created by Alex Rouse on 6/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MBCRConstants.h"

@implementation MBCRConstants

//NSUserDefaultsKeys
NSString* const kLastLaunchDate         = @"launchDate";
NSString* const kLastLineUpdate         = @"lineUpdate";
NSString* const kLastTrainupdate        = @"trainUpdate";
NSString* const kLastAlertViewDate      = @"lastAlertViewDate";


NSString* const kWebserviceCompletionDelegate = @"WebServiceCompletionDelegate";
NSString* const kUnreadAlertCount       = @"UnreadAlertCount";
//SERVER RESPONSE KEYS
NSString* const kResponseKey            = @"Response";
NSString* const kResponseDataKey        = @"responseData";
NSString* const kResponseStatusKey      = @"responseStatus";

//ErrorKeys
NSString* const kResponseErrorCode      = @"errorCode";
NSString* const kResponseErrorMessage   = @"errorMessage";

NSString* const kResponseSuccess        = @"success";
NSString* const KResponseTimestamp      = @"timeStamp";

NSString* const kCommentsPageURL        = @"http://mbcrcc.mbcr.net/conductor_app_comment.php";

//TAlerts
NSString* const kTAlertsLine            = @"Line";
NSString* const kTAlertsMessage         = @"Message";
NSString* const kTAlertsReceivedOn      = @"ReceivedOn";
NSString* const kTAlertsSender          = @"Sender";
NSString* const kTAlertsSenderEmail     = @"SenderEmail";
NSString* const kTAlertsSentOn          = @"SentOn";
NSString* const kTAlertsSubject         = @"Subject";
NSString* const kTAlertsTrainNo         = @"Train";
NSString* const kTAlertsGUID            = @"GUID";
NSString* const kTAlertsDivision        = @"Division";
NSString* const kTAlertsLineId          = @"LineId";

//AllPageAlerts
NSString* const kAllPageAlertsMessage   = @"Message";
NSString* const kAllPageAlertsReceivedOn= @"ReceivedOn";
NSString* const kAllPageAlertsSender    = @"Sender";
NSString* const kAllPageAlertsSenderEmail   = @"SenderEmail";
NSString* const kAllPageAlertsSentOn    = @"SentOn";
NSString* const kAllPageAlertsDivision  = @"Division";
NSString* const kAllPageAlertsLine      = @"LineId";
NSString* const kAllPageAlertsTrain     = @"Train";
NSString* const kAllPageAlertsGuid      = @"GUID";

//LineFeed
NSString* const kLineDescription        = @"Description";
NSString* const kLineID                 = @"ID";
NSString* const kLineDivision           = @"Division";

//DepartureInformation
NSString* const kDepartureInfoCarrier   = @"Carrier";
NSString* const kDepartureInfoTrain     = @"Train";
NSString* const kDepartureInfoTime      = @"DepartureTime";
NSString* const kDepartureInfoPredTime  = @"PredDepartTime";
NSString* const kDepartureInfoOrigin    = @"Origin";
NSString* const kDepartureInfoDestination = @"Dest";
NSString* const kDepartureInfoTrack     = @"Track";
NSString* const kDepartureInfoStatus    = @"Status";

//Bulletin Keys
NSString* const kBulletinStartDate      = @"StartDate";
NSString* const kBulletinExpireDate     = @"ExpireDate";
NSString* const kBulletinUploadDate     = @"UploadDate";
NSString* const kBulletinModifyDate     = @"ModifyDate";
NSString* const kBulletinName           = @"Name";
NSString* const kBulletinWebURL         = @"WebURL";

//Document Keys
NSString* const kDocumentLastUpdated    = @"LastUpdated";
NSString* const kDocumentTitle          = @"Name";
NSString* const kDocumentURL            = @"WebURL";
NSString* const kDocumentModifyDate     = @"ModifyDate";
NSString* const kDocumentExtension      = @"Type";
NSString* const kDocumentType           = @"Category";

//SubwayAlerts
NSString* const kSubwayAlertsGuid       = @"GUID";
NSString* const kSubwayAlertsMessage    = @"Message";
NSString* const kSubwayAlertsRecievedOn = @"ReceivedOn";
NSString* const kSubwayAlertsSender     = @"Sender";
NSString* const kSubwayAlertsSenderEmail= @"SenderEmail";
NSString* const kSubwayAlertsSubject    = @"Subject";
NSString* const kSubwayAlertsTrainNo    = @"TrainNo";
NSString* const kSubwayAlertsLine       = @"Line";
NSString* const kSubwayAlertsDivision   = @"Division";
NSString* const kSubwayAlertsService    = @"Service";

//AVL keys
NSString* const kAVLDestination         = @"Destination";
NSString* const kAVLFlag                = @"Flag";
NSString* const kAVLHeading             = @"Heading";
NSString* const kAVLLateness            = @"Lateness";
NSString* const kAVLLatitude            = @"Latitude";
NSString* const kAVLLineId              = @"LineID";
NSString* const kAVLLongitude           = @"Longitude";
NSString* const kAVLScheduled           = @"Scheduled";
NSString* const kAVLSpeed               = @"Speed";
NSString* const kAVLStop                = @"Stop";
NSString* const kAVLTimeStamp           = @"TimeStamp";
NSString* const kAVLTrain               = @"Train";
NSString* const kAVLVechicle            = @"Vechicle";

//Train Keys
NSString* const kTrainDivision          = @"Division";
NSString* const kTrainID                = @"ID";
NSString* const kTrainLine              = @"Line";
NSString* const kTrainLineID            = @"LineID";
NSString* const kTrainTrain             = @"Train";

NSString* const kSubwayGreenLineKey     = @"Green";
NSString* const kSubwayRedLineKey       = @"Red";
NSString* const kSubwayOrangeLineKey    = @"Orange";
NSString* const kSubwayBlueLineKey      = @"Blue";
NSString* const kSubwaySilverLineKey    = @"Silver";

//Station Strings
NSString* const kStationNorthStationKey = @"NOSTN";
NSString* const kStationSouthStationKey = @"SOSTN";

//File Extension
NSString* const kFileTypePDF            = @"PDF";
NSString* const kFileTypeHTML           = @"HTML";

//Manual types
NSString* const kManualTypeHotTopics    = @"HOT TOPICS";
NSString* const kManualTypeSchedule     = @"SCHEDULES";
NSString* const kManualTypeOtherNotice  = @"OTHER NOTICES";
NSString* const kManualTypeQuickReference= @"QUICK REFERENCE";
NSString* const kManualTypeManual       = @"MANUALS/BOOKS";



//Localytics
//Screens
NSString* const kLocalScreenMBCRMessage     = @"MBCR Messages";
NSString* const kLocalScreenSubwayMessage   = @"Subway Messages";
NSString* const kLocalScreenMessageDetails  = @"Message Details";
NSString* const kLocalScreenLocation        = @"Location";
NSString* const kLocalScreenLocationDetails = @"Location Details";
NSString* const kLocalScreenTrackSouth      = @"Track South";
NSString* const kLocalScreenTrackNorth      = @"Track North";
NSString* const kLocalScreenReference       = @"Reference";
NSString* const kLocalScreenComment         = @"Comment";

//Actions
NSString* const kLocalActionTrainSelected   = @"Train Selected";
NSString* const kLocalActionTrainTapped     = @"Train Tapped";
NSString* const kLocalActionDropDownOpened  = @"Drop Down Opened";
NSString* const kLocalActionTabSelected     = @"Tab Selected";
NSString* const kLocalActionDocumentViewed  = @"Document Viewed";
NSString* const kLocalActionBulletinViewed  = @"Bulletin Viewed";
NSString* const kLocalActionAppOpened       = @"App Opened";
NSString* const kLocalActionMessageViewed   = @"Message Viewed";
NSString* const kLocalActionMessageFilter   = @"Message Filter Applied";
NSString* const kLocalActionSubwayMessageViewed   = @"Subway Message Viewed";
NSString* const kLocalActionSubwayFilter    = @"Subway Filter Applied";

//Attributes
NSString* const kLocalAttributeRegion       = @"region";
NSString* const kLocalAttributeLine         = @"line";
NSString* const kLocalAttributeNameOfTab    = @"nameOfTab";
NSString* const kLocalAttributeName         = @"name";
NSString* const kLocalAttributeType         = @"type";
NSString* const kLocalAttributeMethod       = @"method";

//OTP Keys
NSString* const kDivisionName               = @"DivisionName";
NSString* const kRouteName                  = @"RouteName";
NSString* const kDayPassengerCount          = @"DayPassengerCount";
NSString* const kDayTrainCount              = @"DayTrainCount";
NSString* const kDayOnTimeTrainCount        = @"DayOnTimeTrainCount";
NSString* const kDayOTP                     = @"DayOTP";
NSString* const kMTDPassengerCount          = @"MTDPassengerCount";
NSString* const kMTDTrainCount              = @"MTDTrainCount";
NSString* const kMTDOnTimeTrainCount        = @"MTDOnTimeTrainCount";
NSString* const kMTDOTP                     = @"MTDOTP";
NSString* const kMonthOTP                   = @"MonthOTP";
NSString* const kPrevMonthPassengerCount    = @"PrevMonthPassengerCount";
NSString* const kPrevMonthTrainCount        = @"PrevMonthTrainCount";
NSString* const kPrevMonthOnTimeTrainCount  = @"PrevMonthOnTimeTrainCount";
NSString* const kPrevMonthOTP               = @"PrevMonthOTP";
NSString* const kRouteID                    = @"RouteID";
NSString* const kDivisionID                 = @"DivisionID";
@end
