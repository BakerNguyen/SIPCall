//
//  EmailFacade.m
//  Satay
//
//  Created by enclave on 3/19/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import "EmailFacade.h"

@implementation EmailFacade

@synthesize emailLoginDelegate;
@synthesize loadMoreEmailDelegate;
@synthesize emailDetailDelegate;
@synthesize emailSettingDelegate;
@synthesize emailComposeDelegate;
@synthesize createEmailFolderDelegate;
@synthesize sideBarDelegate;
@synthesize chatViewDelegate;

#define ThreeDaysTime 259200
#define OneWeekTime 604800
#define OneMonthTime 2592000
#define ThreeMonthsTime 7776000
#define FiveMinutes 300
#define FifteenMinutes 900
#define AnHour 3600
#define TwoHours 7200

#define Index_SyncSchedule_Never 0
#define Index_SyncSchedule_5Minutes 1
#define Index_SyncSchedule_15Minutes 2
#define Index_SyncSchedule_1Hour 3
#define Index_SyncSchedule_2Hours 4

#define Index_EmailDeletion_Never 0
#define Index_EmailDeletion_FromInbox 1

+(EmailFacade *)share{
    static dispatch_once_t once;
    static EmailFacade * share;
    dispatch_once(&once, ^{
        share = [self new];
    });
    return share;
}

-(NSString*)getLoginEmailFlag{
    NSString *emailLoginFlag =  [KeyChainSecurity getStringFromKey:kIS_LOGGED_IN_EMAIL];
    if (!emailLoginFlag)
        return IS_NO;
    else
        return emailLoginFlag;
}

-(BOOL) checkValidEmailAddress:(NSString*)emailAddress{
   return [[EmailAdapter share] checkValidEmailAddress:emailAddress];
}

-(NSInteger)getOrderDeleteEmailFromServer:(NSString*)deletionEmail{
    
    if ([deletionEmail isEqualToString:kEmailDeletion_Never]) {
        return Index_EmailDeletion_Never;
    }else if ([deletionEmail isEqualToString:kEmailDeletion_FromInbox]){
        return Index_EmailDeletion_FromInbox;
    }else{
        NSLog(@"Invalid deletionEmail string");
        return 0;
    }
}

-(NSInteger)getOrderSyncSchedule:(NSString*)syncSchedule{
    if ([syncSchedule isEqualToString:kEmailSyncSchedule_Never]) {
        return Index_SyncSchedule_Never;
    }else if ([syncSchedule isEqualToString:kEmailSyncSchedule_5Minutes]){
        return Index_SyncSchedule_5Minutes;
    }else if ([syncSchedule isEqualToString:kEmailSyncSchedule_15Minutes]){
        return Index_SyncSchedule_15Minutes;
    }else if ([syncSchedule isEqualToString:kEmailSyncSchedule_1Hour]){
        return Index_SyncSchedule_1Hour;
    }else if ([syncSchedule isEqualToString:kEmailSyncSchedule_2Hours]){
        return Index_SyncSchedule_2Hours;
    }else {
        NSLog(@"Invalid syncSchedule string");
        return 0;
    }
}

-(NSInteger)getTimerFromPeriodSyncSchedule:(NSInteger)periodSyncSchedule{

    switch (periodSyncSchedule) {
        case Index_SyncSchedule_5Minutes:
            return FiveMinutes;
            break;
        case Index_SyncSchedule_15Minutes:
            return FifteenMinutes;
            break;
        case Index_SyncSchedule_1Hour:
            return AnHour;
            break;
        case Index_SyncSchedule_2Hours:
            return TwoHours;
            break;
            
        default:
            return 0;
            break;
    }

}

// Gets all emails of a use in folder, put them into groups.
- (NSDictionary *)getEmailsOfUser:(NSString *)userName
                           folder:(NSInteger)folderIndex
                     groupingType:(EmailGroupingType)groupingType
              unreadMessageNumber:(NSNumber **)unreadNumber
                       fetchEmail:(NSMutableArray *)arrayEmailHeader
{
    NSUInteger unreadMessageCount = 0;
    
    NSMutableArray *fetchedEmails = [arrayEmailHeader mutableCopy];
    fetchedEmails = [self deleteOldEmailInFolder:folderIndex emails:fetchedEmails];
    if (!fetchedEmails || fetchedEmails.count == 0) {
        *unreadNumber = [NSNumber numberWithInteger:unreadMessageCount];
        return nil;
    }
    
    NSNumber *number = [NSNumber numberWithInteger:0];
    NSDictionary *emailDict;
    
    switch (groupingType) {
        case EmailGroupingTypeDate:
        {
            emailDict = [self classifiedByDateListFromEmails:fetchedEmails
                                                unreadNumber:&number];
        }
            break;
            
        case EmailGroupingTypeSubject:
        {
            emailDict = [self classifiedBySubjectListFromEmails:fetchedEmails
                                                   unreadNumber:&number];
        }
            break;
            
        case EmailGroupingTypeSender:
        {
            emailDict = [self classifiedBySenderListFromEmails:fetchedEmails
                                                  unreadNumber:&number];
        }
            break;
            
        default:
            break;
    }
    
    *unreadNumber = number;
    return emailDict;
}

#pragma mark Sortby functions
- (NSDictionary *)classifiedByDateListFromEmails:(NSArray *)emails unreadNumber:(NSNumber **)unreadNumber
{
    NSMutableDictionary *emailDict = [NSMutableDictionary new];
    NSMutableArray *sectionKeys = [NSMutableArray new];
    NSUInteger unreadMessageCount = 0;
    
    for (NSInteger i = 0; i < emails.count; i++)
    {
        MailHeader *item = [emails objectAtIndex:i];
        if ([item.emailFrom isEqual:@"Gilt"])
            NSLog(@"%@", item.subject);
        // Get the section key for the item
        NSString *key = [[EmailAdapter share] inboxSectionKeyFromTimestamp:[item.sendDate doubleValue]];
        // Check the the key has already existed in the email dictionary, if NOT insert it into the dictionary's keys
        NSUInteger index = [sectionKeys indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
            return [obj isEqualToString:key];
        }];
        
        if (index == NSNotFound)
        {
            // Log the key into the section keys array
            [sectionKeys addObject:key];
            // Create a mutable array in the email dictionary to contain associated emails
            NSMutableArray *emailsInSection = [NSMutableArray new];
            [emailsInSection addObject:item];
            [emailDict setObject:emailsInSection forKey:key];
        }
        else
        {
            // The section of email already existed in the email dict, just insert into
            NSMutableArray *emailsInSection = (NSMutableArray *)[emailDict objectForKey:key];
            [emailsInSection addObject:item];
        }
        // Count unread messages
        if (item.emailStatus == 0)
            unreadMessageCount++;
    }
    
    *unreadNumber = [NSNumber numberWithInteger:unreadMessageCount];
    return emailDict;
}

- (NSDictionary *)classifiedBySenderListFromEmails:(NSArray *)emails unreadNumber:(NSNumber **)unreadNumber
{
    NSMutableDictionary *emailDict = [NSMutableDictionary new];
    NSMutableArray *sectionKeys = [NSMutableArray new];
    NSUInteger unreadMessageCount = 0;
    
    for (NSInteger i = 0; i < emails.count; i++)
    {
        MailHeader *item = [emails objectAtIndex:i];
        // Get the section key for the item
        NSString *key = item.extend1;
        // Check the the key has already existed in the email dictionary, if NOT insert it into the dictionary's keys
        NSUInteger index = [sectionKeys indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
            return [obj isEqualToString:key];
        }];
        if (index == NSNotFound)
        {
            // Log the key into the section keys array
            [sectionKeys addObject:key];
            // Create a mutable array in the email dictionary to contain associated emails
            NSMutableArray *emailsInSection = [NSMutableArray new];
            [emailsInSection addObject:item];
            [emailDict setObject:emailsInSection forKey:key];
        }
        else
        {
            // The section of email already existed in the email dict, just insert into
            NSMutableArray *emailsInSection = (NSMutableArray *)[emailDict objectForKey:key];
            [emailsInSection addObject:item];
        }
        // Count unread messages
        if (item.emailStatus == 0)
            unreadMessageCount++;
    }
    
    *unreadNumber = [NSNumber numberWithInteger:unreadMessageCount];
    return emailDict;
}

- (NSDictionary *)classifiedBySubjectListFromEmails:(NSArray *)emails unreadNumber:(NSNumber **)unreadNumber
{
    NSMutableDictionary *emailDict = [NSMutableDictionary new];
    NSMutableArray *sectionKeys = [NSMutableArray new];
    NSUInteger unreadMessageCount = 0;
    
    for (NSInteger i = 0; i < emails.count; i++)
    {
        MailHeader *item = [emails objectAtIndex:i];
        // Get the section key for the item
        NSString *key = item.subject;
        // Check the the key has already existed in the email dictionary, if NOT insert it into the dictionary's keys
        NSUInteger index = [sectionKeys indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
            return [obj isEqualToString:key];
        }];
        if (index == NSNotFound)
        {
            // Log the key into the section keys array
            [sectionKeys addObject:key];
            // Create a mutable array in the email dictionary to contain associated emails
            NSMutableArray *emailsInSection = [NSMutableArray new];
            [emailsInSection addObject:item];
            [emailDict setObject:emailsInSection forKey:key];
        }
        else
        {
            // The section of email already existed in the email dict, just insert into
            NSMutableArray *emailsInSection = (NSMutableArray *)[emailDict objectForKey:key];
            [emailsInSection addObject:item];
        }
        // Count unread messages
        if (item.emailStatus == 0)
            unreadMessageCount++;
    }
    
    *unreadNumber = [NSNumber numberWithInteger:unreadMessageCount];
    return emailDict;
}

// Returns a sorted emails array from a given emails using a sorting type
- (NSArray *)sortedEmailsFromEmails:(NSArray *)emails sortingType:(EmailSortingType)sortingType;
{
    NSArray *sortedEmails = [NSArray new];
    switch (sortingType)
    {
        case EmailSortingTypeDateDESC:
        {
            sortedEmails = [emails sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                MailHeader *email1 = (MailHeader *)obj1;
                MailHeader *email2 = (MailHeader *)obj2;
                
                NSNumber *timeNumber1 = email1.sendDate;
                NSNumber *timeNumber2 = email2.sendDate;
                
                return [timeNumber1 compare:timeNumber2];
            }];
        }
            break;
            
        default:
        {
            sortedEmails = [emails sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                MailHeader *email1 = (MailHeader *)obj1;
                MailHeader *email2 = (MailHeader *)obj2;
                
                NSNumber *timeNumber1 = email1.sendDate;
                NSNumber *timeNumber2 = email2.sendDate;
                
                return [timeNumber2 compare:timeNumber1];
            }];
        }
            break;
    }
    
    return sortedEmails;
}

// Returns a emails dictionary with sorted content using a sorting type
- (NSDictionary *)emailsDictionayWithSortedContentFromDictionary:(NSDictionary *)emailsDict
                                                     sortingType:(EmailSortingType)sortingType;
{
    NSMutableDictionary *returnedDict = [NSMutableDictionary new];
    
    for (NSString *sectionKey in emailsDict.allKeys)
    {
        NSArray *emailsInSection = [emailsDict objectForKey:sectionKey];
        emailsInSection = [self sortedEmailsFromEmails:emailsInSection sortingType:sortingType];
        [returnedDict setObject:emailsInSection forKey:sectionKey];
    }
    
    return [returnedDict copy];
}

- (EmailGroupingType)groupingTypeBySortingType:(EmailSortingType)sortingType{
    return [[EmailAdapter share] groupingTypeBySortingType:sortingType];
}

- (NSArray *)sortedSectionKeysFromKeys:(NSArray *)keys sortingType:(EmailSortingType)sortingType{    
    return [[EmailAdapter share] sortedSectionKeysFromKeys:keys sortingType:sortingType];
}

- (NSString *)nameStringForInboxSectionKey:(NSString *)sectionKey itemCount:(NSUInteger)number{
    return [[EmailAdapter share] nameStringForInboxSectionKey:sectionKey itemCount:number];
}
- (NSString *)dateStringForInboxSectionKey:(NSString *)sectionKey{
    return [[EmailAdapter share] dateStringForInboxSectionKey:sectionKey];
}

#pragma mark DB functions
- (void) decreaseHeaderNumber:(MailHeader *)emailHeader
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger numberOfEmailHeadersFolder = [[defaults objectForKey:[NSString stringWithFormat:@"%ld",(long)emailHeader.folderIndex.integerValue]] integerValue];
    numberOfEmailHeadersFolder--;
    
    [defaults setObject:[NSNumber numberWithInteger:numberOfEmailHeadersFolder]
                 forKey:[NSString stringWithFormat:@"%ld",(long)emailHeader.folderIndex.integerValue]];
}

- (void) increaseHeaderNumber:(MailHeader *)emailHeader
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger numberOfEmailHeadersFolder = [[defaults objectForKey:[NSString stringWithFormat:@"%ld",(long)emailHeader.folderIndex.integerValue]] integerValue];
    numberOfEmailHeadersFolder++;
    
    [defaults setObject:[NSNumber numberWithInteger:numberOfEmailHeadersFolder]
                 forKey:[NSString stringWithFormat:@"%ld",(long)emailHeader.folderIndex.integerValue]];
}

-(void) deleteDraftEmail:(NSString *)emailUID
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    MailHeader *emailHeader = [self getMailHeaderFromUid:emailUID];
    if (emailHeader.folderIndex.integerValue != kINDEX_FOLDER_DRAFTS)
        return;
    
    [self decreaseHeaderNumber:emailHeader];
    emailHeader.emailStatus = [NSNumber numberWithInt:2]; //delete
    [[DAOAdapter share] commitObject:emailHeader];
    MailContent *emailContent = [self getMailContentFromMailHeaderUid:emailUID];
    [[DAOAdapter share] deleteObject:emailContent];
    [self deleteEmailAttachment:emailUID];
}

- (void) deleteEmailAttachment:(NSString *)emailUID
{
    NSArray *arrayAttachment = [self getMailAttachmentsFromUid:emailUID];
    for (MailAttachment *emailAttachment  in arrayAttachment) {
        [[DAOAdapter share] deleteObject:emailAttachment];
    }
}

- (Contact *)getContactFromEmail:(NSString *)emailAddress
{
    NSString *queryCondition = [NSString stringWithFormat:@"email = '%@'", emailAddress];
   return (Contact *)[[DAOAdapter share] getObject:[Contact class] condition:queryCondition];
}

- (UIImage *)getAvatarFromEmail:(NSString *)emailAddress
{
    Contact *contactObj = [self getContactFromEmail:emailAddress];
    if (contactObj)
    {
        return [[ContactFacade share] updateContactAvatar:contactObj.jid];
    }
    else return [UIImage imageNamed:IMG_C_EMPTY];
}

- (void) buildReopenComposeWithHeader:(MailHeader *)emailHeader
{
    MailContent *emailContent = [self getMailContentFromMailHeaderUid:emailHeader.uid];
    NSArray *mailAttachmentsList = [self getMailAttachmentsFromUid:emailHeader.uid];
    NSMutableDictionary *data = [NSMutableDictionary new];
    [data setObject:emailHeader forKey:kEMAIL_HEADER_KEY];
    [data setObject:emailContent forKey:kEMAIL_CONTENT_KEY];
    if (mailAttachmentsList.count > 0)
    {
        NSMutableArray *arrayAttachment = [NSMutableArray new];
        for (MailAttachment *mailAttachment in mailAttachmentsList)
        {
            [arrayAttachment addObject:mailAttachment.attachmentName];
        }
        [data setObject:arrayAttachment forKey:kEMAIL_ATTACHMENT_KEY];
    }
    [emailComposeDelegate buildReopenComposeViewData:data];
}

- (void) saveEmailFolderName:(NSString *)newFolderName oldName:(NSString *)oldFolderName
{
    //mailAccountObj = [MailAccount new];
    NSArray *folderList= [[EmailFacade share ]getAllEmailFolders];
    long folderIndex= [folderList count];
    
    if (oldFolderName.length > 0)
    {
        if ([newFolderName isEqualToString:oldFolderName])
        {
            [createEmailFolderDelegate createFolderSucceded];
        }
        else
        {
            // function to change the name of existing folder
            for (int i = 0; i < folderIndex; i ++)
            {
                MailFolder *emailFolder = [folderList objectAtIndex:i];
                if ([oldFolderName isEqualToString:emailFolder.folderName])
                {
                    [self updateEmailFolderName:newFolderName oldFolderName:oldFolderName];
                    [createEmailFolderDelegate createFolderSucceded];
                }
            }
        }
    }
    else
    {
        BOOL isExist = NO;
        for (int i = 0; i < folderIndex; i ++)
        {
            MailFolder *emailFolder = [folderList objectAtIndex:i];
            if ([newFolderName isEqualToString:emailFolder.folderName])
            {
                isExist = YES;
            }
        }
        
        if (isExist)
        {
            // Show alert duplicate folder name
            [createEmailFolderDelegate showAlertDuplicateName];
        }
        else
        {
            //Create new folder
            [self createEmailFolder:newFolderName folderIndex:folderIndex+1 status:@""];
            [createEmailFolderDelegate createFolderSucceded];
        }
    }
}

-(void) createDefaultEmailFolders{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [self createEmailFolder:FOLDER_INBOX folderIndex:kINDEX_FOLDER_INBOX status:@""];
    [self createEmailFolder:FOLDER_DRAFTS folderIndex:kINDEX_FOLDER_DRAFTS status:@""];
    [self createEmailFolder:FOLDER_SENT folderIndex:kINDEX_FOLDER_SENT status:@""];
    [self createEmailFolder:FOLDER_RECYCLE_BIN folderIndex:kINDEX_FOLDER_RECYCLE_BIN status:@""];
    [self createEmailFolder:FOLDER_JUNK folderIndex:kINDEX_FOLDER_JUNK status:@""];
    [self createEmailFolder:FOLDER_OUTBOX folderIndex:kINDEX_FOLDER_OUTBOX status:@""];
    [self createEmailFolder:FOLDER_SAVED_EMAILS folderIndex:kINDEX_FOLDER_SAVED_EMAILS status:@""];
}

