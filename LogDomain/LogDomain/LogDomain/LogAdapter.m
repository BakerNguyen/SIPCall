//
//  LogDomainAdpter.m
//  LogDomain
//
//  Created by Duong (Daryl) H. DANG on 4/20/15.
//  Copyright (c) 2015 Duong (Daryl) H. DANG. All rights reserved.
//

#import "LogAdapter.h"
#import "SRDLogStore.h"
#import "SRDRequestAPIObject.h"
#import "SRDHTTPClient.h"
#import "SRDConstants.h"
#import "SRDLogContent.h"
#import "CocoaLumberjack.h"
#import "GAIHeader.h"


#define DEVICE_NAME_STR @"Device name"
#define DEVICE_MODEL_STR @"Device model"
#define OS_NAME_STR @"OS name"
#define OS_VERSION_STR @"OS version"
#define APP_VERSION_STR @"App version"


//Logging
#ifdef DEBUG
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelError;
#endif

@interface LogAdapter ()

@property (nonatomic,strong) id<GAITracker> tracker;
@property (nonatomic, retain) NSString *baseURL;
@property (nonatomic, retain) NSString *source;

@property (nonatomic) int maxNumberOfLogsPerPush;
@property (nonatomic) int maxNumberOfLogsStorage;

// After each time push log error, we will decrease number of log per push until it meet min.
@property (nonatomic) int minNumberOfLogsPerPush;
@property (nonatomic) int percentDecrease;
@property (nonatomic) int counterFailed;
@property dispatch_queue_t concurrentQueue;

@end

@implementation LogAdapter

@synthesize tracker;
+ (instancetype)share{
    
    static LogAdapter *share = nil;
    
    // Thread-safe singletons.
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        share = [[self alloc] initPrivate];
        
        // Configure CocoaLumberjack
        setenv("XcodeColors", "YES", 0);
        [DDLog addLogger:[DDTTYLogger sharedInstance]];
        [[DDTTYLogger sharedInstance] setColorsEnabled:YES];
        [[DDTTYLogger sharedInstance] setForegroundColor:[UIColor greenColor] backgroundColor:nil forFlag:DDLogFlagInfo];
        [[DDTTYLogger sharedInstance] setForegroundColor:[UIColor redColor] backgroundColor:nil forFlag:DDLogFlagError];
        [[DDTTYLogger sharedInstance] setForegroundColor:[UIColor orangeColor] backgroundColor:nil forFlag:DDLogFlagWarning];
        [[DDTTYLogger sharedInstance] setForegroundColor:[UIColor lightGrayColor] backgroundColor:nil forFlag:DDLogFlagVerbose];

    });
    
    return share;
}

// Not allow defaut init create new instace.
- (instancetype)init
{
    @throw [NSException exceptionWithName:@"Singleton" reason:@"Use + [LogDomainAdpter shareInstance]" userInfo:nil];
    return nil;
}

// Private init.
- (instancetype)initPrivate
{
    if (self = [super init]) {
        
        if (![self loadConfigFileWithFileName:@"sotoConfig" Type:@"plist"]) {
            
            // Load default
            _source = @"OneKryptoChat";
            _maxNumberOfLogsStorage= 1000;
            _maxNumberOfLogsPerPush = 50;
            _minNumberOfLogsPerPush = 10;
            _percentDecrease = 10;
            _baseURL = BASE_URL;
            DDLogInfo(@"%s:SOTO:Load default config.", __PRETTY_FUNCTION__);
            
            
        }        
        _counterFailed = 0;
        [SRDHTTPClient sharedInstance].remoteURL = self.baseURL;
        [SRDLogStore shareInstance].maxStore = self.maxNumberOfLogsStorage;
    }
    
    return self;
}

#pragma mark --- External function  ---

