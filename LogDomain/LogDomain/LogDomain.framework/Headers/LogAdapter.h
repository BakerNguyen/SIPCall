//
//  LogDomainAdpter.h
//  LogDomain
//
//  Created by Duong (Daryl) H. DANG on 4/20/15.
//  Copyright (c) 2015 Duong (Daryl) H. DANG. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GAIHeader;
@class SRDHTTPClient, SRDLogContent;

// define google analysis text
static NSString *trackerID           = @"UA-63912826-1";
//App Category
static NSString *APP_Category           = @"Splash";
static NSString *openApp_Action         = @"Open App"; // Click
static NSString *labelAction            = @"Click";

//Profile Category
static NSString *Profile_Category           = @"User Profile";
static NSString *openProfile_Action         = @"Open_Profile_Action";           // Click
static NSString *addProfilePhoto_Action     = @"Add Photo";      //Success change photo
static NSString *changeDisplayName_Action   = @"Change display name";     // Change display name
static NSString *whatUp_Action              = @"Change What’s up";                // Change sentence
static NSString *changeSentence_Action   = @"Change Sentence";
// Contact Category
static NSString *Contact_Category           = @"Contact";          // click
static NSString *openContact_Action         = @"Open";       // Call Success
static NSString *freeCall_Action            = @"Call";          // Click
static NSString *chatClick_Action           = @"Chat";         //Click
static NSString *emailClick_Action          = @"Email";        //Click
static NSString *infoClick_Action           = @"Info";        //Click

// Chat Category
static NSString *Chat_Category           = @"Chat";          // click
static NSString *openChat_Action         = @"Open";       // Create Group
static NSString *openChat_Label          = @"Create Group";       // Create Group
static NSString *composeGroup_Action     = @"Compose";   // Click
static NSString *clickConversation_Action= @"Conversation";    // Click


static NSString *enterConversation_Action = @"Apply to enter conversation";  // Count

// Setting Category
static NSString *Setting_Category           = @"Setting";
static NSString *openSetting_Action         = @"Open";      // click
static NSString *tellaFriend_Action         = @"Tell a Friend";     // Success Tell - count, send type
static NSString *feedback_Action            = @"Feed back";   // Send Success
static NSString *reviewClick_Action         = @"Review";       // click
static NSString *myAccountClick_Action      = @"My Account";   // click
static NSString *paymentOption_Action       = @"Payment Option";     // click
static NSString *passcodeLockOff_Action     = @"Password lock";   // click
static NSString *stealthModeON_Action       = @"Stealth Mode";    // click
static NSString *manageStorage_Action       = @"Manage Storage";     // click
static NSString *qrCode_Click_Action        = @"QR";       // click

// Select timer
static NSString *Conversation_Category    = @"Conversation";
static NSString *selfDestructTimer        = @"Self Destruct Timer";
static NSString *selectTimer30Second      = @"30 second";
static NSString *selectTimer60Second      = @"1 minute";
static NSString *selectTimer3mins         = @"3 minutes";
static NSString *selectTimer5mins         = @"5 minutes";
static NSString *selectTimer10mins        = @"10 minutes";
static NSString *selectTimer_Label        = @"Choose Timer";
static NSString *sendPhoto_Action        = @"Image Message";      // Success send
static NSString *sendVideo_Action        = @"Video Message";      // Success send
static NSString *freeCallContact_Action  = @"Call";      // Call Success
static NSString *sendAudio_Action        = @"Audio Message";      // Success send
static NSString *send_Label              = @"Send";

static NSString *shareFacebook_Click_Action = @"Facebook";
static NSString *shareTwitter_Click_Action  = @"Twitter";
static NSString *signUp_Click_Action      = @"Sign Up";
static NSString *shareSMS_Click_Action      = @"SMS";
static NSString *shareEmail_Click_Action    = @"Email";
// Secure Note Category
static NSString *SecureNote_Category      = @"Secure Note";
static NSString *openSecureNote_Action    = @"Open";      // click
static NSString *encryptNote_Action       = @"Encrypt Note"; // click - Count
static NSString *createEditNote_Action    = @"Create /Edit Secure Note"; // click - Count

// Email Category
static NSString *Email_Category           = @"Email";
static NSString *openEmail_Action         = @"Open Email";      // click
static NSString *setUp_Action             = @"Set Up";     // Setup - Count, email type
static NSString *emailPageClick_Action    = @"Email Page"; // click - Count
static NSString *setUpGmailAction         = @"Gmail"; // click - Count
static NSString *setUpHotmailAction       = @"Other"; // click - Count
static NSString *setUpOfficeAction        = @"Outlook"; // click - Count
static NSString *setUpMicrosoftAction     = @"Exhange"; // click - Count
static NSString *setUpYahooAction         = @"Yahoo"; // click - Count
// Purchase Category
static NSString *Purchase_Category           = @"Purchase";
static NSString *openPurchase_Action         = @"Open";      // click
static NSString *purchaseListClick_Action    = @"Purchase List";// click
static NSString *purchaseTypeBuy_Action      = @"Purchase buy";// click
static NSString *purchaseTypePrice_Action    = @"Purchase Type";// click, price

