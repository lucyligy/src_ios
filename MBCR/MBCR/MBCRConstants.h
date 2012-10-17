//
//  MBCRConstants.h
//  MBCR
//
//  Created by Alex Rouse on 6/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


#define kLocalyticsDebugKey                 @"052cc98f4a8372df9a22732-6279032c-d81b-11e1-48e6-00ef75f32667"
#define kLocalyticsProdKey                  @"052cc98f4a8372df9a22732-6279032c-d81b-11e1-48e6-00ef75f32667"
#define kAirshipDevKey                      @"lycrCoMRQCCUqr-N5K0wJQ"
#define kAirshipDevSecret                   @"6j1J-WlZSUmPMm3SGLAp4g"
#define kAirshipProdKey                     @"YnhsRz67SXSut0S3n8H_Aw"
#define kAirshipProdSecret                  @"nuCfnjDdQU661Yu-9U19Qw"
#define kAppBladeProjectId                  @"97a39e4e-7e62-4bee-9ac0-634dcec5571d"
#define kAppBladeProjectToken               @"44174623a7892e441f3257b1079d892a"
#define kAppBladeProjectSecret              @"52561204f461ffae5ccd98e476d2cc5f"
#define kAppBladeProjectIssuedTimestamp     @"1342534784"


@interface MBCRConstants : NSObject

//NSUserDefaults Keys
extern NSString* const kLastLaunchDate;
extern NSString* const kLastLineUpdate;
extern NSString* const kLastTrainupdate;
extern NSString* const kWebserviceCompletionDelegate;
extern NSString* const kUnreadAlertCount;
extern NSString* const kLastAlertViewDate;
//SERVER RESPONSE KEYS
extern NSString* const kResponseKey;
extern NSString* const kResponseDataKey;
extern NSString* const kResponseStatusKey;

//ErrorKeys
extern NSString* const kResponseErrorCode;
extern NSString* const kResponseErrorMessage;

extern NSString* const kResponseSuccess;
extern NSString* const KResponseTimestamp;

extern NSString* const kCommentsPageURL;

//TAlerts
extern NSString* const kTAlertsLine;
extern NSString* const kTAlertsMessage;
extern NSString* const kTAlertsReceivedOn;
extern NSString* const kTAlertsSender;
extern NSString* const kTAlertsSenderEmail;
extern NSString* const kTAlertsSentOn;
extern NSString* const kTAlertsSubject;
extern NSString* const kTAlertsTrainNo;
extern NSString* const kTAlertsGUID;
extern NSString* const kTAlertsDivision;
extern NSString* const kTAlertsLineId;

//AllPageAlerts
extern NSString* const kAllPageAlertsMessage;
extern NSString* const kAllPageAlertsReceivedOn;
extern NSString* const kAllPageAlertsSender;
extern NSString* const kAllPageAlertsSenderEmail;
extern NSString* const kAllPageAlertsSentOn;
extern NSString* const kAllPageAlertsDivision;
extern NSString* const kAllPageAlertsLine;
extern NSString* const kAllPageAlertsTrain;
extern NSString* const kAllPageAlertsGuid;

//LineFeed
extern NSString* const kLineDescription;
extern NSString* const kLineID;
extern NSString* const kLineDivision;

//DepartureInformation
extern NSString* const kDepartureInfoCarrier;
extern NSString* const kDepartureInfoTrain;
extern NSString* const kDepartureInfoTime;
extern NSString* const kDepartureInfoPredTime;
extern NSString* const kDepartureInfoOrigin;
extern NSString* const kDepartureInfoDestination;
extern NSString* const kDepartureInfoTrack;
extern NSString* const kDepartureInfoStatus;

//Document Keys
extern NSString* const kDocumentLastUpdated;
extern NSString* const kDocumentTitle;
extern NSString* const kDocumentURL;
extern NSString* const kDocumentModifyDate;
extern NSString* const kDocumentExtension;
extern NSString* const kDocumentType;