- (BOOL)loadConfigFileWithFileName:(NSString *)fileName Type:(NSString *)fileType
{
    NSString *path = [[NSBundle mainBundle] pathForResource:fileName ofType:fileType];
    
    if([[NSFileManager defaultManager] fileExistsAtPath:path]){
        
        NSDictionary *settings = [[NSDictionary alloc] initWithContentsOfFile:path];
        NSString *baseURL, *source;
        int maxStorage,maxItem, minItem, percentDecrease;
        
        // Check Source.
        if([settings valueForKey:REQUEST_SOURCE] !=nil ){
            
            source = [settings valueForKey:REQUEST_SOURCE];
            
            if ([source isEqualToString:STRING_EMPTY]) {
                return NO;
            }
        }
        else{
            return NO;
        }
        
        // Check base URL.
        if([settings valueForKey:CONFIG_URL] !=nil ){
            
            baseURL = [settings valueForKey:CONFIG_URL];
            
            if ([baseURL isEqualToString:STRING_EMPTY]) {
                return NO;
            }
        }
        else{
            return NO;
        }
        
        // Check max item storage.
        if([settings valueForKey:CONFIG_MAXITEM_STORAGE] !=nil ){
            
            maxStorage = (int)[[settings valueForKey:CONFIG_MAXITEM_STORAGE] integerValue];
            
            if (maxStorage < 0) {
                return NO;
            }
        }
        else{
            return NO;
        }
        
        // Check max item.
        if([settings valueForKey:CONFIG_MAXITEM_PERPUSH] !=nil ){
            
            maxItem = (int)[[settings valueForKey:CONFIG_MAXITEM_PERPUSH] integerValue];
            
            if (maxItem < 0) {
                return NO;
            }
        }
        else{
            return NO;
        }
        
        // Check min item.
        if([settings valueForKey:CONFIG_MINITEM_PERPUSH] !=nil ){
            minItem = (int)[[settings valueForKey:CONFIG_MINITEM_PERPUSH] integerValue];
            
            if(minItem > maxItem || minItem < 0){
                return NO;
            }
        }
        else{
            return NO;
        }
        
        // Check percent decrease.
        if([settings valueForKey:CONFIG_PERCENT_DECREASE] !=nil ){
            percentDecrease = (int)[[settings valueForKey:CONFIG_PERCENT_DECREASE] integerValue];
            
            if (percentDecrease > 100 || percentDecrease <0){
                return NO;
            }
        }
        else{
            return NO;
        }
        
        // All configurations is valid, load config.
        self.source = source;
        self.baseURL = baseURL;
        self.maxNumberOfLogsPerPush = maxItem;
        self.minNumberOfLogsPerPush = minItem;
        self.percentDecrease = percentDecrease;
        self.maxNumberOfLogsStorage = maxStorage;
        DDLogInfo(@"%s:SOTO: Load config file success", __PRETTY_FUNCTION__);
       
        return YES;
    }
    else
    {
        DDLogError(@"%s:SOTO: Config file not found", __PRETTY_FUNCTION__);
        return NO;
    }
}

//- (void) logDebugWithClass:(NSString *)logClass Category:(NSString *)category Message:(NSString *)message logExtra1:(NSString *)extra1
//                 logExtra2:(NSString *)extra2
//{
//    [self logWithLevel:100 Class:logClass Category:category Message:message logExtra1:extra1 logExtra2:extra2];
//}

- (void)logDebugWithDic:(NSDictionary *)paramettersDic
{
    [self logWithLevel:100 ParaDic:paramettersDic];
}

//- (void) logInfoWithClass:(NSString *)logClass Category:(NSString *)category Message:(NSString *)message logExtra1:(NSString *)extra1
//                logExtra2:(NSString *)extra2
//{
//    [self logWithLevel:200 Class:logClass Category:category Message:message logExtra1:extra1 logExtra2:extra2];
//}

- (void) logInfoWithDic:(NSDictionary *)paramettersDic
{
    [self logWithLevel:200 ParaDic:paramettersDic];
}

//- (void) logNoticeWithClass:(NSString *)logClass Category:(NSString *)category Message:(NSString *)message logExtra1:(NSString *)extra1
//                  logExtra2:(NSString *)extra2
//{
//    [self logWithLevel:250 Class:logClass Category:category Message:message logExtra1:extra1 logExtra2:extra2];
//}

