//
//  XMPPManager.m
//  XMPPDomain
//
//  Created by Daniel Nguyen on 12/30/14.
//  Copyright (c) 2014 mTouche. All rights reserved.
//

#import "XMPPManager.h"
#import "NSString+Utils.h"
#import "JSONHelper_XMPP.h"
#import "XMPPDomainFields.h"

@implementation XMPPManager
@synthesize stringJsonOfflineGroupMessage;

NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";

+ (XMPPManager *)share
{
    static dispatch_once_t once;
    static XMPPManager * share;
    dispatch_once(&once, ^{
        share = [self new];
        share.stringJsonOfflineGroupMessage = [NSString new];
    });
    return share;
}

- (NSString *) generateMessageId
{
    NSMutableString *randomString = [NSMutableString stringWithCapacity: 10];
    for (int i=0; i<10; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random_uniform((int)[letters length])]];
    }
    return randomString;
}

- (void) sendMessageReadStatus:(NSDictionary *)objData{
    NSLog(@"sendMessageReadStatus %@",objData);
    //
    /* the objData
     NSString *receiptType = isSingleChat?@"SR":@"GR";
     NSDictionary *dictParam = [NSDictionary dictionaryWithObjectsAndKeys:
     chatMessage.from_jid, @"JID",
     chatMessage.msg_id, @"MSG_ID",
     receiptType, @"RECEIPT_TYPE",nil];
     */
//    NSString* toUser = @"";
//    NSString* msgID = [NSString stringWithFormat:@"%@:%@", toUser, [[NSString getCurrentTime] MD5String]];//[conCatString3(toUser, @":", [NSString getCurrentTime]) MD5String];
//    
//    NSDictionary *command = [NSDictionary dictionaryWithObjectsAndKeys:
//                             @"rc", @"mt",
//                             [objData objectForKey:@"JID"], JSON_MESSAGE_JID,
//                             [objData objectForKey:@"MSG_ID"], JSON_MESSAGE_ID,
//                             [objData objectForKey:@"RECEIPT_TYPE"], JSON_MESSAGE_RECEIPT_TYPE,
//                             @"0",JSON_MESSAGE_TYPE_READ_FLAG,
//                             nil];
//    
//    NSString* MessageTextJSON = [JSONHelper encodeObjectToJSON:command];
//    
//    NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
//    [body setStringValue:MessageTextJSON];
//    
//    NSXMLElement *message = [NSXMLElement elementWithName:@"message"];
//    [message addAttributeWithName:@"type" stringValue:@"chat"];
//    [message addAttributeWithName:@"to" stringValue:toUser];
//    [message addAttributeWithName:@"from" stringValue:conCatString3([[DaoHandler share] getUDValueByKey:JID], @"@",XMPP_HOST_NAME)];
//    [message addAttributeWithName:@"id" stringValue:msgID];
//    [message addChild:body];
//    
//    if([[AppDelegate share].xmppStream isConnected])
//    {
//        if (chatView.isSingleChat) {
//            [[AppDelegate share] sendMessage:message setReceiptID:msgID];
//            [[DaoHandler share] updateMessageNotifyWithMessageID:[objData objectForKey:@"MSG_ID"] Notify:MESSAGE_NOTIFY_READ];
//        }
//    }
}

- (void) sendGroupChatReadStatus:(XMPPDomainMessageDO *)messageData{
    //
}

- (BOOL) sendFriendApproval:(NSDictionary *)objInfo{
    NSLog(@"objInfo = %@",objInfo);
    
    //
    return YES;
}

//This method is for send  presence friend request
- (void) sendRequestSubscribeToJID:(NSString *)toJID inXMPPStream:(XMPPStream *)xmppStream
{
    XMPPPresence *response = [XMPPPresence presenceWithType:@"subscribe" to:[XMPPJID jidWithString:toJID]];
    [xmppStream sendElement:response];
}
//This method is for send presence Approved friend request comfirm
- (void) sendApprovedSubscribedToJID:(NSString *)toJID inXMPPStream:(XMPPStream *)xmppStream
{
    XMPPPresence *response = [XMPPPresence presenceWithType:@"subscribed" to:[XMPPJID jidWithString:toJID]];
    [xmppStream sendElement:response];
}
//This method is for send presence delete friend
- (void) sendRequestUnsubscribeToJID:(NSString *)toJID inXMPPStream:(XMPPStream *)xmppStream
{
    XMPPPresence *response = [XMPPPresence presenceWithType:@"unsubscribe" to:[XMPPJID jidWithString:toJID]];
    [xmppStream sendElement:response];
}
//This method is for send presence to confirm delete friend success
- (void) sendApprovedUnsubscribedToJID:(NSString *)toJID inXMPPStream:(XMPPStream *)xmppStream
{
    XMPPPresence *response = [XMPPPresence presenceWithType:@"unsubscribed" to:[XMPPJID jidWithString:toJID]];
    [xmppStream sendElement:response];
}

- (void) sendXMPPandStoreDB:(NSDictionary *)XMPPCommand Message:(NSString *)strMessage DBType:(NSString *)DBType{
    //
}


