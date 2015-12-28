//
//  KeyChainSecurity.h
//  SecurityDomain
//
//  Created by MTouche on 1/7/15.
//  Copyright (c) 2015 mTouche. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KeyChainSecurity : NSObject

/*
 * storeString into KeyChain
 * param content, key
 * @author Trung
 */
+(void) storeString:(NSString*) content
                Key:(NSString*) key;

/*
 * get string content from KeyChain
 * param key
 * @author Trung
 */
+(NSString*) getStringFromKey:(NSString*) key;

/*
 * reset string content from KeyChain
 * param key
 * @author Trung
 */

+(BOOL) removeKey:(NSString*) key;

@end
