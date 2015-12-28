//
//  EmailAdapter.h
//  EmailDomain
//
//  Created by William on 12/24/14.
//  Copyright (c) 2014 enclave. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MailCore/MailCore.h>

extern NSString *const kInboxSectionKeyToday;
extern NSString *const kInboxSectionKeyYesterday;
extern NSString *const kInboxSectionKey2DaysAgo;
extern NSString *const kInboxSectionKey3DaysAgo;
extern NSString *const kInboxSectionKey4DaysAgo;
extern NSString *const kInboxSectionKey5DaysAgo;
extern NSString *const kInboxSectionKey6DaysAgo;
extern NSString *const kInboxSectionKey1WeekAgo;
extern NSString *const kInboxSectionKey2WeeksAgo;
extern NSString *const kInboxSectionKey3WeeksAgo;
extern NSString *const kInboxSectionKey1MonthAgo;
extern NSString *const kInboxSectionKeyOlder;

//Sort by define
typedef enum {
    EmailSortingTypeDateASC,
    EmailSortingTypeDateDESC,
    EmailSortingTypeSenderASC,
    EmailSortingTypeSenderDESC,
    EmailSortingTypeSubjectASC,
    EmailSortingTypeSubjectDESC
} EmailSortingType;

typedef enum {
    EmailGroupingTypeDate,
    EmailGroupingTypeSender,
    EmailGroupingTypeSubject
} EmailGroupingType;

@interface EmailAdapter : NSObject

+(EmailAdapter *)share;

typedef void (^requestCompleteBlock)(BOOL success, NSString *message ,NSDictionary *response, NSError *error);

typedef void (^EmailMessageBlock)(BOOL success, NSArray *messages, NSError *error);
typedef void (^EmailCheckImapAccountBlock)(BOOL success, NSString *message, NSError *error);
typedef void (^EmailUpdateFlag)(BOOL success, NSString *message, NSError *error);
typedef void (^EmailContentBlock)(BOOL success, NSData *messagesContent, NSError *error);
typedef void (^EmailAttachmentBlock)(BOOL success, NSArray *attachments, NSError *error);
typedef void (^EmailSendingBlock)(BOOL success, NSString *statusMessage, NSError *error, NSString *emailUID);
typedef void (^EmailHeaderImapBlock)(BOOL success, MCOIMAPMessage *messageHeader, NSError *error);

typedef void (^EmailCheckPopAccountBlock)(BOOL success, NSString *message, NSError *error);
typedef void (^EmailHeaderPopBlock)(BOOL success, MCOMessageHeader *messageHeader, NSError *error);
typedef void (^EmailDetailPopBlock)(BOOL success, NSData *messagesContent, NSError *error);

typedef void (^EmailAttachmentDataBlock)(BOOL success, NSData *data, NSError *error);

/**
 * Check email address is valid or not
 * @author Parker
 *
 * @param (NSString*) emailAddress
 * @return True/False
 * version 1.0
 * date 20/Mar/2015
 */
-(BOOL) checkValidEmailAddress:(NSString*)emailAddress;

/**
 * Set email attachment
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
 * Get email attachment
 * @author Parker
 *
 * @param (NSString*) attachmentName. ex abc.jpg
 * @return (NSData*). data of attachment file.
 * version 1.0
 * date 20/Mar/2015
 */
-(NSData*) getEmailAttachment:(NSString*)attachmentName;

/**
 * Get file size of email attachment
 * @author Parker
 *
 * @param (NSString*) attachmentName. ex abc.jpg
 * @return (unsigned long). size of attachment file.
 * version 1.0
 * date 20/Mar/2015
 */
-(unsigned long) getEmailAttachmentFileSize:(NSString*)attachmentName;

/**
 * Delete  all attachment files in email attachment folder
 * @author Parker
 *
 * @return True/False
 * version 1.0
 * date 20/Apr/2015
 */
-(BOOL) deleteAllAttachmentsInEmailAttachmentFolder;

/**
 * Update Email Account to tenant server
 * @author Parker
 * @parameter parametersDic must have value for keys:API_REQUEST_METHOD(POST/GET),API_REQUEST_KIND(Upload/Download/Normal), TOKEN, MASKINGID, EMAIL
 * @return callback with response include: STATUS_CODE, STATUS_MSG, SUCCESS
 * version 1.0
 * date 23/Mar/2015
 */
-(void)updateEmailAccountToServer:(NSDictionary*)parametersDic callback:(requestCompleteBlock)callback;

