//
//  Base64Security.h
//  SecurityDomain
//
//  Created by MTouche on 12/29/14.
//  Copyright (c) 2014 mTouche. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Base64Security : NSObject

/**
 * generateBase64String from inputObject.
 * @author Trung
 * @param (id) inputObject accept only:
 * NSString* (will be converted to NSUTF8Encoding)
 * NSData*
 * return NSString* base64 in or NULL.
 */
+(NSString*) generateBase64String:(id) inputObject;

/**
 * decodeBase64String from inputObject.
 * @author Trung
 * @param (id) inputObject,
 * @param (id) inputObject accept only:
 * NSString* and NSData*
 * return NSData* original.
 */
+(NSData*) decodeBase64String:(id) inputObject;

/**
 * checkEncoding from inputData.
 * @author Trung
 * @param (NSData*) inputData
 * return NSStringEncoding of string contain in Data, default is NSUTF8.
 */
+(NSStringEncoding) getEncoding:(NSData*) inputData;

/**
 * check inputString is a base64 string or not.
 * @author Trung
 * @param (NSString*) inputString
 * return TRUE or FALSE.
 */
+(BOOL) isValidBase64:(NSString*) inputString;

@end