// Send Location
- (void) sendLocation{
    //
}


// Send Composing chat state
- (void)sendComposingChatStateFrom:(NSString *)fromJID toJID:(NSString *)toJID inXMPPStream:(XMPPStream *)xmppStream withState:(int)state
{
    NSString *msgID = [NSString stringWithFormat:@"%@:%@", toJID, [[NSString getCurrentTime] MD5String]];

    XMPPMessage *chatStateMessage = [XMPPMessage message];
    [chatStateMessage addAttributeWithName:@"to" stringValue:toJID];
    [chatStateMessage addAttributeWithName:@"type" stringValue:@"chat"];
    [chatStateMessage addAttributeWithName:@"from" stringValue:fromJID];
    [chatStateMessage addAttributeWithName:@"id" stringValue:msgID];
    switch (state) {
        case kCHAT_STATE_TYPE_ACTIVE:
            [chatStateMessage addActiveChatState];
            break;
        case kCHAT_STATE_TYPE_COMPOSING:
            [chatStateMessage addComposingChatState];
            break;
        case kCHAT_STATE_TYPE_GONE:
            [chatStateMessage addGoneChatState];
            break;
        case kCHAT_STATE_TYPE_INACTIVE:
            [chatStateMessage addInactiveChatState];
            break;
        case kCHAT_STATE_TYPE_PAUSED:
            [chatStateMessage addPausedChatState];
            break;
            
        default:
            break;
    }
    
    if ([xmppStream isConnected]) {
        [xmppStream sendElement:chatStateMessage];
    }
    
    [self performSelector:@selector(resetChatStateSending) withObject:nil afterDelay:5.0f];
}

- (void) resetChatStateSending{
    //
}

- (void) vibratePhone{
    //
}
+ (BOOL) hasRequestReadStatus:(NSDictionary *)dIncomingMessage{
    
    //
    return NO;
}
+ (void) presentLocalNotification:(NSString *)message isGroupAlert:(BOOL)isGroupAlert{
    //
}

- (void)sendUpdateVcardEventFrom:(NSString *)fromJID toJID:(NSString *)toJID inXMPPStream:(XMPPStream *)xmppStream withType:(int)type
{
    NSString *msgID = [[NSString stringWithFormat:@"%@:%@", [self generateMessageId], [NSString getCurrentTime]] MD5String];
    
    XMPPMessage *updateVcardMessage = [XMPPMessage message];
    [updateVcardMessage addAttributeWithName:@"to" stringValue:toJID];
    [updateVcardMessage addAttributeWithName:@"type" stringValue:@"chat"];
    [updateVcardMessage addAttributeWithName:@"from" stringValue:fromJID];
    [updateVcardMessage addAttributeWithName:@"id" stringValue:msgID];
    switch (type) {
        case kVCARD_UPDATE_AVATAR:
            [updateVcardMessage addVcardUpdateAvatar];
            break;
        case kVCARD_UPDATE_DISPLAYNAME:
            [updateVcardMessage addVcardUpdateDisplayname];
            break;
            
        default:
            break;
    }
    
    if ([xmppStream isConnected]) {
        [xmppStream sendElement:updateVcardMessage];
    }
}

////////////////////////////////////////////////////////////////////////////////////
#pragma mark Incoming Message Processes
////////////////////////////////////////////////////////////////////////////////////
- (NSDictionary *) handleChatStateMessage:(XMPPMessage *)message{
    if ([message wasDelayed]) {
        return nil;
    }
    NSString* from = [message fromStrWithoutResource];
    NSString *state = nil;
    int stateNumber = 0;
    
    if ([message hasComposingChatState]) {
        state = kCHAT_STATE_TYPE_COMPOSING_STRING;
        stateNumber = kCHAT_STATE_TYPE_COMPOSING;
    }
    
    if ([message hasPausedChatState]) {
        state = kCHAT_STATE_TYPE_PAUSED_STRING;
        stateNumber = kCHAT_STATE_TYPE_PAUSED;
    }
    
    if ([message hasActiveChatState]) {
        state = kCHAT_STATE_TYPE_ACTIVE_STRING;
        stateNumber = kCHAT_STATE_TYPE_ACTIVE;
    }
    
    if ([message hasGoneChatState]) {
        state = kCHAT_STATE_TYPE_GONE_STRING;
        stateNumber = kCHAT_STATE_TYPE_GONE;
    }
    
    if (state) {
        NSDictionary *userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:from,kCHAT_STATE_FROM_JID,
                                                                              state,kCHAT_STATE_TYPE,
                                                                              [NSString stringWithFormat:@"%d", stateNumber],kCHAT_STATE_TYPE_NUMBER,nil];
        return userInfo;
    }
    
    return nil;
}

