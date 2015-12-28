//
//  CallTimeOutView.m
//  KryptoChat
//
//  Created by Nghia (William) T. VO on 3/9/15.
//  Copyright (c) 2015 mTouche. All rights reserved.
//

#import "CallTimeOutView.h"
#import "VoiceCallView.h"
#import "CWindow.h"

@interface CallTimeOutView ()

@end

@implementation CallTimeOutView
@synthesize lblFriendName, lblCallStatus, imgAvatar, btnCancel, btnMessage, btnRetry;
@synthesize userJid;

- (IBAction)action_Message:(id)sender {
    ChatBox* chatBox = [[AppFacade share] getChatBox:userJid];
    if (!chatBox) {
        [[ChatFacade share] createChatBox:userJid isMUC:FALSE];
        chatBox = [[AppFacade share] getChatBox:userJid];
    }
    [[CWindow share] hideLoading];
    [[CWindow share] hidePopupWindow:YES];
    [[CWindow share] showChatList];
    [[ChatFacade share] moveToChatView:chatBox.chatboxId];
    [self.view removeFromSuperview];
}

- (IBAction)action_Retry:(id)sender {
    [[SIPFacade share] setStatusOfCall:YES];
    [VoiceCallView share].userJid = userJid;
    [SIPFacade share].isWhoMakeCall = YES;
    [[CWindow share] showVoiceCallView];
    [self.view removeFromSuperview];
}

- (IBAction)action_Cancel:(id)sender {
    [self.view removeFromSuperview];
}

+ (CallTimeOutView *)share {
    static dispatch_once_t once;
    static CallTimeOutView *share;
    
    dispatch_once(&once, ^{
        share = [self new];
        [share.view changeWidth:[CWindow share].width
                         Height:[CWindow share].height];
    });
    return share;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self set_Style_for_Controler];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [VoiceCallView share].isPauseTone = YES;
    [self showUserInfor];
    [SIPFacade share].isTimeOutView = YES;
    //End Call
    NSDictionary *dict = @{ SIP_DURATION : @"00:00:00"
                            , SIP_CMD : @"END"
                            , SIP_REMARKS : @"End Call"};
    [[SIPFacade share] updateEndStatusSIPAPI:dict];
}

- (void)viewWillDisappear:(BOOL)animated {
    [SIPFacade share].isTimeOutView = NO;
}

- (void)showUserInfor
{
    Contact *friendInfo = [[ContactFacade share] getContact:userJid];
    if ((friendInfo.customerName != nil) && (![friendInfo.customerName isEqualToString:@""])) {
        lblFriendName.text = friendInfo.customerName;
    } else if ((friendInfo.serversideName != nil) && (![friendInfo.serversideName isEqualToString:@""])) {
        lblFriendName.text = friendInfo.serversideName;
    } else {
        lblFriendName.text = friendInfo.maskingid;
    }  

    if ((friendInfo.avatarURL != nil) && (![friendInfo.avatarURL isEqualToString:@""])) {
        imgAvatar.image = [[ContactFacade share] updateContactAvatar:friendInfo.avatarURL];
    }
}

- (void) set_Style_for_Controler {
    //set style for button Message
    btnMessage.layer.borderWidth = 1;
    btnMessage.layer.borderColor = COLOR_15224088.CGColor;
    btnMessage.layer.cornerRadius = 15;
    btnMessage.clipsToBounds = YES;
    [btnMessage setBackgroundImage:[UIImage imageFromColor:COLOR_15224088]
                          forState:UIControlStateNormal];
    [btnMessage setBackgroundImage:[UIImage imageFromColor:COLOR_2220431]
                          forState:UIControlStateHighlighted];
    
    //set style for button Retry
    btnRetry.layer.borderWidth = 1;
    btnRetry.layer.borderColor = COLOR_15224088.CGColor;
    btnRetry.layer.cornerRadius = 15;
    btnRetry.clipsToBounds = YES;
    [btnRetry setBackgroundImage:[UIImage imageFromColor:COLOR_15224088]
                          forState:UIControlStateNormal];
    [btnRetry setBackgroundImage:[UIImage imageFromColor:COLOR_2220431]
                          forState:UIControlStateHighlighted];
    
    //set style for button Cancel
    btnCancel.layer.cornerRadius = 15;
    btnCancel.clipsToBounds = YES;
    [btnCancel setBackgroundImage:[UIImage imageFromColor:COLOR_2509696]
                         forState:UIControlStateNormal];
    [btnCancel setBackgroundImage:[UIImage imageFromColor:COLOR_2514242]
                         forState:UIControlStateHighlighted];

    
    //Avatar image
    imgAvatar.layer.masksToBounds = YES;
    imgAvatar.layer.cornerRadius = 62;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




@end
