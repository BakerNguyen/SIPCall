//
//  AppDelegate.m
//  Satay
//
//  Created by enclave on 1/6/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//  Daniel_dev branch

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

@synthesize isStartup;
@synthesize isResignActive;
NSDate *startTime;
UILocalNotification *localPushNotificationSIP;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    application.applicationSupportsShakeToEdit = NO;
    
    startTime = [NSDate date];
    self.window = [CWindow share];
    [[AppFacade share] checkFirstRun];
    [[AppFacade share] connectDB];
    [[LogFacade share] loadTracker];
    [[XMPPFacade share] configXMPP];
    
    [[NotificationFacade share] removeAppBadge];
    [[NotificationFacade share] configNotification];
    [[NotificationFacade share] setupReachability];
    
    isStartup = YES;
    [CWindow share].firstLaunch = YES;
    [[ContactFacade share] checkAccountStatus];
    
    //Parker add this local log to check DB
    NSArray *docPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [docPaths objectAtIndex:0];
    NSLog(@"Database Local: %@", documentsDir);
    
    if (launchOptions) {
        NSDictionary * pnMess = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
        NSLog(@"Push Notification Message: %@", pnMess);
    }
    
    //Baker - Detect call incoming [Phone book]
//    [SIPFacade share].phoneCallCenter = [[CTCallCenter alloc] init];
//    [[SIPFacade share] handlePhoneBookCall];
    [[LogFacade share] sendCrashReportViaEmail];
    
    [[ChatFacade share] updateAllUploadingMessage];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    [[NotificationFacade share] removeAppBadge];

    [[AppFacade share] addBlankViewForSnapShotPrevention:self.window];
    UIApplication *app = [UIApplication sharedApplication];
    //create new uiBackgroundTask
    __block UIBackgroundTaskIdentifier bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
        [app endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }];
    
    //and create new timer with async call:
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSTimer* t = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(disconnectXMPP) userInfo:nil repeats:NO];
        [[NSRunLoop currentRunLoop] addTimer:t forMode:NSDefaultRunLoopMode];
        [[NSRunLoop currentRunLoop] run];
    });
    
    //UnRegister SIP
    [[SIPFacade share] unregistration];
}

- (void)disconnectXMPP
{
    if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive) {
        isResignActive = TRUE;
        [[XMPPFacade share] disconnectXMPP];
    }
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [[ChatFacade share] stopCurrentAudioPlaying:nil];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    NSString* forceUpdateVersion = [KeyChainSecurity getStringFromKey:kFORCE_VERSION_IOS];
    if (forceUpdateVersion){
        if ([[AppFacade share] compareVersion:[APP_VERSION substringFromIndex:1] withVersion:forceUpdateVersion] == -1){
            CAlertView *alertView = [CAlertView new];
            [alertView showInfo: INFO_FORCE_UPDATE];
            [alertView setOnButtonTouchUpInside:^(CAlertView *alertView, int buttonIndex) {
                if (buttonIndex == 0) {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:APP_URL_IN_APP_STORE]];
                }
            }];
        }
    }
    
    if(startTime){
        NSDictionary *logDic = @{
                                 LOG_CLASS : NSStringFromClass(self.class),
                                 LOG_CATEGORY: CATEGORY_TIME_TO_LAUNCH,
                                 LOG_MESSAGE: [NSString stringWithFormat:@"Time: %.3fs",[[NSDate date] timeIntervalSinceDate:startTime]],
                                 LOG_EXTRA1: @"",
                                 LOG_EXTRA2: @""
                                 };
        [[LogFacade share] logInfoWithDic:logDic];
        startTime = nil;
    }
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [[AppFacade share] removeBlankViewForSnapShotPrevention:self.window];
        [[SIPFacade share] registerSIPAccount];
    }];

    [[NSOperationQueue new] addOperationWithBlock:^(void){
        [[LogFacade share] trackingScreen:APP_Category];
        [[NotificationFacade share] removeAppBadge];
        [[AppFacade share] removeCacheDataInsideApp];
    }];

    if (isStartup) {
        isStartup = NO;
        return;
    }
    
    if (isResignActive) {
        [[ContactFacade share] checkAccountStatus];
    }
    
    isResignActive = FALSE;
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [[NotificationFacade share] removeAppBadge];
}

