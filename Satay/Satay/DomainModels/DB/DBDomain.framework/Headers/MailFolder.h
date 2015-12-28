//
//  MailFolder.h
//  DBControl
//
//  Created by enclave on 12/15/14.
//  Copyright (c) 2014 mTouche. All rights reserved.
//

#import <DBAccess/DBAccess.h>
#define Adapter @"DAOAdapter"
#define ColumnName(arg) (@""#arg)

@interface MailFolder : DBObject

@property (strong) NSNumber *folderIndex;
@property (strong) NSString *folderName;
@property (strong) NSString *status;
@property (strong) NSString *extend1;
@property (strong) NSString *extend2;

@end
