//
//  AppFacade.m
//  Satay
//
//  Created by TrungVN on 1/20/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import "CWindow.h"

@implementation AppFacade

@synthesize windowDelegate;
@synthesize chatViewDelegate;
@synthesize contactInfoDelegate;
@synthesize appSettingDelegate;


#define DB_NAME @"Zipit"

+(AppFacade *)share{
    static dispatch_once_t once;
    static AppFacade * share;
    dispatch_once(&once, ^{
        share = [self new];
        [[NSNotificationCenter defaultCenter] addObserver:share
                                                 selector:@selector(keyBoardChanged:)
                                                     name:UIKeyboardDidShowNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:share
                                                 selector:@selector(keyBoardChanged:)
                                                     name:UIKeyboardDidHideNotification
                                                   object:nil];
    });
    return share;
}

-(void) createLocalKey{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSString* passKey = [KeyChainSecurity getStringFromKey:kPASSWORD];
    if (!passKey.length > 0)
        return;
    NSString* localAESKey = [KeyChainSecurity getStringFromKey:kENC_MASTER_KEY];
    if (localAESKey.length > 0)
        return;
    NSData* randomSalt = [AESSecurity randomDataOfLength:16];
    
    //1st create, this is random 32 bytes. This one we call it MASTER KEY;
    NSData* masterKey = [AESSecurity randomDataOfLength:32];
    NSData* encMasterKey = [AESSecurity encryptAES256WithKey:[AESSecurity hashPBKDF2:passKey
                                                                                Salt:randomSalt]
                                                        Data:masterKey
                                                        Salt:randomSalt];
    
    if (encMasterKey.length > 0) {
        [KeyChainSecurity storeString:[Base64Security generateBase64String:encMasterKey]
                                  Key:kENC_MASTER_KEY];
    }
}

/*
 *This method is not public. only using inside AppFacade.m;
 *@Author:TrungVN
 */
-(NSData*) masterKey{
    NSData* encMasterKey = [Base64Security decodeBase64String:[KeyChainSecurity getStringFromKey:kENC_MASTER_KEY]];
    NSData* saltData = [encMasterKey subdataWithRange:NSMakeRange(0, 16)];
    NSData* aesKey = [AESSecurity hashPBKDF2:[KeyChainSecurity getStringFromKey:kPASSWORD]
                                        Salt:saltData];
    NSData* masterKey = [AESSecurity decryptAES256WithKey:aesKey
                                                     Data:encMasterKey];
    return masterKey;
}

-(void) resetLocalKey:(NSString*) oldPassword{
    if (oldPassword.length == 0)
        return;
    NSData* encMasterKey = [Base64Security decodeBase64String:[KeyChainSecurity getStringFromKey:kENC_MASTER_KEY]];
    NSData* saltData = [encMasterKey subdataWithRange:NSMakeRange(0, 16)];
    if (saltData.length == 0)
        return;
    
    NSData* aesKey = [AESSecurity hashPBKDF2:oldPassword
                                        Salt:saltData];
    
    //Reget the masterKey Data
    NSData* masterKey = [AESSecurity decryptAES256WithKey:aesKey
                                                     Data:encMasterKey];
    
    //Recreate encMasterKey
    NSString* passKey = [KeyChainSecurity getStringFromKey:kPASSWORD];
    NSData* randomSalt = [AESSecurity randomDataOfLength:16];
    encMasterKey = [AESSecurity encryptAES256WithKey:[AESSecurity hashPBKDF2:passKey
                                                                        Salt:randomSalt]
                                                Data:masterKey
                                                Salt:randomSalt];
    
    if (encMasterKey.length > 0) {
        [KeyChainSecurity storeString:[Base64Security generateBase64String:encMasterKey]
                                  Key:kENC_MASTER_KEY];
    }
}

-(NSData*) encryptDataLocally:(NSData*) inputData{
    if (!inputData)
        return nil;
    NSData* encData = [AESSecurity encryptAES256WithKey:[self masterKey]
                                                   Data:inputData];
    return encData;
}

