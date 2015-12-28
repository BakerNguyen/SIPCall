/*
 +--------------------------------------------------------------------------
 |
 | WARNING: REMOVING THIS COPYRIGHT HEADER IS EXPRESSLY FORBIDDEN
 |
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
//  SRDRequestAPIObject.m
//  SotoRemoteDebugger
//
//  Created by Duong (Daryl) H. DANG on 3/5/15.
//  Copyright (c) 2015 Duong (Daryl) H. DANG. All rights reserved.
//

#import "SRDRequestAPIObject.h"
#import "SRDConstants.h"
#import "SRDLogContent.h"
#import "SRDLogStore.h"

@implementation SRDRequestAPIObject
/*
- (instancetype)initWithSource:(NSString *)Source
                      Scenario:(NSString *)Scenario
                ArrayOfContent:(NSArray *)Content
                        Format:(NSString *)Format
                        Extra1: (NSString *)extra1
                        Extra2: (NSString *)extra2{
    if (self = [super init]) {
        _RequestSource = Source;
        _RequestDevice = [self getDeviceName];
        _RequestOSVersion = [self getOSVerion];
        _RequestAppVersion = [self getAppVersion];
        _RequestScenario = Scenario;
        _RequestSessionID = [[SRDLogStore shareInstance] getCurrentPushSession];
        
        if (extra1) {
            _RequestExtra1 = extra1;
        }
        else{
            _RequestExtra1 = STRING_EMPTY;
        }
        if (extra2) {
            _RequestExtra2 = extra2;
        }
        else{
            _RequestExtra2 = STRING_EMPTY;
        }
        
        
        // Default format in request is json.
        if ([[Format uppercaseString] isEqualToString:STRING_XML]) {
            _RequestFormat = STRING_XML;
        }
        else {
            _RequestFormat = STRING_JSON;
        }
        
        NSMutableArray *LogsInDictionary = [[NSMutableArray alloc] init];
        for (SRDLogContent *log in Content) {
            [LogsInDictionary addObject:[log getLogInDictionaryNotIncludeSession]];
        }
        
        _RequestContent = LogsInDictionary;
        _RequestTime = [NSDate date];
        
    }
    
    return self;
}*/

- (instancetype)initWithDic:(NSDictionary *)parametersDic
{
    if (self = [super init]) {
    
        [self importSourceFromDictionanry:parametersDic];
        [self importDeviceFromDictionanry:parametersDic];
        [self importOSVersionFromDictionanry:parametersDic];
        [self importAppVersionFromDictionanry:parametersDic];
        [self importScenarioFromDictionanry:parametersDic];
        [self importSessionIDFromDictionanry:parametersDic];
        [self importFormatFromDictionanry:parametersDic];
        [self importContentFromDictionanry:parametersDic];
        [self importExtra1FromDictionanry:parametersDic];
        [self importExtra2FromDictionanry:parametersDic];
        self.RequestTime = [NSDate date];
    }
    return self;
}

- (void) importSourceFromDictionanry:(NSDictionary *)dictionary{
    NSString *requestSource = [NSString stringWithFormat:@"%@",[dictionary objectForKey:REQUEST_SOURCE]];
    if (!requestSource) {
        self.RequestSource = STRING_EMPTY;
    }
    else{
        self.RequestSource  = requestSource;
    }
}
- (void) importDeviceFromDictionanry:(NSDictionary *)dictionary{
    NSString *requestDevice = [NSString stringWithFormat:@"%@",[dictionary objectForKey:REQUEST_DEVICE]];
    if (!requestDevice) {
        self.RequestDevice = STRING_EMPTY;
    }
    else{
        self.RequestDevice  = requestDevice;
    }
}

- (void) importOSVersionFromDictionanry:(NSDictionary *)dictionary{
    NSString *requestOSVersion = [NSString stringWithFormat:@"%@",[dictionary objectForKey:REQUEST_OSVERSION]];
    if (!requestOSVersion) {
        self.RequestOSVersion = STRING_EMPTY;
    }
    else{
        self.RequestOSVersion  = requestOSVersion;
    }
}

