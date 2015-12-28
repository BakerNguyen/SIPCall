//
//  Profile.m
//  ChatDomain
//
//  Created by MTouche on 12/23/14.
//  Copyright (c) 2014 mTouche. All rights reserved.
//

#import "ProfileAdapter.h"
#import "ContactServerAdapter.h"
#import "AFNetworkingHelper_Contact.h"

//Logging
#import "CocoaLumberjack.h"
//CountryCode
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>

//NSDEFAULT KEY default define
#define PROFILEJID @"PROFILEJID"
#define PROFILENAME @"PROFILENAME"
#define PROFILESTATUS @"PROFILESTATUS"
#define PROFILEAVATAR @"PROFILEAVATAR"
//AVATAR default define
#define AVATAR_FOLDERNAME @"AVATAR"
#define AVATAR_FILENAME @"ProfileAvatar.jpg"

//APIs
#define kAPI @"API"
#define kAPI_VERSION @"API_VERSION"

#define API_CHECK_MSISDN @"cb0dW89TDW"
#define API_CHECK_MSISDN_VERSION @"v1"

#define API_SEND_VERIFICAION_CODE @"y3Gts"
#define API_SEND_VERIFICAION_CODE_Celcom @"edxTyCcFcF"
#define API_VERIFY_OTP @"G8ym0l4hlk"
#define API_SEND_VERIFICAION_CODE_VERSION @"v1"

#define API_UPDATE_MSISDN_TENANT @"mkuaJdGC"
#define API_UPDATE_MSISDN_TENANT_VERSION @"v1"

#define API_UPDATE_DISPLAYNAME @"ub2NMv5KMb"
#define API_UPDATE_DISPLAYNAME_VERSION @"v1"

#define API_UPLOAD_AVATAR @"MhmhUFDRWZ" // for avatar, now don't use xmpp command
#define API_UPLOAD_AVATAR_VERSION @"v1"

#define API_DOWNLOAD_AVATAR @"AfGzIm"
#define API_DOWNLOAD_AVATAR_VERSION @"v1"

#define API_SYNC_USER_SETTING @"zGLr6C2sL6"
#define API_SYNC_USER_SETTING_VERSION @"v1"

//Logging
#ifdef DEBUG
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelOff;
#endif

@interface ProfileAdapter ()
{
    NSArray *countries;
    NSDictionary *countryNameWithDialCode;
    NSDictionary *countriesWithDialCodes;
    NSMutableArray *countriesNameList;
}
@end

@implementation ProfileAdapter

+(ProfileAdapter *)share{
    static dispatch_once_t once;
    static ProfileAdapter * share;
    dispatch_once(&once, ^{
        share = [self new];
        if (share) {
            [share getCountries];
            //[share getCurrentCountryNameAndDialCode];
        }
    });
    return share;
}

-(void) setProfileName: (NSString*) strName{
    if(!strName){
        DDLogError(@"%s: strName is NULL", __PRETTY_FUNCTION__);
        return;
    }
    [[NSUserDefaults standardUserDefaults] setObject:strName forKey:PROFILENAME];
}

-(NSString*) getProfileName{
    NSString* profileName = [[NSUserDefaults standardUserDefaults] valueForKey:PROFILENAME];
    if(!profileName){
        DDLogWarn(@"%s: profileName is NULL", __PRETTY_FUNCTION__);
        return NULL;
    }
    else
        return profileName;
}

-(void) setProfileStatus: (NSString*) strStatus{
    if(!strStatus){
        DDLogError(@"%s: strStatus is NULL", __PRETTY_FUNCTION__);
        return;
    }
    [[NSUserDefaults standardUserDefaults] setObject:strStatus forKey:PROFILESTATUS];
}

-(NSString*) getProfileStatus{
    NSString* profileStatus = [[NSUserDefaults standardUserDefaults] valueForKey:PROFILESTATUS];
    if(!profileStatus){
        DDLogWarn(@"%s: profileStatus is NULL", __PRETTY_FUNCTION__);
        return @"";
    }
    else
        return profileStatus;
}

-(BOOL) setProfileAvatar:(NSData*) avatarData{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* folderPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:AVATAR_FOLDERNAME];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:folderPath])
        [[NSFileManager defaultManager] createDirectoryAtPath:folderPath
                                  withIntermediateDirectories:NO
                                                   attributes:nil
                                                        error:nil];
    
    NSString* filePath = [folderPath stringByAppendingPathComponent:AVATAR_FILENAME];
    BOOL writeSuccess = [avatarData writeToFile:filePath atomically:YES];
    if(writeSuccess)
        [[NSUserDefaults standardUserDefaults] setObject:filePath forKey:PROFILEAVATAR];
    else
        DDLogError(@"%s: Cannot write Profile Avatar", __PRETTY_FUNCTION__);
    return writeSuccess;
}

