//
//  NotifyChatView.m
//  KryptoChat
//
//  Created by TrungVN on 6/20/14.
//  Copyright (c) 2014 mTouche. All rights reserved.
//

#import "NotifyChatView.h"
#import "ChatView.h"


@implementation NotifyChatView{
    ChatView* chatView;
}

@synthesize redAlert, lblBlue, lblRed, blueAlert;
@synthesize originScrollHeight;

-(void) willMoveToSuperview:(UIView *)newSuperview{
    chatView = [ChatView share];
    [self hideBlueAlert];
    [self hideRedAlert];
}

-(void) showRedAlert:(NSString*) alertMessage{
    lblRed.text = alertMessage;
    [redAlert changeWidth:redAlert.width Height:30];
    [self redrawNotify];
}
-(void) showBlueAlert:(NSString*) alertMessage{
    lblBlue.text = alertMessage;
    [blueAlert changeWidth:blueAlert.width Height:30];
    lblRed.text = @"";
    [self redrawNotify];
}
-(void) hideRedAlert{
    lblRed.text = @"";
    [redAlert changeWidth:redAlert.width Height:0];
    [self redrawNotify];
}
-(void) hideBlueAlert{
    [blueAlert changeWidth:blueAlert.width Height:0];
    [self redrawNotify];
}

-(void) redrawNotify{
    [redAlert changeXAxis:0 YAxis:0];
    [blueAlert changeXAxis:0 YAxis:redAlert.height];
    float old = self.frame.size.height;
    [self changeWidth:self.width Height:redAlert.height + blueAlert.height];
    float changed = old - self.frame.size.height;
    
    [chatView.bubbleScroll changeXAxis:0 YAxis:self.height];
    [chatView.bubbleScroll changeWidth:chatView.bubbleScroll.width
                                Height:chatView.bubbleScroll.height + changed];
    
    //[chatView.bubbleScroll scrollToBottom];
}

@end
