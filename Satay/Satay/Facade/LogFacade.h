//
//  LogFacade.h
//  Satay
//
//  Created by MTouche on 4/21/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <LogDomain/LogDomain.h>

#define IS_CRASH @"IS_CRASH"
#define IS_SEND_LOG @"IS_SEND_LOG"
#define kENABLE_SEND_CRASHLOG_VIA_EMAIL @"ENABLE_SEND_CRASHLOG_VIA_EMAIL"
#define kENABLE_REMOTE_LOG @"ENABLE_REMOTE_LOG"

@interface LogFacade : NSObject

typedef void (^PushAllLogCallBack)(BOOL success, NSError *error);
typedef void (^PushLogCallBack)(BOOL success, NSDictionary *response, NSError *error);
@property (nonatomic, getter = isRemoteLogEnable) BOOL remoteLogEnable;

/*
 *Singleton of this file
 *@Author TrungVN
 */
+(LogFacade *)share;



/**
 *  Log debug
 *  @author Daryl
 *  @param paramettersDic must have value for keys: LOG_CLASS, LOG_CATEGORY, LOG_MESSAGE, LOG_EXTRA1, LOG_EXTRA2
 */
- (void)logDebugWithDic:(NSDictionary *)paramettersDic;

/**
 *  Log Info
 *  @author Daryl
 *  @param paramettersDic must have value for keys: LOG_CLASS, LOG_CATEGORY, LOG_MESSAGE, LOG_EXTRA1, LOG_EXTRA2
 */
- (void)logInfoWithDic:(NSDictionary *)paramettersDic;

/**
 *  Log Notice
 *  @author Daryl
 *  @param paramettersDic must have value for keys: LOG_CLASS, LOG_CATEGORY, LOG_MESSAGE, LOG_EXTRA1, LOG_EXTRA2
 */
- (void)logNoticeWithDic:(NSDictionary *)paramettersDic;

/**
 *  Log Warning
 *  @author Daryl
 *  @param paramettersDic must have value for keys: LOG_CLASS, LOG_CATEGORY, LOG_MESSAGE, LOG_EXTRA1, LOG_EXTRA2
 */
- (void)logWarningWithDic:(NSDictionary *)paramettersDic;

/**
 *  Log Error
 *  @author Daryl
 *  @param paramettersDic must have value for keys: LOG_CLASS, LOG_CATEGORY, LOG_MESSAGE, LOG_EXTRA1, LOG_EXTRA2
 */
- (void)logErrorWithDic:(NSDictionary *)paramettersDic;

/**
 *  Log Critical
 *  @author Daryl
 *  @param paramettersDic must have value for keys: LOG_CLASS, LOG_CATEGORY, LOG_MESSAGE, LOG_EXTRA1, LOG_EXTRA2
 */
- (void)logCriticalWithDic:(NSDictionary *)paramettersDic;

/**
 *  Log Alert
 *  @author Daryl
 *  @param paramettersDic must have value for keys: LOG_CLASS, LOG_CATEGORY, LOG_MESSAGE, LOG_EXTRA1, LOG_EXTRA2
 */
- (void)logAlertWithDic:(NSDictionary *)paramettersDic;

/**
 *  Push all log in system to server
 *
 *  @param parametersDic must have value for keys: REQUEST_SOURCE, REQUEST_DEVICE, REQUEST_OSVERSION, REQUEST_APPVERSION, REQUEST_SCENARIO, REQUEST_FORMAT, REQUEST_EXTRA1, REQUEST_EXTRA2

 */
- (void)pushAllLogToServerWithDic: (NSDictionary*)parametersDic;

/**
 *  Push all log in system to server
 *
 *  @param parametersDic must have value for keys: REQUEST_SOURCE, REQUEST_DEVICE, REQUEST_OSVERSION, REQUEST_APPVERSION, REQUEST_SCENARIO, REQUEST_FORMAT, REQUEST_EXTRA1, REQUEST_EXTRA2, REQUEST_CONTENT
    value of REQUEST_CONTENT is array of log will push to server in dictionary format.
 
 */
- (void)pushLogToServerWithDic: (NSDictionary *)paramtersDic callback:(PushLogCallBack)callback;

/**
 * Save crash to file.
 * Author: Daryl
 */
- (void)crashHandler:(NSException*) exception;

-(void) clearAllActivityLogs;

/*
 * It will check if app is crashed then send email to developer.
 */
-(void) sendCrashReportViaEmail;
-(void) sendRemoteLogViaEmail;

-(void) setEnableSendCrashViaEmail:(BOOL) enable;

-(void)remoteLogEnable:(BOOL)remoteLogEnable;

-(BOOL) getEnableSendCrashViaEmail;

- (NSString*) crashContent;

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

-(NSDictionary *)EncryptMessageInDic:(NSDictionary *)inputDic;

-(NSDictionary *)DecryptMessageInDic:(NSDictionary *)inputDic;


@end
