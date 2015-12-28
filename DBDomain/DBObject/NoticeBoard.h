//
//  NoticeBoard.h
//  DBControl
//
//  Created by enclave on 12/16/14.
//  Copyright (c) 2014 mTouche. All rights reserved.
//

#import <DBAccess/DBAccess.h>
#define Adapter @"DAOAdapter"
#define ColumnName(arg) (@""#arg)

@interface NoticeBoard : DBObject

@property (strong) NSString *noticeID; //same as requestJID in request object if notice is kind of request.
@property (strong) NSString *title;
@property (strong) NSString *content;
@property (strong) NSString *status;
@property (strong) NSNumber *updateTS;


@end
