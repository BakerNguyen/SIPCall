//
//  Profile.h
//  ChatDomain
//
//  Created by MTouche on 12/23/14.
//  Copyright (c) 2014 mTouche. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define kCOUNTRY_NAME @"COUNTRY_NAME"
#define kCOUNTRY_CODE @"COUNTRY_CODE"
#define kDIAL_CODE @"DIAL_CODE"
#define kUNKNOWN @"UNKNOWN"

@interface ProfileAdapter : NSObject

typedef void (^requestCompleteBlock)(BOOL success, NSString *message ,NSDictionary *response, NSError *error);

/**
 *Singleton of this object
 *Author Trung
 *Purpose, use this method to prevent re-new object.
 */
+ (ProfileAdapter *)share;

/**
 * setProfileName stored by NSDefault.
 * @author Trung
 * @param (NSString*) strName. owner name.
 */
-(void) setProfileName: (NSString*) strName;

/**
 * getProfileName stored in NSDefault.
 * @author Trung
 * return profile name store in NSDefault or NULL.
 */
-(NSString*) getProfileName;

/**
 * setProfileStatus using NSDefault.
 * @author Trung
 * @param (NSString*) strStatus. owner status.
 */
-(void) setProfileStatus: (NSString*) strStatus;

/**
 * getProfileStatus stored in NSDefault.
 * @author Trung
 * return profile status store in NSDefault or @"" - empty string.
 */
-(NSString*) getProfileStatus;

/**
 * get UIImage to AVATAR folder, link set to NSDefault
 * @author Trung
 *
 */
-(BOOL) setProfileAvatar:(NSData*) avatarData;

/**
 * get UIImage from AVATAR folder, link get from NSDefault
 * @author Trung
 *
 */
-(UIImage*) getProfileAvatar;

/**
 * get NSData from AVATAR folder, link get from NSDefault
 * @author Trung
 *
 */
-(NSData*) getProfileAvatarData;

/**
 * get current country and dial code in device if device has phone number. Default Malaysia,+60.
 * @author Parker
 *
 */
-(NSDictionary *)getCurrentCountryNameWithDialCode;

/**
 * get list all countries name with dial codes.
 * @author Parker
 *@return dictionary of all countries and dial code.
 */
- (NSDictionary*)getAllCountriesWithDialCodes;

/**
 * get list all countries name with country code and dial codes.
 * @author Parker
 *@return dictionary of all countries with country code and dial code.
 */
- (NSArray*)getAllCountriesWithCountryCodesAndDialCodes;

/**
 * get list all countries .
 * @author Parker
 *@return dictionary of all countries.
 */
- (NSArray*)getAllCountriesList;

/**
 * Get device name .
 * @author Parker
 *@return NSString.
 */
-(NSString*)getDeviceName;

/**
 * Get device version .
 * @author Parker
 *@return NSString.
 */
-(NSString*)getDeviceVersion;

/**
 * Get device model .
 * @author Parker
 *@return NSString, if failed return "iOS Simulator Model".
 */
-(NSString*)getDeviceModel;

/**
 * Get IMEI of device .
 * @author Parker
 *@return NSString, if failed return nil.
 */
-(NSString*)getIMEIOfDevice;

/**
 * Generate UDID .
 * @author Parker
 *@return NSString.
 */
-(NSString*)generateUDID;

/**
 * Get time zone base on GMT.
 * @author Parker
 *@return NSString form "0", "7", "12".
 */
-(NSString*) getTimeZone;

/**
 * update Display Name to server tenant
 * @author Parker
 * @parameter parametersDic must have value for keys:API,API_REQUEST_METHOD(POST/GET),API_REQUEST_KIND(Upload/Download/Normal), JID, TOKEN(tenant), DISPLAY_NAME, MASKING_ID, IMEI, IMSI
 * @parameter callback with response include: SUCCESS, STATUS_CODE, STATUS_MSG
 */
-(void)updateDisplayName:(NSDictionary*)parametersDic callback:(requestCompleteBlock)callback;

/**
 * check MSISDN to server.
 * @author Parker
 * @parameter parametersDic must have value for keys:API_REQUEST_METHOD(POST/GET),API_REQUEST_KIND(Upload/Download/Normal),MASKING_ID, TOKEN, MSISDN, IMSI, IMEI.

 * @return callback with SUCCESS, STATUS_CODE, STATUS_MSG, EXIST

 */
-(void)checkMSISDNToServer:(NSDictionary*)parametersDic callback:(requestCompleteBlock)callback;

/**
 * Send verification code to server.
 * @author Parker
 * @parameter parametersDic must have value for keys:API,API_REQUEST_METHOD(POST/GET),API_REQUEST_KIND(Upload/Download/Normal), MESSAGE_ID, MSISDN, OTP
 * @parameter callback
 */
-(void)sendVerificationCode:(NSDictionary*)parametersDic resendCode:(BOOL)isResend callback:(requestCompleteBlock)callback;

/**
 * Verify the OTP code, check the expiration.
 * @author Jurian
 * @parameter parametersDic must have value for keys:API,API_REQUEST_METHOD(POST/GET),API_REQUEST_KIND(Upload/Download/Normal), MSISDN, COUNTRY_CODE
 * @parameter callback
 */
-(void)verifyOTP:(NSDictionary*)parametersDic callback:(requestCompleteBlock)callback;
/**
 * Description: update MSISDN to tenant server.
 * @author Parker
 * @parameter parametersDic must have value for keys:API,API_REQUEST_METHOD(POST/GET),API_REQUEST_KIND(Upload/Download/Normal), MASKING_ID, TOKEN, MSISDN, IMSI, IMEI.
 * @return callback with respone include: SUCCESS, STATUS_CODE, STATUS_MSG
 */
-(void)updateMSISDNToServer:(NSDictionary*)parametersDic callback:(requestCompleteBlock)callback;

/**
 * upload avatar to server.
 * @author Parker
 * @parameter parametersDic must have value for keys:API,API_REQUEST_METHOD(POST/GET),API_REQUEST_KIND(Upload), API_UPLOAD_FILEDATA, API_UPLOAD_NAMEUPLOAD, API_UPLOAD_FILENAME, API_UPLOAD_FILETYPE.
 * @parameter callback
 */
-(void)uploadAvatarToServer:(NSDictionary*)parametersDic callback:(requestCompleteBlock)callback;

/**
 * @description: Sync user setting with server.
 * @author Parker
 * @parameter parametersDic must have value for keys:API,API_REQUEST_METHOD(POST/GET),API_REQUEST_KIND(Upload/Download/Normal), MASKING_ID, TOKEN, SETTING, ACTION, IMEI, IMSI.
 *
 * @return callback: STATUS_CODE, STATUS_MSG, SUCCESS, SETTING_STATUS, SETTING
 */
-(void)synUserSettingWithServer:(NSDictionary*)parametersDic callback:(requestCompleteBlock)callback;


@end
