//
//  NotificationDelegate.m
//  NotificationDomain
//
//  Created by Arpana Sakpal on 1/26/15.
//  Copyright (c) 2015 Arpana Sakpal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NotificationAdapter.h"
#import "AFNetworkingHelper.h"
#import "NotificationServerAdapter.h"
#import "CocoaLumberjack.h"
#import <AVFoundation/AVFoundation.h>
#import "Reachability.h"

//Logging
#ifdef DEBUG
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelError;
#endif

@implementation NotificationAdapter{
    Reachability *reachability;
}

@synthesize delegate;

+(NotificationAdapter*)share{
    static dispatch_once_t once;
    static NotificationAdapter * share;
    dispatch_once(&once, ^{
        share = [self new];
        // Configure CocoaLumberjack
        setenv("XcodeColors", "YES", 0);
        [DDLog addLogger:[DDASLLogger_Notification sharedInstance]];
        [DDLog addLogger:[DDTTYLogger_Notification sharedInstance]];
        [[DDTTYLogger_Notification sharedInstance] setColorsEnabled:YES];
        [[DDTTYLogger_Notification sharedInstance] setForegroundColor:[UIColor greenColor] backgroundColor:nil forFlag:DDLogFlagInfo];
        [[DDTTYLogger_Notification sharedInstance] setForegroundColor:[UIColor redColor] backgroundColor:nil forFlag:DDLogFlagError];
        [[DDTTYLogger_Notification sharedInstance] setForegroundColor:[UIColor orangeColor] backgroundColor:nil forFlag:DDLogFlagWarning];
        [[DDTTYLogger_Notification sharedInstance] setForegroundColor:[UIColor lightGrayColor] backgroundColor:nil forFlag:DDLogFlagVerbose];
        
        [[NSNotificationCenter defaultCenter] addObserver:share
                                                 selector:@selector(handleNetworkChange:)
                                                     name:kReachabilityChangedNotification object:nil];
    });
    return share;
}

- (void)configNotification
{
    UIApplication* application = [UIApplication sharedApplication];
    
    if ([application respondsToSelector:@selector(isRegisteredForRemoteNotifications)]){
        // iOS 8 Notifications
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [application registerForRemoteNotifications];
    }
    else{
        // iOS < 8 Notifications
        [application registerForRemoteNotificationTypes:
         (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound)];
    }
}

- (NSString*) processToken:(NSData*) token{
    NSString *deviceToken = [[token description] stringByTrimmingCharactersInSet: [NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    deviceToken = [deviceToken stringByReplacingOccurrencesOfString:@" " withString:@""];
    return deviceToken;
}

#define API_REGISTER_PN @"bhNTAxLZf8"
#define API_REGISTER_PN_VERSION @"v1"
-(void) registerPNToServer:(NSDictionary*)parametersDic callback:(requestCompleteBlock)callback{
    if (!parametersDic) {
        DDLogError(@"%s: parametersDic NULL.", __PRETTY_FUNCTION__);
        return;
    }
    void (^registerPNToServerCallBack)(BOOL success, NSString *message ,NSDictionary *response, NSError *error);
    registerPNToServerCallBack = callback;
    
    NSMutableDictionary *parameters = [parametersDic mutableCopy];
    [parameters setObject:API_REGISTER_PN forKey:kAPI];
    [parameters setObject:API_REGISTER_PN_VERSION forKey:kAPI_VERSION];
    
    [[NotificationServerAdapter share] requestService:parameters tenantServer:YES callback:^(BOOL success, NSString *message, NSDictionary *response, NSError *error) {
        if (success) {
            DDLogInfo(@"%s: SUCCESS", __PRETTY_FUNCTION__);
            registerPNToServerCallBack(YES, @"Register PN successfully.", response, nil);
        }else{
            DDLogError(@"%s: FAILED", __PRETTY_FUNCTION__);
            registerPNToServerCallBack(NO, @"Register PN failed.", response, error);
        }
    }];
}

- (void)toggleFlashlight
{
    AVCaptureDevice *backCamera = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if ( [backCamera isTorchAvailable] && [backCamera isTorchModeSupported:AVCaptureTorchModeOn] )
    {
        BOOL success = [backCamera lockForConfiguration:nil];
        if ( success )
        {
            if (backCamera.torchMode == AVCaptureTorchModeOff)
            {
                [backCamera setTorchMode:AVCaptureTorchModeOn];
                [backCamera setFlashMode:AVCaptureFlashModeOn];
                [backCamera unlockForConfiguration];
            }
            else
            {
                [backCamera setTorchMode:AVCaptureTorchModeOff];
                [backCamera setFlashMode:AVCaptureFlashModeOff];
                [backCamera unlockForConfiguration];
            }
        }
    }
}

- (void) setupReachability{
    reachability = [Reachability reachabilityForInternetConnection];
    [reachability startNotifier];
}

- (void)handleNetworkChange:(NSNotification *)notice{
    NetworkStatus status = [reachability currentReachabilityStatus];
    if (status == NotReachable) {
        DDLogError(@"%s: Disconnected", __PRETTY_FUNCTION__);
        [delegate internetDisconnected];
    } else {
        DDLogInfo(@"%s: Connected", __PRETTY_FUNCTION__);
        [delegate internetConnected];
    }
}

- (BOOL) checkInternetConnected{
    return ([reachability currentReachabilityStatus] == NotReachable ? NO : YES);
}

-(void) removeAppBadge{
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 0];
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}

-(void) playSoundWithFilePath:(NSString *) filePath{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^(void){
        SystemSoundID sounds[10];
        CFURLRef soundURL = (__bridge CFURLRef)[NSURL fileURLWithPath:filePath];
        AudioServicesCreateSystemSoundID(soundURL, &sounds[0]);
        AudioServicesPlaySystemSound(sounds[0]);
    }];
}

@end
