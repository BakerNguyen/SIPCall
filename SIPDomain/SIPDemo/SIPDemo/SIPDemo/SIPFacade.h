//
//  SIPFacade.h
//  SIPDemo
//
//  Created by Ba (Baker) V. NGUYEN on 5/4/15.
//  Copyright (c) 2015 mTouche. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SIPDomain/SIPDomain.h>
#import "UIDelegate.h"

#define SIP_USERNAME_PREFIX @"KC_"
#define SIP_PORT 5060
#define SIP_DOMAIN @"sip.linphone.org"
#define STUN_DOMAIN @""
#define STUN_PORT 3478
#define SIP_TIME_LEFT 120

@interface SIPFacade : NSObject <SIPDomainDelegate> {
    NSObject <SIPDelegate> *SIPDelegate;
}

@property (nonatomic, retain) NSObject* SIPDelegate;

+(SIPFacade *)share;

/*
 * Add proxy config and register to server
 * @parameter is NSString
 * @author Baker
 */
- (void) addProxyConfig:(NSString*)username password:(NSString*)password domain:(NSString*)domain port:(int)port stunServer:(NSString*) stunServer;

/*
 * Make call for friend
 * @parameter address is NSString, address of your friend, ex: sip:baker@sip.linphone.corg
 * @auther Baker
 */
- (void) makeAudioPhoneCall:(NSString*) address;

/*
 * Accept call
 * @auther Baker
 *
 */
- (void) acceptCall;

/*
 * End Call
 * @Auther Baker
 */
-(void) endCall;

/*
 * registrationUpdateNotification
 * get status when we register sip
 * @author Baker
 */
- (void) registrationUpdateNotification;

/*
 * Remove RegistrationUpdateNotification
 * @auther Baker
 */
- (void) removeRegistrationUpdateNotification;

/*
 * Get status of incomming call
 * @auther Baker
 */
- (void) linphoneCallStateNotification;

/*
 * Remove LinphoneCallStateNotification
 * @auther Baker
 */
- (void) removeLinphoneCallStateNotification;


@end
