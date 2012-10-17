//
//  MBCRDataManager.h
//  MBCR
//
//  Created by Alex Rouse on 6/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Line.h"
#import "Manual.h"
#import "Bulletin.h"

@interface MBCRDataManager : NSObject

@property (nonatomic, assign) dispatch_queue_t importerQueue;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, strong) NSString* dbPath;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, strong) NSString* currentTrainNo;

+ (MBCRDataManager*)shared;

//FetchResultsController
- (NSFetchedResultsController *)alertsFetchResultsController;
- (NSFetchedResultsController *)alertsFetchResultsControllerFilterByLine:(Line *)line;
- (NSFetchedResultsController *)alertsFetchResultsControllerFilterByLines:(NSArray *)lines;
- (NSFetchedResultsController *)alertsFetchResultsControllerFilterByTrain:(Train *)train;
- (NSFetchedResultsController *)alertsFetchResultsControllerFilterByTrains:(NSArray *)trains;
- (NSFetchedResultsController *)alertsFetchResultsControllerFilterByRegion:(NSString *)region;
- (NSFetchedResultsController *)lineFetchResultsController;
- (NSFetchedResultsController *)subwayAlertsFetchResultsController;
- (NSFetchedResultsController *)subwayAlertsFetchResultsControllerFilterByLine:(NSString *)line;
- (NSFetchedResultsController *)documentsResultsController;
- (NSFetchedResultsController *)documentsResultsControllerForManualType:(NSString *)manualType;
- (NSFetchedResultsController *)trackAssigmentsFetchResultsController;
- (NSFetchedResultsController *)stationTrackAssignmentsFetchResultsController:(NSString *)station;
- (NSFetchedResultsController *)avlFetchResultsController;
- (NSFetchedResultsController *)bulletinResultsController;
- (NSFetchedResultsController *)unreadBulletinResultsController;

- (NSInteger) numberUnreadMessagesFromDate:(NSDate *)date;

- (Line *)findLineForLineDescription:(NSString *)lineDescription;
- (void)updateOpenedDateForManual:(Manual *)manual;
- (void)updateOpenedDateForBulletin:(Bulletin *)bulletin;
- (void)updateDownloadDateForBulletin:(Bulletin *)bulletin;
- (NSInteger)numberOfUnreadBulletins;

- (void)importTAlerts:(NSArray *)alertsArray;
- (void)importAllPageAlerts:(NSArray *)alertsArray;
- (void)importLineList:(NSArray *)lineArray;
- (void)importTrackAssignments:(NSArray *)trackArray withTime:(NSDate *)time;
- (void)importDocumentList:(NSArray *)docArray;
- (void)importBulletinList:(NSArray *)docArray; 
- (void)importSubwayAlerts:(NSArray *)alertsArray;
- (void)importAVLInformation:(NSArray*)info withTime:(NSDate *)time;
- (void)importTrains:(NSArray *)trains withTime:(NSDate *)time;

@end