-(NSData*) decryptDataLocally:(NSData*) inputData{
    if (!inputData || inputData.length < 16)
        return nil;
    NSData* decData = [AESSecurity decryptAES256WithKey:[self masterKey]
                                                   Data:inputData];
    return decData;
}

-(void) connectDB{
    [[DAOAdapter share] openDB:DB_NAME];
}

-(void) checkFirstRun{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (![defaults objectForKey:FIRSTRUN]){
        [defaults setObject:[NSDate date] forKey:FIRSTRUN];
        
        //reset Account status
        [KeyChainSecurity removeKey:kACCOUNT_STATUS];
        //reset account info
        [KeyChainSecurity removeKey:kSUB_END_DATE];
        [KeyChainSecurity removeKey:kSUB_START_DATE];
        [KeyChainSecurity removeKey:kACCOUNT_URL];
        
        //reset Keychain here
        [KeyChainSecurity removeKey:kMASKINGID];
        [KeyChainSecurity removeKey:kJID];
        [KeyChainSecurity removeKey:kJID_PASSWORD];
        [KeyChainSecurity removeKey:kJID_HOST];
        [KeyChainSecurity removeKey:kTOKEN];
        [KeyChainSecurity removeKey:kTENANTTOKEN];
        [KeyChainSecurity removeKey:kCENTRALTOKEN];
        [KeyChainSecurity removeKey:kPASSWORD];
        [KeyChainSecurity removeKey:kENC_MASTER_KEY];
        [KeyChainSecurity removeKey:kDEVICE_TOKEN];

        //reset Keys pair
        [KeyChainSecurity removeKey:kMOD1_EXPONENT];
        [KeyChainSecurity removeKey:kMOD1_MODULUS];
        [KeyChainSecurity removeKey:kMOD1_PRIVATE];
        [KeyChainSecurity removeKey:kMOD2_EXPONENT];
        [KeyChainSecurity removeKey:kMOD2_MODULUS];
        [KeyChainSecurity removeKey:kMOD2_PRIVATE];
        [KeyChainSecurity removeKey:kMOD3_EXPONENT];
        [KeyChainSecurity removeKey:kMOD3_MODULUS];
        [KeyChainSecurity removeKey:kMOD3_PRIVATE];
        
        //Device info
        [KeyChainSecurity removeKey:kIMEI];
        [KeyChainSecurity removeKey:kIMSI];
        
        //MyPofile
        [KeyChainSecurity removeKey:kDISPLAY_NAME];
        
        //Sync Contact
        [KeyChainSecurity removeKey:kMSISDN];
        [KeyChainSecurity removeKey:kPHONE_NUMBER];
        [KeyChainSecurity removeKey:kCOUNTRY_CODE];
        [KeyChainSecurity removeKey:kDIAL_CODE];
        [KeyChainSecurity removeKey:kVERIFICATION_CODE];
        
        //All flags
        [KeyChainSecurity removeKey:kIS_REGISTER];
        [KeyChainSecurity removeKey:kIS_FREE_TRIAL];
        [KeyChainSecurity removeKey:kIS_SYNC_CONTACT];
        [KeyChainSecurity removeKey:kIS_ACCEPTED_TERM_AND_CONDITION];
        [KeyChainSecurity removeKey:kIS_ACCOUNT_REMOVED];
        //Email
        [KeyChainSecurity removeKey:kIS_LOGGED_IN_EMAIL];
        [KeyChainSecurity removeKey:kEMAIL_ADDRESS];
        
        //Backup/Restore
        [KeyChainSecurity removeKey:kBACKUP_FILE_VERSION];
        [KeyChainSecurity removeKey:kIS_BACKUP_ACCOUNT];
        [KeyChainSecurity removeKey:[NSString stringWithFormat:@"%@%@", kVersionKeyFormat, [[ContactFacade share] getJid:YES]]];
        [KeyChainSecurity removeKey:kIS_UPDATED_PASS_BACKUP_FILE];
        [KeyChainSecurity removeKey:kIS_RE_LOGIN_ACCOUNT];
        [KeyChainSecurity removeKey:kIS_RESTORE_ACCOUNT];
        [KeyChainSecurity removeKey:kIS_RESTORED_ALL_CONTACT];
        
        //Missing keychain
        [KeyChainSecurity removeKey:kENABLE_PASSWORD_LOCK];
        [KeyChainSecurity removeKey:kCOUNT_ENTER_WRONG_PWD];
        [KeyChainSecurity removeKey:kOTP_MESSAGE_ID];
        [KeyChainSecurity removeKey:kFORCE_VERSION_IOS];
        [KeyChainSecurity removeKey:kHOSTMUC];
        [KeyChainSecurity removeKey:IS_CRASH];
        [KeyChainSecurity removeKey:IS_SEND_LOG];
        [KeyChainSecurity removeKey:kREUPLOAD_PASSWORD];
        [KeyChainSecurity removeKey:kENABLE_REMOTE_LOG];
        [KeyChainSecurity removeKey:kENABLE_SEND_CRASHLOG_VIA_EMAIL];
        [KeyChainSecurity removeKey:kENABLE_INAPP_NOTIFICATION_ALERT];
        [KeyChainSecurity removeKey:kENABLE_INAPP_NOTIFICATION_SOUND];
        [KeyChainSecurity removeKey:SIP_RECIPIENT_MASKINGID];
        [KeyChainSecurity removeKey:kRESEND_LIMIT];
        
        //Count wrong password
        [self removeCountWrongPasswordKey];
        
        //Password lock flag
        [self setPasswordLockFlag:IS_YES];
        
        //Send crash log flag
        [[LogFacade share] setEnableSendCrashViaEmail:YES];
        [[LogFacade share] remoteLogEnable:YES];
        
        //Account setting
        [[NotificationFacade share] setNotificationAlertInAppFlag:IS_YES];
        [[NotificationFacade share] setNotificationSoundInAppFlag:IS_YES];       
        
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void) deleteAllTablesDB{
    [[DAOAdapter share] deleteAllObject:[ChatBox class]];
    [[DAOAdapter share] deleteAllObject:[Contact class]];
    [[DAOAdapter share] deleteAllObject:[GroupMember class]];
    [[DAOAdapter share] deleteAllObject:[GroupObj class]];
    [[DAOAdapter share] deleteAllObject:[Key class]];
    [[DAOAdapter share] deleteAllObject:[MailAccount class]];
    [[DAOAdapter share] deleteAllObject:[MailAttachment class]];
    [[DAOAdapter share] deleteAllObject:[MailContent class]];
    [[DAOAdapter share] deleteAllObject:[MailFolder class]];
    [[DAOAdapter share] deleteAllObject:[MailHeader class]];
    [[DAOAdapter share] deleteAllObject:[Message class]];
    [[DAOAdapter share] deleteAllObject:[NoticeBoard class]];
    [[DAOAdapter share] deleteAllObject:[Request class]];
    [[DAOAdapter share] deleteAllObject:[SecureNote class]];
}

-(ChatBox*) getChatBox:(NSString*) chatboxId{
    NSString* queryChatbox = [NSString stringWithFormat:@"chatboxId = '%@'", chatboxId];
    return (ChatBox*)[[DAOAdapter share] getObject:[ChatBox class] condition:queryChatbox];
}

-(Message*) getMessage:(NSString*) messageId{
    NSString* queryMessage = [NSString stringWithFormat:@"messageId = '%@'", messageId];
    Message* message = (Message*)[[DAOAdapter share] getObject:[Message class] condition:queryMessage];
    return message;
}

-(Key*) getKey:(NSString*) keyId{
    NSString* queryKey = [NSString stringWithFormat:@"keyId = '%@'", keyId];
    return (Key*)[[DAOAdapter share] getObject:[Key class] condition:queryKey];
}

-(Key*) getKeyForGroup:(NSString*)keyId andVersion:(NSString *)key_version
{
    NSString *queryKey = [NSString stringWithFormat:@"keyId = '%@' AND keyVersion = '%@'", keyId, key_version];
    return (Key*)[[DAOAdapter share] getObject:[Key class] condition:queryKey];
}

-(NSArray*) getAllGroupKeys:(NSString*) keyId{
    NSString* queryKey = [NSString stringWithFormat:@"keyId = '%@'", keyId];
    return (NSArray*)[[DAOAdapter share] getObjects:[Key class] condition:queryKey];
}

-(Key*) getLatestKeyForGroup:(NSString *)keyId
{
    NSString* queryKey = [NSString stringWithFormat:@"keyId = '%@'", keyId];
    NSArray* keys = [[DAOAdapter share] getObjects:[Key class] condition:queryKey orderBy:@"updateTS" isDescending:YES limit:1];
    
    if (keys.count > 0)
        return [keys objectAtIndex:0];
    else
        return nil;
}

- (GroupObj *)getGroupObj:(NSString *)groupId
{
    NSString* queryGroupObj = [NSString stringWithFormat:@"groupId = '%@'", groupId];
    return (GroupObj *)[[DAOAdapter share] getObject:[GroupObj class] condition:queryGroupObj];
}

- (GroupMember*) getGroupMember:(NSString*) groupId
                        userJID:(NSString*) userJID{
    NSString* query = [NSString stringWithFormat:@"groupId = '%@' AND jid = '%@'", groupId, userJID];
    return (GroupMember *)[[DAOAdapter share] getObject:[GroupMember class] condition:query];
}

-(BOOL)checkString: (NSString *)string withRegularExpression:(NSString *)RegEx
{
    NSPredicate *regExPredicate =[NSPredicate predicateWithFormat:@"SELF MATCHES %@", RegEx];
    BOOL myStringMatchesRegEx = [regExPredicate evaluateWithObject:string];
    
    if (myStringMatchesRegEx)
        return YES;
    else
        return NO;
}

#pragma mark keyboardShow or Hide

- (void)keyBoardChanged:(NSNotification*)notification
{
    // This is keyboard frame rect. Just use it.
    CGRect keyboardFrameEndRect;
    
    if ([notification.name isEqual:UIKeyboardDidShowNotification]) {
        NSDictionary* keyboardInfo = [notification userInfo];
        NSValue* keyboardFrameEnd = [keyboardInfo valueForKey:UIKeyboardFrameEndUserInfoKey];
        keyboardFrameEndRect = [keyboardFrameEnd CGRectValue];
    }
    else if([notification.name isEqual:UIKeyboardDidHideNotification]){
        keyboardFrameEndRect = CGRectZero;
    }
    /*
     handle keyboard change in here.
     
     */
    
}

-(void) reloadSettingViewController{
    [appSettingDelegate reloadSettingsTable];
}

#pragma mark Setting flags

-(NSString*)getPasswordLockFlag{
    NSString* value = [KeyChainSecurity getStringFromKey:kENABLE_PASSWORD_LOCK];
    
    if(!value){
        value = [NSString stringWithFormat:IS_YES];
        [KeyChainSecurity storeString:value Key:kENABLE_PASSWORD_LOCK];
    }
    return value;
}

-(void)setPasswordLockFlag:(NSString*)value{
    [KeyChainSecurity storeString:value Key:kENABLE_PASSWORD_LOCK];
}

-(NSString*)getCountWrongPasswordKey{
    return [KeyChainSecurity getStringFromKey:kCOUNT_ENTER_WRONG_PWD];
}

-(void)setCountWrongPasswordKey:(NSString*)value{
    [KeyChainSecurity storeString:value Key:kCOUNT_ENTER_WRONG_PWD];
}

-(void)removeCountWrongPasswordKey{
    [KeyChainSecurity removeKey:kCOUNT_ENTER_WRONG_PWD];
}

-(void)downloadTokenAgain:(NSDictionary*)retryInfo{
    // only redownload if account is active
    BOOL isActive = [[[[ContactFacade share] getAccountStatus] lowercaseString]
                     isEqual:ACCOUNT_ACTIVE];
    
    NSInteger status_code = [[retryInfo objectForKey:kSTATUS_CODE] integerValue];
    switch (status_code) {
        case ERROR_CODE_EXPIRED_COMMAND_TOKEN_TENANT:
        case ERROR_CODE_EXPIRED_COMMAND_TOKEN_CENTRAL:
            if ([retryInfo[kRETRY_TIME] intValue] > 0 && isActive)
                [[ContactFacade share] loginAccount:retryInfo];
        break;
    }
}

- (void)callRetryFunctionAfterSuccessful:(NSDictionary*)retryInfo{
    if (retryInfo && retryInfo[kRETRY_OPERATION]) {
        NSOperation* retryOperation = retryInfo[kRETRY_OPERATION];
        [retryOperation start];
    }
}

- (void)addBlankViewForSnapShotPrevention:(UIWindow*)window {
    [DeviceSecurity addBlankViewForSnapShotPrevention:window];
}

- (void)removeBlankViewForSnapShotPrevention:(UIWindow*)window {
    [DeviceSecurity removeBlankViewForSnapShotPrevention:window];
}

-(void)removeCacheDataInsideApp {
    [DeviceSecurity removeCacheDataInsideApp];
}

+(BOOL)isJailbroken
{
    return [DeviceSecurity isJailbroken];
}

- (void)callReUploadPasscodeToServer{
    NSString* isReloadPasscode = [KeyChainSecurity getStringFromKey:kREUPLOAD_PASSWORD];
    if(isReloadPasscode.length > 0 && [isReloadPasscode rangeOfString:IS_YES].location != NSNotFound){
        NSString* typeForm = [isReloadPasscode componentsSeparatedByString:@"-"][1];
        [[ContactFacade share] updatePasscodeToServerwithType:[typeForm integerValue]
                                              retryUploadTime:[kRETRY_API_COUNTER intValue]];
    }
}

-(int) compareVersion:(NSString *)strVer1 withVersion:(NSString *)strVer2
{
    NSArray *arrVer1 = [strVer1 componentsSeparatedByString:@"."];
    NSArray *arrVer2 = [strVer2 componentsSeparatedByString:@"."];
    
    for (int counter = 0 ; counter < (([arrVer1 count] < [arrVer2 count]) ? [arrVer1 count] : [arrVer2 count]) ; ++counter)
        if ([[arrVer1 objectAtIndex:counter] intValue] > [[arrVer2 objectAtIndex:counter] intValue])
            return 1;
        else if ([[arrVer1 objectAtIndex:counter] intValue] < [[arrVer2 objectAtIndex:counter] intValue])
            return -1;
    
    if ([arrVer1 count] > [arrVer2 count])
        return 1;
    else if ([arrVer1 count] < [arrVer2 count])
        return -1;
    return 0;
}

-(BOOL)isStringContainWebLink:(NSString *)str
{
    if (str.length==0)
        return NO;
    
    NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink
                                                               error:nil];
    NSArray* resultString = [detector matchesInString:str options:NSMatchingReportProgress range:NSMakeRange(0, [str length])];
    return resultString.count > 0;
}

