//
//  NotificationFacade.m
//  Satay
//
//  Created by MTouche on 4/10/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import "NotificationFacade.h"
#import "IncomingNotification.h"
#import "NotificationController.h"
#import "SideBar.h"
#import "ChatView.h"

@implementation NotificationFacade{
    BOOL isPlayingSound;
}

@synthesize incomingNotificationDelegate;
@synthesize notificationListDelegate;
@synthesize contactNotificationDelegate;
@synthesize chatListNotificationDelegate;
@synthesize emailComposeDelegate;
@synthesize sideBarDelegate;
@synthesize sipDelegate;

+(NotificationFacade *)share{
    static dispatch_once_t once;
    static NotificationFacade * share;
    dispatch_once(&once, ^{
        share = [self new];
        [[NotificationAdapter share] setDelegate: share];
    });
    return share;
}

#pragma mark Remote notification

-(void) configNotification{
    [[NotificationAdapter share] configNotification];
}

-(void) registerWithServer:(NSData*) token{
    NSString* strToken = [[NotificationAdapter share] processToken:token];
    if (strToken.length == 0)
        return;
    
    if ([[ContactFacade share] getTokentCentral].length == 0 ||
        [[ContactFacade share] getTokentTenant].length == 0) {
        return;
    }
    
    if([strToken isEqualToString:[KeyChainSecurity getStringFromKey:kDEVICE_TOKEN]]){
        NSLog(@"ALREADY REGISTER SUCCESS");
        return;
    }
    
    NSDictionary *logDic = @{
               LOG_CLASS : NSStringFromClass(self.class),
               LOG_CATEGORY: CATEGORY_APN_TOKEN_UPLOADED,
               LOG_MESSAGE: @"Enter",
               LOG_EXTRA1: @"",
               LOG_EXTRA2: @""
               };
    [[LogFacade share] logInfoWithDic:logDic];
    
    NSDictionary *registerPNDic = @{kTOKEN: [[ContactFacade share] getTokentTenant],
                                    kMASKINGID: [[ContactFacade share] getMaskingId],
                                    kCENTRALTOKEN:[[ContactFacade share] getTokentCentral],
                                    kPUSH_ID:strToken,
                                    kIMEI: [[ContactFacade share] getIMEI],
                                    kIMSI: [[ContactFacade share] getIMSI],
                                    kAPI_REQUEST_METHOD: POST,
                                    kAPI_REQUEST_KIND: NORMAL};
    [[NotificationAdapter share] registerPNToServer:registerPNDic callback:^(BOOL success, NSString *message, NSDictionary *response, NSError *error) {
        NSDictionary *logDic;
        if (success) {
            
            [KeyChainSecurity storeString:strToken Key:kDEVICE_TOKEN];
            NSLog(@"%s:%@", __PRETTY_FUNCTION__, response);
            logDic = @{LOG_CLASS : NSStringFromClass(self.class),
                       LOG_CATEGORY: CATEGORY_APN_TOKEN_UPLOADED,
                       LOG_MESSAGE: @"UPLOAD SUCCESS",
                       LOG_EXTRA1: @"",
                       LOG_EXTRA2: @""
                       };
            [[LogFacade share] logInfoWithDic:logDic];
        }
        else{
            NSLog(@"%s:%@", __PRETTY_FUNCTION__, error);
            logDic = @{
                       LOG_CLASS : NSStringFromClass(self.class),
                       LOG_CATEGORY: CATEGORY_APN_TOKEN_UPLOADED,
                       LOG_MESSAGE: [NSString stringWithFormat:@"UPLOAD FAIL WITH ERROR: %@",error],
                       LOG_EXTRA1: @"",
                       LOG_EXTRA2: @""
                       };
            [[LogFacade share] logErrorWithDic:logDic];
             if (response){
                NSInvocationOperation* operation=  [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(registerWithServer:) object:token];
                
                NSDictionary* retryDictionary = @{kRETRY_OPERATION:operation,kRETRY_TIME:kRETRY_API_COUNTER,
                                                  kSTATUS_CODE : [response objectForKey:kSTATUS_CODE]};
                [[AppFacade share] downloadTokenAgain:retryDictionary];
             }
        }
    }];
}

- (void) setupReachability{
    [[NotificationAdapter share] setupReachability];
}

