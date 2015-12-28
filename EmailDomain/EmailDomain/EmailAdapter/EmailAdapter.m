//
//  EmailAdapter.m
//  EmailDomain
//
//  Created by enclave on 12/24/14.
//  Copyright (c) 2014 enclave. All rights reserved.
//

#import "EmailAdapter.h"
#import "CocoaLumberjack.h"
#import "EmailDomainDefine.h"
#import "EmailServerAdapter.h"
#import "NSDate+Utilities.h"

#define kAPI @"API"
#define kAPI_VERSION @"API_VERSION"
#define API_UPDATE_EMAIL_ACCOUNT @"moajhkdfuf"
#define API_UPDATE_EMAIL_ACCOUNT_VERSION @"v1"
#define API_RESET_EMAIL_ACCOUNT @"pDCkIrBcRs"
#define API_RESET_EMAIL_ACCOUNT_VERSION @"v2"

NSString *const kInboxSectionKeyToday = @"Today";
NSString *const kInboxSectionKeyYesterday = @"Yesterday";
NSString *const kInboxSectionKey2DaysAgo = @"2DaysAgo";
NSString *const kInboxSectionKey3DaysAgo = @"3DaysAgo";
NSString *const kInboxSectionKey4DaysAgo = @"4DaysAgo";
NSString *const kInboxSectionKey5DaysAgo = @"5DaysAgo";
NSString *const kInboxSectionKey6DaysAgo = @"6DaysAgo";
NSString *const kInboxSectionKey1WeekAgo = @"1WeekAgo";
NSString *const kInboxSectionKey2WeeksAgo = @"2WeeksAgo";
NSString *const kInboxSectionKey3WeeksAgo = @"3WeeksAgo";
NSString *const kInboxSectionKey1MonthAgo = @"1MonthAgo";
NSString *const kInboxSectionKeyOlder = @"Older";

//Logging
#ifdef DEBUG
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelError;
#endif

@implementation EmailAdapter
{
    MCOIMAPSession *imapSession;
    MCOIMAPOperation *imapOperation;
    MCOIMAPFetchMessagesOperation *imapMessagesFetchOp;
    MCOIMAPFetchContentOperation *imapFetchContentOp;
    MCOPOPFetchMessagesOperation *popMessagesFetchOp;
    MCOPOPFetchMessageOperation *popMessageFetchOp;
    MCOPOPFetchHeaderOperation *popHeaderFetchOp;
    MCOSMTPSession *smtpSession;
    
    MCOPOPSession *popSession;
    MCOPOPOperation *popOperation;
}


+(EmailAdapter *)share{
    static dispatch_once_t once;
    static EmailAdapter * share;
    dispatch_once(&once, ^{
        
        share = [self new];
    });
    return share;
}

#pragma mark common methods

-(BOOL) checkValidEmailAddress:(NSString*)emailAddress{
    BOOL stricterFilter = YES;
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:emailAddress];
}

-(BOOL) setEmailAttachment:(NSString*)attachmentName data:(NSData*) attachmentData{
    
    if (!attachmentName || [attachmentName isEqualToString:@""]) {
        DDLogError(@"attachmentName can not be null");
        return FALSE;
    }
    if (!attachmentData || attachmentData.length == 0) {
        DDLogError(@"attachmentData can not be null");
        return FALSE;
    }
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* folderPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:kEMAIL_ATTACHMENTS_FOLDER];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:folderPath])
        [[NSFileManager defaultManager] createDirectoryAtPath:folderPath
                                  withIntermediateDirectories:NO
                                                   attributes:nil
                                                        error:nil];
    
    NSString* filePath = [folderPath stringByAppendingPathComponent:attachmentName];
    BOOL writeSuccess = [attachmentData writeToFile:filePath atomically:YES];
    if(!writeSuccess)
        DDLogError(@"Cannot write attachment data for attachment name %@ to EMAIL_ATTACHMENTS folder", attachmentName);
    else
        DDLogError(@"Successfully write attachment data for attachment name %@ to EMAIL_ATTACHMENTS folder", attachmentName);
    return writeSuccess;
}

-(NSData*) getEmailAttachment:(NSString*)attachmentName{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* folderPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:kEMAIL_ATTACHMENTS_FOLDER];
    if(!folderPath || [folderPath isEqualToString:@""]){
        DDLogError(@"Email Attachment folder link is not set");
        return NULL;
    }
    
    NSString* filePath = [folderPath stringByAppendingPathComponent:attachmentName];
    NSFileManager* fileManager = [NSFileManager defaultManager];
    BOOL success = [fileManager fileExistsAtPath:filePath];
    if(!success){
        DDLogError(@"Email Attachment (attachmentName: %@) file is not existed", attachmentName);
        return NULL;
    }
    NSData* returnData = [NSData dataWithContentsOfFile:filePath];
    return returnData;
}

-(unsigned long) getEmailAttachmentFileSize:(NSString*)attachmentName{
    
    unsigned long long fileSize = 0;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* folderPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:kEMAIL_ATTACHMENTS_FOLDER];
    if(!folderPath || [folderPath isEqualToString:@""]){
        DDLogError(@"Email Attachment folder link is not set");
        return 0;
    }
    
    NSString* filePath = [folderPath stringByAppendingPathComponent:attachmentName];
    NSFileManager* fileManager = [NSFileManager defaultManager];
    BOOL success = [fileManager fileExistsAtPath:filePath];
    if(!success){
        DDLogError(@"Email Attachment (attachmentName: %@) file is not existed", attachmentName);
        return 0;
    }
    
    if (success)
    {
        fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil] fileSize];
    }
    return fileSize;
}

-(BOOL) deleteAllAttachmentsInEmailAttachmentFolder{
    NSString *folderPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:kEMAIL_ATTACHMENTS_FOLDER];
    NSError *error = nil;
    BOOL success = false ;
    for (NSString *file in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:folderPath error:&error]) {
        success = [[NSFileManager defaultManager] removeItemAtPath:[folderPath stringByAppendingPathComponent:file] error:&error];
    }
    if (success) {
        DDLogInfo(@"Successfully delete all email attachments file");
    }else{
        DDLogError(@"Error delete all email attachments file");
    }
    return success;
}

#pragma mark API functions




-(void)updateEmailAccountToServer:(NSDictionary*)parametersDic callback:(requestCompleteBlock)callback{
    void (^updateEmailAccountCallBack)(BOOL success, NSString *message ,NSDictionary *response, NSError *error);
    
    updateEmailAccountCallBack =  callback;
    
    NSMutableDictionary *parameters = [parametersDic mutableCopy];
    
    [parameters setObject:API_UPDATE_EMAIL_ACCOUNT forKey:kAPI];
    [parameters setObject:API_UPDATE_EMAIL_ACCOUNT_VERSION forKey:kAPI_VERSION];
    
    [[EmailServerAdapter share] requestService:parameters tenantServer:YES callback:^(BOOL success, NSString *message, NSDictionary *response, NSError *error) {
        if (success) {
            DDLogInfo(@"%s: Update email account successfully.", __PRETTY_FUNCTION__);
            updateEmailAccountCallBack(YES, @"Update email account successfully.", response, nil);
        }else{
            DDLogError(@"%s: Update email account failed.", __PRETTY_FUNCTION__);
            updateEmailAccountCallBack(NO, @"Update email account failed.", response, error);
        }
    }];
    
}