-(void)createEmailFolder:(NSString*)folderName folderIndex:(NSInteger)folderIndex status:(NSString*)status
{
    NSString* queryCondition = [NSString stringWithFormat:@"folderName = '%@'", folderName];
    MailFolder* mailFolder = (MailFolder*)[[DAOAdapter share] getObject:[MailFolder class]
                                                              condition:queryCondition];
    if (!mailFolder)
    {
        mailFolder = [MailFolder new];
        mailFolder.folderIndex = [NSNumber numberWithInteger:folderIndex];
        mailFolder.folderName = folderName;
        mailFolder.status = status;

        [[DAOAdapter share] commitObject:mailFolder];
    }
}

- (void) updateEmailFolderName:(NSString*)newFolderName oldFolderName:(NSString*)oldFolderName
{
    NSString* queryCondition = [NSString stringWithFormat:@"folderName = '%@'", oldFolderName];
    MailFolder* mailFolder = (MailFolder*)[[DAOAdapter share] getObject:[MailFolder class]
                                                              condition:queryCondition];
    if (mailFolder)
    {
        mailFolder.folderName = newFolderName;
        [[DAOAdapter share] commitObject:mailFolder];
    }
}

-(void)deleteEmailFolder:(NSString*)folderName
{
    NSString* queryCondition = [NSString stringWithFormat:@"folderName = '%@'", folderName];
    MailFolder* mailFolder = (MailFolder*)[[DAOAdapter share] getObject:[MailFolder class]
                                                              condition:queryCondition];

    if ([mailFolder.folderName isEqualToString:folderName])
    {
        [[DAOAdapter share]deleteObject:mailFolder];
     }
    
}

-(NSString*)getEmailAddress
{
    return [KeyChainSecurity getStringFromKey:kEMAIL_ADDRESS];
}

-(MailAccount*) getMailAccount:(NSString*)username{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSString* queryCondition = [NSString stringWithFormat:@"fullEmail = '%@'", username];
    MailAccount* mailAccount = (MailAccount*)[[DAOAdapter share] getObject:[MailAccount class]
                                                                 condition:queryCondition];
    if (!mailAccount)
        return nil;

    mailAccount.displayName = [self decryptString:mailAccount.displayName];
    mailAccount.signature = [self decryptString:mailAccount.signature];
    mailAccount.incomingUserName = [self decryptString:mailAccount.incomingUserName];
    mailAccount.incomingHost = [self decryptString:mailAccount.incomingHost];
    mailAccount.outgoingUserName = [self decryptString:mailAccount.outgoingUserName];
    mailAccount.outgoingHost = [self decryptString:mailAccount.outgoingHost];
    
    return mailAccount;
}

-(BOOL) updateMailAccount:(MailAccount*) mailAccount{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    mailAccount.displayName = [self encryptString:mailAccount.displayName];
    mailAccount.signature = [self encryptString:mailAccount.signature];
    mailAccount.incomingUserName = [self encryptString:mailAccount.incomingUserName];
    mailAccount.incomingHost = [self encryptString:mailAccount.incomingHost];
    mailAccount.outgoingUserName = [self encryptString:mailAccount.outgoingUserName];
    mailAccount.outgoingHost = [self encryptString:mailAccount.outgoingHost];
    BOOL result = [[DAOAdapter share] commitObject:mailAccount];
    
    if (result){
        NSLog(@"Update Mail Account local success.");
    }
    return result;
}

- (void)saveEmailHeader:(MailHeader *)emailHeader
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        emailHeader.subject = [self encryptString:emailHeader.subject];

        if (emailHeader.shortDesc.length > 0)
            emailHeader.shortDesc = [self encryptString:emailHeader.shortDesc];
        
        [[DAOAdapter share] commitObject:emailHeader];
    });
}

-(NSInteger) getNumberOfEmailHeadersInFolder:(NSInteger)folderIndex
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSString* queryCondition = [NSString stringWithFormat:@"folderIndex = '%ld' AND emailStatus != '%d'", (long)folderIndex, 2];
    NSArray *arrayEmailHeader = [[DAOAdapter share] getObjects:[MailHeader class]
                                                     condition:queryCondition];
    return [arrayEmailHeader count];
}

-(NSArray*) getEmailHeadersInFolder:(NSInteger)folderIndex{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSString* queryCondition = [NSString stringWithFormat:@"folderIndex = '%ld' AND emailStatus != '%d'", (long)folderIndex, 2];
    NSArray *arrayEmailHeader = [[DAOAdapter share] getObjects:[MailHeader class]
                                                     condition:queryCondition];
    NSMutableArray *arrayEmailHeaderResult = [NSMutableArray new];
    for (MailHeader *emailHeader in arrayEmailHeader)
    {
        emailHeader.subject = [self decryptString:emailHeader.subject];
        
        if (emailHeader.shortDesc.length > 0)
            emailHeader.shortDesc = [self decryptString:emailHeader.shortDesc];
        
        [arrayEmailHeaderResult addObject:emailHeader];
    }
    return arrayEmailHeaderResult;
}

-(MailFolder*) getMailFolderFromIndex:(NSInteger)folderIndex{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSString* queryCondition = [NSString stringWithFormat:@"folderIndex = '%ld'", (long)folderIndex];
    MailFolder* mailFolder = (MailFolder*)[[DAOAdapter share] getObject:[MailFolder class]
                                                              condition:queryCondition];
    return mailFolder;
}

-(NSArray*) getAllEmailFolders{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSArray* mailFolders = (NSArray*)[[DAOAdapter share] getAllObject:[MailFolder class]];
    return mailFolders;
}

- (void) saveEmailContent:(MailContent *)emailContent
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    if (emailContent.htmlContent.length > 0)
        emailContent.htmlContent = [self encryptString:emailContent.htmlContent];
    
    [[DAOAdapter share] commitObject:emailContent];
    
}
-(MailContent*) getMailContentFromMailHeaderUid:(NSString*)uid{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSString* queryCondition = [NSString stringWithFormat:@"emailHeaderUID = '%@'", uid];
    NSArray* mailContentObs = [[DAOAdapter share] getObjects:[MailContent class]
                                                   condition:queryCondition
                                                     orderBy:@"emailHeaderUID"
                                                isDescending:YES limit:1];
    MailContent *emailContent;
    if (mailContentObs.count > 0)
        emailContent = [mailContentObs firstObject];
    
    if (emailContent.htmlContent.length > 0)
        emailContent.htmlContent = [self decryptString:emailContent.htmlContent];
    return emailContent;
}

-(MailHeader*) getMailHeaderFromUid:(NSString*)uid{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSString* queryCondition = [NSString stringWithFormat:@"uid = '%@'", uid];
    MailHeader* emailHeader = (MailHeader*)[[DAOAdapter share] getObject:[MailHeader class]
                                                               condition:queryCondition];
    if (!emailHeader) {
        return nil;
    }

    emailHeader.subject = [self decryptString:emailHeader.subject];
    
    if (emailHeader.shortDesc.length > 0)
        emailHeader.shortDesc = [self decryptString:emailHeader.shortDesc];
    
    return emailHeader;
}

- (void)updateSeenFlagForEmail:(NSString*)uid{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    MailHeader *emailHeaderObj = [self getMailHeaderFromUid:uid];
    emailHeaderObj.emailStatus = [NSNumber numberWithInt:1];
    [sideBarDelegate updateEmailRowUnreadNumber:-1];
    [self saveEmailHeader:emailHeaderObj];
    [self getConfigurationImapAccount];
    [[EmailAdapter share] updateFlagMessageWithFolderForImap:FOLDER_INBOX
                                                         uid:emailHeaderObj.uid.intValue
                                                        flag:MCOMessageFlagSeen
                                                    callback:^(BOOL success, NSString *message, NSError *error){
                                                        if (success)
                                                        {
                                                            NSLog(@"update succedded");
                                                        }
                                                    }];
}

-(NSInteger) countTotalUnreadEmailInFolderIndex:(NSInteger)folderIndex{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSString* queryCondition = [NSString stringWithFormat:@"folderIndex = '%ld' AND emailStatus = '%d'", (long)folderIndex, 0];
    NSArray* mailHeaderObjs = (NSArray*)[[DAOAdapter share] getObjects:[MailHeader class]
                                                             condition:queryCondition];
    [sideBarDelegate reloadNotificationCount:mailHeaderObjs.count MenuID:SideBarEmailIndex];
    return mailHeaderObjs.count;
}

-(NSArray*) getMailAttachmentsFromUid:(NSString*)uid{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSString* queryCondition = [NSString stringWithFormat:@"mailHeaderUID = '%@'", uid];
    NSArray *mailAttachments = (NSArray*)[[DAOAdapter share] getObjects:[MailAttachment class]
                                                              condition:queryCondition];
    return mailAttachments;
}

#pragma mark Login functions
-(void)loginEmailAccountType:(NSDictionary*)emailAccountDic{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSString *hostname = @"";
    int port;
    int connectType;
    
    NSString* type = [[emailAccountDic objectForKey:kEMAIL_ACCOUNT_TYPE] stringValue];
    
    if (type.length == 0) {
        NSLog(@"Email account type is invalid");
        return;
    }

    NSMutableDictionary * emailAccount = [emailAccountDic mutableCopy];
    
    switch (type.integerValue)
    {
        case kEMAIL_ACCOUNT_TYPE_MICROSOFT_EXCHANGE:
        {//Microsoft exchage
            hostname = [emailAccountDic objectForKey:kEMAIL_INC_HOST];
            port = kEMAIL_PORT_993;
            connectType = kEMAIL_CONNECTION_TYPE_TLS_SSL;//tls-ssl
            
            [emailAccount setObject:[emailAccountDic objectForKey:kEMAIL_PASSWORD] forKey:kEMAIL_INC_PASSWORD];
            [emailAccount setObject:[emailAccountDic objectForKey:kEMAIL_PASSWORD] forKey:kEMAIL_OUT_PASSWORD];
            [emailAccount setObject:[NSNumber numberWithInt:connectType] forKey:kEMAIL_OUT_SECURITY_TYPE];
            
            [emailAccount setObject:[NSNumber numberWithInt:kEMAIL_PORT_587] forKey:kEMAIL_OUT_PORT];
            [emailAccount setObject:[NSNumber numberWithInt:kEMAIL_CONNECTION_TYPE_STARTTLS] forKey:kEMAIL_OUT_SECURITY_TYPE];
            [[LogFacade share] createEventWithCategory:Email_Category
                                                   action:signUp_Click_Action
                                                    label:setUpMicrosoftAction];
        }
            break;
            
        case kEMAIL_ACCOUNT_TYPE_GMAIL:
        {//gmail
            hostname = kGMAIL_IMAP_HOSTNAME;
            port = kEMAIL_PORT_993;
            connectType = kEMAIL_CONNECTION_TYPE_TLS_SSL;//tls-ssl
            //outgoing gmail
            [emailAccount setObject:[emailAccountDic objectForKey:kEMAIL_ADDRESS]
                             forKey:kEMAIL_OUT_USENAME];
            [emailAccount setObject:[emailAccountDic objectForKey:kEMAIL_PASSWORD]
                             forKey:kEMAIL_OUT_PASSWORD];
            [emailAccount setObject:kGMAIL_SMTP_HOSTNAME
                             forKey:kEMAIL_OUT_HOST];
            [emailAccount setObject:[NSNumber numberWithInt:kEMAIL_PORT_587]
                             forKey:kEMAIL_OUT_PORT];
            [emailAccount setObject:[NSNumber numberWithInt:kEMAIL_CONNECTION_TYPE_STARTTLS]
                             forKey:kEMAIL_OUT_SECURITY_TYPE];
            
            [[LogFacade share] createEventWithCategory:Email_Category
                                                action:signUp_Click_Action
                                                 label:setUpGmailAction];
        }
            break;
            
        case kEMAIL_ACCOUNT_TYPE_YAHOO:
        {//yahoo
            hostname = kYAHOO_IMAP_HOSTNAME;
            port = kEMAIL_PORT_993;
            connectType = kEMAIL_CONNECTION_TYPE_TLS_SSL;
            
            //outgoing yahoo
            [emailAccount setObject:[emailAccountDic objectForKey:kEMAIL_ADDRESS]
                             forKey:kEMAIL_OUT_USENAME];
            [emailAccount setObject:[emailAccountDic objectForKey:kEMAIL_PASSWORD]
                             forKey:kEMAIL_OUT_PASSWORD];
            [emailAccount setObject:kYAHOO_SMTP_HOSTNAME
                             forKey:kEMAIL_OUT_HOST];
            [emailAccount setObject:[NSNumber numberWithInt:kEMAIL_PORT_465]
                             forKey:kEMAIL_OUT_PORT];
            [emailAccount setObject:[NSNumber numberWithInt:connectType]
                             forKey:kEMAIL_OUT_SECURITY_TYPE];
            [[LogFacade share] createEventWithCategory:Email_Category
                                                action:signUp_Click_Action
                                                 label:setUpYahooAction];
        }
            break;
            
        case kEMAIL_ACCOUNT_TYPE_HOTMAIL:
        {//hotmail
            hostname = kOUTLOOK_IMAP_HOSTNAME;
            port = kEMAIL_PORT_993;
            connectType = kEMAIL_CONNECTION_TYPE_TLS_SSL;
            
            //outgoing hot mail
            [emailAccount setObject:[emailAccountDic objectForKey:kEMAIL_ADDRESS]
                             forKey:kEMAIL_OUT_USENAME];
            [emailAccount setObject:[emailAccountDic objectForKey:kEMAIL_PASSWORD]
                             forKey:kEMAIL_OUT_PASSWORD];
            [emailAccount setObject:kOUTLOOK_SMTP_HOSTNAME
                             forKey:kEMAIL_OUT_HOST];
            [emailAccount setObject:[NSNumber numberWithInt:kEMAIL_PORT_25]
                             forKey:kEMAIL_OUT_PORT];
            [emailAccount setObject:[NSNumber numberWithInt:kEMAIL_CONNECTION_TYPE_STARTTLS]
                             forKey:kEMAIL_OUT_SECURITY_TYPE];//starttls
            [[LogFacade share] createEventWithCategory:Email_Category
                                                action:signUp_Click_Action
                                                 label:setUpHotmailAction];
        }
            break;
        case kEMAIL_ACCOUNT_TYPE_OTHER_IMAP:
        {//IMAP
            hostname = [emailAccountDic objectForKey:kEMAIL_INC_HOST];
            port = [[emailAccountDic objectForKey:kEMAIL_INC_PORT] intValue];
            if (port == kEMAIL_PORT_993) {
                connectType = kEMAIL_CONNECTION_TYPE_TLS_SSL;//ssl
            }else{//143 or others
                connectType = kEMAIL_CONNECTION_TYPE_STARTTLS;//starttls
            }
            [[LogFacade share] createEventWithCategory:Email_Category
                                                action:signUp_Click_Action
                                                 label:setUpOfficeAction];
        }
            break;
            
        case kEMAIL_ACCOUNT_TYPE_OTHER_POP:
        {//POP kind
            hostname = [emailAccountDic objectForKey:kEMAIL_INC_HOST];
            port = [[emailAccountDic objectForKey:kEMAIL_INC_PORT] intValue];
            
            switch (port) {
                case kEMAIL_PORT_995:
                        connectType = kEMAIL_CONNECTION_TYPE_TLS_SSL;
                    break;
                case kEMAIL_PORT_110:
                        connectType = kEMAIL_CONNECTION_TYPE_STARTTLS;
                    break;
                default:
                        connectType = kEMAIL_CONNECTION_TYPE_STARTTLS;
                    break;
            }
            [[LogFacade share] createEventWithCategory:Email_Category
                                                action:signUp_Click_Action
                                                 label:setUpOfficeAction];
        }
            break;
            
        default:
            break;
    }
    
    [emailAccount setObject:[emailAccountDic objectForKey:kEMAIL_ADDRESS]
                     forKey:kEMAIL_INC_USENAME];
    [emailAccount setObject:[emailAccountDic objectForKey:kEMAIL_PASSWORD]
                     forKey:kEMAIL_INC_PASSWORD];
    [emailAccount setObject:hostname
                     forKey:kEMAIL_INC_HOST];
    [emailAccount setObject:[NSNumber numberWithInt:port]
                     forKey:kEMAIL_INC_PORT];
    [emailAccount setObject:[NSNumber numberWithInt:connectType]
                     forKey:kEMAIL_CONNECTION_TYPE];
    [emailAccount setObject:[NSNumber numberWithInt:connectType]
                     forKey:kEMAIL_INC_SECURITY_TYPE];
    
    if ([[emailAccountDic objectForKey:kEMAIL_ACCOUNT_TYPE] isEqualToNumber:[NSNumber numberWithInt:5]])
    {
        [self configurePopAccount:emailAccount];
        [self checkPopAccount:emailAccount];
    }
    else
    {
        [self configureImapAccount:emailAccount];
        [self checkImapAccount:emailAccount];
    }
}

-(void) configureImapAccount:(NSDictionary*)emailAccountDic{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSString *username = [emailAccountDic objectForKey:kEMAIL_ADDRESS];
    NSString *password = [emailAccountDic objectForKey:kEMAIL_PASSWORD];
    NSString *hostname = [emailAccountDic objectForKey:kEMAIL_INC_HOST];
    NSNumber *port = [emailAccountDic objectForKey:kEMAIL_INC_PORT];
    NSNumber *type = [emailAccountDic objectForKey:kEMAIL_CONNECTION_TYPE];
    
    [[EmailAdapter share] configureImapAccount:username
                                      password:password
                                      hostname:hostname
                                          port:[port intValue]
                                connectionType:[type intValue]];
}