- (void) removeAppBadge{
    [[NotificationAdapter share] removeAppBadge];
}

#pragma mark Local notification banner

-(void) notifyMessageReceived:(Message*) message groupName:(NSString *) groupName{
    if([[AppFacade share] getChatBox:message.chatboxId].isGroup){
        GroupMember *gm = [[AppFacade share] getGroupMember:message.chatboxId userJID:[[ContactFacade share] getJid:YES]];
        if (!gm || [gm.memberState isEqualToNumber:[NSNumber numberWithInt:kGROUP_MEMBER_STATE_LEAVE]] || [gm.memberState isEqualToNumber:[NSNumber numberWithInt:kGROUP_MEMBER_STATE_KICKED]]) {
            return;// for notice of group which have not included myself, will ignore.
        }
    }
    
    if([[self getNotificationAlertInAppFlag] boolValue]){
        [incomingNotificationDelegate showNotifyMessage:message groupName:groupName];
    }
    
    [sideBarDelegate updateChatRowUnreadNumber];
    [self playSoundMessage:message];
}

-(void) notifyFriendRequestReceived:(Request*)request{
    if([[self getNotificationAlertInAppFlag] boolValue]){
        [incomingNotificationDelegate showNotifyRequest:request];
    }
    
    [self playSoundNotification];
}

-(void) notifyRemovedContactReceived:(NSString*)fullJID{
    if([[self getNotificationAlertInAppFlag] boolValue]){
        [incomingNotificationDelegate showNotifyRemovedContact:fullJID];
    }
    
    [self playSoundNotification];
}

-(void) notifyNewEmailReceived:(int) numberNewEmail{
    if([[self getNotificationAlertInAppFlag] boolValue]){
        [incomingNotificationDelegate showNotifyNewEmail:numberNewEmail];
    }
    [sideBarDelegate updateEmailRowUnreadNumber:numberNewEmail];
    [self showLocalNotification:mNumber_New_Email_App_Notification numberNotice:numberNewEmail];
    
    [self playSoundNotification];
}

- (void) showLocalNotification:(NSString*)message numberNotice:(int)number
{
    if ([UIApplication sharedApplication].applicationState ==  UIApplicationStateBackground)
    {
        UILocalNotification* localNotif = [[UILocalNotification alloc] init];
        if (localNotif)
        {
            localNotif.alertBody = [NSString stringWithFormat:message, number];
            localNotif.applicationIconBadgeNumber = localNotif.applicationIconBadgeNumber + number;
            [[UIApplication sharedApplication]  presentLocalNotificationNow:localNotif];
        }
    }
}
#pragma mark Interact with Local database

- (NSArray*) getAllNoticesWithContent:(NSString*) content status:(NSString*) status{
    NSString* queryNotice = [NSString new];
    
    if(content.length > 0 && status.length > 0){
        queryNotice = [NSString stringWithFormat:@"status = '%@' AND content = '%@'", status, content];
    }
    else if(status.length > 0){
        queryNotice = [NSString stringWithFormat:@"status = '%@'", status];
    }
    else{
        queryNotice = [NSString stringWithFormat:@"noticeID != ''"];
    }
    return [[DAOAdapter share] getObjects:[NoticeBoard class] condition:queryNotice orderBy:@"updateTS" isDescending:YES limit:MAXFLOAT];
}

- (NoticeBoard*) getNewNoticeWithID:(NSString*) noticeID content:(NSString*) content{
    NSString* queryNotice  = [NSString stringWithFormat:@"noticeID = '%@' AND content = '%@' AND status = '%@'", noticeID, content, kNOTICEBOARD_STATUS_NEW];
    return (NoticeBoard*)[[DAOAdapter share] getObject:[NoticeBoard class] condition:queryNotice];
}

