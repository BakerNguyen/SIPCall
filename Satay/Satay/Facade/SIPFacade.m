//
//  SIPFacade.m
//  Satay
//
//  Created by Ba (Baker) V. NGUYEN on 5/5/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import "SIPFacade.h"
#import <SIPDomain/SIPDomain.h>
#import "InitIncomingCallView.h"
#import "VoiceCallView.h"
#import "CallTimeOutView.h"

@implementation SIPFacade

@synthesize SIPDelegate;
@synthesize chatViewDelegate,chatListDelegate,chatComposeDelegate,emailInboxDelegate,contactListDelegate,contactBookDelegate, sideBarDelegate, voiceCallViewDelegate, initIncomingCallViewDelegate;
@synthesize isCalling, isOnCall, isEndCall, isMinimize, isTimeOutView, isInitLinphoneCore, isWhoMakeCall, isMissCalled, isBusy;
@synthesize friend_Jid;
@synthesize phoneCallCenter;
@synthesize minutes, seconds;

NSTimer *durationTimer, *networkQualityTimer;


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

- (void) registerSIPAccount {
    if ([KeyChainSecurity getStringFromKey:kJID] == nil) {
        return;
    }
    [self addProxyConfig:[NSString stringWithFormat:@"%@%@", SIP_USERNAME_PREFIX, [KeyChainSecurity getStringFromKey:kJID]]
                password:[KeyChainSecurity getStringFromKey:kJID_PASSWORD]
                  domain:SIP_DOMAIN
                    port:SIP_PORT
              stunServer:STUN_DOMAIN];
}

- (void) addProxyConfig:(NSString *)username password:(NSString *)password domain:(NSString *)domain port:(int)port stunServer:(NSString *)stunServer {
    isInitLinphoneCore = YES;
    [[SIPAdapter share] addProxyConfig:username password:password domain:domain port:port stunServer:stunServer];
    [[SIPFacade share] linphoneSetTimeout:SIP_TIME_LEFT];
}

- (void) unregistration {
    //UnRegister SIP
    if ([SIPFacade share].isInitLinphoneCore) {
        [[SIPAdapter share] unregistration];
    }    
}

- (void) linphoneSetTimeout:(int) duration {
    [[SIPAdapter share] linphoneSetTimeout:duration];
}

- (BOOL) checkProxyConfigIsRegistered {
    return [[SIPAdapter share] checkProxyConfigIsRegistered];
}

- (void) makeAudioPhoneCall:(NSString *)address {
    [[SIPAdapter share] makeAudioPhoneCall:address];
}

- (void) acceptCall {
    [[SIPAdapter share] acceptCall];
}

- (void) declineCall {
    [[SIPAdapter share] declineCall];
}

- (void) endCall {
    if (minutes == 0 && seconds == 0) {
        [[SIPFacade share] addCallLogInfo:[SIPFacade share].friend_Jid
                                 isCaller:isWhoMakeCall
                                   Status:SIPCallStatusCancelled message:@""];
    }
    [[SIPFacade share] setStatusOfCall:NO];
    //End Call
    NSDictionary *dict = @{ SIP_DURATION : [self changeDurationToString]
                            , SIP_CMD : @"END"
                            , SIP_REMARKS : @"End Call"};
    [[SIPFacade share] updateEndStatusSIPAPI:dict];

    [[SIPAdapter share] endCall];
    [self fireCallChangeState];
    self.isMinimize = NO;
}

- (float) qualityOfCall {
    return [[SIPAdapter share] qualityOfCall];
}

- (void) muteMicro:(BOOL)enable {
    [[SIPAdapter share] muteMicro:enable];
}

