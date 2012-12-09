//
//  MBCRAppDelegate.m
//  MBCR
//
//  Created by Alex Rouse on 6/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MBCRAppDelegate.h"
#import "AppBlade.h"
#import "NSDate+Formatter.h"
#import "UIColor+MBCRColors.h"
#import "UAirship.h"
#import "RZHud.h"
#import "MBCRPDFViewController.h"
#import "RZFileManager.h"
#import "UAPush.h"

#define kReferenceVCIndex   3
#define kAlertsVCIndex      0
#define kNumberOfCompletedRequestsToHideHud     3
#define kUAAllTag   @"All"

@interface MBCRAppDelegate ()
@property (nonatomic, strong) RZHud* hud;
@end


@implementation MBCRAppDelegate
@synthesize tabBarController = _tabBarController;
@synthesize window = _window;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;
@synthesize displayingHud = _displayingHud;
@synthesize numberOfCompletedRequests = _numberOfCompletedRequests;

@synthesize hud = _hud;
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
#ifdef PRODUCTION_KEYS
    [[LocalyticsSession sharedLocalyticsSession] startSession:kLocalyticsProdKey];
#else
    [[LocalyticsSession sharedLocalyticsSession] startSession:kLocalyticsDebugKey];
#endif
    
    [self registerForPushWithLaunchOptions:launchOptions];
    
//    if ([self isFirstLaunchOfTheDay]) {
//        [self firstDailyLaunchOfApplication];
//    }
    
    [self.window addSubview:[self.tabBarController view]];
    [self.window makeKeyAndVisible];
    
    
    //Global UIAppearnace Styles.
    
    UIFont *titleFont = [UIFont fontWithName:@"HelveticaNeue-Bold" size:20.0];
//    [[UINavigationBar appearance] setTintColor:[UIColor colorWithRed:0.0/255.0 green:51.0/255.0 blue:142.0/255.0 alpha:1.0]];
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"navbar"] forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], UITextAttributeTextColor, [UIColor blackColor], UITextAttributeTextShadowColor, titleFont, UITextAttributeFont, nil]];
    
//    [[UIBarButtonItem appearance] setTintColor:[UIColor colorWithRed:0.0/255.0 green:51.0/255.0 blue:142.0/255.0 alpha:1.0]];
    
    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil]  setBackgroundImage:[[UIImage imageNamed:@"navbar_button_up"] resizableImageWithCapInsets:UIEdgeInsetsMake(15, 11, 15, 11)] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil]  setBackgroundImage:[[UIImage imageNamed:@"navbar_button_down"] resizableImageWithCapInsets:UIEdgeInsetsMake(15, 11, 15, 11)] forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
    
    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:[[UIImage imageNamed:@"navbar_back_button_up"] resizableImageWithCapInsets:UIEdgeInsetsMake(15, 13, 15, 11)] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:[[UIImage imageNamed:@"navbar_back_button_down"] resizableImageWithCapInsets:UIEdgeInsetsMake(15, 13, 15, 11)] forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];

    [[UISearchBar appearance] setBackgroundImage:[UIImage imageNamed:@"navbar"]];

    
    
    [self configureTabBar];
    [self updateReferenceTabBarImage]; 
    
    
    AppBlade* blade = [AppBlade sharedManager];
    blade.appBladeProjectID = kAppBladeProjectId;
    blade.appBladeProjectToken = kAppBladeProjectToken;
    blade.appBladeProjectSecret = kAppBladeProjectSecret;
    blade.appBladeProjectIssuedTimestamp = kAppBladeProjectIssuedTimestamp;
    
    [blade catchAndReportCrashes];
    
//#ifdef RZ_DEBUG
//    [blade allowFeedbackReporting];
//#endif
    
    [[UIApplication sharedApplication]
     registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                         UIRemoteNotificationTypeSound |
                                         UIRemoteNotificationTypeAlert)];
    
    
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [[LocalyticsSession sharedLocalyticsSession] close];
    [[LocalyticsSession sharedLocalyticsSession] upload];
    
    UIApplication  *app = [UIApplication sharedApplication];
    UIBackgroundTaskIdentifier bgTask;
    
    bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
        [[RZFileManager defaultManager] cancelAlDownloads];
    }];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [[LocalyticsSession sharedLocalyticsSession] resume];
    [[LocalyticsSession sharedLocalyticsSession] upload];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [application setApplicationIconBadgeNumber:0];
    if ([self isFirstLaunchOfTheDay]) {
        [self firstDailyLaunchOfApplication];
    }

    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [[LocalyticsSession sharedLocalyticsSession] close];
    [[LocalyticsSession sharedLocalyticsSession] upload];
    
    [UAirship land];
}