-(BOOL)isStringContainPhoneNumber:(NSString *)str{
    if (str.length==0)
        return NO;
    
    NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypePhoneNumber
                                                               error:nil];
    NSArray* resultString = [detector matchesInString:str options:NSMatchingReportProgress range:NSMakeRange(0, [str length])];
    return resultString.count > 0;
}

-(BOOL)preProcessResponse:(NSDictionary*)response{
    if ([[response objectForKey:kSTATUS_CODE] isEqual:[NSNumber numberWithInt:ERROR_STATUS_CODE_SERVER_MAINTERNACE]] ) {
        [[CAlertView new] showError:[response objectForKey:kSTATUS_MSG]];
        return TRUE;
    }
    return FALSE;
}

- (NSOperation *)executeBlock:(void (^)(void))block
                      inQueue:(NSOperationQueue *)queue
                   completion:(void (^)(BOOL finished))completion
{
    NSOperation *blockOperation = [NSBlockOperation blockOperationWithBlock:block];
    NSOperation *completionOperation = [NSBlockOperation blockOperationWithBlock:^{
        completion(blockOperation.isFinished);
    }];
    [completionOperation addDependency:blockOperation];
    
    [[NSOperationQueue currentQueue] addOperation:completionOperation];
    [queue addOperation:blockOperation];
    return blockOperation;
}

@end