/**
 * Reset Email Account
 * @author Parker
 * @parameter parametersDic must have value for keys:API_REQUEST_METHOD(POST/GET),API_REQUEST_KIND(Upload/Download/Normal), TOKEN, MASKINGID, EMAIL, IMEI, IMSI.
 * @return callback with response include: STATUS_CODE, STATUS_MSG, SUCCESS
 * version 1.0
 * date 23/Mar/2015
 */
-(void)resetEmailAccount:(NSDictionary*)parametersDic callback:(requestCompleteBlock)callback;

/**
 * Configure email account.
 * @author Parker
 *
 * @param (NSString*) username, username account ex abc@gmail.com.
 * @param (NSString*) password, password account.
 * @param (NSString*) hostname, hostname of server mail ex imap.gmail.com
 * @param (int) port, port of server mail
 * @param (NSUInteger) type, connection type ConnectionTypeTLS(2)/ConnectionTypeStartTLS(1)/ConnectionTypeClear(0). Default(>3) is doesn't set connect type.
 * version 1.0
 * date 08/Jan/2015
 */
- (void)configureImapAccount:(NSString*)username password:(NSString*)password hostname:(NSString*)hostname port:(int)port connectionType:(int)type;

/**
 * Check email account with server email.
 * @author Parker
 *
 * @param (EmailCheckImapAccountBlock) callback.
 * version 1.0
 * date 21/Mar/2015
 */
- (void)checkImapAccount:(EmailCheckImapAccountBlock)callback;

/**
 * Get messages email for IMAP account type.
 * @author Parker
 *
 * @param (NSString*) folder, folder you want to get emails ex INBOX, Julk.
 * @param (int) numberMessages, number of emails you want to get
 * @param (EmailMessageBlock) callback, block call back return list of emails
 * @return list of emails /MCOIMAPMessage/ in callback block
 * version 1.0
 * date 25/Dec/2014
 */
- (void)getEmailsHeaderForImap:(NSString*)folder numberMessages:(int)number callback:(EmailMessageBlock)callback;

/**
 * Get messages email for IMAP account type. This function only use for all but except yahoo kind.
 * @author Parker
 *
 * @param (NSString*) folder, folder you want to get emails ex INBOX, Julk.
 * @param (int) numberMessages, number of emails you want to get
 * @param (EmailMessageBlock) callback, block call back return list of emails
 * @return list of emails /MCOIMAPMessage/ in callback block
 * version 1.0
 * date 8/May/2015
 */
- (void)getEmailsHeaderForImapInFolder:(NSString*)folder numberMessages:(int)number callback:(EmailMessageBlock)callback;

/**
 * Get content of emails.
 * @author Parker
 *
 * @param (NSString*) folder, in which folder you want to get.
 * @param (NSString*) uid, uid of email.
 * @param (EmailContentBlock*) callback, callback with messagesContent
 *   using MCOMessageParser * parser = [MCOMessageParser messageParserWithData:messagesContent]
 * version 1.0
 * date 08/Jan/2015
 */
- (void)getEmailsDetailForImap:(NSString*)folder uid:(int)uid callback:(EmailContentBlock)callback;

/**
 * Update flag messages with server.
 * @author Parker
 *
 * @param (NSString*) folder, ex INBOX, Julk.
 * @param (NSInteger) uid, uid of message email want to update flag
 * @param (int) flag, uid of message email want to update flag
 * @param (EmailAccountBlock) callback, block call back return list of emails
 * @return  Returns an operation to change flags of messages.
 For example: Adds the seen flag to the message with UID 456.
 * version 1.0
 * date 25/Dec/2014
 */
-(void)updateFlagMessageWithFolderForImap:(NSString*)folder uid:(NSInteger)uid flag:(int)flag callback:(EmailUpdateFlag)callback;


/**
 * Get new emails for IMAP account type.
 * @author Parker
 *
 * @param (NSString*) folder, folder you want to get emails ex INBOX, Julk.
 * @param (int) fromUID, get fromUID to newest.
 * @param (EmailMessageBlock) callback, block call back return list of emails
 * @return list of emails /MCOIMAPMessage/ in callback block
 * version 1.0
 * date 25/Dec/2014
 */
- (void)getNewEmailsHeaderForImap:(NSString*)folder fromUID:(int)fromUID callback:(EmailMessageBlock)callback;

/**
 * Get new emails for IMAP account type. This function can use for all but except yahoo.
 * @author Parker
 *
 * @param (NSString*) folder, folder you want to get emails ex INBOX, Julk.
 * @param (int) fromUID, get fromUID to newest.
 * @param (EmailMessageBlock) callback, block call back return list of emails
 * @return list of emails /MCOIMAPMessage/ in callback block
 * version 1.0
 * date 8/May/2015
 */
