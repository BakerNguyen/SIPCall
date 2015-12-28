//
//  InitIncomingCallView.m
//  KryptoChat
//
//  Created by Ba (Baker) V. NGUYEN on 11/4/14.
//  Copyright (c) 2014 mTouche. All rights reserved.
//

#import "InitIncomingCallView.h"
#import "BWStatusBarOverlay.h"
#include <stdlib.h>
#import "IncomingCallView.h"

@interface InitIncomingCallView ()

@end

@implementation InitIncomingCallView
@synthesize userJid;

+(InitIncomingCallView *)share{
    static dispatch_once_t once;
    static InitIncomingCallView * share;
    dispatch_once(&once, ^{
        share = [self new];
        [share.view changeWidth:[CWindow share].width
                         Height:[CWindow share].height];

    });
    return share;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [SIPFacade share].SIPDelegate = self;
    [SIPFacade share].initIncomingCallViewDelegate = self;
    
    if ([[SIPFacade share] checkProxyConfigIsRegistered]) {
        [self readyForReceiveCall];
    } else {
        [[SIPFacade share] registerSIPAccount];
        [[SIPFacade share] registrationUpdateNotification];
    }

    [[SIPFacade share] linphoneCallStateNotification];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[SIPFacade share] removeRegistrationUpdateNotification];
}

- (void) readyForReceiveCall {
    Contact *friendInfo = [[ContactFacade share] getContact:userJid];
    [[SIPFacade share] setMaskingIdFriend:friendInfo.maskingid];    
    NSDictionary *dict = @{SIP_CALLER_MASKINGID : [[SIPFacade share] getMaskingIdFriend], SIP_CMD : @"READY"};
    [[SIPFacade share] updateReadyStatusSIPAPI:dict];
}

- (void)linphoneRegistrationSuccessful {
    [[SIPFacade share] removeRegistrationUpdateNotification];
    [self readyForReceiveCall];
}

- (void)linphoneRegistrationFailed {
//    NSDictionary *dict = @{ SIP_CALLER_MASKINGID : [[SIPFacade share] getMaskingIdFriend]
//                            , SIP_RECIPIENT_MASKINGID : [[ContactFacade share] getMaskingId]
//                            , SIP_CMD : @"FAIL"
//                            , SIP_REMARKS : @"Call Fail"};
//    [[SIPFacade share] updateFailStatusSIPAPI:dict];
    [[SIPFacade share] removeRegistrationUpdateNotification];
}

- (void) linphoneCallIncomingReceived {
    [[SIPFacade share] removeLinphoneCallStateNotification];
    [IncomingCallView share].userJid = userJid;
    [[ChatFacade share] stopCurrentAudioPlaying:nil];
    [[CWindow share] showIncomingCallView];
    [self.view removeFromSuperview];
}

- (void) linphoneCallEnded {
}

- (void) linphoneCallBusy {
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