- (void) insertNewNoticeWithID:(NSString *) noticeID type:(int) noticeType{
    BOOL result = FALSE;
    NSString* queryNotice = [NSString new];
    NSString *contentStr = [NSString new];
    
    if(!noticeID)
        return;
    
    switch (noticeType) {
        case kNOTICEBOARD_TYPE_ADD_CONTACT:
            contentStr = kNOTICEBOARD_CONTENT_ADD_CONTACT;
            break;
        case kNOTICEBOARD_TYPE_DELETE_CONTACT:
            contentStr = kNOTICEBOARD_CONTENT_DELETE_CONTACT;
            break;
        default:
            break;
    }
    
    queryNotice = [NSString stringWithFormat:@"noticeID = '%@' AND content = '%@'", noticeID, contentStr];
    NoticeBoard* notice = (NoticeBoard*)[[DAOAdapter share] getObject:[NoticeBoard class] condition:queryNotice];
    if(!notice){
        notice = [NoticeBoard new];
        notice.noticeID = noticeID;
        notice.title = kNOTICEBOARD_TITLE_NEW;
        notice.status = kNOTICEBOARD_STATUS_NEW;
        notice.updateTS = [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]];
        notice.content = contentStr;
        
        result = [[DAOAdapter share] commitObject:notice];
        if(result){
            [notificationListDelegate reloadNotificationPage];
        }
    }
}

- (void) deleteNoticesWithID:(NSString *) noticeID{
    NSLog(@"Delete notices with noticeID after approving/denying friend request");
    
    if(!noticeID)
        return;
    
    NSString* queryNotice = [NSString stringWithFormat:@"noticeID = '%@'", noticeID];
    NSArray *arrDeleteNotices = [[DAOAdapter share] getObjects:[NoticeBoard class] condition:queryNotice];
    
    for(NoticeBoard *item in arrDeleteNotices){
        if([item.noticeID isEqual:noticeID])
            [[DAOAdapter share] deleteObject:item];
    }
    
    [notificationListDelegate reloadNotificationPage];
}

- (void) deleteAllRemovedContactNotices{
    NSLog(@"Delete all removed contact notices after viewing");
    NSString* queryNotice = [NSString stringWithFormat:@"content = '%@'", kNOTICEBOARD_CONTENT_DELETE_CONTACT];
    NSArray *allRemovedContactNotices = [[DAOAdapter share] getObjects:[NoticeBoard class] condition:queryNotice];
    
    if(!allRemovedContactNotices)
        return;
    for(NoticeBoard *item in allRemovedContactNotices){
        [[DAOAdapter share] deleteObject:item];
        [[ContactFacade share] synchronizeBlockList:item.noticeID action:kUNBLOCK_USERS];
    }
}

- (void) markAllNoticesAsRead{
    NSArray *arrAllNotices =  [self getAllNoticesWithContent: nil status:kNOTICEBOARD_STATUS_NEW];
    if(!arrAllNotices)
        return;
    
    for(NoticeBoard *item in arrAllNotices){
        item.status =  kNOTICEBOARD_STATUS_READ;
        [[DAOAdapter share] commitObject:item];
    }
}

-(void) markAllFriendRequestNoticesAsRead{
    NSArray *arrAllUnreadFriendRequestNotices = [self getAllNoticesWithContent:kNOTICEBOARD_CONTENT_ADD_CONTACT status: kNOTICEBOARD_STATUS_NEW];
    if(!arrAllUnreadFriendRequestNotices)
        return;
    
    for (NoticeBoard *item in arrAllUnreadFriendRequestNotices){
        item.status = kNOTICEBOARD_STATUS_READ;
        [[DAOAdapter share] commitObject:item];
    }
}

- (NSInteger) getNumberUnreadNotices{
    NSString* queryNotice = [NSString stringWithFormat:@"status = '%@'", kNOTICEBOARD_STATUS_NEW];
    NSArray *arrUnreadNotices = (NSArray*)[[DAOAdapter share] getObjects:[NoticeBoard class] condition:queryNotice];
    return arrUnreadNotices.count;
}

#pragma mark Notification domain delegate
- (void) internetDisconnected{
    NSLog(@"Internet not reachable");
    [contactNotificationDelegate showNoInternet:NO_INTERNET_CONNECTION_MESSAGE];
    [chatListNotificationDelegate showNoInternet:NO_INTERNET_CONNECTION_MESSAGE];
    [[ContactFacade share] updateContactStateWhenDisconnect];
    [sipDelegate noInternetconnection];
}

- (void) internetConnected{
    NSLog(@"Internet reachable");
    [contactNotificationDelegate hideInternetView:InternetViewTypeNoInternetConnection];
    [chatListNotificationDelegate hideInternetView:InternetViewTypeNoInternetConnection];
    [emailComposeDelegate resendEmails];
    [[ContactFacade share] updateContactStateWhenReconnect];
    [[AppFacade share] callReUploadPasscodeToServer];
}