- (void) logNoticeWithDic:(NSDictionary *)paramettersDic
{
    [self logWithLevel:250 ParaDic:paramettersDic];

}

//- (void) logWarningWithClass:(NSString *)logClass Category:(NSString *)category Message:(NSString *)message logExtra1:(NSString *)extra1
//                  logExtra2:(NSString *)extra2
//{
//    [self logWithLevel:300 Class:logClass Category:category Message:message logExtra1:extra1 logExtra2:extra2];
//}

- (void) logWarningWithDic:(NSDictionary *)paramettersDic
{
    [self logWithLevel:300 ParaDic:paramettersDic];
}

//- (void) logErrorWithClass:(NSString *)logClass Category:(NSString *)category Message:(NSString *)message logExtra1:(NSString *)extra1
//                 logExtra2:(NSString *)extra2
//{
//    [self logWithLevel:400 Class:logClass Category:category Message:message logExtra1:extra1 logExtra2:extra2];
//}

- (void) logErrorWithDic:(NSDictionary *)paramettersDic
{
    [self logWithLevel:400 ParaDic:paramettersDic];
}

//- (void) logCriticalWithClass:(NSString *)logClass Category:(NSString *)category Message:(NSString *)message logExtra1:(NSString *)extra1
//                    logExtra2:(NSString *)extra2
//{
//    [self logWithLevel:500 Class:logClass Category:category Message:message logExtra1:extra1 logExtra2:extra2];
//}

- (void) logCriticalWithDic:(NSDictionary *)paramettersDic
{
    [self logWithLevel:500 ParaDic:paramettersDic];
}

//- (void) logAlertWithClass:(NSString *)logClass Category:(NSString *)category Message:(NSString *)message logExtra1:(NSString *)extra1
//                 logExtra2:(NSString *)extra2
//{
//    [self logWithLevel:550 Class:logClass Category:category Message:message logExtra1:extra1 logExtra2:extra2];
//}

- (void) logAlertWithDic:(NSDictionary *)paramettersDic
{
    [self logWithLevel:550 ParaDic:paramettersDic];
}

//- (void) logEmergencyWithClass:(NSString *)logClass Category:(NSString *)category Message:(NSString *)message logExtra1:(NSString *)extra1
//                     logExtra2:(NSString *)extra2
//{
//    [self logWithLevel:600 Class:logClass Category:category Message:message logExtra1:extra1 logExtra2:extra2];
//}

- (void) logEmergencyWithDic:(NSDictionary *)paramettersDic
{
    [self logWithLevel:600 ParaDic:paramettersDic];
}

- (void)logWithLevel:(NSInteger)level
             ParaDic:(NSDictionary *)parametterDic
{
    NSMutableDictionary *logDic = [parametterDic mutableCopy];
    [logDic setObject:[NSNumber numberWithInteger:level] forKey:LOG_LEVEL];
    [[SRDLogStore shareInstance] createLogWithLogDic:logDic];
}

//- (void)startQueueWithScenario: (NSString *)scenario Extra1:(NSString *)extra1 Extra2:(NSString *)extra2
//{
//    if (!_termAndConditionFlag) {
//        return;
//    }
//    
//    self.counterFailed = 0;
//    
//    // Push all log to server after 10s.
//        if (self.firstPush) {
//    [self pushAllLogsToServerAfterNumberOfSeconds:10
//                                     withScenario:scenario
//                                           Format:STRING_JSON
//                                           Extra1:extra1
//                                           Extra2:extra2];
//    self.firstPush = NO;
//    self.isPushAll = YES;
//        }
//}

- (BOOL)saveLogsToFile
{
   return [[SRDLogStore shareInstance] saveLogs];
}

- (BOOL)clearLogs
{
   return [[SRDLogStore shareInstance] clearAllLogs];
}

- (void)removeLog:(SRDLogContent *)log
{
    [[SRDLogStore shareInstance] removeLog:log];
}

