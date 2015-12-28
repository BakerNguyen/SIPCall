//
//  SIPAdapter.m
//  SIPDomain
//
//  Created by Daniel Nguyen on 4/13/15.
//  Copyright (c) 2015 mTouche. All rights reserved.
//

#import "SIPAdapter.h"
#import "LinphoneManager.h"
#import "SIPServerAdapter.h"

//Define for APIs
#define kAPI @"API"
#define kAPI_VERSION @"API_VERSION"

#define API_SIP_CALL_STATUS @"uMlZQsgEH5"
#define API_SIP_CALL_STATUS_VERSION @"v1"

#define API_xxx @"xxx"
#define API_xxx_VERSION @"v1"

#define API_SIP_MAKE_CALL @"uMlZQsgEH5"
#define API_SIP_MAKE_CALL_VERSION @"v1"

#define API_SIP_UPDATE_READY @"uMlZQsgEH5"
#define API_SIP_UPDATE_READY_VERSION @"v1"

#define API_SIP_UPDATE_FAIL @"uMlZQsgEH5"
#define API_SIP_UPDATE_FAIL_VERSION @"v1"

#define API_SIP_UPDATE_END @"uMlZQsgEH5"
#define API_SIP_UPDATE_END_VERSION @"v1"

#define API_SIP_UPDATE_TIMEOUT @"uMlZQsgEH5"
#define API_SIP_UPDATE_TIMEOUT_VERSION @"v1"

@implementation SIPAdapter

@synthesize SIPDomainDelegate;

LinphoneManager* linManager;
LinphoneCore* lpCore;
LinphoneProxyConfig* lpProxyCfg;

+ (SIPAdapter*) share{
    static dispatch_once_t once;
    static SIPAdapter * share;
    dispatch_once(&once, ^{
        share = [self new];
    });
    return share;
}

- (void) addProxyConfig:(NSString*)username password:(NSString*)password domain:(NSString*)domain port:(int)port stunServer:(NSString*) stunServer {
    
    linManager = [LinphoneManager instance];
    [linManager createLinphoneCore];
    
    lpCore = [LinphoneManager getLc];
    lpProxyCfg = linphone_core_create_proxy_config(lpCore);
    
    char normalizedUserName[256];
    linphone_proxy_config_normalize_number(lpProxyCfg, [username cStringUsingEncoding:[NSString defaultCStringEncoding]], normalizedUserName, sizeof(normalizedUserName));
    
    const char* identity = linphone_proxy_config_get_identity(lpProxyCfg);
    if( !identity || !*identity )
        identity = [[NSString stringWithFormat:@"sip:%@@%@", username, domain] UTF8String];
    
    LinphoneAddress* linphoneAddress = linphone_address_new(identity);
    linphone_address_set_username(linphoneAddress, normalizedUserName);
    
    if( domain && [domain length] != 0) {
        // when the domain is specified (for external login), take it as the server address
        //linphone_proxy_config_set_server_addr(lpProxyCfg, [[NSString stringWithFormat:@"%@:%d", domain, port] UTF8String] );
        linphone_proxy_config_set_server_addr(lpProxyCfg, [domain UTF8String] );
        linphone_address_set_domain(linphoneAddress, [domain UTF8String]);
    }
    
    identity = linphone_address_as_string_uri_only(linphoneAddress);
    
    linphone_proxy_config_set_identity(lpProxyCfg, identity);
    
    LinphoneAuthInfo* info = linphone_auth_info_new([username UTF8String]
                                                    , NULL, [password UTF8String]
                                                    , NULL
                                                    , NULL
                                                    ,linphone_proxy_config_get_domain(lpProxyCfg));
    
    
    linphone_core_verify_server_certificates(lpCore, YES);
    linphone_core_verify_server_cn(lpCore, YES);
    //linphone_address_set_port(linphoneAddress, port);
    //linphone_core_set_sip_port(lpCore, port);
    //linphone_address_set_transport(linphoneAddress, LinphoneTransportTls);
    
    // Set stun server and enable firewall policy.
    if ((stunServer != nil) && (![stunServer isEqualToString:@""])) {
        linphone_core_set_stun_server(lpCore, [stunServer UTF8String]);
        linphone_core_set_firewall_policy(lpCore, LinphonePolicyUseStun);
    }
    
    [self setDefaultSettings:lpProxyCfg];
    linphone_proxy_config_enable_register(lpProxyCfg, true);
    linphone_core_add_auth_info(lpCore, info);
    linphone_core_add_proxy_config(lpCore, lpProxyCfg);
    linphone_core_set_default_proxy(lpCore, lpProxyCfg);
    
    // Set call by ZRTP
    linphone_core_set_media_encryption(lpCore, LinphoneMediaEncryptionZRTP);
    
    //Set number of max call
    linphone_core_set_max_calls(lpCore, 1);
    
    //Enable signaling keep alive. small udp packet sent periodically to keep udp NAT association
    linphone_core_enable_keep_alive(lpCore, true);
}

