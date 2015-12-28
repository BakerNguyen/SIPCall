//
//  AccountAdapter.m
//  ContactDomain
//
//  Created by enclave on 1/26/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import "AccountAdapter.h"
#import "ContactServerAdapter.h"

//Logging
#import "CocoaLumberjack.h"

//APIs
#define kAPI @"API"
#define kAPI_VERSION @"API_VERSION"
#define API_GET_STARTED_ACCOUNT @"YKiyiufH"
#define API_GET_STARTED_ACCOUNT_VERSION @"v1"

#define API_REGISTER_ACCOUNT @"AfGzIm"
#define API_REGISTER_ACCOUNT_VERSION @"v1"

#define API_SET_PASSWORD @"xZCBUjiXCS"
#define API_SET_PASSWORD_VERSION @"v1"

#define API_UPLOAD_KEYS_ACCOUNT @"uIBjoIry"
#define API_UPLOAD_KEYS_ACCOUNT_VERSION @"v1"

#define API_LOGIN_TO_TENANT_SERVER @"szIpG"
#define API_LOGIN_TO_TENANT_SERVER_VERSION @"v1"

#define API_LOGIN_TO_CENTRAL_SERVER @"szIpG"//@"tQnwRMefdc"
#define API_LOGIN_TO_CENTRAL_SERVER_VERSION @"v1"

#define API_BACKUP_FILE_UPLOAD @"V3xZafFUmz"
#define API_BACKUP_FILE_UPLOAD_VERSION @"v1"

#define API_BACKUP_FILE_DOWNLOAD @"sUxtGsuIib"
#define API_BACKUP_FILE_DOWNLOAD_VERSION @"v1"

#define API_UPDATE_PASS_BACKUP_FILE @"qzTeMn0Eft"
#define API_UPDATE_PASS_BACKUP_FILE_VERSION @"v1"

#define API_GET_PASS_BACKUP_FILE @"tx7nrbGkeT"
#define API_GET_PASS_BACKUP_FILE_VERSION @"v1"

#define API_GET_ACCOUNT_DETAILS @"dAOBNSq5vz"
#define API_GET_ACCOUNT_DETAILS_VERSION @"v1"

#define API_BACKUP_CONTACT @"s7FNy4QT8P"
#define API_BACKUP_CONTACT_VERSION @"v1"

#define API_RESTORE_CONTACT @"s7FNy4QT8P"
#define API_RESTORE_CONTACT_VERSION @"v1"

//#warning for testing v2, will use PUT method and param in header (@Daniel)

//Setter
#define setUDString(object,key) [[NSUserDefaults standardUserDefaults] setObject:object forKey:key]; [[NSUserDefaults standardUserDefaults] synchronize]
//Getter
#define getUDString(key) [[NSUserDefaults standardUserDefaults] objectForKey:key]

//Logging
#ifdef DEBUG
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelOff;
#endif

@implementation AccountAdapter

+(AccountAdapter *)share{
    static dispatch_once_t once;
    static AccountAdapter * share;
    dispatch_once(&once, ^{
        share = [self new];        
    });
    return share;
}

#pragma mark API functions of register account
-(void)getStartedAccount:(NSDictionary*)parametersDic callback:(requestCompleteBlock)callback{
    void (^getStartedAccountCallBack)(BOOL success, NSString *message ,NSDictionary *response, NSError *error);
    
    if (!parametersDic) {
        DDLogError(@"%s: parametersDic NULL.", __PRETTY_FUNCTION__);
        return;
    }
    
    getStartedAccountCallBack =  callback;
    NSMutableDictionary *parameters= [parametersDic mutableCopy];
    [parameters setObject:API_GET_STARTED_ACCOUNT forKey:kAPI];
    [parameters setObject:API_GET_STARTED_ACCOUNT_VERSION forKey:kAPI_VERSION];
    
    [[ContactServerAdapter share] requestService:parameters tenantServer:NO callback:^(BOOL success, NSString *message, NSDictionary *response, NSError *error) {
        if (success) {
            DDLogInfo(@"%s: Successfully.", __PRETTY_FUNCTION__);
            getStartedAccountCallBack(YES, @"Get Started account successfully.", response, nil);
        }else{
            DDLogError(@"%s: Failed.", __PRETTY_FUNCTION__);
            getStartedAccountCallBack(NO, @"Get Started account failed.", response, error);
        }
    }];
    
}

