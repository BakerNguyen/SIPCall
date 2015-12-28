//
//  AESSecurity.m
//  SecurityDomain
//
//  Created by MTouche on 12/30/14.
//  Copyright (c) 2014 mTouche. All rights reserved.
//

#import "AESSecurity.h"
#import "Base64Security.h"
#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonKeyDerivation.h>

@implementation AESSecurity

CCAlgorithm kAlgorithm = kCCAlgorithmAES128;
NSUInteger kAlgorithmKeySize = kCCKeySizeAES256;
NSUInteger kAlgorithmBlockSize = kCCBlockSizeAES128;
NSUInteger kAlgorithmIVSize = kCCBlockSizeAES128;
NSString* kErrorDomain = @"com.mtouche.SecurityDomain";
const NSUInteger kPBKDFRounds = 10000;  // ~80ms on an iPhone 4

+ (NSData *) encryptAES256WithKey:(NSData *) key
                             Data:(NSData *) inputData{
    if(!key || key.length != kAlgorithmKeySize){
        NSLog(@"%s: NSData key is empty or length not equal kCCKeySizeAES256/32 bytes", __PRETTY_FUNCTION__);
        return NULL;
    }
    if(!inputData || inputData.length == 0){
        NSLog(@"%s: NSData inputData cannot be nil", __PRETTY_FUNCTION__);
        return NULL;
    }
    
    NSData* iv = [self randomDataOfLength:kAlgorithmIVSize];
    if(!iv){
        NSLog(@"%s: Cannot encrypt inputData", __PRETTY_FUNCTION__);
        return NULL;
    }
    
    NSError *error;
    size_t outLength;
    NSMutableData *cipherData = [NSMutableData dataWithLength:kAlgorithmBlockSize + inputData.length];
    
    CCCryptorStatus result = CCCrypt(kCCEncrypt, // operation
                                     kAlgorithm, // Algorithm
                                     kCCOptionPKCS7Padding, // options
                                     key.bytes, // key
                                     key.length, // keylength
                                     iv.bytes,// iv
                                     inputData.bytes, // dataIn
                                     inputData.length, // dataInLength,
                                     cipherData.mutableBytes, // dataOut
                                     cipherData.length, // dataOutAvailable
                                     &outLength); // dataOutMoved
    if(result == kCCSuccess){
        cipherData.length = outLength;
    }
    else{
        if(error){
            error = [NSError errorWithDomain:kErrorDomain code:result userInfo:nil];
            NSLog(@"%s: Error %@",__PRETTY_FUNCTION__, [error localizedDescription]);
        }
        return NULL;
    }
    
    //NOTE: init vector will be added inside the resultData.
    NSMutableData* resultData = [[NSMutableData alloc] initWithData:iv];
    [resultData appendData:cipherData];
    
    return resultData;
}

+ (NSData*) encryptAES256WithKey:(NSData *)key
                            Data:(NSData *)inputData
                            Salt:(NSData *)saltData{
    if(!key || key.length != kAlgorithmKeySize){
        NSLog(@"%s: NSData key is empty or length not equal kCCKeySizeAES256/32 bytes", __PRETTY_FUNCTION__);
        return NULL;
    }
    if(!inputData || inputData.length == 0){
        NSLog(@"%s: NSData inputData cannot be nil", __PRETTY_FUNCTION__);
        return NULL;
    }
    
    if (saltData.length != kAlgorithmIVSize) {
        NSLog(@"%s: NSData saltData length != 16", __PRETTY_FUNCTION__);
        return NULL;
    }
    
    NSData* iv = saltData;
    if(!iv){
        NSLog(@"%s: Cannot encrypt inputData", __PRETTY_FUNCTION__);
        return NULL;
    }
    
    NSError *error;
    size_t outLength;
    NSMutableData *cipherData = [NSMutableData dataWithLength:kAlgorithmBlockSize + inputData.length];
    
    CCCryptorStatus result = CCCrypt(kCCEncrypt, // operation
                                     kAlgorithm, // Algorithm
                                     kCCOptionPKCS7Padding, // options
                                     key.bytes, // key
                                     key.length, // keylength
                                     iv.bytes,// iv
                                     inputData.bytes, // dataIn
                                     inputData.length, // dataInLength,
                                     cipherData.mutableBytes, // dataOut
                                     cipherData.length, // dataOutAvailable
                                     &outLength); // dataOutMoved
    if(result == kCCSuccess){
        cipherData.length = outLength;
    }
    else{
        if(error){
            error = [NSError errorWithDomain:kErrorDomain code:result userInfo:nil];
            NSLog(@"%s: Error %@",__PRETTY_FUNCTION__, [error localizedDescription]);
        }
        return NULL;
    }
    
    //NOTE: init vector will be added inside the resultData.
    NSMutableData* resultData = [[NSMutableData alloc] initWithData:iv];
    [resultData appendData:cipherData];
    
    return resultData;
}

