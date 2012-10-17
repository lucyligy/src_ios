//
//  MBCRDataManager.m
//  MBCR
//
//  Created by Alex Rouse on 6/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MBCRDataManager.h"
#import "TAlert.h"
#import "AllPageAlert.h"
#import "TrackAssignment.h"
#import "SubwayAlert.h"
#import "Manual.h"
#import "AVL.h"
#import "Train.h"
#import "NSDate+Formatter.h"
#import "NSDictionary+NSNull.h"
#import "RZFileManager.h"
#import "RZWebServiceRequest.h"
#import "MBCRAppDelegate.h"

static MBCRDataManager *s_dataManager;

@interface MBCRDataManager()
- (NSFetchedResultsController *)fetchResultsControllerForEntityName:(NSString *)entity sortDescriptor:(NSString *)desc ascending:(BOOL)ascending;
- (void)clearEntriesForEntityName:(NSString *)name;

@end

@implementation MBCRDataManager
@synthesize importerQueue = _importerQueue;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;
@synthesize dbPath = _dbPath;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize currentTrainNo = _currentTrainNo;


+ (MBCRDataManager*)shared
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_dataManager = [[MBCRDataManager alloc] init];
    });
    
    return s_dataManager;
}

- (id)init {
    self = [super init];
    if (self) {
        self.importerQueue = dispatch_queue_create("MBCRImportQueue", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (void)dealloc
{
    dispatch_release(_importerQueue);
    _importerQueue = nil;
}


- (NSManagedObjectContext*)safeMOC
{
    NSManagedObjectContext* moc = nil;
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil)
    {
        moc = [[NSManagedObjectContext alloc] init];
        [moc setPersistentStoreCoordinator:coordinator];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(safeMOCSaved:) name:NSManagedObjectContextDidSaveNotification object:moc];
    }
    
    return moc;
}

- (void)safeMOCSaved:(NSNotification*)notification
{
    [self.managedObjectContext performSelectorOnMainThread:@selector(mergeChangesFromContextDidSaveNotification:)
                                                withObject:notification
                                             waitUntilDone:NO];
    
}

- (NSManagedObjectContext*)managedObjectContext
{
    if (__managedObjectContext != nil)
    {
        return __managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil)
    {
        __managedObjectContext = [[NSManagedObjectContext alloc] init];
        [__managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    
    return __managedObjectContext;
}


- (NSPersistentStoreCoordinator*)persistentStoreCoordinator
{
    if (__persistentStoreCoordinator != nil)
    {
        return __persistentStoreCoordinator;
    }
    
    // if there's no default path set for the datbase, use the documents directory
    if(nil == self.dbPath)
    {
        self.dbPath = [[self applicationDocumentsDirectory] stringByAppendingPathComponent:@"MBCR.sqlite"];
    }
    
    RZLog(@"Opening Persistent Store at: %@", self.dbPath);
    
    // if the file doesn't exist, copy it from the prepackaced bundle. 
    NSFileManager* manager = [NSFileManager defaultManager];
    
    if (![manager fileExistsAtPath:self.dbPath]) {
        
        [self installDefaultDB];
    }
    
    NSError *error = nil;
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:[NSURL fileURLWithPath:self.dbPath] options:nil error:&error])
    {
        // there was an error; delete the existing database and try again.
        RZLog(@"Database error (so we're deleting the DB) %@, %@", error, [error userInfo]);
        
        error = nil;
        [manager removeItemAtPath:self.dbPath error:&error];
        
        [self installDefaultDB];
        
        // try. again.
        if(![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:[NSURL fileURLWithPath:self.dbPath] options:nil error:&error])
        {
            RZError(@"Unresolveable DB error (we tried. Really, we did.) %@, %@", error, [error userInfo]);
            abort();
        }
        
    }
    
    return __persistentStoreCoordinator;
}

- (void)installDefaultDB
{
    // this is the path to the default database.
    NSString* bundledDBPath = [[NSBundle mainBundle] pathForResource:@"MBCR" ofType:@"sqlite"];
    
    // if the file doesn't exist, copy it from the prepackaced bundle. 
    NSFileManager* manager = [NSFileManager defaultManager];
    
    // only copy it if it exists (we may be in the test cases, in which case this needs to start 
    // without a database and generate one for itself
    
    NSError* error = nil;
    
    if([manager fileExistsAtPath:bundledDBPath])
    {
        RZLog(@"Copying pre-packaged MBCR.sqlite");
        if(![manager copyItemAtPath:bundledDBPath toPath:self.dbPath error:&error])
        {
            RZError(@"Could not copy pre-packaged MBCR.sqlite: %@", error);
        }
    }
    else
    {
        RZError(@"Could not locate pre-packaged MBCR.sqlite");
    }
    
}


- (NSString*)applicationDocumentsDirectory
{
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 
    return [paths objectAtIndex:0];
}
- (NSString*)bundlePath
{
    return [[NSBundle bundleForClass:[MBCRDataManager class]] bundlePath];
}
- (NSManagedObjectModel*)managedObjectModel
{
    if (__managedObjectModel != nil)
    {
        return __managedObjectModel;
    }
    NSString* path = [[self bundlePath] stringByAppendingPathComponent:@"MBCR.momd"];
    NSURL *modelURL = [NSURL fileURLWithPath:path];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return __managedObjectModel;
}

- (NSFetchedResultsController *)alertsFetchResultsController {
    return [self fetchResultsControllerForEntityName:@"MBCRAlert" sortDescriptor:@"receivedOn" ascending:NO];
}

- (NSFetchedResultsController *)alertsFetchResultsControllerFilterByLine:(Line *)line {
    return [self alertsFetchResultsControllerFilterByLines:[NSArray arrayWithObject:line]];
}

- (NSFetchedResultsController *)alertsFetchResultsControllerFilterByLines:(NSArray *)lines {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"MBCRAlert"];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"receivedOn" ascending:NO]]];

    NSMutableString* predicateString = [[NSMutableString alloc] init];
    if (lines.count > 0) {
        [predicateString appendFormat:@"( "];
        for (Line *line in lines) {
            [predicateString appendFormat:@"ANY line.lineId == %@ || ",line.lineId];
        }
        [predicateString appendFormat:@"ANY line == nil)"];
        fetchRequest.predicate = [NSPredicate predicateWithFormat:predicateString];
    } else {
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"ANY line == nil"];
    }
    NSFetchedResultsController* resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[self managedObjectContext] sectionNameKeyPath:nil cacheName:nil];
    return resultsController;
}

- (NSFetchedResultsController *)alertsFetchResultsControllerFilterByTrain:(Train *)train {
    return [self alertsFetchResultsControllerFilterByTrains:[NSArray arrayWithObject:train]];
}

- (NSFetchedResultsController *)alertsFetchResultsControllerFilterByTrains:(NSArray *)trains {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"MBCRAlert"];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"receivedOn" ascending:NO]]];
    
    NSMutableString* predicateString = [[NSMutableString alloc] init];
    
    [predicateString appendFormat:@"( "];
    for (Train *train in trains) {
        [predicateString appendFormat:@"ANY train.trainNo == \"%@\" || ",train.trainNo];
    }
    [predicateString appendFormat:@"ANY line == nil)"];
    
    fetchRequest.predicate = [NSPredicate predicateWithFormat:predicateString];
    NSFetchedResultsController* resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[self managedObjectContext] sectionNameKeyPath:nil cacheName:nil];
    
    return resultsController;
}

- (NSFetchedResultsController *)alertsFetchResultsControllerFilterByRegion:(NSString *)region {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"MBCRAlert"];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"receivedOn" ascending:NO]]];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"(region == %@ || region == %@)",@"",region];
    NSFetchedResultsController* resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[self managedObjectContext] sectionNameKeyPath:nil cacheName:nil];
    
    return resultsController;
}