- (void)checkImapAccount:(NSDictionary*)emailAccountDic{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    [[CWindow share] showLoading:kLOADING_CHECKING];
    [[EmailAdapter share] checkImapAccount:^(BOOL success, NSString *message, NSError *error) {
        [[CWindow share] hideLoading];
        if (!success)
        {
            if (error.code == MCOErrorConnection)
            {
                NSError *error = [NSError errorWithDomain:kEMAIL_ERROR_DOMAIN code:-1 userInfo:@{NSLocalizedDescriptionKey: NO_INTERNET_CONNECTION_TRY_LATER}];
                [emailLoginDelegate loginEmailAccountFailedWithError:error];
            }
            else if([message isEqualToString:mError_PleaseLoginViaYourWebBrowser])
            {
                NSError *error = [NSError errorWithDomain:kEMAIL_ERROR_DOMAIN code:-1 userInfo:@{NSLocalizedDescriptionKey: mError_WeAreUnableToSetupYourEmail}];
                [emailLoginDelegate loginEmailAccountFailedWithError:error];
            }
            else
            {
                NSError *error = [NSError errorWithDomain:kEMAIL_ERROR_DOMAIN code:-1 userInfo:@{NSLocalizedDescriptionKey: ERROR_EMAIL_ACCOUNT_OR_PASSWORD_INCORRECT}];
                [emailLoginDelegate loginEmailAccountFailedWithError:error];
            }
        }
        else
        {
            [self updateEmailAccountToServer:emailAccountDic];
        }
    }];
}

-(void) configurePopAccount:(NSDictionary*)emailAccountDic
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSString *username = [emailAccountDic objectForKey:kEMAIL_INC_USENAME];
    NSString *password = [emailAccountDic objectForKey:kEMAIL_INC_PASSWORD];
    NSString *hostname = [emailAccountDic objectForKey:kEMAIL_INC_HOST];
    NSNumber *port = [emailAccountDic objectForKey:kEMAIL_INC_PORT];
    NSNumber *type = [emailAccountDic objectForKey:kEMAIL_CONNECTION_TYPE];
    
    [[EmailAdapter share] configurePopAccount:username
                                     password:password
                                     hostname:hostname
                                         port:[port intValue]
                               connectionType:[type intValue]];
    
}

- (void)checkPopAccount:(NSDictionary*)emailAccountDic{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [[CWindow share] showLoading:kLOADING_CHECKING];
    
    [[EmailAdapter share] checkPopAccount:^(BOOL success, NSString *message, NSError *error) {
        [[CWindow share] hideLoading];
        if (error) {
             NSError *error = [NSError errorWithDomain:kEMAIL_ERROR_DOMAIN code:-1 userInfo:@{NSLocalizedDescriptionKey: ERROR_EMAIL_ACCOUNT_OR_PASSWORD_INCORRECT}];
            [emailLoginDelegate loginEmailAccountFailedWithError:error];
            NSDictionary* logDic = @{
                       LOG_CLASS : NSStringFromClass(self.class),
                       LOG_CATEGORY: CATEGORY_EMAIL_EMAIL_SETUP_OTHER_POP3_FAIL,
                       LOG_MESSAGE: [NSString stringWithFormat:@"CHECK POP ACCOUNT FAILED ERROR: %@",error],
                       LOG_EXTRA1: @"",
                       LOG_EXTRA2: @""
                       };
            [[LogFacade share] logErrorWithDic:logDic];
        }else{
            [self updateEmailAccountToServer:emailAccountDic];
            NSDictionary* logDic = @{
                                     LOG_CLASS : NSStringFromClass(self.class),
                                     LOG_CATEGORY: CATEGORY_EMAIL_EMAIL_SETUP_OTHER_POP3_INPROGRESS,
                                     LOG_MESSAGE: [NSString stringWithFormat:@"CHECK POP ACCOUNT SUCCESS"],
                                     LOG_EXTRA1: @"",
                                     LOG_EXTRA2: @""
                                     };
            [[LogFacade share] logInfoWithDic:logDic];
        }
    }];
}

- (void)updateEmailAccountToServer:(NSDictionary*)emailAccountDic{
    NSLog(@"%s %@", __PRETTY_FUNCTION__, emailAccountDic);

    [[CWindow share] showLoading:kLOADING_UPDATING];
    
    NSDictionary *updateEmailDic = @{kAPI_REQUEST_METHOD: POST,
                                     kAPI_REQUEST_KIND: NORMAL,
                                     kMASKINGID: [[ContactFacade share] getMaskingId],
                                     kTOKEN: [[ContactFacade share] getTokentTenant],
                                     kEMAIL: [emailAccountDic objectForKey:kEMAIL_ADDRESS]
                                     };
    
    [[EmailAdapter share] updateEmailAccountToServer:updateEmailDic
                                            callback:^(BOOL success, NSString *message, NSDictionary *response, NSError *error) {
        [[CWindow share] hideLoading];
        if (success)
        {
            [KeyChainSecurity storeString:IS_YES Key:kIS_LOGGED_IN_EMAIL];
            
            [KeyChainSecurity storeString:[emailAccountDic objectForKey:kEMAIL_ADDRESS] Key:kEMAIL_ADDRESS];
            NSLog(@"Email Address:%@", [KeyChainSecurity getStringFromKey:kEMAIL_ADDRESS]);
            //encrypt email password
            NSString *securePassword = [self encryptString:[emailAccountDic objectForKey:kEMAIL_PASSWORD]];
            NSString *incSecurePassword = [self encryptString:[emailAccountDic objectForKey:kEMAIL_INC_PASSWORD]];
            NSString *outSecurePassword = [self encryptString:[emailAccountDic objectForKey:kEMAIL_OUT_PASSWORD]];
            
            //Save database
            MailAccount *mailAccount  = [self getMailAccount:[emailAccountDic objectForKey:kEMAIL_ADDRESS]];
            
            if (!mailAccount)
            {
                mailAccount = [MailAccount new];
                mailAccount.fullEmail = [emailAccountDic objectForKey:kEMAIL_ADDRESS];
                mailAccount.password = securePassword;
                mailAccount.accountType = [emailAccountDic objectForKey:kEMAIL_ACCOUNT_TYPE];
                mailAccount.displayName = [emailAccountDic objectForKey:kEMAIL_ADDRESS];
                mailAccount.signature = EMAIL_SIGNATURE_SENT_FROM;
                mailAccount.emailKeeping = [NSNumber numberWithInt:1];//1 week
                mailAccount.useEncrypted = 1;
                mailAccount.syncSchedule = @"";
                mailAccount.periodSyncSchedule = [NSNumber numberWithInt:1];//default 5 minutes
                mailAccount.useSyncEmail = 1;
                mailAccount.retrivalSize = [NSNumber numberWithInt:30];
                mailAccount.useNotify = 1;
                mailAccount.autoDownloadWifi = 1;
                mailAccount.incomingUserName = [emailAccountDic objectForKey:kEMAIL_INC_USENAME];
                mailAccount.incomingPassword = incSecurePassword ;
                mailAccount.incomingHost = [emailAccountDic objectForKey:kEMAIL_INC_HOST];
                mailAccount.incomingPort = [emailAccountDic objectForKey:kEMAIL_INC_PORT];
                mailAccount.incomingUseSSL = @"0";
                mailAccount.incomingSecurityType = [emailAccountDic objectForKey:kEMAIL_INC_SECURITY_TYPE];
                mailAccount.outgoingUserName = [emailAccountDic objectForKey:kEMAIL_OUT_USENAME];
                mailAccount.outgoingPassword = outSecurePassword;
                mailAccount.outgoingHost = [emailAccountDic objectForKey:kEMAIL_OUT_HOST];
                mailAccount.outgoingPort = [emailAccountDic objectForKey:kEMAIL_OUT_PORT];
                mailAccount.outgoingSecurityType = [emailAccountDic objectForKey:kEMAIL_OUT_SECURITY_TYPE];;
                mailAccount.outgoingRequireAuth = @"";
                mailAccount.storeProtocol = @"";
                mailAccount.pop3Deleteable = 0;
                mailAccount.imapPathPrefix = @"";
                mailAccount.extend1 = [emailAccountDic objectForKey:kEMAIL_DESCRIPTION];
                mailAccount.extend2 = @"";
                
                [self updateMailAccount:mailAccount];
            }
            
            NSDictionary* logDic = @{
                                     LOG_CLASS : NSStringFromClass(self.class),
                                     LOG_CATEGORY: CATEGORY_EMAIL_SETUP_SUCCESS,
                                     LOG_MESSAGE: [NSString stringWithFormat:@"LOG IN EMAIL ACCOUNT SUCCESS"],
                                     LOG_EXTRA1: @"",
                                     LOG_EXTRA2: @""
                                     };
            [[LogFacade share] logInfoWithDic:logDic];
            
            //Backup profile to backup email
            [[ContactFacade share] backupProfile];
            
            //Get email headers
            [self getEmailHeaders:[emailAccountDic objectForKey:kEMAIL_ADDRESS]];
            
        }
        else if([[response objectForKey:kSTATUS_CODE] isEqualToNumber:[NSNumber numberWithInt:2054]])
        {
            [emailLoginDelegate updateEmailAccountToServerFailed:[emailAccountDic objectForKey:kEMAIL_ADDRESS]];
            NSDictionary* logDic = @{
                                     LOG_CLASS : NSStringFromClass(self.class),
                                     LOG_CATEGORY: CATEGORY_EMAIL_SETUP_FAIL,
                                     LOG_MESSAGE: [NSString stringWithFormat:@"LOG IN EMAIL ACCOUNT FAILED ERROR: %@",error],
                                     LOG_EXTRA1: @"",
                                     LOG_EXTRA2: @""
                                     };
            [[LogFacade share] logErrorWithDic:logDic];
        }
        else
        {
            NSError *error = [NSError errorWithDomain:kEMAIL_ERROR_DOMAIN code:-1 userInfo:@{NSLocalizedDescriptionKey:ERROR_SERVER_GOT_PROBLEM}];
            [emailLoginDelegate loginEmailAccountFailedWithError:error];
             if (response)
             {
                // if Token is invalid or expire
                NSInvocationOperation* operation=  [[NSInvocationOperation alloc] initWithTarget:self
                                                                                        selector:@selector(updateEmailAccountToServer:)
                                                                                          object:emailAccountDic];
                NSDictionary* retryDictionary = @{kRETRY_OPERATION:operation,kRETRY_TIME:kRETRY_API_COUNTER,
                                                  kSTATUS_CODE : [response objectForKey:kSTATUS_CODE]};
                [[AppFacade share] downloadTokenAgain:retryDictionary];
             }
            NSDictionary* logDic = @{
                                     LOG_CLASS : NSStringFromClass(self.class),
                                     LOG_CATEGORY: CATEGORY_EMAIL_SETUP_FAIL,
                                     LOG_MESSAGE: [NSString stringWithFormat:@"LOG IN EMAIL ACCOUNT FAILED ERROR: %@",error],
                                     LOG_EXTRA1: @"",
                                     LOG_EXTRA2: @""
                                     };
            [[LogFacade share] logErrorWithDic:logDic];
        }
    }];
}

- (void)resetEmailAccount:(NSString*)username
{
    NSLog(@"%s %@", __PRETTY_FUNCTION__, username);
    [[CWindow share] showLoading:kLOADING_RESETTING];
    
    NSDictionary *resetEmailDic = @{kAPI_REQUEST_METHOD: PUT,
                                     kAPI_REQUEST_KIND: NORMAL,
                                     kMASKINGID: [[ContactFacade share] getMaskingId],
                                     kTOKEN: [[ContactFacade share] getTokentTenant],
                                     kIMSI: [[ContactFacade share] getIMSI],
                                     kIMEI: [[ContactFacade share] getIMEI],
                                     kEMAIL: username
                                     };
    
    [[EmailAdapter share] resetEmailAccount:resetEmailDic
                                   callback:^(BOOL success, NSString *message, NSDictionary *response, NSError *error) {
        [[CWindow share] hideLoading];
        if (success)
        {
            [emailLoginDelegate resetEmailAccountSuccess];
        }
        else
        {
            [emailLoginDelegate resetEmailAccountFailed];
            // if Token is invalid or expire
             if (response){
                NSInvocationOperation* operation=  [[NSInvocationOperation alloc] initWithTarget:self
                                                                                        selector:@selector(resetEmailAccount:)
                                                                                          object:username];
                NSDictionary* retryDictionary = @{kRETRY_OPERATION:operation,
                                                  kRETRY_TIME:kRETRY_API_COUNTER,
                                                  kSTATUS_CODE : [response objectForKey:kSTATUS_CODE]};
                [[AppFacade share] downloadTokenAgain:retryDictionary];
             }
        }
    }];
}

#pragma mark Get Email functions
- (void) startNewSyncSchedule:(NSInteger)syncTime
{
    [loadMoreEmailDelegate syncScheduleGetNewEmails:[self getTimerFromPeriodSyncSchedule:syncTime]];
}

-(void)getEmailHeaders:(NSString *)username
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    NSString* queryCondition = [NSString stringWithFormat:@"fullEmail = '%@'", username];
    MailAccount* mailAccountDB = (MailAccount*)[[DAOAdapter share] getObject:[MailAccount class]
                                                                   condition:queryCondition];
    // Set number of emails in all folder to 0 before getting new email
    NSArray *allFolder = [[EmailFacade share] getAllEmailFolders];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    for (MailFolder *emailFolder in allFolder)
        [defaults setObject:[NSNumber numberWithInteger:0]
                     forKey:[NSString stringWithFormat:@"%ld",(long)emailFolder.folderIndex.integerValue]];
    
    if (!mailAccountDB)
    {
        NSLog(@"Mail Account does not exist in DB");
        return;
    }
    
    int type = [mailAccountDB.accountType intValue];
    
    if (type != 5)
    {//Imap
        NSString *folderJunkName = [self getJunkNameInServerEmailForAccountType:type];
        if ([folderJunkName isEqualToString:kEMAIL_FOLDER_BULK_MAIL] ||
            type == kEMAIL_ACCOUNT_TYPE_HOTMAIL ||
            type == kEMAIL_ACCOUNT_TYPE_GMAIL)
        {
            [self getEmailHeadersForImapYahooInFolder:FOLDER_INBOX
                                          folderIndex:kINDEX_FOLDER_INBOX
                                       folderJunkName:folderJunkName];
        }
        else
        {
            [self getEmailHeadersForImapInFolder:FOLDER_INBOX
                                     folderIndex:kINDEX_FOLDER_INBOX
                                  folderJunkName:folderJunkName];
        }
    }
    else
    {//Pop
        [self getEmailHeadersForPopInFolderIndex:kINDEX_FOLDER_INBOX];
    }
}

-(NSString*) getJunkNameInServerEmailForAccountType:(int)accountType{

    NSString *folderJunkName = @"";
    
    switch (accountType)
    {
        case 0:{//Microsoft exchange
            folderJunkName = kEMAIL_FOLDER_JUNK_EMAIL;
        }break;
        case 1:{//gmail
            folderJunkName = kEMAIL_FOLDER_GMAIL_SPAM;
        }
            break;
        case 2:{//yahoo
            folderJunkName = kEMAIL_FOLDER_BULK_MAIL;
        }
            break;
        case 3:{//hotmail
            folderJunkName = FOLDER_JUNK;
        }
            break;
        case 4:{//Other IMAP
            folderJunkName = @"";
            
        }
            break;
            
        default:
            break;
    }
    
    return folderJunkName;
}

- (void)getEmailHeadersForImapYahooInFolder:(NSString *)folderName
                                folderIndex:(NSInteger)folderIndex
                             folderJunkName:(NSString *)folderJunkName
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [[CWindow share] showLoading:kLOADING_LOADING];
    NSOperationQueue *operationQueue = [NSOperationQueue new];
    [[EmailAdapter share] getEmailsHeaderForImap:folderName
                                  numberMessages:kNUMBER_OF_EMAIL_TO_LOAD_10
                                        callback:^(BOOL success, NSArray *messages, NSError *error) {
        if (folderIndex == kINDEX_FOLDER_INBOX)
            [[CWindow share] hideLoading];
        
        if (success)
        {
            NSDictionary* logDic = @{
                                     LOG_CLASS : NSStringFromClass(self.class),
                                     LOG_CATEGORY: CATEGORY_EMAIL_GET_IMAP_FIRST_TIME_SUCCESS,
                                     LOG_MESSAGE: [NSString stringWithFormat:@"GET IMAP FIRST TIME SUCCESS"],
                                     LOG_EXTRA1: @"",
                                     LOG_EXTRA2: @""
                                     };
            [[LogFacade share] logInfoWithDic:logDic];
            //Save message headers to DB

            MCOIMAPMessage *messageHeader;

            if (messages.count > 0)
            {
                for (int i = 0; i < messages.count; i++)
                {
                    messageHeader = messages[i];

                    //Store oldest and newest email
                    if (i == 0)
                    {
                        if ([folderName isEqualToString:FOLDER_INBOX])
                        {
                            [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%u", messageHeader.uid]
                                                                      forKey:kEMAIL_INBOX_NEWEST];
                        }
                        else
                        {
                            [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%u", messageHeader.uid]
                                                                      forKey:kEMAIL_JUNK_NEWEST];
                        }

                        [[NSUserDefaults standardUserDefaults] synchronize];
                    }

                    if (i == messages.count - 1)
                    {
                        if ([folderName isEqualToString:FOLDER_INBOX])
                        {
                            [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%u", messageHeader.uid]
                                                                      forKey:kEMAIL_INBOX_OLDEST];
                        }
                        else
                        {
                            [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%u", messageHeader.uid]
                                                                      forKey:kEMAIL_JUNK_OLDEST];
                        }

                        [[NSUserDefaults standardUserDefaults] synchronize];
                    }

                    [self insertEmailHeaderForImap:folderIndex
                                           headers:messageHeader];

                    NSLog(@"messageUID: %d", messageHeader.uid);
                   //Get email details
                    NSDictionary *paramsMailDetail = [NSDictionary dictionaryWithObjectsAndKeys:folderName, kFOLDER_NAME, [NSNumber numberWithInteger:folderIndex], kFOLDER_INDEX, [NSNumber numberWithInt:messageHeader.uid], kUID, [NSNumber numberWithInt:i], kEMAIL_COUNT, [NSNumber numberWithInteger:messages.count], kEMAIL_TOTAL, nil];
                    NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self
                                                                                            selector:@selector(getEmailDetailForImapInFolder:)
                                                                                              object:paramsMailDetail];
                    [operationQueue addOperation:operation];

                   //Download attachment
                    if ([messageHeader.attachments count] > 0)
                    {
                        [self downloadAttachmentsImapWithMessage:messageHeader
                                                          folder:folderName
                                                    isReDownLoad:NO];
                    }

                    if (i == messages.count - 1 && folderIndex == kINDEX_FOLDER_INBOX)
                    {
                        if (emailLoginDelegate)
                            [emailLoginDelegate loginEmailAccountSuccess];
                        else
                            [loadMoreEmailDelegate loadMoreEmailsSuccess];
                    }
                }
            }
            
            if (folderIndex != kINDEX_FOLDER_JUNK)
            {
                // Get Junk after inbox done
                dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
                    [self getEmailHeadersForImapYahooInFolder:folderJunkName
                                                  folderIndex:kINDEX_FOLDER_JUNK
                                               folderJunkName:folderJunkName];
                });
            }
        }
        else
        {
            if (folderIndex != kINDEX_FOLDER_JUNK)
                [[CAlertView new] showError:[NSString stringWithFormat:mError_CanNotGetEmailInServerFolder, folderName]];
            
            NSDictionary* logDic = @{
                                     LOG_CLASS : NSStringFromClass(self.class),
                                     LOG_CATEGORY: CATEGORY_EMAIL_GET_IMAP_FIRST_TIME_FAILED,
                                     LOG_MESSAGE: [NSString stringWithFormat:@"CATEGORY EMAIL GET IMAP FIRST TIME FAILED ERROR: %@",error],
                                     LOG_EXTRA1: @"",
                                     LOG_EXTRA2: @""
                                     };
            [[LogFacade share] logErrorWithDic:logDic];
        }
    }];
}