- (void) linphoneSetTimeout:(int) duration {
    // Set timeout for receive call
    linphone_core_set_inc_timeout(lpCore, duration);
}

- (void) unregistration {
    // Get the default proxyCfg in Linphone
    LinphoneProxyConfig* proxyCfg = NULL;
    linphone_core_get_default_proxy([LinphoneManager getLc], &proxyCfg);
    
    // To unregister from SIP
    linphone_proxy_config_edit(proxyCfg);
    linphone_proxy_config_enable_register(proxyCfg, false);
    linphone_proxy_config_done(proxyCfg);
}

- (void) registrationUpdateNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(registrationUpdateEvent:)
                                                 name:kLinphoneRegistrationUpdate
                                               object:nil];
}

- (void) registrationUpdateEvent:(NSNotification *)notif
{
    int state = [[notif.userInfo objectForKey:@"state"] intValue];
    switch (state)
    {
        case LinphoneRegistrationOk:
            [SIPDomainDelegate linphoneRegistrationState:@"LinphoneRegistrationOk"];
            break;
        case LinphoneRegistrationNone:
        case LinphoneRegistrationCleared:
            NSLog(@"Not registered");
            break;
        case LinphoneRegistrationFailed:
            [SIPDomainDelegate linphoneRegistrationState:@"LinphoneRegistrationFailed"];
            break;
        case LinphoneRegistrationProgress:
            [SIPDomainDelegate linphoneRegistrationState:@"LinphoneRegistrationProgress"];
            break;            
        default:
            break;
    }
}

- (void) removeRegistrationUpdateNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kLinphoneRegistrationUpdate
                                                  object:nil];
}

- (void) makeAudioPhoneCall:(NSString*) address {
    //address = @"sip:baker@sip.linphone.org"
    [[LinphoneManager instance] call:address displayName:@"" transfer:NO];
}

- (void)setDefaultSettings:(LinphoneProxyConfig*)proxyCfg {
    LinphoneManager* lm = [LinphoneManager instance];
    
    BOOL pushnotification = [lm lpConfigBoolForKey:@"pushnotification_preference"];
    if(pushnotification) {
        [lm addPushTokenToProxyConfig:proxyCfg];
    }
}

- (BOOL) checkProxyConfigIsRegistered {
    if (lpProxyCfg != nil) {
        return linphone_proxy_config_is_registered(lpProxyCfg);
    }
    return NO;
}

- (void) linphoneCallStateNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(linphoneCallState:)
                                                 name:kLinphoneCallUpdate
                                               object:nil];
}

- (void) removeLinphoneCallStateNotification {  
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kLinphoneCallUpdate
                                                  object:nil];
}

- (void) linphoneCallState:(NSNotification*)notif {
    LinphoneCallState state = [[notif.userInfo objectForKey: @"state"] intValue];
    NSString *message = [notif.userInfo objectForKey:@"message"];
    switch (state) {
        case LinphoneCallIncomingReceived:
            [SIPDomainDelegate linphoneCallState:@"LinphoneCallIncomingReceived" message:message];
            break;
        case LinphoneCallEnd:
            [SIPDomainDelegate linphoneCallState:@"LinphoneCallEnd" message:message];
            break;
        case LinphoneCallError:
            [SIPDomainDelegate linphoneCallState:@"LinphoneCallError" message:message];
            break;
        case LinphoneCallOutgoingProgress:
            [SIPDomainDelegate linphoneCallState:@"LinphoneCallOutgoingProgress" message:message];
            break;
        case LinphoneCallOutgoingRinging:
            [SIPDomainDelegate linphoneCallState:@"LinphoneCallOutgoingRinging" message:message];
            break;
        case LinphoneCallStreamsRunning:
            [SIPDomainDelegate linphoneCallState:@"LinphoneCallStreamsRunning" message:message];
            break;
        default:
            break;
    }
}

