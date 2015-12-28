//
//  EmailFacade.h
//  Satay
//
//  Created by enclave on 3/19/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EmailDomain/EmailDomain.h>
#import <MailCore/MailCore.h>
#import "CWindow.h"


#define kYAHOO_IMAP_HOSTNAME @"imap.mail.yahoo.com"
#define kYAHOO_SMTP_HOSTNAME @"smtp.mail.yahoo.com"

#define kGMAIL_IMAP_HOSTNAME @"imap.gmail.com"
#define kGMAIL_SMTP_HOSTNAME @"smtp.gmail.com"

#define kOUTLOOK_IMAP_HOSTNAME @"imap-mail.outlook.com"
#define kOUTLOOK_SMTP_HOSTNAME @"smtp-mail.outlook.com"

#define kEMAIL_PORT_993 993 //ssl:true
#define kEMAIL_PORT_143 143 //"starttls":true

#define kEMAIL_PORT_25 25 //"starttls":true
#define kEMAIL_PORT_465 465 //ssl:true
#define kEMAIL_PORT_587 587 //"starttls":true

#define kEMAIL_PORT_110 110 //"starttls":true
#define kEMAIL_PORT_995 995 //ssl:true

#define kEMAIL_FOLDER_JUNK_EMAIL @"Junk Email"
#define kEMAIL_FOLDER_GMAIL_SPAM @"[Gmail]/Spam"
#define kEMAIL_FOLDER_BULK_MAIL @"Bulk Mail"

#define kNUMBER_OF_EMAIL_TO_LOAD_10 10

#define kEMAIL @"EMAIL"
#define kIS_LOGGED_IN_EMAIL @"IS_LOGGED_IN_EMAIL"
//Define dictionary keys
#define kEMAIL_ADDRESS @"EMAIL_ADDRESS"
#define kEMAIL_PASSWORD @"EMAIL_PASSWORD"
#define kEMAIL_ACCOUNT_TYPE @"EMAIL_ACCOUNT_TYPE"
#define kEMAIL_DISPLAYNAME @"EMAIL_DISPLAYNAME"
#define kEMAIL_SIGNATURE @"EMAIL_SIGNATURE"
#define kEMAIL_KEEPING @"EMAIL_KEEPING"
#define kEMAIL_USE_ENCRYPTED @"EMAIL_USE_ENCRYPTED"
#define kEMAIL_SYNC_SCHEDULE @"EMAIL_SYNC_SCHEDULE"
#define kEMAIL_PERIOD_SYNC_SCHEDULE @"EMAIL_PERIOD_SYNC_SCHEDULE"
#define kEMAIL_USE_SYNC @"EMAIL_USE_SYNC"
#define kEMAIL_RETRIVAL_SIZE @"EMAIL_RETRIVAL_SIZE"
#define kEMAIL_USE_NOTIFY @"EMAIL_USE_NOTIFY"
#define kEMAIL_AUTO_DOWNLOAD_WIFI @"EMAIL_AUTO_DOWNLOAD_WIFI"
#define kEMAIL_INC_USENAME @"EMAIL_INC_USERNAME"
#define kEMAIL_INC_PASSWORD @"EMAIL_INC_PASSWORD"
#define kEMAIL_INC_HOST @"EMAIL_INC_HOST"
#define kEMAIL_INC_PORT @"EMAIL_INC_PORT"
#define kEMAIL_INC_USE_SSL @"EMAIL_INC_USE_SSL"
#define kEMAIL_INC_SECURITY_TYPE @"EMAIL_INC_SECURITY_TYPE"
#define kEMAIL_OUT_USENAME @"EMAIL_OUT_USERNAME"
#define kEMAIL_OUT_PASSWORD @"EMAIL_OUT_PASSWORD"
#define kEMAIL_OUT_HOST @"EMAIL_OUT_HOST"
#define kEMAIL_OUT_PORT @"EMAIL_OUT_PORT"
#define kEMAIL_OUT_SECURITY_TYPE @"EMAIL_OUT_SECURITY_TYPE"
#define kEMAIL_OUT_REQUIRE_AUTH @"EMAIL_OUT_REQUIRE_AUTH"
#define kEMAIL_STORE_PROTOCOL @"EMAIL_STORE_PROTOCOL"
#define kEMAIL_POP3_DELETABLE @"EMAIL_POP3_DELETABLE"
#define kEMAIL_IMAP_PATH_PREFIX @"EMAIL_IMAP_PATH_PREFIX"