-(void)resetEmailAccount:(NSDictionary*)parametersDic callback:(requestCompleteBlock)callback{
    void (^resetEmailAccountCallBack)(BOOL success, NSString *message ,NSDictionary *response, NSError *error);
    resetEmailAccountCallBack =  callback;
    
    NSMutableDictionary *parameters = [parametersDic mutableCopy];
    
    [parameters setObject:API_RESET_EMAIL_ACCOUNT forKey:kAPI];
    [parameters setObject:API_RESET_EMAIL_ACCOUNT_VERSION forKey:kAPI_VERSION];
    
    [[EmailServerAdapter share] requestService:parameters tenantServer:YES callback:^(BOOL success, NSString *message, NSDictionary *response, NSError *error) {
        if (success) {
            DDLogInfo(@"%s: Reset email account successfully.", __PRETTY_FUNCTION__);
            resetEmailAccountCallBack(YES, @"Reset email account successfully.", response, nil);
        }else{
            DDLogError(@"%s: Reset email account failed.", __PRETTY_FUNCTION__);
            resetEmailAccountCallBack(NO, @"Reset email account failed.", response, error);
        }
    }];
    
}

#pragma mark IMAP functions

//void (^EmailContentCallBack)(BOOL success, NSData *messagesContent, NSError *error);


//void (^EmailHeaderImapBlockCallBack)(BOOL success, MCOIMAPMessage *messageHeader, NSError *error);

- (void)configureImapAccount:(NSString*)username password:(NSString*)password hostname:(NSString*)hostname port:(int)port connectionType:(int)type{
    DDLogInfo(@"%s", __PRETTY_FUNCTION__);
    
    imapSession = [[MCOIMAPSession alloc] init];
    [imapSession setHostname:hostname];
    [imapSession setPort:port];
    [imapSession setUsername:username];
    [imapSession setPassword:password];
    
    MCOConnectionType connectType;
    
    if (type == 0){
        connectType = MCOConnectionTypeClear;
        [imapSession setConnectionType:connectType];
    }else if (type == 1){
        connectType =  MCOConnectionTypeStartTLS;
        [imapSession setConnectionType:connectType];
    }else if (type == 2){
        connectType = MCOConnectionTypeTLS;
        [imapSession setConnectionType:connectType];
    }
    
}

- (void)checkImapAccount:(EmailCheckImapAccountBlock)callback{
    
    void (^EmailCheckImapAccountCallBack)(BOOL success, NSString *message, NSError *error);
    EmailCheckImapAccountCallBack = callback;
    
    if (!imapSession) {
        DDLogError(@"Please configure IMAP account first");
        EmailCheckImapAccountCallBack(NO, @"Please configure IMAP account first.", nil);
        return;
    }
    __block BOOL isWrongPass = NO;
    __block BOOL isTurnOnSecurity = NO;
    [imapSession
     setConnectionLogger:^(void *connectionID, MCOConnectionLogType type, NSData *data) {
         NSString *returnString = [[NSString alloc] initWithData:data
                                                        encoding:NSUTF8StringEncoding];
         if ([returnString rangeOfString:mError_AuthenticationFailed].location != NSNotFound)
         {
             isWrongPass = YES;
         }
         else if (([returnString rangeOfString:mError_PleaseLoginViaYourWebBrowser].location != NSNotFound) ||
                  ([returnString rangeOfString:mError_LoginToUrAccViaWeb].location != NSNotFound))
         {
            isTurnOnSecurity = YES;
         }
     }];
    
    imapOperation = [imapSession checkAccountOperation];
    [imapOperation start:^(NSError *error) {
        if (!error)
        {
            DDLogInfo(@"Your email account is correct.");
            EmailCheckImapAccountCallBack(YES, @"Your email account is correct.", nil);
        }
        else
        {
            DDLogError(@"Your email account is incorrect. Error: %@", error);
            if (isWrongPass)
                EmailCheckImapAccountCallBack(NO, mError_AuthenticationFailed, nil);
            else if (isTurnOnSecurity)
                EmailCheckImapAccountCallBack(NO, mError_PleaseLoginViaYourWebBrowser, nil);
            else
                EmailCheckImapAccountCallBack(NO, @"Your email account is incorrect.", error);
        }
    }];
}

- (void)getEmailsHeaderForImap:(NSString*)folder numberMessages:(int)number callback:(EmailMessageBlock)callback{
    DDLogInfo(@"%s", __PRETTY_FUNCTION__);
    
    void (^EmailMessageHeaderCallBack)(BOOL success, NSArray *messages, NSError *error);
    
    EmailMessageHeaderCallBack = callback;
    
    if (!imapSession) {
        DDLogError(@"Please configure IMAP account first");
        EmailMessageHeaderCallBack(NO, nil, nil);
        return;
    }
    
    MCOIMAPFolderInfoOperation *folderInfo = [imapSession folderInfoOperation:folder];
    
    MCOIMAPMessagesRequestKind requestKind = (MCOIMAPMessagesRequestKind)
    (MCOIMAPMessagesRequestKindHeaders | MCOIMAPMessagesRequestKindStructure |
     MCOIMAPMessagesRequestKindInternalDate | MCOIMAPMessagesRequestKindHeaderSubject |
     MCOIMAPMessagesRequestKindFlags);
    
    [folderInfo start:^(NSError *error, MCOIMAPFolderInfo *info) {
        
        if (error != nil) {
            EmailMessageHeaderCallBack(NO, nil, error);
        }else{
            DDLogInfo(@"Get folder info (%@) for email done", folder);
            
            DDLogInfo(@"Email Total Messages in folder %@: %i", folder, [info messageCount]);
            
            MCORange fetchRange = MCORangeEmpty;
            int numberOfMessages = number;
            numberOfMessages -= 1;
            if (numberOfMessages >0)
                fetchRange = MCORangeMake([info messageCount] - numberOfMessages, numberOfMessages);
            
            MCOIndexSet *numbers = [MCOIndexSet indexSetWithRange:fetchRange];
            // Get header of Emails
            imapMessagesFetchOp = [imapSession
                                   fetchMessagesByNumberOperationWithFolder:folder
                                   requestKind:requestKind
                                   numbers:numbers];
            
            __block NSArray *messagesHeader;
            
            [imapMessagesFetchOp start:^(NSError *error, NSArray *messages, MCOIndexSet *vanishedMessages) {
                if (error == nil)
                {
                    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"header.date" ascending:NO];
                    messagesHeader = [messages sortedArrayUsingDescriptors:@[sort]];
                    
                    DDLogInfo(@"Successfully get headers email in folder %@", folder);
                    EmailMessageHeaderCallBack(YES, messagesHeader, nil);
                    
                }else{
                    DDLogError(@"Error downloading header of emails in folder (%@):%@",folder, error);
                    EmailMessageHeaderCallBack(NO, nil,error);
                }
            }];
            
            
        }
        
    }];
    
}