- (NSFetchedResultsController *)lineFetchResultsController {
    return [self fetchResultsControllerForEntityName:@"Line" sortDescriptor:@"lineId" ascending:NO];
}

- (NSFetchedResultsController *)subwayAlertsFetchResultsController {
    return [self fetchResultsControllerForEntityName:@"SubwayAlert" sortDescriptor:@"receivedOn" ascending:NO];
}

- (NSFetchedResultsController *)subwayAlertsFetchResultsControllerFilterByLine:(NSString *)line {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"SubwayAlert"];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"receivedOn" ascending:NO]]];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"(line == %@ || line == %@)",@"",line];

    NSFetchedResultsController* resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[self managedObjectContext] sectionNameKeyPath:nil cacheName:nil];
    
    return resultsController;
}

- (NSFetchedResultsController *)bulletinResultsController {
    return [self fetchResultsControllerForEntityName:@"Bulletin" sortDescriptor:@"expireDate" ascending:NO];
}

- (NSFetchedResultsController *)unreadBulletinResultsController {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Bulletin"];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"lastOpened" ascending:NO]]];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"(lastOpened<downloadDate) || (lastOpened == nil)"];
    NSFetchedResultsController* resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[self managedObjectContext] sectionNameKeyPath:nil cacheName:nil];
    
    return resultsController;
}

- (NSFetchedResultsController *)documentsResultsController {
    return [self fetchResultsControllerForEntityName:@"Manual" sortDescriptor:@"name" ascending:YES];
}
- (NSFetchedResultsController *)documentsResultsControllerForManualType:(NSString *)manualType {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Manual"];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"lastOpened" ascending:NO]]];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"(type == %@)",manualType];
    NSFetchedResultsController* resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[self managedObjectContext] sectionNameKeyPath:nil cacheName:nil];
    
    return resultsController;
}

- (NSFetchedResultsController *)trackAssigmentsFetchResultsController {
    return [self fetchResultsControllerForEntityName:@"TrackAssignment" sortDescriptor:@"predictedDepartureTime" ascending:YES];
}

- (NSFetchedResultsController *)stationTrackAssignmentsFetchResultsController:(NSString *)station {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"TrackAssignment"];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"predictedDepartureTime" ascending:YES],[NSSortDescriptor sortDescriptorWithKey:@"track" ascending:YES],[NSSortDescriptor sortDescriptorWithKey:@"destination" ascending:YES],nil]];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"(origin == %@)", station];
    NSFetchedResultsController* resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[self managedObjectContext] sectionNameKeyPath:nil cacheName:nil];
    
    return resultsController;
}

- (NSFetchedResultsController *)avlFetchResultsController {
    return [self fetchResultsControllerForEntityName:@"AVL" sortDescriptor:@"trip" ascending:YES];
}

- (NSFetchedResultsController *)trainFetchResultsController {
    return [self fetchResultsControllerForEntityName:@"Train" sortDescriptor:@"trainNo" ascending:YES];
}

- (NSFetchedResultsController *)fetchResultsControllerForEntityName:(NSString *)entity sortDescriptor:(NSString *)desc ascending:(BOOL)ascending {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:entity];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:desc ascending:ascending]]];
    NSFetchedResultsController* resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[self managedObjectContext] sectionNameKeyPath:nil cacheName:nil];
    return resultsController;
}

-(NSInteger) numberUnreadMessagesFromDate:(NSDate *)date
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"MBCRAlert"];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"(receivedOn > %@)",date];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"receivedOn" ascending:NO]]];
    
    NSFetchedResultsController* resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[self safeMOC] sectionNameKeyPath:nil cacheName:nil];
    
    NSError *error = nil;
    [resultsController performFetch:&error];
    if(error != nil){
        return 0;
    }
    return [[resultsController fetchedObjects] count];
}


- (Line *)findLineForLineDescription:(NSString *)lineDescription {
    Line *line = nil;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Line"];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"( lineDescription == %@ )", lineDescription];
    NSError *error = nil;
    NSArray *results = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (error == nil && [results count] > 0) {
        line = [results objectAtIndex:0];
    }
    return line;
}

- (void)updateOpenedDateForManual:(Manual *)manual {
    manual.lastOpened = [NSDate date];
    NSError *saveError = nil;
    if (![self.managedObjectContext save:&saveError])
    {
        RZError(@"Error saving Manual update: %@", saveError);
    }
}
- (void)updateOpenedDateForBulletin:(Bulletin *)bulletin {
    if (bulletin.downloadDate == nil) {
        bulletin.downloadDate = [NSDate date];
    }
    bulletin.lastOpened = [NSDate date];
    NSError *saveError = nil;
    if (![self.managedObjectContext save:&saveError])
    {
        RZError(@"Error saving Bulletin update: %@", saveError);
    }
    MBCRAppDelegate* appDel = (MBCRAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDel updateReferenceTabBarImage];
}
- (void)updateDownloadDateForBulletin:(Bulletin *)bulletin {
    bulletin.downloadDate = [NSDate date];
    NSError *saveError = nil;
    if (![self.managedObjectContext save:&saveError])
    {
        RZError(@"Error saving Bulletin update: %@", saveError);
    }
}