- (void) acceptCall {
    LinphoneCall* call = linphone_core_get_current_call([LinphoneManager getLc]);
    [[LinphoneManager instance] acceptCall:call];
}

- (void) declineCall {
    if([LinphoneManager isLcReady]) {
        LinphoneCore* lc = [LinphoneManager getLc];
        LinphoneCall* currentcall = linphone_core_get_current_call(lc);
        if (linphone_core_is_in_conference(lc)) // In conference
        {
            linphone_core_terminate_conference(lc);
        } else if(currentcall != NULL) { // In a call
            linphone_core_terminate_call(lc, currentcall);
        } else {
            const MSList* calls = linphone_core_get_calls(lc);
            if (ms_list_size(calls) == 1) { // Only one call
                linphone_core_terminate_call(lc,(LinphoneCall*)(calls->data));
            }
        }
    }
}

-(void) endCall {
    if([LinphoneManager isLcReady]) {
        LinphoneCore* lc = [LinphoneManager getLc];
        LinphoneCall* currentcall = linphone_core_get_current_call(lc);
        if (linphone_core_is_in_conference(lc)) { // In conference
            linphone_core_terminate_conference(lc);
        } else if(currentcall != NULL) { // In a call
            linphone_core_terminate_call(lc, currentcall);
        } else {
            const MSList* calls = linphone_core_get_calls(lc);
            if (ms_list_size(calls) == 1) { // Only one call
                linphone_core_terminate_call(lc,(LinphoneCall*)(calls->data));
            }
        }
    } else {
        [LinphoneLogger logc:LinphoneLoggerWarning format:"Cannot trigger hangup button: Linphone core not ready"];
    }
}

- (float) qualityOfCall {
    //    4-5 = good quality
    //    3-4 = average quality
    //    2-3 = poor quality
    //    1-2 = very poor quality
    //    0-1 = can't be worse, mostly unusable
    float quality = 0;
    if ([LinphoneManager isLcReady]) {
        LinphoneCall *call = linphone_core_get_current_call([LinphoneManager getLc]);        
        if (call != NULL) {
            LinphoneCallState state = linphone_call_get_state(call);
            if (state == LinphoneCallStreamsRunning) {
                quality = linphone_call_get_average_quality(call);
            }
        }
    }
    return quality;
}

- (void) muteMicro:(BOOL) enable {
    linphone_core_mute_mic([LinphoneManager getLc], enable);
}

- (void) Speaker:(BOOL) enable {
    [[LinphoneManager instance] setSpeakerEnabled:enable]; //default function of linphone >>> COOL function
    //[self setSpeakerEnabled:enable];
}

//Re-write function of linphone
- (void) setSpeakerEnabled:(BOOL)enable
{
    [LinphoneManager instance].speakerEnabled = enable;
    
    if (enable)
    {
        UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
        AudioSessionSetProperty(kAudioSessionProperty_OverrideAudioRoute
                                , sizeof(audioRouteOverride)
                                , &audioRouteOverride);
        [LinphoneManager instance].bluetoothEnabled = FALSE;
    }
    else
    {
        UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_None;
        AudioSessionSetProperty(kAudioSessionProperty_OverrideAudioRoute
                                , sizeof(audioRouteOverride)
                                , &audioRouteOverride);
        
        if ([LinphoneManager instance].bluetoothAvailable)
        {
            UInt32 bluetoothInputOverride = [LinphoneManager instance].bluetoothAvailable;
            AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryEnableBluetoothInput, sizeof(bluetoothInputOverride), &bluetoothInputOverride);
        }
    }
}

- (void) textReceivedNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textReceivedEvent:)
                                                 name:kLinphoneTextReceived
                                               object:nil];
}

- (void) removetextReceivedNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kLinphoneTextReceived
                                                  object:nil];
}

- (void) sendPingPongMessage:(NSString*) sip_address type:(NSString*) type message:(NSString*) message {
    @try {
        LinphoneChatRoom* room = linphone_core_get_or_create_chat_room([LinphoneManager getLc], [sip_address UTF8String]);
        LinphoneChatMessage* msg = linphone_chat_room_create_message(room, [[NSString stringWithFormat:@"{\"mt\":\"%@\",\"ct\":\"%@\",\"dl\":\"2\"}", type, message] UTF8String]);
        linphone_chat_room_send_message2(room,msg , nil, nil);
    }
    @catch (NSException *exception) {
        NSLog(@"Send Ping Pong error");
    }
}

