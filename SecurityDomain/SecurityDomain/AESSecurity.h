//
//  AESSecurity.h
//  SecurityDomain
//
//  Created by MTouche on 12/30/14.
//  Copyright (c) 2014 mTouche. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AESSecurity : NSObject

/*
 * encryptAES256WithKey from key and inputData.
 * key length must equal kCCKeySizeAES256/32 bytes.
 * @author Trung
 * return NSData* encrypted by AES256;
 * failed method return NULL;
 */
+ (NSData*) encryptAES256WithKey:(NSData *)key
                            Data:(NSData *)inputData;

/*
 *AES method replace saltData > iv of AES;
 */
+ (NSData*) encryptAES256WithKey:(NSData *)key
                            Data:(NSData *)inputData
                            Salt:(NSData *)saltData;

/*
 * decryptAES256WithKey from key and inputData.
 * key length must equal kCCKeySizeAES256/32 bytes.
 * @author Trung
 * return NSData* decrypted
 * failed method return NULL.
 */
+ (NSData *) decryptAES256WithKey:(NSData *)key
                             Data:(NSData *)inputData;

/*
 * hash inputString using PBKDF2 method.
 * @author Trung
 * return NSData* was hashed
 * failed method return NULL.
 */
+(NSData*) hashPBKDF2:(NSString*)inputString
                 Salt:(NSData*) salt;

/*
 * hash inputObject using SHA256 method.
 * NOTE: inputObject accept only NSString*(NSUTF8Encoding) and NSData* type;
 * @author Trung
 * return NSString*
 * failed method return NULL.
 */
+(NSString*) hashSHA256:(id) inputObject;

/*
 * randomDataOfLength with size_t length.
 * @author Trung
 * return NSData* with randomValue.
 */
+ (NSData *)randomDataOfLength:(size_t)length;

@end
