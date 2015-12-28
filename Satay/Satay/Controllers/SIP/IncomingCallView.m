//
//  IncomingCallView.m
//  KryptoChat
//
//  Created by Ba (Baker) V. NGUYEN on 7/30/14.
//  Copyright (c) 2014 mTouche. All rights reserved.
//

#import "IncomingCallView.h"
#import "VoiceCallView.h"
#import "CallTimeOutView.h"

@interface IncomingCallView ()

@end

@implementation IncomingCallView
@synthesize lblFriendName, lblIncomingCall, btnAnswer, btnDecline, imgAvatar;
@synthesize userJid;
BOOL isMissCalled;
NSTimer *callPhoneBookTimer;

+(IncomingCallView *)share {
    static dispatch_once_t once;
    static IncomingCallView * share;
    dispatch_once(&once, ^{
        share = [self new];
        [share.view changeWidth:[CWindow share].width
                         Height:[CWindow share].height];

    });
    return share;
}

- (void)viewDidLoad
{
    [super viewDidLoad];   
    [self set_Style_for_Controler];
}

- (void)viewWillAppear:(BOOL)animated {
    [[VoiceCallView share].busyAlertView close];
    [[VoiceCallView share] resetSpeakerMute];
    [[CallTimeOutView share].view removeFromSuperview];
    [SIPFacade share].SIPDelegate = self;
    [NotificationFacade share].sipDelegate = self;
    [SIPFacade share].phoneCallCenter = [[CTCallCenter alloc] init];
    [[SIPFacade share] handlePhoneBookCall];
    
    [SIPFacade share].isWhoMakeCall = NO;
    [SIPFacade share].isMissCalled = YES;
    [SIPFacade share].isOnCall = YES;
    [self showUserInfor];    
    [[SIPFacade share] linphoneCallStateNotification];
    [SIPFacade share].friend_Jid = userJid;
    [SIPFacade share].seconds = 0;
    [SIPFacade share].minutes = 0;
}

- (void)viewWillDisappear:(BOOL)animated {
    [[ChatFacade share] reloadChatBoxList];
    [callPhoneBookTimer invalidate];
    [[SIPFacade share] removetextReceivedNotification];
}

- (void) viewDidAppear:(BOOL)animated {
    [self performSelector:@selector(dismissKeyboard) withObject:nil afterDelay:1];
}

- (void) dismissKeyboard {
    [[CWindow share] endEditing:YES];
}

- (void) noInternetconnection {
    if ([[ContactFacade share] isAccountRemoved]) {
        [[CAlertView new] showError:ERROR_ACCOUNT_REMOVED];
        return;
    }
    
    [[CAlertView new] showError:NO_INTERNET_CONNECTION_TRY_LATER];
    [[SIPFacade share] endCall];
    [SIPFacade share].isOnCall = NO;
    [self.view removeFromSuperview];
}

- (void) incomingPhoneBookCall {
    [[SIPFacade share] endCall];
    [self.view removeFromSuperview];
}

- (void) linphoneCallBusy {    
}

- (void) linphoneCallEnded {
    [self.view removeFromSuperview];
}

- (IBAction)action_Decline:(id)sender {
    [SIPFacade share].isMissCalled = NO;
    [[SIPFacade share] declineCall];
    [[SIPFacade share] removeLinphoneCallStateNotification];
    [self.view removeFromSuperview];
}

- (IBAction)action_Answer:(id)sender {
    [[SIPFacade share] acceptCall];
    [[SIPFacade share] removeLinphoneCallStateNotification];
    [VoiceCallView share].userJid = userJid;
    [VoiceCallView share].isReceiver = YES;
    [VoiceCallView share].lblDuration.text = @"";
    [[CWindow share] showVoiceCallView];
    [self.view removeFromSuperview];
}

- (void) set_Style_for_Controler {
    //set style for button Answer
    btnAnswer.layer.borderWidth = 1;
    btnAnswer.layer.borderColor = COLOR_15224088.CGColor;
    btnAnswer.layer.cornerRadius = 15;
    btnAnswer.clipsToBounds = YES;
    [btnAnswer setBackgroundImage:[UIImage imageFromColor:COLOR_15224088]
                          forState:UIControlStateNormal];
    [btnAnswer setBackgroundImage:[UIImage imageFromColor:COLOR_2220431]
                          forState:UIControlStateHighlighted];
    
    //set style for button Decline
    btnDecline.layer.borderWidth = 1;
    btnDecline.layer.borderColor = COLOR_2509696.CGColor;
    btnDecline.layer.cornerRadius = 15;
    btnDecline.clipsToBounds = YES;
    [btnDecline setBackgroundImage:[UIImage imageFromColor:COLOR_2509696]
                           forState:UIControlStateNormal];
    [btnDecline setBackgroundImage:[UIImage imageFromColor:COLOR_2514242]
                           forState:UIControlStateHighlighted];
    
    //Avatar image
    imgAvatar.layer.masksToBounds = YES;
    imgAvatar.layer.cornerRadius = 62;
}

- (void)showUserInfor
{
    Contact *friendInfo = [[ContactFacade share] getContact:userJid];    
    lblFriendName.text = [[ContactFacade share] getContactName:userJid];
    if ((friendInfo.avatarURL != nil) && (![friendInfo.avatarURL isEqualToString:@""])) {
        imgAvatar.image = [[ContactFacade share] updateContactAvatar:friendInfo.avatarURL];
    }
}

@end
