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
//  SRDLogContent.m
//  SotoRemoteDebugger
//
//  Created by Duong (Daryl) H. DANG on 3/5/15.
//  Copyright (c) 2015 Duong (Daryl) H. DANG. All rights reserved.
//

#import "SRDLogContent.h"
#import "SRDConstants.h"
#import "LogAdapter.h"

@implementation SRDLogContent

/*
- (instancetype) initWithLogLevel:(NSInteger)logLevel
                         logClass:(NSString *)logClass
                      logCategory:(NSString *)logCategory
                     logSessionId:(NSString *)logSessionID
                       logMessage:(NSString *)logMessage
                        logExtra1:(NSString *)extra1
                        logExtra2:(NSString *)extra2
{
    if (self = [super init]) {
        _logLevel = logLevel;
        _logClass = logClass;
        _logCategory = logCategory;
        _logMessage = logMessage;
        _logTime = [NSDate date];
        _logSessionID = logSessionID;
        _logExtra1 = extra1;
        _logExtra2 = extra2;
     
    }
    return self;

}*/

- (instancetype) initFromDictionary:(NSDictionary *)dic
{
    if (self = [super init]) {
        [self importLogLevelFromDictionanry:dic];
        [self importLogClassFromDictionanry:dic];
        [self importLogCategoryFromDictionanry:dic];
        [self importLogSessionIDFromDictionanry:dic];
        [self importLogMessageFromDictionanry:dic];
        [self importLogTimeFromDictionanry:dic];
        [self importLogExtra1FromDictionanry:dic];
        [self importLogExtra2FromDictionanry:dic];
    }
    return self;
}

- (void) importLogLevelFromDictionanry:(NSDictionary *)dictionary{
    NSInteger logLevel = [[dictionary objectForKey:LOG_LEVEL] integerValue];
    self.logLevel = logLevel;
}
- (void) importLogClassFromDictionanry:(NSDictionary *)dictionary{
    NSString *logClass = [NSString stringWithFormat:@"%@",[dictionary objectForKey:LOG_CLASS]];
    self.logClass = logClass;
}

- (void) importLogCategoryFromDictionanry:(NSDictionary *)dictionary{
    NSString *logCategory = [NSString stringWithFormat:@"%@",[dictionary objectForKey:LOG_CATEGORY]];
    self.logCategory = logCategory;
}

-(void)importLogSessionIDFromDictionanry:(NSDictionary *)dictionary{
    self.logSessionID = STRING_EMPTY;
    
    if ([dictionary objectForKey:LOG_SESSION_ID]) {
        NSString *logSessionID = [NSString stringWithFormat:@"%@",[dictionary objectForKey:LOG_SESSION_ID]];
        self.logSessionID = logSessionID;
    }
}

- (void) importLogMessageFromDictionanry:(NSDictionary *)dictionary{
    NSString *logMessage = [NSString stringWithFormat:@"%@",[dictionary objectForKey:LOG_MESSAGE]];
    self.logMessage = logMessage;
}

- (void) importLogExtra1FromDictionanry:(NSDictionary *)dictionary{
    self.logExtra1 = STRING_EMPTY;
    if ([dictionary objectForKey:LOG_SESSION_ID]) {
        NSString *logExtra1 = [NSString stringWithFormat:@"%@",[dictionary objectForKey:LOG_EXTRA1]];
        self.logExtra1 = logExtra1;
    }
}

- (void) importLogExtra2FromDictionanry:(NSDictionary *)dictionary{
    self.logExtra2 = STRING_EMPTY;
    if ([dictionary objectForKey:LOG_SESSION_ID]) {
        NSString *logExtra2 = [NSString stringWithFormat:@"%@",[dictionary objectForKey:LOG_EXTRA2]];
        self.logExtra2 = logExtra2;
    }
}

- (void) importLogTimeFromDictionanry:(NSDictionary *)dictionary{
    NSString *logTime = [NSString stringWithFormat:@"%@",[dictionary objectForKey:LOG_TIME]];
    NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
    [dateFormater setDateFormat:DATE_FORMAT];
    self.logTime = [dateFormater dateFromString:logTime];
}

- (NSDictionary *)getLogInDictionary
{
    NSMutableDictionary *logDictionary = [[NSMutableDictionary alloc] init];
    [logDictionary setObject:[NSNumber numberWithInteger:_logLevel]  forKey:LOG_LEVEL];
    [logDictionary setObject:_logClass forKey:LOG_CLASS];
    [logDictionary setObject:_logMessage forKey:LOG_MESSAGE];
    [logDictionary setObject:_logCategory forKey:LOG_CATEGORY];
    [logDictionary setObject:_logSessionID forKey:LOG_SESSION_ID];
    [logDictionary setObject:_logExtra1 forKey:LOG_EXTRA1];
    [logDictionary setObject:_logExtra2 forKey:LOG_EXTRA2];
    
    
    // Convert NSDate to string.
    NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
    [dateFormater setDateFormat:DATE_FORMAT];
    [logDictionary setObject:[dateFormater stringFromDate:_logTime] forKey:LOG_TIME];
    
    return [logDictionary copy];
}

- (NSDictionary *)getLogInDictionaryNotIncludeSession
{
    NSMutableDictionary *logDictionary = [[NSMutableDictionary alloc] init];
    [logDictionary setObject:[NSNumber numberWithInteger:_logLevel]  forKey:LOG_LEVEL];
    [logDictionary setObject:_logClass forKey:LOG_CLASS];
    [logDictionary setObject:_logMessage forKey:LOG_MESSAGE];
    [logDictionary setObject:_logCategory forKey:LOG_CATEGORY];
    [logDictionary setObject:_logExtra1 forKey:LOG_EXTRA1];
    [logDictionary setObject:_logExtra2 forKey:LOG_EXTRA2];
    
    // Convert NSDate to string.
    NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
    [dateFormater setDateFormat:DATE_FORMAT];
    [logDictionary setObject:[dateFormater stringFromDate:_logTime] forKey:LOG_TIME];
    
    return [logDictionary copy];
}

#pragma mark - NSCoding
/* No longer used.
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInteger:self.logLevel
                   forKey:LOG_LEVEL];
    
    [aCoder encodeObject:self.logClass
                  forKey:LOG_CLASS];
    
    [aCoder encodeObject:self.logCategory
                  forKey:LOG_CATEGORY];
    
    [aCoder encodeObject:self.logMessage
                  forKey:LOG_MESSAGE];
    
    // NSDate does not conform to NSCoding protocol, we have to convert it to string first.
    NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
    [dateFormater setDateFormat:DATE_FORMAT];
    [aCoder encodeObject:[dateFormater stringFromDate:self.logTime]
                  forKey:LOG_TIME];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        _logLevel = [aDecoder decodeIntegerForKey:LOG_LEVEL];
        _logClass = [aDecoder decodeObjectForKey:LOG_CLASS];
        _logCategory = [aDecoder decodeObjectForKey:LOG_CATEGORY];
        _logMessage = [aDecoder decodeObjectForKey:LOG_MESSAGE];
        
        NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
        [dateFormater setDateFormat:DATE_FORMAT];
        NSString *dateString = [aDecoder decodeObjectForKey:LOG_TIME];
        _logTime = [dateFormater dateFromString:dateString];
    }
    
    return self;
}
*/
@end