- (void)getEmailsHeaderForImapInFolder:(NSString*)folder numberMessages:(int)number callback:(EmailMessageBlock)callback{
    DDLogInfo(@"%s", __PRETTY_FUNCTION__);
    
    void (^EmailMessageHeaderCallBack)(BOOL success, NSArray *messages, NSError *error);
    
    EmailMessageHeaderCallBack = callback;
    
    if (!imapSession) {
        DDLogError(@"Please configure IMAP account first");
        EmailMessageHeaderCallBack(NO, nil, nil);
        return;
    }
    
    MCOIMAPMessagesRequestKind requestKind = (MCOIMAPMessagesRequestKind)
    (MCOIMAPMessagesRequestKindHeaders | MCOIMAPMessagesRequestKindStructure |
     MCOIMAPMessagesRequestKindInternalDate | MCOIMAPMessagesRequestKindHeaderSubject |
     MCOIMAPMessagesRequestKindFlags);
    
    imapMessagesFetchOp = [imapSession fetchMessagesOperationWithFolder:folder
                                                            requestKind:requestKind
                                                                   uids:[MCOIndexSet indexSetWithRange:MCORangeMake(1, UINT64_MAX)]];
    [imapMessagesFetchOp start:^(NSError * error, NSArray * messages, MCOIndexSet * vanishedMessages) {
        if (error == nil) {
            MCOIMAPMessage *messageItem;
            
            NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"header.date" ascending:NO];
            NSArray *messagesHeaders = [messages sortedArrayUsingDescriptors:@[sort]];
            
            int index = 0;
            NSMutableArray *emails = [[NSMutableArray alloc] init];
            
            for (int i = 0; i < messagesHeaders.count; i++)
            {
                messageItem = messagesHeaders[i];
                if (index == number) {
                    break;
                }
                
                index += 1;
                [emails addObject:messageItem];
            }
            NSArray *result = [emails copy];
            
            DDLogInfo(@"Successfully get headers email in folder %@", folder);
            EmailMessageHeaderCallBack(YES, result, nil);
            
        }else{
            DDLogError(@"Error downloading header of emails in folder (%@):%@",folder, error);
            EmailMessageHeaderCallBack(NO, nil,error);
        }
        
    }];
    
    
}


-(void)updateFlagMessageWithFolderForImap:(NSString*)folder uid:(NSInteger)uid flag:(int)flag callback:(EmailUpdateFlag)callback{
    DDLogInfo(@"%s", __PRETTY_FUNCTION__);
    
    void (^EmailUpdateFlagCallBack)(BOOL success, NSString *message, NSError *error);
    
    EmailUpdateFlagCallBack = callback;
    
    if (!imapSession) {
        DDLogError(@"Please configure IMAP account first");
        EmailUpdateFlagCallBack(NO, @"Please configure IMAP account first", nil);
        return;
    }
    
    MCOIMAPOperation *op = [imapSession storeFlagsOperationWithFolder:folder
                                                                 uids:[MCOIndexSet indexSetWithIndex:uid]
                                                                 kind:MCOIMAPStoreFlagsRequestKindSet
                                                                flags:flag];
    [op start:^(NSError *error)
     {
         if (!error)
         {
             DDLogInfo(@"Updated flags!");
             EmailUpdateFlagCallBack(YES, @"Update success", nil);
         }
         else
         {
             DDLogError(@"Error updating flags:%@", error);
             EmailUpdateFlagCallBack(NO, @"Update failed", error);
         }
     }];
    
    
}

/*
 - (void)getEmailsDetailForImap:(NSString*)folder uid:(int)uid callback:(EmailContentBlock)callback{
 
 void (^EmailMessageDetailCallBack)(BOOL success, NSData *messagesContent, NSError *error);
 
 DDLogInfo(@"%s", __PRETTY_FUNCTION__);
 
 EmailMessageDetailCallBack = callback;
 
 if (!imapSession) {
 DDLogError(@"Please configure IMAP account first");
 return;
 }
 
 MCOIMAPFolderInfoOperation *folderInfo = [imapSession folderInfoOperation:folder];
 
 [folderInfo start:^(NSError *error, MCOIMAPFolderInfo *info) {
 
 if (error != nil) {
 DDLogError(@"Error get email content:\n %@",error);
 EmailMessageDetailCallBack(NO, nil, error);
 }else{
 DDLogInfo(@"Get folder info for email done");
 
 // Get content of Emails
 MCOIMAPFetchContentOperation *fetchContentOp = [imapSession fetchMessageOperationWithFolder:folder uid:uid];
 __block NSData *messagesContent;
 
 [fetchContentOp start:^(NSError *error, NSData *data) {
 if (error == nil) {
 DDLogInfo(@"Successfully download content of Emails");
 messagesContent = data;
 
 EmailMessageDetailCallBack(YES, messagesContent, nil);
 }else{
 DDLogError(@"Error downloading content of Emails:\n %@", error);
 EmailMessageDetailCallBack(NO, messagesContent, nil);
 }
 }];
 
 }
 
 }];
 
 }
 */
- (void)getEmailsDetailForImap:(NSString*)folder uid:(int)uid callback:(EmailContentBlock)callback{
    
    void (^EmailMessageDetailCallBack)(BOOL success, NSData *messagesContent, NSError *error);
    
    DDLogInfo(@"%s", __PRETTY_FUNCTION__);
    
    EmailMessageDetailCallBack = callback;
    
    if (!imapSession) {
        DDLogError(@"Please configure IMAP account first");
        return;
    }
    // Get content of Emails
    imapFetchContentOp = [imapSession fetchMessageOperationWithFolder:folder uid:uid];
    
    [imapFetchContentOp start:^(NSError *error, NSData *data) {
        if (error == nil) {
            DDLogInfo(@"Successfully download content of Emails with uid: %d", uid);
            EmailMessageDetailCallBack(YES, data, nil);
        }else{
            DDLogError(@"Error downloading content of Emails with uid %d:\n %@",uid, error);
            EmailMessageDetailCallBack(NO, data, nil);
        }
    }];
    
    
}

- (void)getNewEmailsHeaderForImap:(NSString*)folder fromUID:(int)fromUID callback:(EmailMessageBlock)callback{
    DDLogInfo(@"%s", __PRETTY_FUNCTION__);
    void (^EmailNewMessageCallBack)(BOOL success, NSArray *messages, NSError *error);
    
    EmailNewMessageCallBack = callback;
    
    if (!imapSession) {
        DDLogError(@"Please configure IMAP account first");
        EmailNewMessageCallBack(NO, nil, nil);
        return;
    }
    
    //Check Logger connection
    [imapSession setConnectionLogger:^(void *connectionID, MCOConnectionLogType type, NSData *data) {
        NSString *returnString = [[NSString alloc] initWithData:data
                                                       encoding:NSUTF8StringEncoding];
        if ([returnString rangeOfString:mError_AuthenticationFailed options:NSCaseInsensitiveSearch].location != NSNotFound && returnString.length > 0)
        {
            EmailNewMessageCallBack(NO, [NSArray arrayWithObjects:mError_AuthenticationFailed, nil] , nil);
        }
        else if ([returnString rangeOfString:mError_PleaseLoginViaYourWebBrowser options:NSCaseInsensitiveSearch].location != NSNotFound && returnString.length > 0) {
            EmailNewMessageCallBack(NO, [NSArray arrayWithObjects:mError_PleaseLoginViaYourWebBrowser, nil] , nil);
        }
        
    }];
    //Get new email
    
    MCOIMAPFolderInfoOperation *folderInfo = [imapSession folderInfoOperation:folder];
    
    MCOIMAPMessagesRequestKind requestKind = (MCOIMAPMessagesRequestKind)
    (MCOIMAPMessagesRequestKindHeaders | MCOIMAPMessagesRequestKindStructure |
     MCOIMAPMessagesRequestKindInternalDate | MCOIMAPMessagesRequestKindHeaderSubject |
     MCOIMAPMessagesRequestKindFlags);
    
    [folderInfo start:^(NSError *error, MCOIMAPFolderInfo *info) {
        
        if (error != nil) {
            DDLogError(@"Error get folder info for email");
            EmailNewMessageCallBack(NO, nil, error);
        }else {
            DDLogInfo(@"Get folder info for email done");
            MCORange fetchRange = MCORangeEmpty;
            
            int numberOfMessages = info.uidNext - fromUID;
            if (numberOfMessages > 0)
                fetchRange = MCORangeMake([info messageCount] - numberOfMessages + 1, numberOfMessages - 1);
            
            MCOIndexSet *numbers = [MCOIndexSet indexSetWithRange:fetchRange];
            // Get header of Emails
            imapMessagesFetchOp = [imapSession
                                   fetchMessagesByNumberOperationWithFolder:folder
                                   requestKind:requestKind
                                   numbers:numbers];
            
            [imapMessagesFetchOp start:^(NSError *error, NSArray *messages, MCOIndexSet *vanishedMessages) {
                if (error == nil)
                {
                    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"header.date" ascending:NO];
                    NSArray *messagesHeaders = [messages sortedArrayUsingDescriptors:@[sort]];
                    
                    NSMutableArray *newEmails = [[NSMutableArray alloc] init];
                    MCOIMAPMessage *messageItem;
                    for (int i = 0; i < messagesHeaders.count; i++)
                    {
                        messageItem = messagesHeaders[i];
                        
                        if (messageItem.uid > fromUID){
                            [newEmails addObject:messageItem];
                        }
                    }
                    NSArray *result = [newEmails copy];
                    
                    DDLogInfo(@"Successfully get new emails");
                    EmailNewMessageCallBack(YES, result, nil);
                    
                }else {
                    DDLogError(@"Error downloading header of new emails:%@", error);
                    EmailNewMessageCallBack(NO, nil,error);
                }
            }];
            
        }
        
    }];
    
}

