//
//  JSONHelper.m
//  XMPPDomain
//
//  Created by Daniel Nguyen on 1/6/15.
//  Copyright (c) 2015 mTouche. All rights reserved.
//

#import "JSONHelper_XMPP.h"

@implementation JSONHelper_XMPP
+(NSString *) encodeObjectToJSON:(NSObject *)CommandDict{
    SBJsonWriter_XMPP *writer = [[SBJsonWriter_XMPP alloc] init];
    return [writer stringWithObject:CommandDict];
}
+(id) decodeJSONToObject:(NSString *)JSONString{
    SBJsonParser_XMPP *parser = [[SBJsonParser_XMPP alloc] init];
    return [parser objectWithString:JSONString];
}
@end
