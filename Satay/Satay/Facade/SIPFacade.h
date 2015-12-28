//
//  SIPFacade.h
//  Satay
//
//  Created by Ba (Baker) V. NGUYEN on 5/5/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SIPDomain/SIPDomain.h>

#define SIP_MASKINGID @"MASKINGID"
#define SIP_CALLER_MASKINGID @"CALLERMASKINGID"
#define SIP_RECIPIENT_MASKINGID @"RECIPIENTMASKINGID"
#define SIP_TYPE @"TYPE"
#define SIP_CMD @"CMD"
#define SIP_TRANSACTIONID @"TRANSACTIONID"
#define SIP_DURATION @"DURATION"
#define SIP_REMARKS @"REMARKS"

#define SIP_USERNAME_PREFIX @"SS_"
#define SIP_PORT 5060
#define SIP_DOMAIN @"sataydevsip.mtouche-mobile.com;transport=tls"
#define STUN_DOMAIN @""
#define STUN_PORT 3478
#define SIP_TIME_LEFT 120

#define kSIP_MESSAGE @"SIP_MESSAGE"
#define kSIP_JID @"SIP_JID"
#define kSIP_MESSAGE_TYPE_CT @"SIP"
#define kSIP_DELAYED @"SIP_DELAYED"
#define kSIP_IS_ME @"SIP_IS_ME"
#define kSIP_STATUS @"SIP_STATUS"

#define SIP_CODE_END @"400"
#define SIP_CODE_BUSY @"300"

typedef enum {
    SIPCallStatusNoAnswer,
    SIPCallStatusCancelled,
    SIPCallStatusMissed,
    SIPCallStatusCallFailed,
    SIPCallStatusCallBusy,
    SIPCallStatusCallOk
} SIPCallStatus;

//How to detect call incoming programmatically
#import <CoreTelephony/CTCallCenter.h>
#import <CoreTelephony/CTCall.h>

@interface SIPFacade : NSObject <SIPDomainDelegate> {
    NSObject <SIPDelegate> *SIPDelegate;
    NSObject <ChatViewDelegate> *chatViewDelegate;
    NSObject <ChatListDelegate> *chatListDelegate;
    NSObject <ChatComposeDelegate> *chatComposeDelegate;
    NSObject <ContactListDelegate> *contactListDelegate;
    NSObject <ContactBookDelegate> *contactBookDelegate;
    NSObject <EmailInboxDelegate> *emailInboxDelegate;
    NSObject <SideBarDelegate> *sideBarDelegate;
    NSObject <VoiceCallViewDelegate> *voiceCallViewDelegate;
    NSObject <InitIncomingCallViewDelegate> *initIncomingCallViewDelegate;
}

@property (nonatomic, retain) NSObject* SIPDelegate;
@property (nonatomic, retain) NSObject *chatViewDelegate;
@property (nonatomic, retain) NSObject *chatListDelegate;
@property (nonatomic, retain) NSObject *chatComposeDelegate;
@property (nonatomic, retain) NSObject *contactListDelegate;
@property (nonatomic, retain) NSObject *contactBookDelegate;
@property (nonatomic, retain) NSObject *emailInboxDelegate;
@property (nonatomic, retain) NSObject *sideBarDelegate;
@property (nonatomic, retain) NSObject *voiceCallViewDelegate;
@property (nonatomic, retain) NSObject *initIncomingCallViewDelegate;

@property (nonatomic, assign) BOOL isCalling, isOnCall, isEndCall, isBusy, isMinimize, isTimeOutView, isInitLinphoneCore, isWhoMakeCall, isMissCalled;
@property (nonatomic, strong) NSString *friend_Jid, *chatboxID;
@property (nonatomic, strong) CTCallCenter* phoneCallCenter;

@property int minutes, seconds;

+(SIPFacade *)share;

/*****/
- (void) checkProxyConfig;
- (void) startCall;
- (void) callAPI_makeCall;
- (void) setStatusOfCall:(BOOL) isStart;
///////

/*
 * Regiter sip account
 */
- (void) registerSIPAccount;

/*
 * Init Incoming Call view
 */
- (void) initIncomingCallView:(NSString*) trans JID:(NSString*) jid;

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
 * Check register on server
 * Return Yes or NO
 * @auther Baker
 */
- (BOOL) checkProxyConfigIsRegistered;

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
 * send ping pong
 * @auther Baker
 */
- (void) sendPingPongMessage:(NSString*) sip_address type:(NSString*) type message:(NSString*) message;

/*
 * set timeout for sip
 * return address of caller
 * @auther Baker
 */
- (void) linphoneSetTimeout:(int) duration;

/*
 * set marking id of friend
 * @auther Baker
 */
-(void) setMaskingIdFriend:(NSString*) markingId;

