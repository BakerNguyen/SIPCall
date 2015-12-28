//
//  SIPFacade.m
//  SIPDemo
//
//  Created by Ba (Baker) V. NGUYEN on 5/4/15.
//  Copyright (c) 2015 mTouche. All rights reserved.
//

#import "SIPFacade.h"
#import <SIPDomain/SIPDomain.h>

@implementation SIPFacade
@synthesize SIPDelegate;

+(SIPFacade *)share {
    static dispatch_once_t once;
    static SIPFacade * share;
    dispatch_once(&once, ^{
        share = [self new];
    });
    return share;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [SIPAdapter share].SIPDomainDelegate = self;
    }
    return self;
}

- (void) addProxyConfig:(NSString *)username password:(NSString *)password domain:(NSString *)domain port:(int)port stunServer:(NSString *)stunServer {
    [[SIPAdapter share] addProxyConfig:username password:password domain:domain port:port stunServer:stunServer];
}

- (void) makeAudioPhoneCall:(NSString *)address {
    [[SIPAdapter share] makeAudioPhoneCall:address];
}

- (void) acceptCall {
    [[SIPAdapter share] acceptCall];
}

- (void) endCall {
    [[SIPAdapter share] endCall];
}

- (void) registrationUpdateNotification {
    [[SIPAdapter share] registrationUpdateNotification];
}

- (void) removeRegistrationUpdateNotification {
    [[SIPAdapter share] removeRegistrationUpdateNotification];
}

- (void) linphoneCallStateNotification {
    [[SIPAdapter share] linphoneCallStateNotification];
}

- (void) removeLinphoneCallStateNotification {
    [[SIPAdapter share] removeLinphoneCallStateNotification];
}

-(void) linphoneCallState:(NSString *)callState message:(NSString *)message {
    [SIPDelegate linphoneCallState:callState message:message];
}

-(void) linphoneRegistrationState:(NSString *)registrationState {
    [SIPDelegate linphoneRegistrationState:registrationState];
}

-(void) linphoneTextReceivedEvent:(NSString *)textReceived {
    [SIPDelegate linphoneTextReceivedEvent:textReceived];
}

@end
