//
//  Request.h
//  DBControl
//
//  Created by enclave on 12/16/14.
//  Copyright (c) 2014 mTouche. All rights reserved.
//

#import <DBAccess/DBAccess.h>
#define Adapter @"DAOAdapter"
#define ColumnName(arg) (@""#arg)

@interface Request : DBObject

@property (strong) NSString *requestJID;//unique
@property (strong) NSNumber *requestType; // 0 = send, 1 = receive
@property (strong) NSString *content;
@property (strong) NSNumber *status;// 0 = pending, 1 = approved, 2 = denied
@property (strong) NSNumber *createTS;
@property (strong) NSString *extend1;
@property (strong) NSString *extend2;

@end
