//
//  XMPPDomainMessageDO.h
//  XMPPDomain
//
//  Created by Daniel Nguyen on 12/31/14.
//  Copyright (c) 2014 mTouche. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XMPPDomainMessageDO : NSObject

@property (nonatomic,strong) NSString* msg_id;
@property (nonatomic,strong) NSString* message_type;
@property (nonatomic,strong) NSString* chat_id;
@property (nonatomic,strong) NSString* from_jid;
@property (nonatomic,strong) NSString* to_jid;
@property (nonatomic,strong) NSString* retry;
@property (nonatomic,strong) NSString* notify;
@property (nonatomic,strong) NSString* message;
@property (nonatomic,strong) NSString* timer;
@property (nonatomic,strong) NSString* enc;
@property (nonatomic,strong) NSString* status;

@property (nonatomic,strong) NSString* other_1;
@property (nonatomic,strong) NSString* other_2;
@property (nonatomic,strong) NSString* other_3;
@property (nonatomic,strong) NSString* other_4;
@property (nonatomic,strong) NSString* other_5;

@property (nonatomic,strong) NSString* create_ts;
@property (nonatomic,strong) NSString* update_ts;
@property (nonatomic,strong) NSString* destroy_ts;
@property (nonatomic,strong) NSString* title; //caution...need to pass to CHATBOX table, won't insert into MESSAGE table

- (NSString *) toString;

@end