-(UIImage*) getProfileAvatar{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* folderPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:AVATAR_FOLDERNAME];
    if(!folderPath || [folderPath isEqualToString:@""]){
        DDLogError(@"%s: Avatar folder is not set", __PRETTY_FUNCTION__);
        return NULL;
    }
    
    NSString* filePath = [folderPath stringByAppendingPathComponent:AVATAR_FILENAME];
    NSFileManager* fileManager = [NSFileManager defaultManager];
    BOOL success = [fileManager fileExistsAtPath:filePath];
    if(!success){
        DDLogError(@"%s: Avatar file is not set", __PRETTY_FUNCTION__);
        return NULL;
    }
    NSData* imageData = [[NSData alloc] initWithContentsOfFile:filePath];
    if(imageData.length <= 0){
        DDLogError(@"%s: Avatar data is empty", __PRETTY_FUNCTION__);
        return NULL;
    }
    UIImage* image = [UIImage imageWithData:imageData];
    if(!(image.size.width > 0)){
        DDLogError(@"%s: Avatar is not an image", __PRETTY_FUNCTION__);
        return NULL;
    }
    
    return image;
}

-(NSData*) getProfileAvatarData{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* folderPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:AVATAR_FOLDERNAME];
    if(!folderPath || [folderPath isEqualToString:@""]){
        DDLogError(@"%s: Avatar folder is not set", __PRETTY_FUNCTION__);
        return NULL;
    }
    
    NSString* filePath = [folderPath stringByAppendingPathComponent:AVATAR_FILENAME];
    NSFileManager* fileManager = [NSFileManager defaultManager];
    BOOL success = [fileManager fileExistsAtPath:filePath];
    if(!success){
        DDLogError(@"%s: Avatar file is not set", __PRETTY_FUNCTION__);
        return NULL;
    }
    NSData* imageData = [[NSData alloc] initWithContentsOfFile:filePath];
    if(imageData.length <= 0){
        DDLogError(@"%s: Avatar data is empty", __PRETTY_FUNCTION__);
        return NULL;
    }
    return imageData;
}

-(void)getCurrentCountryNameAndDialCode{
    NSString *(^ISOCountryCodeByCarrier)() = ^() {
        CTTelephonyNetworkInfo *networkInfo = [CTTelephonyNetworkInfo new];
        CTCarrier *carrier = [networkInfo subscriberCellularProvider];
        return [carrier isoCountryCode];
    };
    
    /*
    NSString *(^CountryNameByISO)(NSString *) = ^(NSString *iso) {
        NSLocale *locale = [[NSLocale currentLocale] initWithLocaleIdentifier:@"en_US"];
        return [locale displayNameForKey:NSLocaleCountryCode value:iso];
    };
     */
    
    NSString *ISOCountryCode = ISOCountryCodeByCarrier();
    
    NSString *countryDialCode = @"";
    NSString *countryCode = @"";
    NSString *countryName = @"";
    
    countryCode = [ISOCountryCode uppercaseString];
    DDLogWarn(@"%s: Your ISOCountryCode: %@",__PRETTY_FUNCTION__, countryCode);
    
    [self getCountriesListWithDialCodes];
    
    if(!countryCode || [countryCode isEqualToString:@""]){
        DDLogError(@"%s: Failed get Country Code. Use UNKNOWN as default", __PRETTY_FUNCTION__);
        countryCode = kUNKNOWN;
        countryDialCode = kUNKNOWN;
        countryName = kUNKNOWN;
    }
    else{
        for (NSDictionary *country in countries) {
            if ([[country objectForKey:kCOUNTRY_CODE] isEqualToString:countryCode]) {
                countryDialCode = [country objectForKey:kDIAL_CODE];
                countryName = [country objectForKey:kCOUNTRY_NAME];
                break;
            }
        }
    }
    
    if (!countryDialCode || !countryName) {
        DDLogError(@"%s: Parse country code from dictionary failed. Use UNKNOWN as default", __PRETTY_FUNCTION__);
        countryCode = kUNKNOWN;
        countryDialCode = kUNKNOWN;
        countryName = kUNKNOWN;
    }
    
    countryNameWithDialCode = [NSDictionary dictionaryWithObjectsAndKeys:countryName, kCOUNTRY_NAME, countryDialCode, kDIAL_CODE, countryCode, kCOUNTRY_CODE, nil];
    //DDLogInfo(@"%s: countryNameWithDialCode: %@",__PRETTY_FUNCTION__, countryNameWithDialCode);
}

