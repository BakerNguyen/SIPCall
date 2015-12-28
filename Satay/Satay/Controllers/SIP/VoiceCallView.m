//
//  VoiceCallView.m
//  KryptoChat
//
//  Created by Ba (Baker) V. NGUYEN on 7/30/14.
//  Copyright (c) 2014 mTouche. All rights reserved.
//

#import "VoiceCallView.h"
#import "CallTimeOutView.h"
#import "BWStatusBarOverlay.h"

@interface VoiceCallView () {
    AVAudioRecorder *recorder;
    AVAudioPlayer *player;
    NSURL *outputFileURL;
    
    int seconds, minutes;
    NSTimer *checkLinphoneCallStateTimer;
    BOOL isReceiverConnectionLive;
}
@end

@implementation VoiceCallView
@synthesize userJid, lblDuration, lblFriendName, lblNetworkQuality, lblNetworkStatus, lblDurationMinimize;
@synthesize btnMinimize, btnMute, btnSpeaker, btnEndCall, imgAvatar;
@synthesize isReceiver, isPauseTone;
@synthesize busyAlertView;

+ (VoiceCallView *)share {
    static dispatch_once_t once;
    static VoiceCallView *share;
    
    dispatch_once(&once, ^{
        share = [self new];
        [share.view changeWidth:[CWindow share].width
                         Height:[CWindow share].height];

    });
    return share;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //set style for button EndCall
    [self set_Style_for_Controler];
    [self registerBWStatusBarOverlay];
    lblDurationMinimize = [UILabel new];
    player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSBundle.mainBundle URLForResource:@"ringback" withExtension:@"wav"] error:NULL];
    player.volume = 15;
    
    [btnMinimize alignCenter];
    [btnMute alignCenter];
    [btnSpeaker alignCenter];
    [self initRecoder];
}