- (void) Speaker:(BOOL)enable {
    [[SIPAdapter share] Speaker:enable];
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

- (void) textReceivedNotification {
    [[SIPAdapter share] textReceivedNotification];
}

- (void) removetextReceivedNotification {
    [[SIPAdapter share] removetextReceivedNotification];
}

-(void) linphoneCallState:(NSString *)callState message:(NSString *)message {
    //[SIPDelegate linphoneCallState:callState message:message];
    if ([callState isEqualToString:@"LinphoneCallEnd"] || [callState isEqualToString:@"LinphoneCallError"]) {
        [durationTimer invalidate];
        //Call Timeout
        if ([message isEqualToString:@"Request Timeout"]) {
            [SIPDelegate linphoneCallTimeOut];
            
            //Timeout API
            NSDictionary *dict = @{ SIP_CMD : @"TIMEOUT"
                                    , SIP_REMARKS : @"Call TimeOut"};
            [[SIPFacade share] updateTimeOutStatusSIPAPI:dict];            
            //Add call log
            [[SIPFacade share] addCallLogInfo:[SIPFacade share].friend_Jid isCaller:YES Status:SIPCallStatusNoAnswer message:@""];
        }
        //Call Busy
        if ([message isEqualToString:@"Busy here"]) {
            [SIPDelegate linphoneCallBusy];
            //Add call log
            [[SIPFacade share] addCallLogInfo:[SIPFacade share].friend_Jid isCaller:YES Status:SIPCallStatusCallBusy message:@""];
        }
        //Call declined.
        if ([message isEqualToString:@"Call declined."]) {
            [SIPDelegate linphoneCallDeclined];
            //Add call log
            [[SIPFacade share] addCallLogInfo:[SIPFacade share].friend_Jid isCaller:YES Status:SIPCallStatusNoAnswer message:@""];
        }
        if ([message isEqualToString:@"Call ended"] || [message isEqualToString:@"Call terminated"]) {
            //Already accepted call
            [SIPDelegate linphoneCallEnded];
            [voiceCallViewDelegate CallEnded];
            //Add CallLog
            if ([SIPFacade share].seconds > 0 || [SIPFacade share].minutes > 0) {
                if ([SIPFacade share].isWhoMakeCall) {
                    [[SIPFacade share] addCallLogInfo:[SIPFacade share].friend_Jid isCaller:YES Status:SIPCallStatusCallOk message:[VoiceCallView share].lblDuration.text];
                } else {
                    [[SIPFacade share] addCallLogInfo:[SIPFacade share].friend_Jid isCaller:NO Status:SIPCallStatusCallOk message:[VoiceCallView share].lblDuration.text];
                }
            } else {
                if (![SIPFacade share].isWhoMakeCall) {
                    if (isMissCalled) {
                        [[SIPFacade share] addCallLogInfo:[SIPFacade share].friend_Jid
                                                 isCaller:NO
                                                   Status:SIPCallStatusMissed message:@""];
                    }
                    else {
                        [[SIPFacade share] addCallLogInfo:[SIPFacade share].friend_Jid
                                                 isCaller:NO
                                                   Status:SIPCallStatusCancelled message:@""];
                    }
                }
            }
        }
        
        [[SIPFacade share] removeLinphoneCallStateNotification];
        [[SIPFacade share] removeRegistrationUpdateNotification];
        [[SIPFacade share] removetextReceivedNotification];
        [[SIPFacade share] setStatusOfCall:NO];
        [self fireCallChangeState];
        return;
    }
    
    //Receiver got ring ring
    if ([callState isEqualToString:@"LinphoneCallOutgoingRinging"]) {
        [durationTimer invalidate];
        [SIPDelegate linphoneCallOutgoingRinging];
        return;
    }
    
    //Received sip call
    if ([callState isEqualToString:@"LinphoneCallIncomingReceived"]) {
        //[SIPDelegate linphoneCallIncomingReceived];
        [initIncomingCallViewDelegate linphoneCallIncomingReceived];
        return;
    }
    
    //Receiver already accept call.
    if ([callState isEqualToString:@"LinphoneCallStreamsRunning"]) {
        //[SIPDelegate linphoneCallStreamsRunning];
        [self showDurationAndNetworkQuality];
    }
}

-(void)fireCallChangeState{
    [chatComposeDelegate callChangeState];
    [chatListDelegate callChangeState];
    [contactListDelegate callChangeState];
    [emailInboxDelegate callChangeState];
    [contactBookDelegate callChangeState];
}

-(void) linphoneRegistrationState:(NSString *)registrationState {
    NSLog(@"%s: %@",__PRETTY_FUNCTION__, registrationState);
    if ([registrationState isEqualToString:@"LinphoneRegistrationOk"]) {
        [SIPDelegate linphoneRegistrationSuccessful];
        return;
    }
    if ([registrationState isEqualToString:@"LinphoneRegistrationFailed"]) {
        [SIPDelegate linphoneRegistrationFailed];
        //Caller Failed to login sip
        NSDictionary *dict = @{ SIP_CALLER_MASKINGID : [[ContactFacade share] getMaskingId]
                                , SIP_RECIPIENT_MASKINGID : [[SIPFacade share] getMaskingIdFriend]
                                , SIP_CMD : @"FAIL"
                                , SIP_REMARKS : @"Call Fail"};
        [[SIPFacade share] updateFailStatusSIPAPI:dict];
        //Add call log
        [[SIPFacade share] addCallLogInfo:[SIPFacade share].friend_Jid isCaller:YES Status:SIPCallStatusCallFailed message:@""];
    }
}

-(void) linphoneTextReceivedEvent:(NSString *)textReceived {
    [SIPDelegate linphoneTextReceivedEvent:textReceived];
}

- (void) sendPingPongMessage:(NSString *)sip_address type:(NSString *)type message:(NSString *)message {
    //[[SIPAdapter share] sendPingPongMessage:sip_address type:type message:message];
}

- (BOOL) isIncommingCallReceived:(NSString*) message {
    @try {
        NSDictionary* xmppDic = [ChatAdapter decodeJSON:message];
        if (xmppDic == nil) {
            NSData *messageData = [Base64Security decodeBase64String:message];
            NSString *messageBody = [[NSString alloc] initWithData:messageData encoding:NSUTF8StringEncoding];
            xmppDic = [ChatAdapter decodeJSON:messageBody];
        }
        
        //prevent crash when xmppDic nil;
        if(!xmppDic)
            return NO;
        
        //not sip call, return, nothing to do.
        if (![[xmppDic objectForKey:@"mt"] isEqualToString:@"sc"])
            return NO;
        
        //Sip call but blocked user.
        if([[ContactFacade share] isBlocked:[xmppDic objectForKey:@"jid"]])
            return YES;
        
        //End Call
        if ([[xmppDic objectForKey:@"code"] isEqualToString:SIP_CODE_END]) {
            Message* missCallMess = [[AppFacade share] getMessage:[xmppDic objectForKey:@"ct"]];
            if (missCallMess == nil) {
                if ([SIPFacade share].isOnCall)
                    return YES;
                [[SIPFacade share] addCallLogInfo:[xmppDic objectForKey:@"jid"] isCaller:NO Status:SIPCallStatusMissed message:@""];
            }
            return YES;
        }
        
        //Busy with call anther guys.
        if (isCalling) {
            /*
             NSString *messageContent = [Base64Security generateBase64String:[NSString stringWithFormat:@"{\"sid\":\"%@\",\"code\":\"%@\",\"msg\":\"%@\",\"mt\":\"sc\"}", [xmppDic objectForKey:@"jid"], SIP_CODE_BUSY, @"return"]];
             NSDictionary *msgObj = @{kSEND_TEXT_MESSAGE_VALUE: messageContent,
             kSEND_TEXT_TARGET_JID: [xmppDic objectForKey:@"jid"],
             kSEND_TEXT_MESSAGE_ID: [ChatAdapter generateMessageId],
             kXMPP_MESSAGE_STREAM_TYPE: kSIP_MESSAGE
             };
             [[XMPPFacade share] sendTextMessage:msgObj];
             */
            [[SIPFacade share] addCallLogInfo:[xmppDic objectForKey:@"jid"] isCaller:NO Status:SIPCallStatusMissed message:@""];
            Contact *friendInfo = [[ContactFacade share] getContact:[xmppDic objectForKey:@"jid"]];
            NSDictionary *dict = @{SIP_CALLER_MASKINGID : friendInfo.maskingid, SIP_CMD : @"BUSY", SIP_TRANSACTIONID : [xmppDic objectForKey:@"ct"]};
            [[SIPFacade share] updateReadyStatusSIPAPI:dict];
            return YES;
        }

        //Init imcomming call
        [self initIncomingCallView:[xmppDic objectForKey:@"ct"] JID:[xmppDic objectForKey:@"jid"]];
        return YES;
    }
    @catch (NSException *exception) {
        NSLog(@"%s: %@",__PRETTY_FUNCTION__, exception);
    }
    
    return NO;
}

#pragma mark - Call Process -
//*****************************************************************//

- (void) checkProxyConfig {
    if ([[SIPFacade share] checkProxyConfigIsRegistered]) {
        [self startCall];
        return;
    }
    [VoiceCallView share].lblDuration.text = @"Registration Inprogress";
    [[SIPFacade share] registerSIPAccount];
    [[SIPFacade share] registrationUpdateNotification];
}

- (void) startCall {
    if ([SIPFacade share].isWhoMakeCall) {
        [VoiceCallView share].lblDuration.text = SIP_CALLING;
        [self callAPI_makeCall];        

        return;
    }
       
}

- (void) callAPI_makeCall {
    NSDictionary *dict = @{SIP_RECIPIENT_MASKINGID : [[SIPFacade share] getMaskingIdFriend]
                           , SIP_TYPE : @"SIP"
                           , SIP_CMD : @"CALL"};
    [[SIPFacade share] makeSIPCallAPI:dict];
    [[SIPFacade share] removeRegistrationUpdateNotification];
}

- (void) showDurationAndNetworkQuality {
    seconds = 0;
    minutes = 0;
    [durationTimer invalidate];
    durationTimer = [NSTimer scheduledTimerWithTimeInterval:1
                                                     target:self
                                                   selector:@selector(DurationAndNetworkQuality)
                                                   userInfo:nil
                                                    repeats:YES];
}

- (void) DurationAndNetworkQuality {
    [self countDuration];
    [self networkQuality];
}

- (void) countDuration {
    seconds += 1;
    if (seconds == 60) {
        minutes += 1;
        seconds = 0;
    }
    if (seconds < 10) {
        [VoiceCallView share].lblDuration.text = [NSString stringWithFormat:@"%d:0%d", minutes, seconds];
        [VoiceCallView share].lblDurationMinimize.text = [NSString stringWithFormat:@"%d:0%d", minutes, seconds];
    } else {
        [VoiceCallView share].lblDuration.text = [NSString stringWithFormat:@"%d:%d", minutes, seconds];
        [VoiceCallView share].lblDurationMinimize.text = [NSString stringWithFormat:@"%d:%d", minutes, seconds];
    }
}

- (void) networkQuality {
    [VoiceCallView share].lblNetworkQuality.text = SIP_NETWORK_QUALITY;
    [VoiceCallView share].lblNetworkQuality.textAlignment = NSTextAlignmentLeft;
    float quality = [[SIPFacade share] qualityOfCall];
    
    if (quality < 3) {
        [VoiceCallView share].lblNetworkStatus.text = SIP_NETWORK_STATUS_POOR; //Poor
        [VoiceCallView share].lblNetworkStatus.textColor = [UIColor redColor];
    }
    else if (quality < 4) {
        [VoiceCallView share].lblNetworkStatus.text = SIP_NETWORK_STATUS_AVEGARE; //Average
        [VoiceCallView share].lblNetworkStatus.textColor = [UIColor yellowColor];
    }
    else {
        [VoiceCallView share].lblNetworkStatus.text = SIP_NETWORK_STATUS_EXCELLENT; //Good
        [VoiceCallView share].lblNetworkStatus.textColor = [UIColor greenColor];
    }
}

- (NSString*) changeDurationToString {
    //Duration
    NSString *durationFormat = @"";
    int hours = 0;
    if ((seconds > 0) || (minutes > 0)) {
        if (minutes > 60) {
            hours = minutes / 60;
            minutes = minutes % 60;
        }
        durationFormat = [NSString stringWithFormat:@"0%d:", hours];
        durationFormat = (minutes > 10)?([NSString stringWithFormat:@"%@%d:", durationFormat, minutes]):([NSString stringWithFormat:@"%@0%d:", durationFormat, minutes]);
        durationFormat = (seconds > 10)?([NSString stringWithFormat:@"%@%d", durationFormat, seconds]):([NSString stringWithFormat:@"%@0%d", durationFormat, seconds]);
    } else {
        durationFormat = @"00:00:00";
    }
    return durationFormat;
    /////
}

- (void) setStatusOfCall:(BOOL) isStart {
    if (isStart) {
        minutes = 0;
        seconds = 0;
        [SIPFacade share].isMinimize = NO;
        [SIPFacade share].isCalling = YES;
        [SIPFacade share].isOnCall = NO;
        [SIPFacade share].isEndCall = NO;
        [SIPFacade share].isBusy = NO;
        [VoiceCallView share].isPauseTone = NO;
        [[VoiceCallView share] resetSpeakerMute];
    } else {
        isMinimize = NO;
        isMissCalled = NO;
        isCalling = NO;
        isOnCall = NO;
        isEndCall = YES;
        isBusy = NO;
        [VoiceCallView share].isPauseTone = YES;
    }
    [durationTimer invalidate];
}

////////////////////////////////////////////////////////////////////


- (void) initIncomingCallView:(NSString*) trans JID:(NSString*) jid {
    if ([[KeyChainSecurity getStringFromKey:SIP_TRANSACTIONID] isEqualToString:trans]) {
        return;
    }
    //Init imcomming call
    [[InitIncomingCallView share].view removeFromSuperview];
    [KeyChainSecurity storeString:trans Key:SIP_TRANSACTIONID];
    [InitIncomingCallView share].userJid = jid;
    [[CWindow share] showInitIncomingCallView];
}

-(void) setMaskingIdFriend:(NSString*) markingId{
    [KeyChainSecurity storeString:markingId Key:SIP_RECIPIENT_MASKINGID];
}
- (NSString*) getMaskingIdFriend{
    return [KeyChainSecurity getStringFromKey:SIP_RECIPIENT_MASKINGID];
}

- (NSString*) generateTransactionID:(NSString*) friendMarkingId {
    NSString* transactionID = [NSString stringWithFormat:@"%@_%@_%0.f", [[ContactFacade share] getMaskingId], friendMarkingId, [[NSDate date] timeIntervalSince1970]];
    [KeyChainSecurity storeString:transactionID Key:SIP_TRANSACTIONID];
    return transactionID;
}

- (void) addCallLogInfo:(NSString*)jid isCaller:(BOOL)isCaller Status:(SIPCallStatus)status message:(NSString*)message {
    
    if (jid == nil) {
        NSLog(@"addCallLogInfo - JID is nil");
        return;
    }
    
    NSMutableDictionary *logDic = [NSMutableDictionary new];
    [logDic setObject:[NSDate new] forKey:kSIP_DELAYED];
    [logDic setObject:jid forKey:kSIP_JID];
    //isCaller = NO;
    if (isCaller) {
        [logDic setObject:@"1" forKey:kSIP_IS_ME];
    } else {
        [logDic setObject:@"0" forKey:kSIP_IS_ME];
    }
    
    //status = SIPCallStatusMissed;
    switch (status) {
        case SIPCallStatusCallBusy:
            [logDic setObject:[NSString stringWithFormat:@"%d", SIPCallStatusCallBusy] forKey:kSIP_STATUS];
            break;
        case SIPCallStatusCallFailed:
            [logDic setObject:[NSString stringWithFormat:@"%d", SIPCallStatusCallFailed] forKey:kSIP_STATUS];
            break;
        case SIPCallStatusCancelled:
            [logDic setObject:[NSString stringWithFormat:@"%d", SIPCallStatusCancelled] forKey:kSIP_STATUS];
            break;
        case SIPCallStatusMissed:
            [logDic setObject:[NSString stringWithFormat:@"%d", SIPCallStatusMissed] forKey:kSIP_STATUS];
            break;
        case SIPCallStatusNoAnswer:
            [logDic setObject:[NSString stringWithFormat:@"%d", SIPCallStatusNoAnswer] forKey:kSIP_STATUS];
            break;
        default:
            [logDic setObject:[NSString stringWithFormat:@"%d", SIPCallStatusCallOk] forKey:kSIP_STATUS];
            [logDic setObject:message forKey:kSIP_MESSAGE];
            break;
    }
    
    [[SIPFacade share] addCallLog:logDic];
}

- (void) addCallLog:(NSDictionary *)logObject
{
    NSLog(@"%s %@", __PRETTY_FUNCTION__, logObject);
    if (!logObject || ![logObject objectForKey:kSIP_JID]) {
        return;
    }
    
    NSDate* delayedDate = [logObject objectForKey:kSIP_DELAYED];
    Message* message = [Message new];
    message.messageId = [KeyChainSecurity getStringFromKey:SIP_TRANSACTIONID]; //[ChatAdapter generateMessageId]
    message.chatboxId = [logObject objectForKey:kSIP_JID];
    message.messageContent = @"";
    
    switch ([[logObject objectForKey:kSIP_STATUS] integerValue]) {
        case SIPCallStatusCallBusy:
            message.messageContent = SIP_CALL_BUSY;
            message.messageStatus = SIP_CALL_BUSY;
            break;
        case SIPCallStatusCallFailed:
            message.messageContent = SIP_CALL_FAILED;
            message.messageStatus = SIP_CALL_FAILED;
            break;
        case SIPCallStatusCancelled:
            message.messageContent = SIP_CANCELLED;
            message.messageStatus = SIP_CANCELLED;
            break;
        case SIPCallStatusMissed:
            message.messageContent = SIP_MISSED;
            message.messageStatus = SIP_MISSED;
            break;
        case SIPCallStatusNoAnswer:
            message.messageContent = SIP_NO_ANSWER;
            message.messageStatus = SIP_NO_ANSWER;
            break;
            
        default: //SIPCallStatusCallOk, message = duration time of call, eg: 03:01 (= three minutes and one sec)
            message.messageContent = [NSString stringWithFormat:SIP_CALL_OK, [logObject objectForKey:kSIP_MESSAGE]];
            message.messageStatus = SIP_CALL_OK;
            break;
    }
    
    message.senderJID = [[logObject objectForKey:kSIP_IS_ME] boolValue] ? [[ContactFacade share] getJid:YES] : [logObject objectForKey:kSIP_JID];
    message.messageType = kSIP_MESSAGE_TYPE_CT;
    message.sendTS = delayedDate ? [NSNumber numberWithInt:[delayedDate timeIntervalSince1970]] : [NSNumber numberWithInt:[[NSDate date] timeIntervalSince1970]];
    message.isEncrypted = TRUE;
    message.selfDestructDuration = 0;
    [[DAOAdapter share] commitObject:message];
    dispatch_async(dispatch_get_main_queue(), ^(void){
        [chatViewDelegate addMessage:message.messageId];
        [sideBarDelegate updateChatRowUnreadNumber];
    });
    
    // for chat list display
    ChatBox* chatBox = [[AppFacade share] getChatBox:[logObject objectForKey:kSIP_JID]];
    if (!chatBox){
        [[ChatFacade share] createChatBox:[logObject objectForKey:kSIP_JID] isMUC:NO];
        chatBox = [[AppFacade share] getChatBox:[logObject objectForKey:kSIP_JID]];
    }
    
    chatBox.updateTS = [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]];
    chatBox.chatboxState = [NSNumber numberWithInt:kCHATBOX_STATE_DISPLAY];
    [[DAOAdapter share] commitObject:chatBox];
    [[ChatFacade share] reloadChatBoxList];
}