-(NSDictionary *)getCurrentCountryNameWithDialCode{
    [self getCurrentCountryNameAndDialCode];
    return countryNameWithDialCode;
}

- (void)getCountries{
    NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"countries" ofType:@"json"]];
    NSError *localError = nil;
    NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
    
    if (localError){
        DDLogError(@"%s, %@",__PRETTY_FUNCTION__, [localError userInfo]);
        countries = [NSArray new];
    }
    else
        countries = (NSArray *)parsedObject;
}


- (NSDictionary*)getCountriesListWithDialCodes {
    
    NSMutableArray *countriesName = [[NSMutableArray alloc] init];
    NSMutableArray *countriesDial = [[NSMutableArray alloc] init];
    
    for (NSDictionary *country in countries) {
        NSString *countryName = [country objectForKey:kCOUNTRY_NAME];
        NSString *dialCode = [country objectForKey:kDIAL_CODE];
        [countriesName addObject:countryName];
        [countriesDial addObject:dialCode];
    }
    
    NSDictionary *countriesWithDialCode = [NSDictionary dictionaryWithObjects:countriesDial forKeys:countriesName];
    
    // Sort dictionary
    NSArray *sortedKeys = nil;
    NSArray *myKeys = [countriesWithDialCode allKeys];
    if (myKeys) {
        sortedKeys = [[myKeys sortedArrayUsingComparator: ^(id obj1, id obj2) {
            return [obj1 caseInsensitiveCompare:obj2];
        }] mutableCopy];
    }
    
    NSMutableArray *sortedValues = [[NSMutableArray alloc] init];
    for(id key in sortedKeys) {
        id object = [countriesWithDialCode objectForKey:key];
        [sortedValues addObject:object];
    }
    if (sortedKeys) {
        countriesWithDialCodes = [NSDictionary dictionaryWithObjects:sortedValues forKeys:sortedKeys];
    }
    
    countriesNameList = [[NSMutableArray alloc] init];
    for (NSDictionary *country in countries) {
        [countriesNameList  addObject:[country objectForKey:kCOUNTRY_NAME]];
    }
    
    return countriesWithDialCodes;
    
}

- (NSDictionary*)getAllCountriesWithDialCodes{
    return countriesWithDialCodes;
}

- (NSArray*)getAllCountriesWithCountryCodesAndDialCodes{
    return countries;
}

- (NSArray*)getAllCountriesList{
    return countriesNameList;
}

-(NSString*)getDeviceName{
    NSString *deviceName = [[UIDevice currentDevice] name];
    if (!deviceName) {
        DDLogError(@"%s: Failed", __PRETTY_FUNCTION__);
        deviceName = @"iOS Simulator";//this for simulator
    }
    return deviceName;
}

-(NSString*)getDeviceVersion{
    NSString *deviceVersion = [[UIDevice currentDevice] systemVersion];
    if (!deviceVersion) {
        DDLogError(@"%s: Failed", __PRETTY_FUNCTION__);
        deviceVersion = @"iOS Simulator Version";//this for simulator
    }
    return deviceVersion;
}

-(NSString*)getDeviceModel{
    NSString *deviceModel = [[UIDevice currentDevice] model];
    if (!deviceModel) {
        DDLogError(@"%s: Failed", __PRETTY_FUNCTION__);
        deviceModel = @"iOS Simulator Model";//this for simulator
    }
    return deviceModel;
}

-(NSString*)getIMEIOfDevice{
    NSString *UDID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    if (!UDID)
        UDID = [self generateUDID];
    
    if (!UDID) {
        DDLogError(@"%s: Failed", __PRETTY_FUNCTION__);
    }
    return UDID;
}

-(NSString*)generateUDID{
    NSString *result = nil;
    
    CFUUIDRef uuid = CFUUIDCreate(NULL);
    if (uuid){
        result = (__bridge_transfer NSString *)CFUUIDCreateString(NULL, uuid);
        CFRelease(uuid);
    }
    
    if (!result) {
        DDLogError(@"%s: Failed", __PRETTY_FUNCTION__);
    }
    
    return result;
}

-(NSString*) getTimeZone
{
    float timezoneoffset = ([[NSTimeZone systemTimeZone] secondsFromGMT] / 3600.0);
    NSString* timeZone = [NSString stringWithFormat:@"%d", (int)timezoneoffset];
    return timeZone;
}

