//
//  ChatFieldMenu.h
//  JuzChatV2
//
//  Created by TrungVN on 7/26/13.
//  Copyright (c) 2013 mTouche. All rights reserved.
//
#import <UIKit/UIKit.h>


@interface ChatFieldMenu : UIView <UITextViewDelegate>

@property (nonatomic, strong) IBOutlet UIButton* btnPicker;
@property (nonatomic, strong) IBOutlet UITextView* txtChatView;
@property (nonatomic, strong) IBOutlet UIButton* btnSend;
@property (nonatomic, strong) IBOutlet UIView* topBorder;
@property (nonatomic, strong) IBOutlet UIView* bottomBorder;

@property CGFloat originY;
@property CGFloat keyboardHeight;
@property BOOL isTyping;

-(IBAction) showMoreKeyboard;
-(IBAction) sendText;
-(void) resetField;

-(void) showKeyboard:(NSNotification*)notifi;
-(void) hideKeyboard;

-(void)textFieldDidChange:(NSNotification*)notify;

@end