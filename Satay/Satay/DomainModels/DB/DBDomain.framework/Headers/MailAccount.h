//
//  MailAccount.h
//  DBControl
//
//  Created by enclave on 12/16/14.
//  Copyright (c) 2014 mTouche. All rights reserved.
//

#import <DBAccess/DBAccess.h>
#define Adapter @"DAOAdapter"
#define ColumnName(arg) (@""#arg)

@interface MailAccount : DBObject

@property (strong) NSString *fullEmail;//unique
@property (strong) NSString *password;
@property (strong) NSNumber *accountType;
@property (strong) NSString *displayName;
@property (strong) NSString *signature;
@property (strong) NSNumber *emailKeeping;
@property BOOL useEncrypted;
@property (strong) NSString *syncSchedule;
@property (strong) NSNumber *periodSyncSchedule;
@property BOOL useSyncEmail;
@property (strong) NSNumber *retrivalSize;
@property BOOL useNotify;
@property BOOL autoDownloadWifi;
@property (strong) NSString *incomingUserName;
@property (strong) NSString *incomingPassword;
@property (strong) NSString *incomingHost;
@property (strong) NSString *incomingPort;
@property (strong) NSString *incomingUseSSL;
@property (strong) NSString *incomingSecurityType;
@property (strong) NSString *outgoingUserName;
@property (strong) NSString *outgoingPassword;
@property (strong) NSString *outgoingHost;
@property (strong) NSString *outgoingPort;
@property (strong) NSString *outgoingSecurityType;
@property (strong) NSString *outgoingRequireAuth;
@property (strong) NSString *storeProtocol;
@property BOOL pop3Deleteable;
@property (strong) NSString *imapPathPrefix;
@property (strong) NSString *extend1;
@property (strong) NSString *extend2;


@end
