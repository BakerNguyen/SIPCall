//
//  VoiceCallView.h
//  KryptoChat
//
//  Created by Ba (Baker) V. NGUYEN on 7/30/14.
//  Copyright (c) 2014 mTouche. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface VoiceCallView : UIViewController <AVAudioRecorderDelegate, AVAudioPlayerDelegate, SIPDelegate, VoiceCallViewDelegate>

@property (retain, nonatomic) IBOutlet UIButton *btnEndCall;

@property (weak, nonatomic) IBOutlet UILabel *lblFriendName;
@property (weak, nonatomic) IBOutlet UILabel *lblDuration;
@property (weak, nonatomic) IBOutlet UIImageView *imgAvatar;

@property (weak, nonatomic) IBOutlet UILabel *lblNetworkQuality;
@property (weak, nonatomic) IBOutlet UILabel *lblNetworkStatus;
@property (strong, nonatomic)  UILabel *lblDurationMinimize;

@property (weak, nonatomic) IBOutlet UIButton *btnMinimize;
@property (weak, nonatomic) IBOutlet UIButton *btnSpeaker;
@property (weak, nonatomic) IBOutlet UIButton *btnMute;

@property (nonatomic, retain) NSString* userJid;
@property (nonatomic, assign) BOOL isReceiver, isPauseTone;
@property CAlertView *busyAlertView;

+(VoiceCallView *)share;
- (IBAction)action_mute:(id)sender;
- (IBAction)action_Speaker:(id)sender;
- (IBAction)action_Minimize:(id)sender;
- (IBAction)action_endCall:(id)sender;

- (void) resetSpeakerMute;

@end