#pragma mark API functions

-(void)updateDisplayName:(NSDictionary*)parametersDic callback:(requestCompleteBlock)callback{
    void (^updateDisplayNameCallBack)(BOOL success, NSString *message ,NSDictionary *response, NSError *error);
    
    if (!parametersDic) {
        DDLogError(@"%s: parametersDic NULL.", __PRETTY_FUNCTION__);
        return;
    }
    
    updateDisplayNameCallBack =  callback;
    NSMutableDictionary *parameters = [parametersDic mutableCopy];
    [parameters setObject:API_UPDATE_DISPLAYNAME forKey:kAPI];
    [parameters setObject:API_UPDATE_DISPLAYNAME_VERSION forKey:kAPI_VERSION];
    
    [[ContactServerAdapter share] requestService:parameters tenantServer:YES callback:^(BOOL success, NSString *message, NSDictionary *response, NSError *error) {
        if (success) {
            DDLogInfo(@"%s: Success", __PRETTY_FUNCTION__);
            updateDisplayNameCallBack(YES, @"Update name successfully.", response, nil);
        }else{
            DDLogError(@"%s: Failed", __PRETTY_FUNCTION__);
            updateDisplayNameCallBack(NO, @"Update name failed.", response, error);
        }
    }];

}

-(void)checkMSISDNToServer:(NSDictionary*)parametersDic callback:(requestCompleteBlock)callback{
    void (^checkMSISDNToServerCallBack)(BOOL success, NSString *message ,NSDictionary *response, NSError *error);
    
    if (!parametersDic) {
        DDLogError(@"%s: parametersDic NULL.", __PRETTY_FUNCTION__);
        return;
    }
    
    checkMSISDNToServerCallBack =  callback;
    NSMutableDictionary *parameterDic = [parametersDic mutableCopy];
    [parameterDic setObject:API_CHECK_MSISDN forKey:kAPI];
    [parameterDic setObject:API_CHECK_MSISDN_VERSION forKey:kAPI_VERSION];
    
    [[ContactServerAdapter share] requestService:parameterDic tenantServer:YES callback:^(BOOL success, NSString *message, NSDictionary *response, NSError *error) {
        if (success) {
            DDLogInfo(@"%s: MSISDN is available", __PRETTY_FUNCTION__);
            checkMSISDNToServerCallBack(YES, @"MSISDN is available for sync contact.", response, nil);
        }else{
            DDLogError(@"%s: MSISDN is existed", __PRETTY_FUNCTION__);
            checkMSISDNToServerCallBack(NO, @"MSISDN is existed.", response, error);
        }
    }];
}

-(void)sendVerificationCode:(NSDictionary*)parametersDic resendCode:(BOOL)isResend callback:(requestCompleteBlock)callback{
    void (^sendVerificationCodeCallBack)(BOOL success, NSString *message ,NSDictionary *response, NSError *error);
    
    if (!parametersDic) {
        DDLogError(@"%s: parametersDic NULL.", __PRETTY_FUNCTION__);
        return;
    }
    
    sendVerificationCodeCallBack =  callback;
    NSMutableDictionary *parameterDic = [parametersDic mutableCopy];
    [parameterDic setObject:API_SEND_VERIFICAION_CODE_Celcom forKey:kAPI];
    [parameterDic setObject:API_SEND_VERIFICAION_CODE_VERSION forKey:kAPI_VERSION];
    
    [[ContactServerAdapter share] requestService:parameterDic tenantServer:YES callback:^(BOOL success, NSString *message, NSDictionary *response, NSError *error) {
        if (success) {
            DDLogInfo(@"%s: Success", __PRETTY_FUNCTION__);
            sendVerificationCodeCallBack(YES, @"Send Verification Code successfully.", response, nil);
        }else{
            DDLogError(@"%s: Failed", __PRETTY_FUNCTION__);
            sendVerificationCodeCallBack(NO, @"Send Verification Code failed.", response, error);
        }
    }];
}

