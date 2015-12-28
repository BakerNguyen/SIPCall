//
//  AccountAdapter.h
//  ContactDomain
//
//  Created by enclave on 1/26/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import <Foundation/Foundation.h>

#define FOLDER_BACKUP_FILE @"BACKUP_FILE"

@interface AccountAdapter : NSObject

typedef void (^requestCompleteBlock)(BOOL success, NSString *message ,NSDictionary *response, NSError *error);

/**
 *Singleton of this object
 *Author Trung
 *Purpose, use this method to prevent re-new object.
 */
+(AccountAdapter *)share;

/**
 * Register account
 * @author Parker
 * @parameter parametersDic must have value for keys:API_REQUEST_METHOD(POST/GET),API_REQUEST_KIND(Upload/Download/Normal), HOST
 HOST(xmpp): satay.mooo.com
 * @return callback with response has MASKING_ID
 */
-(void)getStartedAccount:(NSDictionary*)parametersDic callback:(requestCompleteBlock)callback;

/**
 * Register account
 * @author Parker
 * @parameter parametersDic must have value for keys:API_REQUEST_METHOD(POST/GET),API_REQUEST_KIND(Upload/Download/Normal),HOST, PLATFORM,  IMSI, IMEI, DEVICE_NAME, OS_VERSION, APP_VERSION, DEVICE_ID, TIMEZONE_OFFSET, COUNTRY_CODE, MASKING_ID, SERVICE_ID
 HOST(xmpp): satay.mooo.com
 SERVICE_ID:
 1    Free Trial
 2    3 Months
 3    6 Months
 4    12 Months
 5    Life Time
 6    1 Month
 
 * @return callback with response include: SUCCESS, STATUS_CODE, JID, JID_PASSWORD, JID_HOST, TOKEN(tanent)
 */
-(void)registerAccount:(NSDictionary*)parametersDic callback:(requestCompleteBlock)callback;

/**
 * Set Password to server // 6-16 charater of numberics
 * @author Parker
 * @parameter parametersDic must have value for keys:API_REQUEST_METHOD(POST/GET),API_REQUEST_KIND(Upload/Download/Normal),TOKEN(tenant), IMSI, IMEI, MASKING_ID, PASS_KEY, JID
 
 * @return callback with response include: SUCCESS, STATUS_CODE
 */
-(void)setPasswordToServer:(NSDictionary*)parametersDic callback:(requestCompleteBlock)callback;

/**
 * Upload keys to server
 * @author Parker
 * @parameter parametersDic must have value for keys:API_REQUEST_METHOD(POST/GET),API_REQUEST_KIND(Upload/Download/Normal),MASKING_ID, JID, HOST, PUB1_N, PUB1_E, PUB2_N, PUB2_E, PUB3_N, PUB3_E, IMSI, IMEI, PASS_KEY
 HOST(xmpp): satay.mooo.com
 * @return callback with response include: SUCCESS, STATUS_CODE, STATUS_MSG, TOKEN(central)
 */
-(void)uploadKeysToServer:(NSDictionary*)parametersDic callback:(requestCompleteBlock)callback;

/**
 * Login account to Tenant server
 * @author Parker
 * @parameter parametersDic must have value for keys:API_REQUEST_METHOD(POST/GET),API_REQUEST_KIND(Upload/Download/Normal), HOST MASKING_ID, PASSWORD, IMSI, IMEI, TIMEZONE_OFFSET
 HOST(xmpp): satay.mooo.com
 * @return  callback with response include: SUCCESS, STATUS_CODE, STATUS_MSG, ACCOUNT(MASKING_ID,ACTIVATION_CODE,SERVICE_ID,TOKEN,STATUS,COUNTRY_CODE,DISPLAY_NAME,PROFILE_IMAGE,LOGIN_FLAG,IMEI)
 */
-(void)loginAccountToTenantServer:(NSDictionary*)parametersDic callback:(requestCompleteBlock)callback;

/**
 * Get account details
 * @author Parker
 * @parameter parametersDic must have value for keys:API_REQUEST_METHOD(POST/GET),API_REQUEST_KIND(Upload/Download/Normal), HOST, IMSI, IMEI, DEVICE_NAME, OS_VERSION, APP_VERSION, XMPP_PSW_FLAG, TIMEZONE_OFFSET, TOKEN
 HOST(xmpp): satay.mooo.com
 XMPP_PSW_FLAG: To change XMPP password. Value is 0 or 1
 * @return callback with response include: STATUS_CODE, STATUS_MSG, URL(Wap Page URL for payment),  ACCOUNT(ACTIVATION_CODE,SERVICE_ID,MASKING_ID,DISPLAY_NAME,USER_STATUS,HOST,DEVICE_NAME,REINSTALL_FLAG,TNC_READ_FLAG,STATUS,STATUS_DESC,PLATFORM_ID,SUB_START_DATE,SUB_START_TIME,SUB_END_DATE,SUB_END_TIME,TRANSACTION_METHOD,XMPP_PASSWORD)
 */