-(void)registerAccount:(NSDictionary*)parametersDic callback:(requestCompleteBlock)callback{
    void (^registerAccountCallBack)(BOOL success, NSString *message ,NSDictionary *response, NSError *error);
    
    if (!parametersDic) {
        DDLogError(@"%s: parametersDic NULL.", __PRETTY_FUNCTION__);
        return;
    }

    registerAccountCallBack =  callback;
    NSMutableDictionary *parameters = [parametersDic mutableCopy];
    [parameters setObject:API_REGISTER_ACCOUNT forKey:kAPI];
    [parameters setObject:API_REGISTER_ACCOUNT_VERSION forKey:kAPI_VERSION];
    
    [[ContactServerAdapter share] requestService:parameters tenantServer:YES callback:^(BOOL success, NSString *message, NSDictionary *response, NSError *error) {
        if (success) {
            DDLogInfo(@"%s: Successfully.", __PRETTY_FUNCTION__);
            registerAccountCallBack(YES, @"Register account successfully.", response, nil);
        }else{
            DDLogError(@"%s: Failed.", __PRETTY_FUNCTION__);
            registerAccountCallBack(NO, @"Register account failed.", response, error);
        }
    }];
}

-(void)setPasswordToServer:(NSDictionary*)parametersDic callback:(requestCompleteBlock)callback{
    void (^setPasswordToServerCallBack)(BOOL success, NSString *message ,NSDictionary *response, NSError *error);
    
    if (!parametersDic) {
        DDLogError(@"%s: parametersDic NULL.", __PRETTY_FUNCTION__);
        return;
    }

    setPasswordToServerCallBack =  callback;
    
    NSMutableDictionary *parameters = [parametersDic mutableCopy];
    [parameters setObject:API_SET_PASSWORD forKey:kAPI];
    [parameters setObject:API_SET_PASSWORD_VERSION forKey:kAPI_VERSION];
    
    [[ContactServerAdapter share] requestService:parameters tenantServer:YES callback:^(BOOL success, NSString *message, NSDictionary *response, NSError *error) {
        if (success) {
            DDLogInfo(@"%s: Successfully.", __PRETTY_FUNCTION__);
            setPasswordToServerCallBack(YES, @"Set password to server successfully.", response, nil);
        }else{
            DDLogError(@"%s: Failed.", __PRETTY_FUNCTION__);
            setPasswordToServerCallBack(NO, @"Set password to server failed.", response, error);
        }
    }];

}

-(void)uploadKeysToServer:(NSDictionary*)parametersDic callback:(requestCompleteBlock)callback{
    void (^uploadKeysToServerCallBack)(BOOL success, NSString *message ,NSDictionary *response, NSError *error);
    
    if (!parametersDic) {
        DDLogError(@"%s: parametersDic NULL.", __PRETTY_FUNCTION__);
        return;
    }
    
    uploadKeysToServerCallBack =  callback;
    
    NSMutableDictionary *parameters = [parametersDic mutableCopy];
    [parameters setObject:API_UPLOAD_KEYS_ACCOUNT forKey:kAPI];
    [parameters setObject:API_UPLOAD_KEYS_ACCOUNT_VERSION forKey:kAPI_VERSION];
    
    [[ContactServerAdapter share] requestService:parameters tenantServer:NO callback:^(BOOL success, NSString *message, NSDictionary *response, NSError *error) {
        if (success) {
            DDLogInfo(@"%s: Successfully.", __PRETTY_FUNCTION__);
            uploadKeysToServerCallBack(YES, @"Upload keys to server successfully.", response, nil);
        }else{
            DDLogError(@"%s: Failed.", __PRETTY_FUNCTION__);
            uploadKeysToServerCallBack(NO, @"Upload keys to server failed.", response, error);
        }
    }];
}

