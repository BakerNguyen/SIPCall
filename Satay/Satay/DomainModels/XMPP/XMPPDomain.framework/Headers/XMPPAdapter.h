//
//  XMPPAdapter.h
//  XMPPDomain
//
//  Created by Daniel Nguyen on 12/30/14.
//  Copyright (c) 2014 mTouche. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "XMPPFramework.h"
#import "XMPPStreamManagement.h"

@protocol XMPPDomainDelegate;

@interface XMPPAdapter : NSObject <XMPPRosterDelegate,
                                    XMPPRosterMemoryStorageDelegate,
                                    XMPPStreamDelegate,
                                    XMPPReconnectDelegate,
                                    XMPPIncomingFileTransferDelegate,
                                    XMPPOutgoingFileTransferDelegate,
                                    XMPPAutoPingDelegate,
                                    XMPPPingDelegate,
                                    XMPPLastActivityDelegate,
                                    XMPPMUCDelegate,
                                    XMPPRoomDelegate,
                                    XMPPvCardAvatarDelegate,
                                    XMPPvCardTempModuleDelegate,
                                    XMPPStreamManagementDelegate>
{
    XMPPStream                      *xmppStream;
    XMPPReconnect                   *xmppReconnect;
    XMPPRoster                      *xmppRoster;
    XMPPRosterCoreDataStorage       *xmppRosterStorage;
    XMPPRosterMemoryStorage         *xmppRosterMemoryStorage;
    XMPPvCardCoreDataStorage        *xmppvCardStorage;
    XMPPvCardTempModule             *xmppvCardTempModule;
    XMPPvCardAvatarModule           *xmppvCardAvatarModule;
    XMPPCapabilities                *xmppCapabilities;
    XMPPCapabilitiesCoreDataStorage *xmppCapabilitiesStorage;
    XMPPAutoPing                    *xmppAutoPing;
    XMPPPing                        *xmppPing;
    XMPPLastActivity                *xmppLastActivity;
    XMPPMUC                         *xmppMUC;
    XMPPMessageDeliveryReceipts     *xmppMDR;
    XMPPStreamManagement            *xmppSM;
}

@property (nonatomic, strong, readonly) XMPPStream *xmppStream;
@property (nonatomic, strong, readonly) XMPPReconnect *xmppReconnect;
@property (nonatomic, strong, readonly) XMPPRoster *xmppRoster;
@property (nonatomic, strong, readonly) XMPPRosterCoreDataStorage *xmppRosterStorage;
@property (nonatomic, strong, readonly) XMPPRosterMemoryStorage *xmppRosterMemoryStorage;
@property (nonatomic, strong, readonly) XMPPvCardTempModule *xmppvCardTempModule;
@property (nonatomic, strong, readonly) XMPPvCardAvatarModule *xmppvCardAvatarModule;
@property (nonatomic, strong, readonly) XMPPCapabilities *xmppCapabilities;
@property (nonatomic, strong, readonly) XMPPCapabilitiesCoreDataStorage *xmppCapabilitiesStorage;
@property (nonatomic, strong, readonly) XMPPIncomingFileTransfer *fileTransfer;
@property (nonatomic, strong, readonly) XMPPAutoPing *xmppAutoPing;
@property (nonatomic, strong, readonly) XMPPPing *xmppPing;
@property (nonatomic, strong, readonly) XMPPLastActivity *xmppLastActivity;
@property (nonatomic, strong, readonly) XMPPMUC *xmppMUC;
@property (nonatomic, strong, readonly) XMPPMessageDeliveryReceipts *xmppMDR;
@property (nonatomic, strong, readonly) XMPPStreamManagement *xmppSM;

@property (nonatomic, strong, readonly) NSString *currentJID;

@property (nonatomic, strong) id<XMPPDomainDelegate> delegate;

typedef void (^requestCompleteBlock)(BOOL success, NSString *message ,NSDictionary *response, NSError *error);

+ (XMPPAdapter *)share;
/**
 * instanceWithDefaultConfig: init the Adapter object to using XMPP Framework, call if you want to use the default host
 * @default host info
 * {
 *    XMPP_HOST_NAME      = @"satay.mooo.com";
 *    XMPP_MUC_HOST_NAME  = @"conference.satay.mooo.com";
 *    XMPP_PORT_NUMBER    = @"5222";
 *    XMPP_RESOURCE       = @"iOSSatay";
 * }
 *
 * @author Daniel
 */
