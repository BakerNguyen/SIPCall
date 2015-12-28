//
//  JSONHelper.h
//  JuzChatV2
//
//  Created by Low Ker Jin on 8/6/13.
//  Copyright (c) 2013 mTouche. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "SBJson.h"
@interface JSONHelper : NSObject
+(NSString *) encodeObjectToJSON:(NSObject *)CommandDict;
+(id) decodeJSONToObject:(NSString *)JSONString;
@end