-(void)getAccountDetails:(NSDictionary*)parametersDic callback:(requestCompleteBlock)callback;


/**
 * Description: Backup file upload (tenant).
 * @author Parker
 * @parameter parametersDic must have value for keys:API,API_REQUEST_METHOD(POST/GET/PUT),API_REQUEST_KIND(Upload/Download/Normal), MASKINGID, TOKEN, IMEI, IMSI, MASTER_KEY, FILE
 * @return callback with response include: SUCCESS, STATUS_CODE, STATUS_MSG, RESULT
 */
-(void)backupFileUpload:(NSDictionary*)parametersDic callback:(requestCompleteBlock)callback;

/**
 * Description: Backup file download (tenant).
 * @author Parker
 * @parameter parametersDic must have value for keys:API,API_REQUEST_METHOD(POST/GET/PUT),API_REQUEST_KIND(Upload/Download/Normal), MASKINGID, TOKEN, IMEI, IMSI, PASS
 * @return callback with response include: SUCCESS, STATUS_CODE, STATUS_MSG
 */
-(void)backupFileDownload:(NSDictionary*)parametersDic callback:(requestCompleteBlock)callback;

/**
 * Description: Update password backup file (tenant).
 * @author Parker
 * @parameter parametersDic must have value for keys:API,API_REQUEST_METHOD(POST/GET/PUT),API_REQUEST_KIND(Upload/Download/Normal), MASKINGID, TOKEN, IMEI, IMSI, PASS, MASTERKEY
 * @return callback with response include: SUCCESS, STATUS_CODE, STATUS_MSG,
 */
-(void)updatePasswordBackupFile:(NSDictionary*)parametersDic callback:(requestCompleteBlock)callback;

/**
 * Description: Get password backup file (tenant).
 * @author Parker
 * @parameter parametersDic must have value for keys:API,API_REQUEST_METHOD(POST/GET/PUT),API_REQUEST_KIND(Upload/Download/Normal), MASKINGID, TOKEN, IMEI, IMSI
 * @return callback with response include: SUCCESS, STATUS_CODE, STATUS_MSG, PASS, MASTERKEY.
 */
-(void)getPasswordBackupFile:(NSDictionary*)parametersDic callback:(requestCompleteBlock)callback;

/**
 * Description: Backup contact to server.
 * @author Parker
 * @parameter
 * parametersDic :parametersDic must have value for keys:API,API_REQUEST_METHOD(POST/GET/PUT),API_REQUEST_KIND(Upload/Download/Normal), MASKINGID, IMEI, IMSI, TOKEN, CMD(UPDATE), STATUS(APPROVED/PENDING/RECEIVED), FRIENDMASKINGID, DATA, VERSION
 * @return callback with response include: SUCCESS, STATUS_CODE, STATUS_MSG.
 */
-(void)backupContact:(NSDictionary*)parametersDic callback:(requestCompleteBlock)callback;

/**
 * Description: Restore contact. Get all contacts of a user.
 * @author Parker
 * @parameter
 * parametersDic :parametersDic must have value for keys:API,API_REQUEST_METHOD(PUT),API_REQUEST_KIND(Normal), MASKINGID, IMEI, IMSI, TOKEN, CMD(GET), STATUS(APPROVED/PENDING/RECEIVED)
 STATUS: 100 - APPROVED list 010 - PENDING list 001 - RECEIVED list 110 - APPROVED and PENDING list
 * @return callback with response include: SUCCESS, STATUS_CODE, STATUS_MSG, FRIENDMASKINGID, DATA, VERSION, STATUS
 */
-(void)restoreContact:(NSDictionary*)parametersDic callback:(requestCompleteBlock)callback;

/**
 * Description: set backup file. Store backup data to backup file.
 * @author Parker
 * @parameter
 * fileName :backup file name
 * backupData: data of backup
 * @return Boolean(TRUE/FALSE)
 */
-(BOOL) setBackupFile:(NSString*)fileName data:(NSData*) backupData;

/**
 * Description: get backup data from backup file.
 * @author Parker
 * @parameter fileName file backup name
 * @return data of backup file
 */
-(NSData*) getBackupData:(NSString*)fileName;

@end
