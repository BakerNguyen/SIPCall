//
//  KeyChainSecurity.m
//  SecurityDomain
//
//  Created by MTouche on 1/7/15.
//  Copyright (c) 2015 mTouche. All rights reserved.
//

#import "KeyChainSecurity.h"
#import "UICKeyChainStore.h"

@implementation KeyChainSecurity

+(void) storeString:(NSString*) content
                Key:(NSString*) key{
    if(!key || key.length == 0){
        NSLog(@"%s: key value is empty", __PRETTY_FUNCTION__);
        return;
    }
    if(!content || content.length == 0){
        NSLog(@"%s: content value is empty", __PRETTY_FUNCTION__);
        return;
    }
    
    [UICKeyChainStore setString:content forKey:key];
}

+(NSString*) getStringFromKey:(NSString*) key{
    if(!key || key.length == 0){
        NSLog(@"%s: key value is empty", __PRETTY_FUNCTION__);
        return NULL;
    }
    
    return [UICKeyChainStore stringForKey:key];
}

+(BOOL) removeKey:(NSString*) key{
    return [UICKeyChainStore removeItemForKey:key];
}

@end
