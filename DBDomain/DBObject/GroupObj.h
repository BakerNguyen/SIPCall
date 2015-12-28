//
//  Group.h
//  DBControl
//
//  Created by enclave on 12/15/14.
//  Copyright (c) 2014 mTouche. All rights reserved.
//

#import <DBAccess/DBAccess.h>
#define Adapter @"DAOAdapter"
#define ColumnName(arg) (@""#arg)

@interface GroupObj : DBObject

@property (strong) NSString *groupId;//unique
@property (strong) NSString *groupPassword;
@property (strong) NSString *groupName;
@property (strong) NSString *groupImageURL;
@property (strong) NSNumber *updateTS;
@property (strong) NSString *extend1;
@property (strong) NSString *extend2;

@end
