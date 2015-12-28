//
//  AudioCell.h
//  JuzChatV2
//
//  Created by TrungVN on 8/7/13.
//  Copyright (c) 2013 mTouche. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface AudioCell : UIView <AVAudioPlayerDelegate>

@property (nonatomic,strong) IBOutlet UIProgressView *progressView;
@property (nonatomic,strong) IBOutlet UIButton *btnRemote;
@property (nonatomic,strong) IBOutlet UILabel *lblDuration;
@property (nonatomic,strong) AVAudioPlayer* audioPlayer;
@property (nonatomic,strong) NSString *audioFilename;
@property (nonatomic,strong) NSString *audioFilePath;
@property (nonatomic,strong) NSString *cellID;

-(IBAction) audioController:(id)sender;
-(void) playAudio;
-(void) stopAudio;
-(void) drawProgressView;
-(void) initAudioCell:(NSString*) messageId;

@end
