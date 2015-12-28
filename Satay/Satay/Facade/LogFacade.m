//
//  LogFacade.m
//  Satay
//
//  Created by MTouche on 4/21/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import "LogFacade.h"
#import <MessageUI/MessageUI.h>
#import <UIKit/UIKit.h>

@import MessageUI;

#define DEVICE_NAME_STR @"Device name"
#define DEVICE_MODEL_STR @"Device model"
#define OS_NAME_STR @"OS name"
#define OS_VERSION_STR @"OS version"
#define APP_VERSION_STR @"App version"


@interface LogFacade ()

@property (nonatomic, retain) NSString *source;
@property (nonatomic, retain) NSString *currentSessionID;
@property (nonatomic, strong) NSMutableArray *allLog;
@property (nonatomic, strong) NSMutableArray *allSessionID;
@property (nonatomic, strong) NSMutableArray *subArrayUseInPush;

@property (nonatomic) int maxNumberOfLogsPerPush;
@property (nonatomic) int counterFailed;
@property (nonatomic) NSOperationQueue *logQueue;

@end

@implementation LogFacade

+(LogFacade *)share{
    static dispatch_once_t once;
    static LogFacade * share;
    dispatch_once(&once, ^{
        share = [self new];
        share.maxNumberOfLogsPerPush = 50;
        share.logQueue = [NSOperationQueue new];
        share.logQueue.maxConcurrentOperationCount = 1;
        if ([[KeyChainSecurity getStringFromKey:kENABLE_REMOTE_LOG] isEqualToString:@"YES"])
            [share remoteLogEnable:YES];
        else
            [share remoteLogEnable:NO];
    });
    return share;
}

-(void)remoteLogEnable:(BOOL)remoteLogEnable
{
    self.remoteLogEnable = remoteLogEnable;
    if (remoteLogEnable) {
        [KeyChainSecurity storeString:@"YES" Key:kENABLE_REMOTE_LOG];
    }
    else{
        [KeyChainSecurity storeString:@"NO" Key:kENABLE_REMOTE_LOG];
    }
}

- (void)logDebugWithDic:(NSDictionary *)paramettersDic
{
    __block NSDictionary *blockDic = paramettersDic;
    __block LogFacade *blockSelf = self;
    [self.logQueue addOperationWithBlock:^(){
        NSDictionary *encryptDic =  [blockSelf EncryptMessageInDic:blockDic];
        if (encryptDic)
            [[LogAdapter share] logWithLevel:100 ParaDic:encryptDic];
    }];
    
}

- (void)logInfoWithDic:(NSDictionary *)paramettersDic
{
    __block NSDictionary *blockDic = paramettersDic;
    __block LogFacade *blockSelf = self;
    [self.logQueue addOperationWithBlock:^(){
        NSDictionary *encryptDic =  [blockSelf EncryptMessageInDic:blockDic];
        if (encryptDic)
        [[LogAdapter share] logWithLevel:200 ParaDic:encryptDic];
    }];
}

- (void) logNoticeWithDic:(NSDictionary *)paramettersDic
{
    __block NSDictionary *blockDic = paramettersDic;
    __block LogFacade *blockSelf = self;
    [self.logQueue addOperationWithBlock:^(){
        NSDictionary *encryptDic =  [blockSelf EncryptMessageInDic:blockDic];
        if (encryptDic)
            [[LogAdapter share] logWithLevel:250 ParaDic:encryptDic];
    }];
}

- (void) logWarningWithDic:(NSDictionary *)paramettersDic
{
    __block NSDictionary *blockDic = paramettersDic;
    __block LogFacade *blockSelf = self;
    [self.logQueue addOperationWithBlock:^(){
        NSDictionary *encryptDic =  [blockSelf EncryptMessageInDic:blockDic];
        if (encryptDic)
            [[LogAdapter share] logWithLevel:300 ParaDic:encryptDic];
    }];
}

- (void) logErrorWithDic:(NSDictionary *)paramettersDic
{
    __block NSDictionary *blockDic = paramettersDic;
    __block LogFacade *blockSelf = self;
    [self.logQueue addOperationWithBlock:^(){
        NSDictionary *encryptDic =  [blockSelf EncryptMessageInDic:blockDic];
        if (encryptDic)
            [[LogAdapter share] logWithLevel:400 ParaDic:encryptDic];
    }];
}