#pragma mark API methods of login
-(void)loginAccountToTenantServer:(NSDictionary*)parametersDic callback:(requestCompleteBlock)callback{
    void (^loginAccountToTenantServerCallBack)(BOOL success, NSString *message ,NSDictionary *response, NSError *error);
    
    if (!parametersDic) {
        DDLogError(@"%s: parametersDic NULL.", __PRETTY_FUNCTION__);
        return;
    }

    loginAccountToTenantServerCallBack =  callback;

    NSMutableDictionary *parameters = [parametersDic mutableCopy];
    
    [parameters setObject:API_LOGIN_TO_TENANT_SERVER forKey:kAPI];
    [parameters setObject:API_LOGIN_TO_TENANT_SERVER_VERSION forKey:kAPI_VERSION];
    
    [[ContactServerAdapter share] requestService:parameters tenantServer:YES callback:^(BOOL success, NSString *message, NSDictionary *response, NSError *error) {
        if (success) {
            DDLogInfo(@"%s: Successfully.", __PRETTY_FUNCTION__);
            loginAccountToTenantServerCallBack(YES, @"Login account to tenant server successfully.", response, nil);
        }else{
            DDLogError(@"%s: Failed.", __PRETTY_FUNCTION__);
            loginAccountToTenantServerCallBack(NO, @"Login account to tenant server failed.", response, error);
        }
    }];
}

-(void)getAccountDetails:(NSDictionary*)parametersDic callback:(requestCompleteBlock)callback{
    void (^getAccountDetailsCallBack)(BOOL success, NSString *message ,NSDictionary *response, NSError *error);
    
    if (!parametersDic) {
        DDLogError(@"%s: parametersDic NULL.", __PRETTY_FUNCTION__);
        return;
    }
    
    getAccountDetailsCallBack =  callback;
    
    NSMutableDictionary *parameters = [parametersDic mutableCopy];
    [parameters setObject:API_GET_ACCOUNT_DETAILS forKey:kAPI];
    [parameters setObject:API_GET_ACCOUNT_DETAILS_VERSION forKey:kAPI_VERSION];
    
    [[ContactServerAdapter share] requestService:parameters tenantServer:YES callback:^(BOOL success, NSString *message, NSDictionary *response, NSError *error) {
        if (success) {
            DDLogInfo(@"%s: Successfully.", __PRETTY_FUNCTION__);
            getAccountDetailsCallBack(YES, @"Get account detail from server successfully.", response, nil);
        }else{
            DDLogError(@"%s: Failed.", __PRETTY_FUNCTION__);
            getAccountDetailsCallBack(NO, @"Get account detail from server failed.", response, error);
        }
    }];
}
#pragma mark API methods of backup and restore profile
-(void)backupFileUpload:(NSDictionary*)parametersDic callback:(requestCompleteBlock)callback{
    if (!parametersDic) {
        DDLogError(@"%s: parametersDic NULL.", __PRETTY_FUNCTION__);
        return;
    }
    void (^backupFileUploadCallBack)(BOOL success, NSString *message ,NSDictionary *response, NSError *error);
    
    backupFileUploadCallBack =  callback;
    
    NSMutableDictionary *parameters = [parametersDic mutableCopy];
    [parameters setObject:API_BACKUP_FILE_UPLOAD forKey:kAPI];
    [parameters setObject:API_BACKUP_FILE_UPLOAD_VERSION forKey:kAPI_VERSION];
    
    [[ContactServerAdapter share] requestService:parameters tenantServer:YES callback:^(BOOL success, NSString *message, NSDictionary *response, NSError *error) {
        if (success) {
            DDLogInfo(@"%s: Successfully.", __PRETTY_FUNCTION__);
            backupFileUploadCallBack(YES, @"Backup file upload successfully.", response, nil);
        }else{
            DDLogError(@"%s: Failed.", __PRETTY_FUNCTION__);
            backupFileUploadCallBack(NO, @"Backup file upload failed.", response, error);
        }
    }];
}

