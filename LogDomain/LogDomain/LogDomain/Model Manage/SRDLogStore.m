/*
 +--------------------------------------------------------------------------
 |
 | WARNING: REMOVING THIS COPYRIGHT HEADER IS EXPRESSLY FORBIDDEN
 |
 | SOTO REMOTE DEBUGGER
 | ========================================
 | by ENCLAVE, INC.
 | (c) 2012-2013 ENCLAVEIT.COM - All right reserved
 | Website: http://www.enclaveit.com [^]
 | Email : engineering@enclave.vn
 | ========================================
 |
 | WARNING //--------------------------
 |
 | Selling the code for this program without prior written consent is expressly
 | forbidden.
 | This computer program is protected by copyright law.
 | Unauthorized reproduction or distribution of this program, or any portion of
 | if, may result in severe civil and criminal penalties and will be prosecuted
 | to the maximum extent possible under the law.
 +--------------------------------------------------------------------------
 */

//
//  SRDLogStore.m
//  SotoRemoteDebugger
//
//  Created by Duong (Daryl) H. DANG on 3/6/15.
//  Copyright (c) 2015 Duong (Daryl) H. DANG. All rights reserved.
//

#import "SRDLogStore.h"
#import "SRDConstants.h"
#import "CocoaLumberjack.h"

//Logging
#ifdef DEBUG
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelOff;
#endif

#define FOLDER_LOG @"LOG"
#define logFileName @"SotoLog.plist"
#define crashFileName @"CrashTrace.txt"

@interface SRDLogStore ()

//@property (nonatomic, assign) dispatch_queue_t persistanceQueue;
@property (nonatomic) NSMutableArray *privateLogs;

// This keep current sessionID use for create log.
@property (nonatomic, retain) NSString *currentCreateSessionID;

@end

@implementation SRDLogStore


+ (instancetype)shareInstance
{
    static SRDLogStore *share = nil;
    
    // Thread-safe singletons.
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        share = [[self alloc] initPrivate];
    });
    
    return share;
}

// Not allow defaut init create new instace.
- (instancetype)init
{
    @throw [NSException exceptionWithName:@"Singleton" reason:@"Use + [SRDLogStore shareInstance]" userInfo:nil];
    return nil;
}

// Private init.
- (instancetype)initPrivate
{
    self = [super init];
    if (self) {
        // Get the saved file path to unarchive saved object.
        NSString *path = [self itemArchivePath];
        NSArray *temp = [NSArray arrayWithContentsOfFile:path];
        _privateLogs = [[NSMutableArray alloc] init];
        
        // No longer use, move it to Log Facade
        //_requestArray = [[NSMutableArray alloc] init];
        _currentCreateSessionID = [self generateSessionIDForCreateLog];
        
        if (temp) {
            for (NSDictionary *logDic in temp) {
                SRDLogContent *log = [[SRDLogContent alloc] initFromDictionary:logDic];
                if (log) {
                    [self.privateLogs addObject:log];
                }
            }
        }
        DDLogInfo(@"%s:SOTO: Load logs from file %lu logs", __PRETTY_FUNCTION__, (unsigned long)[self.privateLogs count]);
    }
    return self;
}


- (void)createLogWithLogDic:(NSDictionary *)parameterDic
{
    
    if (![self validateLogContentWithDic:parameterDic])
    {
        return;
    }
    
    NSMutableDictionary *logDictionary = [parameterDic mutableCopy];
    
    // Check nill with log_extra1 and log_extra2
    NSString *extra = [parameterDic valueForKey:LOG_EXTRA1];
    if (extra) {
        [logDictionary setObject:STRING_EMPTY forKey:LOG_EXTRA1];
    }
    extra = [parameterDic valueForKey:LOG_EXTRA2];
    if (extra) {
        [logDictionary setObject:STRING_EMPTY forKey:LOG_EXTRA2];
    }
    
    // Set session for log.
    [logDictionary setObject:self.currentCreateSessionID forKey:LOG_SESSION_ID];
    
    // set time create log.
    NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
    [dateFormater setDateFormat:DATE_FORMAT];
    [logDictionary setObject:[dateFormater stringFromDate:[NSDate date]] forKey:LOG_TIME];
    
    SRDLogContent *log = [[SRDLogContent alloc] initFromDictionary:logDictionary];
    

    if ([self.privateLogs count] > self.maxStore) {
        [self removeOldestLog];
    }
    
    [self.privateLogs addObject:log];
    BOOL save = [self saveLogs];
    if (save) {
        DDLogInfo(@"%s:SOTO: Save log: %lu logs", __PRETTY_FUNCTION__, (unsigned long)[self.privateLogs count]);
    }
    
}



