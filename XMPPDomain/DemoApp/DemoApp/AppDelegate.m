//
//  AppDelegate.m
//  DemoApp
//
//  Created by Daniel Nguyen on 12/30/14.
//  Copyright (c) 2014 mTouche. All rights reserved.
//

#import "AppDelegate.h"
#import <XMPPDomain/XMPPDomainFields.h>

@interface AppDelegate ()

@end

@implementation AppDelegate

@synthesize xmppAdapter;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    setenv("XcodeColors", "YES", 0);
    
//    NSDictionary *configInfo = [[NSDictionary alloc] initWithObjectsAndKeys:@"mtouches-imac.local", kXMPP_HOST_NAME,
//                                                                            @"conference.mtouches-imac.local", kXMPP_MUC_HOST_NAME,
//                                                                            @"5222", kXMPP_PORT_NUMBER,
//                                                                            @"iOSSatay", kXMPP_RESOURCE,
//                                                                            nil];
    [[XMPPAdapter share] setDelegate:self];
//    [[XMPPAdapter share] reConfigXMPP:configInfo];
    
    NSDictionary *userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:@"daniel", kXMPP_USER_JID,
                                                                          @"daniel123", kXMPP_USER_PASSWORD,
                                                                          nil];
    
    if (![[XMPPAdapter share] connectWithInfo:userInfo]) {
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.0 * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^{
            NSLog(@"Connecting...");
        });
    }
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    NSLog(@"%s %@", __PRETTY_FUNCTION__, notification);
}

#pragma mark - XMPPDomain Delegate -
- (void)xmppDomainDidConnect:(XMPPAdapter *)sender
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)xmppDomainDidDisconnect:(XMPPAdapter *)sender withError:(NSError *)error
{
    NSLog(@"%s %@", __PRETTY_FUNCTION__, error);
    if ([error code] == 1404) {
//        NSDictionary *configInfo = [[NSDictionary alloc] initWithObjectsAndKeys:@"mtouches-imac.local", kXMPP_HOST_NAME,
//                                    @"conference.mtouches-imac.local", kXMPP_MUC_HOST_NAME,
//                                    @"5222", kXMPP_PORT_NUMBER,
//                                    @"iOSSatay", kXMPP_RESOURCE,
//                                    nil];
//        [[XMPPAdapter share] reConfigXMPP:configInfo];
    }
    [[XMPPAdapter share] reconnectXMPP];
}

- (void)xmppDomainDidSuccessLogIn:(XMPPAdapter *)sender
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    //test: for change status
    [[XMPPAdapter share] setStatusMessage:@"hi hi ha ha" callback:^(BOOL success, NSString *message, NSDictionary *response, NSError *error) {
        if (success) {
            NSLog(@"---------------------\nHallo %@", message);
        }
    }];
    
    [self performSelector:@selector(setDN:) withObject:@"nhi nha nhi nho" afterDelay:10.0];

    // for display name
//    [[XMPPAdapter share] setDisplayName:@"Metal 😘"];
//    NSLog(@"my display name: %@ ", [[XMPPAdapter share] getDisplayNameForJID:[XMPPAdapter share].currentJID]);
    
    // update avatar
//    UIImage *avatar = [UIImage imageNamed:@"avatar.jpg"];
//    NSData *avatarData = UIImageJPEGRepresentation(avatar, 0.5f);
//    [[XMPPAdapter share] updateAvatar:avatarData];
}

- (void)setDN:(NSString *)dn
{
    NSLog(@"DN: %@", dn);
}

- (void)xmppDomainDidFailLogIn:(XMPPAdapter *)sender withError:(NSError *)error
{
    NSLog(@"%s %@", __PRETTY_FUNCTION__, error);
}

- (void)xmppDomain:(XMPPAdapter *)sender didGetXMPPDomainMessage:(NSString *)message
{
    NSLog(@"%s %@", __PRETTY_FUNCTION__, message);
}

- (void)xmppDomain:(XMPPAdapter *)sender didReceivePresence:(NSDictionary *)presence
{
    NSLog(@"%s %@", __PRETTY_FUNCTION__, presence);
    
    [[XMPPAdapter share] sendLastActivityQueryToJID:[presence valueForKey:kPRESENCE_FROM_USER_JID]];
    // for friend's avatar
    NSData *avatarData = [[XMPPAdapter share] getAvatarFromJID:[presence valueForKey:kPRESENCE_FROM_USER_JID]];
    if ([avatarData length]) {
        NSLog(@"2. %@ has avatar. size: %lu bytes", [presence valueForKey:kPRESENCE_FROM_USER_JID], (unsigned long)[avatarData length]);
    }
}

- (void)xmppDomain:(XMPPAdapter *)sender didReceiveMUCPresence:(NSDictionary *)presence
{
    NSLog(@"%s %@", __PRETTY_FUNCTION__, presence);
}

