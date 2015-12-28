//
//  VideoCell.m
//  JuzChatV2
//
//  Created by TrungVN on 8/9/13.
//  Copyright (c) 2013 mTouche. All rights reserved.
//
#import "VideoCell.h"
#import "ChatView.h"

@implementation VideoCell

@synthesize imgPlay, btnDisplay, messageID;

-(void) willMoveToSuperview:(UIView *)newSuperview{
    [btnDisplay addTarget:self action:@selector(clickVideo:) forControlEvents:UIControlEventTouchUpInside];
}

-(void) initVideoCell:(NSString*) messageId{
    Message* message = [[AppFacade share] getMessage:messageId];
    if (!message)
        return;
    self.messageID = messageId;
    
    NSData* thumbnailData = [[ChatFacade share] thumbData:messageId];
    NSData* rawData = [[ChatFacade share] videoData:messageId];
    if (message.extend1 && !thumbnailData)
        thumbnailData = [Base64Security decodeBase64String:message.extend1];
    
    if ([[ChatFacade share] isMineMessage:message] && thumbnailData) {
        [self changeWidth:175 Height:175];
        [self.btnDisplay setImage:[UIImage imageWithData:thumbnailData] forState:UIControlStateNormal];
        [self addSubview:imgPlay];
    }
    else{
        self.btnDisplay.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
        self.btnDisplay.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
        if([message.messageStatus isEqualToString:MESSAGE_STATUS_CONTENT_DELETED]){
            [self changeWidth:175 Height:175];
            if(![[ChatFacade share] isMediaFileExisted:messageID]){
                [self.btnDisplay setImage:[UIImage imageWithData:thumbnailData] forState:UIControlStateNormal];
                return;
            }
        }
        [imgPlay removeFromSuperview];
        
        if(message.isEncrypted && rawData.length == 0) {
            [self changeWidth:110 Height:110];
            [self.btnDisplay setImage:[UIImage imageNamed:IMG_CHAT_EN_VIDEO]
                             forState:UIControlStateNormal];
            [self.btnDisplay setImage:[UIImage imageNamed:IMG_CHAT_EN_VIDEO_TAP]
                             forState:UIControlStateHighlighted];
        }
        else{
            [self changeWidth:175 Height:175];
            [self.btnDisplay setImage:[UIImage imageWithData:thumbnailData] forState:UIControlStateNormal];
            [self.btnDisplay setImage:[UIImage imageWithData:thumbnailData]
                             forState:UIControlStateHighlighted];
        }
        if (rawData.length > 0) {
            [self addSubview:imgPlay];
        }
    }

    self.layer.cornerRadius = 3;
    btnDisplay.imageView.contentMode = UIViewContentModeScaleAspectFill;
}

-(IBAction) clickVideo:(id)sender{
    if ([[ContactFacade share] isAccountRemoved]) {
        [[CAlertView new] showError:ERROR_ACCOUNT_REMOVED];
        return;
    }
    
    if([ChatView share].bubbleScroll.popupisShowing == TRUE)
        return;
    
    Message* cellMessage = [[AppFacade share] getMessage:self.messageID];
    if (!cellMessage)
        return;
    
    if ([cellMessage.messageStatus isEqualToString:MESSAGE_STATUS_CONTENT_DELETED])
    {
        [[CAlertView new] showError:_ALERT_VIDEO_DELETED];
        return;
    }
    
    NSData* rawData = nil;
    if (cellMessage.isEncrypted)
        rawData = [[ChatFacade share] videoData:cellMessage.messageId];
    //rawData = nil;
    else
        rawData = [[ChatFacade share] videoData:cellMessage.messageId];
    
    if (rawData.length == 0)
        [[ChatFacade share] downloadMediaMessage:cellMessage];
    else{
        [[ChatFacade share] displayPhotoBrower:cellMessage
                                  showGridView:NO];
    }
}

@end