- (void)getEmailHeadersForImapInFolder:(NSString *)folderName
                           folderIndex:(NSInteger)folderIndex
                        folderJunkName:(NSString *)folderJunkName
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [[CWindow share] showLoading:kLOADING_LOADING];
    NSOperationQueue *operationQueue = [NSOperationQueue new];
    [[EmailAdapter share] getEmailsHeaderForImapInFolder:folderName
                                  numberMessages:kNUMBER_OF_EMAIL_TO_LOAD_10
                                        callback:^(BOOL success, NSArray *messages, NSError *error) {
        if (folderIndex == kINDEX_FOLDER_INBOX)
            [[CWindow share] hideLoading];
        if (success)
        {
            NSDictionary* logDic = @{
                                     LOG_CLASS : NSStringFromClass(self.class),
                                     LOG_CATEGORY: CATEGORY_EMAIL_GET_IMAP_FIRST_TIME_SUCCESS,
                                     LOG_MESSAGE: [NSString stringWithFormat:@"GET IMAP FIRST TIME SUCCESS"],
                                     LOG_EXTRA1: @"",
                                     LOG_EXTRA2: @""
                                     };
            [[LogFacade share] logInfoWithDic:logDic];
            //Save message headers to DB

            MCOIMAPMessage *messageHeader;

            if (messages.count > 0)
            {
                for (int i = 0; i < messages.count; i++)
                {
                    messageHeader = messages[i];
                    //Store oldest and newest email
                    if (i == 0)
                    {
                        if ([folderName isEqualToString:FOLDER_INBOX])
                            [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%u",messageHeader.uid]
                                                                      forKey:kEMAIL_INBOX_NEWEST];
                        else
                            [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%u",messageHeader.uid]
                                                                      forKey:kEMAIL_JUNK_NEWEST];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                    }
                    if (i == messages.count - 1)
                    {
                        if ([folderName isEqualToString:FOLDER_INBOX])
                            [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%u",messageHeader.uid]
                                                                      forKey:kEMAIL_INBOX_OLDEST];
                        else
                            [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%u",messageHeader.uid]
                                                                      forKey:kEMAIL_JUNK_OLDEST];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                    }

                    [self insertEmailHeaderForImap:folderIndex
                                           headers:messageHeader];

                    NSLog(@"messageUID: %d", messageHeader.uid);
                   //Get email details
                    NSDictionary *paramsMailDetail = [NSDictionary dictionaryWithObjectsAndKeys:folderName, kFOLDER_NAME, [NSNumber numberWithInteger:folderIndex], kFOLDER_INDEX, [NSNumber numberWithInt:messageHeader.uid], kUID, [NSNumber numberWithInt:i], kEMAIL_COUNT, [NSNumber numberWithInteger:messages.count], kEMAIL_TOTAL, nil];
                    NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self
                                                                                            selector:@selector(getEmailDetailForImapInFolder:)
                                                                                              object:paramsMailDetail];
                    [operationQueue addOperation:operation];

                   //Download attachment
                    if ([messageHeader.attachments count] > 0)
                        [self downloadAttachmentsImapWithMessage:messageHeader folder:folderName isReDownLoad:NO];
                    
                    if (i == messages.count - 1 && folderIndex == kINDEX_FOLDER_INBOX)
                    {
                        if (emailLoginDelegate)
                            [emailLoginDelegate loginEmailAccountSuccess];
                        else
                            [loadMoreEmailDelegate loadMoreEmailsSuccess];
                    }
                }
                
                if (folderIndex != kINDEX_FOLDER_JUNK)
                {
                    // Get Junk after inbox done
                    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
                        [self getEmailHeadersForImapInFolder:folderJunkName
                                                 folderIndex:kINDEX_FOLDER_JUNK
                                              folderJunkName:folderJunkName];
                    });
                }
            }
        }
        else
        {
            if (folderIndex != kINDEX_FOLDER_JUNK)
                [[CAlertView new] showError:[NSString stringWithFormat:mError_CanNotGetEmailInServerFolder, folderName]];
            NSDictionary* logDic = @{
                                     LOG_CLASS : NSStringFromClass(self.class),
                                     LOG_CATEGORY: CATEGORY_EMAIL_GET_IMAP_FIRST_TIME_FAILED,
                                     LOG_MESSAGE: [NSString stringWithFormat:@"CATEGORY EMAIL GET IMAP FIRST TIME FAILED ERROR: %@",error],
                                     LOG_EXTRA1: @"",
                                     LOG_EXTRA2: @""
                                     };
            [[LogFacade share] logErrorWithDic:logDic];
        }
    }];
}

- (void)downloadAttachmentsImapWithMessage:(MCOIMAPMessage *)message
                                    folder:(NSString *)folderName
                              isReDownLoad:(BOOL)isReDownLoad
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSOperationQueue *myQueue = [[NSOperationQueue alloc] init];
    [myQueue addOperationWithBlock:^{
        NSLog(@"Attachment count for message id %d: %lu", message.uid, (unsigned long)message.attachments.count);

        if ([message.attachments count] > 0)
        {
            //Get all attachments in DB
            NSArray *localAttachment = [self getMailAttachmentsFromUid:[NSString stringWithFormat:@"%u",message.uid]];
            for (int k = 0; k < [message.attachments count]; k++)
            {
                MCOIMAPPart *part = [message.attachments
                                     objectAtIndex:k];
                //Check existing attachment for email or not.
                BOOL existed = NO;
                if (localAttachment.count > 0) {
                    for (MailAttachment *mailAttachment in localAttachment) {
                        if ([mailAttachment.attachmentName rangeOfString:[NSString stringWithFormat:@"%i_%@", message.uid, part.partID]].location != NSNotFound) {
                            existed = YES;
                        }
                    }
                }
                
                if (!existed)//Only download attachment has not downloaded.
                [[EmailAdapter share] downloadAttachmentsForImapWithFolder:folderName
                                                                       uid:message.uid
                                                                    partId:part.partID
                                                                  encoding:part.encoding
                                                                  callback:^(BOOL success, NSData *data, NSError *error) {
                    if (success)
                    {
                        NSLog(@"Downloaded attachment");
                        // add this to defense duplicate attachment when it has same name, same size
                        NSString *attachmentName = [NSString stringWithFormat:@"%i_%@_%@", message.uid, part.partID, part.filename];
                       //Save attachment to local
                        [self setEmailAttachment:attachmentName data:data];

                       //Save attachment info to DB
                        NSString *queryCondition = [NSString stringWithFormat:@"attachmentName = '%@'", attachmentName];
                        MailAttachment *mailAttachment = (MailAttachment *)[[DAOAdapter share] getObject:[MailAttachment class]
                                                                                               condition:queryCondition];

                        if (!mailAttachment)
                        {
                            mailAttachment  = [MailAttachment new];
                            mailAttachment.mailHeaderUID = [NSString stringWithFormat:@"%d", message.uid];
                            mailAttachment.attachmentName = attachmentName;
                            mailAttachment.attachmentLocalPath = @"";
                            mailAttachment.attachmentSize = [NSNumber numberWithInt:part.decodedSize];
                            mailAttachment.mineType = @"";
                            [[DAOAdapter share] commitObject:mailAttachment];

                            if (isReDownLoad)
                            {
                                [emailDetailDelegate showEmailAttachments];
                            }
                        }
                        else
                        {
                            NSLog(@"MailAttachment object existed with attachment name: %@", attachmentName);
                        }

                        //Update attachment for MailHeader
                        MailHeader *mailHeader = [self getMailHeaderFromUid:[NSString stringWithFormat:@"%d", message.uid]];
                        
                        if (mailHeader)
                        {
                            mailHeader.attachNumber = [NSNumber numberWithInteger:[message.attachments count]];
                            [self saveEmailHeader:mailHeader];
                        }

                        if (k == message.attachments.count - 1)
                        {
                            mailHeader = [self getMailHeaderFromUid:[NSString stringWithFormat:@"%d", message.uid]];
                            mailHeader.isDownloaded = [NSNumber numberWithInt:1];
                            [self saveEmailHeader:mailHeader];
                        }
                    }
                }];
            }
        }
    }];
}

- (void) getSingleEmailDetailForImapWithHeader:(MailHeader*)emailHeader
{
    NSLog(@"%s",__PRETTY_FUNCTION__);
    [[CWindow share] showLoading:kLOADING_LOADING];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        NSString *folderName;

        if (emailHeader.folderIndex.intValue == kINDEX_FOLDER_INBOX)
        {
            folderName = FOLDER_INBOX;
        }
        else if (emailHeader.folderIndex.intValue == kINDEX_FOLDER_JUNK)
        {
            MailAccount *mailAccount = [[EmailFacade share]getMailAccount:[[EmailFacade share]getEmailAddress]];
            folderName = [self getJunkNameInServerEmailForAccountType:mailAccount.accountType.intValue];
        }
        else
        {
            folderName = [self getMailFolderFromIndex:emailHeader.uid.intValue].folderName;
        }

        NSLog(@"UID Get Detail: %d", emailHeader.uid.intValue);
        [self getConfigurationImapAccount];
        [[EmailAdapter share] getEmailsDetailForImap:folderName.uppercaseString
                                                 uid:(int)emailHeader.uid.intValue
                                            callback:^(BOOL success, NSData *messagesContent, NSError *error) {
            if (success)
            {
                MCOMessageParser *messageParser = [MCOMessageParser messageParserWithData:messagesContent];
                [self insertEmailDetailWithFolder:emailHeader.folderIndex.intValue
                                              uid:emailHeader.uid
                                   messageContent:messageParser];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [[CWindow share] hideLoading];
                    [emailDetailDelegate getEmailDetailSucceeded];
                });
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    [[CWindow share] hideLoading];
                    if (error)
                        [emailDetailDelegate getEmailDetailFailed:error.localizedDescription];
                    else
                        [emailDetailDelegate getEmailDetailFailed:NO_INTERNET_CONNECTION_TRY_LATER];
                });
            }
        }];
    });
}

-(void)getEmailDetailForImapInFolder:(NSDictionary*)dictionary{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [loadMoreEmailDelegate showLoadingView];
    }];
    
    
    NSString *folderName = [dictionary objectForKey:kFOLDER_NAME] ;
    NSInteger folderIndex = [[dictionary objectForKey:kFOLDER_INDEX] integerValue];
    NSInteger uid = [[dictionary objectForKey:kUID] integerValue];
    NSInteger messageCount = [[dictionary objectForKey:kEMAIL_COUNT] integerValue];
    NSInteger messageTotal = [[dictionary objectForKey:kEMAIL_TOTAL] integerValue];
    NSLog(@"UID Get Detail: %d", (int)uid);
    [[EmailAdapter share] getEmailsDetailForImap:folderName
                                             uid:(int)uid
                                        callback:^(BOOL success, NSData *messagesContent, NSError *error) {

        if (success)
        {
            MCOMessageParser *messageParser = [MCOMessageParser messageParserWithData:messagesContent];
            [self insertEmailDetailWithFolder:folderIndex
                                          uid:[NSString stringWithFormat:@"%d",(int)uid]
                               messageContent:messageParser];
        }
        if (messageCount == messageTotal - 1 || messageTotal == 0)
        {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [[CWindow share] hideLoading];
                // Main thread work (UI usually)
                //call delegate success
                if ([folderName isEqualToString:FOLDER_INBOX])
                    [loadMoreEmailDelegate loadMoreEmailDetailSuccess:[NSString stringWithFormat:@"%d",(int)uid]];
            });
        }
        
    } ];
    
}

-(void)getEmailHeadersForPopInFolderIndex:(NSInteger)folderIndex{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    NSOperationQueue *operationQueue = [NSOperationQueue new];
    
    [[CWindow share] showLoading:kLOADING_LOADING];
    [[EmailAdapter share] getAllEmailsForPop:^(BOOL success, NSArray *messages, NSError *error) {
        [[CWindow share] hideLoading];
        if (success)
        {
     
            NSInteger totalEmails = messages.count;
            NSInteger numberEmailToLoad = kNUMBER_OF_EMAIL_TO_LOAD_10;
            NSInteger indexEmailWillBeLoaded = 0;
            
            if (totalEmails > numberEmailToLoad)
                indexEmailWillBeLoaded = totalEmails - numberEmailToLoad;
            else
                indexEmailWillBeLoaded = totalEmails;
            
            //Save message headers to DB
            MCOPOPMessageInfo *messageInfo;
            
            __block int count = 0;
            
            
            for (int i = (int)messages.count; i > indexEmailWillBeLoaded; i--) {
        
                messageInfo = messages[i-1];
                
                [[CWindow share] showLoading:kLOADING_LOADING];
                [[EmailAdapter share] getEmailsHeaderAtIndexForPop:i
                                                          callback:^(BOOL success, MCOMessageHeader *messageHeader, NSError *error) {
                    
                    [[CWindow share] hideLoading];
                    
                    count += 1;
                    
                    //call delegate success
                    if (count == (int)numberEmailToLoad)
                    {//call when the last message
                        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                            if (emailLoginDelegate)
                                [emailLoginDelegate loginEmailAccountSuccess];
                            else
                                [loadMoreEmailDelegate loadMoreEmailsSuccess];
                        }];
                    }
                    
                    if (success)
                    {
                        //Store newest oldest email
                        if (i == messages.count - 1)
                            [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%f",[messageHeader.date timeIntervalSince1970]] forKey:kEMAIL_INBOX_NEWEST];
                        if (count == (int)numberEmailToLoad)
                            [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%f",[messageHeader.date timeIntervalSince1970]] forKey:kEMAIL_INBOX_OLDEST];

                        [[NSUserDefaults standardUserDefaults] synchronize];
                        
                        //Insert Email header
                        [self insertEmailHeaderForPop:folderIndex
                                              headers:messageHeader
                                           uidMessage:[NSString stringWithFormat:@"%d",i]];
                        //Get email details
                        NSLog(@"messageUID: %@", messageInfo.uid);
                        NSLog(@"messageIndex: %d", i);
                        
                        NSDictionary *paramsMailDetail = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:folderIndex], kFOLDER_INDEX, messageInfo.uid, kUID, [NSNumber numberWithInt:i], kEMAIL_INDEX ,[NSNumber numberWithInt:count], kEMAIL_COUNT, [NSNumber numberWithInteger:numberEmailToLoad], kEMAIL_TOTAL, nil];
                        NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self
                                                                                                selector:@selector(getEmailDetailForPopInFolder:)
                                                                                                  object:paramsMailDetail];
                        [operationQueue addOperation:operation];
                    }
                }];
            }
        }
    }];
}

