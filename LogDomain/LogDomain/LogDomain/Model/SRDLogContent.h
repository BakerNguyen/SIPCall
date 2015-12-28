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
//  SRDLogContent.h
//  SotoRemoteDebugger
//
//  Created by Duong (Daryl) H. DANG on 3/5/15.
//  Copyright (c) 2015 Duong (Daryl) H. DANG. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SRDLogContent : NSObject 

@property (nonatomic) NSInteger logLevel;
@property (nonatomic, retain) NSString *logClass;
@property (nonatomic, retain) NSString *logCategory;
@property (nonatomic, retain) NSString *logSessionID;
@property (nonatomic, retain) NSString *logMessage;
@property (nonatomic, retain) NSDate *logTime;
@property (nonatomic, retain) NSString *logExtra1;
@property (nonatomic, retain) NSString *logExtra2;

//- (instancetype) initWithLogLevel: (NSInteger) logLevel
//                         logClass: (NSString *)logClass
//                      logCategory: (NSString *)logCategory
//                     logSessionId: (NSString *)logSessionID
//                       logMessage: (NSString *)logMessage
//                        logExtra1: (NSString *)extra1
//                        logExtra2: (NSString *)extra2;

/**
 *  Create log object from dictionary of attribute
 *
 *  @param dic dictionary input contain key: LOG_LEVEL, LOG_CLASS, LOG_CATEGORY, LOG_SESSION_ID, LOG_MESSAGE, LOG_EXTRA1, LOG_EXTRA2, LOG_TIME
 *
 *  @return SRDLogContent object
 */
- (instancetype) initFromDictionary: (NSDictionary *)dic;

/**
 *  Get dictionary of log object not contain session attribute.
 *
 */
- (NSDictionary *)getLogInDictionaryNotIncludeSession;

/**
 *  Get dictionary of log object
 *
 */
- (NSDictionary *)getLogInDictionary;


@end