- (void)removeArrayOfLog:(NSArray *)array
{
    [[SRDLogStore shareInstance] removeArrayOfLog:array];
}


- (NSDictionary *)getDictionaryOfLog:(SRDLogContent *) log
{
    return [log getLogInDictionaryNotIncludeSession];
}

- (NSData *)logFileData
{
    if ([SRDLogStore shareInstance].logCount == 0)
        return nil;
    
    NSString *filePath = [[SRDLogStore shareInstance] itemArchivePath];
    NSData *logData = [[NSData alloc] initWithContentsOfFile:filePath];
    return logData;
}

/*
- (void)pushAllLogsToServerWithScenario:(NSString *) scenario
                                 Format:(NSString *)format
                              logExtra1:(NSString *)extra1
                              logExtra2:(NSString *)extra2
                               callback:(PushLogCallBack)callback
{
    if (!_termAndConditionFlag) {
        return;
    }
    
    void (^localPushLogCallBack)(BOOL success, NSDictionary *response, NSError *error);
    localPushLogCallBack = callback;
    
    
    if ([SRDLogStore shareInstance].logCount > 0) {
        NSArray *logsArray = [[SRDLogStore shareInstance] getNUMBerOfLogsInRequestArray:_maxNumberOfLogsPerPush];
    
        [[SRDHTTPClient sharedInstance] pushLogsToServerWithSource:self.source
                                                          Scenario:scenario
                                                            Format:format
                                                        ArrayOfLog:logsArray
                                                            Extra1:extra1
                                                            Extra2:extra2
                                                          callback:^(BOOL success, NSDictionary *response, NSError *error){
                                                                if (success) {
                                                                    // remove log.
                                                                    [[SRDLogStore shareInstance] removeArrayOfLog:logsArray];
                                                                    [[SRDLogStore shareInstance] saveLogs];                                                                   
                                                                    
                                                                    // Continue push after 5 seconds.
                                                                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                                                        [self pushAllLogsToServerWithScenario:scenario
                                                                                                       Format:format
                                                                                                    logExtra1:extra1
                                                                                                    logExtra2:extra2
                                                                                                     callback:callback];
                                                                    });
                                                                }
                                                                else{
                                                                   
                                                                    self.counterFailed ++;
                                                                    
                                                                    // error code = 4 mean invalid data. we remove it.
                                                                    if (error.code == 4) {
                                                                        // Remove logs array and save changes.
                                                                        [[SRDLogStore shareInstance] removeArrayOfLog:logsArray];
                                                                        [[SRDLogStore shareInstance] saveLogs];
                                                                        self.counterFailed = 0;
                                                                    }
                                                                    
                                                                    // if counter fail < 10, keep push log.
                                                                    if (self.counterFailed < 10) {
                                                                        //1. Reduce number of logs will be send.
//                                                                        [self modifyNumberOfLogSendPerRequest];
                                                                        
                                                                        // 2. Continue send.
                                                                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                                                            [self pushAllLogsToServerWithScenario:scenario
                                                                                                           Format:format
                                                                                                        logExtra1:extra1
                                                                                                        logExtra2:extra2
                                                                                                         callback:callback];
                                                                        });
                                                                    }
                                                                    else{
                                                                        // push process fail.
                                                                        localPushLogCallBack(NO,response,error);
                                                                    }
                                                                }
                                                        }];
    }
    else
    {
        // Return yes if no more log.
        localPushLogCallBack(YES,nil,nil);
    }
}
*/
 
- (void)pushLogsToServerWithDic:(NSDictionary *)paramettersDic callback:(PushLogCallBack)callback
{
    void (^localPushLogCallBack)(BOOL success, NSDictionary *response, NSError *error);
    localPushLogCallBack = callback;
    [[SRDHTTPClient sharedInstance] pushLogsTOServerWithDic:paramettersDic
                                                   callback:^(BOOL success, NSDictionary *response, NSError *error){
                                                       if (success) {
                                                           DDLogInfo(@"%s:Push success.", __PRETTY_FUNCTION__);
                                                           localPushLogCallBack(YES,response,nil);
                                                       }
                                                       else{
                                                           DDLogError(@"%s:Push log fail: %@", __PRETTY_FUNCTION__, error.localizedDescription);
                                                           if (!response) {
                                                               DDLogInfo(@"%s %@", __PRETTY_FUNCTION__, response);
                                                           }
                                                           localPushLogCallBack(NO,response,error);
                                                       }
                                                   }];
}

