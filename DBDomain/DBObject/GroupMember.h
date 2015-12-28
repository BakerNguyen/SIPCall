//
//  GroupMember.h
//  DBControl
//
//  Created by enclave on 12/15/14.
//  Copyright (c) 2014 mTouche. All rights reserved.
//

#import <DBAccess/DBAccess.h>
#define Adapter @"DAOAdapter"
#define ColumnName(arg) (@""#arg)

@interface GroupMember : DBObject

@property (strong) NSString *groupId;//unique
@property (strong) NSString *jid;//unique
@property (strong) NSNumber *memberRole;// 0 = admin, 1 = member
@property (strong) NSNumber *memberState;// 0 = kicked, 1 = leave, 2 active 
@property (strong) NSString *memberColor;
@property (strong) NSNumber *memberJoinTS;
@property (strong) NSString *extend1;
@property (strong) NSString *extend2;

@end
