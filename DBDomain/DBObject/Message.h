//
//  Message.h
//  DBControl
//
//  Created by enclave on 12/15/14.
//  Copyright (c) 2014 mTouche. All rights reserved.
//

#import <DBAccess/DBAccess.h>
#define Adapter @"DAOAdapter"
#define ColumnName(arg) (@""#arg)

@interface Message : DBObject

@property (strong) NSString *messageId;//unique
@property (strong) NSString *chatboxId;// from ChatBox table
@property (strong) NSString *senderJID;
@property (strong) NSString* messageType;
@property (strong) NSString *messageContent;
@property (strong) NSString *messageStatus;//0-send, 1-delivered, 2-pending
@property BOOL isEncrypted;//1,0: true flase
@property BOOL isSMS;//1,0: true flase
@property (strong) NSNumber *selfDestructDuration;//(0,30,60,180) seconds
@property (strong) NSNumber *sendTS;
@property (strong) NSNumber *selfDestructTS;
@property (strong) NSNumber *readTS;
@property (strong) NSString *mediaServerURL;
@property (strong) NSString *mediaLocalURL;
@property (strong) NSNumber *mediaFileSize;
@property (strong) NSString *extend1;
@property (strong) NSString *extend2;
@property (strong) NSString *keyVersion;

@end