-(void)getEmailDetailForPopInFolder:(NSDictionary *)dictionary
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [loadMoreEmailDelegate showLoadingView];

    NSInteger folderIndex = [[dictionary objectForKey:kFOLDER_INDEX] integerValue];
    //NSString *uid = [dictionary objectForKey:kUID];
    int messageIndex = [[dictionary objectForKey:kEMAIL_INDEX] intValue];
    int count = [[dictionary objectForKey:kEMAIL_COUNT] intValue];
    int totalMessageLoad = [[dictionary objectForKey:kEMAIL_TOTAL] intValue];
    NSLog(@"messageIndex: %d", messageIndex);
    
    [[EmailAdapter share] getEmailsDetailAtIndexForPop:messageIndex
                                              callback:^(BOOL success, NSData *messagesContent, NSError *error) {
        if (success)
        {
            MCOMessageParser *parser = [MCOMessageParser messageParserWithData:messagesContent];
            //Insert email detail to DB
            [self insertEmailDetailWithFolder:folderIndex
                                          uid:[NSString stringWithFormat:@"%d",messageIndex]
                               messageContent:parser];
            //Save attachment to local
            NSLog(@"Attachment count for message id %d: %lu", messageIndex, (unsigned long)parser.attachments.count);
            if (parser.attachments.count > 0) {
                for (int i = 0; i < parser.attachments.count; i++)
                {
                    MCOAttachment *part = parser.attachments[i];
                    
                    NSString *attachmentName = [NSString stringWithFormat:@"%d_%@", messageIndex, part.filename];
                    //Save attachment to local
                    [self setEmailAttachment:attachmentName data:part.data];
                    //Save attachment info to DB
                    NSString* queryCondition = [NSString stringWithFormat:@"attachmentName = '%@'", attachmentName];
                    MailAttachment* mailAttachment = (MailAttachment*)[[DAOAdapter share] getObject:[MailAttachment class]
                                                                                          condition:queryCondition];
                    if (!mailAttachment) {
                        mailAttachment  = [MailAttachment new];
                        mailAttachment.mailHeaderUID = [NSString stringWithFormat:@"%d", messageIndex];
                        mailAttachment.attachmentName = attachmentName;
                        mailAttachment.attachmentLocalPath = @"";
                        mailAttachment.attachmentSize = [NSNumber numberWithUnsignedLong:[[EmailAdapter share] getEmailAttachmentFileSize:attachmentName]];//set default.
                        mailAttachment.mineType = @"";
                        [[DAOAdapter share] commitObject:mailAttachment];
                        
                    }
                    else
                    {
                        NSLog(@"MailAttachment object existed with attachment name: %@", attachmentName);
                    }
                    //Update attachment for MailHeader
                    MailHeader* mailHeader = [self getMailHeaderFromUid:[NSString stringWithFormat:@"%d",messageIndex]];
                    if (mailHeader)
                    {
                        mailHeader.attachNumber = [NSNumber numberWithInteger:parser.attachments.count];
                        [self saveEmailHeader:mailHeader];
                    }
                    if (i == parser.attachments.count - 1)
                    {
                        NSLog(@"Finished download all attachments for email id %d",messageIndex);
                        mailHeader.isDownloaded = [NSNumber numberWithInt:1];
                        
                        [self saveEmailHeader:mailHeader];
                    }
                    
                }
            }
        }
        
        if (count == totalMessageLoad || totalMessageLoad == 0) {
            [[CWindow share] hideLoading];
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                //call delegate success
                [loadMoreEmailDelegate loadMoreEmailsSuccess];
            }];
        }
    }];
}

- (void)insertEmailHeaderForImap:(NSInteger)folder headers:(MCOIMAPMessage *)message{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    NSString *to = @"";
    NSString *cc = @"";
    NSString *bcc = @"";
    
    MCOAddress *emailAddress;
    
    for (NSInteger i = 0; i < message.header.to.count; i++)
    {
        emailAddress = message.header.to[i];
        to = [NSString stringWithFormat:@"%@, %@", to, emailAddress.mailbox];
    }
    if (![to isEqualToString:@""])
        to = [[to substringToIndex:to.length] substringFromIndex:2];
    
    for (NSInteger i = 0; i < message.header.cc.count; i++)
    {
        emailAddress = message.header.cc[i];
        cc = [NSString stringWithFormat:@"%@, %@", cc, emailAddress.mailbox];
    }
    if (![cc isEqualToString:@""])
        cc = [[cc substringToIndex:cc.length] substringFromIndex:2];
    
    for (NSInteger i = 0; i < message.header.bcc.count; i++)
    {
        emailAddress = message.header.bcc[i];
        bcc = [NSString stringWithFormat:@"%@, %@", bcc, emailAddress.mailbox];
    }
    if (![bcc isEqualToString:@""])
        bcc = [[bcc substringToIndex:bcc.length] substringFromIndex:2];
    
    NSString *displayName, *subject;
    if (message.header.from.displayName == nil)
        displayName = message.header.from.mailbox;
    else
        displayName = message.header.from.displayName;
    
    subject = message.header.subject;
    if (message.header.subject == nil)
        subject = NSLocalizedString(NO_SUBJECT,nil);
    
    MailHeader* mailHeader = [self getMailHeaderFromUid:[NSString stringWithFormat:@"%d",message.uid]];
    if (!mailHeader) {
         mailHeader  = [MailHeader new];
         mailHeader.mailAccountId = @"";
         mailHeader.uid = [NSString stringWithFormat:@"%d", message.uid];
         mailHeader.emailFrom = message.header.from.mailbox;
         mailHeader.emailTo = to;
         mailHeader.emailCC = cc;
         mailHeader.emailBCC = bcc;
         mailHeader.subject = subject;
         mailHeader.shortDesc = @"";
         mailHeader.emailStatus = [NSNumber numberWithInteger:message.flags];
         mailHeader.folderIndex = [NSNumber numberWithInteger:folder];
         mailHeader.attachNumber = [NSNumber numberWithInteger:message.attachments.count] ;
         mailHeader.isDownloaded = 0;
         mailHeader.isImportant = [NSNumber numberWithInt:0];
         mailHeader.isReplied = [NSNumber numberWithInt:0];
         mailHeader.isForwarded = [NSNumber numberWithInt:0];
         mailHeader.isEncrypted = [NSNumber numberWithInt:0];
         mailHeader.sendDate = [NSNumber numberWithInt:[message.header.date timeIntervalSince1970]];
         mailHeader.receiveDate = [NSNumber numberWithInt:[[NSDate date] timeIntervalSince1970]];
         mailHeader.extend1 = displayName;
         mailHeader.extend2 = @"";
        
        [self saveEmailHeader:mailHeader];
        [self increaseHeaderNumber:mailHeader];

    }else{
         NSLog(@"MailHeader object existed with uid: %d", message.uid);
    }
}

- (void)insertEmailDetailWithFolder:(NSInteger)folderIndex
                                uid:(NSString *)uid
                     messageContent:(MCOMessageParser *)message
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        NSString *msgHTMLBody = @"";
        NSString *plainTextBody = @"";

        if (message.htmlInlineAttachments.count > 0)
        {
            NSArray *arrayInlineAttachment = [message htmlInlineAttachments];

            for (NSInteger j = 0; j < message.htmlInlineAttachments.count; j++)
            {
                MCOAttachment *InlineAttachmentsItem = arrayInlineAttachment[j];
                NSData *imageData = InlineAttachmentsItem.data;
                NSString *base64String = [Base64Security generateBase64String:imageData];
                base64String = [NSString stringWithFormat:@"data:image/jpg;base64,%@", base64String];
                msgHTMLBody = [message htmlBodyRendering];
                msgHTMLBody = [msgHTMLBody stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"cid:%@", InlineAttachmentsItem.contentID]
                                                                     withString:base64String];
            }

            plainTextBody = [message plainTextBodyRendering];
        }
        else
        {
            msgHTMLBody = [message htmlBodyRendering];
            plainTextBody = [message plainTextBodyRendering];
        }

        //Insert email details
        MailContent *mailContent = [self getMailContentFromMailHeaderUid:uid];

        if (!mailContent)
        {
            mailContent  = [MailContent new];
            mailContent.emailHeaderUID = [NSString stringWithFormat:@"%@", uid];
            mailContent.htmlContent = msgHTMLBody;
            mailContent.mineType = @"";
            [self saveEmailContent:mailContent];
        }

        //Update shortDescrtion for MailHeader
        MailHeader *mailHeader = [self getMailHeaderFromUid:uid];
        if (mailHeader)
        {
            mailHeader.shortDesc = plainTextBody;
            [self saveEmailHeader:mailHeader];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                 [loadMoreEmailDelegate loadMoreEmailDetailSuccess:mailHeader.uid];
            });
        }
    });
}

- (void)insertEmailHeaderForPop:(NSInteger)folder
                        headers:(MCOMessageHeader *)message
                     uidMessage:(NSString*)uid
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    NSString *to = @"";
    NSString *cc = @"";
    NSString *bcc = @"";
    
    MCOAddress *emailAddress;
    
    for (NSInteger i = 0; i < message.to.count; i++)
    {
        emailAddress = message.to[i];
        to = [NSString stringWithFormat:@"%@, %@", to, emailAddress.mailbox];
    }
    if (![to isEqualToString:@""])
        to = [[to substringToIndex:to.length] substringFromIndex:2];
    
    for (NSInteger i = 0; i < message.cc.count; i++)
    {
        emailAddress = message.cc[i];
        cc = [NSString stringWithFormat:@"%@, %@", cc, emailAddress.mailbox];
    }
    if (![cc isEqualToString:@""])
        cc = [[cc substringToIndex:cc.length] substringFromIndex:2];
    
    for (NSInteger i = 0; i < message.bcc.count; i++)
    {
        emailAddress = message.bcc[i];
        bcc = [NSString stringWithFormat:@"%@, %@", bcc, emailAddress.mailbox];
    }
    if (![bcc isEqualToString:@""])
        bcc = [[bcc substringToIndex:bcc.length] substringFromIndex:2];
    
    NSString *displayName, *subject;
    
    if (message.from.displayName == nil)
        displayName = message.from.mailbox;
    else
        displayName = message.from.displayName;
    
    subject = message.subject;
    if (message.subject == nil)
        subject = NSLocalizedString(NO_SUBJECT,nil);
    
    MailHeader *mailHeader = [self getMailHeaderFromUid:uid];
    if (!mailHeader) {
        mailHeader  = [MailHeader new];
        mailHeader.mailAccountId = @"";
        mailHeader.uid = uid;
        mailHeader.emailFrom = message.from.mailbox;
        mailHeader.emailTo = to;
        mailHeader.emailCC = cc;
        mailHeader.emailBCC = bcc;
        mailHeader.subject = subject;
        mailHeader.shortDesc = @"";
        mailHeader.emailStatus = [NSNumber numberWithInt:0];//no value at this step
        mailHeader.folderIndex = [NSNumber numberWithInteger:folder];
        mailHeader.attachNumber =  [NSNumber numberWithInt:0]; ;//no value at this step
        mailHeader.isDownloaded = [NSNumber numberWithInt:1];
        mailHeader.isImportant = [NSNumber numberWithInt:0];
        mailHeader.isReplied = [NSNumber numberWithInt:0];
        mailHeader.isForwarded = [NSNumber numberWithInt:0];
        mailHeader.isEncrypted = [NSNumber numberWithInt:0];
        mailHeader.sendDate = [NSNumber numberWithInt:[message.date timeIntervalSince1970]];
        mailHeader.receiveDate = [NSNumber numberWithInt:[[NSDate date] timeIntervalSince1970]];
        mailHeader.extend1 = displayName;
        mailHeader.extend2 = @"";
        
        [self saveEmailHeader:mailHeader];
        [self increaseHeaderNumber:mailHeader];
        
    }else{
        NSLog(@"MailHeader object existed with uid: %@", uid);
    }
}

-(NSString*)decryptString:(NSString *)strEncoded
{
    NSData* decodedData = [Base64Security decodeBase64String:strEncoded];
    decodedData = [[AppFacade share] decryptDataLocally:decodedData];
    NSString *decodedString = [[NSString alloc] initWithData:decodedData encoding:NSUTF8StringEncoding];
    return decodedString;
}

-(NSString*)encryptString:(NSString *)normalString
{
    NSData* dataLocally = [[AppFacade share] encryptDataLocally:[normalString dataUsingEncoding:NSUTF8StringEncoding]];
    NSString *secureString = [Base64Security generateBase64String:dataLocally];
    return secureString;
}

-(NSMutableArray*) getEmailHeadersWithOrderBy:(BOOL)isDescending
                                     inFolder:(NSInteger) folderIndex
                                        limit:(int)limit
                                    oldestUID:(NSString *)oldestUID
                                     isGetOld:(BOOL)isGetOld
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    MailHeader *emailHeader = [self getMailHeaderFromUid:oldestUID];
    NSInteger sendDate;
    if (!emailHeader)
        sendDate = isGetOld? MAXFLOAT : 0;
    else
        sendDate = emailHeader.sendDate.integerValue;
    NSString* queryCondition;
    if (isGetOld)
    {
        queryCondition = [NSString stringWithFormat:@"folderIndex = '%ld' AND emailStatus != '%d' AND sendDate < '%ld'", (long)folderIndex, 2,  (long)sendDate];
    }
    else
    {
        queryCondition = [NSString stringWithFormat:@"folderIndex = '%ld' AND emailStatus != '%d' AND sendDate > '%ld'", (long)folderIndex, 2,  (long)sendDate];
    }
    NSArray *fectchEmail = [[DAOAdapter share] getObjects:[MailHeader class]
                                                condition:queryCondition
                                                  orderBy:@"sendDate"
                                             isDescending:isDescending
                                                    limit:limit];
    NSMutableArray *arrayEmailHeader = [NSMutableArray new];
    for (MailHeader *mailHeader in fectchEmail)
    {
        mailHeader.subject = [self decryptString:mailHeader.subject];
        if (mailHeader.shortDesc.length > 0) {
            mailHeader.shortDesc = [self decryptString:mailHeader.shortDesc];
        }
        [arrayEmailHeader addObject:mailHeader];
    }
    return arrayEmailHeader;
}

#pragma mark get MORE emails functions
-(void) getMoreEmailHeaders{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    dispatch_async(dispatch_get_main_queue(), ^(void){
        [[CWindow share] showLoading:kLOADING_LOADING];
    });
    NSString *emailAddress = [self getEmailAddress];
    MailAccount *mailAccount = [self getMailAccount:emailAddress];
    if ([mailAccount.accountType intValue] != 5) {//IMAP
        NSString *folderJunk  = [self getJunkNameInServerEmailForAccountType:[mailAccount.accountType intValue]];
        
        [self getConfigurationImapAccount];
        [self getMoreEmailsForImapInFolder:kINDEX_FOLDER_INBOX
                              folderServer:FOLDER_INBOX
                            folderJunkName:folderJunk];//Inbox
        
    }else{//POP accountType = 5
        [self getConfigurationPopAccount];
        [self getMoreEmailsForPopInFolder:FOLDER_INBOX folderIndex:1];//folderIndex is folder to save into DB
    }
}

-(void)getMoreEmailsForImapInFolder:(NSInteger)folderIndex
                       folderServer:(NSString*)folderName
                     folderJunkName:(NSString *)folderJunkName
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    //Get more email
    
    int oldestUID;
    if ([folderName isEqualToString:FOLDER_INBOX])
        oldestUID = [[[NSUserDefaults standardUserDefaults] stringForKey:kEMAIL_INBOX_OLDEST] intValue];
    else
        oldestUID = [[[NSUserDefaults standardUserDefaults] stringForKey:kEMAIL_JUNK_OLDEST] intValue];
    
    [[CWindow share] showLoading:kLOADING_LOADING];
    
    NSLog(@"Oldest UID %d", oldestUID);
    
    NSOperationQueue *operationQueue = [[NSOperationQueue alloc] init];
    [[EmailAdapter share] getOldEmailsHeaderForImap:folderName
                                            fromUID:(int)oldestUID
                                     numberMessages:kNUMBER_OF_EMAIL_TO_LOAD_10
                                           callback:^(BOOL success, NSArray *messages, NSError *error) {
        if (success)
        {
            NSDictionary* logDic = @{
                                     LOG_CLASS : NSStringFromClass(self.class),
                                     LOG_CATEGORY: CATEGORY_EMAIL_GET_OLD_IMAP_SUCCESS,
                                     LOG_MESSAGE: [NSString stringWithFormat:@"GET OLD IMAP SUCCESS"],
                                     LOG_EXTRA1: @"",
                                     LOG_EXTRA2: @""
                                     };
            [[LogFacade share] logInfoWithDic:logDic];

            //Save message headers to DB
            
            MCOIMAPMessage *messageHeader;
            NSNumber *indexOfFolder;
            NSNumber *messageUID;
            NSNumber *messageCount;
            NSNumber *totalMessage;
            if (messages.count > 0)
            {
                for (int i = 0 ;i < messages.count; i++)
                {
                    messageHeader = messages[i];
                    
                    if (i == messages.count - 1) {
                        if ([folderName isEqualToString:FOLDER_INBOX])
                            [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%u",messageHeader.uid]
                                                                      forKey:kEMAIL_INBOX_OLDEST];
                        else
                            [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%u",messageHeader.uid]
                                                                      forKey:kEMAIL_JUNK_OLDEST];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                    }
                    
                    [self insertEmailHeaderForImap:folderIndex headers:messageHeader];
                    
                    indexOfFolder = [NSNumber numberWithInteger:folderIndex];
                    messageUID = [NSNumber numberWithInt:messageHeader.uid];
                    NSLog(@"messageUID: %@", messageUID);
                    messageCount = [NSNumber numberWithInt:i];
                    totalMessage = [NSNumber numberWithInteger:messages.count];
                    NSDictionary *paramsMailDetail = [NSDictionary dictionaryWithObjectsAndKeys:folderName, kFOLDER_NAME, indexOfFolder, kFOLDER_INDEX, messageUID, kUID, messageCount, kEMAIL_COUNT, totalMessage, kEMAIL_TOTAL, nil];
                    NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self
                                                                                            selector:@selector(getEmailDetailForImapInFolder:)
                                                                                              object:paramsMailDetail];
                    
                    [operationQueue addOperation:operation];
                    //Download attachment
                    if ([messageHeader.attachments count] > 0)
                        [self downloadAttachmentsImapWithMessage:messageHeader folder:folderName isReDownLoad:NO];
                
                }
            }
            if ([folderName isEqualToString:FOLDER_INBOX])
            {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
                    if (folderJunkName.length > 0)
                        [self getMoreEmailsForImapInFolder:kINDEX_FOLDER_JUNK
                                              folderServer:folderJunkName
                                            folderJunkName:folderJunkName];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        //call delegate success
                        [[CWindow share] hideLoading];
                        [loadMoreEmailDelegate loadMoreEmailsSuccess];
                    });
                });
            }

        }
        else
        {
            [[CWindow share] hideLoading];
            
            if (folderIndex != kINDEX_FOLDER_JUNK)
            {
                if([messages[0] isEqualToString:mError_PleaseLoginViaYourWebBrowser]){
                    [loadMoreEmailDelegate disabledLessSecureApp];
                }else if([messages[0] isEqualToString:mError_AuthenticationFailed]){
                    [loadMoreEmailDelegate changedEmailPassword];
                }else if (error.code == MCOErrorConnection) {
                    [[CAlertView new] showError:NSLocalizedString(NO_INTERNET_CONNECTION_TRY_LATER, nil)];
                }else if(error.code != MCOErrorAuthentication)
                    [loadMoreEmailDelegate loadMoreEmailFailed];
            }
            
            NSDictionary* logDic = @{
                                     LOG_CLASS : NSStringFromClass(self.class),
                                     LOG_CATEGORY: CATEGORY_EMAIL_GET_OLD_IMAP_FAILED,
                                     LOG_MESSAGE: [NSString stringWithFormat:@"GET OLD IMAP FAILED ERROR: %@",error],
                                     LOG_EXTRA1: @"",
                                     LOG_EXTRA2: @""
                                     };
            [[LogFacade share] logErrorWithDic:logDic];
        }
    }];
}

