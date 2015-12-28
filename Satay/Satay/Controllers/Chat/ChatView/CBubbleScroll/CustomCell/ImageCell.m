//
//  ImageCell.m
//  JuzChatV2
//
//  Created by TrungVN on 8/9/13.
//  Copyright (c) 2013 mTouche. All rights reserved.
//
#import "ImageCell.h"
#import "ChatView.h"

@implementation ImageCell
@synthesize cellID;

-(void) willMoveToSuperview:(UIView *)newSuperview{
    [self addTarget:self action:@selector(clickImage:) forControlEvents:UIControlEventTouchUpInside];
}

-(void) initImageCell:(NSString*) messageId{
    Message* cellMessage = [[AppFacade share] getMessage:messageId];
    if (!cellMessage)
        return;
    cellID = messageId;
    self.layer.cornerRadius = 3;
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    
    NSData* rawData = [[ChatFacade share] imageData:messageId];
    NSData* thumbData = nil;
    if (cellMessage.extend1)
        thumbData = [Base64Security decodeBase64String:cellMessage.extend1];
    
    [self changeWidth:175 Height:175];
    [self setImage:[UIImage imageWithData:rawData.length > 0 ? rawData:thumbData] forState:UIControlStateNormal];
    [self setImage:[UIImage imageWithData:rawData.length > 0 ? rawData:thumbData] forState:UIControlStateHighlighted];
    self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
    self.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
    if ([[ChatFacade share] isMineMessage:cellMessage])
        return;
    if([cellMessage.messageStatus isEqualToString:MESSAGE_STATUS_CONTENT_DELETED])
        return;
    
    if (cellMessage.isEncrypted) {
        if (rawData.length == 0) {
            [self changeWidth:110 Height:110];
            [self setImage:[UIImage imageNamed:IMG_CHAT_EN_IMAGE] forState:UIControlStateNormal];
            [self setImage:[UIImage imageNamed:IMG_CHAT_EN_IMAGE_TAP] forState:UIControlStateHighlighted];
        }
    }
}

-(IBAction) clickImage:(id)sender{
    if ([[ContactFacade share] isAccountRemoved]) {
        [[CAlertView new] showError:ERROR_ACCOUNT_REMOVED];
        return;
    }
    
    if([ChatView share].bubbleScroll.popupisShowing == TRUE)
        return;
        
    Message* cellMessage = [[AppFacade share] getMessage:cellID];
    if (!cellMessage)
        return;
    if ([cellMessage.messageStatus isEqualToString:MESSAGE_STATUS_CONTENT_DELETED])
    {
        [[CAlertView new] showError:_ALERT_IMAGE_DELETED];
        return;
    }
    NSData* rawData = nil;
    rawData = [[ChatFacade share] imageData:cellMessage.messageId];
    
    if (rawData.length == 0)
        [[ChatFacade share] downloadMediaMessage:cellMessage];
    else{
        [[ChatFacade share] displayPhotoBrower:cellMessage showGridView:NO];
    }
}

@end