- (NSInteger)sipCallStatus:(NSString *)messageType
{
    if([messageType isEqual:SIP_NO_ANSWER])
        return SIPCallStatusNoAnswer;
    if([messageType isEqual:SIP_CALL_OK])
        return SIPCallStatusCallOk;
    if([messageType isEqual:SIP_MISSED])
        return SIPCallStatusMissed;
    if([messageType isEqual:SIP_CALL_BUSY])
        return SIPCallStatusCallBusy;
    if([messageType isEqual:SIP_CANCELLED])
        return SIPCallStatusCancelled;
    if([messageType isEqual:SIP_CALL_FAILED])
        return SIPCallStatusCallFailed;
    
    return -1000;
}

#pragma mark - Call APIs -
- (void) getSIPCallStastus:(NSDictionary *)dicInfo
{
    if (!dicInfo) {
        return;
    }
    
    NSMutableDictionary *params = [dicInfo mutableCopy];
    [params setObject:[[ContactFacade share] getMaskingId] forKey:kMASKINGID];
    [params setObject:[[ContactFacade share] getIMEI] forKey:kIMEI];
    [params setObject:[[ContactFacade share] getIMSI] forKey:kIMSI];
    [params setObject:[[ContactFacade share] getTokentTenant] forKey:kTOKEN];
    
    // two params alway required
    [params setObject:PUT forKey:kAPI_REQUEST_METHOD];
    [params setObject:NORMAL forKey:kAPI_REQUEST_KIND];
    
    [[SIPAdapter share] getSIPCallStatus:params callback:^(BOOL success, NSString *message, NSDictionary *response, NSError *error) {
        NSLog(@"%s %@", __PRETTY_FUNCTION__, response);
        
        if (success) {
            // success code here
            int StatusCode = [[[response objectForKey:@"DATA"] objectForKey:@"STATUS"] intValue];
            switch (StatusCode) {
                case 1:
                    NSLog(@"Friend ready");
                    if (!isOnCall) {
                        [SIPFacade share].isOnCall = YES;                        
                        [[SIPFacade share] makeAudioPhoneCall:[NSString stringWithFormat:@"sip:%@%@",SIP_USERNAME_PREFIX, [friend_Jid stringByReplacingOccurrencesOfString:[[ContactFacade share] getXmppHostName] withString:SIP_DOMAIN]]];
                    }
                    break;
                case 2:                   
                    NSLog(@"Get Status - Pending");
                    if (isEndCall || isOnCall || isBusy) {
                        return;
                    }
                    int count = [[params objectForKey:@"FREQUENCY"] intValue];
                    [params setObject:[NSString stringWithFormat:@"%d", count - 1] forKey:@"FREQUENCY"];
                    if (count > 0) {
                        [self performSelector:@selector(getSIPCallStastus:) withObject:params afterDelay:1.0];
                    } else {
                        NSLog(@"Timeout");                        
                        //Timeout
                        NSDictionary *dict = @{ SIP_CMD : @"TIMEOUT"
                                                , SIP_REMARKS : @"Call TimeOut"};
                        [[SIPFacade share] updateTimeOutStatusSIPAPI:dict];
                        
                        //add call log
                        [[SIPFacade share] addCallLogInfo:[SIPFacade share].friend_Jid isCaller:YES Status:SIPCallStatusNoAnswer message:@""];
                        
                        //Show Timeout ViewControler
                        [SIPDelegate linphoneCallTimeOut];
                    }
                    break;
                case 3:
                    NSLog(@"Get Status - End");
                    [SIPDelegate linphoneCallEnded];
                    [self setStatusOfCall:NO];
                    break;
                case 4:
                    NSLog(@"Get Status - Timeout");
                    [SIPDelegate linphoneCallEnded];
                    [self setStatusOfCall:NO];
                    break;
                case 5:
                    NSLog(@"Get Status - Busy");
                    if ([SIPFacade share].isOnCall) {
                        [VoiceCallView share].isPauseTone = YES;
                        break;
                    }
                    [SIPFacade share].isBusy = YES;
                    [SIPDelegate linphoneCallBusy];
                    break;
                case 99:
                    NSLog(@"Get Status - Fail");
                    [SIPDelegate linphoneCallEnded];
                    [self setStatusOfCall:NO];
                    break;
                default:
                    break;
            }
            
            
        } else {
            // fail code here
             if (response){
                // if Token is invalid or expire
                NSInvocationOperation* operation=  [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(getSIPCallStastus:) object:dicInfo];
                NSDictionary* retryDictionary = @{kRETRY_OPERATION:operation,kRETRY_TIME:kRETRY_API_COUNTER,
                                                  kSTATUS_CODE : [response objectForKey:kSTATUS_CODE]};
                [[AppFacade share] downloadTokenAgain:retryDictionary];
             }
        }
    }];
}