- (void)getNewEmailsHeaderForImapInFolder:(NSString*)folder fromUID:(int)fromUID callback:(EmailMessageBlock)callback;
/**
 * Get old emails for IMAP account type.
 * @author Parker
 *
 * @param (NSString*) folder, folder you want to get emails ex INBOX, Julk.
 * @param (int) fromUID, get fromUID to older.
 * @param (int) numberMessages, number of emails you want to get
 * @param (EmailMessageBlock) callback, block call back return list of emails
 * @return list of emails /MCOIMAPMessage/ in callback block
 * version 1.0
 * date 25/Dec/2014
 */
- (void)getOldEmailsHeaderForImap:(NSString*)folder fromUID:(int)fromUID numberMessages:(int)number callback:(EmailMessageBlock)callback;

/**
 * Get old emails for IMAP account type. This function can use for all but except yahoo.
 * @author Parker
 *
 * @param (NSString*) folder, folder you want to get emails ex INBOX, Julk.
 * @param (int) fromUID, get fromUID to older.
 * @param (int) numberMessages, number of emails you want to get
 * @param (EmailMessageBlock) callback, block call back return list of emails
 * @return list of emails /MCOIMAPMessage/ in callback block
 * version 1.0
 * date 8/May/2015
 */
- (void)getOldEmailsHeaderForImapInFolder:(NSString*)folder fromUID:(int)fromUID numberMessages:(int)number callback:(EmailMessageBlock)callback;

/**
 *  Get email header of email has UID
 *  @author William
 *
 *  @param emailUID email UID
 *  @param folder   folder of that email ex: Inbox, Junk, ...
 *  @param callback (EmailHeaderImapBlock) callback, block call back return email header
 *  @return message header of email /MCOIMAPMessage/ in callback block
 *  version 1.0
 *  date 4/May/2015
 */
- (void) getMessageHeaderWithUID:(int)emailUID inFolder:(NSString *)folder callback:(EmailHeaderImapBlock)callback;

/**
 * Download attachments email for IMAP account type.
 * @author Parker
 *
 * @param (NSString*) folder, folder you want to get emails ex INBOX, Julk.
 * @param (int) uid, uid of email.
 * @param (EmailAttachmentBlock) callback, block call back return data attachment
 * @return
 * version 1.0
 * date 25/Dec/2014
 */
//- (void)downloadAttachmentsEmailForImap:(NSString*)folder uid:(int)uid callback:(EmailAttachmentBlock)callback;

/**
 * Download attachments email for IMAP account type.
 * @author Parker
 *
 * @param (NSString*) folderName, folder you want to get attachment ex INBOX, Julk.
 * @param (int) uid, uid of email.
 * @param (NSString) partId, part id of attachment.
 * @param (MCOEncoding) encoding, encoding type of part of attachment.
 * @param (EmailAttachmentDataBlock) callback, block call back return data attachment
 * @return
 * version 1.0
 * date 10/Apr/2015
 */
- (void) downloadAttachmentsForImapWithFolder:(NSString*)folderName uid:(int)uid partId:(NSString*)partId encoding:(MCOEncoding)encoding callback:(EmailAttachmentDataBlock)callback;

/**
 * Configure smtp. This configuration for sending email
 * @author Parker
 *
 * @param (NSString*) username, username account ex abc@gmail.com.
 * @param (NSString*) password, password account.
 * @param (NSString*) hostname, hostname of server mail ex smtp.gmail.com
 * @param (int) port, port of server mail
 * @param (NSUInteger) type, connection type ConnectionTypeTLS(2)/ConnectionTypeStartTLS(1)/ConnectionTypeClear(0). Default is doesn't set connect type.
 * version 1.0
 * date 19/Mar/2015
 */
- (void)configureSmtp:(NSString*)username password:(NSString*)password hostname:(NSString*)hostname port:(int)port connectionType:(int)type;

/**
 * Send email.
 * @author Parker
 *
 * @param (NSString*) displayName. display name of email address.
 * @param (NSArray*) emailTo. The list of email address want to send to.
 * @param (NSArray*) emailCc. CC list
 * @param (NSArray*) emailBcc. Bcc list
 * @param (NSString*) subject. Email subject
 * @param (NSString*) emailBody. content body of email want to send
 * @param (NSArray*) attachements.array of nsdictionary attachments. kEMAIL_ATTACHMENT_NAME: attachment name, kEMAIL_ATTACHMENT_DATA: attachment data
 * @return (EmailSendingBlock*) callback of sending email
 * version 1.0
 * date 20/Mar/2015
 */
