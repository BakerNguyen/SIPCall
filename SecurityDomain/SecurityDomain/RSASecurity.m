//
//  RSASecurity.m
//  SecurityDomain
//
//  Created by MTouche on 1/2/15.
//  Copyright (c) 2015 mTouche. All rights reserved.
//

#import "RSASecurity.h"
#import "Base64Security.h"
#import "SecurityDefine.h"
#import <CommonCrypto/CommonCryptor.h>

#include <openssl/rsa.h>
#include <openssl/err.h>
#include <openssl/pem.h>
#include <openssl/bio.h>
#include <openssl/evp.h>

@implementation RSASecurity

+(NSData*) encryptRSA:(NSData*) inputData
         b64PublicExp:(NSString*) b64PublicExp
           b64Modulus:(NSString *)b64Modulus{
    
    NSData* modulus = [Base64Security decodeBase64String:b64Modulus];
    NSData* exponent = [Base64Security decodeBase64String:b64PublicExp];
    
    if(!exponent || !modulus){
        NSLog(@"%s: b4PubExp or b4Modulus is NULL", __PRETTY_FUNCTION__);
        return NULL;
    }
    
    unsigned char *_modulus = (unsigned char *) [modulus bytes];
    unsigned char *_exp = (unsigned char *) [exponent bytes];
    
    unsigned char * plain = (unsigned char *) [inputData bytes];
    size_t plain_length = [inputData length];
    
    BIGNUM * bn_mod = NULL;
    BIGNUM * bn_exp = NULL;
    
    bn_mod = BN_bin2bn(_modulus, 128, NULL); // Convert both values to BIGNUM
    bn_exp = BN_bin2bn(_exp, 3, NULL);
    
    RSA * key;
    key = RSA_new(); // Create a new RSA key
    key->n = bn_mod; // Assign in the values
    key->e = bn_exp;
    key->d = NULL;
    key->p = NULL;
    key->q = NULL;
    
    int maxSize = RSA_size(key); // Find the length of the cipher text
    
    unsigned char * cipher = (unsigned char *)malloc(sizeof(unsigned char) * maxSize);
    memset(cipher, 0, maxSize);
    RSA_public_encrypt((int)plain_length, plain, cipher, key,RSA_PKCS1_PADDING); // Encrypt plaintext
    
    NSData * retval = [NSData dataWithBytes:cipher length:maxSize];
    free(cipher);
    return retval;
}

+ (NSData *) decryptRSA:(NSString *)base64Encrypted
           b64PublicExp:(NSString *)b64PublicExp
             b64Modulus:(NSString *)b64Modulus
          b64PrivateExp:(NSString *)b64PrivateExp{
    
    NSData* encryptedData = [Base64Security decodeBase64String:base64Encrypted];
    if(!encryptedData){
        NSLog(@"%s: base64Encrypted is not bas64 format or is NULL", __PRETTY_FUNCTION__);
        return NULL;
    }
    
    NSData* exp_b64 = [Base64Security decodeBase64String:b64PublicExp];
    NSData* modulus_b64 = [Base64Security decodeBase64String:b64Modulus];
    NSData* priexp_b64 = [Base64Security decodeBase64String:b64PrivateExp];
    
    if(!modulus_b64 || ! exp_b64 || !priexp_b64){
        NSLog(@"%s: invalid b64 params", __PRETTY_FUNCTION__);
        return NULL;
    }
    
    BIGNUM * bn_mod = BN_bin2bn([modulus_b64 bytes], (int)[modulus_b64 length], NULL);
    BIGNUM * bn_exp = BN_bin2bn([exp_b64 bytes], (int)[exp_b64 length], NULL);
    BIGNUM * bn_priexp = BN_bin2bn([priexp_b64 bytes], (int)[priexp_b64 length], NULL);
    
    if (!bn_mod || !bn_exp || !bn_priexp){
        NSLog(@"%s: Invalid BIGNUM b4 params", __PRETTY_FUNCTION__);
        return NULL;
    }
    
    RSA *rsa = RSA_new();
    rsa->n = bn_mod; // modulus
    rsa->e = bn_exp; // set it to use public exp
    rsa->d = bn_priexp; // set private exponent
    rsa->iqmp = NULL;
    rsa->p = NULL;
    rsa->q = NULL;
    
    unsigned char *aesKey = (unsigned char *)[encryptedData bytes];
    unsigned char* decrypt = malloc(RSA_size(rsa));
    char* err = (char*)malloc(130);
    
    int result = RSA_private_decrypt(RSA_size(rsa),aesKey,decrypt,rsa,RSA_PKCS1_PADDING);
    
    if(result == -1)
    {
        ERR_load_crypto_strings();
        ERR_error_string(ERR_get_error(), err);
        fprintf(stderr, "Error decrypting message: %s\n", err);
        return NULL;
    }
    if (result != 32)
        NSLog(@"%s: result length != 32, this is not an AESKey", __PRETTY_FUNCTION__);
    
    // AES Key Fixed 32 due to using AES256
    //NSData *returnData = [NSData dataWithBytes:(const void *)decrypt length:strlen(kAlgorithmKeySize)];
    NSData *returnData = [NSData dataWithBytesNoCopy:decrypt
                                              length:result];
    
    return returnData;
}

+ (NSDictionary*) generateRSAKeyPair{
    RSA *rsa = RSA_new();
    BIGNUM *oBigNbr = BN_new();
    BN_set_word(oBigNbr, RSA_F4); // set exponent
    RSA_generate_key_ex(rsa, 1024, oBigNbr, NULL);
    BN_free(oBigNbr);
    
    unsigned char *modulus = malloc( BN_num_bytes(rsa->n));
    int pubmod_length = BN_bn2bin(rsa->n, modulus);
    NSData* modulusData = [[NSData alloc] initWithBytes:modulus length:pubmod_length];
    NSString* base64modulus = [Base64Security generateBase64String:modulusData];
    
    unsigned char *exp = malloc(BN_num_bytes(rsa->e));
    int exp_length = BN_bn2bin(rsa->e, exp);
    NSData* exponentData = [NSData dataWithBytesNoCopy:exp length:exp_length];
    NSString* base64exponent = [Base64Security generateBase64String:exponentData];
    
    unsigned char *priExp = malloc( BN_num_bytes(rsa->d));
    int priexp_length = BN_bn2bin(rsa->d, priExp);
    NSData* priExpData = [NSData dataWithBytesNoCopy:priExp length:priexp_length];
    NSString* base64priExp = [Base64Security generateBase64String:priExpData];
    
    if(base64modulus && base64exponent && base64priExp){
        NSMutableDictionary* dicKey = [NSMutableDictionary new];
        [dicKey setValue:base64modulus forKey:kRSA_MODULUS];
        [dicKey setValue:base64exponent forKey:kRSA_PUBLIC_EXPONENT];
        [dicKey setValue:base64priExp forKey:kRSA_PRIVATE_EXPONENT];
        return dicKey;
    }
    
    return NULL;
}

//fix fwrite$UNIX2003 in new xcode 6.0
size_t fwrite$UNIX2003( const void *a, size_t b, size_t c, FILE *d )
{
    return fwrite(a, b, c, d);
}
char* strerror$UNIX2003( int errnum )
{
    return strerror(errnum);
}
time_t mktime$UNIX2003(struct tm * a)
{
    return mktime(a);
}
double strtod$UNIX2003(const char * a, char ** b) {
    return strtod(a, b);
}

@end