- (void)getNewEmailsHeaderForImapInFolder:(NSString*)folder fromUID:(int)fromUID callback:(EmailMessageBlock)callback{
    DDLogInfo(@"%s", __PRETTY_FUNCTION__);
    
    void (^EmailNewMessageCallBack)(BOOL success, NSArray *messages, NSError *error);
    
    EmailNewMessageCallBack = callback;
    
    if (!imapSession) {
        DDLogError(@"Please configure IMAP account first");
        EmailNewMessageCallBack(NO, nil, nil);
        return;
    }
    DDLogInfo(@"Get new email from UID: %d", fromUID);
    
    MCOIMAPMessagesRequestKind requestKind = (MCOIMAPMessagesRequestKind)
    (MCOIMAPMessagesRequestKindHeaders | MCOIMAPMessagesRequestKindStructure |
     MCOIMAPMessagesRequestKindInternalDate | MCOIMAPMessagesRequestKindHeaderSubject |
     MCOIMAPMessagesRequestKindFlags);
    
    imapMessagesFetchOp = [imapSession fetchMessagesOperationWithFolder:folder
                                                            requestKind:requestKind
                                                                   uids:[MCOIndexSet indexSetWithRange:MCORangeMake(1, UINT64_MAX)]];
    [imapMessagesFetchOp start:^(NSError * error, NSArray * messages, MCOIndexSet * vanishedMessages) {
        if (error == nil) {
            
            NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"header.date" ascending:NO];
            NSArray *messagesHeaders = [messages sortedArrayUsingDescriptors:@[sort]];
            
            NSMutableArray *newEmails = [[NSMutableArray alloc] init];
            MCOIMAPMessage *messageItem;
            for (int i = 0; i < messagesHeaders.count; i++)
            {
                messageItem = messagesHeaders[i];
                
                if (messageItem.uid > fromUID){
                    [newEmails addObject:messageItem];
                }
            }
            NSArray *result = [newEmails copy];
            
            DDLogInfo(@"Successfully get new emails");
            EmailNewMessageCallBack(YES, result, nil);
            
        }else{
            DDLogError(@"Error downloading header of new emails:%@", error);
            EmailNewMessageCallBack(NO, nil,error);
        }
        
    }];
}



- (void)getOldEmailsHeaderForImap:(NSString*)folder fromUID:(int)fromUID numberMessages:(int)number callback:(EmailMessageBlock)callback{
    DDLogInfo(@"%s", __PRETTY_FUNCTION__);
    
    void (^EmailOldMessageCallBack)(BOOL success, NSArray *messages, NSError *error);
    
    EmailOldMessageCallBack = callback;
    
    if (!imapSession) {
        DDLogError(@"Please configure IMAP account first");
        EmailOldMessageCallBack(NO, nil, nil);
        return;
    }
    // Check Connection Logger
    [imapSession setConnectionLogger:^(void *connectionID, MCOConnectionLogType type, NSData *data) {
        NSString *returnString = [[NSString alloc] initWithData:data
                                                       encoding:NSUTF8StringEncoding];
        if ([returnString rangeOfString:mError_AuthenticationFailed options:NSCaseInsensitiveSearch].location != NSNotFound && returnString.length > 0)
        {
            EmailOldMessageCallBack(NO, [NSArray arrayWithObjects:mError_AuthenticationFailed, nil], nil);
        }else if ([returnString rangeOfString:mError_PleaseLoginViaYourWebBrowser options:NSCaseInsensitiveSearch].location != NSNotFound && returnString.length > 0) {
            EmailOldMessageCallBack(NO, [NSArray arrayWithObjects:mError_PleaseLoginViaYourWebBrowser, nil], nil);
        }
        
    }];
    //Get old emails
    MCOIMAPFolderInfoOperation *folderInfo = [imapSession folderInfoOperation:folder];
    MCOIMAPMessagesRequestKind requestKind = (MCOIMAPMessagesRequestKind)
    (MCOIMAPMessagesRequestKindHeaders | MCOIMAPMessagesRequestKindStructure |
     MCOIMAPMessagesRequestKindInternalDate | MCOIMAPMessagesRequestKindHeaderSubject |
     MCOIMAPMessagesRequestKindFlags);
    
    [folderInfo start:^(NSError *error, MCOIMAPFolderInfo *info) {
        
        if (error != nil) {
            DDLogError(@"Error get folder info for email");
            EmailOldMessageCallBack(NO, nil, error);
        }else {
            DDLogInfo(@"Successfully get folder info for email");
            int numberOfMessages;
            if ([info messageCount] > NumberOfLimitedEmailsToGet)
                numberOfMessages = NumberOfLimitedEmailsToGet;
            else
                numberOfMessages = [info messageCount] - 1;
            MCOIndexSet *numbers = [MCOIndexSet indexSetWithRange:MCORangeMake([info messageCount] - numberOfMessages, numberOfMessages)];
            MCOIMAPFetchMessagesOperation *fetchOperation  = [imapSession fetchMessagesByNumberOperationWithFolder:folder
                                                                             requestKind:requestKind
                                                                                 numbers:numbers];
            
            [fetchOperation start:^(NSError *error, NSArray *messages, MCOIndexSet *vanishedMessages) {
                if (error ==  nil) {
                    DDLogInfo(@"number of message: %ld", (long)messages.count);
                    MCOIMAPMessage *messageItem;
                    NSMutableArray *arrMessagesGet = [NSMutableArray new];
                    
                    for (NSInteger i = messages.count - 1; i >= 0; i--)
                    {
                        messageItem = messages[i];
                        if (messageItem.uid < fromUID)
                            [arrMessagesGet addObject:messageItem];
                        
                        if (arrMessagesGet.count == number)
                            break;
                    }
                    
                    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"header.date" ascending:NO];
                    NSArray *messagesHeader = [arrMessagesGet sortedArrayUsingDescriptors:@[sort]];
                    
                    DDLogInfo(@"Successfully get more header for emails");
                    EmailOldMessageCallBack(YES, messagesHeader, nil); 
                }
            }];
        }
    }];
}