- (void) textReceivedEvent:(NSNotification *)notif {
    LinphoneAddress * from    = [[[notif userInfo] objectForKey:@"from_address"] pointerValue];
    //LinphoneChatRoom* room    = [[notif.userInfo objectForKey:@"room"] pointerValue];
    LinphoneChatMessage* chat = [[notif.userInfo objectForKey:@"message"] pointerValue];
    
    if(from == NULL || chat == NULL) {
        return;
    }
    
    @try {
        const char* c_message = linphone_chat_message_get_text(chat);
        NSString *message = [NSString stringWithFormat:@"%s", c_message];
        [SIPDomainDelegate linphoneTextReceivedEvent:message];
    }
    @catch (NSException *exception) {
     
    }
}

- (NSString*) getLinphoneAddress {
    if ([LinphoneManager isLcReady]) {
        LinphoneCall *call = linphone_core_get_current_call([LinphoneManager getLc]);
        const LinphoneAddress *addr = linphone_call_get_remote_address(call);
        char* lAddress = linphone_address_as_string_uri_only(addr);
        return [NSString stringWithFormat:@"%s", lAddress];
    }
    return @"";
}

- (void) linphoneCallSecurityUpdate {
    @try {
        const MSList *list = linphone_core_get_calls([LinphoneManager getLc]);
        while (list != NULL) {
            LinphoneCall *call = (LinphoneCall *)list->data;
            LinphoneMediaEncryption enc = linphone_call_params_get_media_encryption(linphone_call_get_current_params(call));
            if (enc == LinphoneMediaEncryptionZRTP) {
                linphone_call_set_authentication_token_verified(call, true);
            }
            list = list->next;
        }

    }
    @catch (NSException *exception) {
        
    }
}

#pragma mark - APIs Calling -

- (void)getSIPCallStatus:(NSDictionary *)parametersDic callback:(requestCompleteBlock)callback
{
    if (!parametersDic) {
        NSLog(@"%s: FAILED parametersDic NULL", __PRETTY_FUNCTION__);
        return;
    }
    void (^getSIPCallStatusCallBack)(BOOL success, NSString *message ,NSDictionary *response, NSError *error);
    getSIPCallStatusCallBack = callback;
    NSMutableDictionary *parameters = [parametersDic mutableCopy];
    [parameters setObject:API_SIP_CALL_STATUS forKey:kAPI];
    [parameters setObject:API_SIP_CALL_STATUS_VERSION forKey:kAPI_VERSION];
    
    [[SIPServerAdapter share] requestService:parameters tenantServer:YES callback:^(BOOL success, NSString *message, NSDictionary *response, NSError *error) {
        getSIPCallStatusCallBack(success, message, response, error);
    }];
}

//void (^updateSIPCallCallBack)(BOOL success, NSString *message ,NSDictionary *response, NSError *error);
//- (void)updateSIPCall:(NSDictionary *)parametersDic callback:(requestCompleteBlock)callback
//{
//    if (!parametersDic) {
//        NSLog(@"%s: FAILED parametersDic NULL", __PRETTY_FUNCTION__);
//        return;
//    }
//    
//    updateSIPCallCallBack = callback;
//    NSMutableDictionary *parameters = [parametersDic mutableCopy];
//    [parameters setObject:API_xxx forKey:kAPI];
//    [parameters setObject:API_xxx_VERSION forKey:kAPI_VERSION];
//    
//    [[SIPServerAdapter share] requestService:parameters tenantServer:YES callback:^(BOOL success, NSString *message, NSDictionary *response, NSError *error) {
//        updateSIPCallCallBack(success, message, response, error);
//    }];
//}


- (void) makeSIPCallAPI:(NSDictionary *)parametersDic callback:(requestCompleteBlock)callback {
    if (!parametersDic) {
        NSLog(@"%s: FAILED parametersDic NULL", __PRETTY_FUNCTION__);
        return;
    }
    void (^makeSIPCallAPICallBack)(BOOL success, NSString *message ,NSDictionary *response, NSError *error);
    makeSIPCallAPICallBack = callback;
    NSMutableDictionary *parameters = [parametersDic mutableCopy];
    [parameters setObject:API_SIP_MAKE_CALL forKey:kAPI];
    [parameters setObject:API_SIP_MAKE_CALL_VERSION forKey:kAPI_VERSION];
    
    [[SIPServerAdapter share] requestService:parameters tenantServer:YES callback:^(BOOL success, NSString *message, NSDictionary *response, NSError *error) {
        makeSIPCallAPICallBack(success, message, response, error);
    }];
}