- (NSDictionary *)handleChatTextMessage:(XMPPMessage *)message
{
    if (![message body]) {
        return nil;// no body, no deal
    }
    NSString *msg = [message body];//[[message elementForName:@"body"] stringValue];
    NSString *from = [message fromStrWithoutResource];//[[message attributeForName:@"from"] stringValue];
    
    NSMutableDictionary *m = [[NSMutableDictionary alloc] init];
    [m setObject:msg forKey:kTEXT_MESSAGE_BODY];
    [m setObject:from forKey:kTEXT_MESSAGE_FROM];
    [m setObject:[[message attributeForName:@"id"] stringValue] forKey:kTEXT_MESSAGE_ID];
    [m setObject:@"chat" forKey:kTEXT_MESSAGE_TYPE];
    
    if ([message wasDelayed] && [message delayedDeliveryDate])
    {
        [m setObject:[message delayedDeliveryDate] forKey:kTEXT_MESSAGE_DELAYED_DATE];
    }
    
    return m;
}

- (NSDictionary *)handleReceiptResponseMessage:(XMPPMessage *)message{
    NSXMLElement *receiptResponse = [message elementForName:@"received" xmlns:@"urn:xmpp:receipts"];
    NSString *messageID = [receiptResponse attributeStringValueForName:@"id"];
    NSString *fromJID   = [message attributeStringValueForName:@"from"];
    NSRange range = [messageID rangeOfString:fromJID];
    if (range.location != NSNotFound) {
        return nil;
    }
    NSString *toJID     = [message attributeStringValueForName:@"to"];
    NSMutableDictionary *m = [[NSMutableDictionary alloc] init];
    [m setObject:fromJID forKey:kTEXT_MESSAGE_FROM];
    [m setObject:toJID forKey:kTEXT_MESSAGE_TO];
    [m setObject:messageID forKey:kTEXT_MESSAGE_ID];
    [m setObject:kMESSAGE_STATUS_RECEIVED forKey:kMESSAGE_STATUS];
    
    return m;
}

- (NSDictionary *)handleErrorWhenSendMessage:(XMPPMessage *)errorMessage
{
    if ([errorMessage isErrorMessage]) {
        NSError *error = [errorMessage errorMessage];
        NSString *from = [[errorMessage attributeForName:@"from"] stringValue];
        NSMutableDictionary *m = [[NSMutableDictionary alloc] init];
        if (from) {
            [m setObject:from forKey:kTEXT_MESSAGE_FROM];
        }
        if (error) {
            [m setObject:error forKey:kTEXT_MESSAGE_ERROR];
        }
        if ([errorMessage elementID]) {
            [m setObject:[errorMessage elementID] forKey:kTEXT_MESSAGE_ID];
        }
        
        return m;
        
    } else {
        return nil;
    }
    
    return nil;
}

- (void) processIncomingReadRecept:(NSDictionary *)dIncomingMessage RawData:(XMPPMessage *)message{
    //
}

- (void) processIncomingMessage:(NSDictionary *)dIncomingMessage RawData:(XMPPMessage *)message{
    NSLog(@"dIncomingMessage %@", dIncomingMessage);
    
    //
}

- (void) processIncomingAudioWithMessage:(NSDictionary *)dIncomingMessage RawData:(XMPPMessage *)message{
    /*
     1. parse message
     2. create message
     3. download audio file to cachePath
     4. download complete > decrypted message > re-save original file.
     5. updating cell.
     */
    
    //
}

- (void) processIncomingImageWithMessage:(NSDictionary *)dIncomingMessage RawData:(XMPPMessage *)message{
    //
}

- (void) processIncomingVideoWithMessage:(NSDictionary *)dIncomingMessage RawData:(XMPPMessage *)message{
    //
}

- (void) processIncomingRoomNotificationWithMessage:(NSDictionary *)dIncomingMessage RawData:(XMPPMessage *)message{
    //
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void) processOffMessGroup{
    
    @synchronized(stringJsonOfflineGroupMessage) {
        //DDLogCInfo(@"processOffMessGroup invoked");
        //DDLogCInfo(@"arr %@", arrOfflineGroupMessage);
        NSMutableArray* arrOfflineGroupMessage = [JSONHelper_XMPP decodeJSONToObject:stringJsonOfflineGroupMessage];
        if([arrOfflineGroupMessage count] == 0){
            return;
        }
        
        for (NSDictionary* offMessage in arrOfflineGroupMessage) {
            NSLog(@"arr %@", offMessage);
        }
        
        [self performSelector:@selector(processOffMessGroup) withObject:nil afterDelay:15.0];
        [arrOfflineGroupMessage removeAllObjects];
    }
}

- (BOOL)checkISContainMessage:(NSDictionary *)dicMessage
{
    NSMutableArray* arrOfflineGroupMessage = [JSONHelper_XMPP decodeJSONToObject:stringJsonOfflineGroupMessage];
    for (NSDictionary* message in arrOfflineGroupMessage) {
        if ([message[@"MESSAGE_ID"] isEqualToString:dicMessage[@"MESSAGE_ID"]]) {
            [arrOfflineGroupMessage removeAllObjects];
            return YES;
        }
    }
    [arrOfflineGroupMessage removeAllObjects];
    return NO;
}

@end
