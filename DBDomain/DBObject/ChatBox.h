//
//  ChatBox.h
//  DBControl
//
//  Created by enclave on 12/15/14.
//  Copyright (c) 2014 mTouche. All rights reserved.
//

#import <DBAccess/DBAccess.h>
#define Adapter @"DAOAdapter"
#define ColumnName(arg) (@""#arg)

@interface ChatBox : DBObject

@property (strong) NSString *chatboxId;//unique
@property (strong) NSNumber *encSetting;// (0-false, 1-true)
@property (strong) NSNumber *notificationSetting;//(0,1)
@property (strong) NSNumber *soundSetting;//(0, 1)
@property (strong) NSNumber *chatboxState;// 0 - display, 1 - not display
@property (strong) NSNumber *destructTime; //number of second the message will be self-destructed
@property (strong) NSNumber *updateTS;
@property (strong) NSString *extend1;
@property (strong) NSString *extend2;
@property BOOL isGroup;//1,0: true flase
@property BOOL isAlwaysDestruct;//1,0: true flase

@end
