//
//  DeviceSecurity.h
//  SecurityDomain
//
//  Created by Van Trung on 6/25/15.
//  Copyright (c) 2015 mTouche. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface DeviceSecurity : NSObject

/*
 * Check if user is running in Jailbroken device or not.
 * Task 11308:[iOS] - CASE 12 - Security Issue - Application continues to work on Jailbroken/Rooted device
 * Authour: Jurian
 */
+(BOOL)isJailbroken;

/*
 * Remove cache database inside application for fixing security issue.
 * Task 11232:[iOS][Security Issues] - SCD-014 (Medium risk) Cached data information leakage
 * Authour: Jurian
 */
+(void)removeCacheDataInsideApp;

/*
 * Add blackView to prevent user get data from snapshot.
 * Authour: Jurian
 */
+ (void)addBlankViewForSnapShotPrevention:(UIWindow*)window ;

/*
 * Remove blackView when user use app again
 * Authour: Jurian
 */
+ (void)removeBlankViewForSnapShotPrevention:(UIWindow*)window;

/*
 * clear Cache
 * Authour: Jurian
 */

+(void) clearDeviceCache;

@end
