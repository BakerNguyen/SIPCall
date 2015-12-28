//
//  Base64Security.m
//  SecurityDomain
//
//  Created by MTouche on 12/29/14.
//  Copyright (c) 2014 mTouche. All rights reserved.
//

#import "Base64Security.h"

@implementation Base64Security

+(NSString*) generateBase64String:(id) inputObject{
    if(!inputObject){
        NSLog(@"%s: inputObject cannot be NULL", __PRETTY_FUNCTION__);
        return NULL;
    }
    
    if([inputObject isKindOfClass:[NSString class]]){
        NSString* inputString = (NSString*)inputObject;
        NSData* inputData = [inputString dataUsingEncoding:NSUTF8StringEncoding];
        if(!inputData){
            NSLog(@"%s: inputObject String cannot be converted into base64 String", __PRETTY_FUNCTION__);
            return NULL;
        }
        NSString* base64String = [inputData base64EncodedStringWithOptions:0];
        if(!base64String){
            NSLog(@"%s: inputObject String cannot be converted into base64 String", __PRETTY_FUNCTION__);
            return NULL;
        }
        return base64String;
    }
    
    if([inputObject isKindOfClass:[NSData class]]){
        NSData* inputData = (NSData*)inputObject;
        NSString* base64String = [inputData base64EncodedStringWithOptions:0];
        if(!base64String){
            NSLog(@"%s: inputObject Data cannot be converted into base64 String", __PRETTY_FUNCTION__);
            return NULL;
        }
        return base64String;
    }
    
    NSLog(@"%s: inputObject is not a NSString or NSData", __PRETTY_FUNCTION__);
    return NULL;
}

+(NSData*) decodeBase64String:(id) inputObject{
    if(!inputObject){
        NSLog(@"%s: inputObject cannot be NULL", __PRETTY_FUNCTION__);
        return NULL;
    }
    
    NSData* decodedData = nil;
    if([inputObject isKindOfClass:[NSString class]]){
        decodedData = [[NSData alloc] initWithBase64EncodedString:inputObject  options:0];
        if(!decodedData){
            NSLog(@"%s: inputObject NSString cannot be decoded.", __PRETTY_FUNCTION__);
            return NULL;
        }
    }
    
    if([inputObject isKindOfClass:[NSData class]]){
        decodedData = [[NSData alloc] initWithBase64EncodedData:inputObject  options:0];
        if(!decodedData){
            NSLog(@"%s: inputObject NSData cannot be decoded.", __PRETTY_FUNCTION__);
            return NULL;
        }
    }
    
    return decodedData;
}

+(NSStringEncoding) getEncoding:(NSData*) inputData{
    return [NSString stringEncodingForData:inputData encodingOptions:nil convertedString:nil usedLossyConversion:nil];
}

+(BOOL) isValidBase64:(NSString*) inputString{
    if(!inputString || inputString.length == 0){
        NSLog(@"%s: inputData is null", __PRETTY_FUNCTION__);
        return FALSE;
    }
    if (inputString.length % 4 == 0) {
        static NSCharacterSet *invertedBase64CharacterSet = nil;
        if (invertedBase64CharacterSet == nil) {
            invertedBase64CharacterSet = [[NSCharacterSet
                                            characterSetWithCharactersInString:
                                            @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/="]
                                           invertedSet];
        }
        return [inputString rangeOfCharacterFromSet:invertedBase64CharacterSet
                                     options:NSLiteralSearch].location == NSNotFound;
    }
    return FALSE;
}

@end