- (void) updateReadyStatusSIPAPI:(NSDictionary *)parametersDic callback:(requestCompleteBlock)callback {
    if (!parametersDic) {
        NSLog(@"%s: FAILED parametersDic NULL", __PRETTY_FUNCTION__);
        return;
    }
    void (^updateReadyStatusSIPAPICallBack)(BOOL success, NSString *message ,NSDictionary *response, NSError *error);
    updateReadyStatusSIPAPICallBack = callback;
    NSMutableDictionary *parameters = [parametersDic mutableCopy];
    [parameters setObject:API_SIP_UPDATE_READY forKey:kAPI];
    [parameters setObject:API_SIP_UPDATE_READY_VERSION forKey:kAPI_VERSION];
    
    [[SIPServerAdapter share] requestService:parameters tenantServer:YES callback:^(BOOL success, NSString *message, NSDictionary *response, NSError *error) {
        updateReadyStatusSIPAPICallBack(success, message, response, error);
    }];
}


- (void) updateFailStatusSIPAPI:(NSDictionary *)parametersDic callback:(requestCompleteBlock)callback {
    if (!parametersDic) {
        NSLog(@"%s: FAILED parametersDic NULL", __PRETTY_FUNCTION__);
        return;
    }
    void (^updateFailStatusSIPAPICallBack)(BOOL success, NSString *message ,NSDictionary *response, NSError *error);
    updateFailStatusSIPAPICallBack = callback;
    NSMutableDictionary *parameters = [parametersDic mutableCopy];
    [parameters setObject:API_SIP_UPDATE_FAIL forKey:kAPI];
    [parameters setObject:API_SIP_UPDATE_FAIL_VERSION forKey:kAPI_VERSION];
    
    [[SIPServerAdapter share] requestService:parameters tenantServer:YES callback:^(BOOL success, NSString *message, NSDictionary *response, NSError *error) {
        updateFailStatusSIPAPICallBack(success, message, response, error);
    }];
}


- (void) updateEndStatusSIPAPI:(NSDictionary *)parametersDic callback:(requestCompleteBlock)callback {
    if (!parametersDic) {
        NSLog(@"%s: FAILED parametersDic NULL", __PRETTY_FUNCTION__);
        return;
    }
    void (^updateEndStatusSIPAPICallBack)(BOOL success, NSString *message ,NSDictionary *response, NSError *error);
    updateEndStatusSIPAPICallBack = callback;
    NSMutableDictionary *parameters = [parametersDic mutableCopy];
    [parameters setObject:API_SIP_UPDATE_END forKey:kAPI];
    [parameters setObject:API_SIP_UPDATE_END_VERSION forKey:kAPI_VERSION];
    
    [[SIPServerAdapter share] requestService:parameters tenantServer:YES callback:^(BOOL success, NSString *message, NSDictionary *response, NSError *error) {
        updateEndStatusSIPAPICallBack(success, message, response, error);
    }];
}


- (void) updateTimeOutStatusSIPAPI:(NSDictionary *)parametersDic callback:(requestCompleteBlock)callback {
    if (!parametersDic) {
        NSLog(@"%s: FAILED parametersDic NULL", __PRETTY_FUNCTION__);
        return;
    }
    void (^updateTimeOutStatusSIPAPICallBack)(BOOL success, NSString *message ,NSDictionary *response, NSError *error);
    updateTimeOutStatusSIPAPICallBack = callback;
    NSMutableDictionary *parameters = [parametersDic mutableCopy];
    [parameters setObject:API_SIP_UPDATE_TIMEOUT forKey:kAPI];
    [parameters setObject:API_SIP_UPDATE_TIMEOUT_VERSION forKey:kAPI_VERSION];
    
    [[SIPServerAdapter share] requestService:parameters tenantServer:YES callback:^(BOOL success, NSString *message, NSDictionary *response, NSError *error) {
        updateTimeOutStatusSIPAPICallBack(success, message, response, error);
    }];
}

@end