- (void)xmppDomain:(XMPPAdapter *)sender didReceiveProfileInfo:(NSDictionary *)info
{
    NSLog(@"%s %@ %@", __PRETTY_FUNCTION__, sender, info);
//    [[XMPPAdapter share] setDisplayName:@"T1dTVlJUWEc="];
}

- (void)xmppDomain:(XMPPAdapter *)sender didReceiveAvatar:(NSDictionary *)avatarInfo
{
//    NSLog(@"%s %@", __PRETTY_FUNCTION__, avatarInfo);
    NSData *imageData = [avatarInfo objectForKey:kAVATAR_IMAGE_DATA];
    NSLog(@"3.3. %@ has avatar. size: %lu bytes", [avatarInfo objectForKey:kAVATAR_TARGET_JID], (unsigned long)[imageData length]);
    NSNumber *isMe = [avatarInfo objectForKey:kAVATAR_IS_ME];
    if ([isMe isEqualToNumber:@0]) {
        NSLog(@"Not mine");
    } else {
        NSLog(@"Mine");
    }
}

- (void)xmppDomain:(XMPPAdapter *)sender didReceiveMessage:(NSDictionary *)message
{
    NSLog(@"%s %@", __PRETTY_FUNCTION__, message);
    
    NSDictionary *msgOBJ = [[NSDictionary alloc] initWithObjectsAndKeys:@"Hello, i am away now!", kSEND_TEXT_MESSAGE_VALUE, [message objectForKey:kTEXT_MESSAGE_FROM], kSEND_TEXT_TARGET_JID, @"xxxx", kSEND_TEXT_MESSAGE_ID, nil];
    [[XMPPAdapter share] sendTextMessage:msgOBJ];
    [[XMPPAdapter share] setDisplayName:[message objectForKey:kTEXT_MESSAGE_BODY]];
}

- (void)xmppDomain:(XMPPAdapter *)sender didReceiveChatState:(NSDictionary *)userInfo
{
    NSLog(@"%s %@", __PRETTY_FUNCTION__, userInfo);
//    NSDictionary *stateOBJ = [[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%d", kCHAT_STATE_TYPE_COMPOSING], kCHAT_STATE_TYPE, [userInfo objectForKey:kCHAT_STATE_FROM_JID], kCHAT_STATE_TARGET_JID, nil];
}

- (void)xmppDomainDidNotReceiveResponseOfLastActivity
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)xmppDomainDidReceiveResponseOfLastActivity:(NSDate *)lastActivityDate forBuddy:(NSString *)senderJID
{
    NSLog(@"%s %@: %@", __PRETTY_FUNCTION__, senderJID, lastActivityDate);
    
    // test for send text message to a buddy
//    NSDictionary *msgOBJ = [[NSDictionary alloc] initWithObjectsAndKeys:@"Hello, i am online", kSEND_TEXT_MESSAGE_VALUE, senderJID, kSEND_TEXT_TARGET_JID, @"xxxx", kSEND_TEXT_MESSAGE_ID, nil];
//    [[XMPPAdapter share] sendTextMessage:msgOBJ];
}

- (void)xmppDomainDidFailCreateRoom:(NSError *)error
{
    NSLog(@"%s %@", __PRETTY_FUNCTION__, error);
}

- (void)xmppDomain:(XMPPAdapter *)sender didReceiveMessageError:(NSDictionary *)error
{
    NSLog(@"%s %@", __PRETTY_FUNCTION__, error);
}

- (void)xmppDomain:(XMPPAdapter *)sender didFailToSendMessage:(NSDictionary *)userInfo
{
    NSLog(@"%s %@", __PRETTY_FUNCTION__, userInfo);
}

- (void)xmppDomain:(XMPPAdapter *)sender didSendMessage:(NSDictionary *)userInfo
{
    NSLog(@"%s %@", __PRETTY_FUNCTION__, userInfo);
}

- (void)xmppDomainDidFailUpdateOwnAvatar:(NSDictionary *)error
{
    NSLog(@"%s %@", __PRETTY_FUNCTION__, error);
}

- (void)xmppDomainDidUpdateOwnAvatar:(NSDictionary *)info
{
    NSLog(@"%s %@", __PRETTY_FUNCTION__, info);
}

- (void)xmppDomainDidFailUpdateOwnDisplayname:(NSDictionary *)error
{
    NSLog(@"%s %@", __PRETTY_FUNCTION__, error);
}

- (void)xmppDomainDidUpdateOwnDisplayname:(NSDictionary *)info
{
    NSLog(@"%s %@", __PRETTY_FUNCTION__, info);
}

- (void)xmppDomainDidReceiverVcardUpdate:(NSDictionary *)info
{
    NSLog(@"%s %@", __PRETTY_FUNCTION__, info);
}

- (void)xmppDomainDidReceiveAddFriendRequest:(NSDictionary *)requestInfo
{
    //
}

- (void)xmppDomainDidReceiveAddFriendApproved:(NSDictionary *)info
{
    //
}

- (void)xmppDomainDidReceiveAddFriendDenied:(NSDictionary *)info
{
    //
}

@end
