//
//  Contact.h
//  DBASample
//
//  Created by MTouche on 12/3/14.
//  Copyright (c) 2014 mTouche inc. All rights reserved.
//

#import <DBAccess/DBAccess.h>
#define Adapter @"DAOAdapter"
#define ColumnName(arg) (@""#arg)

@interface Contact : DBObject

@property (strong) NSString *jid;
@property (strong) NSString *maskingid;
@property (strong) NSString *phonebookName;
@property (strong) NSString *serversideName;
@property (strong) NSString *customerName;
@property (strong) NSString *statusMsg;
@property (strong) NSString *phoneModel;
@property (strong) NSNumber *platform;
@property (strong) NSString *phonebookMSISDN;
@property (strong) NSString *serverMSISDN;
@property (strong) NSString *email;
@property (strong) NSString *avatarURL;
@property (strong) NSNumber *contactType;// 0 = friend, 1 = not friend, 2 = krypto user
@property (strong) NSNumber *contactState;// 0 = online, 1 = offline, 2 = blocked, 3 = deleted
@property (strong) NSNumber *syncTS;
@property (strong) NSString *extend1;
@property (strong) NSString *extend2; //store last activity of this contact.

@end
