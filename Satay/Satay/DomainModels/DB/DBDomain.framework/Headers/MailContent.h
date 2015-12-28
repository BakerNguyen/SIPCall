//
//  MailContent.h
//  DBControl
//
//  Created by enclave on 12/16/14.
//  Copyright (c) 2014 mTouche. All rights reserved.
//

#import <DBAccess/DBAccess.h>
#define Adapter @"DAOAdapter"
#define ColumnName(arg) (@""#arg)

@interface MailContent : DBObject

@property (strong) NSNumber *emailHeaderId;
@property (strong) NSString *emailHeaderUID;
@property BOOL *isFullyDownloaded;
@property (strong) NSString *htmlContent;
@property (strong) NSString *mineType;
@property (strong) NSString *extend1;
@property (strong) NSString *extend2;

@end
