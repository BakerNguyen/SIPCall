//
//  PopupContact.m
//  KryptoChat
//
//  Created by TrungVN on 4/18/14.
//  Copyright (c) 2014 mTouche. All rights reserved.
//

#import "ContactPopup.h" 
#import "CWindow.h"
#import "EmailComposeView.h"
#import "VoiceCallView.h"

@interface ContactPopup ()
{
    Contact* contact;
}
@end

@implementation ContactPopup

@synthesize navPopup, dimView;
@synthesize avatarUser;
@synthesize btnChat, btnEmail, btnInfo, btnVoiceCall, userJid;

+(ContactPopup *)share{
    static dispatch_once_t once;
    static ContactPopup * share;
    dispatch_once(&once, ^{
        share = [self new];
    });
    return share;
}

- (void)viewDidLoad
{
    [dimView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeView)]];
    
    self.navigationItem.titleView = navPopup;
    avatarUser.layer.cornerRadius = avatarUser.frame.size.width/2;
    
    [btnEmail alignCenter];
    [btnChat alignCenter];
    [btnInfo alignCenter];
    [btnVoiceCall alignCenter];
    [ContactFacade share].contactPopupDelegate = self;
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self displayInfo];
}

-(void) displayInfo{
    if(!self.navigationController)
        return;
    contact = [[ContactFacade share] getContact:userJid];
    if (contact) {
        navPopup.lblTitle.text = [[ContactFacade share] getContactName:userJid];
        NSString* contactState = @"";
        switch ([contact.contactState integerValue]) {
            case kCONTACT_STATE_ONLINE: contactState = _ONLINE; break;
            case kCONTACT_STATE_OFFLINE: contactState = _OFFLINE; break;
            case kCONTACT_STATE_BLOCKED: contactState = _BLOCKED; break;
        }
        navPopup.lblStatus.text = contact.statusMsg.length > 0 ? contact.statusMsg : DEFAULT_STATUS_AVAILABLE;
        navPopup.lblStatus.text = [contactState isEqualToString:_BLOCKED] ? _BLOCKED: navPopup.lblStatus.text;
        avatarUser.image = [[ContactFacade share] updateContactAvatar:contact.avatarURL];
    }
}

-(IBAction) closeView{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction) voiceCall
{
    if ([[ContactFacade share] isAccountRemoved]) {
        [[CAlertView new] showError:ERROR_ACCOUNT_REMOVED];
        return;
    }
    
    if(![[NotificationFacade share] isInternetConnected]){
        [[CAlertView new] showError:NO_INTERNET_CONNECTION_TRY_LATER];
        return;
    }
    
    [[LogFacade share] createEventWithCategory:Contact_Category
                                        action:freeCall_Action
                                         label:labelAction];
    if([[ContactFacade share] isBlocked:userJid]){
        CAlertView *alertView = [CAlertView new];
        NSMutableArray *buttonsName  = [NSMutableArray arrayWithObjects:@"UNBLOCK", @"CANCEL", nil];
        [alertView showInfo_2btn:_ALERT_SIP_BLOCKED ButtonsName:buttonsName];
        [alertView setOnButtonTouchUpInside:^(CAlertView *alertView, int buttonIndex) {
             if (buttonIndex == 0) {
                 [[ContactFacade share] synchronizeBlockList:userJid action:kUNBLOCK_USERS];
             }
         }];
        [alertView show];
        return;
    }

    if ([SIPFacade share].isCalling) {
        [[CAlertView new] showInfo:SIP_ERROR_CANNOT_CALL_WHILE_IN_ANOTHER_CALL];
        return;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
        
    if (!IS_OS_8_OR_LATER) {
        [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
            if (granted) {
                NSLog(@"Permission microphone granted");
            }
            else {
                NSLog(@"Permission microphone denied");
                [[CAlertView new] showError:_ALERT_SATAY_DOES_NOT_HAVE_ACCESS_TO_YOUR_MICROPHONE];
                return;
            }
        }];
    }
    
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    if(authStatus == AVAuthorizationStatusDenied){
        [[CAlertView new] showError:_ALERT_SATAY_DOES_NOT_HAVE_ACCESS_TO_YOUR_MICROPHONE];
        return;
    }
    
    [[SIPFacade share] setStatusOfCall:YES];
    [VoiceCallView share].userJid = userJid;
    [SIPFacade share].isWhoMakeCall = YES;
    [[CWindow share] showVoiceCallView];
}

-(IBAction) showInfo{
    [[LogFacade share] createEventWithCategory:Contact_Category
                                        action:infoClick_Action
                                         label:labelAction];
    ChatBox* chatBox = [[AppFacade share] getChatBox:userJid];
    if (!chatBox) {
        [[ChatFacade share] createChatBox:userJid isMUC:FALSE];
        chatBox = [[AppFacade share] getChatBox:userJid];
    }
    
    if ([[ContactInfo share] checkInfoAvailable:userJid])
        [[self navigationController] pushViewController:[ContactInfo share] animated:YES];
    else{
        [self closeView];
        [[CAlertView new] showError:ERROR_NO_CONTACT];
    }
}

-(IBAction) chatContact{
    
    ChatBox* chatBox = [[AppFacade share] getChatBox:userJid];
    if (!chatBox) {
        [[ChatFacade share] createChatBox:userJid isMUC:FALSE];
        chatBox = [[AppFacade share] getChatBox:userJid];
    }
    [self dismissViewControllerAnimated:NO completion:^(){
        [[CWindow share] showChatList];
        [[ChatFacade share] moveToChatView:chatBox.chatboxId];
    }];
}

-(IBAction) emailContact
{
    [[LogFacade share] createEventWithCategory:Contact_Category
                                        action:emailClick_Action
                                         label:labelAction];

    if ([[[EmailFacade share] getLoginEmailFlag] isEqualToString:IS_NO])
    {
        [[CWindow share] showEmailLogin];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else
    {
        [self dismissViewControllerAnimated:NO completion:^(){
            [[CWindow share] showMailBox];
            [[EmailFacade share] moveToComposeWithEmail:contact.email];
        }];
    }
}

@end
