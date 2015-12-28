//
//  AudioCell.m
//  JuzChatV2
//
//  Created by TrungVN on 8/7/13.
//  Copyright (c) 2013 mTouche. All rights reserved.
//
#import "AudioCell.h"
#import "ChatView.h"

@implementation AudioCell

@synthesize progressView,btnRemote,lblDuration;
@synthesize audioPlayer, audioFilename,audioFilePath, cellID;


-(void) initAudioCell:(NSString*) messageId{
    progressView.progress = 0.0;
    cellID = messageId;
    
    NSData* audioData = [[ChatFacade share] audioData:messageId];
    if(audioData.length > 0){
        audioPlayer = [[AVAudioPlayer alloc] initWithData:audioData error:nil];
        audioPlayer.delegate = self;
        [audioPlayer prepareToPlay];
        btnRemote.enabled = YES;
        [self stopAudio];
        [self drawProgressView];
    }
    else{
        [btnRemote removeTarget:self action:@selector(audioController:) forControlEvents:UIControlEventTouchUpInside];
        [btnRemote addTarget:self action:@selector(downloadAudio) forControlEvents:UIControlEventTouchUpInside];
        Message *message = [[AppFacade share] getMessage:messageId];
        lblDuration.text = [NSString stringWithFormat:@"00:00"];
        if([message.messageStatus isEqualToString:MESSAGE_STATUS_CONTENT_DELETED])
            return;
        if ([[ChatFacade share] isMineMessage:message]) {
            [btnRemote setImage:nil forState:UIControlStateNormal];
        }
        else{
            [btnRemote setImage:[UIImage imageNamed:IMG_CHAT_I_DOWNLOAD] forState:UIControlStateNormal];
            [btnRemote setImage:[UIImage imageNamed:IMG_CHAT_I_DOWNLOAD_TAP] forState:UIControlStateHighlighted];
        }
    }
}

-(void) downloadAudio{
    if([ChatView share].bubbleScroll.popupisShowing == TRUE)
        return;
    
    Message* audioMessage = [[AppFacade share] getMessage:cellID];
    if ([audioMessage.messageStatus  isEqualToString:MESSAGE_STATUS_CONTENT_DELETED])
    {
        [[CAlertView new] showError:_ALERT_AUDIO_DELETED];
        return;
    }
    
    btnRemote.enabled = FALSE;
    [[ChatFacade share] downloadMediaMessage:audioMessage];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        btnRemote.enabled = TRUE;
    });
}

-(void) drawProgressView{
    progressView.progress = audioPlayer.currentTime/audioPlayer.duration;
    if(audioPlayer.isPlaying){
        [self performSelector:@selector(drawProgressView) withObject:nil afterDelay:0.3];
        lblDuration.text = [NSString stringWithFormat:@"%02d:%02d", (int)[audioPlayer duration]/60, (int)[audioPlayer currentTime]%60];
    }
    else{
        lblDuration.text = [NSString stringWithFormat:@"%02d:%02d", (int)[audioPlayer duration]/60, (int)[audioPlayer duration]%60];
    }
}

-(void) playAudio{
    if(self != [ChatView share].currentAudioPlaying){
        [[ChatView share].currentAudioPlaying stopAudio];
        [ChatView share].currentAudioPlaying = self;
    }
    
    Message* audioMessage = [[AppFacade share] getMessage:cellID];
    if ([audioMessage.messageStatus  isEqualToString:MESSAGE_STATUS_CONTENT_DELETED])
    {
        [[CAlertView new] showError:_ALERT_AUDIO_DELETED];
        return;
    }
    [audioPlayer play];
    [btnRemote setImage:[UIImage imageNamed:IMG_CHAT_I_RESUME] forState:UIControlStateNormal];
    [btnRemote removeTarget:self
                     action:@selector(audioController:)
           forControlEvents:UIControlEventTouchUpInside];
    [btnRemote addTarget:self action:@selector(stopAudio) forControlEvents:UIControlEventTouchUpInside];
    [self drawProgressView];
    [[ChatFacade share] startDestroyMessage:cellID];
}
-(void) stopAudio{
    [audioPlayer stop];
    
    [btnRemote setImage:[UIImage imageNamed:IMG_CHAT_I_PLAY] forState:UIControlStateNormal];
    [btnRemote removeTarget:self action:@selector(stopAudio) forControlEvents:UIControlEventTouchUpInside];
    [btnRemote addTarget:self action:@selector(audioController:) forControlEvents:UIControlEventTouchUpInside];
    audioPlayer.currentTime = 0;
    
    [self drawProgressView];
}
-(void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    [self stopAudio];
}

-(IBAction) audioController:(id)sender{
    [self playAudio];
}
 
@end