typedef enum {
    share_SMS = 0,
    share_Email=1,
    share_Facebook=2,
    share_Twitter=3
} tellFriendType;


@interface LogAdapter : NSObject

typedef void (^PushLogCallBack)(BOOL success, NSDictionary *response, NSError *error);

@property (nonatomic) BOOL termAndConditionFlag;

/**
 *  Singleton for this object
 *  @author Daryl
 *
 *  Purpose, use this method to prevent re-new object.
 */
+ (instancetype)share;

/**
 *  Log with level
 *  @author Daryl
 *  @param loglevel :Log level name. Only support these level: debug (100), info (200), notice (250), warning (300), error (400), critical (500), alert (550), emergency (600).
 *  @param paramettersDic must have value for keys: LOG_CLASS, LOG_CATEGORY, LOG_MESSAGE, LOG_EXTRA1, LOG_EXTRA2
 */
- (void)logWithLevel:(NSInteger)level
             ParaDic:(NSDictionary *)parametterDic;

/**
 * Push log to server with scenario and format.
 * @author Daryl
 * @parameter parametersDic must have value for keys:REQUEST_SOURCE, REQUEST_DEVICE, REQUEST_OSVERSION, REQUEST_APPVERSION,  REQUEST_SCENARIO, REQUEST_SESSION_ID (we group log by sessionID), REQUEST_FORMAT (json),  REQUEST_CONTENT (Array of log in dictionary), REQUEST_EXTRA1, REQUEST_EXTRA2
 * @return callback with response include: (BOOL success, NSDictionary *response, NSError *error)
 */
- (void)pushLogsToServerWithDic:(NSDictionary *)paramettersDic
                          callback:(PushLogCallBack)callback;


/**
 *  Direct save all logs to file.
 *  @author Daryl
 *
 */
- (BOOL)saveLogsToFile;

/**
 *  Direct clear all logs in object and file.
 *  @author Daryl
 *
 */
- (BOOL)clearLogs;

/**
 *  Remove a specific log object
 *
 *  @param log SRDLogContent object
 */
- (void)removeLog:(SRDLogContent *)log;

/**
 *  Get log in dictionary format
 *
 *  @param log input
 *
 *  @return dictionary of log
 */
- (NSDictionary *)getDictionaryOfLog:(SRDLogContent *) log;

/**
 *  Remove array of SRDLogContent object
 *
 *  @param array array of SRDLogContent object
 */
- (void)removeArrayOfLog:(NSArray *)array;

/**
 *  Get log file data
 *  @author Daryl
 *
 *  @return data of log file.
 */
- (NSData *)logFileData;

/**
 *  Load Configuration file.
 *  @author Daryl
 *
 *  @param fileName File name.
 *  @param type    Currently, we accept plist file.
 *
 *  @return Yes if file is valid and load success full;
 */
- (BOOL)loadConfigFileWithFileName:(NSString *)fileName Type:(NSString *)fileType;

/**
 *  Get all current log.
 *
 *  @return array of all log
 */
- (NSArray *)getAllLog;

/**
 *  Get all session of log
 *
 *  @return array of session.
 */
- (NSArray *)getAllSession;

/**
 *  Get log by session
 *
 *  @param sessionID Session of log need
 *
 *  @return Array of log have session user need.
 */
- (NSArray *)getLogWithSessionID:(NSString *)sessionID;

/**
 *  Get device name
 *
 *  @return device name
 */
- (NSString*) getDeviceName;

/**
 *  get current OS version
 *
 *  @return OS version
 */
- (NSString*) getOSVerion;

/**
 *  Get current app version running log
 *
 *  @return app version
 */
- (NSString*) getAppVersion;


/**
 *  Get current system name
 *
 *  @return app version
 */
- (NSString *)getSystemName;

/**
 *  Get current device model
 *
 *  @return app version
 */
- (NSString *)getdeviceModel;

/**
 *  Save array crash log trace to file
 */

- (void)crashHandlerWithLogTrackStr:(NSString*) LogTrackStr;

/**
 *  Get data of crash file log
 */
- (NSData *)getCrashLogFileData;
#pragma mark Google Analysis Tracker

/**
 * Load google analysic tracker.
 * Author: Jurian
 */
- (void) loadTracker;

/**
 * Load tracking Screen.
 * Author: Jurian
 */
- (void)trackingScreen:(NSString*)screenName;

/**
 * Create an event for updating google analysis.
 * @param category Category name of google analysis app
 * @param action Action name of google analysis app
 * @param action label name of google analysis app
 * Author: Jurian
 */
- (void)createEventWithCategory:category
                         action:action
                          label:labelAction;
@end

