//
//  XMPPFacade.m
//  Satay
//
//  Created by Daniel Nguyen on 2/4/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import "XMPPFacade.h"

@implementation XMPPFacade

@synthesize displaynameDelegate;
@synthesize myProfileDelegate;
@synthesize contactNotificationDelegate;
@synthesize chatListNotificationDelegate;
@synthesize appSettingDelegate;
@synthesize joinedGroup, newestGroups;
@synthesize xmppQueue;

#define WATCHDOG_ADMIN @"-999"

+(XMPPFacade *)share
{
    static dispatch_once_t once;
    static XMPPFacade * share;
    dispatch_once(&once, ^{
        share = [self new];
        share.xmppQueue = [NSOperationQueue new];
    });
    return share;
}

#pragma mark - For Connecting & Config XMPP

- (BOOL)configXMPP{
    NSMutableDictionary* xmppConfig = [NSMutableDictionary new];
    NSString *resourceStr = [[NSString stringWithFormat:@"%@_IOS_%@", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"], [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]] uppercaseString];
    [xmppConfig setObject:@"sataydevim.mtouche-mobile.com" forKey:kXMPP_HOST_NAME];
    [xmppConfig setObject:resourceStr forKey:kXMPP_RESOURCE]; //@"APPLICATIONNAME_APPLICATIONOS_VERSION"
    [xmppConfig setObject:@"5222" forKey:kXMPP_PORT_NUMBER];
    [xmppConfig setObject:@"conference.sataydevim.mtouche-mobile.com" forKey:kXMPP_MUC_HOST_NAME];
    
    [XMPPAdapter instanceWithConfig:xmppConfig];
    [[XMPPAdapter share] setDelegate:self];
    return TRUE;
}

- (BOOL)configXMPPDefault
{
    [[XMPPAdapter share] setDelegate:self];
    return TRUE;
}

- (BOOL)connectXMPP{
    if ([[ContactFacade share] isAccountRemoved]) {
        return NO;
    }
    
    /*
     Jid:iQBgAkL
     JID Password:]<;8ijLU
     Jid Host:satay.mooo.com
     */
    // disconnect first
    [appSettingDelegate updateNetworkStatus:NO];
    
    // start connect
    NSMutableDictionary* connectDic = [NSMutableDictionary new];
    [connectDic setObject:[KeyChainSecurity getStringFromKey:kJID] forKey:kXMPP_USER_JID];
    [connectDic setObject:[KeyChainSecurity getStringFromKey:kJID_PASSWORD] forKey:kXMPP_USER_PASSWORD];
    NSLog(@"%@", connectDic);
    [[XMPPAdapter share] startAutoReconnect];
    return [[XMPPAdapter share] connectWithInfo:connectDic];
}

-(void)disconnectXMPP{
    [[XMPPAdapter share] stopAutoReconnect];
    [[XMPPAdapter share] disconnect];
    [contactNotificationDelegate showNoInternet:NO_SERVER_CONNECTION_MESSAGE];
    [chatListNotificationDelegate  showNoInternet:NO_SERVER_CONNECTION_MESSAGE];
}

- (NSDictionary *)getCurrentConfig
{
    return [[XMPPAdapter share] getCurrentConfig];
}

-(BOOL) isXMPPConnected{
    return [XMPPAdapter share].isConnected;
}

- (BOOL)isXMPPConnecting {
    return [XMPPAdapter share].isConnecting;
}

#pragma mark - For Main Functions

- (void)sendTextMessage:(NSDictionary *)objMSG
{
    [[XMPPAdapter share] sendTextMessage:objMSG];
}

- (void)sendMessageChatState:(NSDictionary *)stateInfo
{
    /*
     * @parameter messageInfo is a NSDictionary object, not NULL, with keys and values:
     *  + CHAT_STATE_TYPE           -> 1..5 (Active, Inactive, Composing, Paused and Gone)
     *  + CHAT_STATE_TARGET_JID     -> full jid
     */
    [[XMPPAdapter share] sendMessageChatState:stateInfo];
}

- (void)setMyStatus:(NSString *)text
{
    [[XMPPAdapter share] setStatusMessage:text callback:^(BOOL success, NSString *message, NSDictionary *response, NSError *error) {
        if (success) {
            // OK - this call for set old status from last login, no need to noti
        } else {
            // Not OK, maybe xmpp server response an error, need to log and debug.
        }
    }];
}

- (NSString *)getDisplayNameForJID:(NSString *)fullJID
{
    return [[XMPPAdapter share] getDisplayNameForJID:fullJID];
}

- (void)setDisplayName:(NSString *)displayname
{
    displayname = [Base64Security generateBase64String:displayname];
    [[XMPPAdapter share] setDisplayName:displayname];
}

- (void)updateAvatar:(NSData *)imageData
{
    [[XMPPAdapter share] updateAvatar:imageData];
}

#pragma mark - For Friend Featured
- (void)sendFriendRequest:(NSDictionary *)objInfo
{
    [[XMPPAdapter share] sendFriendRequest:objInfo];
}

- (void)sendFriendApproval:(NSDictionary *)objInfo
{
    [[XMPPAdapter share] sendFriendApproval:objInfo];
}

- (void)sendFriendUnapproval:(NSDictionary *)objInfo
{
    [[XMPPAdapter share] sendFriendUnapproval:objInfo];
}

- (void)sendNoticeDeleteFriend:(NSDictionary *)objInfo
{
    [[XMPPAdapter share] sendNoticeDeleteToFriend:objInfo];
}

#pragma mark - For MUC featured
- (void)createChatRoom:(NSDictionary *)objInfo
{
    [[XMPPAdapter share] createChatRoom:objInfo];
}

- (void)addUserToChatRoom:(NSDictionary *)objInfo
{
    NSLog(@"%s %@", __PRETTY_FUNCTION__, objInfo);
    
    [[XMPPAdapter share] addUserToRoom:objInfo];
}

- (void)joinToChatRoom:(NSDictionary *)objInfo
{
    NSLog(@"%s %@", __PRETTY_FUNCTION__, objInfo);
    [[XMPPAdapter share] joinToRoom:objInfo];
}

- (void)leaveChatRoom:(NSDictionary *)objInfo
{
    NSLog(@"%s %@", __PRETTY_FUNCTION__, objInfo);
    [[XMPPAdapter share] leaveChatRoom:[objInfo objectForKey:kMUC_ROOM_JID]];
}

- (void)kickMemberFromChatRoom:(NSDictionary *)objInfo
{
    NSLog(@"%s %@", __PRETTY_FUNCTION__, objInfo);
    [[XMPPAdapter share] kickUser:[objInfo objectForKey:kXMPP_TO_JID] fromRoom:[objInfo objectForKey:kMUC_ROOM_JID]];
}

#pragma mark - XMPP Domain Delegate
- (void)xmppDomainWillConnect:(XMPPAdapter *)sender
{
    if([[NotificationFacade share] isInternetConnected]){
        [contactNotificationDelegate showConnecting];
        [chatListNotificationDelegate showConnecting];
    }
    else{
        [contactNotificationDelegate showNoInternet:NO_SERVER_CONNECTION_MESSAGE];
        [chatListNotificationDelegate showNoInternet:NO_SERVER_CONNECTION_MESSAGE];
    }
    
    NSLog(@"%s %@", __PRETTY_FUNCTION__, sender);
}

- (void)xmppDomainDidConnect:(XMPPAdapter *)sender
{
    [[NotificationFacade share] hideInternetViewOfXmppConnection];
    [appSettingDelegate updateNetworkStatus:YES];
    NSLog(@"%s %@", __PRETTY_FUNCTION__, sender);
}

- (void)xmppDomainDidDisconnect:(XMPPAdapter *)sender withError:(NSError *)error
{
    [contactNotificationDelegate showNoInternet:NO_SERVER_CONNECTION_MESSAGE];
    [chatListNotificationDelegate showNoInternet:NO_SERVER_CONNECTION_MESSAGE];
    
    [appSettingDelegate updateNetworkStatus:NO];
    NSLog(@"%s %@ %@", __PRETTY_FUNCTION__, sender, error);
    NSLog(@"%s %@", __PRETTY_FUNCTION__, [self getCurrentConfig]);
}

- (void)xmppDomainDidSuccessLogIn:(XMPPAdapter *)sender
{
    [[NotificationFacade share] hideInternetViewOfXmppConnection];
    [appSettingDelegate updateNetworkStatus:YES];
    NSLog(@"%s %@", __PRETTY_FUNCTION__, sender);
    [[XMPPAdapter share] setStatusMessage:[[ProfileAdapter share] getProfileStatus] callback:^(BOOL success, NSString *message, NSDictionary *response, NSError *error) {
        if (success) {
            // OK - this call for set old status from last login, no need to noti
        } else {
            // Not OK, maybe xmpp server response an error, need to log and debug.
        }
    }];
    
    // re-join to my old chat rooms
    if (!joinedGroup) {
        joinedGroup = [NSMutableArray new];
    }
    [joinedGroup removeAllObjects];
    
    [joinedGroup addObjectsFromArray:[[ChatFacade share] rejoinGroups]];
    
    // for newest joined group
    if (!newestGroups) {
        newestGroups = [NSMutableArray new];
    }
    [newestGroups removeAllObjects];
}

- (void)xmppDomainDidFailLogIn:(XMPPAdapter *)sender withError:(NSError *)error
{
    NSLog(@"%s %@ %@", __PRETTY_FUNCTION__, sender, error);
    //if this device is unable to login; it will be disconnected from XMPP  because xmpp password is changed.
    [self disconnectXMPP];
}

- (void)xmppDomainDidTimedOut:(XMPPAdapter *)sender
{
#warning Need to handle this, eg: show status pending to send message...
    NSLog(@"%s %@", __PRETTY_FUNCTION__, sender);
}

- (void)xmppDomainDidReceivePong:(XMPPAdapter *)sender
{
    //
}

- (void)xmppDomain:(XMPPAdapter *)sender didReceiveMessage:(NSDictionary *)message
{
    NSString* fromJid = [message objectForKey:kTEXT_MESSAGE_FROM];
    fromJid = [[fromJid componentsSeparatedByString:@"@"] objectAtIndex:0];
    
    if ([fromJid isEqualToString:WATCHDOG_ADMIN]) {
        if ([[SIPFacade share] isIncommingCallReceived:[message objectForKey:kTEXT_MESSAGE_BODY]]) {
            return;
        }
        NSBlockOperation* blockOperation = [NSBlockOperation blockOperationWithBlock:^{
            [[ChatFacade share] receiveNotification:message];
        }];
        if([xmppQueue.operations lastObject]){
            [blockOperation addDependency:[xmppQueue.operations lastObject]];
        }
        [xmppQueue addOperation:blockOperation];
    }
    else{
        [[ChatFacade share] receiveMessage:message];
    }
}

- (void)xmppDomain:(XMPPAdapter *)sender didReceiveChatState:(NSDictionary *)userInfo
{
    NSLog(@"%s %@ %@", __PRETTY_FUNCTION__, sender, userInfo);
    [[ChatFacade share] handleChatStateMessage:userInfo];
}

- (void)xmppDomain:(XMPPAdapter *)sender didReceiveMUCMessage:(NSDictionary *)message
{
    NSLog(@"%s %@ %@", __PRETTY_FUNCTION__, sender, message);
    // check if mess from a room what was kicked you, then leave this room and ignore this mess
    NSString *roomJID = [message objectForKey:kMUC_ROOM_JID];
    if (!roomJID) {
        return;
    }
    
    GroupMember *gm = [[AppFacade share] getGroupMember:roomJID
                                                userJID:[[ContactFacade share] getJid:YES]];
    if (!gm) {
        return;
    }
    
    NSDate *delayed = [message objectForKey:kTEXT_MESSAGE_DELAYED_DATE];
    if(!delayed)
        delayed = [NSDate new];
    
    NSTimeInterval kickTime = [[ChatAdapter convertDate:gm.extend1
                                                 format:FORMAT_DATE_DETAIL_ACCOUNT] floatValue];
    NSTimeInterval addTime = [[ChatAdapter convertDate:gm.extend2
                                                format:FORMAT_DATE_DETAIL_ACCOUNT] floatValue];
    NSTimeInterval msgTime = [delayed timeIntervalSince1970];
    
    if(kickTime > 0 && kickTime > addTime){
        if (msgTime > kickTime) {
            if (![message objectForKey:kTEXT_MESSAGE_DELAYED_DATE]) {
                NSDictionary *leaveDic = @{kMUC_ROOM_JID: roomJID,
                                           kXMPP_TO_JID: [[ContactFacade share] getJid:YES]};
                [[XMPPFacade share] leaveChatRoom:leaveDic];// leave this group because kicked out from this.
            }
            return;
        }
    }
    
    [[ChatFacade share] receiveMessage:message];
}

- (void)xmppDomain:(XMPPAdapter *)sender didReceiveMUCPresence:(NSDictionary *)presence
{
    NSLog(@"%s %@ %@", __PRETTY_FUNCTION__, self, presence);
    [[ChatFacade share] handleNoticeFromPresence:presence];
}

- (void)xmppDomain:(XMPPAdapter *)sender didReceivePresence:(NSDictionary *)presence
{
    NSLog(@"%s %@ %@", __PRETTY_FUNCTION__, sender, presence);
    [[ContactFacade share] updateContactPresence:presence];
}

- (void)xmppDomain:(XMPPAdapter *)sender didReceiveReceiptResponse:(NSDictionary *)receiptInfo
{
    [[ChatFacade share] receiveMessageStatus:receiptInfo];
}

- (void)xmppDomain:(XMPPAdapter *)sender didReceiveAvatar:(NSDictionary *)avatarInfo
{
    /*TRUNGVN, THIS METHOD CURRENTLY DEPRECATED.
     */
}

- (void)xmppDomain:(XMPPAdapter *)sender didFailToSendMessage:(NSDictionary *)userInfo
{
    NSLog(@"%s %@", __PRETTY_FUNCTION__, userInfo);
}

- (void)xmppDomain:(XMPPAdapter *)sender didSendMessage:(NSDictionary *)userInfo
{
    [[ChatFacade share] receiveMessageStatus:userInfo];
}

- (void)xmppDomainDidReceiveResponseOfLastActivity:(NSDate *)lastActivityDate forBuddy:(NSString *)senderJID{
    
    NSLog(@"%s %@ %@", __PRETTY_FUNCTION__, lastActivityDate, senderJID);
    [[ContactFacade share] updateContactLastActivity:lastActivityDate JID:senderJID];
}

- (void)xmppDomainDidNotReceiveResponseOfLastActivity{
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

#pragma mark - For Avatar, Display Name...
- (void)xmppDomain:(XMPPAdapter *)sender didReceiveProfileInfo:(NSDictionary *)info
{
    NSLog(@"%s %@", __PRETTY_FUNCTION__, info);
}

- (void)xmppDomainDidFailUpdateOwnAvatar:(NSDictionary *)error
{
    [myProfileDelegate updateAvatarFailed];
    //NSLog(@"%s %@", __PRETTY_FUNCTION__, error);
}

- (void)xmppDomainDidUpdateOwnAvatar:(NSDictionary *)info
{
    [myProfileDelegate updateAvatarSuccess];
    //NSLog(@"%s %@", __PRETTY_FUNCTION__, info);
}

- (void)xmppDomainDidReceiverVcardUpdate:(NSDictionary *)info
{
    //NSLog(@"%s %@", __PRETTY_FUNCTION__, info);
    //NSLog(@"updateContactInfo from xmpp");
    //[[ContactFacade share] updateContactInfo:[info objectForKey:kXMPP_USER_JID]];
}

#pragma mark - For AddFriend Delegate
- (void)xmppDomainDidReceiveAddFriendRequest:(NSDictionary *)requestInfo
{
    [[ContactFacade share] didReceiveRequest:requestInfo];
}

- (void)xmppDomainDidReceiveAddFriendApproved:(NSDictionary *)info
{
    [[ContactFacade share] didReceiveApprove:info];
}

- (void)xmppDomainDidReceiveAddFriendDenied:(NSDictionary *)info
{
    //NSLog(@"%s %@", __PRETTY_FUNCTION__, info);
    [[ContactFacade share] wasDeniedFromRequest:[info objectForKey:kXMPP_FROM_JID]];
}

- (void)xmppDomainDidDenyARequest:(NSDictionary *)info
{
    //NSLog(@"%s %@", __PRETTY_FUNCTION__, info);
    [[ContactFacade share] removeDeniedRequest:[info objectForKey:kXMPP_FROM_JID]];
}

- (void)xmppDomainDidApprovedFromFriend:(NSDictionary *)info
{
    //NSLog(@"%s %@", __PRETTY_FUNCTION__, info);
    [[ContactFacade share] friendRequestApproved:info wasApprovedFromFriend:NO];
    [self sendLastActivityQueryToJID:[info objectForKey:kXMPP_FROM_JID]];
    [[XMPPAdapter share] setStatusMessage:[[ProfileAdapter share] getProfileStatus] callback:^(BOOL success, NSString *message, NSDictionary *response, NSError *error) {
        if (success) {
            // OK - this call for set old status from last login, no need to noti
        } else {
            // Not OK, maybe xmpp server response an error, need to log and debug.
        }
    }];
}

- (void)xmppDomainDidDeletedFriendFromJID:(NSString *)fromJID
{
    //NSLog(@"%s %@", __PRETTY_FUNCTION__, fromJID);
    [[ContactFacade share] didSuccessRemoveContact:fromJID];
}

#pragma mark - For MUC featured
- (void)xmppDomain:(XMPPAdapter *)sender didCreatedChatRoom:(NSString *)roomID
{
    NSLog(@"%s %@", __PRETTY_FUNCTION__, roomID);
    // we receive room jid as "wkjcwhm0e8qgnenygunteiir2@conference.satay.mooo.com/y956e@satay.mooo.com"
    // but we just use "wkjcwhm0e8qgnenygunteiir2"
    //NSString *roomJID = [[roomID componentsSeparatedByString:@"@"] objectAtIndex:0];
    //[[ChatFacade share] queryAddMembersToChatRoom:roomJID];
    [[ChatFacade share] didSuccessCreateChatRoom:[[roomID componentsSeparatedByString:@"/"] objectAtIndex:0]];
}

- (void)xmppDomainDidFailCreateRoom:(NSError *)error
{
    //NSLog(@"%s %@", __PRETTY_FUNCTION__, error);
    [[CWindow share] hideLoading];
}

- (void)xmppDomain:(XMPPAdapter *)sender didFailInviteToChatRoom:(NSDictionary *)info
{
    NSLog(@"%s %@", __PRETTY_FUNCTION__, info);
}

- (void)xmppDomain:(XMPPAdapter *)sender didInviteToChatRoom:(NSDictionary *)info
{
    NSLog(@"%s %@", __PRETTY_FUNCTION__, info);
    NSString *roomJID = [info objectForKey:kMUC_ROOM_JID];
    NSString *toJID = [info objectForKey:kXMPP_TO_JID];
    [[ChatFacade share] saveMember:toJID
                           toGroup:roomJID
                         withState:kGROUP_MEMBER_STATE_INACTIVE
                           andRole:kGROUP_MEMBER_ROLE_MEMBER];
}

- (void)xmppDomain:(XMPPAdapter *)sender didReceiveInvitationToChatRoom:(NSDictionary *)roomInfo
{
    NSLog(@"%s %@", __PRETTY_FUNCTION__, roomInfo);
    NSString* roomJID = [roomInfo objectForKey:kMUC_ROOM_JID];
    NSString* shortRoomJID = [[roomJID componentsSeparatedByString:@"@"] objectAtIndex:0];
    NSString* fromJID = [roomInfo objectForKey:kXMPP_FROM_JID];
    
    if (roomJID.length == 0 || [roomJID isEqual:[NSNull null]])
        return;
    
    //check if contact blocked or not friend then not process the message.
    if ([[ContactFacade share] isBlocked:fromJID] || ![[ContactFacade share] isFriend:fromJID])
        return;
    
    if(shortRoomJID.length == 0)
        return;
    
    // store local temp for timestamp will update to chatbox db
    NSDate* delayedDate = [roomInfo objectForKey:kTEXT_MESSAGE_DELAYED_DATE];
    if(!delayedDate)
        delayedDate = [NSDate date];
    
    [[NSUserDefaults standardUserDefaults] setObject:delayedDate
                                              forKey:[NSString stringWithFormat:@"%@%@", kJOIN_FREFIX, shortRoomJID]];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[ChatFacade share] getChatRoom:shortRoomJID forJoin:YES];
    
    // add to newestGroups array
    [newestGroups addObject:roomJID];
    NSLog(@"newestGroups: %@", newestGroups);
}

- (void)xmppDomain:(XMPPAdapter *)sender didJoinChatRoom:(NSDictionary *)roomInfo
{
    NSLog(@"%s %@", __PRETTY_FUNCTION__, roomInfo);
    NSString *roomFullJID = [[[roomInfo objectForKey:kMUC_ROOM_JID] componentsSeparatedByString:@"/"] objectAtIndex:0];
    NSString *roomShortJID = [[roomFullJID componentsSeparatedByString:@"@"] objectAtIndex:0];
    
    NSOperationQueue* operationQueue = [NSOperationQueue new];
    NSBlockOperation* blockOperation = [NSBlockOperation blockOperationWithBlock:^{
        [[ChatFacade share] saveGroupChatInfo:roomShortJID];
    }];
    
    [blockOperation setCompletionBlock:^{
        BOOL isNewestGroup = NO;
        for (NSString* roomJID in newestGroups) {
            if ([roomJID isEqualToString:roomFullJID]) {
                isNewestGroup = YES;
                break; // for re-joined, no need to fire to "didSuccessJoinChatRoom" delegate - Daniel, Apr 23, 2015
            }
        }
        
        if (isNewestGroup) {
            [newestGroups removeObject:roomFullJID];
        }
        
        [[ChatFacade share] didSuccessJoinChatRoom:roomFullJID isRejoined:!isNewestGroup];
    }];
    
    [operationQueue addOperation:blockOperation];
}

- (void)xmppDomain:(XMPPAdapter *)sender didLeaveChatRoom:(NSDictionary *)roomInfo
{
    
}

- (void)sendBookmarkForRoom:(NSString *)roomJID
{
    //
}

#pragma mark For sending lastactivity query to JID

-(void) sendLastActivityQueryToJID:(NSString*) JID
{
    NSLog(@"%s: %@", __PRETTY_FUNCTION__, JID);
    [[XMPPAdapter share] sendLastActivityQueryToJID:JID];
}

#pragma mark - For Stream Management
- (void)resetStreamManagement
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [[XMPPAdapter share] resetStreamManagement];
}

@end
