//
//  SecureNote.h
//  DBControl
//
//  Created by enclave on 12/15/14.
//  Copyright (c) 2014 mTouche. All rights reserved.
//

#import <DBAccess/DBAccess.h>
#define Adapter @"DAOAdapter"
#define ColumnName(arg) (@""#arg)

@interface SecureNote : DBObject

@property (strong) NSString *fileName;
@property (strong) NSString *descContentEnc;
@property (strong) NSString *descContentNormal;
@property (strong) NSNumber *updateTS;
@property (strong) NSString *extend1;
@property (strong) NSString *extend2;

@end