#pragma mark - Push

- (void)registerForPushWithLaunchOptions:(NSDictionary  *)launchOptions {
    NSMutableDictionary *takeOffOptions = [[NSMutableDictionary alloc] init];
    [takeOffOptions setValue:launchOptions forKey:UAirshipTakeOffOptionsLaunchOptionsKey];
    
    NSMutableDictionary *airshipConfigOptions = [[NSMutableDictionary alloc] init];
    
    [airshipConfigOptions setValue:kAirshipDevKey forKey:@"DEVELOPMENT_APP_KEY"];
    [airshipConfigOptions setValue:kAirshipDevSecret forKey:@"DEVELOPMENT_APP_SECRET"];
    [airshipConfigOptions setValue:kAirshipProdKey forKey:@"PRODUCTION_APP_KEY"];
    [airshipConfigOptions setValue:kAirshipProdSecret forKey:@"PRODUCTION_APP_SECRET"];
        
    
//#ifdef PRODUCTION_KEYS
    [airshipConfigOptions setValue:@"YES" forKey:@"APP_STORE_OR_AD_HOC_BUILD"];
//#else
//    [airshipConfigOptions setValue:@"NO" forKey:@"APP_STORE_OR_AD_HOC_BUILD"];
//#endif
    [takeOffOptions setValue:airshipConfigOptions forKey:UAirshipTakeOffOptionsAirshipConfigKey];
    
    [UAirship takeOff:takeOffOptions];
    [[UAPush shared] setTags:[NSMutableArray arrayWithObjects:kUAAllTag,@"North",@"South", nil]];
    [[UAPush shared] updateRegistration];
    

}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [[UAirship shared] registerDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [application setApplicationIconBadgeNumber:0];
    NSString* mbcrAlert = [userInfo objectForKey:@"mbcr_type"];
    //App is in foreground
    if ( application.applicationState == UIApplicationStateActive ){
        if ([mbcrAlert isEqualToString:@"bulletin"]) {
            [[MBCRServiceManager shared] downloadBulletinList];
        } else {
            [[MBCRServiceManager shared] downloadTAlerts];
            [[MBCRServiceManager shared] downloadAllPageAlerts];
        }

    }
    else {
        if ([mbcrAlert isEqualToString:@"bulletin"]) {
            [self.tabBarController setSelectedIndex:3];
        } else {
            [self.tabBarController setSelectedIndex:0];
            [[MBCRServiceManager shared] downloadTAlerts];
            [[MBCRServiceManager shared] downloadAllPageAlerts];
        }
    }
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    NSString* tab = @"";
    switch (tabBarController.selectedIndex) {
        case 0:
            tab = @"Alerts";
            [self updateAlertsTabView];
            [self updateAlertsTabBarImage];
            break;
        case 1:
            tab = @"Location";
            break;
        case 2:
            tab = @"Track";
            break;
        case 3:
            tab = @"Reference";
            break;
        case 4:
            tab = @"More";
            break;
        case 5:
            tab = @"Comments";
            break;
        default:
            break;
    }
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                tab, kLocalAttributeNameOfTab,
                                nil];
    [[LocalyticsSession sharedLocalyticsSession] tagEvent:kLocalActionTabSelected attributes:dictionary];
}

- (void)updateAlertsTabView {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSDate date] forKey:kLastAlertViewDate];
    [defaults synchronize];
}

- (BOOL)isFirstLaunchOfTheDay {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSDate* lDate = (NSDate *)[defaults objectForKey:kLastLaunchDate];
    NSDate* lineDate = (NSDate *)[defaults objectForKey:kLastLineUpdate];
    NSDate* trainDate = (NSDate *)[defaults objectForKey:kLastTrainupdate];
    if(![lDate isDateToday] || ![lineDate isDateToday] || ![trainDate isDateToday]) {
        [defaults setObject:[NSDate date] forKey:kLastLaunchDate];
        [defaults synchronize];
        RZLog(@"Is First Launch");
        return YES;
    }
    RZLog(@"Is Not First Launch");
    return NO;
}

- (void)firstDailyLaunchOfApplication {
    self.displayingHud = YES;
    self.numberOfCompletedRequests = 0;
//    self.hud = [[RZHud alloc] initWithStyle:RZHudStyleBoxLoading];
//    self.hud.labelText = @"Updating Line List...";
//    [self.hud presentInView:self.tabBarController.view withFold:NO];
    
    MBCRServiceManager* sm = [MBCRServiceManager shared];
    [sm downloadLineList];
    [sm downloadTrainInformation];
    [sm downloadTAlerts];
    [sm downloadTrackAssignments];
    [sm downloadAllPageAlerts];
    [sm downloadBulletinList];
    [sm downloadDocumentList];
    [sm downloadOTPData:[NSDate date]];
}