/// init the Adapter object to using XMPP Framework, call if you want to use the default host
+ (id)instanceWithDefaultConfig;
/**
 * instanceWithConfig: init the Adapter object to using XMPP Framework, call first if you have a host with info
 * @parameter configInfo is a NSDictionary object, must key - value, not NULL
 * {
 *      XMPP_HOST_NAME - domain name, ip statistic, eg: satay.mooo.com;
 *      XMPP_MUC_HOST_NAME - domain name, ip statistic, eg: conference.satay.mooo.com
 *      XMPP_RESOURCE - string, eg: iOSSatay ;
 *      XMPP_PORT_NUMBER - port number, eg: 5222;
 * }
 * 
 * @author Daniel
 */
///init the Adapter object to using XMPP Framework, call first if you have a host with info
+ (id)instanceWithConfig:(NSDictionary *)configInfo;
/**
 * reConfigXMPP: re-config the Adapter object to using XMPP Framework, can be call anytime
 * @parameter configInfo is a NSDictionary object, must key - value, not NULL
 * {
 *      XMPP_HOST_NAME - domain name, ip statistic, eg: satay.mooo.com;
 *      XMPP_MUC_HOST_NAME - domain name, ip statistic, eg: conference.satay.mooo.com
 *      XMPP_RESOURCE - string, eg: iOSSatay ;
 *      XMPP_PORT_NUMBER - port number, eg: 5222;
 * }
 *
 * @author Daniel
 */
///re-config the Adapter object to using XMPP Framework, can be call anytime
- (void)reConfigXMPP:(NSDictionary *)configInfo;
/**
 * getCurrentConfig: get the current config of the XMPP
 * @result configInfo is a NSDictionary object, have key - value
 * {
 *      XMPP_HOST_NAME - domain name, ip statistic, eg: satay.mooo.com;
 *      XMPP_MUC_HOST_NAME - domain name, ip statistic, eg: conference.satay.mooo.com
 *      XMPP_RESOURCE - string, eg: iOSSatay ;
 *      XMPP_PORT_NUMBER - port number, eg: 5222;
 * }
 *
 * @author Daniel
 */
///get the current config of the XMPP
- (NSDictionary *)getCurrentConfig;
/**
 * connectWithInfo: connect to xmpp server with user JID and password
 * @parameter userInfo is a NSDictionary object, not NULL, with keys and values:
 *  + XMPP_USER_JID         -> @"daniel.nguyen" jid without domain. the domain will get from instance method.
 *  + XMPP_USER_PASSWORD    -> @"123456" (the password string, with plain text)
 *
 * @author Daniel
 */
///connect to xmpp server with user JID and password
- (BOOL)connectWithInfo:(NSDictionary *)userInfo;
- (void)disconnect;
///re-connect to XMPP with current info
- (void)reconnectXMPP;

- (BOOL)isConnected;
- (BOOL)isConnecting;
- (BOOL)isDisconnected;

#pragma mark - for profile
/**
 * getDisplayNameForJID: get the displayname for JID
 * @parameter jid eg: @"daniel.nguyen@satay.mooo.com" jid with domain
 * @result a string object, eg: "My Display Name"
 *
 * @author Daniel
 */
///get the displayname for JID
- (NSString *)getDisplayNameForJID:(NSString *)jid;
/**
 * setDisplayName: set the displayname for current user
 * @parameter displayName is a string value, eg: "My Display Name"
 *
 * @author Daniel
 */
///set the displayname for current user
- (void)setDisplayName:(NSString *)newDisplayName;

#pragma mark - for status
- (void)goAway;
- (void)goBusy;
- (void)goAvailable;
- (void)goOffline;
/**
 * setStatusMessage: set the status text for user
 * @parameter statusMsg is a string object
 *
 * @author Daniel
 */
///set the status text for user
- (void)setStatusMessage:(NSString *)statusMsg callback:(requestCompleteBlock)callback;

#pragma mark - last activity
/**
 * sendLastActivityQueryToJID: send the last activity request to a JID
 * @parameter jid -> @"daniel.nguyen@satay.mooo.com/iOSSatay" jid with full domain and resource.
 *
 * @author Daniel
 */
