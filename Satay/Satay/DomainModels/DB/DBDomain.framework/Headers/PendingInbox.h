//
//  PendingInbox.h
//  DBControl
//
//  Created by enclave on 12/16/14.
//  Copyright (c) 2014 mTouche. All rights reserved.
//

#import <DBAccess/DBAccess.h>
#define Adapter @"DAOAdapter"
#define ColumnName(arg) (@""#arg)

@interface PendingInbox : DBObject

@property (strong) NSNumber *mrn;
@property (strong) NSNumber *messageTS;
@property (strong) NSString *totalPart;
@property (strong) NSString *partNo;
@property (strong) NSString *msisdn;
@property (strong) NSString *msisdnHash;
@property (strong) NSString *actionName;
@property (strong) NSString *createdTime;
@property (strong) NSString *msgID;
@property (strong) NSString *processACK;
@property (strong) NSString *content;
@property (strong) NSString *extend1;
@property (strong) NSString *extend2;


@end