- (void)reDownloadBulletin:(Bulletin *)bulletin {
    [[[UIAlertView alloc] initWithTitle:@"There Was A Problem With That Bulletin" message:@"Please wait while we download that bulletin again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
    [[RZFileManager defaultManager] deleteFileFromCacheWithRemoteURL:[NSURL URLWithString:bulletin.url]];
    [[RZFileManager defaultManager] downloadFileFromURL:[NSURL URLWithString:bulletin.url] withProgressDelegate:nil completion:^(BOOL success, NSURL *downloadedFile, RZWebServiceRequest *request) {
        Bulletin* bulletin = [self getBulletinFromURL:[request url] withMOC:[self safeMOC]];
        bulletin.downloadDate = [NSDate date];
        RZLog(@"Bulletin Updated from:%@",downloadedFile);
    }];
}

- (void)reDownloadManual:(Manual *)manual {
    [[[UIAlertView alloc] initWithTitle:@"There Was A Problem With That Bulletin" message:@"Please wait while we download that bulletin again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
    [[RZFileManager defaultManager] deleteFileFromCacheWithRemoteURL:[NSURL URLWithString:manual.url]];
    [[RZFileManager defaultManager] downloadFileFromURL:[NSURL URLWithString:manual.url] withProgressDelegate:nil completion:^(BOOL success, NSURL *downloadedFile, RZWebServiceRequest *request) {
        Manual* manual = [self getManualFromURL:[request url] withMOC:[self safeMOC]];
        manual.downloadDate = [NSDate date];
        RZLog(@"Bulletin Updated from:%@",downloadedFile);
    }];
}

- (NSInteger)numberOfUnreadBulletins {
    NSFetchedResultsController* frc = [self unreadBulletinResultsController];
    NSError* error = nil;
    if (![frc performFetch:&error]) {
        RZError(@"Error getting number of unread Bulletins:%@",error);
        return 0;
    }
    
    return [[frc fetchedObjects] count];
}


- (Bulletin *)getBulletinFromURL:(NSURL *)url withMOC:(NSManagedObjectContext *)moc{
    Bulletin *ret = nil;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Bulletin"];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"( url == %@ )", url];
    NSError *error = nil;
    NSArray *results = [moc executeFetchRequest:fetchRequest error:&error];
    if (error == nil && [results count] > 0) {
        ret = [results objectAtIndex:0];
    }
    return ret;
}

- (Manual *)getManualFromURL:(NSURL *)url withMOC:(NSManagedObjectContext *)moc {
    Manual *ret = nil;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Manual"];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"( url == %@ )", [url path]];
    NSError *error = nil;
    NSArray *results = [moc executeFetchRequest:fetchRequest error:&error];
    if (error == nil && [results count] > 0) {
        ret = [results objectAtIndex:0];
    }
    return ret;
}

- (void)clearEntriesForEntityName:(NSString *)name {
    
    NSDictionary *entities = [self.managedObjectModel entitiesByName];

    NSEntityDescription* entity = [entities objectForKey:name];
    

    NSFetchRequest *entityFetchRequest = [[NSFetchRequest alloc] init];
    entityFetchRequest.entity = entity;
    
    NSError *error = nil;
    NSArray *entityObjects = [self.managedObjectContext executeFetchRequest:entityFetchRequest error:&error];
    if (error)
    {
        NSLog(@"Error Clearing Entity: %@ Error: %@", entity.name, error);
    }
    
    for (NSManagedObject *entityObject in entityObjects)
    {
        [self.managedObjectContext deleteObject:entityObject];
    }

    if (![self.managedObjectContext save:&error])
    {
        NSLog(@"Error clearing all data from Core Data: %@", error);
    }

}

#pragma mark - ImportTAlerts
- (void)importTAlerts:(NSArray *)alertsArray {
    if(![alertsArray isKindOfClass:[NSArray class]]) {
        return;
    }
    dispatch_async(self.importerQueue, ^{
        
        NSManagedObjectContext *moc = [self safeMOC];
        
        NSArray *validAlerts = [self importTAlerts:alertsArray intoManagedObjectContext:moc];
        
        NSString *guid = ((TAlert*)[validAlerts lastObject]).guid;
        
        //Deletes any duplicates
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"TAlert"];
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"guid == %@ && NOT SELF in %@", guid, validAlerts];
        
        NSError *fetchError = nil;
        NSArray *removedAlerts = [moc executeFetchRequest:fetchRequest error:&fetchError];
        if (fetchError)
        {
            RZError(@"Error fetching messages to delete: %@", fetchError);
        }
        
        for (TAlert *removed in removedAlerts)
        {
            [moc deleteObject:removed];
        }
        
        //Delete any old Alerts
        NSFetchRequest *fetchRequest2 = [NSFetchRequest fetchRequestWithEntityName:@"TAlert"];
        
        NSArray *allAlerts = [moc executeFetchRequest:fetchRequest2 error:&fetchError];
        if (fetchError)
        {
            RZError(@"Error fetching messages to delete: %@", fetchError);
        }
        NSArray* removedAlerts2 = [allAlerts filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
            TAlert* alert = (TAlert *)evaluatedObject;
            return [alert.receivedOn isOlderThan24Hours];
        }]];
        
        for (TAlert *removed in removedAlerts2)
        {
            [moc deleteObject:removed];
        }
        
        NSError *saveError = nil;
        if (![moc save:&saveError])
        {
            RZError(@"Error saving TAlert messages import: %@", saveError);
        }
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [((MBCRAppDelegate *)[[UIApplication sharedApplication] delegate]) updateAlertsTabBarImage];
        });

    });

}

- (NSArray*)importTAlerts:(NSArray*)alerts intoManagedObjectContext:(NSManagedObjectContext *)moc
{
    NSMutableArray *importedAlerts = [NSMutableArray arrayWithCapacity:[alerts count]];
    
    for (NSDictionary *alert in alerts)
    {
        TAlert *tAlert = [self importTAlert:alert intoManagedObjectContext:moc];
        
        if (tAlert)
        {
            [importedAlerts addObject:tAlert];
        }
    }
    
    return importedAlerts;
}

- (TAlert*)importTAlert:(NSDictionary*)alert intoManagedObjectContext:(NSManagedObjectContext *)moc
{
    TAlert *importedAlert = nil;
    
    NSString* guid = [alert validObjectForKey:kTAlertsGUID];
    NSString* recievedOn = [alert validObjectForKey:kTAlertsReceivedOn];
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"TAlert"];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"guid == %@", guid];
    
    NSError *fetchError = nil;
    NSArray *fetchedAlerts = [moc executeFetchRequest:fetchRequest error:&fetchError];
    if (fetchError)
    {
        RZError(@"Error fetching TAlerts with Id:%@.  Error: %@", recievedOn, fetchError);
    }
    
    if ([fetchedAlerts count] > 0)
    {
        importedAlert = [fetchedAlerts objectAtIndex:0];
    }
    else
    {
        importedAlert = [NSEntityDescription insertNewObjectForEntityForName:@"TAlert" inManagedObjectContext:moc];
        importedAlert.guid = guid;
    }
    NSString* line = [alert validObjectForKey:kTAlertsLineId];
    NSString* sentOn = [alert validObjectForKey:kTAlertsSentOn];
    
    importedAlert.subject = [alert validObjectForKey:kTAlertsSubject];
    importedAlert.message = [alert validObjectForKey:kTAlertsMessage];
    importedAlert.sender = [alert validObjectForKey:kTAlertsSender];
    importedAlert.senderEmail = [alert validObjectForKey:kTAlertsSenderEmail];
    importedAlert.region = [alert validObjectForKey:kTAlertsDivision];
    
    importedAlert.receivedOn = [NSDate dateFromDotNetString:recievedOn];
    importedAlert.sentOn = [NSDate dateFromDotNetString:sentOn];

    if (line != nil) {
        Line * currentLine = nil;
        NSFetchRequest *lineFetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Line"];
        lineFetchRequest.predicate = [NSPredicate predicateWithFormat:@"lineId == %@",line];
        
        NSError *lineFetchError = nil;
        NSArray *fetchedLines = [moc executeFetchRequest:lineFetchRequest error:&lineFetchError];
        if (lineFetchError) {
            RZError(@"Error fetching LineNumber");
        }
        if([fetchedLines count] > 0) {
                currentLine = [fetchedLines lastObject];
        } else {
            currentLine = [NSEntityDescription insertNewObjectForEntityForName:@"Line" inManagedObjectContext:moc];
            currentLine.lineId = [NSNumber numberWithInteger:[line integerValue]];
            currentLine.region = [alert validObjectForKey:kTAlertsDivision];
            currentLine.lineDescription = [alert validObjectForKey:kTAlertsLine];
        }
        
        [importedAlert addLineObject:currentLine];
    } else {
        importedAlert.line = nil;
    }
    NSString* train = [[alert validObjectForKey:kTAlertsTrainNo] stringByReplacingOccurrencesOfString:@" " withString:@""];
    Train * currentTrain = nil;
    
    if (train != nil && train.length > 0) {
        NSFetchRequest *trainFetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Train"];
        trainFetchRequest.predicate = [NSPredicate predicateWithFormat:@"trainNo == %@",train];
        
        NSError *fetchError = nil;
        NSArray *fetchedTrains = [moc executeFetchRequest:trainFetchRequest error:&fetchError];
        if (fetchError) {
            RZError(@"Error fetching Train");
        }
        
        if ([fetchedTrains count] > 0) {
            currentTrain = [fetchedTrains lastObject];
        } else {
            currentTrain = [NSEntityDescription insertNewObjectForEntityForName:@"Train" inManagedObjectContext:moc];
            currentTrain.trainNo = train;
            currentTrain.line = [importedAlert.line anyObject];
        }
        [importedAlert addTrainObject:currentTrain];
    }


    
    return importedAlert;
}

