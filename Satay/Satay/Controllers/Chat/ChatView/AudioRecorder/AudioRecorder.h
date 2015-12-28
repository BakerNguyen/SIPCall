//
//  AudioRecorder.h
//  KryptoChat
//
//  Created by TrungVN on 5/12/14.
//  Copyright (c) 2014 mTouche. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>


#define AUDIO_NOTE_RECORD_MAX_SEC 30
#define AUDIO_FILE @"TempAudio.m4a"

typedef enum {
    RecordStageRecorded,
    RecordStageRecording,
    RecordStagePausing,
    RecordStageInitial,
    RecordStageCancel
} RecordStage;

@interface AudioRecorder : UIView <AVAudioRecorderDelegate>

@property (nonatomic, retain) IBOutlet UIButton* btnCancel;
@property (nonatomic, retain) IBOutlet UIImageView* audioTouch;
@property (nonatomic, strong) IBOutlet DACircularProgressView* progressTime;
@property (nonatomic, retain) IBOutlet UILabel *lblAlert;
@property (nonatomic, assign) RecordStage iRecordStage; // record, stop, send,cancel
@property (nonatomic, retain) AVAudioRecorder* audioRecorder;
@property (nonatomic, retain) AVAudioPlayer* audioPlayer;

@property (nonatomic, retain) NSString* audioPath;

-(void) setInitialStage;
-(IBAction) cancelAudioRecorder;
-(void) sendFile;
-(void) handleTouchEndedEvent;

-(void) checkAccessMicrophonePermission;
-(void) show;
-(void) hide;

@end
