//
//  SIPServerAdapter.h
//  SIPDomain
//
//  Created by Daniel Nguyen on 4/20/15.
//  Copyright (c) 2015 mTouche. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kAPI_REQUEST_METHOD @"API_REQUEST_METHOD"// POST or GET
#define kAPI_REQUEST_KIND @"API_REQUEST_KIND"// Upload or Download or Normal
#define kAPI_UPLOAD_FILEDATA @"API_UPLOAD_FILEDATA"// File data
#define kAPI_UPLOAD_NAMEUPLOAD @"API_UPLOAD_NAMEUPLOAD"// name for upload
#define kAPI_UPLOAD_FILENAME @"API_UPLOAD_FILENAME"// file name
#define kAPI_UPLOAD_FILETYPE @"API_UPLOAD_FILETYPE"// File type

#define kAPI_ENCRYPTION_TENANT @"API_ENCRYPTION_TENANT"
#define kAPI_PROTOCOL_TENANT @"API_PROTOCOL_TENANT"
#define kAPI_PORT_TENANT @"API_PORT_TENANT"

@interface SIPServerAdapter : NSObject

+ (SIPServerAdapter *)share;

/**
 *  @author Daniel Nguyen, 15-04-20 13:04
 *
 *  @brief  call this function for setting up the default server configuration. It will connect to centralise database (for shareing). Included: API_ENCRYPTION_CENTRAL, API_PROTOCOL_CENTRAL, API_PORT_CENTRAL, SERVER_CENTRAL
 */
- (void)configServerCentral;

/**
 *  @author Daniel Nguyen, 15-04-20 13:04
 *
 *  @brief  The configuration that you configure for your server (called as Tennant Server).
 *
 *  @param serverConfig must have key - value:
 * {
 *    API_ENCRYPTION_TENANT: 0 or 1 // http or https
 *    API_PROTOCOL_TENANT: domain name, ip statistic, eg: api.mtouche.com
 *    API_PORT_TENANT: default value is 80
 * }
 *
 */
- (void)configServerTenant:(NSDictionary*)serverConfig;

/**
 *  @author Daniel Nguyen, 15-04-20 14:04
 *
 *  @brief  callback block for request service
 *
 *  @param success
 *  @param message
 *  @param response
 *  @param error
 */
typedef void (^requestCompletionBlock)(BOOL success, NSString *message ,NSDictionary *response, NSError *error);

/**
 *  @author Daniel Nguyen, 15-04-20 14:04
 *
 *  @param paramDic       must have values for keys: API, API_VERSION, API_REQUEST_METHOD, API_REQUEST_KIND and more params follow the API Document
 *  @param isTenantServer Request to tenant server or central server. Default is central server
 *  @param callback       requestCompletionBlock callback
 */
- (void)requestService:(NSDictionary*)paramDic tenantServer:(BOOL)isTenantServer callback:(requestCompletionBlock)callback;

@end
