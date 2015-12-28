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
//  SRDRequestAPIObject.h
//  SotoRemoteDebugger
//
//  Created by Duong (Daryl) H. DANG on 3/5/15.
//  Copyright (c) 2015 Duong (Daryl) H. DANG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface SRDRequestAPIObject : NSObject

@property (nonatomic, retain) NSString *RequestSource;
@property (nonatomic, retain) NSString *RequestDevice;
@property (nonatomic, retain) NSString *RequestOSVersion;
@property (nonatomic, retain) NSString *RequestAppVersion;
@property (nonatomic, retain) NSString *RequestScenario;
@property (nonatomic, retain) NSDate *RequestTime;
@property (nonatomic, retain) NSString *RequestFormat;
@property (nonatomic, retain) NSString *RequestSessionID;
@property (nonatomic, retain) NSArray *RequestContent;
@property (nonatomic, retain) NSString *RequestExtra1;
@property (nonatomic, retain) NSString *RequestExtra2;


/**
 *  Init request object.
 *
 *  @param parametersDic Dictionary must contain Key: REQUEST_SOURCE, REQUEST_DEVICE, REQUEST_OSVERSION, REQUEST_APPVERSION, REQUEST_SCENARIO, REQUEST_SESSION_ID, REQUEST_FORMAT, REQUEST_CONTENT ,REQUEST_EXTRA1, REQUEST_EXTRA2
 *
 *  @return request object
 */
- (instancetype)initWithDic:(NSDictionary *)parametersDic;

/**
 *  Request object in dictionary
 *
 *  @return dictionary of request object.
 */
- (NSDictionary*) getRequestAPIObjectInDictionary;

@end
