//
//  CallLogCell.m
//  KryptoChat
//
//  Created by Ba (Baker) V. NGUYEN on 10/17/14.
//  Copyright (c) 2014 mTouche. All rights reserved.
//

#import "CallLogCell.h"
#import "VoiceCallView.h"
#import "ChatView.h"

@implementation CallLogCell

@synthesize imageCallLog, statusCallLog;
@synthesize cellID;

- (void)initCallCell:(NSString *)messageID
{
    Message *message = [[AppFacade share] getMessage:messageID];
    if (!message) {
        return;
    }
    
    NSString *imageName = @"";
    
    switch ([[SIPFacade share] sipCallStatus:message.messageStatus]) {
        case SIPCallStatusCallOk:
            imageName = @"c_bb_call";
            break;
        case SIPCallStatusCallBusy:
        case SIPCallStatusCallFailed:
        case SIPCallStatusCancelled:
        case SIPCallStatusMissed:
        case SIPCallStatusNoAnswer:
            imageName = @"c_bb_call_canceled";
            break;
        default:
            break;
    }
    
    imageCallLog.image = [UIImage imageNamed:imageName];
    statusCallLog.text = message.messageContent;
}

- (IBAction)callBubbleAction:(id)sender
{
    if([ChatView share].bubbleScroll.popupisShowing == TRUE)
        return;
    
    if ([[ContactFacade share] isAccountRemoved]) {
        [[CAlertView new] showError:ERROR_ACCOUNT_REMOVED];
        return;
    }
    
    if([[ContactFacade share] isBlocked:[ChatView share].chatBoxID]){
        [[ChatView share] showAlertBlocked];
        return;
    }
    if (![[NotificationFacade share] isInternetConnected]){
        [[CAlertView new] showError:NO_INTERNET_CONNECTION_TRY_LATER];
        return;
    }
    
    if ([SIPFacade share].isCalling) {
        [[CAlertView new] showInfo:SIP_ERROR_CANNOT_CALL_WHILE_IN_ANOTHER_CALL];
        return;
    }
    
    if ([[ContactFacade share] isBlocked:[ChatView share].chatBoxID] || (![[ContactFacade share] isFriend:[ChatView share].chatBoxID])){
        [[CAlertView new] showError:mERROR_NOT_FRIEND_CALL];
        return;
    }
    
    if (!IS_OS_8_OR_LATER) {
        [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
            if (granted) {
                NSLog(@"Permission microphone granted");
            }
            else {
                NSLog(@"Permission microphone denied");
                [[CAlertView new] showError:_ALERT_SATAY_DOES_NOT_HAVE_ACCESS_TO_YOUR_MICROPHONE];
                return;
            }
        }];
    }
    
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    if(authStatus == AVAuthorizationStatusDenied){
        [[CAlertView new] showError:_ALERT_SATAY_DOES_NOT_HAVE_ACCESS_TO_YOUR_MICROPHONE];
        return;
    }
    
    [[SIPFacade share] setStatusOfCall:YES];
    [VoiceCallView share].userJid = cellID;
    [SIPFacade share].isWhoMakeCall = YES;
    [[ChatFacade share] stopCurrentAudioPlaying:nil];
    [[CWindow share] showVoiceCallView];
    [[LogFacade share] createEventWithCategory:Conversation_Category
                                        action:freeCallContact_Action
                                         label:labelAction];
}

@end