///send the last activity request to a JID
- (void)sendLastActivityQueryToJID:(NSString *)jid;
/**
 * sendUpdatevCardNotice: send the updated vCard to all firends
 * @parameter flag = kVCARD_UPDATE_AVATAR or flag = kVCARD_UPDATE_DISPLAYNAME
 *
 * @author Daniel
 */
- (void)sendUpdatevCardNotice:(int)flag;

#pragma mark - for avatar
- (NSData *)getAvatarFromJID:(NSString *)fullJID;
/**
 * updateAvatar: update current user avatar
 * @parameter imageData -> is a NSData from UIImage
 *
 * @author Daniel
 */
/// update avatar for current user. parameter is a NSData from UIImage (eg: UIImagePNGRepresentation(UIImage))
- (void)updateAvatar:(NSData *)imageData;

#pragma mark - for roster
/**
 * sendFriendRequest
 * @parameter objInfo is a NSDictionary have keys - values
 *  + XMPP_TO_JID
 *  + XMPP_SUBSCRIPTION_ID
 *  + XMPP_SUBSCRIPTION_BODY
 *
 * @author Daniel
 */
- (void)sendFriendRequest:(NSDictionary *)objInfo;
- (void)sendFriendApproval:(NSDictionary *)objInfo;
- (void)sendFriendUnapproval:(NSDictionary *)objInfo;
- (void)sendFriendApprovedNotice:(NSDictionary *)objInfo;
- (BOOL)isFriendWithJID:(NSString *)jid;
- (void)sendNoticeDeleteToFriend:(NSDictionary *)objInfo;

/**
 * send Friend Subscription To a xmpp user
 * @parameter fullJID is a String for full JID of xmpp user
 *
 * @author Daniel
 */
- (void)sendFriendSubscriptionTo:(NSString *)fullJID;
/**
 * send Friend Un-Subscription To a xmpp user
 * @parameter fullJID is a String for full JID of xmpp user
 *
 * @author Daniel
 */
- (void)sendFriendUnSubscriptionTo:(NSString *)fullJID;

#pragma mark - for single chat
/*
 * sendTextMessage: send a text message to jabber id
 * @parameter messageInfo is a NSDictionary object, not NULL, with keys and values:
 *  + SEND_TEXT_MESSAGE_VALUE  -> @"hello, this is a message from a friend!"
 *  + SEND_TEXT_TARGET_JID     -> @"daniel.nguyen@satay.mooo.com/iOSSatay" jid with full domain and resource.
 *  + SEND_TEXT_MESSAGE_ID     -> @"EC0F939F871D76F2BC5034FA67A2DB1A" an unique string.
 *  + XMPP_MESSAGE_TYPE        -> XMPP_MESSAGE_TYPE_MUC or XMPP_MESSAGE_TYPE_SINGLE
 *
 * @author Daniel
 */
///parameter messageInfo is a NSDictionary object, NOT NULL, with keys and values: TEXT_VALUE -> @"hello" and TARGET_JID jid with full domain and resource.
- (void)sendTextMessage:(NSDictionary *)messageInfo;

#pragma mark - for MUC
- (void)fetchRoom;
- (void)addUserToChatRoomByCreateGroup:(NSString *)roomJID TargetJID:(NSString *)targetJID withMessage:(NSString *)message Password:(NSString *)roomPassword;
/*
 * add (invite) an user to exist chat room
 * @param infoObj is a NSDictionary object, have MUC_ROOM_JID, MUC_ROOM_PASSWORD, XMPP_MUC_HOST_NAME
 * @author Daniel
 */
- (void)createChatRoom:(NSDictionary *)infoObj;
- (void)addUserToChatRoom:(NSString *)roomJID TargetJID:(NSString *)targetJID withMessage:(NSString *)message Password:(NSString *)roomPassword;
/*
 * add (invite) an user to exist chat room
 * @param infoObj is a NSDictionary object, have MUC_ROOM_JID, XMPP_MUC_HOST_NAME, XMPP_TO_JID, MUC_ROOM_INVITE_MESSAGE
 * @author Daniel
 */
