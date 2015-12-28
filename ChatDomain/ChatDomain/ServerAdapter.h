//
//  ServerAdapter.h
//  ChatDomain
//
//  Created by MTouche on 1/12/15.
//  Copyright (c) 2015 mTouche. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ServerAdapter : NSObject

+ (ServerAdapter *)share;

/**
 * configServer include:
 * API_ENCRYPTION
 * API_PROTOCOL
 * API_PORT
 * API ...
 */

/*
 *Default mode, set the most server content default value as mTouche Company defined.
 *this method will over-write all manual config.
 *@author Trung
 */
-(void) configServer;

/*
 *Manual mode, user can change server config value here.
 * dicConfig must key - value:
 * API_ENCRYPTION - 0 or 1
 * API_PROTOCOL - domain name, ip statistic, eg: api.mtouche.com
 * API_PORT - default value is 80.
 * Always re-write the config when run.
 *@author Trung
 */
-(void) configServerManual:(NSDictionary*) serverConfig;

/*
 * getServer config.
 *@author Trung
 */
-(NSDictionary*) getServerConfig;

/*
 * callback block for request service
 *@author Parker
 */
typedef void (^requestCompletionBlock)(BOOL success, NSString *message ,NSDictionary *response, NSError *error);

/**
 *@ paramDic must have values for keys: API, API_VERSION, API_REQUEST_METHOD, API_REQUEST_KIND
 if API_REQUEST_KIND is Upload or Download: API, API_VERSION, API_REQUEST_METHOD, API_REQUEST_KIND, API_REQUEST_FILEPATH
 eg: API = "profile.php";
 @ callback: requestCompletionBlock callback
 *@author Parker
 */
-(void) requestService:(NSDictionary*) paramDic callback:(requestCompletionBlock)callback;

@end
