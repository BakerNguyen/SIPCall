//
//  RSASecurity.h
//  SecurityDomain
//
//  Created by MTouche on 1/2/15.
//  Copyright (c) 2015 mTouche. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RSASecurity : NSObject

/*
 * encryptRSA inputData.
 * param b4PubExp, b4Modulus...
 * @author Trung
 * return NSData* encrypted by RSA method, support upto 32 bytes length only.
 * failed method return NULL;
 */
+(NSData*) encryptRSA:(NSData*) inputData
         b64PublicExp:(NSString*) b64PublicExp
           b64Modulus:(NSString *)b64Modulus;

/*
 * decryptRSA inputData.
 * param b4PubExp, b4Modulus, b4PriExp ...
 * @author Trung
 * return NSData* encrypted by RSA method
 * failed method return NULL;
 */
+ (NSData *) decryptRSA:(NSString *)base64Encrypted
           b64PublicExp:(NSString *)b64PublicExp
             b64Modulus:(NSString *)b64Modulus
          b64PrivateExp:(NSString *)b64PrivateExp;

/*
 * generate RSA key.
 * @author Trung
 * return NSDictionary* contain: 
    kRSA_PRIVATE_EXPONENT b64PriExp
    kRSA_MODULUS b64Modulus,
    kRSA_PUBLIC_EXPONENT b64exponent,  ...
 * failed method return NULL;
 */
+ (NSDictionary*) generateRSAKeyPair;

@end