- (NSArray *)getAllLog
{
    return [[SRDLogStore shareInstance] getAllLog];
}

- (NSArray *)getAllSession
{
    return [[SRDLogStore shareInstance] getAllSession];
}

- (NSArray *)getLogWithSessionID:(NSString *)sessionID
{
    return [[SRDLogStore shareInstance] getArrayWithSessionID:sessionID];

}

- (NSString*) getDeviceName
{
    return [[UIDevice currentDevice] name];
}

- (NSString*) getOSVerion
{
    return [[UIDevice currentDevice] systemVersion];
}

- (NSString *)getSystemName
{
    return [[UIDevice currentDevice] systemName];
}

- (NSString *)getdeviceModel
{
    return [[UIDevice currentDevice] model];
}

- (NSString*) getAppVersion
{
    return [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];
}

- (NSData *)getCrashLogFileData{
    NSString *filePath = [[SRDLogStore shareInstance] crashLogPath];
    NSData *logData = [[NSData alloc] initWithContentsOfFile:filePath];
    return logData;
}

- (void)crashHandlerWithLogTrackStr:(NSString*) LogTrackStr {

    NSString *crashLogPath = [[SRDLogStore shareInstance] crashLogPath];
    [[SRDLogStore shareInstance] createNewFile:crashLogPath];
    [[SRDLogStore shareInstance] appendToFile:crashLogPath Content:LogTrackStr];
}


#pragma mark --- Internal function  ---

/**
 *  Create log with log_level, log_class, log_category, log_message.
 *
 *  @param level    Log level name. Only support these level: debug (100), info (200), notice (250), warning (300), error (400), critical (500), alert (550), emergency (600).
 *  @param logClass Class name which is fired belong to scenario.
 *  @param category Category name which define the log message category.
 *  @param message  log message.
 */
/*
- (void)logWithLevel:(NSInteger)level
               Class:(NSString *)logClass
            Category:(NSString *)category
             Message:(NSString *)message
           logExtra1:(NSString *)extra1
           logExtra2:(NSString *)extra2
{
    if (!_termAndConditionFlag) {
        return;
    }
    
    [[SRDLogStore shareInstance] createLogWithLogLevel:level
                                              logClass:logClass
                                           logCategory:category
                                            logMessage:message
                                             logExtra1:extra1
                                             logExtra2:extra2];
    
}
*/



/**
 * Load google analysic tracker.
 * Author: Jurian
 */
- (void) loadTracker{
    
    [GAI sharedInstance].optOut = NO;
    // Optional: automatically send uncaught exceptions to Google Analytics.
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    
    [[GAI sharedInstance] defaultTracker].allowIDFACollection = NO;
    // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
    [GAI sharedInstance].dispatchInterval = 20;
    
    // Optional: set Logger to VERBOSE for debug information.
    [[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelInfo];
    
    // Initialize tracker. Replace with your tracking ID.
    tracker = [[GAI sharedInstance] trackerWithTrackingId:trackerID];
    
    NSLog(@"tracker : %@", tracker);
    
}

/**
 * Load tracking Screen.
 * Author: Jurian
 */
- (void)trackingScreen:(NSString*)screenName{
    [tracker set:kGAIScreenName value:screenName];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    NSLog(@"screenName : %@", screenName);
    
}

- (void)createEventWithCategory:category
                         action:action
                          label:labelAction
{
    NSLog(@"createEventWithCategory : %@ action:%@, labelAction: %@", category,action,labelAction);
    NSLog(@"tracker:%@",tracker);
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:category
                                                          action:action
                                                           label:labelAction
                                                           value:nil] build]];
}



@end