- (void) makeSIPCallAPI:(NSDictionary *)dicInfo
{
    if (!dicInfo) {
        return;
    }
    [[SIPFacade share] generateTransactionID:[[SIPFacade share] getMaskingIdFriend]];
    
    NSMutableDictionary *params = [dicInfo mutableCopy];
    [params setObject:[[ContactFacade share] getMaskingId] forKey:SIP_CALLER_MASKINGID];
    [params setObject:[[ContactFacade share] getIMEI] forKey:kIMEI];
    [params setObject:[[ContactFacade share] getIMSI] forKey:kIMSI];
    [params setObject:[[ContactFacade share] getTokentTenant] forKey:kTOKEN];
    
    [params setObject:[KeyChainSecurity getStringFromKey:SIP_TRANSACTIONID] forKey:SIP_TRANSACTIONID];
    
    // two params alway required
    [params setObject:PUT forKey:kAPI_REQUEST_METHOD];
    [params setObject:NORMAL forKey:kAPI_REQUEST_KIND];
    
    [[SIPAdapter share] getSIPCallStatus:params callback:^(BOOL success, NSString *message, NSDictionary *response, NSError *error) {
        NSLog(@"%s %@", __PRETTY_FUNCTION__, response);        
        if (success) {
            // success code here
            //Call get staus of friend API
            NSDictionary *dict = @{SIP_CMD : @"STATUS"
                                   , SIP_TRANSACTIONID : [KeyChainSecurity getStringFromKey:SIP_TRANSACTIONID]
                                   , @"FREQUENCY" : [[[response objectForKey:@"DATA"] objectForKey:@"FREQUENCY"] stringValue]};
            [self getSIPCallStastus:dict];
        } else {
            [VoiceCallView share].isPauseTone = YES;
            [self setStatusOfCall:NO];
            [[VoiceCallView share].view removeFromSuperview];
            [[CAlertView new] showError:SIP_CALL_FAILED];
            //Add call log
            [[SIPFacade share] addCallLogInfo:[SIPFacade share].friend_Jid isCaller:YES Status:SIPCallStatusCallFailed message:@""];

            // fail code here
             if (response){
                // if Token is invalid or expire
                NSInvocationOperation* operation=  [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(makeSIPCallAPI:) object:dicInfo];
                NSDictionary* retryDictionary = @{kRETRY_OPERATION:operation,kRETRY_TIME:kRETRY_API_COUNTER,
                                                  kSTATUS_CODE : [response objectForKey:kSTATUS_CODE]};
                [[AppFacade share] downloadTokenAgain:retryDictionary];
             }
        }
    }];
}

