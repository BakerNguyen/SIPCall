/*
 +--------------------------------------------------------------------------
 |
 | WARNING: REMOVING THIS COPYRIGHT HEADER IS EXPRESSLY FORBIDDEN
 |
 | SOTO REMOTE DEBUGGER
 | ========================================
 | by ENCLAVE, INC.
 | (c) 2012-2013 ENCLAVEIT.COM - All right reserved
 | Website: http://www.enclaveit.com [^]
 | Email : engineering@enclave.vn
 | ========================================
 |
 | WARNING //--------------------------
 |
 | Selling the code for this program without prior written consent is expressly
 | forbidden.
 | This computer program is protected by copyright law.
 | Unauthorized reproduction or distribution of this program, or any portion of
 | if, may result in severe civil and criminal penalties and will be prosecuted
 | to the maximum extent possible under the law.
 +--------------------------------------------------------------------------
 */

//
//  SRDConstants.h
//  SotoRemoteDebugger
//
//  Created by Duong (Daryl) H. DANG on 3/5/15.
//  Copyright (c) 2015 Duong (Daryl) H. DANG. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SRDConstants : NSObject

/**
 * NSDictionary - Key value for log level.
 */
extern NSString *const LOG_KEY;

/**
 * NSDictionary - Key value for log level.
 */
extern NSString *const LOG_LEVEL;

/**
 * NSDictionary - Key value for log class.
 */
extern NSString *const LOG_CLASS;

/**
 * NSDictionary - Key value for log category.
 */
extern NSString *const LOG_CATEGORY;

/**
 * NSDictionary - Key value for log session.
 */
extern NSString *const LOG_SESSION_ID;

/**
 * NSDictionary - Key value for log message.
 */
extern NSString *const LOG_MESSAGE;

/**
 * NSDictionary - Key value for log time.
 */
extern NSString *const LOG_TIME;

/**
 * NSDictionary - Key value for log extra 1.
 */
extern NSString *const LOG_EXTRA1;

/**
 * NSDictionary - Key value for log extra 2.
 */
extern NSString *const LOG_EXTRA2;

/**
 * NSDictionary - Key value for request source.
 */
extern NSString *const REQUEST_SOURCE;

/**
 * NSDictionary - Key value for request device's name.
 */
extern NSString *const REQUEST_DEVICE;

/**
 * NSDictionary - Key value for request os version.
 */
extern NSString *const REQUEST_OSVERSION;

/**
 * NSDictionary - Key value for request app version.
 */
extern NSString *const REQUEST_APPVERSION;

/**
 * NSDictionary - Key value for request scenario.
 */
extern NSString *const REQUEST_SCENARIO;

/**
 * NSDictionary - Key value for log session.
 */
extern NSString *const REQUEST_SESSION_ID;

///**
// * NSDictionary - Key value for request jid.
// */
//extern NSString *const REQUEST_JID;

/**
 * NSDictionary - Key value for request format.
 */
extern NSString *const REQUEST_FORMAT;

/**
 * NSDictionary - Key value for request time.
 */
extern NSString *const REQUEST_TIME;

/**
 * NSDictionary - Key value for request content.
 */
extern NSString *const REQUEST_CONTENT;

/**
 * NSDictionary - Key value for request extra 1.
 */
extern NSString *const REQUEST_EXTRA1;

/**
 * NSDictionary - Key value for request extra 2.
 */
extern NSString *const REQUEST_EXTRA2;

/**
 * NSDictionary - Key value for response code
 */
extern NSString *const RESPONSE_CODE;

/**
 * NSDictionary - Key value for response message.
 */
extern NSString *const RESPONSE_MESSAGE;

/**
 * NSDictionary - Key value for config URL.
 */
extern NSString *const CONFIG_URL;

/**
 * NSDictionary - Key value for config max item.
 */
extern NSString *const CONFIG_MAXITEM_STORAGE;

/**
 * NSDictionary - Key value for config max item.
 */
extern NSString *const CONFIG_MAXITEM_PERPUSH;

/**
 * NSDictionary - Key value for config min item.
 */
extern NSString *const CONFIG_MINITEM_PERPUSH;

/**
 * NSDictionary - Key value for config percent decrese after per push error.
 */
extern NSString *const CONFIG_PERCENT_DECREASE;

/**
 * Date time format.
 */
extern NSString *const DATE_FORMAT;

/**
 * String JSON.
 */
extern NSString *const STRING_JSON;

/**
 * String XML.
 */
extern NSString *const STRING_XML;

/**
 * String EMPTY.
 */
extern NSString *const STRING_EMPTY;

/**
 * String URL.
 */
extern NSString *const BASE_URL;

@end
