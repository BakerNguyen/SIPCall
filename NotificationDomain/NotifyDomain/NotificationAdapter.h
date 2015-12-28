//
//  NotificationDelegate.h
//  NotificationDomain
//
//  Created by Arpana Sakpal on 1/26/15.
//  Copyright (c) 2015 Arpana Sakpal. All rights reserved.
//

@protocol NotificationDomainDelegate <NSObject>
@optional
- (void) internetDisconnected;
- (void) internetConnected;
@end

@interface NotificationAdapter : NSObject

typedef void (^requestCompleteBlock)(BOOL success, NSString *message ,NSDictionary *response, NSError *error);
#define kAPI @"API"
#define kAPI_VERSION @"API_VERSION"

@property (nonatomic, strong) id<NotificationDomainDelegate> delegate;

+(NotificationAdapter*)share;

/*
 *config Application using notification.
 *@Author:TrungVN
 */
- (void) configNotification;

/*
 *process NSData* token get from device return NSString*
 *@Author:TrungVN
 */
- (NSString*) processToken:(NSData*) token;

/*
 *Call API to register PN
 *@Author: TrungVN
 */
-(void) registerPNToServer:(NSDictionary*)parametersDic callback:(requestCompleteBlock)callback;


/*
 * Cover cover LED flash of push notification.
 * Author: Jurian
 */
- (void)toggleFlashlight;

/**
 *  Register NSNotificationCenter with name: kReachabilityChangedNotification when internet connection change
 *  Author: Violet
 */
- (void) setupReachability;

/**
 *  Check current network status
 *  @return Boolean value
 *  Author:: Violet
 */
- (BOOL) checkInternetConnected;

/**
 *  Remove Push notification badge
 *  Author: Violet
 */
-(void) removeAppBadge;

/**
 *  Play local notification sound with fileName
 *  @param fileName: name of sound file
 *  Author: Violet
 */
-(void) playSoundWithFilePath:(NSString *) filePath;

@end