/**
 *  Keeps track of the last time that we have recieved each of the requests.
 *  We really only care about Line and train.
 **/
- (void)updateLastUpdateForKey:(NSString *)key {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSDate date] forKey:key];
    [defaults synchronize];
}

- (void)requestCompleted {
    self.numberOfCompletedRequests ++;
    if (self.displayingHud) {
        switch (self.numberOfCompletedRequests) {
            case 0:
                self.hud.labelText = @"Updating Line List...";
                break;
            case 1:
                self.hud.labelText = @"Updating Train List...";
                break;
            case 2:
                self.hud.labelText = @"Downloading TAlerts...";
                break;
            case 3:
                self.hud.labelText = @"Downloading Track Assignments...";
                break;
            case 4:
                self.hud.labelText = @"Downloading AllPage Alerts...";
                break;
            case 5:
                self.hud.labelText = @"Downloading Document Lists...";
                break;
            default:
                break;
        }
        if(self.numberOfCompletedRequests >= kNumberOfCompletedRequestsToHideHud) {
            [self.hud dismissAnimated:YES];
            self.displayingHud = NO;
            self.hud = nil;
        }
    }
}

- (void)updateReferenceTabBarImage {
    UIViewController* vc = [self.tabBarController.viewControllers objectAtIndex:kReferenceVCIndex];
    NSInteger badgeCount = [[MBCRDataManager shared] numberOfUnreadBulletins];
    if (badgeCount > 0 ) {
        [vc.tabBarItem setBadgeValue:[NSString stringWithFormat:@"%d",badgeCount]];
    } else {
        [vc.tabBarItem setBadgeValue:nil];
    }
}
- (void)updateAlertsTabBarImage {
    UIViewController* vc = [self.tabBarController.viewControllers objectAtIndex:kAlertsVCIndex];
    if ([self.tabBarController selectedIndex] == 0) {
        [vc.tabBarItem setBadgeValue:nil];
        return;
    }
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSDate* lDate = [defaults objectForKey:kLastAlertViewDate];
    if (lDate == nil) {
        lDate = [NSDate date];
        [defaults setObject:lDate forKey:kLastAlertViewDate];
        [defaults synchronize];
    }
    NSInteger badgeCount = [[MBCRDataManager shared] numberUnreadMessagesFromDate:lDate];
    if (badgeCount > 0 ) {
        [vc.tabBarItem setBadgeValue:[NSString stringWithFormat:@"%d",badgeCount]];
    } else {
        [vc.tabBarItem setBadgeValue:nil];
    }
}

- (void)configureTabBar
{
    self.tabBarController.tabBar.selectionIndicatorImage = [[UIImage alloc] init];
    
    for(int i = 0; i < self.tabBarController.viewControllers.count; i++)
    {
        UIViewController *vc = [self.tabBarController.viewControllers objectAtIndex:i];
        switch (i) {
            case 0:{
                [vc.tabBarItem setImage:[UIImage imageNamed:@"tab_alert"]];
            }break;
            case 1:{
                [vc.tabBarItem setImage:[UIImage imageNamed:@"tab_location"]];   
            }break;
            case 2:{
                [vc.tabBarItem setImage:[UIImage imageNamed:@"tab_track"]];
            }break;
            case 3:{
                [vc.tabBarItem setImage:[UIImage imageNamed:@"tab_reference"]];
            }break;
            case 4:{
                [vc.tabBarItem setImage:[UIImage imageNamed:@"tab_comment"]];
            }break;
            case 5:{
                [vc.tabBarItem setImage:[UIImage imageNamed:@"tab_comment"]];
            }break;
            default:{
            }break;
        }
    }
}

- (UIBarButtonItem *)createLeftBarImage {
    UIView* v = [[UIView alloc] initWithFrame:CGRectMake(0, 8, 76, 36)];
    UIImageView* iv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"navbar_mbcr_logo"]];
    CGRect frame = iv.frame;
    frame.origin.y = 3;
    iv.frame = frame;
    [v addSubview:iv];
    return [[UIBarButtonItem alloc] initWithCustomView:v];
}

- (MBCRPickerView *)createPickerView {
    MBCRPickerView *pickerView = (MBCRPickerView *)[MBCRPickerView view];
    pickerView.frame = CGRectMake(0, 0, pickerView.frame.size.width, pickerView.frame.size.height);
    [self.window addSubview:pickerView];
    return pickerView;
}





@end
