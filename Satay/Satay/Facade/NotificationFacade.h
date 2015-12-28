//
//  NotificationFacade.h
//  Satay
//
//  Created by MTouche on 4/10/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum{
    InternetViewTypeGeneral,
    InternetViewTypeConnectingXMPP,
    InternetViewTypeNoInternetConnection,
    InternetViewTypeNoServerConnection
} InternetViewType;

typedef enum{
    SideBarContactIndex,
    SideBarChatIndex,
    SideBarEmailIndex,
    SideBarSecureNoteIndex,
    SideBarNotificationIndex,
    SideBarSettingIndex
} SideBarIndex;

// notice board content
#define kNOTICEBOARD_CONTENT_DELETE_CONTACT @"DELETE FRIEND CONTACT"
#define kNOTICEBOARD_CONTENT_ADD_CONTACT @"ADD FRIEND CONTACT"

//notice board title
#define kNOTICEBOARD_TITLE_NEW @"Insert New Notice"

// notice board status
#define kNOTICEBOARD_STATUS_NEW @"NEW"
#define kNOTICEBOARD_STATUS_READ @"READ"

// notice type
#define kNOTICEBOARD_TYPE_ADD_CONTACT 0
#define kNOTICEBOARD_TYPE_DELETE_CONTACT 1

// notice message
#define mNOTICEBOARD_DELETE_CONTACT @" removed your contact."
#define mNOTICEBOARD_ADD_CONTACT @" send you a friend request"

// Notification alert/sound in App Setting
#define kENABLE_INAPP_NOTIFICATION_SOUND @"ENABLE_INAPP_NOTIFICATION_SOUND"
#define kENABLE_INAPP_NOTIFICATION_ALERT @"ENABLE_INAPP_NOTIFICATION_ALERT"

// SIP call end
#define kNOTIFICATION_CALL_END @"CallEnd"

@interface NotificationFacade : NSObject<NotificationDomainDelegate>{
    NSObject <IncomingNotificationDelegate> *incomingNotificationDelegate;
    NSObject <NotificationListDelegate> *notificationListDelegate;
    NSObject <ContactNotificationDelegate> *contactNotificationDelegate;
    NSObject <ChatListNotificationDelegate> *chatListNotificationDelegate;
    NSObject <EmailComposeDelegate> *emailComposeDelegate;
    NSObject <SideBarDelegate> *sideBarDelegate;
    NSObject <SIPDelegate> *sipDelegate;
}

@property (strong , retain) NSObject* incomingNotificationDelegate;
@property (strong , retain) NSObject* notificationListDelegate;
@property (strong , retain) NSObject* contactNotificationDelegate;
@property (strong , retain) NSObject* chatListNotificationDelegate;
@property (strong , retain) NSObject* emailComposeDelegate;
@property (strong , retain) NSObject* sideBarDelegate;
@property (strong , retain) NSObject* sipDelegate;

/*
 *Singleton of this method.
 *@Author TrungVN
 */
+(NotificationFacade *)share;
/*
 *config Application to receive remote notification.
 *@Author TrungVN
 */
-(void) configNotification;
/*
 *register token with server.
 *@Author TrungVN
 */
-(void) registerWithServer:(NSData*) token;

/**
 * Start notifier Reachability
 * Author: Violet
 */
- (void) setupReachability;

/*
 *display the message notification locally
 *@Author TrungVN
 */
-(void) notifyMessageReceived:(Message*) message groupName:(NSString*) groupName;

/**
 *  Display incoming friend request locally
 *  Author: Violet
 */
-(void) notifyFriendRequestReceived:(Request*)request;

/**
 *  Display remove contact notification locally
 *  @param fullJID: JID of friend that removed you
 *  Author: Violet
 */
-(void) notifyRemovedContactReceived:(NSString*)fullJID;

/**
 *  Insert new notice into local database
 *  noticeType: IN_Type_NEW_REQUEST/IN_Type_DELETE_REQUEST
 */
- (void) insertNewNoticeWithID:(NSString *) noticeID type:(int) noticeType;

/**
 *  Delete notices with noticeID
 *  Author: Violet
 */
- (void) deleteNoticesWithID:(NSString *) noticeID;

/**
 *  Mark all unread notices to read aftew vieing
 *  Author: Violet
 */
- (void) markAllNoticesAsRead;

/**
 *  Mark all unread friend request notices to read after viewing
 *  Author: Violet
 */
-(void) markAllFriendRequestNoticesAsRead;

/**
 *  Delete all removed contact notices after viewing
 *  Author: Violet
 */
- (void) deleteAllRemovedContactNotices;

/**
 *  Get the number of unread notices
 *  Author: Violet
 */
- (NSInteger) getNumberUnreadNotices;

/**
 *  Set number of unread Chat/Email/Notification at Side bar
 *  Author: Violet
 */
-(void) setUnreadNotification:(NSInteger)count atMenuIndex:(NSInteger)menuIndex;

/**
 *  Check current network status
 *  Author:Violet
 */
- (BOOL) isInternetConnected;

/**
 *  Remove push notification badge
 *  Author: Violet
 */
- (void) removeAppBadge;

/**
 *  Get notification alert flag in app setting
 *  Author:Violet
 */
-(NSString*)getNotificationAlertInAppFlag;

/**
 *  Get notification sound flag in app setting
 *  Author: Violet
 */
-(NSString*)getNotificationSoundInAppFlag;

/**
 *  Set notifiction alert flag in app setting
 *  Author:Violet
 */
-(void)setNotificationAlertInAppFlag:(NSString*)value;

/**
 *  Set notification sound flag in app setting
 *  Author:Violet
 */
-(void)setNotificationSoundInAppFlag:(NSString*)value;

/**
 *  Play notification sound of new request/delete friend
 *  Author: Violet
 */
-(void)playSoundNotification;

/**
 *  Play notification sound of incomming message
 *  @param message: incomming message
 
 */
- (void)playSoundMessage:(id) message;

/*
 *  Hide notification view at Contact list 
 *  Author: Violet
 */
-(void) hideNotificationView;

/**
 *  Hide  xmpp connection view at Contact/Chat
 *  Author: Violet
 */
-(void) hideInternetViewOfXmppConnection;

/**
 *  Get new  notice with noticeID and notice's content
 *  Author: Violet
 */
- (NoticeBoard*) getNewNoticeWithID:(NSString*) noticeID content:(NSString*) content;

/**
 *  Get list of all notices, sort by updateTS
 *  @param content notice's content
 *  @param status  notice's status
 *  @return array of noticeBoard if have
 *  Author: Violet
 */
- (NSArray*) getAllNoticesWithContent:(NSString*) content status:(NSString*) status;

/**
 *  Show banner notification of incomming new email
 *  @param numberNewEmail the number of new emails
 *  Violet
 */
-(void) notifyNewEmailReceived:(int) numberNewEmail;

/**
 *  Show banner local nofitication at lock screen
 *
 *  @param message message will show
 *  @param number  number in message and badge icon
 *  @author William
 */
- (void) showLocalNotification:(NSString*)message numberNotice:(int)number;

/**
 *  Change notification number into string
 *  If number > 9 string will be 9+
 *
 *  @param unreadNumber number of unread notification
 *
 *  @return string of unread notification
 *  @author William
 */
- (NSString *)stringNumberNotification:(NSInteger) unreadNumber;
@end