// Check log content valid or not.
- (BOOL) validateLogContentWithLogLevel:(NSInteger)loglevel
                               logClass:(NSString *)logClass
                            logCategory:(NSString *)logCategory
                             logMessage:(NSString *)logMessage
{
    
    if ([logClass length] > 100 || [logClass isEqualToString:STRING_EMPTY] || logClass == nil) {
        DDLogError(@"%s:Log level not right", __PRETTY_FUNCTION__);
        return NO;
    }
    
    if ([logCategory length] > 100 || [logCategory isEqualToString:STRING_EMPTY] || logCategory == nil) {
        DDLogError(@"%s:Log category not right", __PRETTY_FUNCTION__);
        return NO;
    }
    
    if ([logMessage isEqualToString:STRING_EMPTY] || logMessage == nil) {
        DDLogError(@"%s:Log message null", __PRETTY_FUNCTION__);
        return NO;
    }
    
    return YES;
}

// Check log content valid or not.
- (BOOL) validateLogContentWithDic:(NSDictionary *)parameterDic
{
    NSString *logClass = [parameterDic objectForKey:LOG_CLASS];
    NSString *logCategory = [parameterDic objectForKey:LOG_CATEGORY];
    NSString *logMessage = [parameterDic objectForKey:LOG_MESSAGE];
    
    if ([logClass length] > 100 || [logClass isEqualToString:STRING_EMPTY] || logClass == nil) {
        DDLogError(@"%s:Log level not right", __PRETTY_FUNCTION__);
        return NO;
    }
    
    if ([logCategory length] > 100 || [logCategory isEqualToString:STRING_EMPTY] || logCategory == nil) {
        DDLogError(@"%s:Log category not right", __PRETTY_FUNCTION__);
        return NO;
    }
    
    if ([logMessage isEqualToString:STRING_EMPTY] || logMessage == nil) {
        DDLogError(@"%s:Log message null", __PRETTY_FUNCTION__);
        return NO;
    }
    
    return YES;
}

- (NSArray *)getAllLog
{
    return [self.privateLogs copy];
}

- (void)removeLog:(SRDLogContent *)log
{
    [self.privateLogs removeObjectIdenticalTo:log];
}

- (void)removeArrayOfLog:(NSArray *)logs
{
    for (SRDLogContent *log in logs) {
        [self removeLog:log];
    }
}

- (void)removeOldestLog{
    [self removeLog:[self.privateLogs objectAtIndex:0]];
}

- (NSInteger)logCount
{
    return [self.privateLogs count];
}

- (NSArray *)getNUMberOFLogs:(int)number inArray:(NSArray *)array
{
    NSUInteger count = MIN( [array count], number );
    return [array subarrayWithRange:NSMakeRange(0, count)];
}


- (NSArray *)getArrayOfLogInDictionary:(NSArray *)array
{
    NSMutableArray *LogsInDictionary = [[NSMutableArray alloc] init];
    for (SRDLogContent *log in array) {
        [LogsInDictionary addObject:[log getLogInDictionary]];
    }
    
    return LogsInDictionary;
}

- (NSArray *)getArrayWithSessionID: (NSString *)sessionID
{
    NSMutableArray *result = [[NSMutableArray alloc] init];
    for (SRDLogContent *log in [self.privateLogs mutableCopy]) {
        if ([log.logSessionID isEqualToString:sessionID]) {
            [result addObject:log];
        }
    }
    return result;
}


/**
 *  Get the save file path.
 *
 *  @return Save file path.
 */
