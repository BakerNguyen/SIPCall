//
//  MD5Security.m
//  SecurityDomain
//
//  Created by MTouche on 12/29/14.
//  Copyright (c) 2014 mTouche. All rights reserved.
//

#import "MD5Security.h"
#import <CommonCrypto/CommonDigest.h>

@implementation MD5Security

+(NSString*) generateMD5:(id) inputObject{
    if([inputObject isKindOfClass:[NSString class]]){
        NSString* inputString = (NSString*)inputObject;
        // Create pointer to the string as UTF8
        const char *ptr = [inputString UTF8String];
        // Create byte array of unsigned chars
        unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
        // Create 16 byte MD5 hash value, store in buffer
        CC_MD5(ptr, (unsigned int)strlen(ptr), md5Buffer);
        // Convert MD5 value in the buffer to NSString of hex values
        NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
        for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
            [output appendFormat:@"%02x",md5Buffer[i]];
        return output;
    }
    
    if([inputObject isKindOfClass:[NSData class]]){
        NSData* inputData = (NSData*)inputObject;
        // Create byte array of unsigned chars
        unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
        // Create 16 byte MD5 hash value, store in buffer
        CC_MD5(inputData.bytes, (unsigned int)inputData.length, md5Buffer);
        // Convert unsigned char buffer to NSString of hex values
        NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
        for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
            [output appendFormat:@"%02x",md5Buffer[i]];
        
        return output;
    }
    
    NSLog(@"%s: inputObject is not a NSString or NSData", __PRETTY_FUNCTION__);
    return NULL;
}

+(BOOL) compareMD5:(id) firstObject
      SecondObject:(id) secondObject{
    NSString* firstMD5 = [self generateMD5:firstObject];
    NSString* secondMD5 = [self generateMD5:secondObject];
    
    if([firstMD5 isEqualToString:secondMD5] && firstMD5){
        return YES;
    }
    return NO;
}

@end