#pragma mark Notification setting flags
-(NSString*)getNotificationAlertInAppFlag{
    NSString* value = [KeyChainSecurity getStringFromKey:kENABLE_INAPP_NOTIFICATION_ALERT];
    
    if(!value){
        value = [NSString stringWithFormat:IS_YES];
        [KeyChainSecurity storeString:value Key:kENABLE_INAPP_NOTIFICATION_ALERT];
    }
    return value;
}

-(NSString*)getNotificationSoundInAppFlag{
    NSString* value = [KeyChainSecurity getStringFromKey:kENABLE_INAPP_NOTIFICATION_SOUND];
    
    if(!value){
        value = [NSString stringWithFormat:IS_YES];
        [KeyChainSecurity storeString:value Key:kENABLE_INAPP_NOTIFICATION_SOUND];
    }
    return value;
}

-(void)setNotificationAlertInAppFlag:(NSString*)value{
    [KeyChainSecurity storeString:value Key:kENABLE_INAPP_NOTIFICATION_ALERT];
}

-(void)setNotificationSoundInAppFlag:(NSString*)value{
    [KeyChainSecurity storeString:value Key:kENABLE_INAPP_NOTIFICATION_SOUND];
}

#pragma mark Play sound notification/ChatMessage

-(void)playSoundNotification{
    if(![[self getNotificationSoundInAppFlag] boolValue])
        return;
    
    if(isPlayingSound)
        return;
    
    isPlayingSound = YES;
    
    NSString *soundPath = [[NSBundle mainBundle] pathForResource:AUD_RECEIVE_MSG_SOUND ofType:@"mp3"];
    [[NotificationAdapter share] playSoundWithFilePath:soundPath];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        isPlayingSound = FALSE;
    });
}

- (void)playSoundMessage:(id) message{
    if(![[self getNotificationSoundInAppFlag] boolValue])
        return;
    
    if(![message isKindOfClass:[Message class]])
        return;
    
    Message *currentMessage = (Message *)message;
    ChatBox* chatBox = [[AppFacade share] getChatBox:currentMessage.chatboxId];
    
    BOOL isChatboxSoundOn = [chatBox.soundSetting boolValue];
    if(!isChatboxSoundOn)
        return;
    
    if(isPlayingSound)
        return;
    
    isPlayingSound = YES;
    
    NSString *fileName = [NSString new];
    if([[ChatFacade share] isMineMessage:currentMessage])
        fileName  = AUD_SEND_MSG_SOUND;
    else
        fileName = AUD_RECEIVE_MSG_SOUND;
    
    NSString *soundPath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"mp3"];
    [[NotificationAdapter share] playSoundWithFilePath:soundPath];
    
    double delayTime = 0;
    if([[ChatView share].chatBoxID isEqual:currentMessage.chatboxId])
        delayTime = 0.5;
    else
        delayTime = 3.0;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        isPlayingSound = FALSE;
    });
}

#pragma mark Suport methods
- (NSString *)stringNumberNotification:(NSInteger) unreadNumber
{
    if(unreadNumber < 10)
        return [NSString stringWithFormat:@"%ld", (long)unreadNumber];
    else
        return @"9+";
}

-(void) setUnreadNotification:(NSInteger)count atMenuIndex:(NSInteger)menuIndex{
    [sideBarDelegate reloadNotificationCount:count MenuID:menuIndex];
}

- (BOOL) isInternetConnected{
    return [[NotificationAdapter share] checkInternetConnected];
}

-(void) hideNotificationView{
    if([self getNumberUnreadNotices] == 0){
        [contactNotificationDelegate hideNotification];
    }
}

-(void) hideInternetViewOfXmppConnection{
    [contactNotificationDelegate hideInternetView:InternetViewTypeConnectingXMPP];
    [contactNotificationDelegate hideInternetView:InternetViewTypeNoServerConnection];
    [chatListNotificationDelegate hideInternetView:InternetViewTypeConnectingXMPP];
    [chatListNotificationDelegate hideInternetView:InternetViewTypeNoServerConnection];
}


@end