- (NSString *)itemArchivePath
{
    // Make sure that the first argument is NSDocumentDirectory and not NSDocumantationDirectory.
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    // Get the one document directory from that list.
    NSString *documentDirectory = [documentDirectories firstObject];
    documentDirectory= [documentDirectory  stringByAppendingPathComponent:FOLDER_LOG];
    
    //Create folder
    if (![[NSFileManager defaultManager] fileExistsAtPath:documentDirectory]){
        [[NSFileManager defaultManager] createDirectoryAtPath:documentDirectory
                                  withIntermediateDirectories:NO
                                                   attributes:nil
                                                        error:nil];
    }
    
    return [documentDirectory  stringByAppendingPathComponent:logFileName];
}


- (NSString *)crashLogPath{
    // Make sure that the first argument is NSDocumentDirectory and not NSDocumantationDirectory.
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    // Get the one document directory from that list.
    NSString *documentDirectory = [documentDirectories firstObject];
    documentDirectory= [documentDirectory  stringByAppendingPathComponent:FOLDER_LOG];
    
    //Create folder
    if (![[NSFileManager defaultManager] fileExistsAtPath:documentDirectory]){
        [[NSFileManager defaultManager] createDirectoryAtPath:documentDirectory
                                  withIntermediateDirectories:NO
                                                   attributes:nil
                                                        error:nil];
    }
    
    return [documentDirectory  stringByAppendingPathComponent:crashFileName];

}

/**
 *  Save logs.
 *
 *  @return Save status.
 */
- (BOOL)saveLogs
{
    NSString *path = [self itemArchivePath];
    NSMutableArray *temp = [[NSMutableArray alloc] init];
    
    for (SRDLogContent *log in [self.privateLogs mutableCopy]) {
        [temp addObject:[log getLogInDictionary]];
    }
    
    return [temp writeToFile:path atomically:YES];
}

/**
 *  Clear all logs
 *
 *  @return clear status.
 */
- (BOOL)clearAllLogs
{
    [self.privateLogs removeAllObjects];

    return  [self saveLogs];
}


- (NSArray *)getAllSession
{
    NSMutableSet *sessionSet = nil;
    NSMutableArray *allLogSession = [[NSMutableArray alloc] init];
    
    for (SRDLogContent *log in [self.privateLogs mutableCopy]) {
        [allLogSession addObject:log.logSessionID];
    }
    sessionSet = [[NSSet setWithArray:allLogSession] mutableCopy];
    
    [allLogSession removeAllObjects];
    allLogSession = [[sessionSet allObjects] mutableCopy];
    return [allLogSession copy];
}


-(NSString *)generateSessionIDForCreateLog
{
    // Convert NSDate to string.
    NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
    [dateFormater setDateFormat:DATE_FORMAT];
    NSString *timeStamp = [dateFormater stringFromDate:[NSDate date]];
    NSUUID *uniqueIdentity = [NSUUID UUID];
    return [[NSString alloc] initWithFormat:@"%@_%@",[uniqueIdentity UUIDString],timeStamp];
}


- (void)createNewFile:(NSString *)filename{
    
    NSString *logsDirectory =  NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES)[0];
    
    NSString *fileName = filename;
    
    NSString *filePath = [logsDirectory stringByAppendingPathComponent:fileName];
    
    if ([self isFileExist:filePath])
    {
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
        DDLogInfo(@"%s:Remove file path: %@", __PRETTY_FUNCTION__, filePath);
    }
    
    if (![self isFileExist:filePath])
    {
        [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];
        DDLogInfo(@"%s:Create file path: %@", __PRETTY_FUNCTION__, filePath);
    }
    
}

-(void) appendToFile:(NSString *)filePath Content:(NSString *)content{
    [content writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
    if ([self isFileExist:filePath])
    {        
        DDLogInfo(@"%s:Write to file: %@ content: %@", __PRETTY_FUNCTION__, filePath,content);
    }
    else
    {
        DDLogError(@"%s:AppendToFile file doesn't exist: %@", __PRETTY_FUNCTION__, filePath);
    }
}

- (BOOL)isFileExist:(NSString *)filePath{
    return [[NSFileManager defaultManager] fileExistsAtPath: filePath];
}

@end
