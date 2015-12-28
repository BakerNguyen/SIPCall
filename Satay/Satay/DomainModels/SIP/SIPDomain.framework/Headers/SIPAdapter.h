//
//  SIPAdapter.h
//  SIPDomain
//
//  Created by Daniel Nguyen on 4/13/15.
//  Copyright (c) 2015 mTouche. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SIPDomainDelegate

@optional
-(void) linphoneCallState:(NSString*) callState message:(NSString*) message;
-(void) linphoneRegistrationState:(NSString*) registrationState;
-(void) linphoneTextReceivedEvent:(NSString*) textReceived;
@end

@interface SIPAdapter : NSObject {
        NSObject <SIPDomainDelegate> *SIPDomainDelegate;
}

@property (nonatomic, retain) NSObject* SIPDomainDelegate;

+ (SIPAdapter*) share;

/*
 * Add proxy config and register to server
 * @parameter is NSString
 * @author Baker
 */
- (void) addProxyConfig:(NSString*)username password:(NSString*)password domain:(NSString*)domain port:(int)port stunServer:(NSString*) stunServer;

/*
 * unregister to server
 * @parameter is NSString
 * @author Baker
 */
- (void) unregistration;

/*
 * Make call for friend
 * @parameter address is NSString, address of your friend, ex: sip:baker@sip.linphone.corg
 * @auther Baker
 */
- (void) makeAudioPhoneCall:(NSString*) address;

/*
 * Check register on server
 * Return Yes or NO
 * @auther Baker
 */
- (BOOL) checkProxyConfigIsRegistered;

/*
 * Accept call
 * @auther Baker
 *
 */
- (void) acceptCall;

/*
 * Decline call
 * @auther Baker
 *
 */
- (void) declineCall;

/*
 * End Call
 * @Auther Baker
 */
-(void) endCall;

/*
 * Return quality of current call
 * Return float 
 * 0-1 = can't be worse, mostly unusable, 1-2 = very poor quality, 2-3 = poor quality, 3-4 = average quality, 4-5 = good quality
 * @auther Baker
 */
- (float) qualityOfCall;
    
/*
 * Mute micro
 * Parameter bool, Yes or NO
 * @auther Baker
 */
- (void) muteMicro:(BOOL) enable;

/*
 * Speaker
 * Parameter bool, Yes or NO
 * @auther Baker
 */
- (void) Speaker:(BOOL) enable;

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
 * send ping pong
 * @auther Baker
 */
- (void) sendPingPongMessage:(NSString*) sip_address type:(NSString*) type message:(NSString*) message;

/*
 * textReceivedNotification
 * @author Baker
 */
- (void) textReceivedNotification;

/*
 * remove textReceivedNotification
 * @author Baker
 */
- (void) removetextReceivedNotification;

/*
 * get caller adress
 * return address of caller
 * @auther Baker
 */
- (NSString*) getLinphoneAddress;

/*
 * set timeout for sip
 * return address of caller
 * @auther Baker
 */
- (void) linphoneSetTimeout:(int) duration;

/*
 * linphoneCallSecurityUpdate
 * Call this function by NSTimer
 * @author Baker
 */
- (void) linphoneCallSecurityUpdate;

#pragma mark - APIs Calling -
typedef void (^requestCompleteBlock)(BOOL success, NSString *message ,NSDictionary *response, NSError *error);

/**
 * get SIP Call Status in server tenant
 * @author Daniel
 * @parameter parametersDic must have value for keys: MASKINGID, IMSI, IMEI, TOKEN, CMD (Its value must be fixed string - "STATUS"), TRANSACTIONID
 * @callback with response include: {"STATUS_CODE":0,"STATUS_MSG":"Success","SUCCESS":true,"DATA":{"STATUS":2}}
 */
- (void) getSIPCallStatus:(NSDictionary *)parametersDic callback:(requestCompleteBlock)callback;

///**
// * updateSIPCall in server central
// * @author Daniel
// * @parameter parametersDic must have value for keys: xxx
// * @callback with response include: xxx
// */
//- (void) updateSIPCall:(NSDictionary *)parametersDic callback:(requestCompleteBlock)callback;

/**
 * make SIP Call in server tenant
 * @author Baker
 * @parameter parametersDic must have value for keys: CALLERMASKINGID, IMSI, IMEI, TOKEN, RECIPIENTMASKINGID, TYPE (Its value must be fixed string - "SIP"), CMD (Its value must be fixed string - "CALL"), TRANSACTIONID
 * @callback with response include: {"STATUS_CODE":0,"STATUS_MSG":"Success","SUCCESS":true,"DATA":{"FIRSTDELAY":1000,"DELAY":1000,"FREQUENCY":20}}
 */
- (void) makeSIPCallAPI:(NSDictionary *)parametersDic callback:(requestCompleteBlock)callback;

/**
 * update SIP Call Status in server tenant (only for receiver)
 * @author Baker
 * @parameter parametersDic must have value for keys: RECIPIENTMASKINGID, IMSI, IMEI, TOKEN, CALLERMASKINGID, CMD (Its value must be fixed string - "ANSWER" or "READY"), TRANSACTIONID
 * @callback with response include: {"STATUS_CODE":0,"STATUS_MSG":"Success","SUCCESS":true,"DATA":{"CALLERJID":"dqbuxir@snim.mtouche- mobile.com","CALLERNAME":"Vko0Rlc4RUs=","CALLTIMEOUT":30000}
 */
- (void) updateReadyStatusSIPAPI:(NSDictionary *)parametersDic callback:(requestCompleteBlock)callback;

/**
 * update Fail status SIP Call in server tenant
 * @author Baker
 * @parameter parametersDic must have value for keys: MASKINGID, CALLERMASKINGID, IMSI, IMEI, TOKEN, RECIPIENTMASKINGID, REMARKS, CMD (Its value must be fixed string - "FAIL"), TRANSACTIONID
 * @callback with response include: {"STATUS_CODE":0,"STATUS_MSG":"Success","SUCCESS":true}
 */
- (void) updateFailStatusSIPAPI:(NSDictionary *)parametersDic callback:(requestCompleteBlock)callback;

/**
 * update End status SIP Call in server tenant
 * @author Baker
 * @parameter parametersDic must have value for keys: MASKINGID, IMSI, IMEI, TOKEN, REMARKS,  DURATION, CMD (Its value must be fixed string - "END"), TRANSACTIONID
 * @callback with response include: {"STATUS_CODE":0,"STATUS_MSG":"Success","SUCCESS":true}
 */
- (void) updateEndStatusSIPAPI:(NSDictionary *)parametersDic callback:(requestCompleteBlock)callback;

/**
 * update TimeOut status SIP Call in server tenant
 * @author Baker
 * @parameter parametersDic must have value for keys: MASKINGID, IMSI, IMEI, TOKEN, REMARKS, CMD (Its value must be fixed string - "END"), TRANSACTIONID
 * @callback with response include: {"STATUS_CODE":0,"STATUS_MSG":"Success","SUCCESS":true}
 */
- (void) updateTimeOutStatusSIPAPI:(NSDictionary *)parametersDic callback:(requestCompleteBlock)callback;

@end
