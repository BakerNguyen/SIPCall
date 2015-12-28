//
//  LoggingHelper.m
//  KryptoChat
//
//  Created by enclave on 9/25/14.
//  Copyright (c) 2014 mTouche. All rights reserved.
//

#import "LoggingHelper.h"

@implementation LoggingHelper

//Logging
#ifdef DEBUG
 int ddLogLevel = DDLogLevelVerbose;
#else
 int ddLogLevel = DDLogLevelOff;
#endif

+(void) setLoggingConfiguration{

    // Configure CocoaLumberjack
    [DDLog addLogger:[DDASLLogger sharedInstance]];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];

    setenv("XcodeColors", "YES", 0);
    // Enable Colors
    [[DDTTYLogger sharedInstance] setColorsEnabled:YES];
    [[DDTTYLogger sharedInstance] setForegroundColor:[UIColor greenColor] backgroundColor:nil forFlag:DDLogFlagInfo];
   
    [self writeLoggingFile];

}

+(void) writeLoggingFile{
    
    //Save log file to directory
    NSString* documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    DDLogFileManagerDefault* logFileManager = [[DDLogFileManagerDefault alloc] initWithLogsDirectory:documentsDirectory];
    // Initialize File Logger
    DDFileLogger *fileLogger  = [[DDFileLogger alloc] initWithLogFileManager:logFileManager];
    // Configure File Logger
    [fileLogger setMaximumFileSize:(2 * 1024 * 1024)];//2* 1024 * 1024 -2mb
    [fileLogger setRollingFrequency:(3600 *24)];// 3600 *24 - rolling everyday
    [[fileLogger logFileManager] setMaximumNumberOfLogFiles:1];
    
    [DDLog addLogger:fileLogger];
    DDLogVerbose(@"Logging is setup (\"%@\")", [fileLogger.logFileManager logsDirectory]);

}


@end