- (void) updateReadyStatusSIPAPI:(NSDictionary *)dicInfo
{
    if (!dicInfo) {
        return;
    }
    NSMutableDictionary *params = [dicInfo mutableCopy];
    [params setObject:[[ContactFacade share] getMaskingId] forKey:SIP_RECIPIENT_MASKINGID];
    [params setObject:[[ContactFacade share] getIMEI] forKey:kIMEI];
    [params setObject:[[ContactFacade share] getIMSI] forKey:kIMSI];
    [params setObject:[[ContactFacade share] getTokentTenant] forKey:kTOKEN];
    
    if (![[params objectForKey:SIP_CMD] isEqualToString:@"BUSY"]) {
        [params setObject:[KeyChainSecurity getStringFromKey:SIP_TRANSACTIONID] forKey:SIP_TRANSACTIONID];
    }
    
    // two params alway required
    [params setObject:PUT forKey:kAPI_REQUEST_METHOD];
    [params setObject:NORMAL forKey:kAPI_REQUEST_KIND];
    
    [[SIPAdapter share] getSIPCallStatus:params callback:^(BOOL success, NSString *message, NSDictionary *response, NSError *error) {
        NSLog(@"%s %@", __PRETTY_FUNCTION__, response);
        if (success) {
            // success code here
            
        } else {
             if (response){
                // fail code here
                // if Token is invalid or expire
                NSInvocationOperation* operation=  [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(updateReadyStatusSIPAPI:) object:dicInfo];
                NSDictionary* retryDictionary = @{kRETRY_OPERATION:operation,kRETRY_TIME:kRETRY_API_COUNTER,
                                                  kSTATUS_CODE : [response objectForKey:kSTATUS_CODE]};
                [[AppFacade share] downloadTokenAgain:retryDictionary];
             }
        }
    }];
}