+ (NSData *) decryptAES256WithKey:(NSData *)key
                             Data:(NSData *)inputData{
    if(!key || key.length != kAlgorithmKeySize){
        NSLog(@"%s: NSData key is empty or length not equal kCCKeySizeAES256/32 bytes", __PRETTY_FUNCTION__);
        return NULL;
    }
    if(!inputData || inputData.length == 0){
        NSLog(@"%s: NSData inputData cannot be nil", __PRETTY_FUNCTION__);
        return NULL;
    }
    
    NSData *iv = [inputData subdataWithRange:NSMakeRange(0, kAlgorithmIVSize)];
    NSData *data = [inputData subdataWithRange:NSMakeRange(kAlgorithmIVSize, inputData.length-kAlgorithmIVSize)];
    
    size_t outLength;
    NSMutableData* decryptedData = [NSMutableData dataWithLength:data.length];
    CCCryptorStatus result = CCCrypt(kCCDecrypt, // operation
                                     kAlgorithm, // Algorithm
                                     kCCOptionPKCS7Padding, // options
                                     key.bytes, // key
                                     key.length, // keylength
                                     iv.bytes,// iv
                                     data.bytes, // dataIn
                                     data.length, // dataInLength,
                                     decryptedData.mutableBytes, // dataOut
                                     decryptedData.length, // dataOutAvailable
                                     &outLength); // dataOutMoved
    
    if (result != kCCSuccess) {
        NSError* error = [NSError errorWithDomain:kErrorDomain code:result userInfo:nil];
        NSLog(@"%s: Error: %@",__PRETTY_FUNCTION__,[error localizedDescription]);
        return NULL;
    }
    
    if((int)outLength == (int)decryptedData.length
       || (int)decryptedData.length == 0){
        NSLog(@"%s: Decrypted failed with keyData",__PRETTY_FUNCTION__);
        return NULL;
    }
    
    [decryptedData setLength:outLength];
    return decryptedData;
}

+(NSData*) hashPBKDF2:(NSString*)inputString Salt:(NSData*) salt{
    NSMutableData * derivedKey = [NSMutableData dataWithLength:kAlgorithmKeySize];
    
    if (!salt || salt.length == 0){
        NSLog(@"%s: salt data is empty", __PRETTY_FUNCTION__);
        return NULL;
    }
    
    if(!inputString || inputString.length == 0){
        NSLog(@"%s: inputString is empty", __PRETTY_FUNCTION__);
        return NULL;
    }
    
    int result = CCKeyDerivationPBKDF(kCCPBKDF2,            // algorithm
                                      inputString.UTF8String,  // password
                                      [inputString lengthOfBytesUsingEncoding:NSUTF8StringEncoding],  // passwordLength
                                      salt.bytes,           // salt
                                      salt.length,          // saltLen
                                      kCCPRFHmacAlgSHA1,    // PRF
                                      kPBKDFRounds,         // rounds
                                      derivedKey.mutableBytes, // derivedKey
                                      derivedKey.length); // derivedKeyLen
    
    if(result != kCCSuccess){
        NSLog(@"%s: Unable to hash inputString", __PRETTY_FUNCTION__);
        return NULL;
    }
    
    return derivedKey;
}

+(NSString*) hashSHA256:(id) inputObject{
    if(!inputObject){
        NSLog(@"%s: inputObject is NULL", __PRETTY_FUNCTION__);
        return NULL;
    }
    
    if([inputObject isKindOfClass:[NSString class]]){
        const char* str = [inputObject UTF8String];
        unsigned char result[CC_SHA256_DIGEST_LENGTH];
        CC_SHA256(str, (CC_LONG)strlen(str), result);
        NSMutableString *ret = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH*2];
        for(int i = 0; i<CC_SHA256_DIGEST_LENGTH; i++)
        {
            [ret appendFormat:@"%02x",result[i]];
        }
        return ret;
    }
    
    if([inputObject isKindOfClass:[NSData class]]){
        unsigned char hash[CC_SHA256_DIGEST_LENGTH];
        if ( CC_SHA256([(NSData*)inputObject bytes], (int)[(NSData*)inputObject length], hash) ) {
            NSData *sha2 = [NSData dataWithBytes:hash length:CC_SHA256_DIGEST_LENGTH];
            
            // description converts to hex but puts <> around it and spaces every 4 bytes
            NSString *hash = [sha2 description];
            hash = [hash stringByReplacingOccurrencesOfString:@" " withString:@""];
            hash = [hash stringByReplacingOccurrencesOfString:@"<" withString:@""];
            hash = [hash stringByReplacingOccurrencesOfString:@">" withString:@""];
            // hash is now a string with just the 40char hash value in it
            
            int keyLength = (int)[hash length];
            NSString *formattedKey = @"";
            for (int i=0; i<keyLength; i+=2) {
                NSString *substr=[hash substringWithRange:NSMakeRange(i, 2)];
                formattedKey = [formattedKey stringByAppendingString:substr];
            }
            return formattedKey;
        }
    }
    
    NSLog(@"%s: inputObject is not a NSString or NSData", __PRETTY_FUNCTION__);
    return NULL;
}


+ (NSData *)randomDataOfLength:(size_t)length {
    NSMutableData *data = [NSMutableData dataWithLength:length];
    int result = SecRandomCopyBytes(kSecRandomDefault,length,data.mutableBytes);
    if(result != 0){
        NSLog(@"%s: Unable to generate random bytes %d", __PRETTY_FUNCTION__, errno);
        return NULL;
    }
    return data;
}

@end