- (void)importAllPageAlerts:(NSArray *)alertsArray {
    if(![alertsArray isKindOfClass:[NSArray class]]) {
        return;
    }
    dispatch_async(self.importerQueue, ^{
        NSManagedObjectContext *moc = [self safeMOC];
        
        NSArray *validAlerts = [self importAllPageAlerts:alertsArray intoManagedObjectContext:moc];
        
        NSString *guid = ((AllPageAlert*)[validAlerts lastObject]).guid;
        
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"AllPageAlert"];
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"guid == %@ && NOT SELF in %@", guid, validAlerts];
        
        NSError *fetchError = nil;
        NSArray *removedAlerts = [moc executeFetchRequest:fetchRequest error:&fetchError];
        if (fetchError)
        {
            RZError(@"Error fetching messages to delete: %@", fetchError);
        }
        
        for (AllPageAlert *removed in removedAlerts)
        {
            [moc deleteObject:removed];
        }
        
        //Delete any old Alerts
        NSFetchRequest *fetchRequest2 = [NSFetchRequest fetchRequestWithEntityName:@"AllPageAlert"];

        NSArray *allAlerts = [moc executeFetchRequest:fetchRequest2 error:&fetchError];
        if (fetchError)
        {
            RZError(@"Error fetching messages to delete: %@", fetchError);
        }
        NSArray* removedAlerts2 = [allAlerts filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
            AllPageAlert* alert = (AllPageAlert *)evaluatedObject;
            return [alert.receivedOn isOlderThan24Hours];
        }]];
        
        for (AllPageAlert *removed in removedAlerts2)
        {
            [moc deleteObject:removed];
        }
        
        NSError *saveError = nil;
        if (![moc save:&saveError])
        {
            RZError(@"Error saving messages import: %@", saveError);
        }
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [((MBCRAppDelegate *)[[UIApplication sharedApplication] delegate]) updateAlertsTabBarImage];
        });

    });
    
}

- (NSArray*)importAllPageAlerts:(NSArray*)alerts intoManagedObjectContext:(NSManagedObjectContext *)moc
{
    NSMutableArray *importedAlerts = [NSMutableArray arrayWithCapacity:[alerts count]];
    
    for (NSDictionary *alert in alerts)
    {
        AllPageAlert *allAlert = [self importAllPageAlert:alert intoManagedObjectContext:moc];
        
        if (allAlert)
        {
            [importedAlerts addObject:allAlert];
        }
    }
    
    return importedAlerts;
}

- (AllPageAlert*)importAllPageAlert:(NSDictionary*)alert intoManagedObjectContext:(NSManagedObjectContext *)moc
{
    AllPageAlert *importedAlert = nil;
    
    NSString* guid = [alert validObjectForKey:kAllPageAlertsGuid];
    NSString* recievedOn = [alert validObjectForKey:kAllPageAlertsReceivedOn];
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"AllPageAlert"];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"guid == %@", guid];
    
    NSError *fetchError = nil;
    NSArray *fetchedAlerts = [moc executeFetchRequest:fetchRequest error:&fetchError];
    if (fetchError)
    {
        RZError(@"Error fetching AllPageAlerts with Id:%@.  Error: %@", recievedOn, fetchError);
    }
    
    if ([fetchedAlerts count] > 0)
    {
        importedAlert = [fetchedAlerts objectAtIndex:0];
    }
    else
    {
        importedAlert = [NSEntityDescription insertNewObjectForEntityForName:@"AllPageAlert" inManagedObjectContext:moc];
        importedAlert.guid = guid;
    }
    NSString* sentOn = [alert validObjectForKey:kAllPageAlertsSentOn];
    NSArray* lines = [alert validObjectForKey:kAllPageAlertsLine];
    importedAlert.receivedOn = [NSDate dateFromDotNetString:recievedOn];
    importedAlert.sentOn = [NSDate dateFromDotNetString:sentOn];
    importedAlert.region = [alert validObjectForKey:kAllPageAlertsDivision];
    importedAlert.message = [alert validObjectForKey:kAllPageAlertsMessage];
    importedAlert.sender = [alert validObjectForKey:kAllPageAlertsSender];
    importedAlert.senderEmail = [alert validObjectForKey:kAllPageAlertsSenderEmail];

    if (lines != nil) {
        for (NSNumber* num in lines) {
            Line * currentLine = nil;
            NSFetchRequest *lineFetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Line"];
            lineFetchRequest.predicate = [NSPredicate predicateWithFormat:@"lineId == %@",num];
            
            NSError *lineFetchError = nil;
            NSArray *fetchedLines = [moc executeFetchRequest:lineFetchRequest error:&lineFetchError];
            if (lineFetchError) {
                RZError(@"Error fetching LineNumber");
            }
            
            if([fetchedLines count] > 0) {
                currentLine = [fetchedLines lastObject];
            } else {
                currentLine = [NSEntityDescription insertNewObjectForEntityForName:@"Line" inManagedObjectContext:moc];
                currentLine.lineId = num;
                currentLine.region = [alert validObjectForKey:kAllPageAlertsDivision];
            }
            
            [importedAlert addLineObject:currentLine];
        } 
    }
    
    NSArray* trains = [alert validObjectForKey:kAllPageAlertsTrain];
    Train * currentTrain = nil;
    if (trains != nil) {
        for (NSString* trainNo in trains) {
            NSString* train = [trainNo stringByReplacingOccurrencesOfString:@" " withString:@""];
            NSFetchRequest *trainFetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Train"];
            trainFetchRequest.predicate = [NSPredicate predicateWithFormat:@"trainNo == %@",train];
            
            NSError *fetchError = nil;
            NSArray *fetchedTrains = [moc executeFetchRequest:trainFetchRequest error:&fetchError];
            if (fetchError) {
                RZError(@"Error fetching Train");
            }
            
            if ([fetchedTrains count] > 0) {
                currentTrain = [fetchedTrains lastObject];
            }  else {
                currentTrain = [NSEntityDescription insertNewObjectForEntityForName:@"Train" inManagedObjectContext:moc];
                currentTrain.trainNo = train;
                currentTrain.line = [importedAlert.line anyObject];
            }
            [importedAlert addTrainObject:currentTrain];
        }
    }

    return importedAlert;
}

- (void)importLineList:(NSArray *)lineArray {
    if(![lineArray isKindOfClass:[NSArray class]]) {
        return;
    }
    dispatch_async(self.importerQueue, ^{
        NSManagedObjectContext *moc = [self safeMOC];
        
        NSArray *validLines = [self importLineList:lineArray intoManagedObjectContext:moc];
        
        NSNumber *lineId = ((Line*)[validLines lastObject]).lineId;
        
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Line"];
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"lineId == %@ && NOT SELF in %@", lineId, validLines];
        
        NSError *fetchError = nil;
        NSArray *removedLines = [moc executeFetchRequest:fetchRequest error:&fetchError];
        if (fetchError)
        {
            RZError(@"Error fetching Lines to delete: %@", fetchError);
        }
        
        for (Line *removed in removedLines)
        {
            [moc deleteObject:removed];
        }
        
        NSError *saveError = nil;
        if (![moc save:&saveError])
        {
            RZError(@"Error saving line import: %@", saveError);
        }
    });
    
}

- (NSArray*)importLineList:(NSArray*)lines intoManagedObjectContext:(NSManagedObjectContext *)moc
{
    NSMutableArray *importedLines = [NSMutableArray arrayWithCapacity:[lines count]];
    
    for (NSDictionary *line in lines)
    {
        Line *importLine = [self importLine:line intoManagedObjectContext:moc];
        
        if (importLine)
        {
            [importedLines addObject:importLine];
        }
    }
    
    return importedLines;
}

- (Line*)importLine:(NSDictionary*)alert intoManagedObjectContext:(NSManagedObjectContext *)moc
{
    Line *importedLine = nil;
    
    NSString* lineStr = ((NSString *)[alert validObjectForKey:kLineID]);
    NSNumber* lineId = [NSNumber numberWithInt:[lineStr intValue]];

    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Line"];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"lineId == %@", lineId];
    
    NSError *fetchError = nil;
    NSArray *fetchedAlerts = [moc executeFetchRequest:fetchRequest error:&fetchError];
    if (fetchError)
    {
        RZError(@"Error fetching Line with Id:%@.  Error: %@", lineId, fetchError);
    }
    
    if ([fetchedAlerts count] > 0)
    {
        importedLine = [fetchedAlerts objectAtIndex:0];
    }
    else
    {
        importedLine = [NSEntityDescription insertNewObjectForEntityForName:@"Line" inManagedObjectContext:moc];
    }
    
    importedLine.lineDescription = [alert validObjectForKey:kLineDescription];
    importedLine.lineId = lineId;
    importedLine.region = [alert validObjectForKey:kLineDivision];
    
    return importedLine;
}