- (void) logCriticalWithDic:(NSDictionary *)paramettersDic
{
    __block NSDictionary *blockDic = paramettersDic;
    __block LogFacade *blockSelf = self;
    [self.logQueue addOperationWithBlock:^(){
        NSDictionary *encryptDic =  [blockSelf EncryptMessageInDic:blockDic];
        if (encryptDic)
            [[LogAdapter share] logWithLevel:500 ParaDic:encryptDic];
    }];
}

- (void) logAlertWithDic:(NSDictionary *)paramettersDic
{
    __block NSDictionary *blockDic = paramettersDic;
    __block LogFacade *blockSelf = self;
    [self.logQueue addOperationWithBlock:^(){
        NSDictionary *encryptDic =  [blockSelf EncryptMessageInDic:blockDic];
        if (encryptDic)
            [[LogAdapter share] logWithLevel:550 ParaDic:encryptDic];
    }];
}

- (void) logEmergencyWithDic:(NSDictionary *)paramettersDic
{
    __block NSDictionary *blockDic = paramettersDic;
    __block LogFacade *blockSelf = self;
    [self.logQueue addOperationWithBlock:^(){
        NSDictionary *encryptDic =  [blockSelf EncryptMessageInDic:blockDic];
        if (encryptDic)
            [[LogAdapter share] logWithLevel:600 ParaDic:encryptDic];
    }];
}

- (void) pushLogToServerWithDic:(NSDictionary *)paramtersDic callback:(PushLogCallBack)callback
{
    void (^localPushLogCallBack)(BOOL success, NSDictionary *response, NSError *error);
    localPushLogCallBack = callback;
    /*
     NSDictionary *paramtersDic = @{REQUEST_SOURCE: @"App name",
                                    REQUEST_DEVICE: [[LogAdapter share] getDeviceName],
                                 REQUEST_OSVERSION: [[LogAdapter share] getOSVersion],
                                REQUEST_APPVERSION: [[LogAdapter share] getAppVersion],
                                  REQUEST_SCENARIO: @"any scenario",
                                    REQUEST_FORMAT: @"abc123haha",
                                   REQUEST_CONTENT: arrayOfLog in dictionary format
                                    REQUEST_EXTRA1: @"JID or MaskingID"
                                    REQUEST_EXTRA2: @"Extra 1 value" (JID or MaskingID)
     };
     */
    
    [[LogAdapter share] pushLogsToServerWithDic:paramtersDic callback:^(BOOL success, NSDictionary *response, NSError *error){
        if (success) {
            localPushLogCallBack(YES, response, nil);
        }
        else {
            localPushLogCallBack(NO, response, error);
        }
    }];
}

- (void) pushAllLogToServerWithDic:(NSDictionary *)parametersDic
{    /*
     NSDictionary *paramtersDic = @{REQUEST_SOURCE: @"App Name"@,
                                    REQUEST_DEVICE: [[LogAdapter share] getDeviceName],
                                 REQUEST_OSVERSION: [[LogAdapter share] getOSVersion],
                                REQUEST_APPVERSION: [[LogAdapter share] getAppVersion],
                                    REQUEST_FORMAT: @"json",
                                    REQUEST_EXTRA1: @"JID or MaskingID"
                                    REQUEST_EXTRA2: @"JID or MaskingID value"
     };
     */
    
    self.allSessionID = [[[LogAdapter share] getAllSession] mutableCopy];
    
    // Create Sub array by session ID.
    NSMutableArray *ArrayBySession = [[NSMutableArray alloc] init];
    for (int index = 0; index < [self.allSessionID count]; index++) {
        NSArray *tempArray = [[LogAdapter share] getLogWithSessionID:[self.allSessionID objectAtIndex:index]];
        [ArrayBySession addObject:tempArray];
    }
    
    for (int index = 0; index < [ArrayBySession count]; index++) {
        NSMutableArray *subArraytoPush = [[NSMutableArray alloc] init];
        NSArray *array = [ArrayBySession objectAtIndex:index];
        NSString *currentSessionID = [self.allSessionID objectAtIndex:index];
        
        // Slipt to smaller array base on maxNumberOfLogsPerPush property default is 50;
        for (int tempIndex = 0; tempIndex * self.maxNumberOfLogsPerPush < [array count]; tempIndex++) {
            NSUInteger start = tempIndex * self.maxNumberOfLogsPerPush ;
            NSRange range = NSMakeRange(start, MIN([array count] - start, self.maxNumberOfLogsPerPush));
            [subArraytoPush addObject:[array subarrayWithRange:range]];
        }
        
        // begin Push.
        for (NSArray *arrayOfLog in subArraytoPush) {
            
            NSMutableDictionary *pushDictionary = [parametersDic mutableCopy];
            NSArray *logArrayInDic = [self getArrayOfLogInDictionary:arrayOfLog];
            
            [pushDictionary setObject:logArrayInDic forKey:REQUEST_CONTENT];
            [pushDictionary setObject:currentSessionID forKey:REQUEST_SESSION_ID];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
                [[LogAdapter share] pushLogsToServerWithDic:pushDictionary
                                                   callback:^(BOOL success, NSDictionary *response, NSError *error){
                    if (success) {
                        [[LogAdapter share] removeArrayOfLog:arrayOfLog];
                    }
                    else{
                        
                        // error code = 4 mean invalid data. we remove it.
                        if (error.code == 4) {
                            [[LogAdapter share] removeArrayOfLog:arrayOfLog];
                        }
                    }
                }];                
            });
        }
    }
}