- (void)addUserToRoom:(NSDictionary *)infoObj;
- (void)joinChatRoom:(NSString *)chatRoomJID withNickName:(NSString *)nickName andPassword:(NSString *)roomPassword;
/*
 * join to exist chat room
 * @param infoObj is a NSDictionary object, have MUC_ROOM_JID, MUC_ROOM_PASSWORD, XMPP_USER_DISPLAYNAME, MUC_HISTORY (= timestamp, default = 0)
 * @author Daniel
 */
- (void)joinToRoom:(NSDictionary *)infoObj;
- (void)leaveChatRoom:(NSString *)chatRoomJID;
- (void)kickUser:(NSString *)targetJID fromRoom:(NSString *)roomJID;
- (void)banUser:(NSString *)targetJID fromRoom:(NSString *)roomJID;
/*
 * sendGroupTextMessage: send a text message to jabber id
 * @parameter messageInfo is a NSDictionary object, not NULL, with keys and values:
 *  + MUC_SEND_TEXT_MESSAGE_VALUE   -> @"hello, this is a message from a group chat!"
 *  + MUC_SEND_TEXT_TARGET_ROOMJID  -> @"groupgameonline" jid without domain.
 *
 * @author Daniel
 */
///parameter messageInfo is a NSDictionary object, NOT NULL, with keys and values: TEXT_VALUE -> "hello" and TARGET_ROOMJID  -> jid without domain.
- (void)sendGroupTextMessage:(NSDictionary *)messageInfo;
- (void)bookmarkGroupChat:(NSDictionary *)infoObj;
- (void)setNoDiscussionHistory:(NSString *)fullRoomJID;
#pragma mark - for Other
/*
 * sendMessageChatState: send Composing Chat State to friend (a jabber id) in chat view
 * @parameter messageInfo is a NSDictionary object, not NULL, with keys and values:
 *  + CHAT_STATE_TYPE           -> 1..5 (Active, Inactive, Composing, Paused and Gone)
 *  + CHAT_STATE_TARGET_JID     -> @"daniel.nguyen@satay.mooo.com/iOSSatay" jid with full domain and resource.
 *
 * @author Daniel
 */
///parameter stateInfo is a NSDictionary object, NOT NULL, with keys and values: STATE_TYPE -> 1..5 and TARGET_JID -> jid with full domain and resource
- (void)sendMessageChatState:(NSDictionary *)stateInfo;

#pragma mark - Utils
- (NSDictionary *)parsevCardInfoFromXMLString:(NSString *)xmlstring;
- (void)startAutoReconnect;
- (void)stopAutoReconnect;
- (void)resetStreamManagement;
@end

#pragma mark - XMPP Domain Delegate
@protocol XMPPDomainDelegate <NSObject>
@required
/**
 *  @author Daniel Nguyen, 15-05-06 18:05
 *
 *  @brief  Callback when the XMPPAdapter sender is connected
 *
 *  @param sender current instance of XMPPAdapter
 */
- (void)xmppDomainDidConnect:(XMPPAdapter *)sender;
/**
 *  @author Daniel Nguyen, 15-05-06 17:05
 *
 *  @brief  Callback when the XMPPAdapter sender is connecting
 *
 *  @param sender current instance of XMPPAdapter
 */
- (void)xmppDomainWillConnect:(XMPPAdapter *)sender;
/**
 *  @author Daniel Nguyen, 15-05-06 17:05
 *
 *  @brief  Callback when the XMPPAdapter sender receives an error and can't connect
 *
 *  @param sender current instance of XMPPAdapter
 *  @param error
 */
- (void)xmppDomainDidDisconnect:(XMPPAdapter *)sender withError:(NSError *)error;
/**
 *  @author Daniel Nguyen, 15-05-06 18:05
 *
 *  @brief  Callback when the XMPPAdapter sender login success
 *
 *  @param sender current instance of XMPPAdapter
 */
- (void)xmppDomainDidSuccessLogIn:(XMPPAdapter *)sender;
/**
 *  @author Daniel Nguyen, 15-05-06 18:05
 *
 *  @brief  Callback when the XMPPAdapter sender receives an error and can't loged in
 *
 *  @param sender current instance of XMPPAdapter
 *  @param error
 */
- (void)xmppDomainDidFailLogIn:(XMPPAdapter *)sender withError:(NSError *)error;
/**
 *  @author Daniel Nguyen, 15-05-06 18:05
 *
 *  @brief  Callback when the XMPPAdapter sender is timed out
 *
 *  @param sender current instance of XMPPAdapter
 */