- (void)viewWillAppear:(BOOL)animated {
    [SIPFacade share].SIPDelegate = self;
    [SIPFacade share].voiceCallViewDelegate = self;
    [NotificationFacade share].sipDelegate = self;
    [SIPFacade share].phoneCallCenter = [[CTCallCenter alloc] init];
    [[SIPFacade share] handlePhoneBookCall];    
    [BWStatusBarOverlay dismiss];
    //Show receiver infomation
    [self showUserInfor];
    
    //Register notification
    [[SIPFacade share] linphoneCallStateNotification];
    [[SIPFacade share] checkProxyConfig];
    [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
    [self commonConfig];
    [self startRecoder];
}

- (void) viewDidAppear:(BOOL)animated {
    [self performSelector:@selector(dismissKeyboard) withObject:nil afterDelay:1];
}

- (void) dismissKeyboard {
    [[CWindow share] endEditing:YES];
}

- (void) commonConfig {
    lblNetworkQuality.text = @"";
    lblNetworkStatus.text = @"";
    //Display network quality.
    if ([SIPFacade share].isWhoMakeCall) {
        [self performSelector:@selector(playRingBackTone) withObject:nil afterDelay:3];
    }
}

- (void) playRingBackTone {
    if (!isPauseTone) {
        [player play];
        [self performSelector:@selector(playRingBackTone) withObject:nil afterDelay:3];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    self.view.hidden = NO;
    [[ChatFacade share] reloadChatBoxList];
    [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
    [self stopRecoder];
}

- (void)linphoneRegistrationSuccessful {
    [[SIPFacade share] startCall];
    [[SIPFacade share] removeRegistrationUpdateNotification];
}

- (void)linphoneRegistrationFailed {
    isPauseTone = YES;
    [[SIPFacade share] setStatusOfCall:NO];
    [BWStatusBarOverlay dismiss];
    [[CAlertView new] showError:SIP_REGISTER_FAILED];
    [self.view removeFromSuperview];
    [[SIPFacade share] removeRegistrationUpdateNotification];
}


- (void)linphoneCallTimeOut {
    [BWStatusBarOverlay dismiss];
    [self.view removeFromSuperview];
    [CallTimeOutView share].userJid = userJid;
    [[CWindow share] showCallTimeOutView];
    [[SIPFacade share] setStatusOfCall:NO];
}

- (void)linphoneCallBusy {
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [BWStatusBarOverlay dismiss];
        [self.view removeFromSuperview];
        if (busyAlertView == nil) {
            busyAlertView = [CAlertView new];
        }
        [busyAlertView showInfo:[NSString stringWithFormat:SIP_CALL_FRIEND_BUSY, lblFriendName.text]];
        if ([SIPFacade share].isBusy) {
            [[SIPFacade share] addCallLogInfo:userJid isCaller:YES Status:SIPCallStatusCallBusy message:@""];
        }
        [[SIPFacade share] setStatusOfCall:NO];
    }];
}

- (void)linphoneCallDeclined {
    [BWStatusBarOverlay dismiss];
    [self.view removeFromSuperview];
}

- (void)linphoneCallEnded {
    [BWStatusBarOverlay dismiss];
    [self.view removeFromSuperview];
}

- (void) CallEnded {
    [self linphoneCallEnded];
}

- (void)linphoneCallOutgoingRinging {
    lblDuration.text = SIP_CALLING;
    [player stop];
    isPauseTone = YES;
    [self stopRecoder];
}

//- (void) linphoneCallIncomingReceived {   
//}

- (void) noInternetconnection {
    if ([SIPFacade share].isOnCall || [SIPFacade share].isCalling) {
        [[CAlertView new] showError:INTERNET_CONNECTION_NOT_STABLE];
        [[SIPFacade share] endCall];
        [self.view removeFromSuperview];
    }
}

- (void) incomingPhoneBookCall {
    [[SIPFacade share] endCall];
    [self.view removeFromSuperview];
}

- (IBAction)action_endCall:(id)sender {
    isPauseTone = YES;
    [[SIPFacade share] endCall];
    [self.view removeFromSuperview];
}

- (IBAction)action_mute:(id)sender {
    if ([btnMute.accessibilityIdentifier isEqualToString:@"mute"]) {
        [btnMute setImage:[UIImage imageNamed:@"call_i_speaker_t.png"] forState:UIControlStateNormal];
        btnMute.accessibilityIdentifier = @"mute_click";
        [[SIPFacade share] muteMicro:YES];
    } else {
        [btnMute setImage:[UIImage imageNamed:@"call_i_speaker.png"] forState:UIControlStateNormal];
        btnMute.accessibilityIdentifier = @"mute";
        [[SIPFacade share] muteMicro:NO];
    }
}

- (IBAction)action_Speaker:(id)sender {
    if ([btnSpeaker.accessibilityIdentifier isEqualToString:@"speaker"]) {
        [btnSpeaker setImage:[UIImage imageNamed:@"call_i_mute_t.png"] forState:UIControlStateNormal];
        btnSpeaker.accessibilityIdentifier = @"speaker_click";
        [[SIPFacade share] Speaker:YES];
    } else {
        [btnSpeaker setImage:[UIImage imageNamed:@"call_i_mute.png"] forState:UIControlStateNormal];
        btnSpeaker.accessibilityIdentifier = @"speaker";
        [[SIPFacade share] Speaker:NO];
    }
}

- (IBAction)action_Minimize:(id)sender {
    [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
    
    //Red bar
    lblDurationMinimize.text = @"";
    [BWStatusBarOverlay showSuccessWithMessage:@"Tap to return Call Screen" duration:360000 animated:YES];
    lblDurationMinimize.frame = CGRectMake(250, 5, 100, 10);
    [lblDurationMinimize setFont:[UIFont systemFontOfSize:12]];
    lblDurationMinimize.textColor = [UIColor whiteColor];
    [[BWStatusBarOverlay shared].contentView addSubview:lblDurationMinimize];
    [BWStatusBarOverlay shared].textLabel.textColor = [UIColor whiteColor];
    [[BWStatusBarOverlay shared].contentView setBackgroundColor:[UIColor redColor]];
    
    self.view.hidden = YES;
    [SIPFacade share].isMinimize = YES;
    [[SIPFacade share] fireCallChangeState];
}

- (void) registerBWStatusBarOverlay {
    [BWStatusBarOverlay setActionBlock:^{
        self.view.hidden = NO;
        [[CWindow share].rootViewController.view endEditing:YES];
        [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
        [BWStatusBarOverlay dismiss];
        [[CWindow share] hidePopupWindow:YES];
        [SIPFacade share].isMinimize = NO;
    }];
}

- (void) set_Style_for_Controler {
    //set style for button EndCall
    btnEndCall.layer.cornerRadius = 15;
    btnEndCall.clipsToBounds = YES;
    [btnEndCall setBackgroundImage:[UIImage imageFromColor:COLOR_2509696]
                          forState:UIControlStateNormal];
    [btnEndCall setBackgroundImage:[UIImage imageFromColor:COLOR_2514242]
                          forState:UIControlStateHighlighted];
    
    //Avatar image
    imgAvatar.layer.masksToBounds = YES;
    imgAvatar.layer.cornerRadius = 62;
}

- (void) resetSpeakerMute {
    //Mute
    [btnMute setImage:[UIImage imageNamed:@"call_i_speaker.png"] forState:UIControlStateNormal];
    btnMute.accessibilityIdentifier = @"mute";
    [[SIPFacade share] muteMicro:NO];
    //Speaker
    [btnSpeaker setImage:[UIImage imageNamed:@"call_i_mute.png"] forState:UIControlStateNormal];
    btnSpeaker.accessibilityIdentifier = @"speaker";
    [[SIPFacade share] Speaker:NO];
}

- (void)showUserInfor
{
    Contact *friendInfo = [[ContactFacade share] getContact:userJid];
    [SIPFacade share].friend_Jid = friendInfo.jid;
    [[SIPFacade share] setMaskingIdFriend:friendInfo.maskingid];
    lblFriendName.text = [[ContactFacade share] getContactName:userJid];
    imgAvatar.image = [UIImage imageNamed:@"c_empty.png"];
    if ((friendInfo.avatarURL != nil) && (![friendInfo.avatarURL isEqualToString:@""])) {
        imgAvatar.image = [[ContactFacade share] updateContactAvatar:friendInfo.avatarURL];
    }
}

- (void) initRecoder {
    // Set the audio file
    NSArray *pathComponents = [NSArray arrayWithObjects:
                               [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
                               @"MyTempAudio.m4a",
                               nil];
    outputFileURL = [NSURL fileURLWithPathComponents:pathComponents];
    
    // Setup audio session
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    
    // Define the recorder setting
    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
    
    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    [recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
    [recordSetting setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];
    
    // Initiate and prepare the recorder
    recorder = [[AVAudioRecorder alloc] initWithURL:outputFileURL settings:recordSetting error:nil];
    recorder.delegate = self;
    recorder.meteringEnabled = YES;
    [recorder prepareToRecord];
}

- (void) startRecoder {
    if (!recorder.recording) {
        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setActive:YES error:nil];
        // Start recording
        [recorder record];
    }
}

- (void) stopRecoder {
    //remove file
    [[NSFileManager defaultManager] removeItemAtURL:outputFileURL error:nil];
    if (recorder.recording) {
        // Stop recording
        [recorder stop];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
