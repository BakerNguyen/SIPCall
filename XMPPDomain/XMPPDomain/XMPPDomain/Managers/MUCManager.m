//
//  MUCManager.m
//  XMPPDomain
//
//  Created by Daniel Nguyen on 1/28/15.
//  Copyright (c) 2015 mTouche. All rights reserved.
//

#import "MUCManager.h"
#import "XMPPDomainFields.h"

@implementation MUCManager

+ (MUCManager *)share
{
    static dispatch_once_t once;
    static MUCManager * share;
    dispatch_once(&once, ^{
        share = [self new];
        
    });
    return share;
}

- (NSDictionary *)processGroupMessage:(XMPPMessage *)message
{
    //<message xmlns="jabber:client" from="1551cb467227a91551cb467227ff@conference.satay.mooo.com/af4bg2at@satay.mooo.com" to="aluqvs@satay.mooo.com/iOS_TEST" type="groupchat" id="cR1lW4mV"><body>ENC$#$3Owq1Cou4AV1++GGYPVGCKtVRg5qVLRBDMXRvdp8E5kEC8jsXyjyZf2KVOseSV2D$#$^%^551cb469d0a58</body><request xmlns="urn:xmpp:receipts"/></message>
    
    NSString *strBody = [message body];
    NSString *strFrom = [message fromStrWithoutResource] ? [message fromStrWithoutResource] : @"";
    NSString *strFromUser = [message fromStrResource] ? [message fromStrResource] : @"";
    NSString *strID = [[message attributeForName:@"id"] stringValue];
    
    if (!strBody || !strID) {
        return nil;
    }
    
    NSMutableDictionary *m = [[NSMutableDictionary alloc] init];
    [m setObject:strBody forKey:kTEXT_MESSAGE_BODY];
    [m setObject:strFromUser forKey:kTEXT_MESSAGE_FROM];
    [m setObject:strFrom forKey:kMUC_ROOM_JID];
    [m setObject:strID forKey:kTEXT_MESSAGE_ID];
    [m setObject:@"groupchat" forKey:kTEXT_MESSAGE_TYPE];
    
    if ([message wasDelayed])
    {
        [m setObject:[message delayedDeliveryDate] forKey:kTEXT_MESSAGE_DELAYED_DATE];
    }
    
    return m;
}

- (void)processIncomingRoomImageWithMessage:(NSDictionary *)dIncomingMessage Data:(NSDictionary *)objData
{
    //
}

- (void)processIncomingRoomVideoWithMessage:(NSDictionary *)dIncomingMessage Data:(NSDictionary *)objData
{
    //
}

- (void)processIncomingRoomAudioWithMessage:(NSDictionary *)dIncomingMessage Data:(NSDictionary *)objData
{
    //
}

@end