#define kEMAIL_SERVER_MICROSORT @"EMAIL_SERVER_MICROSORT"
#define kEMAIL_DOMAIN_MICROSORT @"EMAIL_DOMAIN_MICROSORT"

#define kMESSAGE_HEADER @"MESSAGE_HEADER"
#define kFOLDER_INDEX @"FOLDER_INDEX"
#define kFOLDER_NAME @"FOLDER_NAME"
#define kUID @"UID"
#define kEMAIL_COUNT @"EMAIL_COUNT"
#define kEMAIL_TOTAL @"EMAIL_TOTAL"
#define kEMAIL_INDEX @"EMAIL_INDEX"

#define kEMAIL_CONNECTION_TYPE @"EMAIL_CONNECTION_TYPE"
#define kEMAIL_DESCRIPTION @"EMAIL_DESCRIPTION"

#define kEMAIL_ACCOUNT_TYPE_MICROSOFT_EXCHANGE 0
#define kEMAIL_ACCOUNT_TYPE_GMAIL 1
#define kEMAIL_ACCOUNT_TYPE_YAHOO 2
#define kEMAIL_ACCOUNT_TYPE_HOTMAIL 3
#define kEMAIL_ACCOUNT_TYPE_OTHER_IMAP 4
#define kEMAIL_ACCOUNT_TYPE_OTHER_POP 5

#define kEMAIL_CONNECTION_TYPE_CLEAR 0
#define kEMAIL_CONNECTION_TYPE_STARTTLS 1
#define kEMAIL_CONNECTION_TYPE_TLS_SSL 2

//Folder Index
#define kINDEX_FOLDER_INBOX 1
#define kINDEX_FOLDER_DRAFTS 2
#define kINDEX_FOLDER_SENT 3
#define kINDEX_FOLDER_RECYCLE_BIN 4
#define kINDEX_FOLDER_JUNK 5
#define kINDEX_FOLDER_OUTBOX 6
#define kINDEX_FOLDER_SAVED_EMAILS 7

#define kEMAIL_ENC_BODY @"EMAIL_ENC_BODY"
#define kEMAIL_ENC_ATTACHMENT @"EMAIL_ENC_ATTACHMENT"
#define kEMAIL_DEC_BODY @"EMAIL_DEC_BODY"
#define kEMAIL_DEC_ATTACHMENT @"EMAIL_DEC_ATTACHMENT"
#define kDELETE @"DELETE"

#define kEMAIL_HEADER_KEY @"emailHeader"
#define kEMAIL_CONTENT_KEY @"emailContent"
#define kEMAIL_ATTACHMENT_KEY @"arrayAttachment"

//define key for oldest email and newest email
#define kEMAIL_INBOX_OLDEST @"EMAIL_INBOX_OLDEST"
#define kEMAIL_INBOX_NEWEST @"EMAIL_INBOX_NEWEST"
#define kEMAIL_JUNK_OLDEST @"EMAIL_JUNK_OLDEST"
#define kEMAIL_JUNK_NEWEST @"EMAIL_JUNK_NEWEST"

#define kNUMBER_DELETE_EMAIL -9999

#define kEMAIL_ERROR_DOMAIN @"EmailErrorDomain"

typedef enum {
    kEMAIL_KEEPING_3_DAYS,
    kEMAIL_KEEPING_1_WEEK,
    kEMAIL_KEEPING_1_MONTH,
    kEMAIL_KEEPING_3_MONTHS,
    kEMAIL_KEEPING_NEVER
} EmailKeepingType;

@interface EmailFacade : NSObject{
    NSObject <EmailLoginDelegate> *emailLoginDelegate;
    NSObject <EmailLoadMoreDelegate> *loadMoreEmailDelegate;
    NSObject <EmailDetailDelegate> *emailDetailDelegate;
    NSObject <EmailSettingDelegate> *emailSettingDelegate;
    NSObject <EmailComposeDelegate> *emailComposeDelegate;
    NSObject <CreateEmailFolderDelegate> *createEmailFolderDelegate;
    NSObject <SideBarDelegate> *sideBarDelegate;
    NSObject <ChatViewDelegate> *chatViewDelegate;
}