- (void) importAppVersionFromDictionanry:(NSDictionary *)dictionary{
    NSString *requestAppVersion = [NSString stringWithFormat:@"%@",[dictionary objectForKey:REQUEST_APPVERSION]];
    if (!requestAppVersion) {
        self.RequestAppVersion = STRING_EMPTY;
    }
    else{
        self.RequestAppVersion  = requestAppVersion;
    }
}

- (void) importSessionIDFromDictionanry:(NSDictionary *)dictionary{
    NSString *requestSessionID = [NSString stringWithFormat:@"%@",[dictionary objectForKey:REQUEST_SESSION_ID]];
    if (!requestSessionID) {
        self.RequestSessionID = STRING_EMPTY;
    }
    else{
        self.RequestSessionID  = requestSessionID;
    }
}

- (void) importScenarioFromDictionanry:(NSDictionary *)dictionary{
    NSString *requestScenario = [NSString stringWithFormat:@"%@",[dictionary objectForKey:REQUEST_SCENARIO]];
    if (!requestScenario) {
        self.RequestScenario = STRING_EMPTY;
    }
    else{
        self.RequestScenario  = requestScenario;
    }
}

- (void) importContentFromDictionanry:(NSDictionary *)dictionary{
    NSArray *requestContent = [dictionary objectForKey:REQUEST_CONTENT];
    if (!requestContent) {
        self.RequestContent = [[NSArray alloc] init] ;
    }
    else{
        self.RequestContent = [[NSArray alloc] initWithArray:requestContent];
    }
}

- (void) importFormatFromDictionanry:(NSDictionary *)dictionary{
    NSString *requestFormat = [NSString stringWithFormat:@"%@",[dictionary objectForKey:REQUEST_FORMAT]];
    if (!requestFormat) {
        self.RequestFormat = STRING_JSON;
    }
    else{
        self.RequestFormat = requestFormat;
    }
}

- (void) importExtra1FromDictionanry:(NSDictionary *)dictionary{
    NSString *requestExtra1 = [NSString stringWithFormat:@"%@",[dictionary objectForKey:REQUEST_EXTRA1]];
    if (!requestExtra1) {
        self.RequestExtra1 = STRING_EMPTY;
    }
    else{
        self.RequestExtra1  = requestExtra1;
    }
}

- (void) importExtra2FromDictionanry:(NSDictionary *)dictionary{
    NSString *requestExtra2 = [NSString stringWithFormat:@"%@",[dictionary objectForKey:REQUEST_EXTRA2]];
    if (!requestExtra2) {
        self.RequestExtra2 = STRING_EMPTY;
    }
    else{
        self.RequestExtra2  = requestExtra2;
    }
}

- (NSDictionary*) getRequestAPIObjectInDictionary
{
    NSMutableDictionary *logDictionary = [[NSMutableDictionary alloc] init];
    
    [logDictionary setObject:_RequestSource  forKey:REQUEST_SOURCE];
    [logDictionary setObject:_RequestDevice forKey:REQUEST_DEVICE];
    [logDictionary setObject:_RequestOSVersion forKey:REQUEST_OSVERSION];
    [logDictionary setObject:_RequestAppVersion forKey:REQUEST_APPVERSION];
    [logDictionary setObject:_RequestScenario forKey:REQUEST_SCENARIO];
    [logDictionary setObject:_RequestSessionID forKey:REQUEST_SESSION_ID];
    [logDictionary setObject:_RequestExtra1 forKey:REQUEST_EXTRA1];
    [logDictionary setObject:_RequestExtra2 forKey:REQUEST_EXTRA2];
    
    // Convert NSDate to string.
    NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
    [dateFormater setDateFormat:DATE_FORMAT];
    [logDictionary setObject:[dateFormater stringFromDate:_RequestTime] forKey:REQUEST_TIME];
    [logDictionary setObject:_RequestFormat forKey:REQUEST_FORMAT];
    [logDictionary setObject:_RequestContent forKey:REQUEST_CONTENT];
    
    return [logDictionary copy];
}


@end