-(NSDictionary *)EncryptMessageInDic:(NSDictionary *)inputDic
{
    NSString *message = [inputDic objectForKey:LOG_MESSAGE];
    NSData *messageData = [message dataUsingEncoding:NSUTF8StringEncoding];
    NSData *encryptData = [[AppFacade share] encryptDataLocally:messageData];
    NSString *encryptString = [Base64Security generateBase64String:encryptData];
    NSMutableDictionary *newDic = [inputDic mutableCopy];
    if(encryptString)
        [newDic setObject:encryptString forKey:LOG_MESSAGE];
    else{
        // Can not encrypt
        NSLog(@"Cannot encrypt Dic: %@",inputDic);
        newDic = nil;
    }
    return newDic;
}

-(NSDictionary *)DecryptMessageInDic:(NSDictionary *)inputDic
{
    NSString *message = [inputDic objectForKey:LOG_MESSAGE];
    NSData *base64Data = [Base64Security decodeBase64String:message];
    NSData *decryptData = [[AppFacade share] decryptDataLocally:base64Data];
    message = [[NSString alloc] initWithData:decryptData encoding:NSUTF8StringEncoding];
    NSMutableDictionary *newDic = [inputDic mutableCopy];
    if(message){
        [newDic setObject:message forKey:LOG_MESSAGE];
    }
    else {
        // Can not decrypt
        NSLog(@"Cannot decrypt Dic: %@",inputDic);
        newDic = nil;
    }
    return newDic;
}

- (NSArray *)getArrayOfLogInDictionary: (NSArray *)array
{
    NSMutableArray *logArrayInDic = [[NSMutableArray alloc] init];
    
    for (SRDLogContent *logItem in array) {
        NSDictionary *LogDic = [[LogAdapter share] getDictionaryOfLog:logItem];
        LogDic = [self DecryptMessageInDic:LogDic];
        if (LogDic) // log dictionary valid
            [logArrayInDic addObject:LogDic];
        else // log dictionary invalid, we delete log it.
            [[LogAdapter share] removeLog:logItem];
    }
    return [logArrayInDic copy];
}

- (NSArray *)getNumberOFLogs:(int)number inArray:(NSArray *)array
{
    NSUInteger count = MIN( [array count], number );
    return [array subarrayWithRange:NSMakeRange(0, count)];
}

- (NSString *)getSource
{
    return self.source;
}

/**
 * Load google analysic tracker.
 * Author: Jurian
 */
- (void) loadTracker{
    [[LogAdapter share] loadTracker];
}

/**
 * Load tracking Screen.
 * Author: Jurian
 */
- (void)trackingScreen:(NSString*)screenName{
    [[LogAdapter share] trackingScreen:screenName];
}

/**
 * Create an event for updating google analysis.
 * @param category Category name of google analysis app
 * @param action Action name of google analysis app
 * @param action label name of google analysis app
 * Author: Jurian
 */
- (void)createEventWithCategory:category
                         action:action
                          label:labelAction{
    [[LogAdapter share] createEventWithCategory:category action:action label:labelAction];
}