@property (strong , retain) NSObject* emailLoginDelegate;
@property (strong , retain) NSObject* loadMoreEmailDelegate;
@property (strong , retain) NSObject* emailDetailDelegate;
@property (strong , retain) NSObject* emailSettingDelegate;
@property (strong , retain) NSObject* emailComposeDelegate;
@property (strong , retain) NSObject* createEmailFolderDelegate;
@property (strong , retain) NSObject* sideBarDelegate;
@property (strong , retain) NSObject* chatViewDelegate;

+(EmailFacade *)share;
// Common
/* *
 * Get login email flag. This one will know user did login email or not
 * @return: YES/NO.
 *
 * @Author Parker
 */
-(NSString*)getLoginEmailFlag;

/* *
 * Check email address is valid or not
 * @parameters: emailAddress.
 * @return: TRUE/FALSE
 * @Author Parker
 */
-(BOOL) checkValidEmailAddress:(NSString*)emailAddress;

/* *
 * Get email address
 * @return: string of email address of user
 * @Author Parker
 */
-(NSString*)getEmailAddress;

/* *
 * Get the order from deletion email string
 * @paramemter: deletionEmail. string of deletion email
 * @return: NSInteger of order
 * @Author Parker
 */
-(NSInteger)getOrderDeleteEmailFromServer:(NSString*)deletionEmail;

/* *
 * Get the order from sync schedule string
 * @paramemter: syncSchedule. string of sync schedule email
 * @return: NSInteger of order
 * @Author Parker
 */
-(NSInteger)getOrderSyncSchedule:(NSString*)syncSchedule;

/* *
 * Get seconds timer from period sync schedule
 * @paramemter: periodSyncSchedule. the order of sync schedule
 * @return: NSInteger of timer as seconds
 * @Author Parker
 */
-(NSInteger)getTimerFromPeriodSyncSchedule:(NSInteger)periodSyncSchedule;

//Mail Folder
/* *
 * Create default email folders
 * @Author Parker
 */
-(void) createDefaultEmailFolders;

/* *
 * Create new folder.
 * @parameters: folderName, folderIndex, status
 * @Author Parker
 */
-(void)createEmailFolder:(NSString*)folderName folderIndex:(NSInteger)folderIndex status:(NSString*)status;

/* *
 * Delete folder.
 * @parameters: folderName
 * @Author Arpana
 */
-(void)deleteEmailFolder:(NSString*)folderName;

/* *
 * Get all email folders.
 * @return: array of all MailFolder object
 * @Author Parker
 */
-(NSArray*) getAllEmailFolders;

/* *
 * Get mail folder from index.
 * @parameter: folderIndex. folder index
 * @return: mail folder object
 * @Author Parker
 */
-(MailFolder*) getMailFolderFromIndex:(NSInteger)folderIndex;

//MailHeader
/* *
 * Get mail header from folder index.
 * @parameter: folderIndex. folder index
 * @return: array of mail header objects
 * @Author Parker
 */
-(NSArray*) getEmailHeadersInFolder:(NSInteger)folderIndex;

/* *
 * Get mail header with order by.
 * @parameter:
 isDescending. is decending or not
 folderIndex, folder index.
 limit, limit of query
 * @return: array of mail header objects
 * @Author Parker
 */
-(NSMutableArray*) getEmailHeadersWithOrderBy:(BOOL)isDescending
                                     inFolder:(NSInteger) folderIndex
                                        limit:(int)limit
                                    oldestUID:(NSString *)oldestUID
                                     isGetOld:(BOOL)isGetOld;

/* *
 * Update seen flag for email.
 * @parameter:
 uid. uid of email
 *
 * @Author Parker
 */
- (void)updateSeenFlagForEmail:(NSString*)uid;

//Mail Account
/* *
 * Get mail account.
 * @parameter:
 username: email address
 * @return: mail account object
 *
 * @Author Parker
 */
-(MailAccount*) getMailAccount:(NSString*)username;

