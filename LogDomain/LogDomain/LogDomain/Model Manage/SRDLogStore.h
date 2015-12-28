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
//  SRDLogStore.h
//  SotoRemoteDebugger
//
//  Created by Duong (Daryl) H. DANG on 3/6/15.
//  Copyright (c) 2015 Duong (Daryl) H. DANG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SRDLogContent.h"

@interface SRDLogStore : NSObject

+(instancetype)shareInstance;

@property (nonatomic) int maxStore;

/**
 *  log count.
 */
@property(nonatomic,readonly) NSInteger logCount;

/**
 *  Create log object from dictionary of attribute
 *
 *  @param parameterDic LOG_LEVEL, LOG_CLASS, LOG_CATEGORY, LOG_MESSAGE, LOG_EXTRA1, LOG_EXTRA2
 */
- (void)createLogWithLogDic:(NSDictionary *)parameterDic;

/**
 *  Get all log.
 *
 *  @return Array of all log
 */
- (NSArray *)getAllLog;

/**
 *  Get all sessionID of log
 *
 *  @return array of sessionID
 */
- (NSArray *)getAllSession;

/**
 *  Get array of log base on sessionID
 *
 *  @param sessionID input
 *
 *  @return Array of log have sessionID match with input
 */
- (NSArray *)getArrayWithSessionID: (NSString *)sessionID;

/**
 *  Remove single log.
 *
 *  @param log log will be remote.
 */
- (void)removeLog:(SRDLogContent *)log;

/**
 *  Remove array of logs.
 *
 *  @param logs array of log will be remove.
 */
- (void)removeArrayOfLog:(NSArray *)logs;

/**
 *  Remove oldest log.
 */
- (void)removeOldestLog;

/**
 *  Get the save file path.
 *
 *  @return Save file path.
 */
- (NSString *)itemArchivePath;

/**
 *  Get the crash log file path.
 *
 *  @return crash log file path.
 */
- (NSString *)crashLogPath;

/**
 *  Save current log to file
 */
- (BOOL)saveLogs;

/**
 *  Clear all logs.
 */
- (BOOL)clearAllLogs;

- (void)createNewFile:(NSString *)filename;

- (void)appendToFile:(NSString *)filePath Content:(NSString *)content;
- (BOOL)isFileExist:(NSString *)filePath;

@end
