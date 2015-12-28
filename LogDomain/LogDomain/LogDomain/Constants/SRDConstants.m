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
//  SRDConstants.m
//  SotoRemoteDebugger
//
//  Created by Duong (Daryl) H. DANG on 3/5/15.
//  Copyright (c) 2015 Duong (Daryl) H. DANG. All rights reserved.
//

#import "SRDConstants.h"

@implementation SRDConstants

/**
 * NSDictionary - Key value for log level.
 */
NSString *const LOG_KEY = @"key";

/**
 * NSDictionary - Key value for log level.
 */
NSString *const LOG_LEVEL = @"lvl";

/**
 * NSDictionary - Key value for log class.
 */
NSString *const LOG_CLASS = @"cls";

/**
 * NSDictionary - Key value for log category.
 */
NSString *const LOG_CATEGORY = @"cat";

/**
 * NSDictionary - Key value for log sesion id.
 */
NSString *const LOG_SESSION_ID = @"sid";

/**
 * NSDictionary - Key value for log message.
 */
NSString *const LOG_MESSAGE = @"msg";

/**
 * NSDictionary - Key value for log time.
 */
NSString *const LOG_TIME = @"lt";

/**
 * NSDictionary - Key value for log extra 1.
 */
NSString *const LOG_EXTRA1 = @"ex1";

/**
 * NSDictionary - Key value for log extra 2.
 */
NSString *const LOG_EXTRA2 = @"ex2";

/**
 * NSDictionary - Key value for request source.
 */
NSString *const REQUEST_SOURCE = @"src";

/**
 * NSDictionary - Key value for request device's name.
 */
NSString *const REQUEST_DEVICE = @"dev";

/**
 * NSDictionary - Key value for request os version.
 */
NSString *const REQUEST_OSVERSION = @"os";

/**
 * NSDictionary - Key value for request app version.
 */
NSString *const REQUEST_APPVERSION = @"app";

/**
 * NSDictionary - Key value for request scenario.
 */
NSString *const REQUEST_SCENARIO = @"sc";

/**
 * NSDictionary - Key value for log session.
 */
NSString *const REQUEST_SESSION_ID = @"sid";

///**
// * NSDictionary - Key value for request jid.
// */
//NSString *const REQUEST_JID = @"jid";

/**
 * NSDictionary - Key value for request format.
 */
NSString *const REQUEST_FORMAT = @"fm";

/**
 * NSDictionary - Key value for request time.
 */
NSString *const REQUEST_TIME = @"rt";

/**
 * NSDictionary - Key value for request content.
 */
NSString *const REQUEST_CONTENT = @"ct";

/**
 * NSDictionary - Key value for request extra 1.
 */
NSString *const REQUEST_EXTRA1 = @"ex1";

/**
 * NSDictionary - Key value for request extra 2.
 */
NSString *const REQUEST_EXTRA2 = @"ex2";


/**
 * NSDictionary - Key value for response code
 */
NSString *const RESPONSE_CODE = @"status_code";

/**
 * NSDictionary - Key value for request message.
 */
NSString *const RESPONSE_MESSAGE = @"status_msg";

/**
 * NSDictionary - Key value for config URL.
 */
NSString *const CONFIG_URL = @"BASE_URL";

/**
 * NSDictionary - Key value for config max item.
 */
NSString *const CONFIG_MAXITEM_STORAGE = @"MAX_ITEM_STORAGE";

/**
 * NSDictionary - Key value for config max item.
 */
NSString *const CONFIG_MAXITEM_PERPUSH = @"MAX_ITEM_PER_PUSH";

/**
 * NSDictionary - Key value for config min item.
 */
NSString *const CONFIG_MINITEM_PERPUSH = @"MIN_ITEM";

/**
 * NSDictionary - Key value for config percent decrese after per push error.
 */
NSString *const CONFIG_PERCENT_DECREASE = @"PERCENT_DECREASE";

/**
 * Date time format.
 */
NSString *const DATE_FORMAT = @"yyyy-MM-dd' 'HH:mm:ss";

/**
 * String JSON.
 */
NSString *const STRING_JSON = @"json";

/**
 * String XML.
 */
NSString *const STRING_XML = @"xml";

/**
 * String EMPTY.
 */
NSString *const STRING_EMPTY = @"";

/**
 * String URL.
 */
NSString *const BASE_URL = @"http://203.115.217.10:8080/";

@end