/* *
 * Update mail account.
 * @parameter:
 mailAccount. mailAccount object
 * @return: TRUE/FALSE
 *
 * @Author Parker
 */
-(BOOL) updateMailAccount:(MailAccount*) mailAccount;

//Mail Content
/* *
 * get mail content from header uid.
 * @parameter:
 uid. uid of email
 * @return: MailContent object
 *
 * @Author Parker
 */
-(MailContent*) getMailContentFromMailHeaderUid:(NSString*)uid;

/* *
 * Count total unread email in folder
 * @parameter:
 folderIndex. folder index
 * @return: number of unread email
 *
 * @Author Parker
 */
-(NSInteger) countTotalUnreadEmailInFolderIndex:(NSInteger)folderIndex;

//Get attachment
/* *
 * Get mail attachments
 * @parameter:
 uid. uid of email
 * @return: array of attachments
 *
 * @Author Parker
 */
-(NSArray*) getMailAttachmentsFromUid:(NSString*)uid;

/* *
 * Get attachment data
 * @parameter:
 fileName. file name
 * @return: nsdata of attachment
 *
 * @Author Parker
 */
- (NSData*) getAttachmentDataWithFileName:(NSString*)fileName;

//Sort by
//Gets all emails of a use in folder, put them into groups.
/* *
 * Get emails headers in folder with sort type
 * @parameter:
 userName. email address
 folderIndex. folder index
 groupingType. group type
 * @return: nsdictionary of email headers
 *
 * @Author Parker
 */
- (NSDictionary *)getEmailsOfUser:(NSString *)userName
                           folder:(NSInteger)folderIndex
                     groupingType:(EmailGroupingType)groupingType
              unreadMessageNumber:(NSNumber **)unreadNumber
                       fetchEmail:(NSMutableArray *)arrayEmailHeader;

/* *
 * Get group type by sorting type
 * @parameter:
 sortingType. sorting type
 * @return: nsdictionary of email headers
 *
 * @Author Parker
 */
- (EmailGroupingType)groupingTypeBySortingType:(EmailSortingType)sortingType;

/* *
 * Sort by sections with sorting type.
 * @parameter:
 keys. keys of sections
 sortingType. sorting type
 * @return: array of email headers in section
 *
 * @Author Parker
 */
- (NSArray *)sortedSectionKeysFromKeys:(NSArray *)keys sortingType:(EmailSortingType)sortingType;

/* *
 * get email sorted content.
 * @parameter:
 emailsDict. email dic needs to sort
 sortingType. sorting type
 * @return: nsdictionary of email headers
 *
 * @Author Parker
 */
- (NSDictionary *)emailsDictionayWithSortedContentFromDictionary:(NSDictionary *)emailsDict sortingType:(EmailSortingType)sortingType;

/**
 * Get name string for section in inbox.
 * @author Parker
 *
 * @param (NSString *) sectionKey, section
 * @param (NSUInteger) number
 * @return (NSString*) name string for section
 * version 1.0
 * date 3/Apr/2015
 */
- (NSString *)nameStringForInboxSectionKey:(NSString *)sectionKey itemCount:(NSUInteger)number;

/**
 * Get date string for section in inbox.
 * @author Parker
 *
 * @param (NSString *) sectionKey, section
 * @return (NSString) date string
 * version 1.0
 * date 3/Apr/2015
 */
- (NSString *)dateStringForInboxSectionKey:(NSString *)sectionKey;

/*
 emailAccountDic require
 type = 0(Microsoft Exchange), 1(Gmail), 2(Yahoo), 3(Hotmail-Outlook), 4(Other-IMAP), 5 (Other-POP)
 */
//Login and get emails function
/**
 * Login email account.
 * @author Parker
 *
 * @param (NSDictionary *) emailAccountDic, email account dictionary
 * version 1.0
 * date 3/Apr/2015
 */
-(void)loginEmailAccountType:(NSDictionary*)emailAccountDic;

/**
 * Reset email account.
 * @author Parker
 *
 * @param (NSString *) username, email address
 * version 1.0
 * date 3/Apr/2015
 */
-(void)resetEmailAccount:(NSString*)username;

/**
 * Get configuration of Imap account at local.
 * @author Parker
 *
 * version 1.0
 * date 3/Apr/2015
 */