/*
 * get marking id of friend
 * @auther Baker
 */
-(NSString*) getMaskingIdFriend;

/*
 * generate transaction id
 * @auther Baker
 */
- (NSString*) generateTransactionID:(NSString*) friendMarkingId;

/*
 * check call is comming
 * @auther Baker
 */
- (BOOL) isIncommingCallReceived:(NSString*) message;

/**
 *  @author Daniel Nguyen, 15-05-13 11:05
 *
 *  @brief  handling the call log for SIP
 *
 *  @param logObject is a nsdictionary, have keys and values:
 *      - SIP_JID: target full jid without resource, eg: daniel@snim.mtouche-mobile.com
 *      - SIP_MESSAGE: message = duration time of call, eg: 03:01 (= three minutes and one sec), default is empty string @""
 *      - SIP_DELAYED: a NSDate object, default is now
 *      - SIP_IS_ME: a String, the value must be @"0" or @"1", =1 -> sender is current user.
 *      - SIP_STATUS: one of there values: SIPCallStatusNoAnswer, SIPCallStatusCancelled, SIPCallStatusMissed, SIPCallStatusCallFailed, SIPCallStatusCallBusy, SIPCallStatusCallOk
 */

- (void) addCallLogInfo:(NSString*)jid isCaller:(BOOL)isCaller Status:(SIPCallStatus)status message:(NSString*)message;
- (NSInteger)sipCallStatus:(NSString *)messageType;

#pragma mark - Call APIs -
/**
 *  @author Daniel Nguyen, 15-05-08 11:05
 *
 *  @brief  get SIP Call Status
 *
 *  @param dicInfo must have keys and values CMD (Its value must be fixed string - "STATUS"), TRANSACTIONID
 */
- (void) getSIPCallStastus:(NSDictionary *)dicInfo;

/**
 * make SIP Call in server tenant
 * @author Baker
 * @parameter parametersDic must have value for keys: CALLERMASKINGID, IMSI, IMEI, TOKEN, RECIPIENTMASKINGID, TYPE (Its value must be fixed string - "SIP"), CMD (Its value must be fixed string - "CALL"), TRANSACTIONID
 * @callback with response include: {"STATUS_CODE":0,"STATUS_MSG":"Success","SUCCESS":true,"DATA":{"FIRSTDELAY":1000,"DELAY":1000,"FREQUENCY":20}}
 */
- (void) makeSIPCallAPI:(NSDictionary *)dicInfo;

/**
 * update SIP Call Status in server tenant (only for receiver)
 * @author Baker
 * @parameter parametersDic must have value for keys: RECIPIENTMASKINGID, IMSI, IMEI, TOKEN, CALLERMASKINGID, CMD (Its value must be fixed string - "ANSWER" or "READY"), TRANSACTIONID
 * @callback with response include: {"STATUS_CODE":0,"STATUS_MSG":"Success","SUCCESS":true,"DATA":{"CALLERJID":"dqbuxir@snim.mtouche- mobile.com","CALLERNAME":"Vko0Rlc4RUs=","CALLTIMEOUT":30000}
 */
- (void) updateReadyStatusSIPAPI:(NSDictionary *)dicInfo;

/**
 * update End status SIP Call in server tenant
 * @author Baker
 * @parameter parametersDic must have value for keys: MASKINGID, IMSI, IMEI, TOKEN, REMARKS,  DURATION, CMD (Its value must be fixed string - "END"), TRANSACTIONID
 * @callback with response include: {"STATUS_CODE":0,"STATUS_MSG":"Success","SUCCESS":true}
 */
- (void) updateEndStatusSIPAPI:(NSDictionary *)dicInfo;

/**
 * update TimeOut status SIP Call in server tenant
 * @author Baker
 * @parameter parametersDic must have value for keys: MASKINGID, IMSI, IMEI, TOKEN, REMARKS, CMD (Its value must be fixed string - "END"), TRANSACTIONID
 * @callback with response include: {"STATUS_CODE":0,"STATUS_MSG":"Success","SUCCESS":true}
 */
- (void) updateTimeOutStatusSIPAPI:(NSDictionary *)dicInfo;

/**
 * update Fail status SIP Call in server tenant
 * @author Baker
 * @parameter parametersDic must have value for keys: MASKINGID, CALLERMASKINGID, IMSI, IMEI, TOKEN, RECIPIENTMASKINGID, REMARKS, CMD (Its value must be fixed string - "FAIL"), TRANSACTIONID
 * @callback with response include: {"STATUS_CODE":0,"STATUS_MSG":"Success","SUCCESS":true}
 */
- (void) updateFailStatusSIPAPI:(NSDictionary *)dicInfo;

/**
 * Handle phone call
 * @author Baker
 */
- (void) handlePhoneBookCall;

- (void)fireCallChangeState;

@end