- (void)getOldEmailsHeaderForImapInFolder:(NSString*)folder fromUID:(int)fromUID numberMessages:(int)number callback:(EmailMessageBlock)callback{
    DDLogInfo(@"%s", __PRETTY_FUNCTION__);
    
    void (^EmailOldMessageCallBack)(BOOL success, NSArray *messages, NSError *error);
    
    EmailOldMessageCallBack = callback;
    
    if (!imapSession) {
        DDLogError(@"Please configure IMAP account first");
        EmailOldMessageCallBack(NO, nil, nil);
        return;
    }
    
    DDLogInfo(@"Get old email from UID: %d", fromUID);
    
    MCOIMAPMessagesRequestKind requestKind = (MCOIMAPMessagesRequestKind)
    (MCOIMAPMessagesRequestKindHeaders | MCOIMAPMessagesRequestKindStructure |
     MCOIMAPMessagesRequestKindInternalDate | MCOIMAPMessagesRequestKindHeaderSubject |
     MCOIMAPMessagesRequestKindFlags);
    
    imapMessagesFetchOp = [imapSession fetchMessagesOperationWithFolder:folder
                                                            requestKind:requestKind
                                                                   uids:[MCOIndexSet indexSetWithRange:MCORangeMake(1, UINT64_MAX)]];
    [imapMessagesFetchOp start:^(NSError * error, NSArray * messages, MCOIndexSet * vanishedMessages) {
        if (error == nil) {
            DDLogInfo(@"Successfully get more header for emails");
            MCOIMAPMessage *messageItem;
            
            NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"header.date" ascending:NO];
            NSArray *messagesHeaders = [messages sortedArrayUsingDescriptors:@[sort]];
            
            int index = 0;
            NSMutableArray *oldEmails = [[NSMutableArray alloc] init];
            
            for (int i = 0; i < messagesHeaders.count; i++)
            {
                messageItem = messagesHeaders[i];
                DDLogInfo(@"Index emails: %d", index);
                DDLogInfo(@"Number load emails: %d", number);
                if (index == number) {
                    break;
                }
                
                if (messageItem.uid < fromUID){
                    index += 1;
                    [oldEmails addObject:messageItem];
                }
            }
            NSArray *result = [oldEmails copy];
            
            DDLogInfo(@"Successfully get more header for emails");
            EmailOldMessageCallBack(YES, result, error);
            
        }else{
            DDLogError(@"Error get more header of emails:%@", error);
            EmailOldMessageCallBack(NO, nil, error);
        }
        
    }];
    
    
}

- (void)getMessageHeaderWithUID:(int)emailUID inFolder:(NSString *)folder callback:(EmailHeaderImapBlock)callback
{
    DDLogInfo(@"%s", __PRETTY_FUNCTION__);
    void (^ EmailHeaderImapBlockCallBack)(BOOL success, MCOIMAPMessage *messageHeader, NSError *error);
    EmailHeaderImapBlockCallBack = callback;
    
    if (!imapSession)
    {
        DDLogError(@"Please configure IMAP account first");
        EmailHeaderImapBlockCallBack(NO, nil, nil);
        return;
    }
    
    DDLogInfo(@"Get get email header from UID: %d", emailUID);
    MCOIMAPMessagesRequestKind requestKind = (MCOIMAPMessagesRequestKind)(MCOIMAPMessagesRequestKindHeaders |
                                                                          MCOIMAPMessagesRequestKindStructure |
                                                                          MCOIMAPMessagesRequestKindInternalDate |
                                                                          MCOIMAPMessagesRequestKindHeaderSubject |
                                                                          MCOIMAPMessagesRequestKindFlags);
    MCOIndexSet *uids = [MCOIndexSet indexSetWithIndex:emailUID];
    imapMessagesFetchOp = [imapSession fetchMessagesOperationWithFolder:folder
                                                            requestKind:requestKind
                                                                   uids:uids];
    [imapMessagesFetchOp start:^(NSError *error, NSArray *messages, MCOIndexSet *vanishedMessages) {
        if (error)
        {
            DDLogError(@"Error downloading message headers:%@", error);
            EmailHeaderImapBlockCallBack(NO, nil, error);
            return;
        }
        
        MCOIMAPMessage *myMessage = [messages lastObject];
        DDLogInfo(@"Successfully get email header");
        EmailHeaderImapBlockCallBack(YES, myMessage, nil);
    }];
}

/*
 - (void)downloadAttachmentsEmailForImap:(NSString*)folder uid:(int)uid callback:(EmailAttachmentBlock)callback{
 DDLogInfo(@"%s", __PRETTY_FUNCTION__);
 
 EmailAttachmentCallBack = callback;
 
 if (!imapSession) {
 DDLogError(@"Please configure IMAP account first");
 return;
 }
 
 MCOIMAPMessagesRequestKind requestKind = (MCOIMAPMessagesRequestKind)
 (MCOIMAPMessagesRequestKindHeaders | MCOIMAPMessagesRequestKindStructure |
 MCOIMAPMessagesRequestKindInternalDate | MCOIMAPMessagesRequestKindHeaderSubject |
 MCOIMAPMessagesRequestKindFlags);
 
 MCOIndexSet *uids = [MCOIndexSet indexSetWithIndex:uid];
 MCOIMAPFetchMessagesOperation *fetchOperation = [imapSession fetchMessagesOperationWithFolder:folder requestKind:requestKind uids:uids];
 
 [fetchOperation start:^(NSError *error, NSArray *fetchedMessages, MCOIndexSet *vanishedMessages) {
 //Let's check if there was an error:
 if (error)
 {
 DDLogError(@"Error downloading message headers:%@", error);
 EmailAttachmentCallBack(NO, nil, error);
 return ;
 }
 NSArray *attachments;
 
 
 
 MCOIMAPMessage *myMessage = [fetchedMessages lastObject];
 if ([myMessage.attachments count] > 0)
 {
 //NSOperationQueue *operationQueue2 = [[NSOperationQueue alloc] init];
 
 //[operationQueue2 addOperationWithBlock:^{
 //Back ground task here
 for (int k = 0; k < [myMessage.attachments count]; k++)
 {
 
 dispatch_group_t group = dispatch_group_create();
 dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
 dispatch_group_async(
 group,
 queue,
 ^{
 dispatch_semaphore_t sem = dispatch_semaphore_create( 0 );
 
 DDLogInfo(@"Block START");
 
 MCOIMAPPart *part = [myMessage.attachments objectAtIndex:k];
 part.filename = [NSString stringWithFormat:@"(%d)%@",k, part.filename];
 
 MCOIMAPFetchContentOperation *mcop = [imapSession fetchMessageAttachmentOperationWithFolder:folder
 uid:uid
 partID:part.partID
 encoding:part.encoding];
 [mcop start:^(NSError *error, NSData *data) {
 if (error != nil)
 {
 DDLogError(@"Error download attachment for email:%@", error);
 DDLogInfo(@"Block END");
 dispatch_semaphore_signal(sem);
 
 }else{
 [attachments arrayByAddingObject:data];
 DDLogInfo(@"Block SUCCESS");
 dispatch_semaphore_signal(sem);
 }
 
 }];
 
 dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
 
 DDLogInfo(@"Block END");
 });
 
 dispatch_group_notify(
 group,
 queue,
 ^{
 DDLogInfo(@"FINAL block");
 
 });
 
 
 
 
 }
 
 // }];
 
 }
 
 EmailAttachmentCallBack(YES, attachments, error);
 
 
 
 }];
 
 
 }
 */
