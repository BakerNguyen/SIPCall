//
//  AudioRecorder.m
//  KryptoChat
//
//  Created by TrungVN on 5/12/14.
//  Copyright (c) 2014 mTouche. All rights reserved.
//

#import "AudioRecorder.h"
#import "ChatView.h"


@implementation AudioRecorder{
    NSTimer *startRecordingTimer;
    ChatView* chatView;
}


@synthesize iRecordStage;
@synthesize progressTime;
@synthesize audioRecorder, audioPlayer;
@synthesize btnCancel, audioTouch, lblAlert;
@synthesize audioPath;

-(void) didMoveToSuperview{
    [self setInitialStage];
    chatView = [ChatView share];
    btnCancel.enabled = TRUE;
    
    progressTime.layer.borderWidth = 1;
    progressTime.layer.borderColor = COLOR_170170170.CGColor;
    
    progressTime.backgroundColor = [UIColor whiteColor];
    progressTime.trackTintColor = [UIColor whiteColor];
    progressTime.progressTintColor = COLOR_170170170;
    progressTime.thicknessRatio = 0.2;
    progressTime.layer.cornerRadius = progressTime.width/2;
    
    lblAlert.layer.cornerRadius = 5;
    
    [self hide];
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:audioTouch];
    
    if (touchPoint.x > 0 && touchPoint.x < audioTouch.width ) {
        if (touchPoint.y > 0 && touchPoint.y < audioTouch.height) {
            audioTouch.highlighted = TRUE;
            btnCancel.enabled = FALSE;
            [chatView.notifyChat hideRedAlert];
            startRecordingTimer = [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(startRecording) userInfo:nil repeats:NO];
            NSRunLoop *runner = [NSRunLoop currentRunLoop];
            [runner addTimer:startRecordingTimer forMode: NSDefaultRunLoopMode];
        }
    }
}

-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:audioTouch];
    
    if(audioRecorder.currentTime > 0){
        if(touchPoint.x < 0 || touchPoint.x > audioTouch.width){
            iRecordStage = RecordStagePausing;
            [chatView.notifyChat showRedAlert:AUDIO_RELEASE_TO_CANCEL];
        }
        else if(touchPoint.y < 0 || touchPoint.y > audioTouch.height){
            iRecordStage = RecordStagePausing;
            [chatView.notifyChat showRedAlert:AUDIO_RELEASE_TO_CANCEL];
        }
        else{
            iRecordStage = RecordStageRecording;
            [chatView.notifyChat hideRedAlert];
        }
    }
}

-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [self handleTouchEndedEvent];
}

-(void) handleTouchEndedEvent{
    audioTouch.highlighted = FALSE;
    [startRecordingTimer invalidate];
    startRecordingTimer = nil;
    if(iRecordStage == RecordStagePausing){
        [self stopRecording];
        [self setInitialStage];
        [chatView.notifyChat showRedAlert:AUDIO_VOICE_CANCEL];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [chatView.notifyChat hideRedAlert];
        });
        return;
    }
    if(iRecordStage != RecordStageRecording){
        [self setInitialStage];
        return;
    }
    
    if(audioRecorder.currentTime > 1.0){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [chatView.notifyChat hideRedAlert];
            [self sendFile];
        });
    }
    else{
        [self setInitialStage];
    }
    
    [self stopRecording];
}

-(void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    [self touchesEnded:touches withEvent:event];
}

-(void) setInitialStage {
    iRecordStage = RecordStageInitial;
    audioRecorder = nil;
    audioPlayer = nil;
    progressTime.progress = 0;
    progressTime.hidden = TRUE;
    lblAlert.text = AUDIO_HOLD_TO_TALK;
    btnCancel.enabled = TRUE;
    
    NSArray *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDirectory = [documentPath objectAtIndex:0];
    audioPath = [docDirectory stringByAppendingPathComponent:AUDIO_FILE];
    [[NSFileManager new] removeItemAtPath:audioPath error:nil];
}

