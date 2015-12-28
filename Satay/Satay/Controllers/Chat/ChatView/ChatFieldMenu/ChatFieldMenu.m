//
//  ChatFieldMenu.m
//  JuzChatV2
//
//  Created by TrungVN on 7/26/13.
//  Copyright (c) 2013 mTouche. All rights reserved.
//
#import "ChatFieldMenu.h"

#import "ChatView.h"

@interface ChatFieldMenu (){
    ChatView* chatView;
}
@end

@implementation ChatFieldMenu

@synthesize btnPicker,btnSend,txtChatView;
@synthesize topBorder,bottomBorder, keyboardHeight;
@synthesize originY, isTyping;

-(void) didMoveToSuperview{
    chatView = [ChatView share];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showKeyboard:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideKeyboard) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChange:) name:UITextViewTextDidChangeNotification object:nil];
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self resetField];
        txtChatView.layer.borderWidth = 1;
        txtChatView.layer.borderColor = COLOR_230230230.CGColor;
    });
    
    [[UITextView appearance] setTintColor:[UIColor blackColor]];
}
// prevent crash in ios7 when use undo option
-(void) showKeyboard:(NSNotification*) notifi{
    [chatView.moreKeyboard hide];
    [chatView.audioRecorder hide];
    
    CGRect _keyboardEndFrame;
    [[notifi.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue:&_keyboardEndFrame];
    self.keyboardHeight = _keyboardEndFrame.size.height;
    
    [chatView.notifyChat redrawNotify];
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;

    if (self.superview.y > 0) {
        [self changeXAxis:0 YAxis: screenHeight - self.superview.y - self.height - keyboardHeight];
    }else{
        [self animateXAxis:0 YAxis:self.superview.height - self.height - keyboardHeight];
    }
    
    [chatView.bubbleScroll animateWidth:chatView.bubbleScroll.width
                                 Height:self.y - chatView.notifyChat.height];
    
    [chatView.bubbleScroll scrollToBottom];
    originY = self.y;
}

-(void) hideKeyboard{
    if (chatView.bubbleScroll.popupisShowing) {
        [chatView.bubbleScroll hidePopup];
    }
    
    keyboardHeight = 0;
    [chatView.chatfield.txtChatView resignFirstResponder];
    [chatView.moreKeyboard hide];
    [chatView.audioRecorder hide];
    [chatView.notifyChat redrawNotify];
    [chatView.bubbleScroll scrollToBottom];
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    
    if (self.superview.y > 0) {
        [self changeXAxis:0 YAxis: screenHeight - self.superview.y - self.height];        
    }else{
        [self animateXAxis:0 YAxis:self.superview.height - self.height];
    }
    [chatView.bubbleScroll animateWidth:chatView.bubbleScroll.width Height:self.y - chatView.notifyChat.height];
}

-(void) textFieldDidChange:(NSNotification*)notifi{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^(void){
        if (![(UITextField *)notifi.object isEqual:txtChatView]) {
            return;
        }
        
        if([txtChatView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0){
            [btnSend setTitle:@"" forState:UIControlStateNormal];
            [btnSend setImage:[UIImage imageNamed:IMG_CHAT_VOICE] forState:UIControlStateNormal];
            return;
        }
        
        //chatView.chatBoxID
        if (![[AppFacade share] getChatBox:chatView.chatBoxID].isGroup && !isTyping) {
            NSDictionary *stateDic = @{kCHAT_STATE_TARGET_JID:chatView.chatBoxID,
                                       kCHAT_STATE_TYPE: [NSString stringWithFormat:@"%d", kCHAT_STATE_TYPE_COMPOSING]
                                       };
            [[XMPPFacade share] sendMessageChatState:stateDic];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                isTyping = FALSE;
            });
        }
        isTyping = TRUE;
        
        [btnSend setTitle:_SEND forState:UIControlStateNormal];
        [btnSend setImage:nil forState:UIControlStateNormal];
        
        if([txtChatView.text isEqualToString:@""]){
            [self resetField];
            return;
        }
        
        if(txtChatView.contentSize.height > 80)
            return;
        
        [txtChatView animateWidth:txtChatView.width Height:txtChatView.contentSize.height];
        [self animateWidth:self.width Height:txtChatView.height + 12];
        CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
        
        if (self.superview.y > 0) {
            originY = screenHeight - self.superview.y - self.height;
        }else{
            originY = self.superview.height - self.height;
        }
        
        if([txtChatView isFirstResponder])
            originY = originY - keyboardHeight;
        [self animateXAxis:0 YAxis:originY];
    }];
}

-(void) resetField{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^(void){
        txtChatView.text = @"";
        [btnSend setTitle:@"" forState:UIControlStateNormal];
        [btnSend setImage:[UIImage imageNamed:IMG_CHAT_VOICE] forState:UIControlStateNormal];
        
        txtChatView.contentSize = CGSizeMake(txtChatView.frame.size.width, 32);
        [txtChatView animateWidth:txtChatView.width Height:txtChatView.contentSize.height];
        [self animateWidth:self.width Height:(txtChatView.height + 12)];
        //originY = self.superview.height - self.height;
        CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
        
        if (self.superview.y > 0) {
            originY = screenHeight - self.superview.y - self.height;
        }else{
            originY = self.superview.height - self.height;
        }
        
        if(keyboardHeight > 0)
            originY = originY - keyboardHeight;
        [self animateXAxis:0 YAxis:originY];
        originY = self.y;
    }];
}

-(IBAction)showMoreKeyboard{
    ChatBox *chatbox = [[AppFacade share] getChatBox:chatView.chatBoxID];
    
    if (chatbox.isGroup) {
        if (![[ContactInfo share] checkInfoAvailable:chatView.chatBoxID]) {
            [[CAlertView new] showError:_ALERT_NOT_GROUP_MEMBER];
            return;
        }
    } else {
        if([[ContactFacade share] isBlocked:chatView.chatBoxID]){
            [chatView showAlertBlocked];
            return;
        }
        
        if (![[ContactFacade share] isFriend:chatView.chatBoxID]) {
            [[CAlertView new] showError:_ALERT_NOT_FRIEND];
            return;
        }
    }
    
    [chatView.moreKeyboard show];
}

-(IBAction)sendText{
    if ([[ContactFacade share] isAccountRemoved]) {
        [[CAlertView new] showError:ERROR_ACCOUNT_REMOVED];
        return;
    }
    
    if([[ContactFacade share] isBlocked:chatView.chatBoxID]){
        [chatView showAlertBlocked];
        return;
    }
    
    if (![[ContactFacade share] isFriend:chatView.chatBoxID] && ![[AppFacade share] getChatBox:chatView.chatBoxID].isGroup) {
        [[CAlertView new] showError:_ALERT_NOT_FRIEND];
        return;
    }
    
    if (![[ContactInfo share] checkInfoAvailable:chatView.chatBoxID]) {
        [[CAlertView new] showError:_ALERT_NOT_GROUP_MEMBER];
        return;
    }
    
    if([txtChatView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0){
        [chatView.audioRecorder checkAccessMicrophonePermission];
    }
    else{
        BOOL success = [[ChatFacade share] sendText:txtChatView.text chatboxId:chatView.chatBoxID];
        if(!success)
            [[CAlertView new] showError:_ALERT_SEND_MESSAGE_FAILED];
        [self resetField];
    }
}

@end
