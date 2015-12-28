//
//  XMPPDomainMessageDO.m
//  XMPPDomain
//
//  Created by Daniel Nguyen on 12/31/14.
//  Copyright (c) 2014 mTouche. All rights reserved.
//

#import "XMPPDomainMessageDO.h"

@implementation XMPPDomainMessageDO
@synthesize msg_id,message,message_type,chat_id,create_ts,timer,to_jid,retry,notify,enc,status,other_1,other_2,other_3,other_4,other_5,destroy_ts,update_ts,from_jid,title;

-(id)init{
    self = [super init];
    if (self) {
        // Custom initialization
        
    }
    return self;
}



- (NSString *) toString{
    
    NSMutableString * string = [NSMutableString new];
    [string appendString:NSStringFromClass([self class])];
    [string appendString:[NSString stringWithFormat:@"msg_id; %@ \n",self.msg_id]];
    [string appendString:[NSString stringWithFormat:@"message; %@ \n",self.message]];
    [string appendString:[NSString stringWithFormat:@"message_type; %@ \n",self.message_type]];
    [string appendString:[NSString stringWithFormat:@"chat_id; %@ \n",self.chat_id]];
    [string appendString:[NSString stringWithFormat:@"create_ts; %@ \n",self.create_ts]];
    [string appendString:[NSString stringWithFormat:@"timer; %@ \n",self.timer]];
    [string appendString:[NSString stringWithFormat:@"to_jid; %@ \n",self.to_jid]];
    [string appendString:[NSString stringWithFormat:@"retry; %@ \n",self.retry]];
    [string appendString:[NSString stringWithFormat:@"notify; %@ \n",self.notify]];
    [string appendString:[NSString stringWithFormat:@"enc; %@ \n",self.enc]];
    [string appendString:[NSString stringWithFormat:@"status; %@ \n",self.status]];
    [string appendString:[NSString stringWithFormat:@"other_1; %@ \n",self.other_1]];
    [string appendString:[NSString stringWithFormat:@"other_2; %@ \n",self.other_2]];
    [string appendString:[NSString stringWithFormat:@"other_3; %@ \n",self.other_3]];
    [string appendString:[NSString stringWithFormat:@"other_4; %@ \n",self.other_4]];
    [string appendString:[NSString stringWithFormat:@"other_5; %@ \n",self.other_5]];
    [string appendString:[NSString stringWithFormat:@"destroy_ts; %@ \n",self.destroy_ts]];
    [string appendString:[NSString stringWithFormat:@"update_ts; %@ \n",self.update_ts]];
    [string appendString:[NSString stringWithFormat:@"from_jid; %@ \n",self.from_jid]];
    [string appendString:[NSString stringWithFormat:@"title; %@ \n",self.title]];
    return string;
}

@end
