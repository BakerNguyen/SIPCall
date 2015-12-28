//
//  MailAttachment.h
//  DBControl
//
//  Created by enclave on 12/16/14.
//  Copyright (c) 2014 mTouche. All rights reserved.
//

#import <DBAccess/DBAccess.h>
#define Adapter @"DAOAdapter"
#define ColumnName(arg) (@""#arg)

@interface MailAttachment : DBObject

@property (strong) NSString *mailHeaderUID;
@property (strong) NSString *attachmentName;
@property (strong) NSString *attachmentLocalPath;
@property (strong) NSNumber *attachmentSize;
@property (strong) NSString *mineType;
@property (strong) NSString *extend1;
@property (strong) NSString *extend2;


@end