- (void)sendEmailWithUID:(NSString*)emailUID
             displayName:(NSString*)displayName
                      to:(NSArray*)emailTo
                      cc:(NSArray*)emailCc
                     bcc:(NSArray*)emailBcc
                 subject:(NSString*)emailSubject
                    body:(NSString*)emailBody
              attachment:(NSArray*)attachments
                callback:(EmailSendingBlock)callback;

/**
 * Configure email account pop kind.
 * @author Parker
 *
 * @param (NSString*) username, username account
 * @param (NSString*) password, password account.
 * @param (NSString*) hostname, hostname of server mail
 * @param (int) port, port of server mail
 * @param (NSUInteger) type, connection type ConnectionTypeTLS(2)/ConnectionTypeStartTLS(1)/ConnectionTypeClear(0). Default(>3) is doesn't set connect type.
 * version 1.0
 * date 25/Mar/2015
 */
- (void)configurePopAccount:(NSString*)username password:(NSString*)password hostname:(NSString*)hostname port:(int)port connectionType:(int)type;

/**
 * Check pop email account with server email.
 * @author Parker
 *
 * @param (EmailCheckPopAccountBlock) callback.
 * version 1.0
 * date 25/Mar/2015
 */
- (void)checkPopAccount:(EmailCheckPopAccountBlock)callback;

/**
 * Get all emails for POP account type.
 * @author Parker
 *
 * @param (EmailMessageBlock) callback, block call back return list of emails
 * @return list of emails /MCOPOPMessageInfo/ in callback block
 * version 1.0
 * date 25/Dec/2014
 */
- (void)getAllEmailsForPop:(EmailMessageBlock)callback;

/**
 * Get messages header of email for POP account type.
 * @author Parker
 *
 * @param (unsigned int) index, index message
 * @param (EmailHeaderPopBlock) callback, block call back return list of emails
 * @return email header /MCOMessageHeader/ in callback block
 * version 1.0
 * date 3/Apr/2015
 */
- (void)getEmailsHeaderAtIndexForPop:(unsigned int)index callback:(EmailHeaderPopBlock)callback;

/**
 * Get email detail for POP account type.
 * @author Parker
 *
 * @param (unsigned int) index, index message
 * @param (EmailDetailPopBlock) callback, block call back return list of emails
 * @return email detail in callback block
 // messagesContent is the RFC 822 formatted message data.
 * version 1.0
 * date 3/Apr/2015
 */
- (void)getEmailsDetailAtIndexForPop:(unsigned int)index callback:(EmailDetailPopBlock)callback;


//Sort by functions
/**
 * Sort email dictionary by date.
 * @author Parker
 *
 * @param (NSDictionary *) emailDict, dictionary of emails
 * @param (BOOL) isAscending, is Ascending
 * @return NSDictionary has been sorted
 * version 1.0
 * date 3/Apr/2015
 */
- (NSDictionary *)sortedByDateDictionayFromDictionary:(NSDictionary *)emailDict isAscending:(BOOL)isAscending;

/**
 * Sort email dictionary by name.
 * @author Parker
 *
 * @param (NSDictionary *) emailDict, dictionary of emails
 * @param (BOOL) isAscending, is Ascending
 * @return NSDictionary has been sorted
 * version 1.0
 * date 3/Apr/2015
 */
- (NSDictionary *)sortedByNameDictionaryFromDictionary:(NSDictionary *)emailDict isAscending:(BOOL)isAscending;

/**
 * Sort in section by keys.
 * @author Parker
 *
 * @param (NSArray *) keys, keys in section
 * @param (EmailSortingType) sortingType, sorting type
 * @return NSArray has been sorted
 * version 1.0
 * date 3/Apr/2015
 */
- (NSArray *)sortedSectionKeysFromKeys:(NSArray *)keys sortingType:(EmailSortingType)sortingType;

/**
 * Get data string from time stap for sections.
 * @author Parker
 *
 * @param (NSTimeInterval) timestamp, time stamp
 * @return NSString date time string
 * version 1.0
 * date 3/Apr/2015
 */
- (NSString *)inboxSectionKeyFromTimestamp:(NSTimeInterval)timestamp;

/**
 * Get group type by sorting type.
 * @author Parker
 *
 * @param (EmailSortingType) sortingType, sorting type
 * @return (EmailGroupingType) return group type: Date, Sender, Subject
 * version 1.0
 * date 3/Apr/2015
 */
- (EmailGroupingType)groupingTypeBySortingType:(EmailSortingType)sortingType;

/**
 * Get name string for section in inbox.
 * @author Parker
 *
 * @param (NSString *) sectionKey, section
 * @return (NSUInteger) number
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


@end






