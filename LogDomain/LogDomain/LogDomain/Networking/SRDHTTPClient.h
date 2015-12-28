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
//  SRDHTTPClient.h
//  SotoRemoteDebugger
//
//  Created by Duong (Daryl) H. DANG on 3/6/15.
//  Copyright (c) 2015 Duong (Daryl) H. DANG. All rights reserved.
//

#import "AFHTTPSessionManager.h"
#import "SRDLogContent.h"
#import "SRDLogStore.h"
#import "SRDRequestAPIObject.h"
#import "SRDConstants.h"

@interface SRDHTTPClient : AFHTTPSessionManager

typedef void (^requestCompleteCallBack)(BOOL success, NSDictionary *response, NSError *error);

@property (nonatomic, retain) NSString * scenario;
@property (nonatomic, retain) NSString * format;
@property (nonatomic, retain) NSString * remoteURL;
@property (nonatomic, retain) NSString * extra1;
@property (nonatomic, retain) NSString * extra2;


+ (SRDHTTPClient *)sharedInstance;
- (instancetype)initWithBaseURL:(NSURL *) url;

/**
 *  Push array of log to server.
 *
 *  @param scenario name of the current log event.
 *  @param format   specific the format of the return result. Currently only support "xml" and "json". Default "json".
 *  @param logs     Array of log will be push.
 */
/*
- (void)pushLogsToServerWithSource:(NSString *) source
                          Scenario:(NSString *) scenario
                            Format: (NSString *) format
                        ArrayOfLog: (NSArray *)logs
                            Extra1: (NSString *)extra1
                            Extra2: (NSString *)extra2
                          callback:(requestCompleteCallBack)callback;
*/
- (void)pushLogsTOServerWithDic:(NSDictionary *)parametersDic callback:(requestCompleteCallBack)callback;

/**
 *  Push a log to server
 *
 *  @param log      log need tobe push.
 *  @param scenario name of the current log event.
 *  @param format   specific the format of the return result. Currently only support "xml" and "json". Default "json".
 */
/*
- (void)pushLogToServerWithLog:(SRDLogContent *) log
                        Source:(NSString *) source
                      Scenario:(NSString *) scenario
                        Format:(NSString *)format
                        Extra1: (NSString *)extra1
                        Extra2: (NSString *)extra2
                      callback:(requestCompleteCallBack)callback;
*/

@end

