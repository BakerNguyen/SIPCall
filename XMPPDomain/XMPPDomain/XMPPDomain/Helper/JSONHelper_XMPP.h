//
//  JSONHelper.h
//  XMPPDomain
//
//  Created by Daniel Nguyen on 1/6/15.
//  Copyright (c) 2015 mTouche. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SBJson.h"

@interface JSONHelper_XMPP : NSObject
+(NSString *) encodeObjectToJSON:(NSObject *)CommandDict;
+(id) decodeJSONToObject:(NSString *)JSONString;
@end