- (void) downloadAttachmentsForImapWithFolder:(NSString*)folderName uid:(int)uid partId:(NSString*)partId encoding:(MCOEncoding)encoding callback:(EmailAttachmentDataBlock)callback{
    
    if (!imapSession) {
        DDLogError(@"Please configure IMAP account first");
        return;
    }
    
    void (^EmailImapAttachmentCallBack)(BOOL success, NSData *attachmentData, NSError *error);
    
    EmailImapAttachmentCallBack = callback;
    
    imapFetchContentOp = [imapSession fetchMessageAttachmentOperationWithFolder:folderName
                                                                            uid:uid
                                                                         partID:partId
                                                                       encoding:encoding];
    [imapFetchContentOp start:^(NSError *error, NSData *data) {
        if (error != nil)
        {
            DDLogError(@"Error download email attachment for uid %d partId %@: %@",uid, partId, error);
            EmailImapAttachmentCallBack(NO, data, error);
        }else{
            EmailImapAttachmentCallBack(YES, data, nil);
        }
        
    }];
    
    
    
}

#pragma mark SMTP functions

- (void)configureSmtp:(NSString*)username password:(NSString*)password hostname:(NSString*)hostname port:(int)port connectionType:(int)type{
    
    DDLogInfo(@"%s", __PRETTY_FUNCTION__);
    
    smtpSession = [[MCOSMTPSession alloc] init];
    [smtpSession setHostname:hostname];
    [smtpSession setPort:port];
    [smtpSession setUsername:username];
    [smtpSession setPassword:password];
    
    MCOConnectionType connectType;
    
    if (type == 0){
        connectType = MCOConnectionTypeClear;
        [smtpSession setConnectionType:connectType];
    }else if (type == 1){
        connectType =  MCOConnectionTypeStartTLS;
        [smtpSession setConnectionType:connectType];
    }else if (type == 2){
        connectType = MCOConnectionTypeTLS;
        [smtpSession setConnectionType:connectType];
    }
    
}

- (void)sendEmailWithUID:(NSString*)emailUID
             displayName:(NSString*)displayName
                      to:(NSArray*)emailTo
                      cc:(NSArray*)emailCc
                     bcc:(NSArray*)emailBcc
                 subject:(NSString*)emailSubject
                    body:(NSString*)emailBody
              attachment:(NSArray*)attachments
                callback:(EmailSendingBlock)callback{
    
    DDLogInfo(@"%s", __PRETTY_FUNCTION__);
    void (^EmailSendingCallBack)(BOOL success, NSString *statusMessage, NSError *error, NSString *emailUID);
    EmailSendingCallBack = callback;
    
    if (!smtpSession) {
        DDLogError(@"Please configure SMTP first");
        return;
    }
    
    DDLogInfo(@"Email From: %@", smtpSession.username);
    DDLogInfo(@"Email DisplayName: %@", displayName);
    
    MCOMessageBuilder *builder = [[MCOMessageBuilder alloc] init];
    [[builder header] setFrom:[MCOAddress addressWithDisplayName:displayName
                                                         mailbox:smtpSession.username]];
    
    //To
    NSMutableArray *to = [[NSMutableArray alloc] init];
    
    for (NSInteger i = 0; i < emailTo.count; i++)
    {
        if (![emailTo[i] isEqualToString:@""])
        {
            MCOAddress *newAddress = [MCOAddress addressWithMailbox:emailTo[i]];
            [to addObject:newAddress];
        }
    }
    
    [[builder header] setTo:to];
    
    DDLogInfo(@"Email To: %@", to);
    
    ///CC
    NSMutableArray *cc = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < emailCc.count; i++)
    {
        if (![emailCc[i] isEqualToString:@""])
        {
            MCOAddress *newAddress = [MCOAddress addressWithMailbox:emailCc[i]];
            [cc addObject:newAddress];
        }
    }
    [[builder header] setCc:cc];
    DDLogInfo(@"Email CC: %@", cc);
    
    ///BCC
    NSMutableArray *Bcc = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < emailBcc.count; i++)
    {
        if (![emailBcc[i] isEqualToString:@""])
        {
            MCOAddress *newAddress = [MCOAddress addressWithMailbox:emailBcc[i]];
            [Bcc addObject:newAddress];
        }
    }
    
    [[builder header] setBcc:Bcc];
    DDLogInfo(@"Email BCC: %@", Bcc);
    
    // Set Subject
    [[builder header] setSubject:emailSubject];
    
    //check attachment size
    unsigned long long fileSize = 0;
    
    if (attachments.count >0)
        for (NSInteger i = 0; i < attachments.count; i++)
        {
            fileSize += [self getEmailAttachmentFileSize:[attachments[i] objectForKey:kEMAIL_ATTACHMENT_NAME]];
        }
    DDLogInfo(@"FileSize attachment: %llu", fileSize);
    if (fileSize > 10485760)
    {
        DDLogError(@"The files that you are trying to send exceeds the 10 MB attachment limit.");
        EmailSendingCallBack(NO, @"The files that you are trying to send exceeds the 10 MB attachment limit.", nil, emailUID);
        return;
    }
    
    //Set body
    [builder setHTMLBody:emailBody];
    
    if (attachments.count >0)
        for (int i = 0; i < attachments.count; i++)
        {
            [builder addAttachment:[MCOAttachment attachmentWithData:[attachments[i] objectForKey:kEMAIL_ATTACHMENT_DATA]
                                                            filename:[attachments[i] objectForKey:kEMAIL_ATTACHMENT_NAME]]];
        }
    
    NSData *rfc822Data = [builder data];
    MCOSMTPSendOperation *sendOperation = [smtpSession sendOperationWithData:rfc822Data];
    
    [sendOperation start:^(NSError *error) {
        if (error)
        {
            EmailSendingCallBack(NO, @"Send email failed.", error, emailUID);
        }else{
            EmailSendingCallBack(YES, @"Send email successfully.", nil, emailUID);
        }
    }];
}

#pragma mark POP functions


- (void)configurePopAccount:(NSString*)username password:(NSString*)password hostname:(NSString*)hostname port:(int)port connectionType:(int)type{
    
    DDLogInfo(@"%s", __PRETTY_FUNCTION__);
    
    popSession = [[MCOPOPSession alloc] init];
    [popSession setHostname:hostname];
    [popSession setPort:port];
    [popSession setUsername:username];
    [popSession setPassword:password];
    
    MCOConnectionType connectType;
    
    if (type == 0){
        connectType = MCOConnectionTypeClear;
        [popSession setConnectionType:connectType];
    }else if (type == 1){
        connectType =  MCOConnectionTypeStartTLS;
        [popSession setConnectionType:connectType];
    }else if (type == 2){
        [popSession setConnectionType:connectType];
        connectType = MCOConnectionTypeTLS;
    }
    
}

