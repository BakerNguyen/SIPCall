//
//  MailHeader.h
//  DBControl
//
//  Created by enclave on 12/16/14.
//  Copyright (c) 2014 mTouche. All rights reserved.
//

#import <DBAccess/DBAccess.h>
#define Adapter @"DAOAdapter"
#define ColumnName(arg) (@""#arg)

@interface MailHeader : DBObject

@property (strong) NSString *mailAccountId;//unique
@property (strong) NSString *uid;//unique
@property (strong) NSString *emailFrom;
@property (strong) NSString *emailTo;
@property (strong) NSString *emailCC;
@property (strong) NSString *emailBCC;
@property (strong) NSString *subject;
@property (strong) NSString *shortDesc;
@property (strong) NSNumber *emailStatus;// 0 = not seen, 1 = seen, 2 = deleted
@property (strong) NSNumber *folderIndex;
@property (strong) NSNumber *attachNumber;
@property (strong) NSNumber *isDownloaded;
@property (strong) NSNumber *isImportant;
@property (strong) NSNumber *isReplied;
@property (strong) NSNumber *isForwarded;
@property (strong) NSNumber *isEncrypted;
@property (strong) NSNumber *sendDate;
@property (strong) NSNumber *receiveDate;
@property (strong) NSString *extend1;
@property (strong) NSString *extend2;


@end
