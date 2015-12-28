//
//  JSONHelper.m
//  JuzChatV2
//
//  Created by Low Ker Jin on 8/6/13.
//  Copyright (c) 2013 mTouche. All rights reserved.
//
#import "JSONHelper.h"
@implementation JSONHelper
+(NSString *) encodeObjectToJSON:(NSObject *)CommandDict{
    SBJsonWriter *writer = [[SBJsonWriter alloc] init];
    return [writer stringWithObject:CommandDict];
}
+(id) decodeJSONToObject:(NSString *)JSONString{
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    return [parser objectWithString:JSONString];
}
@end
