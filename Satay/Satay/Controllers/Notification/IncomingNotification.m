//
//  IncomingNotification.m
//  Satay
//
//  Created by Arpana Sakpal on 1/20/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import "IncomingNotification.h"
#import "ChatView.h"
#import "ContactRequest.h"
#import "ContactInfo.h"

@implementation IncomingNotification{
    BOOL isDisplaying;
}

@synthesize bannerButton;
@synthesize cancelButton;
@synthesize titleLabel;
@synthesize messageLabel;
@synthesize chatBoxImage;
@synthesize currentMessage;
@synthesize currentRequest;

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        NSArray *subviewArray = [[NSBundle mainBundle] loadNibNamed:@"IncomingNotification"
                                                              owner:self options:nil];
        UIView *mainView = [subviewArray objectAtIndex:0];
        [self changeWidth: self.width Height:64];
        [self changeXAxis:0 YAxis:-self.height];
        [self addSubview:mainView];
        [mainView changeWidth:self.width Height:mainView.height];
    }
    return self;
}

+(IncomingNotification *)share{
    static dispatch_once_t once;
    static IncomingNotification * share;
    dispatch_once(&once, ^{
        share = [[self alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        [NotificationFacade share].incomingNotificationDelegate = share;
        [ChatFacade share].incomingNotificationDelegate = share;

    });
    return share;
}

-(void)willMoveToSuperview:(UIView *)newSuperview{
    chatBoxImage.layer.cornerRadius = chatBoxImage.width/2;
}

#pragma mark Show/Hide local notification banner

-(void) showNotifyMessage:(id) message groupName:(id)groupName{
    IncomingNotificationType = IN_Type_Chat;

    if (isDisplaying)
        return;

    if (![message isKindOfClass:[Message class]])
        return;
    currentMessage = (Message*)message;
    if ([[ChatView share].chatBoxID isEqualToString:currentMessage.chatboxId])
        return;
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^(){
        NSString* messageContent = @"";
        NSInteger messageType = [[ChatFacade share] messageType:currentMessage.messageType];
        switch (messageType) {
            case MediaTypeText:{
                if (currentMessage.isEncrypted) {
                    NSData* data = [Base64Security decodeBase64String:currentMessage.messageContent];
                    data = [[AppFacade share] decryptDataLocally:data];
                    if (data)
                        messageContent = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                    else
                        messageContent = __MESSAGE_SENT_TEXT;
                }
                else{
                    messageContent = currentMessage.messageContent;
                }
            }
                break;
            case MediaTypeAudio:
                messageContent = __MESSAGE_SENT_AUDIO;
                break;
            case MediaTypeImage:
                messageContent = __MESSAGE_SENT_IMAGE;
                break;
            case MediaTypeVideo:
                messageContent = __MESSAGE_SENT_VIDEO;
                break;
            case MediaTypeNotification:{
                messageContent = currentMessage.messageContent;
            }
                break;
                
            default:
                break;
        }
        
        ChatBox* chatBox = [[AppFacade share] getChatBox:currentMessage.chatboxId];
        if (!chatBox)
            return;
        
        BOOL isChatboxNotifyAlertOn = [chatBox.notificationSetting boolValue];
        if(!isChatboxNotifyAlertOn)
            return;
        
        if (chatBox.isGroup) {
            GroupObj *groupObj = [[AppFacade share] getGroupObj:chatBox.chatboxId];
            chatBoxImage.image = [[ChatFacade share] updateGroupLogo:groupObj.groupId];
            titleLabel.text = (!groupObj ? (NSString*)groupName : groupObj.groupName);
        }
        else{
            chatBoxImage.image = [[ContactFacade share] updateContactAvatar:chatBox.chatboxId];
            titleLabel.text = [[ContactFacade share] getContactName:chatBox.chatboxId];
        }
        messageLabel.text = messageContent;
        [self performShowNotice];
       
    }];
}

-(void)performShowNotice{
    [CWindow share].windowLevel = UIWindowLevelStatusBar;
    for (UIWindow *window in [[UIApplication sharedApplication] windows]) {
        if (CGRectEqualToRect(window.frame, [CWindow share].frame)) {
            if (![window isEqual:[CWindow share]]) {
                window.windowLevel = UIWindowLevelStatusBar + 1;
            }
        }
    }
    isDisplaying = TRUE;
    [self.superview bringSubviewToFront:self];
    [self animateXAxis:0 YAxis:0];
    [self performSelector:@selector(hideBannerNotification) withObject:nil afterDelay:3.0];
}

-(void) showNotifyRequest:(id) request{
    IncomingNotificationType = IN_Type_NEW_REQUEST;
    
    if (isDisplaying)
        return;
    
    if(!request || ![request isKindOfClass:[Request class]])
        return;
    currentRequest = (Request*)request;
    titleLabel.text = [[ContactFacade share] getContactName:currentRequest.requestJID];
    chatBoxImage.image = [[ContactFacade share] updateContactAvatar:currentRequest.requestJID];
    
    NSString* messageContent = NOTIFY_SEND_YOU_A_FRIEND_REQUEST;
    messageLabel.text = messageContent;
    
    [self performShowNotice];
}

- (void) showNotifyRemovedContact:(NSString *) fullJID{
    IncomingNotificationType = IN_Type_DELETE_REQUEST;
    
    if (isDisplaying)
        return;
    
    if(!fullJID || fullJID.length == 0)
        return;
    titleLabel.text = [[ContactFacade share] getContactName:fullJID];
    chatBoxImage.image = [[ContactFacade share] updateContactAvatar:fullJID];
    
    NSString *messageContent = NOTIFY_FRIEND_HAS_REMOVED_YOU;
    messageLabel.text = messageContent;
    
    [self performShowNotice];
}

-(void) showNotifyNewEmail:(int) numberNewEmail{
    IncomingNotificationType = IN_Type_Email;
    
    if(isDisplaying)
        return;
    
    if(numberNewEmail == 0)
        return;
    
    titleLabel.text = TITLE_EMAIL;
    messageLabel.text = [NSString stringWithFormat:mNumber_New_Email, numberNewEmail];
    chatBoxImage.image = [UIImage imageNamed:IMG_RECEIVE_EMAIL];
    
   [self performShowNotice];
    
}

-(void) hideBannerNotification{
    [self animateXAxis:0 YAxis:-self.height];
    [CWindow share].windowLevel = UIWindowLevelNormal;
    isDisplaying = FALSE;
}

#pragma mark UI interaction

-(IBAction) cancelButtonPress:(id)sender{
    [self hideBannerNotification];
}

-(IBAction) bannerButtonPress:(id)sender{
    //No action when we tap on Notificaion when app in incoming call, calling or Timeout
    if ([SIPFacade share].isCalling || [SIPFacade share].isOnCall || [SIPFacade share].isTimeOutView) {
        if (![SIPFacade share].isMinimize) {
            return;
        }
    }
    
    [[CWindow share] hidePopupWindow:NO];
    [self hideBannerNotification];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        switch (IncomingNotificationType) {
            case IN_Type_Chat:
            {
                if (currentMessage) {
                    [[CWindow share] showChatList];
                    [[ChatFacade share] moveToChatView:currentMessage.chatboxId];
                }
                break;
            }
            case IN_Type_Email:
            {
                [[CWindow share] showMailBox];
                break;
            }
            case IN_Type_NEW_REQUEST:
            {
                if(currentRequest){
                    [[CWindow share] showNotification];
                }
                break;
            }
            case IN_Type_DELETE_REQUEST:
            {
                [[CWindow share] showNotification];
                break;
            }
                
            default:
                break;
        }
        
    });
}



@end