-(void) getConfigurationImapAccount;

/**
 * Get configuration of Pop account at local.
 * @author Parker
 *
 * version 1.0
 * date 3/Apr/2015
 */
-(void) getConfigurationPopAccount;

/**
 * Get emails for first time.
 * @author Parker
 *
 * @param (NSString *) username, email address
 * version 1.0
 * date 3/Apr/2015
 */
-(void)getEmailHeaders:(NSString *)username;

/**
 * Get more emails.
 * @author Parker
 *
 * version 1.0
 * date 3/Apr/2015
 */
-(void) getMoreEmailHeaders;

/**
 * Get new emails.
 * @author Parker
 *
 * version 1.0
 * date 3/Apr/2015
 */
-(void) getNewEmailHeaders;

/**
 * Decode string.
 * @author Arpana
 *
 * @param: (NSString *)strEncoded, encoded string
 * @return: decrypted string
 * version 1.0
 * date 3/Apr/2015
 */
-(NSString*)decryptString:(NSString *)strEncoded;

/**
 * Encode string.
 * @author Parker
 *
 * @param: (NSString *)normalString, string want to encode
 * @return: encrypted string
 * version 1.0
 * date 3/Apr/2015
 */
-(NSString*)encryptString:(NSString *)normalString;

/**
 * Delete email.
 * @author Parker
 *
 * @param: (NSString *)uid, uid of email
 * @param: (NSInteger)folderIndex, folder index
 * version 1.0
 * date 3/Apr/2015
 */
- (void)deleteEmail:(NSString*)uid inFolder:(NSInteger)folderIndex;

/**
 * Move email to folder.
 * @author Parker
 *
 * @param: (NSString *)uid, uid of email
 * @param: (NSInteger)folderIndex, folder index
 * version 1.0
 * date 3/Apr/2015
 */
-(void)moveEmail:(NSString*)uid toFolder:(NSInteger)folderIndex;

/**
 * Delete email account.
 * @author Parker
 *
 * version 1.0
 * date 3/Apr/2015
 */
- (void)deleteEmailAccount;

/**
 * Send email.
 * @author Parker
 *
 * @param: (NSString*)uid, uid
 * version 1.0
 * date 3/Apr/2015
 */
- (void)sendEmail:(NSString*)uid attachments:(NSArray*)attachmentNames encrypted:(BOOL)isEncrypted isResend:(BOOL)isResend;

/**
 * Re-Send email.
 * @author Parker
 *
 * version 1.0
 * date 11/May/2015
 */
- (void)reSendEmails;

/**
 * Save email.
 * @author Parker
 *
 * parameters:
 * attachmentNames, array attachments name
 * @return: email uid
 * version 1.0
 * date 3/Apr/2015
 */
- (NSString*)saveEmailToFolder:(NSInteger)folderIndex
                           uid:(NSString *)emailUID
                            to:(NSString*)emailTo
                            cc:(NSString*)emailCc
                           bcc:(NSString*)emailBcc
                       subject:(NSString*)emailSubject
                          body:(NSString*)emailBody
                    attachment:(NSArray*)attachmentNames
                     encrypted:(BOOL)isEncrypted;

/**
 * Set email attachment data
 * @author Parker
 *
 * @param (NSString*) attachmentName. ex abc.jpg
 * @param (NSData*) attachmentData. data of attachment file.
 * @return True/False
 * version 1.0
 * date 20/Mar/2015
 */
-(BOOL) setEmailAttachment:(NSString*)attachmentName data:(NSData*) attachmentData;

/**
 *  Remove email out of keeping date
 *  Change email status = 2
 *  @param folderIndex index of current folder
 *  @author William
 */
- (NSMutableArray *)deleteOldEmailInFolder:(NSInteger)folderIndex emails:(NSArray*)arrayEmail;

/* *
 * Check email is encrypted or not
 * @parameters: emailBody: body content of email.
 * @return: TRUE/FALSE
 * @Author Parker
 */
- (BOOL) isEncEmail:(NSString *)emailBody;