-(void) getConfigurationImapAccount
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSString *emailAddress = [self getEmailAddress];
    MailAccount *mailAccount = [self getMailAccount:emailAddress];
    NSString *username = mailAccount.fullEmail;
    NSString *password = [self decryptString:mailAccount.password];
    NSString *hostname = mailAccount.incomingHost;
    int port = [mailAccount.incomingPort intValue];
    int connectionType = [mailAccount.incomingSecurityType intValue];
    
    [[EmailAdapter share] configureImapAccount:username
                                      password:password
                                      hostname:hostname
                                          port:port
                                connectionType:connectionType];

}

-(void) getConfigurationPopAccount
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSString *emailAddress = [self getEmailAddress];
    MailAccount *mailAccount = [self getMailAccount:emailAddress];
    NSString *username = mailAccount.fullEmail;
    NSString *password = [self decryptString:mailAccount.password];;
    NSString *hostname = mailAccount.incomingHost;
    int port = [mailAccount.incomingPort intValue];
    int connectionType = [mailAccount.incomingSecurityType intValue];
    
    [[EmailAdapter share] configurePopAccount:username
                                     password:password
                                     hostname:hostname
                                         port:port
                               connectionType:connectionType];
}

-(void)getMoreEmailsForPopInFolder:(NSString*)folderName folderIndex:(NSInteger)folderIndex{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    NSString *oldestEmailDate = [[NSUserDefaults standardUserDefaults] stringForKey:kEMAIL_INBOX_OLDEST];
    
    [[CWindow share] showLoading:kLOADING_LOADING];
    [[EmailAdapter share] getAllEmailsForPop:^(BOOL success, NSArray *messages, NSError *error) {
        [[CWindow share] hideLoading];
        if (success)
        {
            
            NSInteger totalEmails = messages.count;
            
            __block NSInteger numberLoadEmail = 0;
            //Save message headers to DB
            MCOPOPMessageInfo *messageInfo;
            
            for (int i = (int)totalEmails; i > 0; i--)
            {
                
                messageInfo = messages[i-1];

                NSOperationQueue *operationQueue = [NSOperationQueue new];
                [[CWindow share] showLoading:kLOADING_LOADING];
                [[EmailAdapter share] getEmailsHeaderAtIndexForPop:i
                                                          callback:^(BOOL success, MCOMessageHeader *messageHeader, NSError *error) {
                    
                    [[CWindow share] hideLoading];
                    
                    if (success)
                    {
                        
                        NSInteger sendDate = [messageHeader.date timeIntervalSince1970];
                        
                        if (sendDate < [oldestEmailDate integerValue]) {
                            
                            numberLoadEmail +=1;
                            
                            if ((int)numberLoadEmail == kNUMBER_OF_EMAIL_TO_LOAD_10) {
                                //store oldest email
                                [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%f",[messageHeader.date timeIntervalSince1970]] forKey:kEMAIL_INBOX_OLDEST];
                                [[NSUserDefaults standardUserDefaults] synchronize];
                            }
                            
                            if ((int)numberLoadEmail > kNUMBER_OF_EMAIL_TO_LOAD_10) {
                                NSLog(@"Done to load more 10 emails");
                                return;
                            }
                            
                            //Insert Email header
                            [self insertEmailHeaderForPop:folderIndex
                                                  headers:messageHeader
                                               uidMessage:[NSString stringWithFormat:@"%d",i]];
                            //Get email details
                            NSLog(@"messageUID: %@", messageInfo.uid);
                            NSLog(@"messageIndex: %d", i);
                            
                            NSDictionary *paramsMailDetail = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:folderIndex], kFOLDER_INDEX, messageInfo.uid, kUID, [NSNumber numberWithInt:i], kEMAIL_INDEX , [NSNumber numberWithInteger:numberLoadEmail], kEMAIL_COUNT, [NSNumber numberWithInteger:kNUMBER_OF_EMAIL_TO_LOAD_10], kEMAIL_TOTAL, nil];
                            
                            NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(getEmailDetailForPopInFolder:) object:paramsMailDetail];
                            [operationQueue addOperation:operation];
                        }
                    }
                }];
            }
        }
    }];
}

#pragma mark get NEW emails functions
- (void)getNewEmailHeaders
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        NSLog(@"%s", __PRETTY_FUNCTION__);

        NSString *emailAddress = [self getEmailAddress];
        MailAccount *mailAccount = [self getMailAccount:emailAddress];

        if ([mailAccount.accountType intValue] != 5) //IMAP
        {
            NSString *folderJunk  = [self getJunkNameInServerEmailForAccountType:[mailAccount.accountType intValue]];

            [self getConfigurationImapAccount];
            // remove method sync delete email between email server and local  because get all email in one time take a lot of resource
            if ([mailAccount.accountType intValue] == kEMAIL_ACCOUNT_TYPE_OTHER_IMAP)
            {
                 [self getNewEmailsForOtherImapInFolder:kINDEX_FOLDER_INBOX
                                           folderServer:FOLDER_INBOX
                                         folderJunkName:folderJunk];
            }
            else
            {
                 [self getNewEmailsForImapInFolder:kINDEX_FOLDER_INBOX
                                      folderServer:FOLDER_INBOX
                                    folderJunkName:folderJunk];
            }

            
//            if ([mailAccount.accountType intValue] == kEMAIL_ACCOUNT_TYPE_YAHOO ||
//                [mailAccount.accountType intValue] == kEMAIL_ACCOUNT_TYPE_HOTMAIL ||
//                [mailAccount.accountType intValue] == kEMAIL_ACCOUNT_TYPE_HOTMAIL) // Ignore Yahoo/Hotmail because can't fetch all email in once time
//            {
//                [self getNewEmailsForImapInFolder:kINDEX_FOLDER_INBOX
//                                     folderServer:FOLDER_INBOX
//                                   folderJunkName:folderJunk];//Inbox
//            }
//            else
//            {
//                [[EmailAdapter share] getEmailsHeaderForImapInFolder:FOLDER_INBOX
//                                                      numberMessages:MAXFLOAT
//                                                            callback:^(BOOL success, NSArray *messages, NSError *error) {
//                    if (success)
//                    {
//                        NSArray *emailsLocal = [self getEmailHeadersInFolder:kINDEX_FOLDER_INBOX];
//
//                        for (int i = 0; i < emailsLocal.count; i++)
//                        {
//                            BOOL isExist = NO;
//                            MailHeader *emailHeaderLocal = emailsLocal[i];
//
//                            for (int j = 0; j < messages.count; j++)
//                            {
//                                MCOIMAPMessage *messageHeader = messages[j];
//                                if (emailHeaderLocal.uid.intValue == messageHeader.uid)
//                                {
//                                    isExist = YES;
//                                }
//                            }
//
//                            if (isExist == NO)
//                            {
//                                [loadMoreEmailDelegate removeEmailHeader:emailHeaderLocal.uid];
//                                emailHeaderLocal.emailStatus = [NSNumber numberWithInt:2];//2 for delete
//                                [self saveEmailHeader:emailHeaderLocal];
//                                [self decreaseHeaderNumber:emailHeaderLocal];
//                            }
//                        }
//                        
//                        if ([mailAccount.accountType intValue] == kEMAIL_ACCOUNT_TYPE_OTHER_IMAP)
//                        {
//                            [self getNewEmailsForOtherImapInFolder:kINDEX_FOLDER_INBOX
//                                                      folderServer:FOLDER_INBOX
//                                                    folderJunkName:folderJunk];
//                        }
//                        else
//                        {
//                            [self getNewEmailsForImapInFolder:kINDEX_FOLDER_INBOX
//                                                 folderServer:FOLDER_INBOX
//                                               folderJunkName:folderJunk];
//                        }
//                    }
//                    else
//                    {
//                        dispatch_async(dispatch_get_main_queue(), ^(void) {
//                            [loadMoreEmailDelegate loadMoreEmailFailed];
//                        });
//                    }
//                }];
//            }
        }
        else //POP accountType = 5
        {
            [self getConfigurationPopAccount];
            [self getNewEmailsForPopInFolder:kINDEX_FOLDER_INBOX
                                folderServer:FOLDER_INBOX];//folderIndex is folder to save into DB
        }
    });
}

- (void)getNewEmailsForOtherImapInFolder:(NSInteger)folderIndex
                            folderServer:(NSString *)folderName
                          folderJunkName:(NSString *)folderJunkName
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [loadMoreEmailDelegate showLoadingView];
    });

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        int fromUID;

        if ([folderName isEqualToString:FOLDER_INBOX])
        {
            fromUID = [[[NSUserDefaults standardUserDefaults] stringForKey:kEMAIL_INBOX_NEWEST] intValue];
            NSLog(@"Newest Inbox UID %d", fromUID);
        }
        else
        {
            fromUID = [[[NSUserDefaults standardUserDefaults] stringForKey:kEMAIL_JUNK_NEWEST] intValue];
            NSLog(@"Newest Junk UID %d", fromUID);
        }

        [[EmailAdapter share] getNewEmailsHeaderForImapInFolder:folderName
                                                        fromUID:fromUID
                                                       callback:^(BOOL success, NSArray *messages, NSError *error) {
            if (success)
            {
                NSOperationQueue *operationQueue = [NSOperationQueue new];
                MCOIMAPMessage *messageHeader;
                NSNumber *indexOfFolder;
                NSNumber *messageUID;
                NSNumber *messageCount;
                NSNumber *totalMessage;

                if (messages.count > 0)
                {
                    for (int i = 0; i < messages.count; i++)
                    {
                        messageHeader = messages[i];

                        //Store newest email
                        if (i == 0)
                        {
                            if ([folderName isEqualToString:FOLDER_INBOX])
                            {
                                [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%u", messageHeader.uid]
                                                                          forKey:kEMAIL_INBOX_NEWEST];
                            }
                            else
                            {
                                [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%u", messageHeader.uid]
                                                                          forKey:kEMAIL_JUNK_NEWEST];
                            }

                            [[NSUserDefaults standardUserDefaults] synchronize];
                        }

                       //Save message headers to DB
                        [self insertEmailHeaderForImap:folderIndex
                                               headers:messageHeader];
                       //Get email details
                        indexOfFolder = [NSNumber numberWithInteger:folderIndex];
                        messageUID = [NSNumber numberWithInt:messageHeader.uid];
                        messageUID = [NSNumber numberWithInt:messageHeader.uid];
                        messageCount = [NSNumber numberWithInt:i];
                        totalMessage = [NSNumber numberWithInteger:messages.count];
                        NSDictionary *paramsMailDetail = [NSDictionary dictionaryWithObjectsAndKeys:folderName, kFOLDER_NAME, indexOfFolder, kFOLDER_INDEX, messageUID, kUID, messageCount, kEMAIL_COUNT, totalMessage, kEMAIL_TOTAL, nil];
                        NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self
                                                                                                selector:@selector(getEmailDetailForImapInFolder:)
                                                                                                  object:paramsMailDetail];
                        [operationQueue addOperation:operation];

                        //Download attachment
                        if ([messageHeader.attachments count] > 0)
                        {
                            [self downloadAttachmentsImapWithMessage:messageHeader
                                                              folder:folderName
                                                        isReDownLoad:NO];
                        }
                    }
                }

                if ([folderName isEqualToString:FOLDER_INBOX])
                {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [[CWindow share] hideLoading];

                        //call delegate success
                        if (messages.count > 0)
                        {
                            [[NotificationFacade share] notifyNewEmailReceived:(int)messages.count];
                            [loadMoreEmailDelegate loadNewEmailsSuccess];
                        }
                    });
                }
            }
            else
            {
                [[CWindow share] hideLoading];
                if (folderIndex != kINDEX_FOLDER_JUNK)
                {
                    if ([messages[0] isEqualToString:mError_PleaseLoginViaYourWebBrowser])
                        [loadMoreEmailDelegate disabledLessSecureApp];
                    else if ([messages[0] isEqualToString:mError_AuthenticationFailed])
                        [loadMoreEmailDelegate changedEmailPassword];
                    else if (error.code == MCOErrorConnection)
                        [[CAlertView new] showError:NSLocalizedString(NO_INTERNET_CONNECTION_TRY_LATER, nil)];
                    else if (error.code != MCOErrorAuthentication)
                        [loadMoreEmailDelegate loadMoreEmailFailed];
                }
                NSDictionary* logDic = @{
                                         LOG_CLASS : NSStringFromClass(self.class),
                                         LOG_CATEGORY: CATEGORY_EMAIL_GET_NEW_IMAP_FAILED,
                                         LOG_MESSAGE: [NSString stringWithFormat:@"GET NEW IMAP FAILED ERROR: %@",error],
                                         LOG_EXTRA1: @"",
                                         LOG_EXTRA2: @""
                                         };
                [[LogFacade share] logErrorWithDic:logDic];
            }
        }];
    });
}


- (void)getNewEmailsForImapInFolder:(NSInteger)folderIndex
                       folderServer:(NSString *)folderName
                     folderJunkName:(NSString *)folderJunkName
{
    
    NSLog(@"%s", __PRETTY_FUNCTION__);
    dispatch_async(dispatch_get_main_queue(), ^(void){
        [loadMoreEmailDelegate showLoadingView];
    });
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
    int fromUID;

    if ([folderName isEqualToString:FOLDER_INBOX])
    {
        fromUID = [[[NSUserDefaults standardUserDefaults] stringForKey:kEMAIL_INBOX_NEWEST] intValue];
        NSLog(@"Newest Inbox UID %d", fromUID);
    }
        
    [[EmailAdapter share] getNewEmailsHeaderForImap:folderName
                                            fromUID:fromUID
                                           callback:^(BOOL success, NSArray *messages, NSError *error) {
        if (success)
        {
            NSDictionary* logDic = @{
                                     LOG_CLASS : NSStringFromClass(self.class),
                                     LOG_CATEGORY: CATEGORY_EMAIL_GET_NEW_IMAP_SUCCESS,
                                     LOG_MESSAGE: [NSString stringWithFormat:@"GET NEW IMAP SUCCESS"],
                                     LOG_EXTRA1: @"",
                                     LOG_EXTRA2: @""
                                     };
            [[LogFacade share] logInfoWithDic:logDic];
            NSOperationQueue *operationQueue = [NSOperationQueue new];
            MCOIMAPMessage *messageHeader;
            NSNumber *indexOfFolder;
            NSNumber *messageUID;
            NSNumber *messageCount;
            NSNumber *totalMessage;

            if (messages.count > 0)
            {
                for (int i = 0; i < messages.count; i++)
                {
                    messageHeader = messages[i];

                    //Store newest email
                    if (i == 0)
                    {
                        if ([folderName isEqualToString:FOLDER_INBOX])
                        {
                            [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%u", messageHeader.uid]
                                                                      forKey:kEMAIL_INBOX_NEWEST];
                        }
                        else
                        {
                            [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%u", messageHeader.uid]
                                                                      forKey:kEMAIL_JUNK_NEWEST];
                        }

                        [[NSUserDefaults standardUserDefaults] synchronize];
                    }

                   //Save message headers to DB
                    [self insertEmailHeaderForImap:folderIndex
                                           headers:messageHeader];
                   //Get email details
                    indexOfFolder = [NSNumber numberWithInteger:folderIndex];
                    messageUID = [NSNumber numberWithInt:messageHeader.uid];
                    messageUID = [NSNumber numberWithInt:messageHeader.uid];
                    NSLog(@"messageUID: %@", messageUID);
                    messageCount = [NSNumber numberWithInt:i];
                    totalMessage = [NSNumber numberWithInteger:messages.count];
                    NSDictionary *paramsMailDetail = [NSDictionary dictionaryWithObjectsAndKeys:folderName, kFOLDER_NAME, indexOfFolder, kFOLDER_INDEX, messageUID, kUID, messageCount, kEMAIL_COUNT, totalMessage, kEMAIL_TOTAL, nil];
                    NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self
                                                                                            selector:@selector(getEmailDetailForImapInFolder:)
                                                                                              object:paramsMailDetail];
                    [operationQueue addOperation:operation];

                    //Download attachment
                    if ([messageHeader.attachments count] > 0)
                    {
                        [self downloadAttachmentsImapWithMessage:messageHeader
                                                          folder:folderName
                                                    isReDownLoad:NO];
                    }
                }
            }

            if ([folderName isEqualToString:FOLDER_INBOX])
            {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
                    //temporary stop getting new email for ms exchange to prevent showing error message
                    if (folderJunkName.length > 0 && ![folderJunkName isEqualToString:kEMAIL_FOLDER_JUNK_EMAIL])
                        [self getNewEmailsForImapInFolder:kINDEX_FOLDER_JUNK
                                             folderServer:folderJunkName
                                           folderJunkName:folderJunkName];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [[CWindow share] hideLoading];

                        //call delegate success
                        if (messages.count > 0)
                        {
                            if ([[EmailFacade share] getMailAccount:[[EmailFacade share] getEmailAddress]].useNotify)
                                [[NotificationFacade share] notifyNewEmailReceived:(int)messages.count];
                            [loadMoreEmailDelegate loadNewEmailsSuccess];
                        }
                    });
                });
            }
        }
        else
        {
            [[CWindow share] hideLoading];
            if (folderIndex != kINDEX_FOLDER_JUNK)
            {
                if ([messages[0] isEqualToString:mError_PleaseLoginViaYourWebBrowser])
                    [loadMoreEmailDelegate disabledLessSecureApp];
                else if ([messages[0] isEqualToString:mError_AuthenticationFailed])
                    [loadMoreEmailDelegate changedEmailPassword];
                else if (error.code == MCOErrorConnection)
                    [[CAlertView new] showError:NSLocalizedString(NO_INTERNET_CONNECTION_TRY_LATER, nil)];
                else if (error.code != MCOErrorAuthentication)
                    [loadMoreEmailDelegate loadMoreEmailFailed];
            }
            
            NSDictionary* logDic = @{
                                     LOG_CLASS : NSStringFromClass(self.class),
                                     LOG_CATEGORY: CATEGORY_EMAIL_GET_NEW_IMAP_FAILED,
                                     LOG_MESSAGE: [NSString stringWithFormat:@"GET NEW IMAP FAILED ERROR: %@",error],
                                     LOG_EXTRA1: @"",
                                     LOG_EXTRA2: @""
                                     };
            [[LogFacade share] logErrorWithDic:logDic];
        }
    }];
    });
}