-(void)backupFileDownload:(NSDictionary*)parametersDic callback:(requestCompleteBlock)callback{
    if (!parametersDic) {
        DDLogError(@"%s: parametersDic NULL.", __PRETTY_FUNCTION__);
        return;
    }
    
    void (^backupFileDownloadCallBack)(BOOL success, NSString *message ,NSDictionary *response, NSError *error);
    
    backupFileDownloadCallBack =  callback;
    
    NSMutableDictionary *parameters = [parametersDic mutableCopy];
    [parameters setObject:API_BACKUP_FILE_DOWNLOAD forKey:kAPI];
    [parameters setObject:API_BACKUP_FILE_DOWNLOAD_VERSION forKey:kAPI_VERSION];
    
    [[ContactServerAdapter share] requestService:parameters tenantServer:YES callback:^(BOOL success, NSString *message, NSDictionary *response, NSError *error) {
        if (success) {
            DDLogInfo(@"%s: Successfully.", __PRETTY_FUNCTION__);
            backupFileDownloadCallBack(YES, @"Backup file download successfully.", response, nil);
        }else{
            DDLogError(@"%s: Failed.", __PRETTY_FUNCTION__);
            backupFileDownloadCallBack(NO, @"Backup file download failed.", response, error);
        }
    }];
}

-(void)updatePasswordBackupFile:(NSDictionary*)parametersDic callback:(requestCompleteBlock)callback{
    if (!parametersDic) {
        DDLogError(@"%s: parametersDic NULL.", __PRETTY_FUNCTION__);
        return;
    }
    void (^updatePasswordBackupFileCallBack)(BOOL success, NSString *message ,NSDictionary *response, NSError *error);
    
    updatePasswordBackupFileCallBack =  callback;
    
    NSMutableDictionary *parameters = [parametersDic mutableCopy];
    [parameters setObject:API_UPDATE_PASS_BACKUP_FILE forKey:kAPI];
    [parameters setObject:API_UPDATE_PASS_BACKUP_FILE_VERSION forKey:kAPI_VERSION];
    
    [[ContactServerAdapter share] requestService:parameters tenantServer:YES callback:^(BOOL success, NSString *message, NSDictionary *response, NSError *error) {
        if (success) {
            DDLogInfo(@"%s: Successfully.", __PRETTY_FUNCTION__);
            updatePasswordBackupFileCallBack(YES, @"Update password backup file successfully.", response, nil);
        }else{
            DDLogError(@"%s: Failed.", __PRETTY_FUNCTION__);
            updatePasswordBackupFileCallBack(NO, @"Update password backup file failed.", response, error);
        }
    }];
}

-(void)getPasswordBackupFile:(NSDictionary*)parametersDic callback:(requestCompleteBlock)callback{
    if (!parametersDic) {
        DDLogError(@"%s: parametersDic NULL.", __PRETTY_FUNCTION__);
        return;
    }
    
    void (^getPasswordBackupFileCallBack)(BOOL success, NSString *message ,NSDictionary *response, NSError *error);
    getPasswordBackupFileCallBack =  callback;
    
    NSMutableDictionary *parameters = [parametersDic mutableCopy];
    [parameters setObject:API_GET_PASS_BACKUP_FILE forKey:kAPI];
    [parameters setObject:API_GET_PASS_BACKUP_FILE_VERSION forKey:kAPI_VERSION];
    
    [[ContactServerAdapter share] requestService:parameters tenantServer:YES callback:^(BOOL success, NSString *message, NSDictionary *response, NSError *error) {
        if (success) {
            DDLogInfo(@"%s: Successfully.", __PRETTY_FUNCTION__);
            getPasswordBackupFileCallBack(YES, @"Get password backup file successfully.", response, nil);
        }else{
            DDLogError(@"%s: Failed.", __PRETTY_FUNCTION__);
            getPasswordBackupFileCallBack(NO, @"Get password backup file failed.", response, error);
        }
    }];
}
#pragma mark API methods of backup and restore contact
-(void)backupContact:(NSDictionary*)parametersDic callback:(requestCompleteBlock)callback{
    if (!parametersDic) {
        DDLogError(@"%s: parametersDic NULL.", __PRETTY_FUNCTION__);
        return;
    }
    
    void (^backupContactCallBack)(BOOL success, NSString *message ,NSDictionary *response, NSError *error);
    
    backupContactCallBack =  callback;
    
    NSMutableDictionary *parameters = [parametersDic mutableCopy];
    [parameters setObject:API_BACKUP_CONTACT forKey:kAPI];
    [parameters setObject:API_BACKUP_CONTACT_VERSION forKey:kAPI_VERSION];
    
    [[ContactServerAdapter share] requestService:parameters tenantServer:YES callback:^(BOOL success, NSString *message, NSDictionary *response, NSError *error) {
        if (success) {
            DDLogInfo(@"%s: Successfully.", __PRETTY_FUNCTION__);
            backupContactCallBack(YES, @"Backup contact successfully.", response, nil);
        }else{
            DDLogError(@"%s: Failed.", __PRETTY_FUNCTION__);
            backupContactCallBack(NO, @"Backup contact failed.", response, error);
        }
    }];
}