- (void)crashHandler:(NSException*) exception {
    [KeyChainSecurity storeString:@"YES" Key:IS_CRASH];
    UIDevice *currentDevice = [UIDevice currentDevice];
    NSString *crashContent = @"";
    NSString *generalInfo = [NSString stringWithFormat:@"%@: %@ \n %@: %@ \n %@: %@ \n %@: %@ \n %@: %@ \n\n",
                             DEVICE_NAME_STR, currentDevice.name,
                             DEVICE_MODEL_STR, currentDevice.model,
                             OS_NAME_STR, currentDevice.systemName,
                             OS_VERSION_STR, currentDevice.systemVersion,
                             APP_VERSION_STR, APP_VERSION];
    
    NSString *logReasonExc = [NSString stringWithFormat:@"(%@) - %@ \n",[ChatAdapter convertDateToString:[NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]]  format:FORMAT_DATE_MMMDDYYYHMMA] , exception.reason];
    crashContent = [crashContent stringByAppendingString:generalInfo];
    crashContent = [crashContent stringByAppendingString:logReasonExc];
    NSArray* traceCrashArray = [exception callStackSymbols];
    for (int i= 0; i < traceCrashArray.count; i++) {
        NSString *logMessage = [NSString stringWithFormat:@"(%@) - %@ \n",[ChatAdapter convertDateToString:[NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]]  format:FORMAT_DATE_MMMDDYYYHMMA], traceCrashArray[i]];
         crashContent = [crashContent stringByAppendingString:logMessage];
    }

    NSData *crashData = [crashContent dataUsingEncoding:NSUTF8StringEncoding];
    crashData = [[AppFacade share] encryptDataLocally:crashData];
    NSString* base64Content = [Base64Security generateBase64String:crashData];
    [[LogAdapter share] crashHandlerWithLogTrackStr:base64Content];
}

- (NSString*) crashContent{
    NSData* contentData = [[LogAdapter share] getCrashLogFileData];
    NSString* contentString = [[NSString alloc] initWithData:contentData
                                                    encoding:NSUTF8StringEncoding];
    NSString *crashContent = @"";
    if (contentString.length > 0) {
        NSData* base64Content = [Base64Security decodeBase64String:contentString];
        NSData* decryptData = [[AppFacade share] decryptDataLocally:base64Content];
        if (decryptData.length > 0)
            crashContent = [[NSString alloc] initWithData:decryptData
                                                 encoding:NSUTF8StringEncoding];
    }
    
    return crashContent;
}

-(void)setEnableSendCrashViaEmail:(BOOL)enable
{
    if (enable)
        [KeyChainSecurity storeString:@"YES" Key:kENABLE_SEND_CRASHLOG_VIA_EMAIL];
    else
        [KeyChainSecurity storeString:@"NO" Key:kENABLE_SEND_CRASHLOG_VIA_EMAIL];
    
    // Reset flag, effect after setting change
    [KeyChainSecurity storeString:@"NO" Key:IS_CRASH];
}

-(BOOL)getEnableSendCrashViaEmail
{
    NSString *enableSendLog = [KeyChainSecurity getStringFromKey:kENABLE_SEND_CRASHLOG_VIA_EMAIL];
    return[enableSendLog isEqualToString:@"YES"];
}

-(void) clearAllActivityLogs{
    [[LogAdapter share] clearLogs];
}

/*
 * This function will be call when user first open Kypto app
 * It will check if app is crashed then send email to developer.
 */
-(void) sendCrashReportViaEmail
{
    NSString *isCrashStr = [KeyChainSecurity getStringFromKey:IS_CRASH];
    NSString *crashContent = [self crashContent];
    if (![self getEnableSendCrashViaEmail] || ![isCrashStr isEqualToString:@"YES"] || crashContent.length==0)
        return;
    
    [[CWindow share] showEmail:@"support@onekrypto.com"
                         title:@"IOS Report Crashed App"
                          body:crashContent
               attacthmentData:nil
           attacthmentDataType:@""
           attacthmentFileName:@""];
    
}

-(NSArray *)arrAllDecryptlogs{
    NSArray *arrAllEncryptlogs = [[LogAdapter share] getAllLog];
    NSArray *arrAllDecryptlogs = [self getArrayOfLogInDictionary:arrAllEncryptlogs];
    return arrAllDecryptlogs;
}

-(void)sendRemoteLogViaEmail
{
    NSArray *arrDecryptData = [self arrAllDecryptlogs];
    if (arrDecryptData.count == 0) {
        [[CAlertView new] showError:@"Log file doesn't have content"];
        return;
    }
    
    NSString *error;
    NSData *data = [NSPropertyListSerialization dataFromPropertyList:arrDecryptData
                                                              format:NSPropertyListXMLFormat_v1_0
                                                    errorDescription:&error];
    
    if(data.length == 0 || error){
        [[CAlertView new] showError:@"Attachment error!"];
        return;
    }
 
    [KeyChainSecurity storeString:@"YES" Key:IS_SEND_LOG];
    NSString *body = @"System Auto generated content";
    
    [[CWindow share] showEmail:@"support@onekrypto.com"
                         title:@"Debug Log Report"
                          body:body
               attacthmentData:data
           attacthmentDataType:@"text/plain"
           attacthmentFileName:@"Soto_Log.txt"];

}



@end
