//
//  LoggingHelper.h
//  KryptoChat
//
//  Created by enclave on 9/25/14.
//  Copyright (c) 2014 mTouche. All rights reserved.
//

#import <Foundation/Foundation.h>
//Logging
//#import "CocoaLumberjack.h"
//#import "DDTTYLogger.h"
// The first two classes are in charge of sending log messages to the Console application and Xcode’s Console.
// The DDFileLogger class takes care of writing log messages to a file on disk.

@interface LoggingHelper : NSObject 

extern int ddLogLevel;

+(void) setLoggingConfiguration;
+(void) writeLoggingFile;
//+(void) createNewFile:(NSString *)filename;

@end