-(void)restoreContact:(NSDictionary*)parametersDic callback:(requestCompleteBlock)callback{
    if (!parametersDic) {
        DDLogError(@"%s: parametersDic NULL.", __PRETTY_FUNCTION__);
        return;
    }
    
    void (^restoreContactCallBack)(BOOL success, NSString *message ,NSDictionary *response, NSError *error);
    
    restoreContactCallBack =  callback;
    
    NSMutableDictionary *parameters = [parametersDic mutableCopy];
    [parameters setObject:API_RESTORE_CONTACT forKey:kAPI];
    [parameters setObject:API_RESTORE_CONTACT_VERSION forKey:kAPI_VERSION];
    
    [[ContactServerAdapter share] requestService:parameters tenantServer:YES callback:^(BOOL success, NSString *message, NSDictionary *response, NSError *error) {
        if (success) {
            DDLogInfo(@"%s: Successfully.", __PRETTY_FUNCTION__);
            restoreContactCallBack(YES, @"Restore contact successfully.", response, nil);
        }else{
            DDLogError(@"%s: Failed.", __PRETTY_FUNCTION__);
            restoreContactCallBack(NO, @"Restore contact failed.", response, error);
        }
    }];
}

#pragma mark save backup file and get backup file functions
-(BOOL) setBackupFile:(NSString*)fileName data:(NSData*) backupData{
    
    if (!fileName || [fileName isEqualToString:@""]) {
        DDLogError(@"backup file name can not be null");
        return FALSE;
    }
    if (!backupData || backupData.length == 0) {
        DDLogError(@"backup data can not be null");
        return FALSE;
    }
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* folderPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:FOLDER_BACKUP_FILE];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:folderPath])
        [[NSFileManager defaultManager] createDirectoryAtPath:folderPath
                                  withIntermediateDirectories:NO
                                                   attributes:nil
                                                        error:nil];
    
    NSString* filePath = [folderPath stringByAppendingPathComponent:fileName];
    BOOL writeSuccess = [backupData writeToFile:filePath atomically:YES];
    if(!writeSuccess)
        DDLogError(@"Cannot write backup data for backup file name %@ to BACKUP_FILE folder", fileName);
    else
        DDLogInfo(@"Successfully write backup data for backup file name %@ to BACKUP_FILE folder", fileName);
    return writeSuccess;
}


-(NSData*) getBackupData:(NSString*)fileName{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* folderPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:FOLDER_BACKUP_FILE];
    if(!folderPath || [folderPath isEqualToString:@""]){
        DDLogError(@"BACKUP FILE folder link is not set");
        return NULL;
    }
    
    NSString* filePath = [folderPath stringByAppendingPathComponent:fileName];
    NSFileManager* fileManager = [NSFileManager defaultManager];
    BOOL success = [fileManager fileExistsAtPath:filePath];
    if(!success){
        DDLogError(@"BACKUP FILE (fileName: %@) file is not existed", fileName);
        return NULL;
    }
    NSData* returnData = [NSData dataWithContentsOfFile:filePath];
    return returnData;
}




@end