- (void)checkPopAccount:(EmailCheckPopAccountBlock)callback{
    
    void (^EmailCheckPopAccountCallBack)(BOOL success, NSString *message, NSError *error);
    DDLogInfo(@"%s", __PRETTY_FUNCTION__);
    
    EmailCheckPopAccountCallBack = callback;
    
    if (!popSession) {
        DDLogError(@"Please configure POP account first");
        return;
    }
    
    popOperation = [popSession checkAccountOperation];
    [popOperation start:^(NSError *error) {
        if (!error) {
            DDLogInfo(@"Your email account is correct.");
            EmailCheckPopAccountCallBack(YES, @"Your email account is correct.", nil);
        }else{
            DDLogError(@"Your email account is correct. Error: %@", error);
            EmailCheckPopAccountCallBack(NO, @"Your email account is incorrect.", error);
        }
    }];
    
    
    
}

- (void)getAllEmailsForPop:(EmailMessageBlock)callback{
    
    DDLogInfo(@"%s", __PRETTY_FUNCTION__);
    
    void (^EmailMessageHeaderCallBack)(BOOL success, NSArray *messages, NSError *error);
    
    EmailMessageHeaderCallBack = callback;
    
    if (!popSession) {
        DDLogError(@"Please configure POP account first");
        return;
    }
    
    popMessagesFetchOp = [popSession fetchMessagesOperation];
    [popMessagesFetchOp start:^(NSError *error, NSArray *arrayMess) {
        if (error == nil)
        {
            DDLogInfo(@"Successfully get all emails");
            EmailMessageHeaderCallBack(YES, arrayMess, nil);
            
        }else{
            DDLogError(@"Error get all emails:%@", error);
            EmailMessageHeaderCallBack(NO, nil,error);
            
        }
    }];
    
}

- (void)getEmailsHeaderAtIndexForPop:(unsigned int)index callback:(EmailHeaderPopBlock)callback{
    
    void (^EmailHeaderPopCallBack)(BOOL success, MCOMessageHeader *messagesHeader, NSError *error);
    
    //DDLogInfo(@"%s", __PRETTY_FUNCTION__);
    
    EmailHeaderPopCallBack = callback;
    
    if (!popSession) {
        DDLogError(@"Please configure POP account first");
        return;
    }
    
    popHeaderFetchOp = [popSession fetchHeaderOperationWithIndex:index];
    [popHeaderFetchOp start:^(NSError * error, MCOMessageHeader * header) {
        if (error == nil)
        {
            DDLogInfo(@"Successfully get headers email at index %u", index);
            EmailHeaderPopCallBack(YES, header, nil);
            
        }else{
            DDLogError(@"Error downloading header of emails at index %u :%@",index, error);
            EmailHeaderPopCallBack(NO, nil, error);
            
        }
    }];
    
}

- (void)getEmailsDetailAtIndexForPop:(unsigned int)index callback:(EmailDetailPopBlock)callback{
    
    void (^EmailDetailPopCallBack)(BOOL success, NSData *messagesDetail, NSError *error);
    
    //DDLogInfo(@"%s", __PRETTY_FUNCTION__);
    
    EmailDetailPopCallBack = callback;
    
    if (!popSession) {
        DDLogError(@"Please configure POP account first");
        return;
    }
    
    popMessageFetchOp = [popSession fetchMessageOperationWithIndex:index];
    [popMessageFetchOp start:^(NSError * error, NSData * message) {
        if (error == nil)
        {
            DDLogInfo(@"Successfully get email detail at index %u", index);
            EmailDetailPopCallBack(YES, message, nil);
            
        }else{
            DDLogError(@"Error get email detail at index %u :%@",index, error);
            EmailDetailPopCallBack(NO, nil, error);
        }
    }];
    
}

#pragma mark - Private Sorting Methods
- (NSDictionary *)sortedByDateDictionayFromDictionary:(NSDictionary *)emailDict isAscending:(BOOL)isAscending;
{
    NSDictionary *rankDict = @{
                               kInboxSectionKeyToday : @0,
                               kInboxSectionKeyYesterday : @1,
                               kInboxSectionKey2DaysAgo : @2,
                               kInboxSectionKey3DaysAgo : @3,
                               kInboxSectionKey4DaysAgo : @4,
                               kInboxSectionKey5DaysAgo : @5,
                               kInboxSectionKey6DaysAgo : @6,
                               kInboxSectionKey1WeekAgo : @7,
                               kInboxSectionKey2WeeksAgo : @8,
                               kInboxSectionKey3WeeksAgo : @9,
                               kInboxSectionKey1MonthAgo : @10,
                               kInboxSectionKeyOlder : @11
                               };
    
    NSMutableArray *keys = [NSMutableArray arrayWithArray:[emailDict allKeys]];
    DDLogInfo(@"Keys before sorting: %@", keys);
    [keys sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSNumber *rank1 = [rankDict objectForKey:obj1];
        NSNumber *rank2 = [rankDict objectForKey:obj2];
        
        if ([rank1 integerValue] == [rank2 integerValue])
            return NSOrderedSame;
        else if (isAscending)
            return [rank1 compare:rank2];
        else
            return [rank2 compare:rank1];
    }];
    
    DDLogInfo(@"Keys after sorting: %@", keys);
    
    NSMutableDictionary *resultDict = [NSMutableDictionary new];
    for (NSString *key in keys) {
        [resultDict setObject:[emailDict objectForKey:key] forKey:key];
    }
    
    return resultDict;
}

- (NSDictionary *)sortedByNameDictionaryFromDictionary:(NSDictionary *)emailDict isAscending:(BOOL)isAscending
{
    NSMutableArray *keys = [NSMutableArray arrayWithArray:[emailDict allKeys]];
    [keys sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        if (isAscending)
            return [obj1 caseInsensitiveCompare:obj2];
        else
            return [obj2 caseInsensitiveCompare:obj1];
    }];
    
    NSMutableDictionary *resultDict = [NSMutableDictionary new];
    for (NSString *key in keys) {
        [resultDict setObject:[emailDict objectForKey:key] forKey:key];
    }
    
    return resultDict;
}

#pragma Utilites SortBy functions
- (NSDate *)dateForInboxSectionKey:(NSString *)sectionKey;
{
    
    // Days to add to today
    NSUInteger daysToAdd;
    if (sectionKey == kInboxSectionKeyToday)
        daysToAdd = 0;
    else if (sectionKey == kInboxSectionKeyYesterday)
        daysToAdd = 1;
    else if (sectionKey == kInboxSectionKey2DaysAgo)
        daysToAdd = 2;
    else if (sectionKey == kInboxSectionKey3DaysAgo)
        daysToAdd = 3;
    else if (sectionKey == kInboxSectionKey4DaysAgo)
        daysToAdd = 4;
    else if (sectionKey == kInboxSectionKey5DaysAgo)
        daysToAdd = 5;
    else if (sectionKey == kInboxSectionKey6DaysAgo)
        daysToAdd = 6;
    else
        return nil;
    
    return [NSDate dateWithDaysBeforeNow:daysToAdd];
}