-(void)getNewEmailsForPopInFolder:(NSInteger)folderIndex folderServer:(NSString*)folderName{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    NSString *newestEmailDate = [[NSUserDefaults standardUserDefaults] stringForKey:kEMAIL_INBOX_NEWEST];
    
    [loadMoreEmailDelegate showLoadingView];
    [[EmailAdapter share] getAllEmailsForPop:^(BOOL success, NSArray *messages, NSError *error) {
        [[CWindow share] hideLoading];
        
        if (success) {
            NSDictionary* logDic = @{
                                     LOG_CLASS : NSStringFromClass(self.class),
                                     LOG_CATEGORY: CATEGORY_EMAIL_GET_NEW_POP_SUCCESS,
                                     LOG_MESSAGE: [NSString stringWithFormat:@"GET NEW POP SUCCESS"],
                                     LOG_EXTRA1: @"",
                                     LOG_EXTRA2: @""
                                     };
            [[LogFacade share] logInfoWithDic:logDic];
            NSInteger totalEmails = messages.count;
            __block NSInteger numberLoadEmail = 0;
            
            //Save message headers to DB
            MCOPOPMessageInfo *messageInfo;
            for (int i = (int)totalEmails; i > 0; i--)
            {
                
                messageInfo = messages[i-1];
                
                NSOperationQueue *operationQueue = [NSOperationQueue new];
                
                [loadMoreEmailDelegate showLoadingView];
                [[EmailAdapter share] getEmailsHeaderAtIndexForPop:i
                                                          callback:^(BOOL success, MCOMessageHeader *messageHeader, NSError *error) {
                    [[CWindow share] hideLoading];
                    
                    if (success)
                    {
                        NSInteger sendDate = [messageHeader.date timeIntervalSince1970];
                        
                        if (sendDate > [newestEmailDate integerValue])
                        {
                            numberLoadEmail +=1;
                            //store newest email
                            [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%f",[messageHeader.date timeIntervalSince1970]] forKey:kEMAIL_INBOX_NEWEST];
                            [[NSUserDefaults standardUserDefaults] synchronize];
                            
                            //Insert Email header
                            [self insertEmailHeaderForPop:folderIndex
                                                  headers:messageHeader
                                               uidMessage:[NSString stringWithFormat:@"%d",i]];
                            //Get email details
                            NSDictionary *paramsMailDetail = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:folderIndex], kFOLDER_INDEX, messageInfo.uid, kUID, [NSNumber numberWithInt:i], kEMAIL_INDEX , [NSNumber numberWithInteger:numberLoadEmail], kEMAIL_COUNT, [NSNumber numberWithInteger:numberLoadEmail], kEMAIL_TOTAL, nil];
                            
                            NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(getEmailDetailForPopInFolder:) object:paramsMailDetail];
                            [operationQueue addOperation:operation];
                        }
                    }
                }];
            }
            [loadMoreEmailDelegate loadNewEmailsSuccess];
        }
        else
        {
            [loadMoreEmailDelegate loadMoreEmailFailed];
        }
    }];
}

#pragma mark get attachment functions
- (NSData*) getAttachmentDataWithFileName:(NSString*)fileName{
    return [self getEmailAttachment:fileName];
}

- (void)reDownLoadAttachmentOfEmail:(MailHeader *)emailHeader
{
    [self getConfigurationImapAccount];
    NSString *folderName;

    if (emailHeader.folderIndex.intValue == kINDEX_FOLDER_INBOX)
    {
        folderName = FOLDER_INBOX;
    }
    else if (emailHeader.folderIndex.intValue == kINDEX_FOLDER_JUNK)
    {
        MailAccount *mailAccount = [[EmailFacade share]getMailAccount:[[EmailFacade share]getEmailAddress]];
        folderName = [self getJunkNameInServerEmailForAccountType:mailAccount.accountType.intValue];
    }
    else
    {
        folderName = [self getMailFolderFromIndex:emailHeader.uid.intValue].folderName;
    }

    [[EmailAdapter share] getMessageHeaderWithUID:emailHeader.uid.intValue
                                         inFolder:folderName
                                         callback:^(BOOL success, MCOIMAPMessage *messageHeader, NSError *error) {
        if (success)
        {
            [self downloadAttachmentsImapWithMessage:messageHeader
                                              folder:folderName
                                        isReDownLoad:YES];
        }
    }];
}
#pragma mark update email functions
- (void) updateEmailOfContact:(NSString *)jid
{
    Contact *contact = [[ContactFacade share] getContact:jid];
    contact.email = @"";
    [[DAOAdapter share] commitObject:contact];
}
- (void) showAlertResetEmailAccount
{
    [[NSOperationQueue new] addOperationWithBlock:^{
        [self deleteEmailAccount];
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [chatViewDelegate handleAudioRecordWhileResetEmail];
            [[CAlertView new] showInfo:mERROR_EMAIL_RESET_NOTIFICATION];
            [[CWindow share] showEmailLogin];
        }];
    }];
}

- (NSMutableArray *)deleteOldEmailInFolder:(NSInteger)folderIndex emails:(NSMutableArray*)arrayEmail
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
        //NSArray *emailArray = [self getEmailHeadersInFolder:folderIndex];
        MailAccount *mailAccount = [[EmailFacade share]getMailAccount:[[EmailFacade share]getEmailAddress]];
        NSInteger remainDay = 0;
        float currentTime = [[NSDate date] timeIntervalSince1970];
        switch (mailAccount.emailKeeping.integerValue)
        {
            case kEMAIL_KEEPING_3_DAYS:
                remainDay = currentTime - ThreeDaysTime;
                break;

            case kEMAIL_KEEPING_1_WEEK:
                remainDay = currentTime - OneWeekTime;
                break;

            case kEMAIL_KEEPING_1_MONTH:
                remainDay = currentTime - OneMonthTime;
                break;

            case kEMAIL_KEEPING_3_MONTHS:
                remainDay = currentTime - ThreeMonthsTime;
                break;

            case kEMAIL_KEEPING_NEVER:
                remainDay = 0;
                break;

            default:
                break;
        }
    
        for (MailHeader *emailHeader in [arrayEmail mutableCopy])
        {
            if (emailHeader.receiveDate.integerValue - remainDay < 0)
            {
                emailHeader.emailStatus = [NSNumber numberWithInt:2];//2 for delete
                [self saveEmailHeader:emailHeader];
                [arrayEmail removeObject:emailHeader];
                [self decreaseHeaderNumber:emailHeader];
            }
        }
    return arrayEmail;
}

- (void)deleteEmail:(NSString *)uid inFolder:(NSInteger)folderIndex
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [[CWindow share] showLoading:kLOADING_DELETING];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        MailHeader *emailHeader = [self getMailHeaderFromUid:uid];
        //Update email to recycle bin if folder is not recrycle bin
        if (folderIndex == kINDEX_FOLDER_RECYCLE_BIN) //Delete in server
        {
            if (emailHeader)
            {
                emailHeader.emailStatus = [NSNumber numberWithInt:2];//2 for delete
                [self saveEmailHeader:emailHeader];
                [self decreaseHeaderNumber:emailHeader];
               //Call delete email to server here
                [self getConfigurationImapAccount];
                [[EmailAdapter share] updateFlagMessageWithFolderForImap:FOLDER_INBOX
                                                                     uid:emailHeader.uid.intValue
                                                                    flag:MCOMessageFlagDeleted
                                                                callback:^(BOOL success, NSString *message, NSError *error) {
                    dispatch_async(dispatch_get_main_queue(), ^(void) {
                        [[CWindow share] hideLoading];
                        //call delegate
                        [emailDetailDelegate deleteEmailSuccess];
                    });
                }];
            }
            else
            {
                NSLog(@"This email does not exist in MailHeader. email Uid: %@", uid);
            }
        }
        else //Move to recycle bin
        {
            [self moveEmail:uid toFolder:kINDEX_FOLDER_RECYCLE_BIN];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [[CWindow share] hideLoading];
                //call delegate
                [emailDetailDelegate deleteEmailSuccess];
            });
        }
    });
}

-(void)moveEmail:(NSString*)uid toFolder:(NSInteger)folderIndex{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    MailHeader *emailHeader = [self getMailHeaderFromUid:uid];
    [self decreaseHeaderNumber:emailHeader];
    if (emailHeader) {
        emailHeader.folderIndex = [NSNumber numberWithInteger:folderIndex];
        [self increaseHeaderNumber:emailHeader];
        [self saveEmailHeader:emailHeader];
    }else{
        NSLog(@"This email does not exist in MailHeader to move. email Uid: %@",uid);
    }
}

-(void)deleteEmailAccount{

    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    [[CWindow share] showLoading:kLOADING_UPDATING];
    
    if([self getEmailAddress].length == 0){
        NSLog(@"Your email address is nil or empty. So no call API delete email.");
        [[CWindow share] hideLoading];
        return;
    }
    
    NSDictionary *updateEmailDic = @{kAPI_REQUEST_METHOD: POST,
                                     kAPI_REQUEST_KIND: NORMAL,
                                     kMASKINGID: [[ContactFacade share] getMaskingId],
                                     kTOKEN: [[ContactFacade share] getTokentTenant],
                                     kEMAIL: [self getEmailAddress],
                                     kDELETE: @"1"
                                     };
    
    [[EmailAdapter share] updateEmailAccountToServer:updateEmailDic
                                            callback:^(BOOL success, NSString *message, NSDictionary *response, NSError *error) {
        [[CWindow share] hideLoading];
        if (success) {
            NSLog(@"Delete email account success");
            [KeyChainSecurity storeString:IS_NO Key:kIS_LOGGED_IN_EMAIL];
            
            NSArray *allFolder = [[EmailFacade share] getAllEmailFolders];
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            
            for (MailFolder *emailFolder in allFolder)
                [defaults removeObjectForKey:[NSString stringWithFormat:@"%ld",(long)emailFolder.folderIndex.integerValue]];
            
            //Delete all DB
            [[DAOAdapter share] deleteAllObject:[MailAccount class]];
            [[DAOAdapter share] deleteAllObject:[MailHeader class]];
            [[DAOAdapter share] deleteAllObject:[MailContent class]];
            [[DAOAdapter share] deleteAllObject:[MailAttachment class]];
            [[DAOAdapter share] deleteAllObject:[MailFolder class]];
            
            [[EmailAdapter share] deleteAllAttachmentsInEmailAttachmentFolder];
            
            //Call backup profile to backup email setting again
            [[ContactFacade share] backupProfile];
            
            [emailSettingDelegate deleteEmailAccountSuccess];
            [sideBarDelegate updateEmailRowUnreadNumber:kNUMBER_DELETE_EMAIL];
            
            NSDictionary* logDic = @{
                                     LOG_CLASS : NSStringFromClass(self.class),
                                     LOG_CATEGORY: CATEGORY_EMAIL_DELETE_EMAIL_ACCOUNT_SUCCESS,
                                     LOG_MESSAGE: [NSString stringWithFormat:@"DELETE EMAIL ACCOUNT SUCCESS"],
                                     LOG_EXTRA1: @"",
                                     LOG_EXTRA2: @""
                                     };
            [[LogFacade share] logInfoWithDic:logDic];
        }
        else
        {
            [emailSettingDelegate deleteEmailAccountFailed];
            NSDictionary* logDic = @{
                                     LOG_CLASS : NSStringFromClass(self.class),
                                     LOG_CATEGORY: CATEGORY_EMAIL_DELETE_EMAIL_ACCOUNT_FAILED,
                                     LOG_MESSAGE: [NSString stringWithFormat:@"DELETE EMAIL ACCOUNT FAILED ERROR: %@",error],
                                     LOG_EXTRA1: @"",
                                     LOG_EXTRA2: @""
                                     };
            [[LogFacade share] logErrorWithDic:logDic];
             if (response){
                // if Token is invalid or expire
                NSInvocationOperation* operation=  [[NSInvocationOperation alloc] initWithTarget:self
                                                                                        selector:@selector(deleteEmailAccount)
                                                                                          object:nil];
                NSDictionary* retryDictionary = @{kRETRY_OPERATION:operation,kRETRY_TIME:kRETRY_API_COUNTER,
                                                  kSTATUS_CODE : [response objectForKey:kSTATUS_CODE]};
                [[AppFacade share] downloadTokenAgain:retryDictionary];
             }
        }
    }];
}

#pragma mark Send email functions
-(void) moveToComposeWithEmail:(NSString *)emailContact
{
    [loadMoreEmailDelegate moveToComposeWithEmail:emailContact];
}
- (void) addReceipientIntoTextFieldWithData:(NSMutableArray *)arrayContactSelect
{
    [emailComposeDelegate updateTextFieldWithData:arrayContactSelect];
}

- (void)sendEmail:(NSString *)uid attachments:(NSArray *)attachmentNames encrypted:(BOOL)isEncrypted isResend:(BOOL)isResend
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        NSLog(@"%s", __PRETTY_FUNCTION__);

        //Sending email
        if (!isResend)
        {
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                [[CWindow share] showLoading:kLOADING_SENDING];
            });
        }

        NSString *emailAddress = [self getEmailAddress];
        MailAccount *mailAccount = [self getMailAccount:emailAddress];

        [self getConfigurationSmtpSession];

        NSString *displayName = mailAccount.fullEmail;

        if (mailAccount.displayName && ![mailAccount.displayName isEqualToString:@""])
        {
            displayName = mailAccount.displayName;
        }

        MailHeader *mailHeaderObj = [self getMailHeaderFromUid:uid];
        
        MailContent *mailContentObj = [self getMailContentFromMailHeaderUid:uid];
        NSArray *emailTo = [[mailHeaderObj.emailTo stringByReplacingOccurrencesOfString:@" " withString:@""] componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@","]];
        NSArray *emailCc = [[mailHeaderObj.emailCC stringByReplacingOccurrencesOfString:@" " withString:@""] componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@","]];
        NSArray *emailBcc = [[mailHeaderObj.emailBCC stringByReplacingOccurrencesOfString:@" " withString:@""] componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@","]];

        NSString *emailSubject = mailHeaderObj.subject;
        NSString *emailBody = mailContentObj.htmlContent;

        NSMutableArray *attachments = [NSMutableArray new];

        if (isEncrypted)//Encrypted
        {
            NSMutableArray *encryptAttachments = [NSMutableArray new];

            // NSarray attachment data to encrypt
            if (attachmentNames.count > 0)
            {
                for (int i = 0; i < attachmentNames.count; i++)
                {
                    NSMutableDictionary *attachmentDic = [[NSMutableDictionary alloc] init];
                    [attachmentDic setObject:attachmentNames[i] forKey:kEMAIL_ATTACHMENT_NAME];
                    //[attachmentDic setObject:[[EmailAdapter share] getEmailAttachment:attachmentNames[i]] forKey:kEMAIL_ATTACHMENT_DATA];
                    [attachmentDic setObject:[self getEmailAttachment:attachmentNames[i]] forKey:kEMAIL_ATTACHMENT_DATA];
                    [encryptAttachments addObject:attachmentDic];
                }
            }

            // Get array Jid
            NSArray *arrEmailAddress = [[emailTo arrayByAddingObjectsFromArray:emailCc] arrayByAddingObjectsFromArray:emailBcc];
            NSMutableArray *arrayJid = [NSMutableArray new];

            for (int i = 0; i < arrEmailAddress.count; i++)
            {
                Contact *contactObj = [self getContactFromEmail:arrEmailAddress[i]];

                if (contactObj.email.length > 0)
                {
                    [arrayJid addObject:contactObj.jid];
                }
            }

            [arrayJid addObject:[[ContactFacade share] getJid:YES]];

            //Encrypt data
            NSDictionary *encryptedEmail = [self encrypteEmail:emailBody
                                                    attachment:encryptAttachments
                                                           jid:arrayJid];

            emailBody = [encryptedEmail objectForKey:kEMAIL_ENC_BODY];
            attachments = [encryptedEmail objectForKey:kEMAIL_ENC_ATTACHMENT];
        }
        else//Not ecrypted
        {
            if (attachmentNames.count > 0)
            {
                for (int i = 0; i < attachmentNames.count; i++)
                {
                    NSMutableDictionary *attachmentDic = [[NSMutableDictionary alloc] init];
                    [attachmentDic setObject:attachmentNames[i] forKey:kEMAIL_ATTACHMENT_NAME];
                    [attachmentDic setObject:[self getEmailAttachment:attachmentNames[i]]
                                      forKey:kEMAIL_ATTACHMENT_DATA];
                    [attachments addObject:attachmentDic];
                }
            }
        }

        [[EmailAdapter share] sendEmailWithUID:uid
                                   displayName:displayName
                                            to:emailTo
                                            cc:emailCc
                                           bcc:emailBcc
                                       subject:emailSubject
                                          body:emailBody
                                    attachment:attachments
                                      callback:^(BOOL success, NSString *statusMessage, NSError *error, NSString *emailUID)
        {
            if (success)
            {
                [self moveEmail:emailUID
                       toFolder:kINDEX_FOLDER_SENT];         //move to sent folder
            }
            else
            {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    if (error != nil)
                    {
                        [emailComposeDelegate sendEmailFailed:error.localizedDescription];
                    }
                    else
                    {
                        [self moveEmail:emailUID toFolder:kINDEX_FOLDER_DRAFTS];
                        [emailComposeDelegate sendEmailFailed:statusMessage];
                    }
                });
            }
        }];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[CWindow share] hideLoading];
            [emailComposeDelegate sendEmailSuccess];
        });
    });
}