-(void)verifyOTP:(NSDictionary*)parametersDic callback:(requestCompleteBlock)callback;{
    void (^verifyOTPCallBack)(BOOL success, NSString *message ,NSDictionary *response, NSError *error);
    
    if (!parametersDic) {
        DDLogError(@"%s: parametersDic NULL.", __PRETTY_FUNCTION__);
        return;
    }
    
    verifyOTPCallBack =  callback;
    NSMutableDictionary *parameterDic = [parametersDic mutableCopy];
    [parameterDic setObject:API_VERIFY_OTP forKey:kAPI];
    [parameterDic setObject:API_SEND_VERIFICAION_CODE_VERSION forKey:kAPI_VERSION];
    
    [[ContactServerAdapter share] requestService:parameterDic tenantServer:YES callback:^(BOOL success, NSString *message, NSDictionary *response, NSError *error) {
        if (success) {
            DDLogInfo(@"%s: Success", __PRETTY_FUNCTION__);
            verifyOTPCallBack(YES, @"Verify OTP successfully.", response, nil);
        }else{
            DDLogError(@"%s: Failed", __PRETTY_FUNCTION__);
            verifyOTPCallBack(NO, @"Verify OTP Code failed.", response, error);
        }
    }];
}

-(void)updateMSISDNToServer:(NSDictionary*)parametersDic callback:(requestCompleteBlock)callback{
    void (^updateMSISDNToServerCallBack)(BOOL success, NSString *message ,NSDictionary *response, NSError *error);
    
    if (!parametersDic) {
        DDLogError(@"%s: parametersDic NULL.", __PRETTY_FUNCTION__);
        return;
    }
    
    updateMSISDNToServerCallBack =  callback;
    NSMutableDictionary *parameterDic = [parametersDic mutableCopy];
    [parameterDic setObject:API_UPDATE_MSISDN_TENANT forKey:kAPI];
    [parameterDic setObject:API_UPDATE_MSISDN_TENANT_VERSION forKey:kAPI_VERSION];
    
    [[ContactServerAdapter share] requestService:parameterDic tenantServer:YES callback:^(BOOL success, NSString *message, NSDictionary *response, NSError *error) {
        if (success) {
            DDLogInfo(@"%s: Success", __PRETTY_FUNCTION__);
            updateMSISDNToServerCallBack(YES, @"MSISDN is updated to tenant server successfully.", response, nil);
        }else{
            DDLogError(@"%s: Failed", __PRETTY_FUNCTION__);
            updateMSISDNToServerCallBack(NO, @"MSISDN update to tenant server failed.", response, error);
        }
    }];
}

-(void)uploadAvatarToServer:(NSDictionary*)parametersDic callback:(requestCompleteBlock)callback{
    void (^uploadAvatarToServerCallBack)(BOOL success, NSString *message ,NSDictionary *response, NSError *error);
    
    if (!parametersDic) {
        DDLogError(@"%s: parametersDic NULL.", __PRETTY_FUNCTION__);
        return;
    }
    
    uploadAvatarToServerCallBack =  callback;
    NSMutableDictionary *parameters = [parametersDic mutableCopy];
    [parameters setObject:API_UPLOAD_AVATAR forKey:kAPI];
    [parameters setObject:API_UPLOAD_AVATAR_VERSION forKey:kAPI_VERSION];
    
    [[ContactServerAdapter share] requestService:parameters tenantServer:YES callback:^(BOOL success, NSString *message, NSDictionary *response, NSError *error) {
        if (success) {
            DDLogInfo(@"%s: Success", __PRETTY_FUNCTION__);
            uploadAvatarToServerCallBack(YES, @"Upload avatar successfully.", response, nil);
        }else{
            DDLogError(@"%s: Failed", __PRETTY_FUNCTION__);
            uploadAvatarToServerCallBack(NO, @"Upload avatar failed.", response, error);
        }
    }];
}

-(void)synUserSettingWithServer:(NSDictionary*)parametersDic callback:(requestCompleteBlock)callback{
    void (^synUserSettingWithServerCallBack)(BOOL success, NSString *message ,NSDictionary *response, NSError *error);
    
    if (!parametersDic) {
        DDLogError(@"%s: parametersDic NULL.", __PRETTY_FUNCTION__);
        return;
    }
    
    synUserSettingWithServerCallBack =  callback;
    NSMutableDictionary *parameters = [parametersDic mutableCopy];
    [parameters setObject:API_SYNC_USER_SETTING forKey:kAPI];
    [parameters setObject:API_SYNC_USER_SETTING_VERSION forKey:kAPI_VERSION];
    
    [[ContactServerAdapter share] requestService:parameters tenantServer:YES callback:^(BOOL success, NSString *message, NSDictionary *response, NSError *error) {
        if (success) {
            DDLogInfo(@"%s: Success", __PRETTY_FUNCTION__);
            synUserSettingWithServerCallBack(YES, @"Sync user setting successfully.", response, nil);
        }else{
            DDLogError(@"%s: Failed", __PRETTY_FUNCTION__);
            synUserSettingWithServerCallBack(NO, @"Sync user setting failed.", response, error);
        }
    }];

}


@end