- (void) updateEndStatusSIPAPI:(NSDictionary *)dicInfo
{
    if (!dicInfo) {
        return;
    }
    NSMutableDictionary *params = [dicInfo mutableCopy];
    [params setObject:[[ContactFacade share] getMaskingId] forKey:SIP_MASKINGID];
    [params setObject:[[ContactFacade share] getIMEI] forKey:kIMEI];
    [params setObject:[[ContactFacade share] getIMSI] forKey:kIMSI];
    [params setObject:[[ContactFacade share] getTokentTenant] forKey:kTOKEN];
    
    [params setObject:[KeyChainSecurity getStringFromKey:SIP_TRANSACTIONID] forKey:SIP_TRANSACTIONID];
    
    // two params alway required
    [params setObject:PUT forKey:kAPI_REQUEST_METHOD];
    [params setObject:NORMAL forKey:kAPI_REQUEST_KIND];
    
    [[SIPAdapter share] getSIPCallStatus:params callback:^(BOOL success, NSString *message, NSDictionary *response, NSError *error) {
        NSLog(@"%s %@", __PRETTY_FUNCTION__, response);
        if (success) {
            // success code here
            
        } else {
             if (response){
                // fail code here
                NSInvocationOperation* operation=  [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(updateEndStatusSIPAPI:) object:dicInfo];
                NSDictionary* retryDictionary = @{kRETRY_OPERATION:operation,
                                                  kRETRY_TIME:kRETRY_API_COUNTER,
                                                  kSTATUS_CODE : [response objectForKey:kSTATUS_CODE]};
                [[AppFacade share] downloadTokenAgain:retryDictionary];
             }
        }
    }];
}