- (void)importSubwayAlerts:(NSArray *)alertsArray 
{
    if(![alertsArray isKindOfClass:[NSArray class]]) {
        return;
    }
    dispatch_async(self.importerQueue, ^{
        NSManagedObjectContext *moc = [self safeMOC];
        NSArray* validSubwayAlerts = [self importSubwayAlerts:alertsArray intoManagedObjectContext:moc];
        
        NSString* guid = ((SubwayAlert *)[validSubwayAlerts lastObject]).guid; 
        
        NSFetchRequest* fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"SubwayAlert"];
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"guid == %@ && NOT SELF in %@", guid, validSubwayAlerts];
        
        NSError* fetchError = nil;
        NSArray* removedLines = [moc executeFetchRequest:fetchRequest error:&fetchError];
        if (fetchError) {
            RZError(@"Error fetching subway Alerts to delete %@", fetchError);
        }
        
        //removing duplicate Alerts
        for (SubwayAlert* removed in removedLines) {
            [moc deleteObject:removed];
        }
        
        
        //Delete any old Alerts
        NSFetchRequest *fetchRequest2 = [NSFetchRequest fetchRequestWithEntityName:@"SubwayAlert"];
        
        NSArray *allAlerts = [moc executeFetchRequest:fetchRequest2 error:&fetchError];
        if (fetchError)
        {
            RZError(@"Error fetching Subway Alerts to delete: %@", fetchError);
        }
        NSArray* removedAlerts2 = [allAlerts filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
            SubwayAlert* alert = (SubwayAlert *)evaluatedObject;
            return [alert.receivedOn isOlderThan24Hours];
        }]];
        
        for (SubwayAlert *removed in removedAlerts2)
        {
            [moc deleteObject:removed];
        }

        
        NSError* saveError = nil;
        if (![moc save:&saveError]) {
            RZError(@"Error saving Subway Alerts import: %@", saveError);
        }
    });
}

- (NSArray *)importSubwayAlerts:(NSArray *)alertsArray intoManagedObjectContext:(NSManagedObjectContext *)moc
{
    NSMutableArray* importedSubwayAlerts = [NSMutableArray arrayWithCapacity:[alertsArray count]];
    
    for (NSDictionary* alert in alertsArray) {
        SubwayAlert* importAlert = [self importSubwayAlert:alert intoManagedObjectContext:moc];
        
        if (importedSubwayAlerts) {
            [importedSubwayAlerts addObject:importAlert];
        }
    }
    return importedSubwayAlerts;
}

-(SubwayAlert *)importSubwayAlert:(NSDictionary *)alert intoManagedObjectContext:(NSManagedObjectContext *)moc
{
    SubwayAlert* importAlert = nil;
    
    NSString* guid = [alert validObjectForKey:kSubwayAlertsGuid];
        
    NSFetchRequest* fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"SubwayAlert"];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"guid == %@", guid];
    
    NSError* fetchError = nil;
    NSArray* fetchedAlerts = [moc executeFetchRequest:fetchRequest error:&fetchError];
    if (fetchError) {
        RZError(@"Error fetching Subway alerts with GUID: %@; error: %@", guid, fetchError);
    }
    
    if ([fetchedAlerts count] > 0) {
        importAlert =  [fetchedAlerts objectAtIndex:0];
    } else {
        importAlert = [NSEntityDescription insertNewObjectForEntityForName:@"SubwayAlert" inManagedObjectContext:moc];
        importAlert.guid = guid;
    }
    
    NSString* recOn = [alert validObjectForKey:kSubwayAlertsRecievedOn];
    
    importAlert.message = [alert validObjectForKey:kSubwayAlertsMessage];
    importAlert.receivedOn = [NSDate dateFromDotNetString:recOn];
    importAlert.sender = [alert validObjectForKey:kSubwayAlertsSender];
    importAlert.senderEmail = [alert validObjectForKey:kSubwayAlertsSenderEmail];
    importAlert.subject = [alert validObjectForKey:kSubwayAlertsSubject];
    importAlert.trainNumber = [alert validObjectForKey:kSubwayAlertsTrainNo];
    importAlert.line = [alert validObjectForKey:kSubwayAlertsLine];
    importAlert.region = [alert validObjectForKey:kSubwayAlertsDivision];
    importAlert.service = [alert validObjectForKey:kSubwayAlertsService];

        
    return importAlert;
}
                                                                        



- (void)importTrackAssignments:(NSArray *)trackArray withTime:(NSDate *)time{
    if(![trackArray isKindOfClass:[NSArray class]]) {
        return;
    }
    dispatch_async(self.importerQueue, ^{
        NSManagedObjectContext *moc = [self safeMOC];
                
        NSArray *validAssignments = [self importTrackAssignments:trackArray intoManagedObjectContext:moc withTime:time];
        
        NSString *train = ((TrackAssignment*)[validAssignments lastObject]).train.trainNo;
        
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"TrackAssignment"];
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"train.trainNo == %@ && NOT SELF in %@", train, validAssignments];
        
        NSError *fetchError = nil;
        NSArray *removedLines = [moc executeFetchRequest:fetchRequest error:&fetchError];
        if (fetchError)
        {
            RZError(@"Error fetching Track Assignments to delete: %@", fetchError);
        }
        
        for (TrackAssignment *removed in removedLines)
        {
            [moc deleteObject:removed];
        }
        
        //Delete any old Assignments
        NSFetchRequest *allResults = [NSFetchRequest fetchRequestWithEntityName:@"TrackAssignment"];
        
        NSArray *allAssignments = [moc executeFetchRequest:allResults error:&fetchError];
        if (fetchError)
        {
            RZError(@"Error fetching messages to delete: %@", fetchError);
        }
        NSArray* oldAssignments = [allAssignments filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
            TrackAssignment* alert = (TrackAssignment *)evaluatedObject;
            return [alert.departureTime isOlderThenNow];
        }]];
        
        for (TrackAssignment *removed in oldAssignments)
        {
            [moc deleteObject:removed];
        }
        
        NSError *saveError = nil;
        if (![moc save:&saveError])
        {
            RZError(@"Error saving Track Assignment import: %@", saveError);
        }
    });
    
}

- (NSArray*)importTrackAssignments:(NSArray*)assignments intoManagedObjectContext:(NSManagedObjectContext *)moc withTime:(NSDate *)time
{
    NSMutableArray *importedAssignments = [NSMutableArray arrayWithCapacity:[assignments count]];
    
    for (NSDictionary *assignment in assignments)
    {
        TrackAssignment *importAssignment= [self importTrackAssignment:assignment intoManagedObjectContext:moc withTime:time];
        
        if (importAssignment)
        {
            [importedAssignments addObject:importAssignment];
        }
    }
    
    return importedAssignments;
}