#pragma mark - NotificationDomain Delegate-

- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)devToken
{
    [[NSOperationQueue new] addOperationWithBlock:^{
        [[NotificationFacade share] registerWithServer:devToken];
    }];
    
    NSDictionary *logDic = @{LOG_CLASS : NSStringFromClass(self.class),
                             LOG_CATEGORY: CATEGORY_APN_TOKEN_REGISTERD,
                             LOG_MESSAGE: @"REGISTER SUCCESS",
                             LOG_EXTRA1: @"",
                             LOG_EXTRA2: @""};
    [[LogFacade share] logInfoWithDic:logDic];
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err
{
    NSDictionary *logDic = @{LOG_CLASS : NSStringFromClass(self.class),
                             LOG_CATEGORY: CATEGORY_APN_TOKEN_REGISTERD,
                             LOG_MESSAGE: [NSString stringWithFormat:@"REGISTER FAIL ERROR: %@",err],
                             LOG_EXTRA1: @"",
                             LOG_EXTRA2: @""};
    [[LogFacade share] logInfoWithDic:logDic];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
     if ([[userInfo[@"MESSAGE_TYPE"] uppercaseString] isEqualToString:@"SC"]) {
        NSString *SIP_PN_MESSAGE_ID = userInfo[@"MESSAGE_ID"];
        if ([SIP_PN_MESSAGE_ID isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"SIP_PN_MESSAGE_ID"]]) {
            return;
        }
        [[NSUserDefaults standardUserDefaults] setObject:userInfo[@"MESSAGE_ID"] forKey:@"SIP_PN_MESSAGE_ID"] ;
        
        if ([[userInfo[@"CALL_STATUS"] uppercaseString] isEqualToString:@"CALL"]) {
            //Incoming call
            localPushNotificationSIP = [UILocalNotification new];
            localPushNotificationSIP.fireDate = [NSDate dateWithTimeIntervalSinceNow:4];
            localPushNotificationSIP.timeZone = [NSTimeZone defaultTimeZone];
            localPushNotificationSIP.alertBody = [userInfo[@"aps"] objectForKey:@"alert"];
            localPushNotificationSIP.soundName = @"ring_local.wav";
            // Perform the notification.
            [[UIApplication sharedApplication] scheduleLocalNotification:localPushNotificationSIP];
            
            //and create new timer with async call:        
            UIBackgroundTaskIdentifier bgTask;
            bgTask = UIBackgroundTaskInvalid;
            UIApplication *app = [UIApplication sharedApplication];
            bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
                [app endBackgroundTask:bgTask];
            }];
            NSTimer* playingCycleTimer = [NSTimer scheduledTimerWithTimeInterval:35.0f
                                                                          target:self
                                                                        selector:@selector(cancelSIPLocalNotifications)
                                                                        userInfo:nil
                                                                         repeats:NO];
            [[NSRunLoop mainRunLoop] addTimer:playingCycleTimer
                                      forMode:NSDefaultRunLoopMode];
            
            
            //Init imcomming call
            [[SIPFacade share] initIncomingCallView:userInfo[@"TRANSACTION_ID"]
                                                JID:[NSString stringWithFormat:@"%@@%@", userInfo[@"FROM_CALLER_JID"], [[ContactFacade share] getXmppHostName]]];
        } else {
            //Missed call
            if (localPushNotificationSIP != nil) {
                [[UIApplication sharedApplication] cancelLocalNotification:localPushNotificationSIP];
            }
            [[SIPFacade share] addCallLogInfo:[NSString stringWithFormat:@"%@@%@", userInfo[@"FROM_CALLER_JID"], [[ContactFacade share] getXmppHostName]]
                                     isCaller:NO
                                       Status:SIPCallStatusMissed message:@""];
            [[SIPFacade share] unregistration];
        }
    }
}

- (void) cancelSIPLocalNotifications {
    if (localPushNotificationSIP != nil) {
        [[UIApplication sharedApplication] cancelLocalNotification:localPushNotificationSIP];
    }
}

@end