- (void) updateTimeOutStatusSIPAPI:(NSDictionary *)dicInfo
{
    if (!dicInfo) {
        return;
    }
    NSMutableDictionary *params = [dicInfo mutableCopy];
    [params setObject:[[ContactFacade share] getMaskingId] forKey:SIP_MASKINGID];
    [params setObject:[[ContactFacade share] getIMEI] forKey:kIMEI];
    [params setObject:[[ContactFacade share] getIMSI] forKey:kIMSI];
    [params setObject:[[ContactFacade share] getTokentTenant] forKey:kTOKEN];
    
    [params setObject:[KeyChainSecurity getStringFromKey:SIP_TRANSACTIONID] forKey:SIP_TRANSACTIONID];
    
    // two params alway required
    [params setObject:PUT forKey:kAPI_REQUEST_METHOD];
    [params setObject:NORMAL forKey:kAPI_REQUEST_KIND];
    
    [[SIPAdapter share] getSIPCallStatus:params callback:^(BOOL success, NSString *message, NSDictionary *response, NSError *error) {
        NSLog(@"%s %@", __PRETTY_FUNCTION__, response);
        if (success) {
            // success code here
            NSLog(@"Success");
        } else {
             if (response){
            // fail code here
                NSInvocationOperation* operation=  [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(updateTimeOutStatusSIPAPI:) object:dicInfo];
                NSDictionary* retryDictionary = @{kRETRY_OPERATION:operation,kRETRY_TIME:kRETRY_API_COUNTER,
                                                  kSTATUS_CODE : [response objectForKey:kSTATUS_CODE]};
                [[AppFacade share] downloadTokenAgain:retryDictionary];
             }
        }
    }];
}