- (TrackAssignment*)importTrackAssignment:(NSDictionary*)assignment intoManagedObjectContext:(NSManagedObjectContext *)moc withTime:(NSDate *)time
{
    TrackAssignment *importedAssignment = nil;
    NSString* train = [assignment validObjectForKey:kDepartureInfoTrain];
    
    
    NSString* departureTime = [assignment validObjectForKey:kDepartureInfoTime];
    NSString* predictedDepartureTime = [assignment validObjectForKey:kDepartureInfoPredTime];
    NSString* track = [assignment validObjectForKey:kDepartureInfoTrack];
    NSString* carrier = [assignment validObjectForKey:kDepartureInfoCarrier];
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"TrackAssignment"];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"(train.trainNo == %@ && carrier != %@) || (trainNo != nil && trainNo == %@)", train,@"AMTK",train];
    
    NSError *fetchError = nil;
    NSArray *fetchedAssignments = [moc executeFetchRequest:fetchRequest error:&fetchError];
    if (fetchError)
    {
        RZError(@"Error fetching TrackAssignment with train:%@.  Error: %@", train, fetchError);
    }
    
    if ([fetchedAssignments count] > 0)
    {
        importedAssignment = [fetchedAssignments objectAtIndex:0];
    }
    else
    {
        importedAssignment = [NSEntityDescription insertNewObjectForEntityForName:@"TrackAssignment" inManagedObjectContext:moc];
        Train * currentTrain = nil;
        
        if (train != nil && train.length > 0 && ![carrier isEqualToString:@"AMTK"]) {
            NSFetchRequest *trainFetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Train"];
            trainFetchRequest.predicate = [NSPredicate predicateWithFormat:@"trainNo == %@",train];
            
            NSError *fetchError = nil;
            NSArray *fetchedTrains = [moc executeFetchRequest:trainFetchRequest error:&fetchError];
            if (fetchError) {
                RZError(@"Error fetching Train");
            }
            
            if ([fetchedTrains count] > 0) {
                currentTrain = [fetchedTrains lastObject];
            } else {
                importedAssignment.trainNo = train;
            }
        }
        importedAssignment.train = currentTrain;
    }
    if (importedAssignment.train == nil && train != nil && ![carrier isEqualToString:@"AMTK"]) {
        Train * currentTrain = nil;

        NSFetchRequest *trainFetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Train"];
        trainFetchRequest.predicate = [NSPredicate predicateWithFormat:@"trainNo == %@",train];
        
        NSError *fetchError = nil;
        NSArray *fetchedTrains = [moc executeFetchRequest:trainFetchRequest error:&fetchError];
        if (fetchError) {
            RZError(@"Error fetching Train");
        }
        
        if ([fetchedTrains count] > 0) {
            currentTrain = [fetchedTrains lastObject];
            importedAssignment.train = currentTrain;
        } 
    } else if ( [carrier isEqualToString:@"AMTK"]) {
        importedAssignment.train = nil;
        if (train != nil) {
            importedAssignment.trainNo = train;
        }

    }
    importedAssignment.carrier = [assignment validObjectForKey:kDepartureInfoCarrier];
    importedAssignment.origin = [assignment validObjectForKey:kDepartureInfoOrigin];
    importedAssignment.status = [assignment validObjectForKey:kDepartureInfoStatus];
    importedAssignment.destination = [assignment validObjectForKey:kDepartureInfoDestination];
    importedAssignment.departureTime = [NSDate dateFromDotNetString:departureTime];
    importedAssignment.predictedDepartureTime = [NSDate dateFromDotNetString:predictedDepartureTime];
    importedAssignment.lastUpdate = time;
    importedAssignment.track = [NSNumber numberWithInt:[track intValue]];
    return importedAssignment;
}

- (void)importDocumentList:(NSArray *)docArray {
    if(![docArray isKindOfClass:[NSArray class]]) {
        return;
    }
    dispatch_async(self.importerQueue, ^{
        NSManagedObjectContext *moc = [self safeMOC];
        
        NSArray *validDocs = [self importDocumentList:docArray intoManagedObjectContext:moc];
        
        NSString *title = ((Manual*)[validDocs lastObject]).name;
        
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Manual"];
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"name == %@ && NOT SELF in %@", title, validDocs];
        
        NSError *fetchError = nil;
        NSArray *removedManuals = [moc executeFetchRequest:fetchRequest error:&fetchError];
        if (fetchError)
        {
            RZError(@"Error fetching Documents to delete: %@", fetchError);
        }
        
        for (Manual *removed in removedManuals)
        {
            [moc deleteObject:removed];
        }
        
        NSFetchRequest *allResults = [NSFetchRequest fetchRequestWithEntityName:@"Manual"];
        
        NSArray *allManual= [moc executeFetchRequest:allResults error:&fetchError];
        if (fetchError)
        {
            RZError(@"Error fetching messages to delete: %@", fetchError);
        }
        NSArray* oldManual = [allManual filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
            Manual* manual = (Manual *)evaluatedObject;
            return ([manual.lastSeen isOlderThan24Hours]);
        }]];
        
        for (Manual *removed in oldManual)
        {
            [moc deleteObject:removed];
            [[RZFileManager defaultManager] deleteFileFromCacheWithRemoteURL:[NSURL URLWithString:removed.url]];
            RZLog(@"Deleting Manual: %@ - url:%@",removed, removed.url);
        }
        
        NSError *saveError = nil;
        if (![moc save:&saveError])
        {
            RZError(@"Error saving Documents import: %@", saveError);
        }
    });
    
}

- (NSArray*)importDocumentList:(NSArray*)documents intoManagedObjectContext:(NSManagedObjectContext *)moc
{
    NSMutableArray *importedDocs = [NSMutableArray arrayWithCapacity:[documents count]];
    
    for (NSDictionary *doc in documents)
    {
        Manual *importDoc= [self importDocument:doc intoManagedObjectContext:moc];
        
        if (importDoc)
        {
            [importedDocs addObject:importDoc];
        }
    }
    
    return importedDocs;
}

- (Manual*)importDocument:(NSDictionary*)doc intoManagedObjectContext:(NSManagedObjectContext *)moc
{
    Manual *importedManual = nil;
    
    NSString* modifyDate = [doc validObjectForKey:kDocumentModifyDate];
    NSString* url = [doc validObjectForKey:kDocumentURL];
    
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Manual"];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"url == %@", url];
    
    NSError *fetchError = nil;
    NSArray *fetchedManuals = [moc executeFetchRequest:fetchRequest error:&fetchError];
    if (fetchError)
    {
        RZError(@"Error fetching Document with URL:%@.  Error: %@", url, fetchError);
    }
    
    if ([fetchedManuals count] > 0)
    {
        importedManual = [fetchedManuals objectAtIndex:0];
        NSDate* lastUpdate = [NSDate dateFromDotNetString:modifyDate];
        if ([lastUpdate compare:importedManual.downloadDate] == NSOrderedDescending && [[[RZFileManager defaultManager] requestsWithDownloadURL:[NSURL URLWithString:url]] count] == 0) {
            [[RZFileManager defaultManager] deleteFileFromCacheWithURL:[NSURL URLWithString:url]];
            [[RZFileManager defaultManager] downloadFileFromURL:[NSURL URLWithString:url] withProgressDelegate:nil enqueue:YES completion:^(BOOL success, NSURL *downloadedFile, RZWebServiceRequest *request) {
                Manual* man = [self getManualFromURL:[request url] withMOC:moc];
                man.downloadDate = [NSDate date];
                RZLog(@"Manual Updated from:%@",downloadedFile);
            }]; 
        }
    }
    else
    {
        importedManual = [NSEntityDescription insertNewObjectForEntityForName:@"Manual" inManagedObjectContext:moc];
        importedManual.lastOpened = nil;
        if ([[[RZFileManager defaultManager] requestsWithDownloadURL:[NSURL URLWithString:url]] count] == 0) {
            [[RZFileManager defaultManager] downloadFileFromURL:[NSURL URLWithString:url] withProgressDelegate:nil enqueue:YES completion:^(BOOL success, NSURL *downloadedFile, RZWebServiceRequest *request) {
                Manual* man = [self getManualFromURL:[request url] withMOC:moc];
                man.downloadDate = [NSDate date];
                RZLog(@"Manual Downloaded from:%@",downloadedFile);
            }];
        }
        
    }
    importedManual.lastSeen = [NSDate date];
    importedManual.modifyDate = [NSDate dateFromDotNetString:[doc validObjectForKey:kDocumentModifyDate]];
    importedManual.name = [doc validObjectForKey:kDocumentTitle];
    importedManual.type = [doc validObjectForKey:kDocumentType];
    importedManual.fileExtension = [doc validObjectForKey:kDocumentExtension];
    importedManual.url = url;
       
    return importedManual;
}


