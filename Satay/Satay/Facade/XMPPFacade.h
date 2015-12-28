//
//  XMPPFacade.h
//  Satay
//
//  Created by Daniel Nguyen on 2/4/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XMPPDomain/XMPPDomain.h>

#define kJOIN_FREFIX @"JOIN:"
#define kMUC_MESS_PREFIX @"MUCMESS:"

@interface XMPPFacade : NSObject <XMPPDomainDelegate>{
    NSObject <MyProfileDelegate> *myProfileDelegate;
    NSObject <ContactNotificationDelegate> *contactNotificationDelegate;
    NSObject <ChatListNotificationDelegate> *chatListNotificationDelegate;
    NSObject <AppSettingDelegate> *appSettingDelegate;
    NSMutableArray *joinedGroup;
    NSMutableArray *newestGroups;
}
@property (nonatomic, retain) NSObject* displaynameDelegate;
@property (nonatomic, retain) NSObject* myProfileDelegate;
@property (nonatomic, retain) NSObject* contactNotificationDelegate;
@property (nonatomic, retain) NSObject* chatListNotificationDelegate;
@property (nonatomic, retain) NSObject* appSettingDelegate;
@property (nonatomic, retain) NSMutableArray *joinedGroup;
@property (nonatomic, retain) NSMutableArray *newestGroups;
@property (nonatomic, retain) NSOperationQueue* xmppQueue;

+(XMPPFacade *)share;

-(BOOL)configXMPP;
-(BOOL)configXMPPDefault;
-(BOOL)connectXMPP;
-(void)disconnectXMPP;

/**
 *  Check xmpp connection
 *  @return TRUE if xmpp is connected
 *  Author: Violet
 */
-(BOOL) isXMPPConnected;

/**
 *  @author Daniel Nguyen, 15-05-06 10:05
 *
 *  @brief  Check the XMPP connection
 *
 *  @return TRUE if xmpp is connecting..
 */
- (BOOL)isXMPPConnecting;

- (NSDictionary *)getCurrentConfig;

- (void)sendTextMessage:(NSDictionary *)objMSG;
- (void)sendMessageChatState:(NSDictionary*)stateInfo;
- (void)setMyStatus:(NSString *)text;
- (void)setDisplayName:(NSString *)displayname;
- (NSString *)getDisplayNameForJID:(NSString *)fullJID;
- (void)updateAvatar:(NSData *)imageData;

- (void)sendFriendRequest:(NSDictionary *)objInfo;
- (void)sendFriendApproval:(NSDictionary *)objInfo;
- (void)sendFriendUnapproval:(NSDictionary *)objInfo;
- (void)sendNoticeDeleteFriend:(NSDictionary *)objInfo;

/**
 *  @author Daniel Nguyen, 15-04-27 09:04
 *
 *  @brief  send configuration to bookmark this room, but now we don't uses this. all chat room of user, must be manual call re-join when login
 *
 *  @param roomJID full room jid
 */
- (void)sendBookmarkForRoom:(NSString *)roomJID;

/*
 * add (invite) an user to exist chat room
 * @param infoObj is a NSDictionary object, have MUC_ROOM_JID, MUC_ROOM_PASSWORD, XMPP_MUC_HOST_NAME
 * @author Daniel
 */
- (void)createChatRoom:(NSDictionary *)objInfo;
/*
 * add (invite) an user to exist chat room
 * @param infoObj is a NSDictionary object, have MUC_ROOM_JID, XMPP_MUC_HOST_NAME, XMPP_TO_JID, MUC_ROOM_INVITE_MESSAGE
 * @author Daniel
 */
- (void)addUserToChatRoom:(NSDictionary *)objInfo;
/*
 * join to exist chat room
 * @param infoObj is a NSDictionary object, have kMUC_ROOM_JID, kMUC_ROOM_PASSWORD, kXMPP_USER_DISPLAYNAME
 * @author Daniel
 */
- (void)joinToChatRoom:(NSDictionary *)objInfo;

/**
 *  @author Daniel Nguyen, 15-04-27 10:04
 *
 *  @brief  leave from exist chat room
 *
 *  @param objInfo is a NSDictionary object, have kMUC_ROOM_JID
 */
- (void)leaveChatRoom:(NSDictionary *)objInfo;

/**
 *  @author Daniel Nguyen, 15-04-27 09:04
 *
 *  @brief  kick a membet from a chatroom
 *
 *  @param objInfo has values for keys: {XMPP_TO_JID: full user jid, MUC_ROOM_JID: full room jid}
 */
- (void)kickMemberFromChatRoom:(NSDictionary *)objInfo;

/**
 *  Send last activity query to JID
 *  Author: Violet
 */
-(void) sendLastActivityQueryToJID:(NSString*) JID;

/**
 *  @author Daniel Nguyen, 15-07-24 09:07
 *
 *  @brief  reset the Stream Management to stop current stream - fix the group message still fire to kicked member at a moment after online back and receive notice of kick event
 */
- (void)resetStreamManagement;

@end
