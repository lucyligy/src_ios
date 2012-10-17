//
//  MBCRAppDelegate.h
//  MBCR
//
//  Created by Alex Rouse on 6/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBCRServiceManager.h"
#import "MBCRDataManager.h"
#import "MBCRPickerView.h"
#import "LocalyticsSession.h"

@interface MBCRAppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate>

@property (strong, nonatomic) IBOutlet UIWindow* window;
@property (strong, nonatomic) IBOutlet UITabBarController* tabBarController;
//@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (assign, nonatomic) BOOL displayingHud;
@property (assign, nonatomic) NSUInteger numberOfCompletedRequests;
- (void)updateReferenceTabBarImage;
- (void)updateAlertsTabBarImage;
- (void)updateLastUpdateForKey:(NSString *)key;
- (MBCRPickerView *)createPickerView;
- (UIBarButtonItem *)createLeftBarImage;
- (void)requestCompleted;
@end