#pragma mark - BulletinList
- (void)importBulletinList:(NSArray *)docArray {
    if(![docArray isKindOfClass:[NSArray class]]) {
        return;
    }
    dispatch_async(self.importerQueue, ^{
        NSManagedObjectContext *moc = [self safeMOC];
        
        NSArray *validDocs = [self importBulletins:docArray intoManagedObjectContext:moc];
        
        NSString *url = ((Bulletin*)[validDocs lastObject]).url;
        
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Bulletin"];
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"url == %@ && NOT SELF in %@", url, validDocs];
        
        NSError *fetchError = nil;
        NSArray *removedBulletins = [moc executeFetchRequest:fetchRequest error:&fetchError];
        if (fetchError)
        {
            RZError(@"Error fetching Bulletin to delete: %@", fetchError);
        }
        
        for (Bulletin *removed in removedBulletins)
        {
            [moc deleteObject:removed];
        }
        
        NSFetchRequest *allResults = [NSFetchRequest fetchRequestWithEntityName:@"Bulletin"];
        
        NSArray *allBulletins = [moc executeFetchRequest:allResults error:&fetchError];
        if (fetchError)
        {
            RZError(@"Error fetching messages to delete: %@", fetchError);
        }
        NSArray* oldBulletins = [allBulletins filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
            Bulletin* bulletin = (Bulletin *)evaluatedObject;
            return ((bulletin.expireDate != nil && [bulletin.expireDate isOlderThenNow]) || (bulletin.expireDate == nil && [bulletin.modifyDate isOlderThan24Hours]) || [bulletin.lastSeen isOlderThan24Hours]);
        }]];
        
        for (Bulletin *removed in oldBulletins)
        {
            [moc deleteObject:removed];
        }
        
        NSError *saveError = nil;
        if (![moc save:&saveError])
        {
            RZError(@"Error saving Bulletin import: %@", saveError);
        }
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            MBCRAppDelegate* appDel = (MBCRAppDelegate *)[[UIApplication sharedApplication] delegate];
           [appDel updateReferenceTabBarImage];
        });
    });
    
    
}

- (NSArray*)importBulletins:(NSArray*)documents intoManagedObjectContext:(NSManagedObjectContext *)moc
{
    NSMutableArray *importedDocs = [NSMutableArray arrayWithCapacity:[documents count]];
    
    for (NSDictionary *doc in documents)
    {
        Bulletin *importDoc= [self importBulletin:doc intoManagedObjectContext:moc];
        
        if (importDoc)
        {
            [importedDocs addObject:importDoc];
        }
    }
    
    return importedDocs;
}

- (Bulletin*)importBulletin:(NSDictionary*)doc intoManagedObjectContext:(NSManagedObjectContext *)moc
{
    Bulletin *importedBulletin = nil;
    
    NSString* lastUpdated = [doc validObjectForKey:kBulletinModifyDate];
    NSString* url = [doc validObjectForKey:kBulletinWebURL];
    
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Bulletin"];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"url == %@", url];
    
    NSError *fetchError = nil;
    NSArray *fetchedAlerts = [moc executeFetchRequest:fetchRequest error:&fetchError];
    if (fetchError)
    {
        RZError(@"Error fetching Bulletin with URL:%@.  Error: %@", url, fetchError);
    }
    
    if ([fetchedAlerts count] > 0)
    {
        importedBulletin = [fetchedAlerts objectAtIndex:0];
        NSDate* lastUpdate = [NSDate dateFromDotNetString:lastUpdated];
        if (([lastUpdate compare:importedBulletin.downloadDate] == NSOrderedDescending || importedBulletin.downloadDate == nil) && [[[RZFileManager defaultManager] requestsWithDownloadURL:[NSURL URLWithString:url]] count] == 0)
        {
            [[RZFileManager defaultManager] deleteFileFromCacheWithURL:[NSURL URLWithString:url]];
            [[RZFileManager defaultManager] downloadFileFromURL:[NSURL URLWithString:url] withProgressDelegate:nil enqueue:YES completion:^(BOOL success, NSURL *downloadedFile, RZWebServiceRequest *request) {
                Bulletin* bulletin = [self getBulletinFromURL:[request url] withMOC:moc];
                bulletin.downloadDate = [NSDate date];
                RZLog(@"Bulletin Updated from:%@",downloadedFile);
            }]; 
        }

    }
    else
    {
        importedBulletin = [NSEntityDescription insertNewObjectForEntityForName:@"Bulletin" inManagedObjectContext:moc];
        importedBulletin.lastOpened = nil;
        importedBulletin.downloadDate = nil;
        if ([[[RZFileManager defaultManager] requestsWithDownloadURL:[NSURL URLWithString:url]] count] == 0) {
            [[RZFileManager defaultManager] downloadFileFromURL:[NSURL URLWithString:url] withProgressDelegate:nil enqueue:YES completion:^(BOOL success, NSURL *downloadedFile, RZWebServiceRequest *request) {
                Bulletin* bulletin = [self getBulletinFromURL:[request url] withMOC:moc];
                bulletin.downloadDate = [NSDate date];
                RZLog(@"Bulletin Downloaded from:%@",downloadedFile);
            }];
        }
    }
    
    importedBulletin.lastSeen = [NSDate date];
    importedBulletin.modifyDate = [NSDate dateFromDotNetString:[doc validObjectForKey:kBulletinModifyDate]];
    importedBulletin.startDate = [NSDate dateFromDotNetString:[doc validObjectForKey:kBulletinStartDate]];
    importedBulletin.expireDate = [NSDate dateFromDotNetString:[doc validObjectForKey:kBulletinExpireDate]];
    importedBulletin.name = [doc validObjectForKey:kBulletinName];
    importedBulletin.url = url;
    
    return importedBulletin;
}


- (void)importAVLInformation:(NSArray*)info withTime:(NSDate *)time {
    dispatch_async(self.importerQueue, ^{
        NSManagedObjectContext *moc = [self safeMOC];
        
        NSArray *validAVL = [self importAVLInformation:info intoManagedObjectContext:moc withTime:time];
                
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"AVL"];
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"train.trainNo == %@ && NOT SELF in %@", ((AVL*)[validAVL lastObject]).train.trainNo, validAVL];
        
        NSError *fetchError = nil;
        NSArray *removedAVL = [moc executeFetchRequest:fetchRequest error:&fetchError];
        if (fetchError)
        {
            RZError(@"Error fetching AVL to delete: %@", fetchError);
        }
        
        for (AVL *removed in removedAVL)
        {
            [moc deleteObject:removed];
        }
        NSDate* newTime = [time dateByAddingTimeInterval:-kSecondsIn5Minutes];
        NSDate* farTime = [time dateByAddingTimeInterval:-kSecondsIn15Minutes];
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"(train == nil || serverTime ==nil || serverTime < %@ || timestamp < %@)",newTime, farTime];
        NSArray* oldAVL = [moc executeFetchRequest:fetchRequest error:&fetchError];
        if (fetchError) {
            RZError(@"Error fetching AVL to delete: %@", fetchError);
        }
        for (AVL* avl in oldAVL)
        {
            RZLog(@"Deleting avl with Train: %@", avl.train.trainNo);
            [moc deleteObject:avl];
        }
        NSError *saveError = nil;
        if (![moc save:&saveError])
        {
            RZError(@"Error saving AVL import: %@", saveError);
        }
    });
}