- (void)xmppDomainDidTimedOut:(XMPPAdapter *)sender;

@optional
/**
 *  @author Daniel Nguyen, 15-05-06 18:05
 *
 *  @brief  Callback when the XMPPAdapter sender is ping normally
 *
 *  @param sender current instance of XMPPAdapter
 */
- (void)xmppDomainDidReceivePong:(XMPPAdapter *)sender;
/**
 * xmppDomain:didReceiveProfileInfo:
 * @result:
 *   {
 *       "XMPP_USER_DISPLAYNAME" = @"Display Name";
 *       "XMPP_USER_JID" = d0dvj@satay.mooo.com;
 *       "XMPP_JID_KIND" = @"jid_single" or @"jid_single";
 *   }
 * @author Daniel
 */
- (void)xmppDomain:(XMPPAdapter *)sender didReceiveProfileInfo:(NSDictionary *)info;
- (void)xmppDomain:(XMPPAdapter *)sender didReceivePresence:(NSDictionary *)presence;
/**
 * xmppDomain:didReceiveMessage
 * @result info:
 *    {
 *    "TEXT_MESSAGE_BODY" = "ENC$#$Na0xaAeEUMbOXCLzORnL5hcXMaw3BthY8eZM+2825Beo4esxEeXH0HFqS226YcBLmOdRT2TA5eDIyRwvRdP8v3p9bpI0de+ohI1S72/B9WzqPlOzRQEeUmViSgzsKdm89Ho5dGEMgEjbZlmbRostj2VWtdWzx+8bYqZYz2BqlyU=*@*3Zjdnf1lvpupGHQmvFYO/b68hcNgIeFIp0JRRt2EC5mB045zuSEwg6/dKTGK7/0AIGgxOWh3LIOtjVDW1wzc0g==$#$H1+TBVH9E+yKfImSV3SDzysfFgfZx+hYpsOTIZl7GG9Oo8fI4q04dCpSAdFLszJb4HyzGL4cI+HaEK477pOSs+e1xeR4RzV2K+o+kld8uoohO6EBloZdmZaTBM1qfGZqTft064YaKuQQoin4Cypue9UUzBDlqGjKEtvOpoudceE=^%^";
 *    "TEXT_MESSAGE_DELAYED_DATE" = "2015-03-06 10:13:20 +0000" -> NSDate object
 *    "TEXT_MESSAGE_FROM" = "wbaieh_q1g@satay.mooo.com"         -> NSString
 *    "TEXT_MESSAGE_ID" = YpdTpMvK                              -> NSString
 *    "TEXT_MESSAGE_TYPE" = chat                                -> NSString
 *    }
 * @author Daniel
 */
- (void)xmppDomain:(XMPPAdapter *)sender didReceiveMessage:(NSDictionary *)message;
- (void)xmppDomain:(XMPPAdapter *)sender didGetXMPPDomainMessage:(NSString *)message;
- (void)xmppDomain:(XMPPAdapter *)sender didReceiveChatState:(NSDictionary *)userInfo;
/*
 * xmppDomain:didSendMessage:
 * @result:
 *   {
 *       "MESSAGE_STATUS" = 10 (= MESSAGE_STATUS_SENT);
 *       "TEXT_MESSAGE_ID" = xxxx;
 *   }
 * @author Daniel
 */
- (void)xmppDomain:(XMPPAdapter *)sender didSendMessage:(NSDictionary *)userInfo;
/*
 * xmppDomain:didFailToSendMessage:
 * @result:
 *   {
 *       "MESSAGE_STATUS" = 18 (= MESSAGE_STATUS_SEND_FAILED);
 *       "TEXT_MESSAGE_ERROR" = [NSError *];
 *       "TEXT_MESSAGE_ID" = xxxx;
 *   }
 * @author Daniel
 */
- (void)xmppDomain:(XMPPAdapter *)sender didFailToSendMessage:(NSDictionary *)userInfo;
/*
 * xmppDomain:didReceiveAvatar:
 * @result avatarInfo is a NSDictionary, contain:
 *  {
 *      "AVATAR_IMAGE_DATA" = [NSData dataWithBase64EncodedString:base64DataString];
 *      "AVATAR_IS_ME" = 1 (my avatar) or 0 (friend's avatar);
 *      "AVATAR_TARGET_JID" = "d0dvj@satay.mooo.com";
 *  }
 * @author Daniel
 */
