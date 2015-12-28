//
//  XMPPManager.h
//  XMPPDomain
//
//  Created by Daniel Nguyen on 12/30/14.
//  Copyright (c) 2014 mTouche. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMPPDomainMessageDO.h"
#include "XMPPFramework.h"

@interface XMPPManager : NSObject

@property (nonatomic, retain) NSString* stringJsonOfflineGroupMessage;

+ (XMPPManager *)share;
- (void)sendMessageReadStatus:(NSDictionary *)objData;
- (void)sendXMPPandStoreDB:(NSDictionary *)XMPPCommand Message:(NSString *)strMessage DBType:(NSString *)DBType;
- (void)sendLocation;
- (void)sendComposingChatStateFrom:(NSString *)fromJID toJID:(NSString *)toJID inXMPPStream:(XMPPStream *)xmppStream withState:(int)state;
- (void)resetChatStateSending;
- (void)vibratePhone;
+ (BOOL)hasRequestReadStatus:(NSDictionary *)dIncomingMessage;
- (void)sendGroupChatReadStatus:(XMPPDomainMessageDO *)messageData;
+ (void)presentLocalNotification:(NSString *)message isGroupAlert:(BOOL)isGroupAlert;

- (BOOL)sendFriendApproval:(NSDictionary *)objInfo;

- (void)sendRequestSubscribeToJID:(NSString *)toJID inXMPPStream:(XMPPStream *)xmppStream;
- (void)sendApprovedSubscribedToJID:(NSString *)toJID inXMPPStream:(XMPPStream *)xmppStream;
- (void)sendRequestUnsubscribeToJID:(NSString *)toJID inXMPPStream:(XMPPStream *)xmppStream;
- (void)sendApprovedUnsubscribedToJID:(NSString *)toJID inXMPPStream:(XMPPStream *)xmppStream;

- (void)sendUpdateVcardEventFrom:(NSString *)fromJID toJID:(NSString *)toJID inXMPPStream:(XMPPStream *)xmppStream withType:(int)type;

//Single xmpp
- (NSDictionary *)handleChatStateMessage:(XMPPMessage *)message;
- (NSDictionary *)handleChatTextMessage:(XMPPMessage *)message;
- (NSDictionary *)handleReceiptResponseMessage:(XMPPMessage *)message;
- (NSDictionary *)handleErrorWhenSendMessage:(XMPPMessage *)errorMessage;
- (void)processIncomingReadRecept:(NSDictionary *)dIncomingMessage RawData:(XMPPMessage *)message;
- (void)processIncomingMessage:(NSDictionary *)dIncomingMessage RawData:(XMPPMessage *)message;
- (void)processIncomingAudioWithMessage:(NSDictionary *)dIncomingMessage RawData:(XMPPMessage *)message;
- (void)processIncomingImageWithMessage:(NSDictionary *)dIncomingMessage RawData:(XMPPMessage *)message;
- (void)processIncomingVideoWithMessage:(NSDictionary *)dIncomingMessage RawData:(XMPPMessage *)message;
- (void)processIncomingRoomNotificationWithMessage:(NSDictionary *)dIncomingMessage RawData:(XMPPMessage *)message;

//Group xmpp
- (void)processOffMessGroup;

@end