//Bulletin Keys
extern NSString* const kBulletinStartDate;
extern NSString* const kBulletinExpireDate;
extern NSString* const kBulletinUploadDate;
extern NSString* const kBulletinModifyDate;
extern NSString* const kBulletinName;
extern NSString* const kBulletinWebURL;

//SubwayAlerts
extern NSString* const kSubwayAlertsGuid;
extern NSString* const kSubwayAlertsMessage;
extern NSString* const kSubwayAlertsRecievedOn;
extern NSString* const kSubwayAlertsSender;
extern NSString* const kSubwayAlertsSenderEmail;
extern NSString* const kSubwayAlertsSubject;
extern NSString* const kSubwayAlertsTrainNo;
extern NSString* const kSubwayAlertsLine;
extern NSString* const kSubwayAlertsDivision;
extern NSString* const kSubwayAlertsService;

//AVL Keys
extern NSString* const kAVLDestination;
extern NSString* const kAVLFlag;
extern NSString* const kAVLHeading;
extern NSString* const kAVLLateness;
extern NSString* const kAVLLatitude;
extern NSString* const kAVLLineId;
extern NSString* const kAVLLongitude;
extern NSString* const kAVLScheduled;
extern NSString* const kAVLSpeed;
extern NSString* const kAVLStop;
extern NSString* const kAVLTimeStamp;
extern NSString* const kAVLTrain;
extern NSString* const kAVLVechicle;

//Train Keys
extern NSString* const kTrainDivision;
extern NSString* const kTrainID;
extern NSString* const kTrainLine;
extern NSString* const kTrainLineID;
extern NSString* const kTrainTrain;

extern NSString* const kSubwayGreenLineKey;
extern NSString* const kSubwayRedLineKey;
extern NSString* const kSubwayOrangeLineKey;
extern NSString* const kSubwayBlueLineKey;
extern NSString* const kSubwaySilverLineKey;

//Station Strings
extern NSString* const kStationNorthStationKey;
extern NSString* const kStationSouthStationKey;

//File Extension
extern NSString* const kFileTypePDF;
extern NSString* const kFileTypeHTML;

//Manual types
extern NSString* const kManualTypeHotTopics;
extern NSString* const kManualTypeSchedule;
extern NSString* const kManualTypeOtherNotice;
extern NSString* const kManualTypeQuickReference;
extern NSString* const kManualTypeManual;

//Localytics
//Screens
extern NSString* const kLocalScreenMBCRMessage;
extern NSString* const kLocalScreenSubwayMessage;
extern NSString* const kLocalScreenMessageDetails;
extern NSString* const kLocalScreenLocation;
extern NSString* const kLocalScreenLocationDetails;
extern NSString* const kLocalScreenTrackSouth;
extern NSString* const kLocalScreenTrackNorth;
extern NSString* const kLocalScreenReference;
extern NSString* const kLocalScreenComment;

//Actions
extern NSString* const kLocalActionTrainSelected;
extern NSString* const kLocalActionTrainTapped;
extern NSString* const kLocalActionDropDownOpened;
extern NSString* const kLocalActionTabSelected;
extern NSString* const kLocalActionDocumentViewed;
extern NSString* const kLocalActionBulletinViewed;
extern NSString* const kLocalActionAppOpened;
extern NSString* const kLocalActionMessageViewed;
extern NSString* const kLocalActionMessageFilter;
extern NSString* const kLocalActionSubwayMessageViewed;
extern NSString* const kLocalActionSubwayFilter;

//Attributes
extern NSString* const kLocalAttributeRegion;
extern NSString* const kLocalAttributeLine;
extern NSString* const kLocalAttributeNameOfTab;
extern NSString* const kLocalAttributeName;
extern NSString* const kLocalAttributeType;
extern NSString* const kLocalAttributeMethod;


//TimeKeys
#define kSecondsInDay       86400.0
#define kSecondsIn15Minutes 900.0
#define kSecondsIn5Minutes  300.0

#define kViewFlipDuration   0.8
@end