-(void) startRecording {
    if ([SIPFacade share].isCalling || [SIPFacade share].isOnCall)
    {
        [[CAlertView new] showError:mERROR_CANNOT_SEND_VIDEO_OR_RECORD_AUDIO];
        return;
    }
    
    [[ChatFacade share] stopCurrentAudioPlaying:nil];
    
    NSError *error;
    // Recording settings
    NSMutableDictionary *settings = [NSMutableDictionary dictionary];
    [settings setValue :[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    [settings setValue:[NSNumber numberWithFloat:8000.0] forKey:AVSampleRateKey];
    [settings setValue:[NSNumber numberWithInt: 1] forKey:AVNumberOfChannelsKey];
    [settings setValue :[NSNumber numberWithInt:8] forKey:AVLinearPCMBitDepthKey];
    [settings setValue :[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsBigEndianKey];
    [settings setValue :[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsFloatKey];
    //Encoder
    [settings setValue :[NSNumber numberWithInt:12000] forKey:AVEncoderBitRateKey];
    [settings setValue :[NSNumber numberWithInt:8] forKey:AVEncoderBitDepthHintKey];
    [settings setValue :[NSNumber numberWithInt:8] forKey:AVEncoderBitRatePerChannelKey];
    [settings setValue :[NSNumber numberWithInt:AVAudioQualityMin] forKey:AVEncoderAudioQualityKey];
    
    if(audioRecorder != nil) {
        [audioRecorder stop];
        audioRecorder = nil;
    }
    
    // create AVAudioSession, to fixed record before called MPMoviePlayerViewController
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryRecord error:&error];
    [audioSession setActive:YES error:&error];
    
    // Create recorder
    NSURL *url = [NSURL fileURLWithPath:audioPath];
    audioRecorder = [[AVAudioRecorder alloc] initWithURL:url settings:settings error:&error];
    
    if (error != nil || ![audioRecorder prepareToRecord]){
        NSLog(@"%s %@",__PRETTY_FUNCTION__, [error localizedDescription]);
        return;
    }
    
    audioRecorder.delegate = self;
    audioRecorder.meteringEnabled = YES;
    
    iRecordStage = RecordStageRecording;
    [audioRecorder record];
    [self updateRecordProcess];
}

-(void) stopRecording {
    btnCancel.enabled = TRUE;

    [audioRecorder stop];
    audioRecorder = nil;
    
    iRecordStage = RecordStageRecorded;
    lblAlert.text = AUDIO_HOLD_TO_TALK;
    
    NSError* error;
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:&error];
    [audioSession setActive:YES error:&error];
}

-(void) pauseRecording {
    [audioRecorder pause];
    progressTime.hidden = FALSE;
    btnCancel.enabled = FALSE;
}

-(void) updateRecordProcess {
    if(iRecordStage == RecordStageRecording || iRecordStage == RecordStageCancel){
        progressTime.hidden = FALSE;
        btnCancel.enabled = FALSE;
        int secs = (int)audioRecorder.currentTime;
        lblAlert.text = [NSString stringWithFormat:@"%02d:%02d", secs / 60 % 60, secs % 60];
        [progressTime setProgress:(audioRecorder.currentTime/AUDIO_NOTE_RECORD_MAX_SEC) animated:TRUE];
        if (audioRecorder.currentTime <= AUDIO_NOTE_RECORD_MAX_SEC && audioRecorder != nil) {
            [self performSelector:@selector(updateRecordProcess) withObject:nil afterDelay:1.0f];
        }
        else
        {
            audioTouch.highlighted = FALSE;
            if(audioRecorder.currentTime > 1.0 && iRecordStage != RecordStageCancel){
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self sendFile];
                });
            }
            
            [progressTime setProgress:0.0 animated:TRUE];
            [self stopRecording];

        }
    }
    else if (iRecordStage == RecordStagePausing){
        [self pauseRecording];
    }
}

-(void)disappearNotifyChat{
    [chatView.notifyChat hideRedAlert];
}

-(void) audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag{
    btnCancel.enabled = TRUE;
}

-(void) checkAccessMicrophonePermission
{
    if ([SIPFacade share].isCalling || [SIPFacade share].isOnCall)
    {
        [[CAlertView new] showError:mERROR_CANNOT_SEND_VIDEO_OR_RECORD_AUDIO];
        return;
    }
    
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    switch (authStatus) {
        case AVAuthorizationStatusDenied:
            [[CAlertView new] showInfo:_ALERT_SATAY_DOES_NOT_HAVE_ACCESS_TO_YOUR_MICROPHONE];
            break;
        case AVAuthorizationStatusAuthorized:
            [self show];
            break;
        case AVAuthorizationStatusNotDetermined:{
            [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
                NSLog(@"requestRecordPermission");
                if (granted) {
                    NSLog(@"Permission granted");
                    [self show];
                }
            }];
        }
            break;
        default:
            break;
    }
}

-(void) show{
    if(self.y < chatView.view.height)
        return;
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^(void){
        [chatView.chatfield hideKeyboard];
        [chatView.notifyChat redrawNotify];
        //NSLog(@"Violet before x: %f y: %f", self.x, self.y);
        [self changeXAxis:0 YAxis:chatView.view.height - self.height];
        ///NSLog(@"Violet after x: %f y: %f", self.x, self.y);
        [chatView.chatfield animateXAxis:0 YAxis:chatView.view.height - self.height];
        [chatView.bubbleScroll changeWidth:chatView.bubbleScroll.width Height:chatView.chatfield.y - chatView.notifyChat.height];
        [chatView.bubbleScroll scrollToBottom];
    }];
}

-(void) hide{
    [self changeXAxis:0 YAxis:self.superview.height];
}

-(IBAction) cancelAudioRecorder{
    [self setInitialStage];
    [chatView.chatfield hideKeyboard];
    [chatView.chatfield.txtChatView becomeFirstResponder];
}

-(void) sendFile{
    if(iRecordStage == RecordStageRecorded){
        [[ChatFacade share] sendAudio:audioPath chatboxId:chatView.chatBoxID];
    }
    [self setInitialStage];
}

@end