/* *
 * Decrypt email
 * @parameters: attachmentNames: array attachments name.
 * @return: Dictionary email encrypted with kEMAIL_DEC_BODY, kEMAIL_DEC_ATTACHMENT
 * @Author Parker
 */
- (NSDictionary *) decrypteEmailContent:(NSString *)emailBody attachments:(NSArray *)attachmentNames;

/**
 *  Re-Download attachment which has not finished downloading yet
 *
 *  @param emailHeader header of email need to redownload attachment
 *  @author William
 *  version 1.0
 *  date 4-May-2015
 */
- (void) reDownLoadAttachmentOfEmail:(MailHeader *)emailHeader;

/**
 *  add receipient into actived textfield in compose view
 *
 *  @param arrayContactSelect selected contacts in find email contact view
 *  @author  William
 *  version 1.0
 *  date 6-Apr-2015
 */
- (void) addReceipientIntoTextFieldWithData:(NSMutableArray *)arrayContactSelect;

/**
 *  Save email folder name into database
 *
 *  @param newFolderName new folder name
 *  @param oldFolderName old folder if this is update name
 *  @author William
 *  date 10-May-2015
 */
- (void) saveEmailFolderName:(NSString *)newFolderName oldName:(NSString *)oldFolderName;

/**
 *  Get database data then show in EmailComposeView
 *
 *  @param emailHeader email header of selected email in draft folder
 *  @author William
 *  date 14-May-2015
 */
- (void) buildReopenComposeWithHeader:(MailHeader *)emailHeader;

/**
 *  Show alert email has been reset, and then delete email in app
 *  @author William
 *  date 19-May-2015
 */
- (void) showAlertResetEmailAccount;

/**
 *  update email of contact to nil when receive notice
 *  kBODY_MT_NOT_EAC_RESET
 *
 *  @param jid jid of that contact
 *  @author William
 *  date 20-May-2015
 */
- (void) updateEmailOfContact:(NSString *)jid;

/**
 *  Get Friend Avatar from his email address
 *
 *  @param emailAddress user's email address
 *
 *  @return avatar of that user
 *  @author William
 *  date 27-May-2015
 */
- (UIImage *)getAvatarFromEmail:(NSString *)emailAddress;

/**
 *  Get email detail of a email
 *
 *  @param emailHeader email header
 *  @author William
 *  date 5-Jun-2015
 */
- (void) getSingleEmailDetailForImapWithHeader:(MailHeader*)emailHeader;

/**
 *  Random id for an object
 *
 *  @return a string of random id
 */
- (NSString *)randomEmailUid;

/**
 *  Update email account data into server
 *
 */
- (void)updateEmailAccountToServer:(NSDictionary*)emailAccountDic;

/**
 *  Get number of email in folder
 *
 *  @param folderIndex index of request folder
 *
 *  @return number of emails in request folder
 *  @date 25-Jun-2015
 *  @author William
 */
-(NSInteger) getNumberOfEmailHeadersInFolder:(NSInteger)folderIndex;

/**
 *  Move to compose view
 *  @date 26-Jun-2015
 *  @author William
 */
-(void) moveToComposeWithEmail:(NSString*)emailContact;

/**
 *  Delete draft email had been saved
 *
 *  @param emailUID uid of email need to delete
 *  @date 29-Jun-2015
 *  @author William
 */
-(void) deleteDraftEmail:(NSString *)emailUID;

/**
 *  Start new sync email schedule after changed in setting
 *
 *  @param syncTime sync time
 *  @date 1-Jul-2015
 *  @author William
 */
- (void) startNewSyncSchedule:(NSInteger)syncTime;

/**
 *  Get single email header from UI in database
 *
 *  @param uid uid of email
 *
 *  @return email header query in database
 *  @author William
 *  @date 20-Jul-2015
 */
- (MailHeader*) getMailHeaderFromUid:(NSString*)uid;

/**
 *  Decrease number of email in folder
 *
 *  @param emailHeader
 *  @author William
 *  @date 20-Jul-2015
 */
- (void) decreaseHeaderNumber:(MailHeader *)emailHeader;

/**
 *  Increase number of email in folder
 *
 *  @param emailHeader
 *  @author William
 *  @date 20-Jul-2015
 */
- (void) increaseHeaderNumber:(MailHeader *)emailHeader;
@end
