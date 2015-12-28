//
//  XMPPMessage+XEP_XMPPDomain_001.m
//  XMPPDomain
//
//  Created by Daniel Nguyen on 2/3/15.
//  Copyright (c) 2015 mTouche. All rights reserved.
//

#import "XMPPMessage+XEP_XMPPDomain_001.h"
#import "NSXMLElement+XMPP.h"
#import "JSONHelper_XMPP.h"

static NSString *const xmlns_vcardupdate = @"vcard:event:update";

@implementation XMPPMessage (XEP_XMPPDomain_001)

- (BOOL)hasVcardUpdateAvatar
{
    return ([self elementForName:@"avatar" xmlns:xmlns_vcardupdate] != nil);
}

- (BOOL)hasVcardUpdateDisplayname
{
    return ([self elementForName:@"displayname" xmlns:xmlns_vcardupdate] != nil);
}

- (void)addVcardUpdateAvatar
{
    [self addChild:[NSXMLElement elementWithName:@"avatar" xmlns:xmlns_vcardupdate]];
}

- (void)addVcardUpdateDisplayname
{
    [self addChild:[NSXMLElement elementWithName:@"displayname" xmlns:xmlns_vcardupdate]];
}

- (BOOL)isFriendRequest
{
    NSDictionary *bodyDic = (NSDictionary *)[JSONHelper_XMPP decodeJSONToObject:[self body]];
    if ([[bodyDic objectForKey:kXMPP_BODY_MESSAGE_TYPE] isEqualToString:kSUB_BODY_MT_IDEN_XCHANGE_ADD])
    {
        return YES;
    }
    return NO;
}

- (BOOL)isFriendApprove
{
    NSDictionary *bodyDic = (NSDictionary *)[JSONHelper_XMPP decodeJSONToObject:[self body]];
    if ([[bodyDic objectForKey:kXMPP_BODY_MESSAGE_TYPE] isEqualToString:kSUB_BODY_MT_IDEN_XCHANGE_APPROVE])
    {
        return YES;
    }
    return NO;
}

- (BOOL)isFriendDone
{
    NSDictionary *bodyDic = (NSDictionary *)[JSONHelper_XMPP decodeJSONToObject:[self body]];
    if ([[bodyDic objectForKey:kXMPP_BODY_MESSAGE_TYPE] isEqualToString:kSUB_BODY_MT_IDEN_XCHANGE_DONE])
    {
        return YES;
    }
    return NO;
}

- (BOOL)isEncryptedMessage
{
    return NO;
}

- (BOOL)isSatayMessage
{
    NSDictionary *bodyDic = (NSDictionary *)[JSONHelper_XMPP decodeJSONToObject:[self body]];
    if (bodyDic) {
        return YES;
    }
    
    return NO;
}

- (BOOL)isGroupInvite
{
    NSXMLElement *x = [self elementForName:@"x" xmlns:XMPPMUCUserNamespace];
    return (x!=nil);
}

- (NSString *)inviteFromJID
{
    NSXMLElement *invite = [[self elementForName:@"x" xmlns:XMPPMUCUserNamespace] elementForName:@"invite"];
    NSString *fromJID = [[invite attributeForName:@"from"] stringValue];
    // return the jid without resource
    return [[fromJID componentsSeparatedByString:@"/"] objectAtIndex:0];
}

- (NSString *)inviteToJID
{
    NSXMLElement *invite = [[self elementForName:@"x" xmlns:XMPPMUCUserNamespace] elementForName:@"invite"];
    return [[invite attributeForName:@"to"] stringValue];
}

- (NSString *)inviteMessage
{
    NSXMLElement *invite = [self elementForName:@"x" xmlns:XMPPMUCUserNamespace];
    return [invite stringValue];
}

@end

@implementation XMPPElement (XEP_XMPPDomain_001)

- (NSString *)toStrWithoutResource
{
    NSString *tmp = [[[self toStr] componentsSeparatedByString:@"/"] objectAtIndex:0];
    if (!tmp)
        tmp = @"";
    
    return tmp;
}

- (NSString *)fromStrWithoutResource
{
    NSString *tmp = [[[self fromStr] componentsSeparatedByString:@"/"] objectAtIndex:0];
    if (!tmp)
        tmp = @"";
    return tmp;
}

- (NSString *)fromDomain
{
    NSArray *arr = [[self fromStrWithoutResource] componentsSeparatedByString:@"@"];
    if ([arr count] < 2) {
        return @"";
    }
    return [arr objectAtIndex:1];
}

- (NSString *)fromStrResource
{
    if ([[[self fromStr] componentsSeparatedByString:@"/"] count] < 2) {
        return @"";
    }
    return [[[self fromStr] componentsSeparatedByString:@"/"] objectAtIndex:1];
}

@end

@implementation XMPPIQ (XEP_XMPPDomain_001)

- (BOOL)isMUCIQ
{
    return ([self elementForName:@"query" xmlnsPrefix:XMPPMUCNamespace] != nil);
}

@end

@implementation XMPPPing (XEP_XMPPDomain_001)

- (void)replyPongToReceivePingIQ:(XMPPIQ*)iq
{
    //RECV: <iq xmlns="jabber:client" from="ssdevim.mtouche-mobile.com" to="7d6d30ef73e032ed6403750c690bcc1047abeb09@ssdevim.mtouche-mobile.com/ZIPIT CHAT_IOS_1.0" id="2914786091" type="get"><ping xmlns="urn:xmpp:ping"/></iq>
    //SEND: <iq from='7d6d30ef73e032ed6403750c690bcc1047abeb09@ssdevim.mtouche-mobile.com/ZIPIT CHAT_IOS_1.0' to='ssdevim.mtouche-mobile.com' id='2914786091' type='result'/>
    NSXMLElement *ping = [iq elementForName:@"ping" xmlns:@"urn:xmpp:ping"];
    if (ping) {
        XMPPIQ *pong = [XMPPIQ iqWithType:@"result" to:[iq from] elementID:[iq elementID]];
        [xmppStream sendElement:pong];
    }
}

@end