- (void) updateFailStatusSIPAPI:(NSDictionary *)dicInfo
{
    if (!dicInfo) {
        return;
    }
    NSMutableDictionary *params = [dicInfo mutableCopy];
    [params setObject:[[ContactFacade share] getMaskingId] forKey:SIP_MASKINGID];
    [params setObject:[[ContactFacade share] getIMEI] forKey:kIMEI];
    [params setObject:[[ContactFacade share] getIMSI] forKey:kIMSI];
    [params setObject:[[ContactFacade share] getTokentTenant] forKey:kTOKEN];

    [params setObject:[KeyChainSecurity getStringFromKey:SIP_TRANSACTIONID] forKey:SIP_TRANSACTIONID];
    
    // two params alway required
    [params setObject:PUT forKey:kAPI_REQUEST_METHOD];
    [params setObject:NORMAL forKey:kAPI_REQUEST_KIND];
    
    [[SIPAdapter share] getSIPCallStatus:params callback:^(BOOL success, NSString *message, NSDictionary *response, NSError *error) {
        NSLog(@"%s %@", __PRETTY_FUNCTION__, response);
        if (success) {
            // success code here
            NSLog(@"Success");
        } else {
             if (response){
                // fail code here
                NSInvocationOperation* operation=  [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(updateFailStatusSIPAPI:) object:dicInfo];
                
                NSDictionary* retryDictionary = @{kRETRY_OPERATION:operation,
                                                  kRETRY_TIME:kRETRY_API_COUNTER,
                                                  kSTATUS_CODE : [response objectForKey:kSTATUS_CODE]};
                [[AppFacade share] downloadTokenAgain:retryDictionary];
             }
        }
    }];
}

- (void) handlePhoneBookCall {
    __block id phoneSipDelegate = SIPDelegate;
    self.phoneCallCenter.callEventHandler = ^(CTCall *call) {
        if ([call.callState isEqualToString: CTCallStateConnected])
        {
            //NSLog(@"call stopped");
        }
        else if ([call.callState isEqualToString: CTCallStateDialing])
        {
            [phoneSipDelegate incomingPhoneBookCall];
        }
        else if ([call.callState isEqualToString: CTCallStateDisconnected])
        {
            //NSLog(@"call played");
        }
        else if ([call.callState isEqualToString: CTCallStateIncoming])
        {
            [phoneSipDelegate incomingPhoneBookCall];
        }
    };
}

@end
