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
//  SRDHTTPClient.m
//  SotoRemoteDebugger
//
//  Created by Duong (Daryl) H. DANG on 3/6/15.
//  Copyright (c) 2015 Duong (Daryl) H. DANG. All rights reserved.
//

#import "SRDHTTPClient.h"
#import "CocoaLumberjack.h"

@implementation SRDHTTPClient

//Logging
#ifdef DEBUG
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelOff;
#endif


+ (SRDHTTPClient *)sharedInstance
{
    static SRDHTTPClient *shareinstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareinstance = [[self alloc] initWithBaseURL:[NSURL URLWithString:BASE_URL]];
    });
    
    return shareinstance;
}

- (instancetype)initWithBaseURL:(NSURL *)url
{
    self = [super initWithBaseURL:url];
    
    if (self) {
        self.responseSerializer = [AFJSONResponseSerializer serializer];
        self.requestSerializer = [AFJSONRequestSerializer serializer];
        self.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
        _remoteURL = BASE_URL;
    }
    
    return self;
}
/*
- (void)pushLogToServerWithLog:(SRDLogContent *)log
                        Source:(NSString *)source
                      Scenario:(NSString *)scenario
                        Format:(NSString *)format
                        Extra1:(NSString *)extra1
                        Extra2:(NSString *)extra2
                      callback:(requestCompleteCallBack)callback
{
    void (^localRequestCompleteCallBack)(BOOL success, NSDictionary *response, NSError *error);
    localRequestCompleteCallBack = callback;
    
    NSArray *arrayOfContent = [NSArray arrayWithObject:log];
    
    SRDRequestAPIObject *newRequest = [[SRDRequestAPIObject alloc] initWithSource:source
                                                                         Scenario:scenario
                                                                   ArrayOfContent:arrayOfContent
                                                                           Format:format
                                                                           Extra1:extra1
                                                                           Extra2:extra2];
    
    [self POST:self.remoteURL
    parameters:[newRequest getRequestAPIObjectInDictionary]
       success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSError *error = nil;
        
        if ([self handleResponse:responseObject error:&error]) {
            
            localRequestCompleteCallBack(YES,responseObject,nil);
            
        }
        else {
            localRequestCompleteCallBack(NO,nil,error);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        localRequestCompleteCallBack(NO,nil,error);
    }];
}

- (void)pushLogsToServerWithSource:(NSString *)source
                          Scenario:(NSString *)scenario
                            Format:(NSString *)format
                        ArrayOfLog:(NSArray *)logs
                            Extra1:(NSString *)extra1
                            Extra2:(NSString *)extra2
                          callback:(requestCompleteCallBack)callback

{
    self.scenario = scenario;
    self.format = format;
    self.extra1 = extra1;
    self.extra2 = extra2;
    
    void (^localRequestCompleteCallBack)(BOOL success, NSDictionary *response, NSError *error);
    localRequestCompleteCallBack = callback;
    
    // Generate HTTP request object.
    SRDRequestAPIObject *newRequest = [[SRDRequestAPIObject alloc] initWithSource:source
                                                                         Scenario:scenario
                                                                   ArrayOfContent:logs
                                                                           Format:format
                                                                           Extra1:extra1
                                                                           Extra2:extra2];
    [self POST:self.remoteURL
    parameters:[newRequest getRequestAPIObjectInDictionary]
       success:^(NSURLSessionDataTask *task, id responseObject) {
           
           NSError *error = nil;
           
           if ([self handleResponse:responseObject error:&error]) {
               
               localRequestCompleteCallBack(YES,responseObject,nil);
           }
           else {
               
              localRequestCompleteCallBack(NO,nil,error);
           }
           
       } failure:^(NSURLSessionDataTask *task, NSError *error) {
           localRequestCompleteCallBack(NO,nil,error);
       }];
}
*/

- (void)pushLogsTOServerWithDic:(NSDictionary *)parametersDic callback:(requestCompleteCallBack)callback
{
    DDLogInfo(@"%s %@", __PRETTY_FUNCTION__, parametersDic);
    
    if (!parametersDic) {
        DDLogError(@"%s: paramDic cannot be NULL",__PRETTY_FUNCTION__);
        return;
    }
    
    void (^localRequestCompleteCallBack)(BOOL success, NSDictionary *response, NSError *error);
    localRequestCompleteCallBack = callback;
    
    SRDRequestAPIObject *newRequest = [[SRDRequestAPIObject alloc] initWithDic:parametersDic];
    
    [self POST:self.remoteURL parameters:[newRequest getRequestAPIObjectInDictionary] success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSError *error = nil;
        
        if ([self handleResponse:responseObject error:&error]) {
            
            localRequestCompleteCallBack(YES,responseObject,nil);
        }
        else {
            
            localRequestCompleteCallBack(NO,responseObject,error);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        localRequestCompleteCallBack(NO,nil,error);
    }];
}

/**
 *  Handle response from server.
 *
 *  @param response Dictionary response from server.
 *  @param error    Error if it occur.
 *
 *  @return Yes if response message is success. No if response faile, error will be parse.
 */
- (BOOL)handleResponse:(NSDictionary *)response error:(NSError **)error
{
    NSNumber *status_code = (NSNumber*)response[RESPONSE_CODE];
    
    if ([status_code intValue] == 1 || [status_code intValue] == 2) {
        return YES;
    }
    else {
        NSDictionary *info = @{NSLocalizedDescriptionKey: NSLocalizedString(response[RESPONSE_MESSAGE], nil),
                               };
        if (error) {
            *error = [[NSError alloc] initWithDomain:@"Log to Server Fail"
                                                code:[status_code intValue]
                                            userInfo: info];
        }
        
        return NO;
    }
}

@end
