//
//  Key.h
//  DBControl
//
//  Created by enclave on 12/15/14.
//  Copyright (c) 2014 mTouche. All rights reserved.
//

#import <DBAccess/DBAccess.h>
#define Adapter @"DAOAdapter"
#define ColumnName(arg) (@""#arg)

@interface Key : DBObject

@property (strong) NSString *keyId;//unique--> change to no unique
@property (strong) NSString *keyJSON;//key P1, P2 , P3, group key etc. in JSON format
@property (strong) NSString *keyVersion;
@property (strong) NSNumber *updateTS;//store the timestamp to know the order
@property (strong) NSString *extend1;
@property (strong) NSString *extend2;


@end