- (void)reSendEmails
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        NSArray *mailHeadersInOutbox = [self getEmailHeadersInFolder:kINDEX_FOLDER_OUTBOX];

        if (mailHeadersInOutbox.count > 0)
        {
            for (MailHeader *mailHeader in mailHeadersInOutbox)
            {
                NSMutableArray *attachmentNames = [[NSMutableArray alloc] init];
                NSArray *mailAttachments =  [[EmailFacade share] getMailAttachmentsFromUid:mailHeader.uid];

                for (MailAttachment *mailAttachment in mailAttachments)
                {
                    [attachmentNames addObject:mailAttachment.attachmentName];
                }

                [self sendEmail:mailHeader.uid
                    attachments:attachmentNames
                      encrypted:[mailHeader.isEncrypted boolValue]
                       isResend:YES];
            }
        }
    });
}

-(void) getConfigurationSmtpSession{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSString *emailAddress = [self getEmailAddress];
    MailAccount *mailAccount = [self getMailAccount:emailAddress];
    NSString *username = mailAccount.fullEmail;
    NSString *password = [self decryptString:mailAccount.outgoingPassword];;
    NSString *hostname = mailAccount.outgoingHost;
    int port = [mailAccount.outgoingPort intValue];
    //int connectionType = [mailAccount.outgoingSecurityType intValue];
    int connectionType;
    switch (port) {
        case kEMAIL_PORT_465:
            connectionType = kEMAIL_CONNECTION_TYPE_TLS_SSL;
            break;
        case kEMAIL_PORT_25:
            if (mailAccount.accountType.integerValue == kEMAIL_ACCOUNT_TYPE_OTHER_IMAP)//temporay fix for mtouche email
                connectionType = kEMAIL_CONNECTION_TYPE_CLEAR;
            else
                connectionType = kEMAIL_CONNECTION_TYPE_STARTTLS;
            break;
        default:
            connectionType = [mailAccount.outgoingSecurityType intValue];
            break;
    }
    
    [[EmailAdapter share] configureSmtp:username
                               password:password
                               hostname:hostname
                                   port:port
                         connectionType:connectionType];
    
}


- (NSString *)randomEmailUid{

    int codeRandom = arc4random()%1000000000;
    while (codeRandom < 100000000) {
        codeRandom = arc4random()%1000000000;
    }
    
    NSString *uidEmail = [NSString stringWithFormat:@"%d", codeRandom];

    return uidEmail;
}

- (NSString*)saveEmailToFolder:(NSInteger)folderIndex
                           uid:(NSString *)emailUID
                            to:(NSString*)emailTo
                            cc:(NSString*)emailCc
                           bcc:(NSString*)emailBcc
                       subject:(NSString*)emailSubject
                          body:(NSString*)emailBody
                    attachment:(NSArray*)attachmentNames
                     encrypted:(BOOL)isEncrypted{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    MailAccount *mailAccount = [[EmailFacade share] getMailAccount:[[EmailFacade share] getEmailAddress]];
    
    NSString *displayName = mailAccount.fullEmail;
    
    if (mailAccount.displayName && ![mailAccount.displayName isEqualToString:@""]) {
        displayName = mailAccount.displayName;
    }
    
    if (emailUID.length > 0)
    {
        [self deleteDraftEmail:emailUID];
    }
    
    NSString *uidEmail = [self randomEmailUid];
    
    MailHeader* mailHeaderObj = [self getMailHeaderFromUid:uidEmail];
    if (mailHeaderObj) {
       uidEmail = [self randomEmailUid];
        mailHeaderObj = [self getMailHeaderFromUid:uidEmail];
    }
    
    if (!mailHeaderObj) {

        mailHeaderObj = [MailHeader new];
        mailHeaderObj.mailAccountId = @"";
        mailHeaderObj.uid = uidEmail;
        mailHeaderObj.emailFrom = mailAccount.fullEmail;
        mailHeaderObj.emailTo = emailTo;
        mailHeaderObj.emailCC = emailCc;
        mailHeaderObj.emailBCC = emailBcc;
        mailHeaderObj.subject = emailSubject;
        mailHeaderObj.shortDesc = emailBody;
        mailHeaderObj.emailStatus = [NSNumber numberWithInt:1];//read
        mailHeaderObj.folderIndex = [NSNumber numberWithInteger:folderIndex];
        mailHeaderObj.attachNumber =  [NSNumber numberWithInteger:attachmentNames.count];
        mailHeaderObj.isDownloaded = [NSNumber numberWithInt:1];
        mailHeaderObj.isImportant = [NSNumber numberWithInt:0];
        mailHeaderObj.isReplied = [NSNumber numberWithInt:0];
        mailHeaderObj.isForwarded = [NSNumber numberWithInt:0];
        mailHeaderObj.isEncrypted = [NSNumber numberWithInt:isEncrypted];
        mailHeaderObj.sendDate = [NSNumber numberWithInt:[[NSDate date] timeIntervalSince1970]];
        mailHeaderObj.receiveDate = [NSNumber numberWithInt:[[NSDate date] timeIntervalSince1970]];
        mailHeaderObj.extend1 = displayName;
        mailHeaderObj.extend2 = @"";
        
        [self saveEmailHeader:mailHeaderObj];
        [self increaseHeaderNumber:mailHeaderObj];
    }
    
    MailContent* mailContentObj = [self getMailContentFromMailHeaderUid:uidEmail];
    if (!mailContentObj) {
        mailContentObj  = [MailContent new];
        mailContentObj.emailHeaderUID = uidEmail;
        //mailContent.isFullyDownloaded = 0;
        mailContentObj.htmlContent = emailBody;
        mailContentObj.mineType = @"";
        [self saveEmailContent:mailContentObj];
    }
    
    if (attachmentNames.count > 0)
    {
        for (int i = 0; i < attachmentNames.count; i++)
        {
            NSString *attachName = [NSString stringWithFormat:@"%@_%d_%@", uidEmail, i, attachmentNames[i]];
            NSString *queryCondition = [NSString stringWithFormat:@"attachmentName = '%@'", attachName];
            MailAttachment *mailAttachmentObj = (MailAttachment *)[[DAOAdapter share] getObject:[MailAttachment class]
                                                                                      condition:queryCondition];

            if (!mailAttachmentObj)
            {
                mailAttachmentObj  = [MailAttachment new];
                mailAttachmentObj.mailHeaderUID = uidEmail;
                mailAttachmentObj.attachmentName = attachName;
                mailAttachmentObj.attachmentLocalPath = @"";
                mailAttachmentObj.attachmentSize = [NSNumber numberWithInt:0];    //set default.
                mailAttachmentObj.mineType = @"";
                [[DAOAdapter share] commitObject:mailAttachmentObj];
            }
        }
    }
    
    return uidEmail;
}

-(BOOL) setEmailAttachment:(NSString*)attachmentName data:(NSData*) attachmentData{
    return [[EmailAdapter share] setEmailAttachment:attachmentName
                                               data:[[AppFacade share] encryptDataLocally:attachmentData]];
}

-(NSData*) getEmailAttachment:(NSString*)attachmentName{
    return [[AppFacade share] decryptDataLocally:[[EmailAdapter share] getEmailAttachment:attachmentName]];
}

#pragma mark Encrypt/decrypt functions
/* *
 * Encrypt email
 * @parameters: attachmentsData: array of nsdictionery with kEMAIL_ATTACHMENT_NAME, kEMAIL_ATTACHMENT_DATA .
 * @return: Dictionary email encrypted with kEMAIL_ENC_BODY, kEMAIL_ENC_ATTACMENT
 * @Author Parker
 */
- (NSDictionary *) encrypteEmail:(NSString *)emailBody attachment:(NSArray *)attachmentsData jid:(NSArray *)arrJID{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    NSMutableDictionary *encryptedEmailDic = [[NSMutableDictionary alloc] init];
    
    //Encrypt email body
    NSString *encryptedEmailBody;
    NSData* key32 = [AESSecurity randomDataOfLength:32];
    if(emailBody && ![emailBody isEqualToString:@""]){
        NSData* contentData = [emailBody dataUsingEncoding:NSUTF8StringEncoding];
        encryptedEmailBody = [Base64Security generateBase64String:[AESSecurity encryptAES256WithKey:key32
                                                                                               Data:contentData]];
    }
    else {
        encryptedEmailBody = @"";
    }
    //encrypt attachments
    NSMutableArray *encryptedAttachments = [NSMutableArray new];
    if (attachmentsData.count > 0)
        for (NSDictionary *attachData in attachmentsData)
        {
            NSMutableDictionary *attachmentDic = [[NSMutableDictionary alloc] init];
            
            NSData *attachmentData = [AESSecurity encryptAES256WithKey:key32
                                                                  Data:[attachData objectForKey:kEMAIL_ATTACHMENT_DATA]];
            //NSData *base64Decode = [Base64Security decodeBase64String:[Base64Security generateBase64String:attachmentData]];
            [attachmentDic setObject:attachmentData forKey:kEMAIL_ATTACHMENT_DATA];
            [attachmentDic setObject:[attachData objectForKey:kEMAIL_ATTACHMENT_NAME]
                              forKey:kEMAIL_ATTACHMENT_NAME];
            
            [encryptedAttachments addObject:attachmentDic];
        }
    
    NSMutableDictionary *mutaMaskid = [NSMutableDictionary new];
    
    for (NSString * userJID in arrJID)
    {
        Contact *contact = [[ContactFacade share] getContact:userJID];
        if (!contact || !contact.maskingid) {
            NSLog(@"Contact with jid %@ does not existed",userJID);
        }
        
        Key* key = [[AppFacade share] getKey:userJID];
        if(!key || !key.keyJSON){
            NSLog(@"No Key available for jid %@", userJID);
        }
        if (key.keyJSON) {
            NSData* keyData = [Base64Security decodeBase64String:key.keyJSON];
            if (keyData)
                key.keyJSON = [[NSString alloc] initWithData:[[AppFacade share] decryptDataLocally:keyData]
                                                    encoding:NSUTF8StringEncoding];
        }
        
        NSDictionary* dicKey = [ChatAdapter decodeJSON:key.keyJSON];
        
        if (contact.jid) {
            NSString* base64KeyString = [Base64Security generateBase64String:
                                   [RSASecurity encryptRSA:key32
                                              b64PublicExp:[dicKey objectForKey:kMOD1_EXPONENT]
                                                b64Modulus:[dicKey objectForKey:kMOD1_MODULUS]]];
            if (base64KeyString)
                [mutaMaskid setObject:base64KeyString
                               forKey:(contact.maskingid)?contact.maskingid:[NSString stringWithFormat:@"%@",userJID]];
            else // QA said no need to show alert can't encrypt email
                NSLog(@"Can't encrypt email");
        }
        // Send email to self
        if ([userJID isEqualToString:[[ContactFacade share] getJid:YES]])
        {
            NSString* base64KeyString = [Base64Security generateBase64String:
                                         [RSASecurity encryptRSA:key32
                                                    b64PublicExp:[KeyChainSecurity getStringFromKey:kMOD1_EXPONENT]
                                                      b64Modulus:[KeyChainSecurity getStringFromKey:kMOD1_MODULUS]]];
            if (base64KeyString)
                [mutaMaskid setObject:base64KeyString forKey:[[ContactFacade share] getMaskingId]];
            else
                [[CAlertView new] showError:NSLocalizedString(mError_CanNotEncryptYourEmail,nil)];
        }
    }
    
    NSString * strJSON = [ChatAdapter generateJSON:mutaMaskid];
    
    NSString * returnEmailBody = [NSString stringWithFormat:@"%@%@%@%@%@",kEMAIL_SEPARATOR,
                                  [Base64Security generateBase64String:strJSON],kEMAIL_SEPARATOR,
                                  encryptedEmailBody,kEMAIL_SEPARATOR];
    
    NSLog(@"strJSON = %@",strJSON);
    NSLog(@"returnEmailBody = %@",returnEmailBody);
    
    [encryptedEmailDic setObject:encryptedAttachments forKey:kEMAIL_ENC_ATTACHMENT];
    [encryptedEmailDic setObject:returnEmailBody forKey:kEMAIL_ENC_BODY];
    
    return encryptedEmailDic;
}

/* *
 * Decrypt email
 * @parameters: attachmentsData: array of nsdictionery with kEMAIL_ATTACHMENT_NAME, kEMAIL_ATTACHMENT_DATA .
 * @return: Dictionary email encrypted with kEMAIL_ENC_BODY, kEMAIL_ENC_ATTACMENT
 * @Author Parker
 */
- (NSDictionary *) decrypteEmail:(NSString *)emailBody attachment:(NSArray *)attachmentsData{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
      NSMutableDictionary *decryptedEmailDic = [[NSMutableDictionary alloc] init];
    
    NSArray *arrEmailData = [emailBody componentsSeparatedByString:kEMAIL_SEPARATOR];
    
    if ([arrEmailData count] != 4) {
        NSLog(@"Wrong Encryption format.");
        return nil;
    }
    
    NSString *base64KeyString = arrEmailData[1];
    NSString *base64EncData = arrEmailData[2];
    
    if (!base64KeyString || [[base64KeyString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]) {
        NSLog(@"base64KeyString is empty");
        return nil;
    }
    
    if (!base64EncData || [[base64EncData stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]) {
        NSLog(@"base64EncData is empty");
        return nil;
    }
    
    NSString *jsonKeyString =  [[NSString alloc] initWithData:[Base64Security decodeBase64String:base64KeyString]
                                                     encoding:NSUTF8StringEncoding];
    NSDictionary *dictData = [ChatAdapter decodeJSON:jsonKeyString];
   
    NSLog(@"JSONKeyString = %@",jsonKeyString);
    
    if (![dictData objectForKey:[[[ContactFacade share] getMaskingId] uppercaseString]]){
        NSLog(@"My MaskingID not found");
        return nil;
    }
    
    NSString *base64AESKey = [dictData objectForKey:[[[ContactFacade share] getMaskingId] uppercaseString]];
    NSData *AESKey = [RSASecurity decryptRSA:base64AESKey
                                b64PublicExp:[KeyChainSecurity getStringFromKey:kMOD1_EXPONENT]
                                  b64Modulus:[KeyChainSecurity getStringFromKey:kMOD1_MODULUS]
                               b64PrivateExp:[KeyChainSecurity getStringFromKey:kMOD1_PRIVATE]];
    
    if (!AESKey) {
        NSLog(@"AESKey is nil");
        return nil;
    }
    
    NSString *decryptedEmailBody;
    NSMutableArray *decryptedAttachments = [NSMutableArray new];
    
    if (attachmentsData.count > 0)
        for (NSDictionary* attachData in attachmentsData)
        {
            NSMutableDictionary *attachmentDic = [[NSMutableDictionary alloc] init];
            
            NSData *attachmentData = [AESSecurity decryptAES256WithKey:AESKey
                                                                  Data:[attachData objectForKey:kEMAIL_ATTACHMENT_DATA]];
            if (attachmentData != nil && attachmentData.length > 0) {
                [attachmentDic setObject:attachmentData forKey:kEMAIL_ATTACHMENT_DATA];
                [attachmentDic setObject:[attachData objectForKey:kEMAIL_ATTACHMENT_NAME] forKey:kEMAIL_ATTACHMENT_NAME];
                [self setEmailAttachment:[attachmentDic objectForKey:kEMAIL_ATTACHMENT_NAME]
                                    data:[attachmentDic objectForKey:kEMAIL_ATTACHMENT_DATA]];

                [decryptedAttachments addObject:attachmentDic];
            }

        }
    
    NSData* emailBodyData = [AESSecurity decryptAES256WithKey:AESKey
                                                         Data:[Base64Security decodeBase64String:base64EncData]];
    decryptedEmailBody = [[NSString alloc] initWithData:emailBodyData
                                               encoding:NSUTF8StringEncoding];
    
    [decryptedEmailDic setObject:decryptedAttachments forKey:kEMAIL_DEC_ATTACHMENT];
    [decryptedEmailDic setObject:decryptedEmailBody forKey:kEMAIL_DEC_BODY];
    
    return decryptedEmailDic;
}

/* *
 * Check email is encrypted or not
 * @parameters: emailBody: body content of email.
 * @return: TRUE/FALSE
 * @Author Parker
 */
- (BOOL) isEncEmail:(NSString *)emailBody{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSArray *arrEmailData = [emailBody componentsSeparatedByString:kEMAIL_SEPARATOR];
    
    if ([arrEmailData count] != 4) {
        return NO;
    } else {
        return YES;
    }
}

- (NSDictionary *) decrypteEmailContent:(NSString *)emailBody attachments:(NSArray *)attachmentNames{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSMutableArray *decryptAttachments = [NSMutableArray new];
    // NSarray attachment data to decrypt
    if (attachmentNames.count > 0)
        for (int i = 0; i < attachmentNames.count; i++) {
            NSMutableDictionary *attachmentDic = [[NSMutableDictionary alloc] init];
            [attachmentDic setObject:attachmentNames[i] forKey:kEMAIL_ATTACHMENT_NAME];
            [attachmentDic setObject:[self getEmailAttachment:attachmentNames[i]]
                              forKey:kEMAIL_ATTACHMENT_DATA];
            [decryptAttachments addObject:attachmentDic];
        }
    
    NSDictionary *decryptEmailDic = [self decrypteEmail:emailBody attachment:decryptAttachments];
    
    return decryptEmailDic;
}

@end
