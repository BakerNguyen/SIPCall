//
//  MD5Security.h
//  SecurityDomain
//
//  Created by MTouche on 12/29/14.
//  Copyright (c) 2014 mTouche. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MD5Security : NSObject

/**
 * generateMD5 string from inputObject.
 * @author Trung
 * @param (id) inputObject, 
 * NOTE, the inputObject accept only NSString or NSData type. else will return NULL;
 */
+(NSString*) generateMD5:(id) inputObject;


/**
 * compare MD5 of firstObject and secondObject.
 * @author Trung
 * @param (id) firstObject, (id) secondObject;
 */
+(BOOL) compareMD5:(id) firstObject
      SecondObject:(id) secondObject;

@end