- (NSString *)inboxSectionKeyFromTimestamp:(NSTimeInterval)timestamp;
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timestamp];
    NSDate *now = [NSDate date];
    
    // Distance in days to current date
    NSInteger days = [[date dateAtStartOfDay] distanceInDaysToDate:[now dateAtStartOfDay]];
    
    NSString *sectionKey = nil;
    if ([date isThisMonth]) {
        if (days >= 0 && days <= 6) {
            switch (days) {
                case 0:
                    sectionKey = kInboxSectionKeyToday;
                    break;
                    
                case 1:
                    sectionKey = kInboxSectionKeyYesterday;
                    break;
                    
                case 2:
                    sectionKey = kInboxSectionKey2DaysAgo;
                    break;
                    
                case 3:
                    sectionKey = kInboxSectionKey3DaysAgo;
                    break;
                    
                case 4:
                    sectionKey = kInboxSectionKey4DaysAgo;
                    break;
                    
                case 5:
                    sectionKey = kInboxSectionKey5DaysAgo;
                    break;
                    
                case 6:
                    sectionKey = kInboxSectionKey6DaysAgo;
                    break;
                    
                default:
                    break;
            }
        }
        else if ((days >= 7) && (days <= 13)) {
            sectionKey = kInboxSectionKey1WeekAgo;
        }
        else if ((days >= 14) && (days <= 20)) {
            sectionKey = kInboxSectionKey2WeeksAgo;
        }
        else {
            sectionKey = kInboxSectionKey3WeeksAgo;
        }
    }
    else if ([date isLastMonth]) {
        sectionKey = kInboxSectionKey1MonthAgo;
    }
    
    else {
        sectionKey = kInboxSectionKeyOlder;
    }
    
    return sectionKey;
}

- (EmailGroupingType)groupingTypeBySortingType:(EmailSortingType)sortingType;
{
    if (sortingType == EmailSortingTypeDateASC || sortingType == EmailSortingTypeDateDESC)
        return EmailGroupingTypeDate;
    
    if (sortingType == EmailSortingTypeSenderASC || sortingType == EmailSortingTypeSenderDESC)
        return EmailGroupingTypeSender;
    
    return EmailGroupingTypeSubject;
}

- (NSArray *)sortedSectionKeysFromKeys:(NSArray *)keys sortingType:(EmailSortingType)sortingType;
{
    NSArray *sortedKeys;
    switch (sortingType) {
        case EmailSortingTypeDateASC:
            sortedKeys = [self sortedByDateKeysFromKeys:keys isAscending:YES];
            break;
            
        case EmailSortingTypeDateDESC:
            sortedKeys = [self sortedByDateKeysFromKeys:keys isAscending:NO];
            break;
            
        case EmailSortingTypeSenderASC:
        case EmailSortingTypeSubjectASC:
            sortedKeys = [self sortedByNameKeysFromKeys:keys isAscending:YES];
            break;
            
        case EmailSortingTypeSenderDESC:
        case EmailSortingTypeSubjectDESC:
            sortedKeys = [self sortedByNameKeysFromKeys:keys isAscending:NO];
            break;
            
        default:
            break;
    }
    
    return sortedKeys;
}

- (NSArray *)sortedByDateKeysFromKeys:(NSArray *)keys isAscending:(BOOL)isAscending
{
    NSDictionary *rankDict = @{
                               kInboxSectionKeyToday : @0,
                               kInboxSectionKeyYesterday : @1,
                               kInboxSectionKey2DaysAgo : @2,
                               kInboxSectionKey3DaysAgo : @3,
                               kInboxSectionKey4DaysAgo : @4,
                               kInboxSectionKey5DaysAgo : @5,
                               kInboxSectionKey6DaysAgo : @6,
                               kInboxSectionKey1WeekAgo : @7,
                               kInboxSectionKey2WeeksAgo : @8,
                               kInboxSectionKey3WeeksAgo : @9,
                               kInboxSectionKey1MonthAgo : @10,
                               kInboxSectionKeyOlder : @11
                               };
    
    NSMutableArray *newKeys = [NSMutableArray arrayWithArray:keys];
    [newKeys sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSNumber *rank1 = [rankDict objectForKey:obj1];
        NSNumber *rank2 = [rankDict objectForKey:obj2];
        
        if ([rank1 integerValue] == [rank2 integerValue])
            return NSOrderedSame;
        else if (isAscending)
            return [rank1 compare:rank2];
        else
            return [rank2 compare:rank1];
    }];
    
    return newKeys;
}

- (NSArray *)sortedByNameKeysFromKeys:(NSArray *)keys isAscending:(BOOL)isAscending
{
    NSMutableArray *newKeys = [NSMutableArray arrayWithArray:keys];
    [newKeys sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        
        NSString *normalizeString1 = [obj1 precomposedStringWithCanonicalMapping];
        NSString *normalizeString2 = [obj2 precomposedStringWithCanonicalMapping];
        if (isAscending)
            return [normalizeString1 caseInsensitiveCompare:normalizeString2];
        else
            return [normalizeString2 caseInsensitiveCompare:normalizeString1];
    }];
    
    return newKeys;
}
//
- (NSString *)nameStringForInboxSectionKey:(NSString *)sectionKey itemCount:(NSUInteger)number;
{
    NSString *nameString;
    
    NSDate *date = [self dateForInboxSectionKey:sectionKey];
    if (sectionKey == kInboxSectionKeyToday) {
        nameString = [NSString stringWithFormat:NSLocalizedString(@"Today (%d)",nil), number];
    }
    else if (sectionKey == kInboxSectionKeyYesterday) {
        nameString = [NSString stringWithFormat:NSLocalizedString(@"Yesterday(%d)",nil), number];
    }
    else if (sectionKey == kInboxSectionKey2DaysAgo ||
             sectionKey == kInboxSectionKey3DaysAgo ||
             sectionKey == kInboxSectionKey4DaysAgo ||
             sectionKey == kInboxSectionKey5DaysAgo ||
             sectionKey == kInboxSectionKey6DaysAgo) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"EEEE"];
        nameString = [NSString stringWithFormat:@"%@ (%lu)", [dateFormatter stringFromDate:date], (unsigned long)number];
    }
    else if (sectionKey == kInboxSectionKey1WeekAgo) {
        nameString = [NSString stringWithFormat:NSLocalizedString(@"1 week (%d)",nil), number];
    }
    else if (sectionKey == kInboxSectionKey2WeeksAgo) {
        nameString = [NSString stringWithFormat:NSLocalizedString(@"2 weeks (%d)",nil), number];
    }
    else if (sectionKey == kInboxSectionKey3WeeksAgo) {
        nameString = [NSString stringWithFormat:NSLocalizedString(@"3 weeks (%d)",nil), number];
    }
    else if (sectionKey == kInboxSectionKey1MonthAgo) {
        nameString = [NSString stringWithFormat:NSLocalizedString(@"1 month (%d)",nil), number];
    }
    else if (sectionKey == kInboxSectionKeyOlder) {
        nameString = [NSString stringWithFormat:NSLocalizedString(@"Older (%d)",nil), number];
    }
    
    return nameString;
}

- (NSString *)dateStringForInboxSectionKey:(NSString *)sectionKey
{
    NSString *dateString;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMM dd, yyyy"];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    
    NSDate *date = [self dateForInboxSectionKey:sectionKey];
    if (sectionKey == kInboxSectionKeyToday) {
        dateString = [dateFormatter stringFromDate:date];
    }
    else if (sectionKey == kInboxSectionKeyYesterday) {
        dateString = [dateFormatter stringFromDate:date];
    }
    else if (sectionKey == kInboxSectionKey2DaysAgo ||
             sectionKey == kInboxSectionKey3DaysAgo ||
             sectionKey == kInboxSectionKey4DaysAgo ||
             sectionKey == kInboxSectionKey5DaysAgo ||
             sectionKey == kInboxSectionKey6DaysAgo) {
        dateString = [dateFormatter stringFromDate:date];
    }
    else {
        dateString = nil;
    }
    
    return dateString;
}





@end
