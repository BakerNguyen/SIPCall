//
//  XMPPMessage+XEP_XMPPDomain_001.h
//  XMPPDomain
//
//  Created by Daniel Nguyen on 2/3/15.
//  Copyright (c) 2015 mTouche. All rights reserved.
//

#import <XMPPDomain/XMPPDomain.h>

@interface XMPPMessage (XEP_XMPPDomain_001)

- (BOOL)hasVcardUpdateAvatar;
- (BOOL)hasVcardUpdateDisplayname;
- (void)addVcardUpdateAvatar;
- (void)addVcardUpdateDisplayname;
- (BOOL)isFriendRequest;
- (BOOL)isFriendApprove;
- (BOOL)isFriendDone;
- (BOOL)isEncryptedMessage;
- (BOOL)isSatayMessage;
- (BOOL)isGroupInvite;
- (NSString *)inviteFromJID;
- (NSString *)inviteToJID;
- (NSString *)inviteMessage;

@end

@interface XMPPElement (XEP_XMPPDomain_001)

- (NSString *)toStrWithoutResource;
- (NSString *)fromStrWithoutResource;
- (NSString *)fromDomain;
- (NSString *)fromStrResource;

@end

@interface XMPPIQ (XEP_XMPPDomain_001)

- (BOOL)isMUCIQ;

@end

@interface XMPPPing (XEP_XMPPDomain_001)

- (void)replyPongToReceivePingIQ:(XMPPIQ*)iq;

@end