- (NSArray*)importAVLInformation:(NSArray*)infoArray intoManagedObjectContext:(NSManagedObjectContext *)moc withTime:(NSDate *)time {
    NSMutableArray *importeAVL = [NSMutableArray arrayWithCapacity:[infoArray count]];
    
    for (NSDictionary *info in infoArray)
    {
        AVL *importAVL= [self importAVL:info intoManagedObjectContext:moc withTime:time];
        
        if (importAVL)
        {
            [importeAVL addObject:importAVL];
        }
    }
    
    return importeAVL;
}

- (AVL*)importAVL:(NSDictionary*)info intoManagedObjectContext:(NSManagedObjectContext *)moc withTime:(NSDate *)serverTime {
    
    AVL *importedAVL = nil;
    NSDate* timeStamp = [NSDate dateFromDotNetString:[info validObjectForKey:kAVLTimeStamp]];
    NSDate* scheduled = [NSDate dateFromDotNetString:[info validObjectForKey:kAVLScheduled]];
    NSString* vehicle = [[info validObjectForKey:kAVLVechicle] description];

    NSString* train = [info validObjectForKey:kAVLTrain];
   
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"AVL"];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"train.trainNo == %@", train];
    
    NSError *fetchError = nil;
    NSArray *fetchedAVL = [moc executeFetchRequest:fetchRequest error:&fetchError];
    if (fetchError)
    {
        RZError(@"Error fetching AVL with vehicle:%@.  Error: %@", vehicle, fetchError);
    }
  
    if ([fetchedAVL count] > 0)
    {
        importedAVL = [fetchedAVL objectAtIndex:0];
    }
    else
    {
        importedAVL = [NSEntityDescription insertNewObjectForEntityForName:@"AVL" inManagedObjectContext:moc];
        Train* currentTrain = nil;
        if (train != nil && train.length > 0) {
            NSFetchRequest *trainFetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Train"];
            trainFetchRequest.predicate = [NSPredicate predicateWithFormat:@"trainNo == %@",train];
            
            NSError *fetchError = nil;
            NSArray *fetchedTrains = [moc executeFetchRequest:trainFetchRequest error:&fetchError];
            if (fetchError) {
                RZError(@"Error fetching Train");
            }
            
            if ([fetchedTrains count] > 0) {
                currentTrain = [fetchedTrains lastObject];
            } else {
                RZLog(@"Creating Train?  TrainNo: %@",train);
                currentTrain = [NSEntityDescription insertNewObjectForEntityForName:@"Train" inManagedObjectContext:moc];
                currentTrain.trainNo = train;
            }
        }
        importedAVL.train = currentTrain;
    }
    
    importedAVL.vehicle = vehicle;
    importedAVL.serverTime = serverTime;
    importedAVL.timestamp = timeStamp;
    importedAVL.trip = [NSNumber numberWithInt:[[info validObjectForKey:kAVLTrain] integerValue]];
    importedAVL.destination =  [info validObjectForKey:kAVLDestination];
    importedAVL.stop = [info validObjectForKey:kAVLStop];
    importedAVL.scheduled = scheduled;
    importedAVL.flag = [info validObjectForKey:kAVLFlag];
    importedAVL.latitude = [NSNumber numberWithFloat:[[info validObjectForKey:kAVLLatitude] floatValue]];
    importedAVL.longitude = [NSNumber numberWithFloat:[[info validObjectForKey:kAVLLongitude] floatValue]];
    importedAVL.heading = [NSNumber numberWithInt:[[info validObjectForKey:kAVLHeading] integerValue]];
    importedAVL.speed = [NSNumber numberWithInt:[[info validObjectForKey:kAVLSpeed] integerValue]];
    importedAVL.lateness = [[info validObjectForKey:kAVLLateness] description];
    
    return importedAVL;

}
- (void)importTrains:(NSArray *)trains withTime:(NSDate *)time {
    if(![trains isKindOfClass:[NSArray class]]) {
        return;
    }
    dispatch_async(self.importerQueue, ^{
        NSManagedObjectContext *moc = [self safeMOC];
        
        NSArray *validTrains = [self importTrains:trains intoManagedObjectContext:moc withTime:time];
        
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Train"];
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"trainNo == %@ && NOT SELF in %@", ((Train*)[validTrains lastObject]).trainNo, validTrains];
        
        NSError *fetchError = nil;
        NSArray *removedEntries = [moc executeFetchRequest:fetchRequest error:&fetchError];
        if (fetchError)
        {
            RZError(@"Error fetching Train to delete: %@", fetchError);
        }
        
        for (Train *removed in removedEntries)
        {
            [moc deleteObject:removed];
        }
        
        //Remove Stale Trains
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"(lastUpdate < %@)",[NSDate yesterdaysDate]];
        NSArray* staleTrains = [moc executeFetchRequest:fetchRequest error:&fetchError];
        if (fetchError) {
            RZError(@"Error fetching AVL to delete: %@", fetchError);
        }
        for (Train* train in staleTrains)
        {
            [moc deleteObject:train];
        }
        
        NSError *saveError = nil;
        if (![moc save:&saveError])
        {
            RZError(@"Error saving Train import: %@", saveError);
        }
    });
}

- (NSArray*)importTrains:(NSArray*)infoArray intoManagedObjectContext:(NSManagedObjectContext *)moc withTime:(NSDate *)time {
    NSMutableArray *importedTrains = [NSMutableArray arrayWithCapacity:[infoArray count]];
    
    for (NSDictionary *info in infoArray)
    {
        Train *importTrain= [self importTrain:info intoManagedObjectContext:moc withTime:time];
        
        if (importTrain)
        {
            [importedTrains addObject:importTrain];
        }
    }
    
    return importedTrains;
}

- (Train *)importTrain:(NSDictionary*)info intoManagedObjectContext:(NSManagedObjectContext *)moc withTime:(NSDate *)timestamp{
    
    Train *importedTrain = nil;
    NSString* trainNo = [[info validObjectForKey:kTrainTrain] stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Train"];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"trainNo == %@", trainNo];
    
    NSError *fetchError = nil;
    NSArray *fetchedTrains = [moc executeFetchRequest:fetchRequest error:&fetchError];
    
    if (fetchError)
    {
        RZError(@"Error fetching Train with trainId:%@.  Error: %@", trainNo, fetchError);
    }
    
    if ([fetchedTrains count] > 0)
    {
        importedTrain = [fetchedTrains objectAtIndex:0];
    }
    else
    {
        importedTrain = [NSEntityDescription insertNewObjectForEntityForName:@"Train" inManagedObjectContext:moc];
        importedTrain.trainNo = trainNo;
        NSNumber* lineId = [NSNumber numberWithInt:[[info validObjectForKey:kTrainLineID] intValue]];
        Line* currentLine = nil;
        if (lineId != nil) {
            NSFetchRequest *lineFetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Line"];
            lineFetchRequest.predicate = [NSPredicate predicateWithFormat:@"lineId == %@",lineId];
            
            NSError *fetchError = nil;
            NSArray *fetchedResults = [moc executeFetchRequest:lineFetchRequest error:&fetchError];
            if (fetchError) {
                RZError(@"Error fetching Line");
            }
            
            if ([fetchedResults count] > 0) {
                currentLine = [fetchedResults lastObject];
            } else {
                currentLine = [NSEntityDescription insertNewObjectForEntityForName:@"Line" inManagedObjectContext:moc];
                currentLine.lineId = lineId;
            }
        }
        importedTrain.line = currentLine;
    }
    importedTrain.lastUpdate = timestamp;
    importedTrain.trainId = [NSNumber numberWithInt:[[info validObjectForKey:kTrainID] intValue]];

    return importedTrain;
    
}

@end
