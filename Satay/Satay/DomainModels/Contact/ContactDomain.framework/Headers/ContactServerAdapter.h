//
//  ServerAdapter.h
//  ChatDomain
//
//  Created by MTouche on 1/12/15.
//  Copyright (c) 2015 mTouche. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kAPI_REQUEST_METHOD @"API_REQUEST_METHOD"// POST or GET
#define kAPI_REQUEST_KIND @"API_REQUEST_KIND"// Upload or Download or Normal
#define kAPI_UPLOAD_FILEDATA @"API_UPLOAD_FILEDATA"// File data
#define kAPI_UPLOAD_NAMEUPLOAD @"API_UPLOAD_NAMEUPLOAD"// name for upload
#define kAPI_UPLOAD_FILENAME @"API_UPLOAD_FILENAME"// file name
#define kAPI_UPLOAD_FILETYPE @"API_UPLOAD_FILETYPE"// File type

#define kRESPONSE_DATA @"RESPONSE_DATA"// Using for downloading data of file by API

#define kAPI_ENCRYPTION_TENANT @"API_ENCRYPTION_TENANT"
#define kAPI_PROTOCOL_TENANT @"API_PROTOCOL_TENANT"
#define kAPI_PORT_TENANT @"API_PORT_TENANT"

#define kMAINTENANCE_MSG @"MAINTENANCE_MSG"
#define ERROR_STATUS_CODE_SERVER_MAINTERNACE -9999

@interface ContactServerAdapter : NSObject

/*
 *Singleton of this object
 *Author Trung
 *Purpose, use this method to prevent re-new object.
 *Config DDLog at share creation;
 */
+ (ContactServerAdapter *)share;

/*
 * Call this function for setting up the default server configuration(called Central Server).
 * It will connect to centralise database (for sharing).
 include:
 * API_ENCRYPTION_CENTRAL
 * API_PROTOCOL_CENTRAL
 * API_PORT_CENTRAL
 * SERVER_CENTRAL
 * @author Trung/Parker
 */
-(void) configServerCentral;

/*
 * The configuration that you configure for your server(called Tenant Server).
 * serverConfig must key - value:
 * API_ENCRYPTION_TENANT - 0 or 1 // http or https
 * API_PROTOCOL_TENANT - domain name, ip statistic, eg: api.mtouche.com
 * API_PORT_TENANT - default value is 80.
 * Always re-write the config when run.
 *@author Trung/Parker
 */
-(void) configServerTenant:(NSDictionary*) serverConfig;

/*
 * callback block for request service
 *@author Parker
 */
typedef void (^requestCompletionBlock)(BOOL success, NSString *message ,NSDictionary *response, NSError *error);

/**
 *@ paramDic must have values for keys: API, API_VERSION, API_REQUEST_METHOD, API_REQUEST_KIND
 if API_REQUEST_KIND is Upload: API, API_VERSION, API_REQUEST_METHOD, API_REQUEST_KIND, API_UPLOAD_FILEDATA, API_UPLOAD_NAMEUPLOAD, API_UPLOAD_FILENAME, API_UPLOAD_FILETYPE
 * @parameter isTenantServer. Request to tenant server or central server. Default is central server
 eg: API = "profile.php";
 @ callback: requestCompletionBlock callback
 *@author Parker
 */
-(void) requestService:(NSDictionary*) paramDic tenantServer:(BOOL)isTenantServer callback:(requestCompletionBlock)callback;

@end