- (void)xmppDomain:(XMPPAdapter *)sender didReceiveAvatar:(NSDictionary *)avatarInfo;
- (void)xmppDomainDidReceiveResponseOfLastActivity:(NSDate *)lastActivityDate forBuddy:(NSString *)senderJID;
- (void)xmppDomainDidNotReceiveResponseOfLastActivity;

- (void)xmppDomainDidFailCreateRoom:(NSError *)error;
- (void)xmppDomain:(XMPPAdapter *)sender didReceiveMUCPresence:(NSDictionary *)presence;
- (void)xmppDomain:(XMPPAdapter *)sender didCreatedChatRoom:(NSString *)roomID;
- (void)xmppDomain:(XMPPAdapter *)sender didInviteToChatRoom:(NSDictionary *)info;
- (void)xmppDomain:(XMPPAdapter *)sender didFailInviteToChatRoom:(NSDictionary *)info;
- (void)xmppDomain:(XMPPAdapter *)sender didReceiveInvitationToChatRoom:(NSDictionary *)roomInfo;
- (void)xmppDomain:(XMPPAdapter *)sender didJoinChatRoom:(NSDictionary *)roomInfo;
- (void)xmppDomain:(XMPPAdapter *)sender didLeaveChatRoom:(NSDictionary *)roomInfo;
- (void)xmppDomain:(XMPPAdapter *)sender didReceiveMUCMessage:(NSDictionary *)message;

- (void)xmppDomain:(XMPPAdapter *)sender didReceiveMessageError:(NSDictionary *)error;
/* 
 * xmppDomain:didReceiveReceiptResponse:
 * @result receiptInfo is a NSDictionary, contain:
 *  {
 *      "MESSAGE_STATUS" = 12; (see the XMPPDomainFields.h to more status)
 *      "TEXT_MESSAGE_FROM" = "m2uliu910@satay.mooo.com/iOSSatay";
 *      "TEXT_MESSAGE_ID" = dv46IXaj;
 *      "TEXT_MESSAGE_TO" = "d0dvj@satay.mooo.com/iOSSatay";
 *  }
 * @author Daniel
 */
- (void)xmppDomain:(XMPPAdapter *)sender didReceiveReceiptResponse:(NSDictionary *)receiptInfo;
- (void)xmppDomainDidUpdateOwnAvatar:(NSDictionary *)info;
- (void)xmppDomainDidFailUpdateOwnAvatar:(NSDictionary *)error;
- (void)xmppDomainDidUpdateOwnDisplayname:(NSDictionary *)info;
- (void)xmppDomainDidFailUpdateOwnDisplayname:(NSDictionary *)error;
/*
 * xmppDomainDidReceiverVcardUpdate:
 * @result info is a NSDictionary, contain:
 *  {
 *       "AVATAR_IMAGE_DATA" = [NSData *]; = null if not change
 *       "XMPP_USER_DISPLAYNAME" = @"Display Name"; = @"" if not change
 *       "XMPP_USER_JID" = d0dvj@satay.mooo.com;
 *       "TEXT_MESSAGE_DELAYED_DATE" = [NSDate *]; MUST have if update when friend offline
 *  }
 * @author Daniel
 */
- (void)xmppDomainDidReceiverVcardUpdate:(NSDictionary *)info;
- (void)xmppDomainDidSuccessSendFriendRequest:(NSDictionary *)info;
- (void)xmppDomainDidFailSendFriendRequest:(NSDictionary *)info;
- (void)xmppDomainDidDenyARequest:(NSDictionary *)info;
/**
 * xmppDomainDidReceiveSubscriptionRequest:
 * @result requestInfo
 *  {
 *      //
 *  }
 * @autho Daniel
 */
- (void)xmppDomainDidReceiveAddFriendRequest:(NSDictionary *)requestInfo;
- (void)xmppDomainDidReceiveAddFriendApproved:(NSDictionary *)info;
- (void)xmppDomainDidReceiveAddFriendDenied:(NSDictionary *)info;
- (void)xmppDomainDidApprovedFromFriend:(NSDictionary *)info;
- (void)xmppDomainDidDeletedFriendFromJID:(NSString *)fromJID;


@end
