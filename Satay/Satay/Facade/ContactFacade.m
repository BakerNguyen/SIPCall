//
//  ContactFacade.m
//  Satay
//
//  Created by enclave on 2/4/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import "ContactFacade.h"
#import "CWindow.h"
@implementation ContactFacade

//UI Delegate
@synthesize contactSearchMIDDelegate;
@synthesize contactHeaderDelegate;
@synthesize contactListDelegate;
@synthesize contactRequestDelegate;
@synthesize contactPendingDelegate;
@synthesize myProfileDelegate;
@synthesize displaynameDelegate;
@synthesize statusProfileDelegate;
@synthesize checkMSISDNDelegate;
@synthesize updateMSISDNDelegate;
@synthesize sendVerificationCodeDelegate;
@synthesize syncContactDelegate;
@synthesize chatViewDelegate;
@synthesize contactPopupDelegate;
@synthesize contactInfoDelegate;
@synthesize getStartedDelegate;
@synthesize registerAccountDelegate;
@synthesize setPasswordDelegate;
@synthesize uploadKeysDelegate;
@synthesize contactBookDelegate;
@synthesize contactEditDelegate;
@synthesize chatComposeDelegate;
@synthesize findEmailContactDelegate;
@synthesize forwardListDelegate;
@synthesize contactNotificationDelegate;
@synthesize NewGroupViewDelegate;
@synthesize changePasswordDelegate;
@synthesize enablePasswordLockDelegate;
@synthesize notificationListDelegate;
@synthesize blockUsersDelegate;
@synthesize unblockUsersDelegate;
@synthesize signInAccountDelegate;
@synthesize verificationDelegate;
@synthesize chatListDelegate;
@synthesize webMyAccountDelegate;
@synthesize blockUsersCellDelegate;
@synthesize contactNotSyncDelegate;

+(ContactFacade *)share{
    static dispatch_once_t once;
    static ContactFacade * share;
    dispatch_once(&once, ^{
        share = [self new];
    });
    return share;
}

-(void)setAccountStatusPending{
    [KeyChainSecurity storeString:ACCOUNT_PENDING Key:kACCOUNT_STATUS];
}

- (void)updateDisplayName:(NSString *)displayNameBased64
{
    NSLog(@"%s: %@", __PRETTY_FUNCTION__, displayNameBased64);
    if(!displayNameBased64)
        return;
    
    [displaynameDelegate showLoadingView];
    NSDictionary *updateDNReqDic = @{kHOST: [self getXmppHostName],
                                  kDISPLAY_NAME: displayNameBased64,
                                     kJID: [self getJid:NO],
                                  kMASKINGID: [self getMaskingId],
                                  kIMEI: [self getIMEI],
                                  kIMSI: [self getIMSI],
                                  kAPI_REQUEST_METHOD: POST,
                                  kAPI_REQUEST_KIND: NORMAL,
                                  kTOKEN: [self getTokentTenant]
                                  };
    
    [[ProfileAdapter share] updateDisplayName:updateDNReqDic callback:^(BOOL success, NSString *message, NSDictionary *response, NSError *error) {
        [[CWindow share] hideLoading];
        if ([[AppFacade share] preProcessResponse:response])
            return;
        
        NSDictionary* logDic = @{LOG_CLASS : NSStringFromClass(self.class),
                                 LOG_CATEGORY: CATEGORY_PROFILE_CHANGE_NAME,
                                 LOG_MESSAGE: [NSString stringWithFormat:@"PROFILE CHANGE NAME %@: ParaDic: %@, Response: %@", success?@"SUCCESS":@"FAILED",updateDNReqDic,response],
                                 LOG_EXTRA1: @"",
                                 LOG_EXTRA2: @""
                                 };
        success ? [[LogFacade share] logInfoWithDic:logDic] : [[LogFacade share] logErrorWithDic:logDic];
        
        if (success) {
            NSData *data = [Base64Security decodeBase64String:displayNameBased64];
            NSString *dn = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            [[XMPPAdapter share] sendUpdatevCardNotice:kVCARD_UPDATE_DISPLAYNAME];
            [[ProfileAdapter share] setProfileName:dn];
            [displaynameDelegate cancelDisplayNameView];
        }
        else {
            [displaynameDelegate updateDisplayNameFailed];
            
            if (response){
                NSInvocationOperation* operation=  [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(updateDisplayName:) object:displayNameBased64];
                // if Token is invalid or expire
                NSDictionary* retryDictionary = @{kRETRY_OPERATION:operation,
                                                  kRETRY_TIME:kRETRY_API_COUNTER,
                                                  kSTATUS_CODE : [response objectForKey:kSTATUS_CODE]};
                [[AppFacade share] downloadTokenAgain:retryDictionary];
            }
        }
    }];
}

-(void)uploadAvatar:(UIImage *)avatarImage
{
    NSLog(@"%s: %@", __PRETTY_FUNCTION__, avatarImage.description);
    
    NSData *imageDataToPost = [ChatAdapter scaleImage:avatarImage rate:2];
    __block NSData *imageDataBlock = imageDataToPost;
    
    NSDictionary *uploadDic = @{kHOST: [self getXmppHostName],
                                kMASKINGID: [self getMaskingId],
                                kJID: [self getJid:NO],
                                kIMSI: [self getIMSI],
                                kIMEI: [self getIMEI],
                                kAPI_REQUEST_METHOD: POST,
                                kAPI_REQUEST_KIND: UPLOAD,
                                kTOKEN: [self getTokentTenant],
                                kAVATAR:@"AVATAR",
                                kAPI_UPLOAD_FILEDATA:imageDataToPost,
                                kAPI_UPLOAD_NAMEUPLOAD:@"AVATAR",
                                kAPI_UPLOAD_FILENAME:@"ProfileAvatar.jpg",
                                kAPI_UPLOAD_FILETYPE:@"image/jpeg"
                               };
    //Show loading
    [[CWindow share] showLoading:kLOADING_UPLOADING_AVATAR];
    
    [[ProfileAdapter share] uploadAvatarToServer:uploadDic callback:^(BOOL success, NSString *message, NSDictionary *response, NSError *error) {
        [[CWindow share] hideLoading];
        if ([[AppFacade share] preProcessResponse:response])
            return;
        
        NSDictionary *logDic = @{LOG_CLASS : NSStringFromClass(self.class),
                                 LOG_CATEGORY: CATEGORY_PROFILE_CHANGE_PHOTO,
                                 LOG_MESSAGE: [NSString stringWithFormat:@"PROFILE CHANGE PHOTO %@: ParaDic: %@, Response: %@",success?@"SUCCESS":@"FAILED",uploadDic,response],
                                 LOG_EXTRA1: @"",
                                 LOG_EXTRA2: @""
                                 };
        success ? [[LogFacade share] logInfoWithDic:logDic] : [[LogFacade share] logErrorWithDic:logDic];
        if (success) {
            NSData* imageDataBlockEncrypt = [[AppFacade share] encryptDataLocally:imageDataBlock];
            [[ProfileAdapter share] setProfileAvatar:imageDataBlockEncrypt];
            [myProfileDelegate updateAvatarSuccess];
            [[XMPPAdapter share] sendUpdatevCardNotice:kVCARD_UPDATE_AVATAR];
        }
        else {
            [myProfileDelegate updateAvatarFailed];
            
            if (response){
                NSInvocationOperation* operation=  [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(uploadAvatar:) object:avatarImage];
                NSDictionary* retryDictionary = @{kRETRY_OPERATION:operation,
                                                  kRETRY_TIME:kRETRY_API_COUNTER,
                                                  kSTATUS_CODE : [response objectForKey:kSTATUS_CODE]};
                [[AppFacade share] downloadTokenAgain:retryDictionary];
            }
        }
    }];
}

-(UIImage *)getProfileAvatar{
    NSData* profileAvatar = [[ProfileAdapter share] getProfileAvatarData];
    NSData* profileAvatarDecrypt =  [[AppFacade share] decryptDataLocally:profileAvatar];
    UIImage* image = [[UIImage alloc]initWithData:profileAvatarDecrypt];
    if (!image){
        image = [UIImage imageNamed:IMG_S_EMPTY];
    }
    return image;
}

//Sync Contacts
#pragma mark sync contact functions
- (NSArray*)getAllCountries{
    return [[ProfileAdapter share] getAllCountriesList];
}

- (NSDictionary*)getAllCountriesWithDialCodes{
    return [[ProfileAdapter share] getAllCountriesWithDialCodes];
}

-(NSDictionary*) getCurrentCountryNameWithDialCode{
    return [[ProfileAdapter share] getCurrentCountryNameWithDialCode];
}

- (NSArray*)getAllCountriesWithCountryCodesAndDialCodes{
    return [[ProfileAdapter share] getAllCountriesWithCountryCodesAndDialCodes];
}

-(NSString*)getMSISDN{
    return [KeyChainSecurity getStringFromKey:kMSISDN];
}

-(NSString*)getNumberPhoneFromMSISDN{
    return [KeyChainSecurity getStringFromKey:kPHONE_NUMBER];
}

-(NSString*)getDialCodeFromMSISDN{
    NSString *dialCode =  [KeyChainSecurity getStringFromKey:kDIAL_CODE];
    if (dialCode.length == 0)
        return kUNKNOWN;
    
    return dialCode;
}

-(NSString*) getVerificationCode{
    return [KeyChainSecurity getStringFromKey:kVERIFICATION_CODE];
}
-(NSString*) getOTPMessageID{
    return [KeyChainSecurity getStringFromKey:kOTP_MESSAGE_ID];
}

-(BOOL) checkMSISDNValid:(NSString *)phoneNumber
{
    NSLog(@"%s: %@", __PRETTY_FUNCTION__, phoneNumber);
    
    NSError *error = NULL;
    NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypePhoneNumber error:&error];
    
    NSRange inputRange = NSMakeRange(0, [phoneNumber length]);
    NSArray *matches = [detector matchesInString:phoneNumber options:0 range:inputRange];
    
    if ([matches count] == 0)
        return NO;
        
    // found match but we need to check if it matched the whole string
    NSTextCheckingResult *result = (NSTextCheckingResult *)[matches objectAtIndex:0];
    
    if ([result resultType] == NSTextCheckingTypePhoneNumber &&
        result.range.location == inputRange.location &&
        result.range.length == inputRange.length) {
        return YES;
    }
    
    return NO;
}

- (NSString*) getFullNumber:(NSString *)countryCode phoneNumber:(NSString*)phoneNumber{
    NSArray *countriesWithCountryCodesDialCodes = [self getAllCountriesWithCountryCodesAndDialCodes];
    NSString *dialCode = kUNKNOWN;
    for (NSDictionary *country in countriesWithCountryCodesDialCodes) {
        if ([[country objectForKey:kCOUNTRY_CODE] isEqualToString:countryCode]) {
            dialCode = [country objectForKey:kDIAL_CODE];
            break;
        }
    }
    
    if (![dialCode isEqualToString:kUNKNOWN])
        phoneNumber = [dialCode stringByAppendingString:phoneNumber];
    
    return phoneNumber;
}

-(void) validateMSISDNWithServer:(NSString *)countryCode phoneNumber:(NSString*)phoneNumber{
    NSLog(@"%s: %@ %@", __PRETTY_FUNCTION__, countryCode, phoneNumber);
    
    if (countryCode.length == 0)
        return;
    if (phoneNumber.length == 0)
        return;
    
    NSString *msisdn = kUNKNOWN;
    NSString *dialCode = kUNKNOWN;
    NSArray *countriesWithCountryCodesDialCodes = [self getAllCountriesWithCountryCodesAndDialCodes];
    
    for (NSDictionary *country in countriesWithCountryCodesDialCodes) {
        if ([[country objectForKey:kCOUNTRY_CODE] isEqualToString:countryCode]) {
            dialCode = [country objectForKey:kDIAL_CODE];
            break;
        }
    }
    if (![dialCode isEqualToString:kUNKNOWN])
        msisdn = [dialCode stringByAppendingString:phoneNumber];

    NSLog(@"%s: %@", __PRETTY_FUNCTION__, msisdn);
    
    __block NSString* phoneNumberBlock = phoneNumber;
    __block NSString* countryCodeBlock = countryCode;
    
    NSDictionary *checkMSISDNDictionary = @{
                                             kMASKINGID: [self getMaskingId],
                                             kIMSI: [self getIMSI],
                                             kIMEI: [self getIMEI],
                                             kTOKEN: [self getTokentTenant],
                                             kMSISDN: msisdn,
                                             kAPI_REQUEST_METHOD: POST,
                                             kAPI_REQUEST_KIND: NORMAL};
    
    [[CWindow share] showLoading:kLOADING_LOADING];
    [[ProfileAdapter share] checkMSISDNToServer:checkMSISDNDictionary callback:^(BOOL success, NSString *message, NSDictionary *response, NSError *error) {
        [[CWindow share] hideLoading];
        
        if ([[AppFacade share] preProcessResponse:response])
            return ;
        
        if (success) {
            [KeyChainSecurity storeString:countryCodeBlock Key:kCOUNTRY_CODE];
            [KeyChainSecurity storeString:phoneNumberBlock Key:kPHONE_NUMBER];
            
            if (![self getReloginFlag] && [[response objectForKey:kEXIST] isEqualToNumber:[NSNumber numberWithInt:1]])
                [checkMSISDNDelegate msisdnExisted:countryCode phoneNumber:phoneNumber];
            else
                [checkMSISDNDelegate checkMSISDNSuccess:countryCode phoneNumber:phoneNumber];
        }
        else{
            [checkMSISDNDelegate checkMSISDNFailed];
            
            if (response){
                SEL  currentSelector = @selector(validateMSISDNWithServer:phoneNumber:);
                NSMethodSignature * methSig          = [self methodSignatureForSelector: currentSelector];
                NSInvocation      * invocation       = [NSInvocation invocationWithMethodSignature: methSig];
                [invocation setSelector: currentSelector];
                [invocation setTarget: self];
                [invocation setArgument: &phoneNumberBlock atIndex: 2];
                [invocation setArgument: &countryCodeBlock atIndex: 3];
                NSInvocationOperation* operation=  [[NSInvocationOperation alloc] initWithInvocation:invocation];
                
                // if Token is invalid or expire
                NSDictionary* retryDictionary = @{kRETRY_OPERATION:operation,
                                                  kRETRY_TIME:kRETRY_API_COUNTER,
                                                  kSTATUS_CODE : [response objectForKey:kSTATUS_CODE]};
                [[AppFacade share] downloadTokenAgain:retryDictionary];
             }
        }
    }];
    
}


-(void) updateMSISDNToServer:(NSString *)countryCode phoneNumber:(NSString*)phoneNumber{
    NSLog(@"%s: %@ %@", __PRETTY_FUNCTION__, countryCode, phoneNumber);
    
    if (countryCode.length == 0)
        return;
    if (phoneNumber.length == 0)
        return;
    
    NSString *msisdn = kUNKNOWN;
    NSString *dialCode = kUNKNOWN;
    NSArray *countriesWithCountryCodesDialCodes = [self getAllCountriesWithCountryCodesAndDialCodes];
    
    for (NSDictionary *country in countriesWithCountryCodesDialCodes) {
        if ([[country objectForKey:kCOUNTRY_CODE] isEqualToString:countryCode]) {
            dialCode = [country objectForKey:kDIAL_CODE];
            break;
        }
    }
    if (![dialCode isEqualToString:kUNKNOWN])
        msisdn = [dialCode stringByAppendingString:phoneNumber];
    
    NSLog(@"%s: %@", __PRETTY_FUNCTION__, msisdn);
    
    __block NSString* msisdnBlock = msisdn;
    __block NSString* phoneNumberBlock = phoneNumber;
    __block NSString* countryCodeBlock = countryCode;
    __block NSString* dialCodeBlock = dialCode;
    
    NSDictionary *updateMSISDNDictionary = @{
                               kMASKINGID: [self getMaskingId],
                               kIMSI: [self getIMSI],
                               kIMEI: [self getIMEI],
                               kTOKEN: [self getTokentTenant],
                               kMSISDN: msisdn,
                               kAPI_REQUEST_METHOD: POST,
                               kAPI_REQUEST_KIND: NORMAL
                               };
    
    [[CWindow share] showLoading:kLOADING_LOADING];
    [[ProfileAdapter share] updateMSISDNToServer:updateMSISDNDictionary callback:^(BOOL success, NSString *message, NSDictionary *response, NSError *error) {
        [[CWindow share] hideLoading];
        
        if ([[AppFacade share] preProcessResponse:response])
            return ;
        
        if (success) {
            [KeyChainSecurity storeString:countryCodeBlock Key:kCOUNTRY_CODE];
            [KeyChainSecurity storeString:phoneNumberBlock Key:kPHONE_NUMBER];
            [KeyChainSecurity storeString:msisdnBlock Key:kMSISDN];
            [KeyChainSecurity storeString:dialCodeBlock Key:kDIAL_CODE];
            
            if ([msisdn hasPrefix:@"+"])
                 msisdnBlock = [msisdn substringFromIndex:1];
            
            [updateMSISDNDelegate updateMSISDNSuccess:countryCode phoneNumber:msisdnBlock];
        }
        else{
            [updateMSISDNDelegate updateMSISDNFailed];
            
             if (response){
                // create invocation for current function, it will be recall when retry finish
                SEL  currentSelector = @selector(updateMSISDNToServer:phoneNumber:);
                NSMethodSignature * methSig          = [self methodSignatureForSelector: currentSelector];
                NSInvocation      * invocation       = [NSInvocation invocationWithMethodSignature: methSig];
                [invocation setSelector: currentSelector];
                [invocation setTarget: self];
                [invocation setArgument: &phoneNumberBlock atIndex: 2];
                [invocation setArgument: &countryCodeBlock atIndex: 3];
                NSInvocationOperation* operation=  [[NSInvocationOperation alloc] initWithInvocation:invocation];
                // if Token is invalid or expire
                NSDictionary* retryDictionary = @{kRETRY_OPERATION:operation,
                                                  kRETRY_TIME:kRETRY_API_COUNTER,
                                                  kSTATUS_CODE : [response objectForKey:kSTATUS_CODE]};
                [[AppFacade share] downloadTokenAgain:retryDictionary];
             }
        }
    }];

}

-(void) sendVerfificationCode:(NSString *)countryCode phoneNumber:(NSString*)phoneNumber resendCode:(BOOL)resendCode{
    NSLog(@"%s: %@ %@ %d", __PRETTY_FUNCTION__, countryCode, phoneNumber, resendCode);
    if (countryCode.length == 0)
        return;
    if (phoneNumber.length == 0)
        return;
    
    NSString* isLogin = ([self getReloginFlag] ? @"1":@"0");
    NSDictionary *sendVerificationDic = @{kMSISDN: phoneNumber,
                                        kCOUNTRY_CODE: countryCode,
                                        kMASKINGID:[[ContactFacade share] getMaskingId],
                                        kAPI_REQUEST_METHOD: PUT,
                                        kAPI_REQUEST_KIND: NORMAL,
                                        kIS_RE_LOGIN_ACCOUNT:isLogin};
    
    //Show loading
    [[CWindow share] showLoading:kLOADING_LOADING];
    
    [[ProfileAdapter share] sendVerificationCode:sendVerificationDic resendCode:resendCode callback:^(BOOL success, NSString *message, NSDictionary *response, NSError *error) {
         [[CWindow share] hideLoading];
        
        if ([[AppFacade share] preProcessResponse:response])
            return ;
        
        if (success) {
            NSLog(@"%s: %@", __PRETTY_FUNCTION__, response);
            
            [KeyChainSecurity storeString:response[kOTP_MESSAGE_ID] Key:kOTP_MESSAGE_ID];
            if (resendCode == NO) {
                [[CAlertView new] showInfo:INFO_OTP];
                [sendVerificationCodeDelegate sendVerfificationCodeSuccess];
            }
        }
        else{
            NSInteger statusCode = 0;
            if ([response objectForKey:kSTATUS_CODE] && ![[response objectForKey:kSTATUS_CODE] isEqual:[NSNull null]]) {
                statusCode = [[response objectForKey:kSTATUS_CODE] integerValue];
            }
            
            if (resendCode) {
                if (statusCode == 6003) {
                    [[CAlertView new] showError:ERROR_RESENT_LIMIT];
                }
                [[CAlertView new] showError:ERROR_RESEND_CODE_TRY_AGAIN];
                return;
            }
            
            switch (statusCode) {
                case 2009:
                    [[CAlertView new] showError:mERROR_INVALID_PHONENUMBER];
                    break;
                case 6003:
                    [[CAlertView new] showError:ERROR_RESENT_LIMIT];
                    break;
                case 6005:
                    [[CAlertView new] showError:ERROR_PHONE_NUMBER_NOT_MATCH];
                    break;
                default:
                    [sendVerificationCodeDelegate sendVerfificationCodeSuccessFailed];
                    break;
            }
        }
    }];

}

- (void) verifyOTP:(NSString*)phoneNumber otpCode:(NSString*)verificationCode resendCode:(BOOL)resendCode{
    NSLog(@"%s: %@ %@ %d", __PRETTY_FUNCTION__, phoneNumber, verificationCode, resendCode);
    
    if (phoneNumber.length == 0)
        return;
    if (verificationCode.length == 0)
        return;
    
    if ([self getOTPMessageID].length == 0)
        return;
    
    NSDictionary *sendVerificationDic = @{kMSISDN: phoneNumber,
                                          kOTP_MESSAGE_ID: [self getOTPMessageID],
                                          kOTPCode: verificationCode,
                                          kAPI_REQUEST_METHOD: PUT,
                                          kAPI_REQUEST_KIND: NORMAL
                                          };
    [[CWindow share] showLoading:kLOADING_LOADING];
    [[ProfileAdapter share] verifyOTP:sendVerificationDic callback:^(BOOL success, NSString *message, NSDictionary *response, NSError *error) {
        [[CWindow share] hideLoading];
        if (success) {
            if ([self getReloginFlag]) {
                [KeyChainSecurity storeString:IS_YES Key:kIS_FREE_TRIAL];
                //connect xmpp
                [[XMPPFacade share] connectXMPP];
                //Add proxy config for SIP
                [[SIPFacade share] registerSIPAccount];
                [[ContactFacade share] restoreProfile];
            }
            [verificationDelegate verifyOTPSuccess];
        }
        else
        {
            if (resendCode){
                [[CAlertView new] showError:ERROR_RESEND_CODE_TRY_AGAIN];
                return;
            }
            
            NSInteger statusCode = 0;
            if ([response objectForKey:kSTATUS_CODE] && ![[response objectForKey:kSTATUS_CODE] isEqual:[NSNull null]]) {
                statusCode = [[response objectForKey:kSTATUS_CODE] integerValue];
            }
            
            switch (statusCode) {
                case 2009:
                    [[CAlertView new] showError:mERROR_INVALID_PHONENUMBER];
                    break;
                case 6002:
                    [[CAlertView new] showError:mERROR_OTP_FAIL];
                    break;
                case 6004:
                    [[CAlertView new] showError:mERROR_OTP_EXPIRE];
                    break;
                case 6003:
                    [[CAlertView new] showError:ERROR_RESENT_LIMIT];
                    break;
                case 0:
                    [[CAlertView new] showError:ERROR_SERVER_GOT_PROBLEM];
                    break;
                    
                default:
                    [[CAlertView new] showError:CANNOT_SEND_VERIFY_CODE_NOW];
                    break;
            }
        }
    }];
}

- (void)getAddressPhoneBook{
    [[ContactAdapter share] getAddressPhoneBook];
}

-(void) syncContactsWithServer{
    NSLog(@"%s",__PRETTY_FUNCTION__);
    
    [self getAddressPhoneBook];
    
    NSArray *normalContactsPhoneBook = [self getContactsAddressBook];
    NSArray *symbolicContactsPhoneBook = [self getSymbolicContactsAddressBook];
    NSArray *allContactsPhoneBook = [normalContactsPhoneBook arrayByAddingObjectsFromArray:symbolicContactsPhoneBook];
    
    NSString *msisdnList = @"";
    NSString *sourceCode = kUNKNOWN;
    
    if ([self getMSISDN].length == 0)
        return;
    
    if (![[self getDialCodeFromMSISDN] isEqualToString:kUNKNOWN])
        sourceCode = [[self getDialCodeFromMSISDN] substringFromIndex:1];
    
    NSArray *phoneNumberList = [[ContactAdapter share] getPhoneNumberListInContactAddressBook];
    
    if (phoneNumberList.count > 0){
        for (NSString* contactNumber in phoneNumberList) {
            
            if ([contactNumber isEqualToString:[self getMSISDN]])
                continue;
            
            NSString* queryCondition = [NSString stringWithFormat:@"serverMSISDN = '%@'", contactNumber];
            Contact* contact = (Contact*)[[DAOAdapter share] getObject:[Contact class] condition:queryCondition];
            if (!contact){
                if(msisdnList.length > 0)
                    msisdnList = [msisdnList stringByAppendingString:@","];
                msisdnList = [msisdnList stringByAppendingString:contactNumber];
            }
        }
    }
    
    NSDictionary *logDic = @{
               LOG_CLASS : NSStringFromClass(self.class),
               LOG_CATEGORY: CATEGORY_SYNC_LOADED_CONTACT,
               LOG_MESSAGE: [NSString stringWithFormat:@"LOAD CONTACT SUCCESS: %@",msisdnList],
               LOG_EXTRA1: @"",
               LOG_EXTRA2: @""
               };
    [[LogFacade share] logInfoWithDic:logDic];
    
    NSDictionary *sendVerificationDic = @{kMASKINGID: [self getMaskingId],
                                          kTOKEN: [self getTokentTenant],
                                          kSOURCE_COUNTRY: sourceCode,
                                          kMSISDN_LIST: msisdnList,
                                          kIMSI: [self getIMSI],
                                          kIMEI: [self getIMEI],
                                          kAPI_REQUEST_METHOD: POST,
                                          kAPI_REQUEST_KIND: NORMAL
                                          };
    
    //Show loading
    [[CWindow share] showLoading:kLOADING_LOADING];
    
    [[ContactAdapter share] searchContactsTenant:sendVerificationDic callback:^(BOOL success, NSString *message, NSDictionary *response, NSError *error) {
        [[CWindow share] hideLoading];
        if ([[AppFacade share] preProcessResponse:response])
            return ;
        NSDictionary * logDic = @{
                                  LOG_CLASS : NSStringFromClass(self.class),
                                  LOG_CATEGORY: CATEGORY_SYNC_MARKED_OK_CONTACT,
                                  LOG_MESSAGE: [NSString stringWithFormat:@"SYNC CONTACT %@: ParaDic: %@, Response: %@",success ?@"SUCCESSED":@"FAILED",sendVerificationDic,response],
                                  LOG_EXTRA1: @"",
                                  LOG_EXTRA2: @""
                                  };
        success ? [[LogFacade share] logInfoWithDic:logDic] : [[LogFacade share] logErrorWithDic:logDic];
        
        if (success) {
            NSDictionary *objContacts = [[response objectForKey:@"CONTACTS"] copy];
            
            for(NSDictionary *contactDict in objContacts)
            {
                //Contact* contact =  [self getContact:[contactDict objectForKey:kJID]];
                
                // We have 2 scenario
                // Sec 1:
                // - Account A sync with phone number xxx. After that account B sync with phone number xxx . We should remove phone number xxx from account A
                // Sec 2:
                // - Account A sync with phone number xxx. After that account A sycn with phone number xyz. Should display phone number xyz.
                [self checkContactSyncValid:contactDict];
              
                Contact* contact =  [self getContact:[contactDict objectForKey:kJID]];
                
                NSString *serverDisplayName = @"";
                if([contactDict objectForKey:kDISPLAY_NAME])
                    serverDisplayName = [[NSString alloc] initWithData:[Base64Security decodeBase64String:[contactDict objectForKey:kDISPLAY_NAME]] encoding:NSUTF8StringEncoding];
                
                if(!contact){
                    contact = [Contact new];
                    contact.jid = [contactDict objectForKey:kJID];
                    contact.maskingid = [contactDict objectForKey:kMASKINGID];
                    contact.serversideName = serverDisplayName;
                    contact.contactType = [NSNumber numberWithInt:kCONTACT_TYPE_KRYPTO_USER];
                    [[DAOAdapter share] commitObject:contact];
                    
                    [self updateContactInfo:contact.jid];
                    
                    logDic = @{LOG_CLASS : NSStringFromClass(self.class),
                               LOG_CATEGORY: CATEGORY_SYNC_SAVED_DB,
                               LOG_MESSAGE: [NSString stringWithFormat:@"SAVE CONTACT TO DB: %@",contact],
                               LOG_EXTRA1: @"",
                               LOG_EXTRA2: @""
                               };
                    [[LogFacade share] logInfoWithDic:logDic];
                }
                
                //Get Avatar of contact
                [self updateContactInfo:contact.jid];
                
                if ([contactDict objectForKey:kMSISDN]) {
                    contact.phonebookMSISDN = [contactDict objectForKey:kMSISDN];
                    contact.serverMSISDN = [contactDict objectForKey:kMSISDN];
                    for(NSDictionary *item in allContactsPhoneBook){
                        if([[item objectForKey:@"mobile"] isEqual:[contactDict objectForKey:kMSISDN]]){
                            contact.phonebookName = [item objectForKey:@"contactFirstLast"];
                            break;
                        }
                    }
                }
                [[DAOAdapter share] commitObject:contact];
            }
            
            [KeyChainSecurity storeString:IS_YES Key:kIS_SYNC_CONTACT];
            [verificationDelegate syncContactsSuccess];
            [contactBookDelegate syncContactsSuccess];
            [KeyChainSecurity storeString:IS_YES Key:kIS_FREE_TRIAL];// this flag after delegate
        }
        else{
            if([[response objectForKey:kSTATUS_CODE] isEqualToNumber:[NSNumber numberWithInt:2025]]){
                [KeyChainSecurity storeString:IS_YES Key:kIS_SYNC_CONTACT];
                [verificationDelegate syncContactsSuccess];
                [contactBookDelegate syncContactsSuccess];
                [KeyChainSecurity storeString:IS_YES Key:kIS_FREE_TRIAL];// this flag after delegate
                if ([self getReloginFlag]) {
                    //Restore profile
                    [[ContactFacade share] restoreProfile];
                }
            }
            else{
                [contactBookDelegate syncContactsFailed];
                [verificationDelegate syncContactsFailed];
                [KeyChainSecurity storeString:IS_YES Key:kIS_FREE_TRIAL];
            }
            
            if ([response objectForKey:kSTATUS_CODE]){
                NSInvocationOperation* operation = [[NSInvocationOperation alloc] initWithTarget:self
                                                                                        selector:@selector(syncContactsWithServer)
                                                                                          object:nil];
                // if Token is invalid or expire
                NSDictionary* retryDictionary = @{kRETRY_OPERATION:operation,
                                                  kRETRY_TIME:kRETRY_API_COUNTER,
                                                  kSTATUS_CODE : [response objectForKey:kSTATUS_CODE]};
                [[AppFacade share] downloadTokenAgain:retryDictionary];
            }
        }
    }];
}

-(void)checkContactSyncValid:(NSDictionary *)contactDict{
    Contact* contact = nil;
    if ([contactDict objectForKey:kMSISDN])
       contact = [self getContactByServerMSISDN:[contactDict objectForKey:kMSISDN]];
    
    if (contact) {
        // If the Jid in response and Jid in DB not match, we remove phone number of contact in database
        if (![contact.jid isEqualToString:[contactDict objectForKey:kJID]]) {
            contact.serverMSISDN = STRING_EMPTY;
            contact.phonebookMSISDN = STRING_EMPTY;
            [[DAOAdapter share] commitObject:contact];
        }
    }
}

-(void) showKeyboardSyncContactView{
    [syncContactDelegate showKeyboard];
}

- (void) resetMSISDNNumber
{
    [KeyChainSecurity removeKey:kMSISDN];
    [KeyChainSecurity removeKey:kPHONE_NUMBER];
    [KeyChainSecurity storeString:IS_NO Key:kIS_SYNC_CONTACT];
    [myProfileDelegate reloadTableData];
    [[CAlertView new] showInfo:ERROR_ACCOUNT_INVALID];
    [KeyChainSecurity storeString:IS_YES Key:kIS_ACCOUNT_REMOVED];
    [KeyChainSecurity storeString:ACCOUNT_INACTIVE Key:kACCOUNT_STATUS];
    [[XMPPFacade share] disconnectXMPP];
}

#pragma mark Login functions
-(void)loginAccount:(NSDictionary*)retryInfo
{
    NSLog(@"%s: %@",__PRETTY_FUNCTION__, retryInfo);
    NSDictionary *loginDic = @{kHOST: [self getXmppHostName],
                               kMASKINGID: [self getMaskingId],
                               kPASSWORD: [self getPasscode],
                               kIMSI: [self getIMSI],
                               kIMEI: [self getIMEI],
                               kTIMEZONE_OFFSET: [self getTimeZone],
                               kDEVICE_NAME: [self getDeviceName],
                               kXMPP_PSW_FLAG:@"0",
                               kAPP_VERSION: APP_VERSION,
                               kAPI_REQUEST_METHOD: POST,
                               kAPI_REQUEST_KIND: NORMAL
                               };
    [[AccountAdapter share] loginAccountToTenantServer:loginDic callback:^(BOOL success, NSString *message, NSDictionary *response, NSError *error) {
        if ([[AppFacade share] preProcessResponse:response])
            return;
        
        NSDictionary *logDic = @{LOG_CLASS : NSStringFromClass(self.class),
                                 LOG_CATEGORY: CATEGORY_LOGIN,
                                 LOG_MESSAGE: [NSString stringWithFormat:@"LOGIN %@: ParaDic: %@, Response: %@",success ? @"SUCCESSED": @"FAILED",loginDic,response],
                                 LOG_EXTRA1: @"",
                                 LOG_EXTRA2: @""
                                 };
        success ? [[LogFacade share] logInfoWithDic:logDic]:[[LogFacade share] logErrorWithDic:logDic];
        NSLog(@"%s: %@ %@",__PRETTY_FUNCTION__, response, error);
        if (success) {
            [KeyChainSecurity storeString:[[response objectForKey:kACCOUNT] objectForKey:kTENANTTOKEN] Key:kTENANTTOKEN];
            [KeyChainSecurity storeString:[[response objectForKey:kACCOUNT] objectForKey:kCENTRALTOKEN] Key:kCENTRALTOKEN];
            [self getFriendPendingRequests];
            [[ContactFacade share] getDetailAccount]; // need to account info because token changed
            BOOL isFunctionKeyNil = (retryInfo == nil);
            if (!isFunctionKeyNil) {
                [[AppFacade share] callRetryFunctionAfterSuccessful:retryInfo];
            }
        }
        else {
            NSInteger status_code = [[response objectForKey:kSTATUS_CODE] integerValue];
            if (!((retryInfo == nil) || status_code == 4016)) {
                // Decrease retry time and perform retry login one more time.
                NSMutableDictionary *newDict = [[NSMutableDictionary alloc] init];
                [newDict addEntriesFromDictionary:retryInfo];
                int numberOfRetry = [retryInfo[kRETRY_TIME] intValue] - 1;
                [newDict setObject:[NSString stringWithFormat:@"%d",numberOfRetry] forKey:kRETRY_TIME];
                [[AppFacade share] downloadTokenAgain:newDict];
            }
        }
    }];
}


- (void) getDetailAccount{
    NSLog(@"%s",__PRETTY_FUNCTION__);
    NSDictionary *loginDictest = @{kHOST: [[ContactFacade share] getXmppHostName],
                                   kMASKINGID: [[ContactFacade share] getMaskingId],
                                   kIMSI: [[ContactFacade share] getIMSI],
                                   kIMEI: [[ContactFacade share] getIMEI],
                                   kTIMEZONE_OFFSET: [self getTimeZone],
                                   kDEVICE_NAME: [self getDeviceName],
                                   kAPP_VERSION: APP_VERSION,
                                   kAPI_REQUEST_METHOD: POST,
                                   kAPI_REQUEST_KIND: NORMAL,
                                   kOS_VERSION:[self getDeviceVersion],
                                   kXMPP_PSW_FLAG:@"0",
                                   kTOKEN:[self getTokentTenant]
                                   };
    [[AccountAdapter share] getAccountDetails:loginDictest callback:^(BOOL success, NSString *message, NSDictionary *response, NSError *error) {
        NSLog(@"%s: %@ %@",__PRETTY_FUNCTION__, response, error);
        if ([[AppFacade share] preProcessResponse:response])
            return;

        if (response) {
            if (success) {
                [self updateLocalAccountInfo:response];
                [KeyChainSecurity storeString:response[kFORCE_VERSION_IOS] Key:kFORCE_VERSION_IOS];
                [webMyAccountDelegate getDetailAccountSuccess];
            }
            else
                [webMyAccountDelegate getDetailAccountFail];
        }
        
    }];
}

- (void) updateLocalAccountInfo:(NSDictionary *)response{
    NSLog(@"%s: %@",__PRETTY_FUNCTION__, response);
    if (!response)
        return;
    
    NSDictionary* accountInfo       = response [kACCOUNT];
    NSString* endDateServerTime     = accountInfo[kSUB_END_DATE];
    NSString* startDateServerTime   = accountInfo[kSUB_START_DATE];
    
    [[ProfileAdapter share] setProfileStatus:accountInfo[kUSER_STATUS]];

    // get time for end date
    [KeyChainSecurity storeString:endDateServerTime Key:kSUB_END_DATE];
    
    //add Time for start date
    [KeyChainSecurity storeString:startDateServerTime Key:kSUB_START_DATE];
    [KeyChainSecurity storeString:response[kACCOUNT_URL] Key:kACCOUNT_URL];
    
    if (self.isAccountExpired) {
        [KeyChainSecurity storeString:ACCOUNT_INACTIVE Key:kACCOUNT_STATUS];
        if (!self.getReloginFlag) {
            [[CWindow share] showPaymentOption];
        }
    }
}

- (BOOL) isAccountExpired{
    NSTimeInterval endTime = [[ChatAdapter convertDate:[KeyChainSecurity getStringFromKey:kSUB_END_DATE]
                                                format:FORMAT_DATE_DETAIL_ACCOUNT] doubleValue];
    NSTimeInterval currentTime = [[NSDate date] timeIntervalSince1970];
    return (currentTime > endTime);
}

-(void)signInAccount:(NSString*)maskingID password:(NSString*)password
{
    NSLog(@"%s: %@ %@",__PRETTY_FUNCTION__, maskingID,password);
    [self configureServersAndXmppHost];
    [self storeIMSIAndIMEI];
    
    NSString *passcodeEcrypted =  [AESSecurity hashSHA256:password];
    __block NSString *passcodeString = passcodeEcrypted;
    NSDictionary *loginDic = @{kHOST: [self getXmppHostName],
                               kMASKINGID: maskingID,
                               kPASSWORD: passcodeEcrypted,
                               kIMSI: [self getIMSI],
                               kIMEI: [self getIMEI],
                               kTIMEZONE_OFFSET: [self getTimeZone],
                               kDEVICE_NAME: [self getDeviceName],
                               kXMPP_PSW_FLAG:@"1",
                               kAPP_VERSION: APP_VERSION,
                               kAPI_REQUEST_METHOD: POST,
                               kAPI_REQUEST_KIND: NORMAL
                               };
    [[CWindow share] showLoading:kLOADING_LOGGING];
    [[AccountAdapter share] loginAccountToTenantServer:loginDic callback:^(BOOL success, NSString *message, NSDictionary *response, NSError *error) {
        NSLog(@"%s: %@, %@",__PRETTY_FUNCTION__, response, error);
        [[CWindow share] hideLoading];
        if ([[AppFacade share] preProcessResponse:response])
            return;
        if (success) {
            NSDictionary *account = [response objectForKey:kACCOUNT];
            [KeyChainSecurity storeString:[account objectForKey:kTENANTTOKEN] Key:kTENANTTOKEN];
            [KeyChainSecurity storeString:[account objectForKey:kCENTRALTOKEN] Key:kCENTRALTOKEN];
            [KeyChainSecurity storeString:[account objectForKey:kMASKINGID] Key:kMASKINGID];
            [KeyChainSecurity storeString:passcodeString Key:kPASSWORD];
            [KeyChainSecurity storeString:[account objectForKey:kJID] Key:kJID];
            [KeyChainSecurity storeString:[account objectForKey:kXMPP_PASSWORD] Key:kJID_PASSWORD];
            [KeyChainSecurity storeString:[account objectForKey:kXMPP_HOST] Key:kJID_HOST];
            
            //set flags
            [KeyChainSecurity storeString:IS_YES Key:kIS_RE_LOGIN_ACCOUNT];
            [KeyChainSecurity storeString:IS_YES Key:kIS_REGISTER];
            [KeyChainSecurity storeString:ACCOUNT_ACTIVE Key:kACCOUNT_STATUS];
            
            [KeyChainSecurity storeString:IS_YES Key:kIS_BACKUP_ACCOUNT];//Re-login then no call backup. Just call when needed.

            //Displayname
            NSData *dataDisplayName = [Base64Security decodeBase64String:[account objectForKey:kDISPLAY_NAME]];
            NSString *displayName = [[NSString alloc] initWithData:dataDisplayName encoding:NSUTF8StringEncoding];
            [[ProfileAdapter share] setProfileName:displayName];

            [signInAccountDelegate signInAccountSuccess];
            [[ContactFacade share] getDetailAccount];
        }
        else {
            NSInteger status_code = 0;
            if ([response objectForKey:kSTATUS_CODE])
                status_code = [[response objectForKey:kSTATUS_CODE] integerValue];
            switch (status_code) {
                case 2010:
                   [signInAccountDelegate signInAccountMaskingIDInvalid];
                    break;
                case 4001:
                    [signInAccountDelegate signInAccountNotFound];
                    break;
                case 4017:
                    [signInAccountDelegate signInAccountWrongPassword];
                    break;
                case 4016:
                    [signInAccountDelegate signInAccountBlocked];
                    break;
                default:
                    [signInAccountDelegate signInAccountFailed];
                    break;
            }
        }
    }];
}


-(void)checkAccountStatus{
    NSLog(@"%s %@", __PRETTY_FUNCTION__, [self getAccountStatus]);
    if ([[self getAccountStatus] isEqualToString:ACCOUNT_ACTIVE]) {
        if (![self getSyncContactFlag])//If not sync yet
            [[CWindow share] showSyncContacts];
        else
            [[CWindow share] showApplication];
        
        if([[[AppFacade share] getPasswordLockFlag] boolValue]){
            [[CWindow share] showPasswordView:LockAccess];
        }else{
            [[XMPPFacade share] connectXMPP];
            [[ContactFacade share] loginAccount:nil];
        }
    }
    else if ([[self getAccountStatus] isEqualToString:ACCOUNT_INACTIVE]){//inactive
        if ([[ContactFacade share] isAccountRemoved]) {
            [[CWindow share] showApplication];
            [[XMPPFacade share] disconnectXMPP];
        }
        else{
            CAlertView* alertView = [CAlertView new];
            [alertView showInfo:_ALERT_ACCOUNT_EXPIRED];
            [alertView setOnButtonTouchUpInside:^(CAlertView *alertView, int indexButton){
                [[CWindow share] showPaymentOption];
            }];
            
        }
    }
    else{
        if ([self getRegisterFlag])
            if(![self getSyncContactFlag])
                [[CWindow share] showSyncContacts];
            else
                [[CWindow share] showSignUp];
        else
            [[CWindow share] showLoginFirstScreen];
    }
}

-(void)resetSignUpAndSignInAccount{
    NSLog(@"%s",__PRETTY_FUNCTION__);
    [KeyChainSecurity storeString:IS_NO Key:kIS_RE_LOGIN_ACCOUNT];
    [KeyChainSecurity storeString:IS_NO Key:kIS_REGISTER];
    [KeyChainSecurity storeString:ACCOUNT_PENDING Key:kACCOUNT_STATUS];
}

- (void)configureServersAndXmppHost{
    NSDictionary *xmppConfigure = [[XMPPAdapter share] getCurrentConfig];
    //Store xmpp host to kHOST
    [KeyChainSecurity storeString:[xmppConfigure objectForKey:kXMPP_HOST_NAME] Key:kHOST];
    [KeyChainSecurity storeString:[xmppConfigure objectForKey:kXMPP_MUC_HOST_NAME] Key:kHOSTMUC];
    //Config servers
    /*
     > conference.ssim.mtouche-mobile.com
     > vjud.ssim.mtouche-mobile.com
     > proxy.ssim.mtouche-mobile.com
     > ssapi.mtouche-mobile.com
     > ssiapi.mtouche-mobile.com
     > sscapi.mtouche-mobile.com
     > ssm.mtouche-mobile.com
     > ssim.mtouche-mobile.com
     > sssip.mtouche-mobile.com
     > ssstun.mtouche-mobile.com
     > sssiremis.mtouche-mobile.com
     */
    [[ContactServerAdapter share] configServerCentral];
    [[ContactServerAdapter share] configServerTenant:@{kAPI_ENCRYPTION_TENANT :@"1", kAPI_PROTOCOL_TENANT : @"sataydevapi.mtouche-mobile.com", kAPI_PORT_TENANT: @"443"}];
}

-(void)getStartedAccount{
    NSLog(@"%s",__PRETTY_FUNCTION__);
    [self configureServersAndXmppHost];
    [self storeIMSIAndIMEI];
    
    //Call get Started
    NSDictionary *getStartedDic = @{kAPI_REQUEST_METHOD: POST,
                                    kAPI_REQUEST_KIND: NORMAL,
                                    kHOST: [self getXmppHostName]
                                    };
    
    [[CWindow share] showLoading:kLOADING_LOADING];
    [[AccountAdapter share] getStartedAccount:getStartedDic callback:^(BOOL success, NSString *message, NSDictionary *response, NSError *error) {
        [[CWindow share] hideLoading];
        
        if ([[AppFacade share] preProcessResponse:response])
            return ;
        
        if (success) {
            NSLog(@"%s: Masking Id:%@",__PRETTY_FUNCTION__, [KeyChainSecurity getStringFromKey:kMASKINGID]);
            [KeyChainSecurity storeString:[response objectForKey:kMASKINGID] Key:kMASKINGID];
            [getStartedDelegate getStartedSuccess];
        }
        else{
            NSLog(@"%s: FAILED",__PRETTY_FUNCTION__);
            [getStartedDelegate getStartedFailed];
        }
    }];
}

-(void)registerAccount:(int)serviceId{
    NSLog(@"%s: %d",__PRETTY_FUNCTION__, serviceId);
    if ([self getMaskingId].length > 0) {
        //Generate keys
        NSDictionary *keysPair1 =  [RSASecurity generateRSAKeyPair];
        NSDictionary *keysPair2 =  [RSASecurity generateRSAKeyPair];
        NSDictionary *keysPair3 =  [RSASecurity generateRSAKeyPair];
        //Store keys pair
        [KeyChainSecurity storeString:[keysPair1 objectForKey:kRSA_PUBLIC_EXPONENT] Key:kMOD1_EXPONENT];
        [KeyChainSecurity storeString:[keysPair1 objectForKey:kRSA_MODULUS] Key:kMOD1_MODULUS];
        [KeyChainSecurity storeString:[keysPair1 objectForKey:kRSA_PRIVATE_EXPONENT] Key:kMOD1_PRIVATE];
        [KeyChainSecurity storeString:[keysPair2 objectForKey:kRSA_PUBLIC_EXPONENT] Key:kMOD2_EXPONENT];
        [KeyChainSecurity storeString:[keysPair2 objectForKey:kRSA_MODULUS] Key:kMOD2_MODULUS];
        [KeyChainSecurity storeString:[keysPair2 objectForKey:kRSA_PRIVATE_EXPONENT] Key:kMOD2_PRIVATE];
        [KeyChainSecurity storeString:[keysPair3 objectForKey:kRSA_PUBLIC_EXPONENT] Key:kMOD3_EXPONENT];
        [KeyChainSecurity storeString:[keysPair3 objectForKey:kRSA_MODULUS] Key:kMOD3_MODULUS];
        [KeyChainSecurity storeString:[keysPair3 objectForKey:kRSA_PRIVATE_EXPONENT] Key:kMOD3_PRIVATE];
        
        //Show loading view
        [[CWindow share] showLoading:kLOADING_REGISTER_ACCOUNT];
        
        //Get country code
        NSDictionary *country = [[ProfileAdapter share] getCurrentCountryNameWithDialCode];
        
        NSDictionary *registerDic = @{kAPI_REQUEST_METHOD: POST,
                                      kAPI_REQUEST_KIND: NORMAL,
                                      kHOST: [self getXmppHostName],
                                      kPLATFORM: IOS_PLATFORM, //1 for iOS
                                      kIMSI: [self getIMSI],
                                      kIMEI: [self getIMEI],
                                      kDEVICE_NAME: [self getDeviceName],
                                      kOS_VERSION: [self getDeviceVersion],
                                      kAPP_VERSION: APP_VERSION,
                                      kDEVICE_ID: [[NSUUID UUID] UUIDString],
                                      kTIMEZONE_OFFSET: [self getTimeZone],
                                      kCOUNTRY_CODE: [country objectForKey:kCOUNTRY_CODE],
                                      kMASKINGID: [self getMaskingId],
                                      kSERVICE_ID: [NSString stringWithFormat:@"%d",serviceId],};
        
        [[AccountAdapter share] registerAccount:registerDic callback:^(BOOL success, NSString *message, NSDictionary *response, NSError *error) {
            NSLog(@"%s: %@ %@",__PRETTY_FUNCTION__, response, error);
            [[CWindow share] hideLoading];
            if ([[AppFacade share] preProcessResponse:response])
                return;
            NSDictionary *logDic = @{LOG_CLASS : NSStringFromClass(self.class),
                                     LOG_CATEGORY: @"CATEGORY_REGISTER",
                                     LOG_MESSAGE: success ? @"Success":@"Failed",
                                     LOG_EXTRA1: @"",
                                     LOG_EXTRA2: @""};
            success ? [[LogFacade share] logInfoWithDic:logDic] : [[LogFacade share] logErrorWithDic:logDic];
            if (success) {
                //Store values into keychain
                [KeyChainSecurity storeString:[response objectForKey:kJID] Key:kJID];
                [KeyChainSecurity storeString:[response objectForKey:kJID_PASSWORD] Key:kJID_PASSWORD];
                [KeyChainSecurity storeString:[response objectForKey:kJID_HOST] Key:kJID_HOST];
                [KeyChainSecurity storeString:[response objectForKey:kTOKEN] Key:kTENANTTOKEN];
                //set register flag
                [KeyChainSecurity storeString:IS_YES Key:kIS_REGISTER];
                
                [registerAccountDelegate registerAccountSuccess];
                
                if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
                    //Add proxy config for SIP
                    [[SIPFacade share] registerSIPAccount];
                }
            }
            else{
                [registerAccountDelegate registerAccountFailed];
            }
        }];
    }
}


-(void)updatePasscodeToServerwithType:(NSInteger)updateType retryUploadTime:(NSInteger)retryTime{
    NSLog(@"%s %d %d", __PRETTY_FUNCTION__, updateType, retryTime);
    
    __block NSInteger type = updateType;
    __block NSInteger numberOfRetry = retryTime;
    
    if ([self getTokentTenant].length == 0)
        return;
    if ([self getMaskingId].length == 0)
        return;
    if ([self getJid:NO].length == 0)
        return;
    
    //Show loading view when register acc
    if(type == UploadPasswordForRegister)
        [[CWindow share] showLoading:kLOADING_REGISTER_ACCOUNT];
    else if(type == UploadPasswordForChangePsw)
        [[CWindow share] showLoading:kLOADING_LOADING];

    NSDictionary *setPasswordDic = @{kAPI_REQUEST_METHOD: POST,
                                     kAPI_REQUEST_KIND: NORMAL,
                                     kTOKEN: [self getTokentTenant],
                                     kIMSI: [self getIMSI],
                                     kIMEI: [self getIMEI],
                                     kMASKINGID: [self getMaskingId],
                                     kPASSWORD: [KeyChainSecurity getStringFromKey:kPASSWORD],
                                     kJID: [self getJid:NO]
                                     };
    
    [[AccountAdapter share] setPasswordToServer:setPasswordDic callback:^(BOOL success, NSString *message, NSDictionary *response, NSError *error) {
        //Disable loading view
        [[CWindow share] hideLoading];
        
        if ([[AppFacade share] preProcessResponse:response])
            return ;
        
        if (success) {
            switch (type) {
                case UploadPasswordForRegister:{
                    [setPasswordDelegate setPasswordToServerSuccess];
                    }break;
                case UploadPasswordForChangePsw:{
                    [changePasswordDelegate changePasswordToServerSuccess];
                    //Backup profile
                    [[ContactFacade share] backupProfile];
                    //update masterkey for backup file
                    [self uploadMasterKey];
                }
                    break;
                case UploadPasswordForEnablePswLock:
                    [enablePasswordLockDelegate enablePasswordLockSuccess];
                    break;
                    
                default:
                    break;
            }
            
        }
        else{
            switch (type) {
                case UploadPasswordForRegister:
                    [setPasswordDelegate setPasswordToServerFailed];
                    return;
                    
                case UploadPasswordForChangePsw:
                    [changePasswordDelegate changePasswordToServerFailed];
                    break;
                    
                case UploadPasswordForEnablePswLock:
                    [enablePasswordLockDelegate enablePasswordLockFailed];
                    break;
                    
                default:
                    break;
            }
            if (response) {
                // retry upload if Token is invalid or expire
                NSInteger status_code = [[response objectForKey:kSTATUS_CODE] integerValue];
                if (status_code == ERROR_CODE_EXPIRED_COMMAND_TOKEN_TENANT ||
                    status_code == ERROR_CODE_EXPIRED_COMMAND_TOKEN_CENTRAL) {
                    
                    NSBlockOperation* operation = [NSBlockOperation blockOperationWithBlock:^{
                        [self updatePasscodeToServerwithType:type
                                             retryUploadTime:[kRETRY_API_COUNTER intValue]];
                    }];
                    
                    NSDictionary* retryDictionary = @{kRETRY_OPERATION:operation,
                                                      kRETRY_TIME:kRETRY_API_COUNTER,
                                                      kSTATUS_CODE : [response objectForKey:kSTATUS_CODE]};
                    
                    [[AppFacade share] downloadTokenAgain:retryDictionary];
                }
                else{
                    // retry update passcode to server 5 times if token is correct but upload fail
                    if (numberOfRetry > 0) {
                        numberOfRetry = numberOfRetry - 1;
                        [self updatePasscodeToServerwithType:type
                                             retryUploadTime:numberOfRetry];
                    }
                }
            }
        }
    }];
}

/*
 * Update old passcode and update master key local
 * Author : Jurian
 */
- (void) updatePasscodeAndMasterKeyLocal:(NSString*)passcode withType:(NSInteger)type{
    NSString *oldPasscode = [KeyChainSecurity getStringFromKey:kPASSWORD];
    [KeyChainSecurity storeString:[AESSecurity hashSHA256:passcode] Key:kPASSWORD];
    if(type != UploadPasswordForRegister)
        [[AppFacade share] resetLocalKey:oldPasscode];
}

-(void)uploadKeysToServer{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    NSDictionary *uploadKeyDic = @{kAPI_REQUEST_METHOD: POST,
                                   kAPI_REQUEST_KIND: NORMAL,
                                   kMASKINGID: [KeyChainSecurity getStringFromKey:kMASKINGID],
                                   kJID: [KeyChainSecurity getStringFromKey:kJID],
                                   kHOST: [self getXmppHostName],
                                   kDEVICE_ID: [[NSUUID UUID] UUIDString],
                                   kPLATFORM: @"1", //1 for iOS
                                   kIMSI: [self getIMSI],
                                   kIMEI: [self getIMEI],
                                   kMOD1_EXPONENT: [KeyChainSecurity getStringFromKey:kMOD1_EXPONENT],
                                   kMOD1_MODULUS: [KeyChainSecurity getStringFromKey:kMOD1_MODULUS],
                                   kMOD2_EXPONENT: [KeyChainSecurity getStringFromKey:kMOD2_EXPONENT],
                                   kMOD2_MODULUS: [KeyChainSecurity getStringFromKey:kMOD2_MODULUS],
                                   kMOD3_EXPONENT: [KeyChainSecurity getStringFromKey:kMOD3_EXPONENT],
                                   kMOD3_MODULUS: [KeyChainSecurity getStringFromKey:kMOD3_MODULUS],
                                   kPASSWORD: [self getPasscode]
                                   };
    
    [[CWindow share] showLoading:kLOADING_REGISTER_ACCOUNT];
    [[AccountAdapter share] uploadKeysToServer:uploadKeyDic callback:^(BOOL success, NSString *message, NSDictionary *response, NSError *error) {
        [[CWindow share] hideLoading];
        if ([[AppFacade share] preProcessResponse:response])
            return;
        if (success) {
            //Store keys
            [self setOwnKeyVersion:[response objectForKey:kKEY_VERSION]];
            [KeyChainSecurity storeString:ACCOUNT_ACTIVE Key:kACCOUNT_STATUS];
            [KeyChainSecurity storeString:[response objectForKey:kTOKEN] Key:kCENTRALTOKEN];
            
            [[XMPPFacade share] connectXMPP];
            [uploadKeysDelegate uploadKeysToServerSuccess];

            //Get account detail here
            [[ContactFacade share] getDetailAccount];
            //Get pending friend request
            [self getFriendPendingRequests];
            
            //Create local key
            if (![self getReloginFlag]) {//If relogin then no call createLocalKey
                [[AppFacade share] createLocalKey];
            }
            //Backup profile
            [[ContactFacade share] backupProfile];
            // update passfor backup file
            [self uploadMasterKey];
            NSLog(@"Finished register flow");
        }
        else{
            NSLog(@"Upload Key Failed: %@", error);
            [uploadKeysDelegate uploadKeysToServerFailed];
        }
    }];
}

-(void)searchFriendByMaskingId:(NSString*)maskingId{
    NSLog(@"%s: %@", __PRETTY_FUNCTION__, maskingId);
    NSDictionary *searchFriendDic = @{kAPI_REQUEST_METHOD: POST,
                                        kAPI_REQUEST_KIND: NORMAL,
                                        kMASKINGID: [self getMaskingId],
                                        kTOKEN: [self getTokentTenant],
                                        kIMSI: [self getIMSI],
                                        kIMEI: [self getIMEI],
                                        kFRIEND_MASKING_ID: maskingId
                                        };
    
    [[ContactAdapter share] searchFriendByMaskingId:searchFriendDic callback:^(BOOL success, NSString *message, NSDictionary *response, NSError *error) {
        NSLog(@"%s %@ %@",__PRETTY_FUNCTION__, response, error);
        [[CWindow share] hideLoading];
        if ([[AppFacade share] preProcessResponse:response])
            return;
        if (success) {
            NSMutableDictionary *friendInfomation = [[response objectForKey:kACCOUNT] mutableCopy];
            
            if(!friendInfomation)
                return;
            
            NSString* fullJID = [NSString stringWithFormat:@"%@@%@",[friendInfomation objectForKey:kJID],[friendInfomation objectForKey:kHOST]];
            NSString* queryCondition = [NSString stringWithFormat:@"jid = '%@'", fullJID];
            Contact* contact = (Contact*)[[DAOAdapter share] getObject:[Contact class] condition:queryCondition];
            
            if(!contact){
                contact = [Contact new];
                contact.jid = fullJID;
                contact.maskingid = [friendInfomation objectForKey:kMASKINGID];
                contact.serversideName = [[NSString alloc] initWithData:[Base64Security decodeBase64String:[friendInfomation objectForKey:kDISPLAY_NAME]] encoding:NSUTF8StringEncoding];
                contact.contactType = [NSNumber numberWithInt:kCONTACT_TYPE_KRYPTO_USER];
                contact.email = [friendInfomation objectForKey:kEMAIL];
                [[DAOAdapter share] commitObject:contact];
            }
            [friendInfomation setValue:contact.contactType forKey:kCONTACT_TYPE];
            [contactSearchMIDDelegate showSearchResult:friendInfomation];
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self updateContactInfo:fullJID];
            }];
        }
        else{
            [contactSearchMIDDelegate failedSearchResult];
            if (response){
                NSInvocationOperation* operation=  [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(searchFriendByMaskingId:) object:maskingId];
                // if Token is invalid or expire
                NSDictionary* retryDictionary = @{kRETRY_OPERATION:operation,
                                                  kRETRY_TIME:kRETRY_API_COUNTER,
                                                  kSTATUS_CODE : [response objectForKey:kSTATUS_CODE]};
                [[AppFacade share] downloadTokenAgain:retryDictionary];
            }
        }
    }];
}

-(void)addFriend:(NSString*)bobMaskindId{
    NSLog(@"%s: %@", __PRETTY_FUNCTION__, bobMaskindId);
    NSDictionary *getIdentityDic = @{kAPI_REQUEST_METHOD: POST,
                                     kAPI_REQUEST_KIND: NORMAL,
                                     kMASKINGID: [self getMaskingId],
                                     kTOKEN: [self getTokentCentral],
                                     kIMEI: [self getIMEI],
                                     kIMSI: [self getIMSI],
                                     kBOB_MASKING_ID: bobMaskindId
                                     };
    
    [[CWindow share] showLoading:kLOADING_ADDING];
    [[ContactAdapter share] getIdentity:getIdentityDic callback:^(BOOL success, NSString *message, NSDictionary *response, NSError *error) {
        NSLog(@"%s %@", __PRETTY_FUNCTION__, response);
        [[CWindow share] hideLoading];
        
        if ([[AppFacade share] preProcessResponse:response])
            return ;
        
        if (success) {
            NSString* friendJID = [response objectForKey:@"BOB_JID"];
            Request* request = [self getRequest:friendJID];
            Contact* contact = [self getContact:friendJID];
            
            if (request && ([request.requestType intValue] == 0) &&
                ([request.status intValue] == kREQUEST_STATUS_PENDING))
            {
                [[DAOAdapter share] deleteObject:request];
                request = nil;
            }
            
            if (!request) {
                request = [Request new];
                request.requestJID = [response objectForKey:@"BOB_JID"];
                request.requestType = [NSNumber numberWithInteger:0];
                request.status = [NSNumber numberWithInteger:kREQUEST_STATUS_PENDING];
                request.content = [response objectForKey:kDATA];
            }
            
            NSString* identitySend = [self processIdentity:[response objectForKey:kDATA]];
            if (!identitySend) {
                NSLog(@"%s Failed Add: %@", __PRETTY_FUNCTION__, identitySend);
                [contactSearchMIDDelegate addFriendFailed];
                [contactBookDelegate addKryptoFriendFailed:friendJID];// in Add Friend page
            }
            else{
                NSMutableDictionary* xmppDic = [NSMutableDictionary new];
                [xmppDic setObject:kBODY_MT_IDEN_XCHANGE_ADD forKey:kBODY_MESSAGE_TYPE];
                [xmppDic setObject:identitySend forKey:kBODY_MESSAGE_CONTENT];
                NSString* xmppBody = [ChatAdapter generateJSON:xmppDic];
                
                NSDictionary *msgOBJ = [[NSDictionary alloc] initWithObjectsAndKeys:xmppBody, kXMPP_SUBSCRIPTION_BODY, friendJID, kXMPP_TO_JID, [ChatAdapter generateMessageId], kXMPP_SUBSCRIPTION_ID, nil];
                NSLog(@"Object Send Friend Request: %@", msgOBJ);
                [[XMPPFacade share] sendFriendRequest:msgOBJ];
                if(contact)
                    contact.contactType = [NSNumber numberWithInt:kCONTACT_TYPE_NOT_FRIEND];
                
                //Save DB.
                [[DAOAdapter share] commitObject:contact];
                [[DAOAdapter share] commitObject:request];
                [contactSearchMIDDelegate addFriendSuccess];
                // in Add Friend page
                [contactBookDelegate addKryptoFriendSuccess:friendJID];
                [self loadContactRequest];
            }
        }
        else{
            [contactSearchMIDDelegate addFriendFailed];
            // in Add Friend page
#warning I'm not sure about parse bobMaskingId in this.
            //Daryl comment on 11/8.2015
            [contactBookDelegate addKryptoFriendFailed:bobMaskindId];
            
            if (response){
                NSInvocationOperation* operation=  [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(addFriend:) object:bobMaskindId];
                // if Token is invalid or expire
                NSDictionary* retryDictionary = @{kRETRY_OPERATION:operation,
                                                  kRETRY_TIME:kRETRY_API_COUNTER,
                                                  kSTATUS_CODE : [response objectForKey:kSTATUS_CODE]};
                [[AppFacade share] downloadTokenAgain:retryDictionary];
            }
        }
    }];
}

-(void)didReceiveApprove:(NSDictionary *)approveInfo{
    NSLog(@"%s: %@", __PRETTY_FUNCTION__, approveInfo);
    NSString* fullJID = [[[approveInfo objectForKey:kXMPP_FROM_JID] componentsSeparatedByString:@"/"] objectAtIndex:0];
    Contact* contact = [self getContact:fullJID];
    
    NSDictionary* requestDic = [ChatAdapter decodeJSON:[approveInfo objectForKey:kXMPP_SUBSCRIPTION_BODY]];
    NSString* base64Content = [requestDic objectForKey:kBODY_MESSAGE_CONTENT];
    if (!fullJID || !base64Content || !contact.maskingid.length > 0)
        return;
    
    // checkIdentity.
    NSLog(@"8. A will call IdentityCheck in central to confirm B identity");
    /*
     MASKINGID
     TOKEN
     IMEI
     IMSI
     ALICE_MASKING_ID
     */
    NSDictionary *checkIdentityDic = @{kAPI_REQUEST_METHOD: POST,
                                       kAPI_REQUEST_KIND: NORMAL,
                                       kMASKINGID: [self getMaskingId],
                                       kTOKEN: [self getTokentCentral],
                                       kIMEI: [self getIMEI],
                                       kIMSI: [self getIMSI],
                                       kALICE_MASKING_ID: contact.maskingid
                                       };
    [[ContactAdapter share] checkIdentity:checkIdentityDic callback:^(BOOL success, NSString *message, NSDictionary *response, NSError *error) {
        
        if ([[AppFacade share] preProcessResponse:response])
            return ;
        
        if (success) {
            //NSLog(@"%s checkIdentity Success: %@", __PRETTY_FUNCTION__, response);
            NSLog(@"9. A will call IdentityApprove in tenant. Server will add B into A roster");
            
            NSString* queryRequest = [NSString stringWithFormat:@"requestJID = '%@'", fullJID];
            Request* request = (Request*)[[DAOAdapter share] getObject:[Request class] condition:queryRequest];
            if (request) {
                request.content = base64Content;
                [[DAOAdapter share] commitObject:request];
            }
            
            NSString* identityHash = [self compareIdentityFromRequest:fullJID
                                                       serverIdentity:[response objectForKey:kDATA]];
            
            NSLog(@"identityHash %@", identityHash);
            
            if (identityHash) {
                [[CWindow share] showLoading:kLOADING_APPROVING];
                NSDictionary *approveIdentity = @{
                                                  kAPI_REQUEST_METHOD: POST,
                                                  kAPI_REQUEST_KIND: NORMAL,
                                                  kMASKINGID: [self getMaskingId],
                                                  kTOKEN: [self getTokentTenant],
                                                  kBOB_MASKING_ID: contact.maskingid,
                                                  kHASH:identityHash,
                                                  kCENTRALTOKEN: [self getTokentCentral],
                                                  kIMEI: [self getIMEI],
                                                  kIMSI: [self getIMSI],
                                                  kGET_IDENTITY:@"true"
                                                  };
                [[ContactAdapter share] approveIdentity:approveIdentity callback:^(BOOL success, NSString *message, NSDictionary *response, NSError *error){
                    [[CWindow share] hideLoading];
                    if (success) {
                        NSLog(@"10.1. A send notice approved from friend");
                        NSMutableDictionary* xmppDic = [NSMutableDictionary new];
                        [xmppDic setObject:kSUB_BODY_MT_IDEN_XCHANGE_DONE forKey:kBODY_MESSAGE_TYPE];
                        [xmppDic setObject:@"second_time" forKey:kBODY_MESSAGE_CONTENT];
                        NSString* xmppBody = [ChatAdapter generateJSON:xmppDic];
                        
                        NSDictionary *msgOBJ = [[NSDictionary alloc] initWithObjectsAndKeys:xmppBody, kXMPP_SUBSCRIPTION_BODY, fullJID, kXMPP_TO_JID, [ChatAdapter generateMessageId], kXMPP_SUBSCRIPTION_ID, nil];
                        [[XMPPFacade share] sendFriendRequest:msgOBJ];
                        // update request and contact db for Alice
                        NSLog(@"%s call update after receive approved.", __PRETTY_FUNCTION__);
                        [self friendRequestApproved:@{kXMPP_FROM_JID: fullJID} wasApprovedFromFriend:YES];
                    } else {
                        NSLog(@"%s Error: %@ - \nResponse: %@", __PRETTY_FUNCTION__, error, response);
                    }
                }];
            }
            else{
                NSLog(@"Identity of this friend is not match! Can't approve now");
                // if Token is invalid or expire
                if (response){
                    NSInvocationOperation* operation=  [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(didReceiveApprove:) object:approveInfo];
                    NSDictionary* retryDictionary = @{kRETRY_OPERATION:operation,
                                                      kRETRY_TIME:kRETRY_API_COUNTER,
                                                      kSTATUS_CODE : [response objectForKey:kSTATUS_CODE]};
                    [[AppFacade share] downloadTokenAgain:retryDictionary];
                }
            }
        }
        else {
            NSLog(@"%s Failed: %@ - %@", __PRETTY_FUNCTION__, response, error);
        }
    }];
}

-(void) friendRequestApproved:(NSDictionary*) info wasApprovedFromFriend:(BOOL)wasApprovedFromFriend{
    NSLog(@"%s %@", __PRETTY_FUNCTION__, info);
    NSString* fullJID = [info objectForKey:kJID];
    Contact* contact = [self getContact:fullJID];
    Request* request = [self getRequest:fullJID];
    if (request) {
        request.status = [NSNumber numberWithInt:kREQUEST_STATUS_APPROVED];
        [[DAOAdapter share] commitObject:request];
    }
    
    if (contact) {
        contact.contactType = [NSNumber numberWithInt:kCONTACT_TYPE_FRIEND];
        contact.contactState = [NSNumber numberWithInt:kCONTACT_STATE_OFFLINE];
        [[DAOAdapter share] commitObject:contact];

        [self getFriendPublicKey:contact.maskingid callback:^(BOOL success, NSString *message, NSDictionary *response, NSError *error) {
            
            if ([[AppFacade share] preProcessResponse:response])
                return ;
            
            if (success) {
                NSLog(@"%@", response);
                Key *friendKey = [Key new];
                friendKey.keyId = contact.jid;
                friendKey.keyJSON = [ChatAdapter generateJSON:response];
                if (friendKey.keyJSON) {
                    NSData* keyData = [[AppFacade share] encryptDataLocally:[friendKey.keyJSON dataUsingEncoding:NSUTF8StringEncoding]];
                    if (keyData)
                        friendKey.keyJSON = [Base64Security generateBase64String:keyData];
                }
                if ([response objectForKey:kS_KEY_VERSION]) {
                    friendKey.keyVersion = [response objectForKey:kS_KEY_VERSION];
                }
                
                [[DAOAdapter share] commitObject:friendKey];
                [self loadFriendArray];
                if(wasApprovedFromFriend)
                    [contactNotificationDelegate showNotifiView:HAVE_ACCEPT_FRIEND_REQUEST_NOTIFICATION_MESSAGE];
                else
                    [contactSearchMIDDelegate approveFriendSuccess];

                
                //backup contact
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self backupContact:fullJID friendStatus:APPROVED];
                });
            } else {
                NSLog(@"%s %@ %@ %@", __PRETTY_FUNCTION__, message, error, response);
            }
        }];
    }
    
    //Get Avatar of contact
    [self updateContactInfo:contact.jid];
    [self loadContactRequest];
}



- (void)wasDeniedFromRequest:(NSString *)requestJID
{
    NSLog(@"%s %@", __PRETTY_FUNCTION__, requestJID);
    Contact* contact = [self getContact:requestJID];
    Request* request = [self getRequest:requestJID];
    if (request) {
        [[DAOAdapter share] deleteObject:request];
    }
    if (contact) {
        contact.contactType = [NSNumber numberWithInt:kCONTACT_TYPE_KRYPTO_USER];
        [[DAOAdapter share] commitObject:contact];
    }
    
    [self loadFriendArray];
    [self loadContactRequest];
}

-(void)didReceiveRequest:(NSDictionary*) requestInfo{
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        
        NSString* fullJID = [[[requestInfo objectForKey:kXMPP_FROM_JID] componentsSeparatedByString:@"/"] objectAtIndex:0];
        NSString* JID = [[fullJID componentsSeparatedByString:@"@"] objectAtIndex:0];
        NSString* HOST = [[fullJID componentsSeparatedByString:@"@"] objectAtIndex:1];
        
        NSDictionary* requestDic = [ChatAdapter decodeJSON:[requestInfo objectForKey:kXMPP_SUBSCRIPTION_BODY]];
        NSString* base64Content = [requestDic objectForKey:kBODY_MESSAGE_CONTENT];
        if (!fullJID || !base64Content)
            return;
        
        //get friend info, who request to be my friend.
        NSDictionary *getFriendvCard = @{kAPI_REQUEST_METHOD: POST,
                                         kAPI_REQUEST_KIND: NORMAL,
                                         kMASKINGID: [self getMaskingId],
                                         kTOKEN: [self getTokentTenant],
                                         kIMSI: [self getIMSI],
                                         kIMEI: [self getIMEI],
                                         kJID: JID,
                                         kHOST: HOST,
                                         };
        
        [[ContactAdapter share] getFriendvCard:getFriendvCard callback:^(BOOL success, NSString *message, NSDictionary *response, NSError *error){
            NSLog(@"%@", response);
            
            if ([[AppFacade share] preProcessResponse:response])
                return ;
            
            if (success) {
                NSDictionary* contactInfo = [[XMPPAdapter share] parsevCardInfoFromXMLString:[response objectForKey:kVCARD]];
                Contact* contact = [self getContact:fullJID];
                
                if (![contactInfo objectForKey:kXMPP_USER_MASKING_ID]) {
                    NSLog(@"ANONYMOUS WITHOUT MASKING ID ADDING ME?");
                    return;
                }
                
                NSString* queryRequest = [NSString stringWithFormat:@"requestJID = '%@'", fullJID];
                Request* request = (Request*)[[DAOAdapter share] getObject:[Request class] condition:queryRequest];
                
                if (request && ([request.requestType intValue] == 1) && ([request.status intValue] == kREQUEST_STATUS_PENDING)) {
                    [[DAOAdapter share] deleteObject:request];
                    request = nil;
                }
                
                if (!request){
                    request = [Request new];
                    request.requestJID = fullJID;
                    request.requestType = [NSNumber numberWithInt:1];
                    request.status = [NSNumber numberWithInteger:kREQUEST_STATUS_PENDING];
                    request.content = base64Content;
                    [[DAOAdapter share] commitObject:request];
                    [self loadContactRequest];
                }
                
                if (!contact) {
                    contact = [Contact new];
                    contact.jid = fullJID;
                    contact.maskingid = [contactInfo objectForKey:kXMPP_USER_MASKING_ID];
                    contact.contactType = [NSNumber numberWithInt:kCONTACT_TYPE_KRYPTO_USER];
                    [[DAOAdapter share] commitObject:contact];
                    [self updateContactInfo:fullJID];
                }
                
                [[NotificationFacade share] insertNewNoticeWithID:fullJID type:kNOTICEBOARD_TYPE_ADD_CONTACT];
                
                dispatch_async(dispatch_get_main_queue(), ^(void){
                    [[NotificationFacade share] setUnreadNotification:[[NotificationFacade share] getNumberUnreadNotices] atMenuIndex:SideBarNotificationIndex];
                    [[NotificationFacade share] setUnreadNotification:[[NotificationFacade share] getAllNoticesWithContent:kNOTICEBOARD_CONTENT_ADD_CONTACT status:kNOTICEBOARD_STATUS_NEW].count atMenuIndex:SideBarContactIndex];
                    [[NotificationFacade share] notifyFriendRequestReceived:request];
                    [contactNotificationDelegate showNotifiView:HAVE_NEW_NOTIFICATION_MESSAGE];
                });;
            }
            else{
                if (response){
                    // if Token is invalid or expire
                    NSInvocationOperation* operation=  [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(didReceiveRequest:) object:requestInfo];
                    
                    NSDictionary* retryDictionary = @{kRETRY_OPERATION:operation,
                                                      kRETRY_TIME:kRETRY_API_COUNTER,
                                                      kSTATUS_CODE : [response objectForKey:kSTATUS_CODE]};
                    [[AppFacade share] downloadTokenAgain:retryDictionary];
                }
                NSLog(@"This contact is anonymous??");
            }
        }];
    });
}

-(void)approveRequest:(NSString*)requestJID{
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void)
    {
        Contact* aliceContact = [self getContact:requestJID];
        if(!aliceContact.maskingid)
            return;
        
        [[CWindow share] showLoading:kLOADING_CHECKING];
        NSDictionary *checkIdentity = @{kAPI_REQUEST_METHOD: POST,
                                        kAPI_REQUEST_KIND: NORMAL,
                                        kMASKINGID: [self getMaskingId],
                                        kTOKEN: [self getTokentCentral],
                                        kIMEI: [self getIMEI],
                                        kIMSI: [self getIMSI],
                                        kALICE_MASKING_ID: aliceContact.maskingid
                                        };
        
        [[ContactAdapter share] checkIdentity:checkIdentity callback:^(BOOL success, NSString *message, NSDictionary *response, NSError *error) {
            [[CWindow share] hideLoading];
            NSLog(@"%s %@", __PRETTY_FUNCTION__, response);
            
            if ([[AppFacade share] preProcessResponse:response])
                return ;
            
            if (success) {
                NSString* identityHash = [self compareIdentityFromRequest:requestJID
                                                           serverIdentity:[response objectForKey:kDATA]];
                
                NSLog(@"identityHash %@", identityHash);
                
                if (identityHash) {
                    [[CWindow share] showLoading:kLOADING_APPROVING];
                    NSDictionary *approveIdentity = @{
                                                      kAPI_REQUEST_METHOD: POST,
                                                      kAPI_REQUEST_KIND: NORMAL,
                                                      kMASKINGID: [self getMaskingId],
                                                      kTOKEN: [self getTokentTenant],
                                                      kBOB_MASKING_ID: aliceContact.maskingid,
                                                      kHASH:identityHash,
                                                      kGET_IDENTITY:@"true",
                                                      kIMEI: [self getIMEI],
                                                      kIMSI: [self getIMSI],
                                                      kCENTRALTOKEN: [self getTokentCentral]
                                                      };
                    [[ContactAdapter share] approveIdentity:approveIdentity callback:^(BOOL success, NSString *message, NSDictionary *response, NSError *error){
                        [[CWindow share] hideLoading];
                        
                        if ([[AppFacade share] preProcessResponse:response])
                            return ;
                        
                        if (success) {
                            // get IdentityGet in central. Central return A jid@host + A public key
                            NSDictionary *getIdentityDic = @{kAPI_REQUEST_METHOD: POST,
                                                             kAPI_REQUEST_KIND: NORMAL,
                                                             kMASKINGID: [self getMaskingId],
                                                             kTOKEN: [self getTokentCentral],
                                                             kIMEI: [self getIMEI],
                                                             kIMSI: [self getIMSI],
                                                             kBOB_MASKING_ID: aliceContact.maskingid
                                                             };
                            NSLog(@"6. B will call IdentityGet in central. Central return A jid@host + A public key");
                            [[ContactAdapter share] getIdentity:getIdentityDic callback:^(BOOL success, NSString *message, NSDictionary *response, NSError *error) {
                                NSLog(@"%s %@", __PRETTY_FUNCTION__, response);
                                if (success) {
                                    NSString* friendJID = [response objectForKey:@"BOB_JID"];
                                    
                                    NSString* identitySend = [self processIdentity:[response objectForKey:kDATA]];
                                    if (!identitySend) {
                                        NSLog(@"identitySend is nil");
                                        [contactSearchMIDDelegate addFriendFailed];
                                    }else{
                                        NSMutableDictionary* xmppDic = [NSMutableDictionary new];
                                        [xmppDic setObject:kBODY_MT_IDEN_XCHANGE_APPROVE forKey:kBODY_MESSAGE_TYPE];
                                        [xmppDic setObject:identitySend forKey:kBODY_MESSAGE_CONTENT];
                                        NSString* xmppBody = [ChatAdapter generateJSON:xmppDic];
                                        
                                        NSDictionary *msgOBJ = [[NSDictionary alloc] initWithObjectsAndKeys:xmppBody, kXMPP_SUBSCRIPTION_BODY, friendJID, kXMPP_TO_JID, [ChatAdapter generateMessageId], kXMPP_SUBSCRIPTION_ID, nil];
                                        NSLog(@"7. B send XMPP message to A using jid@host");
                                        [[XMPPFacade share] sendFriendRequest:msgOBJ];
                                        
                                        /*
                                         UPDATE: no need to send DONE from Bob side after send APPROVED command.
                                         */
                                        /*
                                         NSLog(@"7.1. B send notice approved from friend");
                                         NSMutableDictionary* newDic = [NSMutableDictionary new];
                                         [newDic setObject:kSUB_BODY_MT_IDEN_XCHANGE_DONE forKey:kBODY_MESSAGE_TYPE];
                                         [newDic setObject:@"first_time" forKey:kBODY_MESSAGE_CONTENT];
                                         NSString* newBody = [ChatAdapter generateJSON:newDic];
                                         NSDictionary *newOBJ = [[NSDictionary alloc] initWithObjectsAndKeys:newBody, kXMPP_SUBSCRIPTION_BODY, friendJID, kXMPP_TO_JID, [ChatAdapter generateMessageId], kXMPP_SUBSCRIPTION_ID, nil];
                                         [[XMPPFacade share] sendFriendRequest:newOBJ];
                                         */
                                        
                                        NSLog(@"7.1 Update contact as a friend at local DB");
                                        if(aliceContact){
                                            aliceContact.contactType = [NSNumber numberWithInt:kCONTACT_TYPE_FRIEND];
                                            aliceContact.contactState = [NSNumber numberWithInt:kCONTACT_STATE_OFFLINE];
                                        }
                                        [[DAOAdapter share] commitObject:aliceContact];
                                        
                                        Request* request = [self getRequest:requestJID];
                                        if (request) {
                                            request.status = [NSNumber numberWithInt:kREQUEST_STATUS_APPROVED];
                                            [[DAOAdapter share] commitObject:request];
                                        }
                                        
                                        [[NotificationFacade share] deleteNoticesWithID:requestJID];
                                        
                                        [self loadContactRequest];
                                    }
                                }
                                else{
                                    [contactSearchMIDDelegate addFriendFailed];
                                }
                            }];
                        }
                        else{
                            [[CAlertView new] showError:_ALERT_FAILED_ADD];
                        }
                    }];
                }
                else{
                    [[CAlertView new] showError:_ALERT_FAILED_IDENTITY_NOT_MATCH];
                }
            }
            else{
                [[CAlertView new] showError:_ALERT_FAILED_CHECK_IDENTITY];
            }
        }];
    });
}

-(BOOL)denyRequest:(NSString*)requestJID{
    Request* request = [self getRequest:requestJID];
    if (request) {
        NSMutableDictionary* xmppDic = [NSMutableDictionary new];
        [xmppDic setObject:kSUB_BODY_MT_IDEN_XCHANGE_DENY forKey:kBODY_MESSAGE_TYPE];
        [xmppDic setObject:@"" forKey:kBODY_MESSAGE_CONTENT];
        NSString* xmppBody = [ChatAdapter generateJSON:xmppDic];
        
        NSDictionary *msgOBJ = [[NSDictionary alloc] initWithObjectsAndKeys:xmppBody, kXMPP_SUBSCRIPTION_BODY, requestJID, kXMPP_TO_JID, [ChatAdapter generateMessageId], kXMPP_SUBSCRIPTION_ID, nil];
        [[XMPPFacade share] sendFriendUnapproval:msgOBJ];
        
        [[NotificationFacade share] deleteNoticesWithID:requestJID];
        [[DAOAdapter share] deleteObject:request];
        
        return true;
    }
    return false;
}

- (void)removeDeniedRequest:(NSString *)requestJID
{
    NSLog(@"%s %@", __PRETTY_FUNCTION__, requestJID);
    Request *req = [self getRequest:requestJID];
    if (req) {
        [[DAOAdapter share] deleteObject:req];
        [self loadContactRequest];
    }
    
    Contact* contact = [self getContact:requestJID];
    if (contact) {
        contact.contactType = [NSNumber numberWithInt:kCONTACT_TYPE_KRYPTO_USER];
        [[DAOAdapter share] commitObject:contact];
    }
}

-(void) loadContactRequest{
    NSOperationQueue *loadContactOperation = [[NSOperationQueue alloc] init];
    __block NSArray* arrayPending;
    __block NSArray* arrayRequest;
    [[AppFacade share] executeBlock:^{
        arrayPending = (NSArray*)[[DAOAdapter share] getObjects:[Request class]
                                                               condition:@"requestType = '0' and status = '0'"];
        arrayRequest = (NSArray*)[[DAOAdapter share] getObjects:[Request class]
                                                               condition:@"requestType = '1' and status = '0'"];
    }
                            inQueue:loadContactOperation
                         completion:^(BOOL finished) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^(){
            [arrayRequest count] > 0 ?
            [contactHeaderDelegate showNewRequest:arrayRequest] :
            [contactHeaderDelegate hideNewRequest];
            
            [arrayPending count] > 0 ?
            [contactHeaderDelegate showPending:arrayPending] :
            [contactHeaderDelegate hidePending];
            
            [contactRequestDelegate displayRequest:arrayRequest];
            [contactPendingDelegate displayPending:arrayPending];
            
            [contactRequestDelegate backViewWhenNoRequest];
            [contactPendingDelegate backViewWhenNoPending];

        }];
    }];
    
  }

-(void) loadFriendArray{
    NSOperationQueue *loadFriendOperation = [[NSOperationQueue alloc] init];
    __block NSArray* arrayContact;
    [[AppFacade share] executeBlock:^{
        NSString* query = [NSString stringWithFormat:@"contactType = '%d' AND (contactState != '%d' AND contactState != '%d' OR contactState is NULL)", kCONTACT_TYPE_FRIEND, kCONTACT_STATE_BLOCKED, kCONTACT_STATE_DELETED];
        
        arrayContact = [[DAOAdapter share] getObjects:[Contact class] condition:query];
        arrayContact = [arrayContact sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            Contact *contact1 = (Contact*) obj1;
            Contact *contact2 = (Contact*) obj2;
            
            NSString *contactName1 = [[self getContactName:contact1.jid] lowercaseString];
            NSString *contactName2 = [[self getContactName:contact2.jid] lowercaseString];
            
            return [contactName1 compare:contactName2];
        }];
    } inQueue:loadFriendOperation completion:^(BOOL finished) {
        [forwardListDelegate reloadForwardList:arrayContact];
        [contactListDelegate reloadContactList:arrayContact];
        [chatComposeDelegate reloadComposeList:arrayContact];
        [findEmailContactDelegate reloadEmailContactList:arrayContact];
        [unblockUsersDelegate reloadUnblockList:arrayContact];
        [chatListDelegate reloadComposeButton:arrayContact];
    }];
 }

-(void) loadBlockedUsersArray{
    NSOperationQueue *operationBlockUser = [[NSOperationQueue alloc] init];
    [operationBlockUser addOperationWithBlock:^{
        NSArray* arrayBlockUser =  [self getAllBlockedContacts];
        NSOperationQueue *mainQueue = [NSOperationQueue mainQueue];
        [mainQueue addOperationWithBlock:^{
            if (arrayBlockUser.count > 0)
                [blockUsersDelegate reloadBlockList:arrayBlockUser];
        }];
    }];
}

-(NSArray *)getAllBlockedContacts{
    NSString *queryCondition = [NSString stringWithFormat:@"contactType = '%d' AND contactState = '%d'", kCONTACT_TYPE_FRIEND, kCONTACT_STATE_BLOCKED];
    NSArray* arrayBlockUser =  [[DAOAdapter share] getObjects:[Contact class] condition:queryCondition];
    return arrayBlockUser;
}

/*Build string for block array.*/
- (NSString*)buildBlockListString:(NSArray*)arrayBlockUserDB{
    NSString *blocklist = @"";
    // get block list
    for (int i=0; i<[arrayBlockUserDB count]; i++) {
        //using full jid as param
        Contact *contactItem = [arrayBlockUserDB objectAtIndex:i];
        if ([blocklist length]>0) {
            blocklist = [blocklist stringByAppendingString:@","];
        }
        blocklist = [blocklist stringByAppendingString:contactItem.jid];
    }
    
    return blocklist;
}

-(void) displayNewRequest{
    NSString* condition = [NSString stringWithFormat:@"requestType = '1' and status = '%d'", kREQUEST_STATUS_PENDING];
    NSArray* arrayRequest = [[DAOAdapter share] getObjects:[Request class] condition:condition orderBy:@"createTS" isDescending:YES limit:MAXFLOAT];
    [contactRequestDelegate displayRequest:arrayRequest];
}

-(void) displayNewPending{
    NSString* condition = [NSString stringWithFormat:@"requestType = '0' and status = '%d'", kREQUEST_STATUS_PENDING];
    NSArray* arrayPending = [[DAOAdapter share] getObjects:[Request class]
                                                 condition:condition];
    [contactPendingDelegate displayPending:arrayPending];
}

#pragma mark - NEW FLOW FOR REQUEST FRIEND (Parker/Daniel) -
- (void)friendRequestWithContactJid:(NSString*)contactJid requestType:(NSString*)requestType requestInfo:(NSDictionary *)requestInfo
{
    NSDictionary *logDic;
    if (!requestType || !([requestType isEqualToString:CANCEL] || [requestType isEqualToString:REQUEST] || [requestType isEqualToString:SMS_REQUEST])) {
        NSLog(@"Friend request type is invalid. Must be REQUEST/CANCEL/SMS_REQUEST");
        logDic = @{
                                 LOG_CLASS : NSStringFromClass(self.class),
                                 LOG_CATEGORY: CATEGORY_FRIEND_REQUEST_SEND,
                                 LOG_MESSAGE: @"Friend request type is invalid",
                                 LOG_EXTRA1: @"",
                                 LOG_EXTRA2: @""
                                 };
        [[LogFacade share] logErrorWithDic:logDic];
        return;
    }
    
    NSMutableDictionary *requestDic = [NSMutableDictionary new];
    __block NSDictionary *reqInfo = [[NSDictionary alloc] init];
    if (requestInfo) {
        reqInfo = [requestInfo mutableCopy];
    }
    
    if ([requestType isEqualToString:SMS_REQUEST]) {
        // for Invite friends via SMS
        if ([contactJid length] < 1) {
            return;
        }
        
        [requestDic setObject:contactJid forKey:kRECIPIENT_MSISDN];
    }
    
    if ([requestType isEqualToString:REQUEST] || [requestType isEqualToString:CANCEL]) {
        NSRange ran = [contactJid rangeOfString:[self getXmppHostName]];
        if (ran.location == NSNotFound) {
            [requestDic setObject:contactJid forKey:kRECIPIENT_MSISDN];// for SMS Request
        } else {
            Contact* contact = [self getContact:contactJid];
            if (!contact) {
                NSLog(@"Contact jid %@ is not exist in database.", contactJid);
                return;
            }
            [requestDic setObject:contact.maskingid forKey:kRECIPIENT_MASKING_ID];
        }
    }
    
    [requestDic setObject:PUT forKey:kAPI_REQUEST_METHOD];
    [requestDic setObject:NORMAL forKey:kAPI_REQUEST_KIND];
    [requestDic setObject:[self getMaskingId] forKey:kMASKINGID];
    [requestDic setObject:[self getTokentTenant] forKey:kTOKEN];
    [requestDic setObject:[self getTokentCentral] forKey:kCENTRALTOKEN];
    [requestDic setObject:[self getIMSI] forKey:kIMSI];
    [requestDic setObject:[self getIMEI] forKey:kIMEI];
    [requestDic setObject:requestType forKey:kCMD];
    
    [[ContactAdapter share] httpFriendRequest:requestDic callback:^(BOOL success, NSString *message, NSDictionary *response, NSError *error){
        NSLog(@"%s %@", __PRETTY_FUNCTION__, response);
        if ([[AppFacade share] preProcessResponse:response])
            return;
        
        NSDictionary *logDic;
        if (success) {
            Request* request = [self getRequest:contactJid];
            Contact* contact = [self getContact:contactJid];
            
            if ([requestType isEqualToString:CANCEL]) {
                logDic = @{
                           LOG_CLASS : NSStringFromClass(self.class),
                           LOG_CATEGORY: CATEGORY_FRIEND_REQUEST_DELETE_PENDING,
                           LOG_MESSAGE: [NSString stringWithFormat:@"DELETE PENDING SUCCESS: ParaDic: %@, Response: %@",requestDic,response],
                           LOG_EXTRA1: @"",
                           LOG_EXTRA2: @""
                           };
                [[LogFacade share] logInfoWithDic:logDic];
                //Update DB
                if (request) {
                    [[NotificationFacade share] deleteNoticesWithID:contactJid];
                    [[DAOAdapter share] deleteObject:request];
                }
                if (contact) {
                    contact.contactType = [NSNumber numberWithInt:kCONTACT_TYPE_KRYPTO_USER];
                    [[DAOAdapter share] commitObject:contact];
                }
                [contactPendingDelegate cancelFriendRequestSuccess];
                [self loadContactRequest];
                //Backup contact here
                [self backupContact:contactJid friendStatus:PENDING];
            }
            
            if ([requestType isEqualToString:REQUEST]) {
                logDic = @{
                           LOG_CLASS : NSStringFromClass(self.class),
                           LOG_CATEGORY: CATEGORY_FRIEND_REQUEST_SEND,
                           LOG_MESSAGE: [NSString stringWithFormat:@"SEND REQUEST FRIEND SUCCESS: ParaDic: %@, Response: %@",requestDic,response],
                           LOG_EXTRA1: @"",
                           LOG_EXTRA2: @""
                           };
                [[LogFacade share] logInfoWithDic:logDic];

                if (!request) {
                    request = [Request new];
                    request.requestJID = contactJid;
                    request.requestType = [NSNumber numberWithInteger:0];
                    request.status = [NSNumber numberWithInteger:kREQUEST_STATUS_PENDING];
                    request.content = [response objectForKey:kDATA];
                }
                
                if(contact){
                    contact.contactType = [NSNumber numberWithInt:kCONTACT_TYPE_NOT_FRIEND];
                }
                
                //Save DB.
                [[DAOAdapter share] commitObject:contact];
                [[DAOAdapter share] commitObject:request];
                [contactSearchMIDDelegate addFriendSuccess];
                [contactPendingDelegate resendFriendSuccess];
                [contactBookDelegate addKryptoFriendSuccess:contactJid];// in Add Friend page
                [self loadContactRequest];
                
                //Backup contact here
                [self backupContact:contactJid friendStatus:PENDING];
            }
            
            if ([requestType isEqualToString:SMS_REQUEST]) {
                logDic = @{
                           LOG_CLASS : NSStringFromClass(self.class),
                           LOG_CATEGORY: CATEGORY_FRIEND_REQUEST_SMS,
                           LOG_MESSAGE: [NSString stringWithFormat:@"FRIEND REQUEST VIA SMS SUCCESS: ParaDic: %@, Response: %@",requestDic,response],
                           LOG_EXTRA1: @"",
                           LOG_EXTRA2: @""
                           };
                [[LogFacade share] logInfoWithDic:logDic];

                // update request items
                // EG: +841688946879,+84966596536 -> 2 items
                NSArray *arrSMSRequest = [contactJid componentsSeparatedByString:@","];
                if (arrSMSRequest) {
                    for (int i=0; i<[arrSMSRequest count]; i++) {
                        
                        Request* req = [self getRequest:[arrSMSRequest objectAtIndex:i]];
                        
                        if (!req) {
                            req = [Request new];
                            req.requestJID = [arrSMSRequest objectAtIndex:i];
                        }
                        req.requestType = [NSNumber numberWithInteger:0];
                        req.content = [response objectForKey:kDATA];
                        req.status = [NSNumber numberWithInteger:kREQUEST_STATUS_PENDING];
                        req.extend1 = [reqInfo objectForKey:[arrSMSRequest objectAtIndex:i]] ? [reqInfo objectForKey:[arrSMSRequest objectAtIndex:i]] : @"";
                        //Save DB
                        [[DAOAdapter share] commitObject:req];
                    }
                }
            }
            
            
        }else{
            
            if ([requestType isEqualToString:CANCEL]) {
                NSInteger status_code = 0;
                if ([response objectForKey:kSTATUS_CODE]) {
                    status_code = [[response objectForKey:kSTATUS_CODE] integerValue];
                }
                switch (status_code) {
                    case ERROR_CODE_FRIEND_REQUEST_DENIED:
                    case ERROR_CODE_FRIEND_REQUEST_NOT_FOUND:
                    {
                        //Friend Request Has Been Denied
                        Request* request = [self getRequest:contactJid];
                        Contact* contact = [self getContact:contactJid];
                        if (request) {
                            [[NotificationFacade share] deleteNoticesWithID:contactJid];
                            [[DAOAdapter share] deleteObject:request];
                        }
                        if (contact) {
                            contact.contactType = [NSNumber numberWithInt:kCONTACT_TYPE_KRYPTO_USER];
                            [[DAOAdapter share] commitObject:contact];
                        }
                        
                        [self loadContactRequest];
                    }
                        logDic = @{
                                   LOG_CLASS : NSStringFromClass(self.class),
                                   LOG_CATEGORY: CATEGORY_FRIEND_REQUEST_DELETE_PENDING,
                                   LOG_MESSAGE: [NSString stringWithFormat:@"DELETE PENDING FAIL: ParaDic: %@, Response: %@",requestDic,response],
                                   LOG_EXTRA1: @"",
                                   LOG_EXTRA2: @""
                                   };
                        [[LogFacade share] logErrorWithDic:logDic];

                        [[CWindow share] hideLoading];
                        break;
                        
                    default:
                        [contactPendingDelegate cancelFriendRequestFailed];
                        break;
                }
                if (response){
                    NSBlockOperation* operation = [NSBlockOperation blockOperationWithBlock:^{
                        [self friendRequestWithContactJid:contactJid requestType:requestType requestInfo:requestInfo];
                    }];
                    
                    // if Token is invalid or expire
                    NSDictionary* retryDictionary = @{kRETRY_OPERATION:operation,
                                                      kRETRY_TIME:kRETRY_API_COUNTER,
                                                      kSTATUS_CODE : [response objectForKey:kSTATUS_CODE]};
                    [[AppFacade share] downloadTokenAgain:retryDictionary];
                }
            }
            
            if ([requestType isEqualToString:REQUEST]) {
                logDic = @{
                           LOG_CLASS : NSStringFromClass(self.class),
                           LOG_CATEGORY: CATEGORY_FRIEND_REQUEST_SEND,
                           LOG_MESSAGE: [NSString stringWithFormat:@"SEND FRIEND REQUEST FAIL: ParaDic: %@, Response: %@",requestDic,response],
                           LOG_EXTRA1: @"",
                           LOG_EXTRA2: @""
                           };
                [[LogFacade share] logErrorWithDic:logDic];
                [contactSearchMIDDelegate addFriendFailed];
                [contactPendingDelegate resendFriendFailed];
                [contactBookDelegate addKryptoFriendFailed:contactJid];// in Add Friend page
            }
        }
    }];
}

- (void)didReceiveFriendRequest:(NSDictionary *)requestInfo
{
    NSLog(@"%s %@", __PRETTY_FUNCTION__, requestInfo);
    
    NSString* fullJID = [requestInfo objectForKey:kJID];
    if (fullJID.length == 0)
        return;
    
    NSString* JID = [[fullJID componentsSeparatedByString:@"@"] objectAtIndex:0];
    NSString* HOST = [[fullJID componentsSeparatedByString:@"@"] objectAtIndex:1];
    
    if(JID.length == 0 || HOST.length == 0)
        return;
    
    //get friend info, who request to be my friend.
    NSDictionary *getFriendvCard = @{kAPI_REQUEST_METHOD: POST,
                                     kAPI_REQUEST_KIND: NORMAL,
                                     kMASKINGID: [self getMaskingId],
                                     kTOKEN: [self getTokentTenant],
                                     kJID: JID,
                                     kHOST: HOST,
                                     kIMSI: [self getIMSI],
                                     kIMEI: [self getIMEI]
                                     };
    
    [[ContactAdapter share] getFriendvCard:getFriendvCard callback:^(BOOL success, NSString *message, NSDictionary *response, NSError *error){
        NSLog(@"%s %@",__PRETTY_FUNCTION__, response);
        if (success) {
            NSDictionary* contactInfo = [[XMPPAdapter share] parsevCardInfoFromXMLString:[response objectForKey:kVCARD]];
            if (![contactInfo objectForKey:kXMPP_USER_MASKING_ID]) {
                NSLog(@"ANONYMOUS WITHOUT MASKING ID ADDING ME?");
                return;
            }
            
            NSString* queryRequest = [NSString stringWithFormat:@"requestJID = '%@'", fullJID];
            Request* request = (Request*)[[DAOAdapter share] getObject:[Request class] condition:queryRequest];
            if (!request){
                request = [Request new];
                request.requestJID = fullJID;
                request.requestType = [NSNumber numberWithInt:1];
                request.status = [NSNumber numberWithInteger:kREQUEST_STATUS_PENDING];
                request.content = [requestInfo objectForKey:kBODY_MESSAGE_CONTENT];
                request.createTS = [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]];
                [[DAOAdapter share] commitObject:request];
                [self loadContactRequest];
            }
            
            Contact* contact = [self getContact:fullJID];
            if (!contact) {
                contact = [Contact new];
                contact.jid = fullJID;
            }
            
            contact.maskingid = [contactInfo objectForKey:kXMPP_USER_MASKING_ID];
            contact.contactType = [NSNumber numberWithInt:kCONTACT_TYPE_NOT_FRIEND];
            
            NSData* avatarData = [contactInfo objectForKey:kAVATAR_IMAGE_DATA];
            if (avatarData) {
                [[ContactAdapter share] setContactAvatar:fullJID
                                                    data:[[AppFacade share] encryptDataLocally:avatarData]];
                contact.avatarURL = fullJID;
            }
            
            contact.serversideName = [[NSString alloc] initWithData:[Base64Security decodeBase64String:[contactInfo objectForKey:kXMPP_USER_DISPLAYNAME]] encoding:NSUTF8StringEncoding];
            contact.email = [contactInfo objectForKey:kXMPP_USER_EMAIL];
            
            [[DAOAdapter share] commitObject:contact];
            [[NotificationFacade share] insertNewNoticeWithID:fullJID type:kNOTICEBOARD_TYPE_ADD_CONTACT];
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [[NotificationFacade share] setUnreadNotification:[[NotificationFacade share] getNumberUnreadNotices] atMenuIndex:SideBarNotificationIndex];
                [[NotificationFacade share] setUnreadNotification:[[NotificationFacade share] getAllNoticesWithContent:kNOTICEBOARD_CONTENT_ADD_CONTACT status:kNOTICEBOARD_STATUS_NEW].count atMenuIndex:SideBarContactIndex];
                [[NotificationFacade share] notifyFriendRequestReceived:request];
                [contactNotificationDelegate showNotifiView:HAVE_NEW_NOTIFICATION_MESSAGE];
            }];
            
            //backup contact
            [self backupContact:fullJID friendStatus:RECEIVED];
        }
        else if(response){
            // if Token is invalid or expire
            NSInvocationOperation* operation=  [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(didReceiveFriendRequest:) object:requestInfo];
            NSDictionary* retryDictionary = @{kRETRY_OPERATION:operation,
                                              kRETRY_TIME:kRETRY_API_COUNTER,
                                              kSTATUS_CODE : [response objectForKey:kSTATUS_CODE]};
            [[AppFacade share] downloadTokenAgain:retryDictionary];
        }
    }];
}

- (void)responseFriendRequest:(NSString *)requestJID responseType:(NSString *)responseType
{
    Contact* aliceContact = [self getContact:requestJID];
    if(!aliceContact.maskingid)
        return;
    
    NSDictionary *friendRequestDic = @{kAPI_REQUEST_METHOD: PUT,
                                       kAPI_REQUEST_KIND: NORMAL,
                                       kMASKINGID: [self getMaskingId],
                                       kTOKEN: [self getTokentTenant],
                                       kCENTRALTOKEN: [self getTokentCentral],
                                       kIMSI: [self getIMSI],
                                       kIMEI: [self getIMEI],
                                       kSENDERMASKINGID: aliceContact.maskingid,
                                       kRESPONSE: responseType
                                       };
    [[CWindow share] showLoading:kLOADING_LOADING];
    [[ContactAdapter share] httpFriendRequestResponse:friendRequestDic callback:^(BOOL success, NSString *message, NSDictionary *response, NSError *error) {
        NSLog(@"%s %@", __PRETTY_FUNCTION__, response);
        NSDictionary *logDic;
        [[CWindow share] hideLoading];
        
        if ([[AppFacade share] preProcessResponse:response])
            return ;
        
        if (success) {
            if ([responseType isEqualToString:APPROVED]) {
                [[XMPPAdapter share] sendFriendSubscriptionTo:aliceContact.jid];
                [self friendRequestApproved:@{kJID: aliceContact.jid} wasApprovedFromFriend:NO];
                [self backupContact:aliceContact.jid friendStatus:APPROVED];
                logDic = @{LOG_CLASS : NSStringFromClass(self.class),
                           LOG_CATEGORY: CATEGORY_FRIEND_REQUEST_DELETE_PENDING,
                           LOG_MESSAGE: [NSString stringWithFormat:@"APPROVE FRIEND REQUEST SUCCESS: ParaDic: %@, Response: %@",friendRequestDic,response],
                           LOG_EXTRA1: @"",
                           LOG_EXTRA2: @""
                           };
            }
            
            if ([responseType isEqualToString:DENIED]) {
                Request* request = [self getRequest:requestJID];
                if (request) {
                    [[DAOAdapter share] deleteObject:request];
                }
                Contact* contact = [self getContact:requestJID];
                if (contact) {
                    contact.contactType = [NSNumber numberWithInt:kCONTACT_TYPE_KRYPTO_USER];
                    [[DAOAdapter share] commitObject:contact];
                }
                [[XMPPAdapter share] sendFriendUnSubscriptionTo:aliceContact.jid];
                [self loadContactRequest];
                [self backupContact:aliceContact.jid friendStatus:REMOVED];
                logDic = @{LOG_CLASS : NSStringFromClass(self.class),
                           LOG_CATEGORY: CATEGORY_FRIEND_REQUEST_DELETE_PENDING,
                           LOG_MESSAGE: [NSString stringWithFormat:@"DENY FRIEND REQUEST SUCCESS: ParaDic: %@, Response: %@",friendRequestDic,response],
                           LOG_EXTRA1: @"",
                           LOG_EXTRA2: @""
                           };
            }
            
            [[LogFacade share] logInfoWithDic:logDic];
            [[NotificationFacade share] deleteNoticesWithID:requestJID];
        }
        else {
            
            if ([responseType isEqualToString:APPROVED]) {
                NSInteger status_code = 0;
                if ([response objectForKey:kSTATUS_CODE]) {
                    status_code = [[response objectForKey:kSTATUS_CODE] integerValue];
                }
                
                switch (status_code) {
                    case 4095://Friend Request Has Been Cancelled
                    case 4093://Friend Request Not Found
                    {
                        CAlertView* alertView = [CAlertView new];
                        [alertView showError:mERROR_REQUEST_NO_LONGER_VALID];
                        [alertView setOnButtonTouchUpInside:^(CAlertView *alertView, int indexButton){
                            [self removeDeniedRequest:requestJID];
                        }];
                        [self backupContact:requestJID friendStatus:REMOVED];
                        [[NotificationFacade share] deleteNoticesWithID:requestJID];
                    }
                        break;
                        
                    default:
                        [[CAlertView new] showError:_ALERT_FAILED_ADD];
                        break;
                }
                
                logDic = @{LOG_CLASS : NSStringFromClass(self.class),
                           LOG_CATEGORY: CATEGORY_FRIEND_REQUEST_DELETE_PENDING,
                           LOG_MESSAGE: [NSString stringWithFormat:@"APPROVE FRIEND REQUEST FAILED: ParaDic: %@, Response: %@, Error: %@",friendRequestDic,response,error],
                           LOG_EXTRA1: @"",
                           LOG_EXTRA2: @""
                           };
            }
            
            if ([responseType isEqualToString:DENIED]) {
                CAlertView* alertView = [CAlertView new];
                [alertView showError:mERROR_FRIEND_REQUEST_NOT_AVAILABEL];
                [alertView setOnButtonTouchUpInside:^(CAlertView *alertView, int indexButton){
                    [self backupContact:requestJID friendStatus:REMOVED];
                    [self removeDeniedRequest:requestJID];
                    [[NotificationFacade share] deleteNoticesWithID:requestJID];
                }];
                
                logDic = @{LOG_CLASS : NSStringFromClass(self.class),
                           LOG_CATEGORY: CATEGORY_FRIEND_REQUEST_DENY,
                           LOG_MESSAGE: [NSString stringWithFormat:@"DENY FRIEND REQUEST FAILED: ParaDic: %@, Response: %@, Error: %@",friendRequestDic,response,error],
                           LOG_EXTRA1: @"",
                           LOG_EXTRA2: @""
                           };
            }
            
            [[LogFacade share] logErrorWithDic:logDic];
            
            if (response){
                // if Token is invalid or expire
                NSBlockOperation* operation = [NSBlockOperation blockOperationWithBlock:^{
                    [self responseFriendRequest:requestJID responseType:responseType];
                }];
                
                NSDictionary* retryDictionary = @{kRETRY_OPERATION:operation,
                                                  kRETRY_TIME:kRETRY_API_COUNTER,
                                                  kSTATUS_CODE : [response objectForKey:kSTATUS_CODE]};
                [[AppFacade share] downloadTokenAgain:retryDictionary];
            }
        }
    }];
}

- (void)didReceiveFriendApprove:(NSDictionary *)approveInfo
{
    if (approveInfo) {
        [[XMPPAdapter share] sendFriendSubscriptionTo:[approveInfo objectForKey:kJID]];
        [self friendRequestApproved:approveInfo wasApprovedFromFriend:YES];
    }
}

- (void)didReceiveFriendDenied:(NSDictionary *)deniedInfo
{
    NSLog(@"%s %@", __PRETTY_FUNCTION__, [deniedInfo objectForKey:kJID]);
    Contact* contact = [self getContact:[deniedInfo objectForKey:kJID]];
    Request* request = [self getRequest:[deniedInfo objectForKey:kJID]];
    
    // Accroding to UX expert we don't need to remove the friend request from the "Pending list".
    //if (request) {
    //    [[DAOAdapter share] deleteObject:request];
    //}
    
    if (contact) {
        contact.contactType = [NSNumber numberWithInt:kCONTACT_TYPE_KRYPTO_USER];
        [[DAOAdapter share] commitObject:contact];
    }
    
    [self loadFriendArray];
    [self loadContactRequest];
}

- (void)getFriendPendingRequests
{
    NSDictionary *friendRequestDic = @{kAPI_REQUEST_METHOD: PUT,
                                       kAPI_REQUEST_KIND: NORMAL,
                                       kMASKINGID: [self getMaskingId],
                                       kTOKEN: [self getTokentTenant],
                                       kCENTRALTOKEN: [self getTokentCentral],
                                       kIMSI: [self getIMSI],
                                       kIMEI: [self getIMEI]
                                       };

    [[ContactAdapter share] httpFriendRequestList:friendRequestDic callback:^(BOOL success, NSString *message, NSDictionary *response, NSError *error) {
        NSLog(@"%s %@", __PRETTY_FUNCTION__, response);
        
        if ([[AppFacade share] preProcessResponse:response])
            return ;
        
        if (success) {
            NSString *myMaskingID = [self getMaskingId];
            NSString *myMSISDN = [self getMSISDN];
            NSArray *friendRequests = (NSArray *)[[response objectForKey:@"DATA"] objectForKey:@"FRIEND_REQUEST_LIST"];
            if ([friendRequests count]>0) {
                for (NSDictionary *req in friendRequests) {
                    NSString *recipient_masking_id = [req objectForKey:@"recipient_masking_id"];
                    NSString *recipient_msisdn = [req objectForKey:@"recipient_msisdn"];
                    //NSString *recipient_cert = [[NSString alloc] initWithData:[Base64Security decodeBase64String:[req objectForKey:@"recipient_cert"]] encoding:NSUTF8StringEncoding]; << not using, temp comment,TrungVN
                    NSString *sender_masking_id = [req objectForKey:@"sender_masking_id"];
                    NSString *sender_cert = [[NSString alloc] initWithData:[Base64Security decodeBase64String:[req objectForKey:@"sender_cert"]] encoding:NSUTF8StringEncoding];
                    
                    
                    //get friend info and save to local db, who in response data
                    if ([sender_masking_id isEqualToString:myMaskingID]) {
                        [self searchFriendByMaskingId:recipient_masking_id];
                    } else {
                        [self searchFriendByMaskingId:sender_masking_id];
                    }
                    
                    //
                    if (!sender_cert) {
                        break;
                    }
                    
                    NSArray* arrIdentity = [sender_cert componentsSeparatedByString:kAES_SEPARATOR];
                    if ([arrIdentity count] != 2) {
                        break;
                    }
                    
                    NSData* partKey = [Base64Security decodeBase64String:[arrIdentity objectAtIndex:0]];
                    NSData* partAES = [Base64Security decodeBase64String:[arrIdentity objectAtIndex:1]];
                    if((partKey.length < 16) || !partAES) {
                        break;
                    }
                    
                    NSData* realKey = [RSASecurity decryptRSA:[Base64Security generateBase64String:partKey]
                                                 b64PublicExp:[KeyChainSecurity getStringFromKey:kMOD2_EXPONENT]
                                                   b64Modulus:[KeyChainSecurity getStringFromKey:kMOD2_MODULUS]
                                                b64PrivateExp:[KeyChainSecurity getStringFromKey:kMOD2_PRIVATE]];
                    if (realKey) {
                        NSData* identityKey = [AESSecurity decryptAES256WithKey:realKey Data:partAES];
                        if (!identityKey) {
                            NSString* strKey = [[NSString alloc] initWithData:identityKey encoding:NSUTF8StringEncoding];
                            NSArray* arrKey = [strKey componentsSeparatedByString:kMSG_SEPARATOR];
                            
                            NSLog(@"hashSHA256 %@", [AESSecurity hashSHA256:[arrKey objectAtIndex:1]]);
                        }
                    }
                    
                    NSLog(@"sender_cert %@", sender_cert);
                    NSString* identitySend = [self processIdentity:sender_cert];
                    NSLog(@"identitySend %@", identitySend);
                    
                    if (!recipient_masking_id || !recipient_msisdn || !sender_masking_id) {
                        break;
                    }
                    
                    if ([recipient_msisdn isEqualToString:myMSISDN] && [recipient_masking_id isEqualToString:myMaskingID]) {
                        // update to pending request list
                    }
                }
            }
        }
    }];
}

#pragma mark - END OF NEW FLOW FOR FRIEND REQUEST (Parker/Daniel) -

- (void)requestContactInfo:(NSString *)fullJid
{
    if ([fullJid isEqualToString:[self getJid:YES]]) {
        return;
    }
    //get friend info, who request to be my friend.
    NSDictionary *getFriendvCard = @{kAPI_REQUEST_METHOD: POST,
                                     kAPI_REQUEST_KIND: NORMAL,
                                     kMASKINGID: [self getMaskingId],
                                     kTOKEN: [self getTokentTenant],
                                     kJID: [[fullJid componentsSeparatedByString:@"@"] objectAtIndex:0],
                                     kHOST: [[fullJid componentsSeparatedByString:@"@"] objectAtIndex:1],
                                     kIMSI: [self getIMSI],
                                     kIMEI: [self getIMEI]
                                     };
    
    [[ContactAdapter share] getFriendvCard:getFriendvCard callback:^(BOOL success, NSString *message, NSDictionary *response, NSError *error){
        //NSLog(@"%@", response);
        
        if ([[AppFacade share] preProcessResponse:response])
            return ;
        
        if (success) {
            NSDictionary* contactInfo = [[XMPPAdapter share] parsevCardInfoFromXMLString:[response objectForKey:kVCARD]];
            Contact* contact = [self getContact:fullJid];
            
            if (!contact) {
                contact = [Contact new];
                contact.jid = fullJid;
                contact.maskingid = [contactInfo objectForKey:kXMPP_USER_MASKING_ID];
                contact.contactType = [NSNumber numberWithInt:kCONTACT_TYPE_KRYPTO_USER];
                [[DAOAdapter share] commitObject:contact];
                [self updateContactInfo:fullJid];
            }
        }
        else{
            // if Token is invalid or expire
             if (response){
                NSInvocationOperation* operation=  [[NSInvocationOperation alloc] initWithTarget:self
                                                                                        selector:@selector(requestContactInfo:)
                                                                                          object:fullJid];
                
                NSDictionary* retryDictionary = @{kRETRY_OPERATION:operation,
                                                  kRETRY_TIME:kRETRY_API_COUNTER,
                                                  kSTATUS_CODE : [response objectForKey:kSTATUS_CODE]};
                [[AppFacade share] downloadTokenAgain:retryDictionary];
             }
        }
        
    }];
}

- (void)getFriendPublicKey:(NSString *)bobMaskindIdPara callback:(reqCompleteBlock)callbackPara
{
    __block NSString* bobMaskindId = bobMaskindIdPara;
    __block reqCompleteBlock callback = callbackPara;
    
    void (^reqPublicKeyCompleteCallBack)(BOOL success, NSString *message ,NSDictionary *response, NSError *error) = callback;
    /*
     API
     API_REQUEST_METHOD(POST/GET)
     API_REQUEST_KIND(Upload/Download/Normal)
     MASKINGID
     TOKEN(Token of the own user)
     IMEI
     IMSI
     F_MASKING_ID
     */
    NSDictionary *pubKeyRegDic = @{kAPI_REQUEST_KIND: NORMAL,
                                   kAPI_REQUEST_METHOD: POST,
                                   kMASKINGID: [self getMaskingId],
                                   kIMEI: [self getIMEI],
                                   kIMSI: [self getIMSI],
                                   kBOB_MASKING_ID: bobMaskindId,
                                   kTOKEN: [self getTokentCentral]
                                   };
    [[ContactAdapter share] getFriendPublicKey:pubKeyRegDic callback:^(BOOL success, NSString *message, NSDictionary *response, NSError *error) {
        
        if ([[AppFacade share] preProcessResponse:response])
            return ;
        
        if (success) {
            if ([response objectForKey:@"E1"]) {
                NSMutableDictionary *m = [NSMutableDictionary new];
                [m setObject:[response objectForKey:@"E1"] forKey:kMOD1_EXPONENT];
                [m setObject:[response objectForKey:@"N1"] forKey:kMOD1_MODULUS];
                [m setObject:[response objectForKey:@"E3"] forKey:kMOD3_EXPONENT];
                [m setObject:[response objectForKey:@"N3"] forKey:kMOD3_MODULUS];
                [m setObject:[response objectForKey:@"VERSION"] forKey:kS_KEY_VERSION];
                reqPublicKeyCompleteCallBack(YES, @"getFriendPublicKey successfully", m, nil);
            } else {
                reqPublicKeyCompleteCallBack(NO, @"getFriendPublicKey failed", response, error);
            }
        } else {
            NSLog(@"%s %@ %@", __PRETTY_FUNCTION__, response, error);
            reqPublicKeyCompleteCallBack(NO, @"getFriendPublicKey failed", response, error);
             if (response){
                // if Token is invalid or expire
                SEL  currentSelector = @selector(getFriendPublicKey:callback:);
                NSMethodSignature * methSig          = [self methodSignatureForSelector: currentSelector];
                NSInvocation      * invocation       = [NSInvocation invocationWithMethodSignature: methSig];
                [invocation setSelector: currentSelector];
                [invocation setTarget: self];
                [invocation setArgument: &bobMaskindId atIndex: 2];
                [invocation setArgument: &callback atIndex: 3];
                NSInvocationOperation* operation=  [[NSInvocationOperation alloc] initWithInvocation:invocation];
                
                
                NSDictionary* retryDictionary = @{kRETRY_OPERATION:operation,
                                                  kRETRY_TIME:kRETRY_API_COUNTER,
                                                  kSTATUS_CODE : [response objectForKey:kSTATUS_CODE]};
                [[AppFacade share] downloadTokenAgain:retryDictionary];
             }
        }
    }];
}

#pragma mark - Backup/Restore functions -
-(void)backupProfile{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [self generateBackupFile:^(BOOL success, NSDictionary *objDict) {
        if (success) {
            
            NSString *fileName = [NSString stringWithFormat:@"%@.%@", [self getJid:YES], BACKUP_FILE_EXTENSION];
            NSData *backupData = [[AccountAdapter share] getBackupData:fileName];
            
            NSMutableData *masterKeyData = [[Base64Security decodeBase64String:[KeyChainSecurity getStringFromKey:kENC_MASTER_KEY]] mutableCopy];
            
            NSString *masterKeyUpload = [Base64Security generateBase64String:[masterKeyData copy]];
            
            if (!masterKeyUpload) {
                NSLog(@"Master key for backup file upload is nill");
                return;
            }
            
            //upload backup file to server
            NSMutableDictionary *backupParameter = [[NSMutableDictionary alloc] init];
            [backupParameter setObject:POST forKey:kAPI_REQUEST_METHOD];
            [backupParameter setObject:UPLOAD forKey:kAPI_REQUEST_KIND];
            [backupParameter setObject:[self getMaskingId] forKey:kMASKINGID];
            [backupParameter setObject:[self getTokentTenant] forKey:kTOKEN];
            [backupParameter setObject:[self getIMEI] forKey:kIMEI];
            [backupParameter setObject:[self getIMSI] forKey:kIMSI];
            [backupParameter setObject:masterKeyUpload forKey:kMASTERKEY];
            
            [backupParameter setObject:BACKUP_FILE_EXTENSION forKey:kUPLOAD_FILE];
            [backupParameter setObject:backupData forKey:kAPI_UPLOAD_FILEDATA];
            [backupParameter setObject:@"file" forKey:kAPI_UPLOAD_NAMEUPLOAD];
            [backupParameter setObject:BACKUP_FILE_EXTENSION forKey:kAPI_UPLOAD_FILETYPE];
            [backupParameter setObject:fileName forKey:kAPI_UPLOAD_FILENAME];
            
            [[AccountAdapter share] backupFileUpload:backupParameter callback:^(BOOL success, NSString *message, NSDictionary *response, NSError *error) {
                NSLog(@"%s %@", __PRETTY_FUNCTION__, success ? @"SUCCESS":@"FAILED");
                if (success) {
                    [KeyChainSecurity storeString:_YES Key:kIS_BACKUP_ACCOUNT];
                }
                else{
                    [KeyChainSecurity storeString:_NO Key:kIS_BACKUP_ACCOUNT];
                    
                    if (response){
                        NSInvocationOperation* operation=  [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(backupProfile) object:nil];
                        NSDictionary* retryDictionary = @{kRETRY_OPERATION:operation,
                                                          kRETRY_TIME:kRETRY_API_COUNTER,
                                                          kSTATUS_CODE : [response objectForKey:kSTATUS_CODE]};
                        [[AppFacade share] downloadTokenAgain:retryDictionary];
                    }
                }
            }];
        }
    }];
}

typedef void (^BackupFileCompletionHandler)(BOOL success, NSDictionary *objDict);
- (void) generateBackupFile:(BackupFileCompletionHandler) callback{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    @try {
        void (^backupFileCallBack)(BOOL success, NSDictionary *objDict) = callback;
        
        if([[self getJid:YES] isEqualToString:@""] || [[self getPasscode] isEqualToString:@""]){
            NSLog(@"JID or PASSWORD_KEY is empty");
            backupFileCallBack(NO,nil);
            return;
        }
        //backup file version
        NSString *backupVersion = [KeyChainSecurity getStringFromKey:kBACKUP_FILE_VERSION]?[KeyChainSecurity getStringFromKey:kBACKUP_FILE_VERSION]:@"1";
        int ibackupVersion = [backupVersion intValue];
        backupVersion = [NSString stringWithFormat:@"%d",ibackupVersion++];
        [KeyChainSecurity storeString:backupVersion Key:kBACKUP_FILE_VERSION];
        
        //Backup notification here. missing
        
        //get keys to backup
        NSDictionary *dictKeys = [self getKeysToBackup];
        
        NSLog(@"dicKeys to backup : %@", dictKeys);
        
        //Get email setting to backup
        NSDictionary * dictEmailSetting = [self getEmailSettingToBackup];
        NSLog(@"EMAIL SETTING BACKUP: %@", dictEmailSetting);
        //Add to dictionary backup
        NSDictionary *dictDataBackup = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [NSString stringWithFormat:@"%@.0",backupVersion],kBACKUP_VERSION,
                                  dictEmailSetting, kBACKUP_EMAIL_SETTING,
                                  dictKeys,kBACKUP_KEYS, nil];
        //Generate backup to JSON
        NSString *JSONString = [ChatAdapter generateJSON:dictDataBackup];
        NSData *dataBinary = [JSONString dataUsingEncoding:NSUTF8StringEncoding];
        NSLog(@"JSON Backup Account = %@",JSONString);
        //Encrypt backup data
        NSData *binaryDataBK = [[AppFacade share] encryptDataLocally:dataBinary];
        //Store backup data to backup file
        NSString *fileName = [NSString stringWithFormat:@"%@.%@", [self getJid:YES], BACKUP_FILE_EXTENSION];
        
        if (!binaryDataBK) {
            NSLog(@"Binary backup data is null.");
            backupFileCallBack(NO,nil);
            return;
        }
        [[AccountAdapter share] setBackupFile:fileName data:binaryDataBK];
        
        backupFileCallBack(YES,dictDataBackup);
        
        NSLog(@"Backup account done");
        
    }
    @catch (NSException *exception) {
         NSLog(@"generateBackupFile exception : %@", exception.description);
    }
    
}

-(NSDictionary*)getKeysToBackup{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSMutableDictionary * dictKeys = [NSMutableDictionary new];
    [dictKeys setObject:[self getIMEI] forKey:kIMEI];
    [dictKeys setObject:[self getIMSI] forKey:kIMEI];
    [dictKeys setObject:[KeyChainSecurity getStringFromKey:kMOD1_PRIVATE] forKey:kMOD1_PRIVATE];
    [dictKeys setObject:[KeyChainSecurity getStringFromKey:kMOD1_EXPONENT] forKey:kMOD1_EXPONENT];
    [dictKeys setObject:[KeyChainSecurity getStringFromKey:kMOD1_MODULUS] forKey:kMOD1_MODULUS];
    [dictKeys setObject:[KeyChainSecurity getStringFromKey:kMOD2_PRIVATE] forKey:kMOD2_PRIVATE];
    [dictKeys setObject:[KeyChainSecurity getStringFromKey:kMOD2_EXPONENT] forKey:kMOD2_EXPONENT];
    [dictKeys setObject:[KeyChainSecurity getStringFromKey:kMOD2_MODULUS] forKey:kMOD2_MODULUS];
    [dictKeys setObject:[KeyChainSecurity getStringFromKey:kMOD3_PRIVATE] forKey:kMOD3_PRIVATE];
    [dictKeys setObject:[KeyChainSecurity getStringFromKey:kMOD3_EXPONENT] forKey:kMOD3_EXPONENT];
    [dictKeys setObject:[KeyChainSecurity getStringFromKey:kMOD3_MODULUS] forKey:kMOD3_MODULUS];
    
    [dictKeys setObject:[self getOwnKeyVersion] forKey:kVERSION];
    
    return dictKeys;

}

- (NSDictionary*) getEmailSettingToBackup {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    // get email setting
    MailAccount *mailAccount = [[EmailFacade share] getMailAccount:[[EmailFacade share] getEmailAddress]];
    
    NSMutableDictionary * dictEmailSetting = [NSMutableDictionary new];
    
    if (mailAccount) {
        @try {
            [dictEmailSetting setObject:[NSString stringWithFormat:@"%d", mailAccount.accountType.intValue] forKey:kEMAIL_ACCOUNT_TYPE];
            [dictEmailSetting setObject:mailAccount.fullEmail forKey:kEMAIL_ADDRESS];
            [dictEmailSetting setObject:mailAccount.displayName forKey:kEMAIL_DISPLAYNAME];
            
            [dictEmailSetting setObject:mailAccount.incomingHost forKey:kEMAIL_INC_HOST];
            [dictEmailSetting setObject:mailAccount.incomingUserName forKey:kEMAIL_INC_USENAME];
            [dictEmailSetting setObject:mailAccount.incomingPassword forKey:kEMAIL_INC_PASSWORD];
            [dictEmailSetting setObject:[NSString stringWithFormat:@"%d", mailAccount.incomingPort.intValue] forKey:kEMAIL_INC_PORT];
            [dictEmailSetting setObject:[NSString stringWithFormat:@"%d", mailAccount.incomingSecurityType.intValue] forKey:kEMAIL_INC_SECURITY_TYPE];
            [dictEmailSetting setObject:[NSString stringWithFormat:@"%d", mailAccount.incomingUseSSL.intValue] forKey:kEMAIL_INC_USE_SSL];
            
            [dictEmailSetting setObject:mailAccount.outgoingHost forKey:kEMAIL_OUT_HOST];
            [dictEmailSetting setObject:mailAccount.outgoingUserName forKey:kEMAIL_OUT_USENAME];
            [dictEmailSetting setObject:mailAccount.outgoingPassword forKey:kEMAIL_OUT_PASSWORD];
            [dictEmailSetting setObject:[NSString stringWithFormat:@"%d", mailAccount.outgoingPort.intValue] forKey:kEMAIL_OUT_PORT];
            [dictEmailSetting setObject:[NSString stringWithFormat:@"%d", mailAccount.outgoingSecurityType.intValue] forKey:kEMAIL_OUT_SECURITY_TYPE];
            [dictEmailSetting setObject:[NSString stringWithFormat:@"%d", mailAccount.outgoingRequireAuth.intValue] forKey:kEMAIL_OUT_REQUIRE_AUTH];
            
            [dictEmailSetting setObject:[NSString stringWithFormat:@"%d", mailAccount.pop3Deleteable] forKey:kEMAIL_POP3_DELETABLE];
            [dictEmailSetting setObject:[NSString stringWithFormat:@"%d", mailAccount.periodSyncSchedule.intValue] forKey:kEMAIL_PERIOD_SYNC_SCHEDULE];
            [dictEmailSetting setObject:[NSString stringWithFormat:@"%d", mailAccount.useNotify] forKey:kEMAIL_USE_NOTIFY];
            
            [dictEmailSetting setObject:mailAccount.incomingHost forKey:kEMAIL_SERVER_MICROSORT];
            [dictEmailSetting setObject:mailAccount.outgoingHost forKey:kEMAIL_DOMAIN_MICROSORT];
            [dictEmailSetting setObject:[NSString stringWithFormat:@"%d", mailAccount.emailKeeping.intValue] forKey:kEMAIL_KEEPING];
            [dictEmailSetting setObject:mailAccount.signature forKey:kEMAIL_SIGNATURE];
            [dictEmailSetting setObject:[NSString stringWithFormat:@"%d", mailAccount.useEncrypted] forKey:kEMAIL_USE_ENCRYPTED];
            
            //For android
            [dictEmailSetting setObject:mailAccount.storeProtocol forKey:kEMAIL_STORE_PROTOCOL];
            [dictEmailSetting setObject:[NSString stringWithFormat:@"%d", 1] forKey:kEMAIL_AUTO_DOWNLOAD_WIFI];
            [dictEmailSetting setObject:[NSString stringWithFormat:@"%d", 5000] forKey:kEMAIL_RETRIVAL_SIZE];
            
        }
        @catch (NSException *exception) {
             NSLog(@"getEmailSettingToBackup exception : %@", exception.description);
        }
    }
    return [dictEmailSetting copy];
}

- (void) setOwnKeyVersion:(NSString *)version{
    NSLog(@"%s : %@", __PRETTY_FUNCTION__, version);
    if ([self getJid:YES].length == 0)
        return;
    if (version.length == 0)
        return;
    NSString *key = [NSString stringWithFormat:@"%@%@", kVersionKeyFormat, [self getJid:YES]];
    [KeyChainSecurity storeString:version Key:key];
}

- (NSString*) getOwnKeyVersion{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    if ([self getJid:YES].length == 0)
        return @"";
    NSString *key = [NSString stringWithFormat:@"%@%@", kVersionKeyFormat, [self getJid:YES]];
    
    if ([KeyChainSecurity getStringFromKey:key]) {
        return [KeyChainSecurity getStringFromKey:key];
    }
    return @"";
}

-(void)uploadMasterKey{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    NSMutableData *masterKeyData = [[Base64Security decodeBase64String:[KeyChainSecurity getStringFromKey:kENC_MASTER_KEY]] mutableCopy];
    
    NSString *masterKeyUpload = [Base64Security generateBase64String:[masterKeyData copy]];
    
    if (!masterKeyUpload)
        return;
    
    NSMutableDictionary *backupParameter = [[NSMutableDictionary alloc] init];
    [backupParameter setObject:PUT forKey:kAPI_REQUEST_METHOD];
    [backupParameter setObject:NORMAL forKey:kAPI_REQUEST_KIND];
    [backupParameter setObject:[self getMaskingId] forKey:kMASKINGID];
    [backupParameter setObject:[self getTokentTenant] forKey:kTOKEN];
    [backupParameter setObject:[self getIMEI] forKey:kIMEI];
    [backupParameter setObject:[self getIMSI] forKey:kIMSI];
    [backupParameter setObject:masterKeyUpload forKey:kMASTERKEY];
    [backupParameter setObject:[self getPasscode] forKey:kPASSWORD];
    
    [[AccountAdapter share] updatePasswordBackupFile:backupParameter callback:^(BOOL success, NSString *message, NSDictionary *response, NSError *error) {
        
        if ([[AppFacade share] preProcessResponse:response])
            return ;
        
        if (success) {
            [KeyChainSecurity storeString:_YES Key:kIS_UPDATED_PASS_BACKUP_FILE];//This flag is used for re-update if it failed
        }
        else{
            [KeyChainSecurity storeString:_NO Key:kIS_UPDATED_PASS_BACKUP_FILE];
             if (response){
                // if Token is invalid or expire
                NSInvocationOperation* operation=  [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(uploadMasterKey) object:nil];
                NSDictionary* retryDictionary = @{kRETRY_OPERATION:operation,
                                                  kRETRY_TIME:kRETRY_API_COUNTER,
                                                  kSTATUS_CODE : [response objectForKey:kSTATUS_CODE]};
                [[AppFacade share] downloadTokenAgain:retryDictionary];
             }
        }
        
    }];
}

- (void)restoreProfile{
    
    NSMutableDictionary *backupParameter = [[NSMutableDictionary alloc] init];
    [backupParameter setObject:PUT forKey:kAPI_REQUEST_METHOD];
    [backupParameter setObject:NORMAL forKey:kAPI_REQUEST_KIND];
    [backupParameter setObject:[self getMaskingId] forKey:kMASKINGID];
    [backupParameter setObject:[self getTokentTenant] forKey:kTOKEN];
    [backupParameter setObject:[self getIMEI] forKey:kIMEI];
    [backupParameter setObject:[self getIMSI] forKey:kIMSI];
    [backupParameter setObject:[self getPasscode] forKey:kPASSWORD];
    
    [[AccountAdapter share] getPasswordBackupFile:backupParameter callback:^(BOOL success, NSString *message, NSDictionary *response, NSError *error) {
        NSLog(@"%s %@", __PRETTY_FUNCTION__, response);
        if ([[AppFacade share] preProcessResponse:response])
            return;
        
        if (success) {
            NSData *masterkeyRespone = [Base64Security decodeBase64String:[response objectForKey:kMASTERKEY]];
            if (masterkeyRespone)
                [KeyChainSecurity storeString:[Base64Security generateBase64String:masterkeyRespone] Key:kENC_MASTER_KEY];
            //Download backup file
            [self downloadBackupFile];
            
        }
        else{
            if (response){
                NSInvocationOperation* operation=  [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(restoreProfile) object:nil];
                NSDictionary* retryDictionary = @{kRETRY_OPERATION:operation,
                                                  kRETRY_TIME:kRETRY_API_COUNTER,
                                                  kSTATUS_CODE : [response objectForKey:kSTATUS_CODE]};
                [[AppFacade share] downloadTokenAgain:retryDictionary];
            }
        }
    }];
}

-(void)downloadBackupFile{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    NSMutableDictionary *backupParameter = [[NSMutableDictionary alloc] init];
    [backupParameter setObject:PUT forKey:kAPI_REQUEST_METHOD];
    [backupParameter setObject:DOWNLOAD forKey:kAPI_REQUEST_KIND];
    [backupParameter setObject:[self getMaskingId] forKey:kMASKINGID];
    [backupParameter setObject:[self getTokentTenant] forKey:kTOKEN];
    [backupParameter setObject:[self getIMEI] forKey:kIMEI];
    [backupParameter setObject:[self getIMSI] forKey:kIMSI];
    [backupParameter setObject:[self getPasscode] forKey:kPASSWORD];
    
    [[AccountAdapter share] backupFileDownload:backupParameter callback:^(BOOL success, NSString *message, NSDictionary *response, NSError *error) {
        //NSLog(@"%s RESPONSE DOWNLOAD: %@", __PRETTY_FUNCTION__, response);
        
        if ([[AppFacade share] preProcessResponse:response])
            return ;
        
        if (success) {
            NSLog(@"Download backup file successfully.");
            
            if (response) {
                NSLog(@"RESPONSE Backupfile Data: %@",[response objectForKey:kRESPONSE_DATA]);
                if (![response objectForKey:kRESPONSE_DATA]) {
                    NSLog(@"RESPONSE BACKUP FILE DATA NULL");
                    return ;
                }
                
                NSData* binaryData =  [[AppFacade share] decryptDataLocally:[response objectForKey:kRESPONSE_DATA]];
                
                if (!binaryData) {
                    return;
                }
                
                NSString *decodedString = [[NSString alloc] initWithData:binaryData encoding:NSUTF8StringEncoding];
                
                NSDictionary *jsonDic = [ChatAdapter decodeJSON:decodedString];
                
                [self restoreProfileData:jsonDic];
                
                 NSLog(@"JSON Restore Account = %@",decodedString);
                
                [KeyChainSecurity storeString:_YES Key:kIS_RESTORE_ACCOUNT];
            }else{
                NSLog(@"Response download backup file null.");
            }
            
            
        }else{
            NSLog(@"Download backup file failed.");
            
            [KeyChainSecurity storeString:_NO Key:kIS_RESTORE_ACCOUNT];
        }
        
        //Restore group chat
        if ([[ContactFacade share] getReloginFlag])
            [[ChatFacade share] getChatRoom:@"" forJoin:YES];
        
    }];
    
}

-(void) restoreProfileData:(NSDictionary*)dataDic{
    NSLog(@"%s %@", __PRETTY_FUNCTION__, dataDic);
    if(!dataDic)
        return;
    NSString *backupVersion = [dataDic objectForKey:kBACKUP_VERSION];
    NSDictionary *keyPairs = [dataDic objectForKey:kBACKUP_KEYS];
    NSDictionary *emailSettings = [dataDic objectForKey:kBACKUP_EMAIL_SETTING];
    NSLog(@"EMAIL SETTING RESTORE: %@", emailSettings);
    //Restore backup file version
    NSArray* arrVersion =  [backupVersion componentsSeparatedByString:@"."];
    if ([arrVersion count] == 2) {
        [KeyChainSecurity storeString:arrVersion[0] Key:kBACKUP_FILE_VERSION];
    } else {
        [KeyChainSecurity storeString:@"1" Key:kBACKUP_FILE_VERSION];
    }
    //Restore keys
    [KeyChainSecurity storeString:[keyPairs objectForKey:kMOD1_PRIVATE] Key:kMOD1_PRIVATE];
    [KeyChainSecurity storeString:[keyPairs objectForKey:kMOD1_EXPONENT] Key:kMOD1_EXPONENT];
    [KeyChainSecurity storeString:[keyPairs objectForKey:kMOD1_MODULUS] Key:kMOD1_MODULUS];
    [KeyChainSecurity storeString:[keyPairs objectForKey:kMOD2_PRIVATE] Key:kMOD2_PRIVATE];
    [KeyChainSecurity storeString:[keyPairs objectForKey:kMOD2_EXPONENT] Key:kMOD2_EXPONENT];
    [KeyChainSecurity storeString:[keyPairs objectForKey:kMOD2_MODULUS] Key:kMOD2_MODULUS];
    [KeyChainSecurity storeString:[keyPairs objectForKey:kMOD3_PRIVATE] Key:kMOD3_PRIVATE];
    [KeyChainSecurity storeString:[keyPairs objectForKey:kMOD3_EXPONENT] Key:kMOD3_EXPONENT];
    [KeyChainSecurity storeString:[keyPairs objectForKey:kMOD3_MODULUS] Key:kMOD3_MODULUS];
    
    [self setOwnKeyVersion:[keyPairs objectForKey:kVERSION]];
    
    //Restore MailAccount
    if (emailSettings.count > 0) {
        [[EmailFacade share] createDefaultEmailFolders];
        
        [KeyChainSecurity storeString:[emailSettings objectForKey:kEMAIL_ADDRESS] Key:kEMAIL_ADDRESS];
         MailAccount *mailAccount = [[EmailFacade share] getMailAccount:[[EmailFacade share] getEmailAddress]];
        
        if (!mailAccount) {
            mailAccount = [MailAccount new];
        }
        mailAccount.fullEmail = [emailSettings objectForKey:kEMAIL_ADDRESS];
        mailAccount.accountType = [emailSettings objectForKey:kEMAIL_ACCOUNT_TYPE];
        mailAccount.displayName = [emailSettings objectForKey:kEMAIL_DISPLAYNAME];
        mailAccount.incomingHost = [emailSettings objectForKey:kEMAIL_INC_HOST];
        mailAccount.incomingUserName = [emailSettings objectForKey:kEMAIL_INC_USENAME];
        mailAccount.incomingPassword = [emailSettings objectForKey:kEMAIL_INC_PASSWORD];
        mailAccount.incomingPort = [emailSettings objectForKey:kEMAIL_INC_PORT];
        mailAccount.incomingSecurityType = [emailSettings objectForKey:kEMAIL_INC_SECURITY_TYPE];
        mailAccount.outgoingHost = [emailSettings objectForKey:kEMAIL_OUT_HOST];
        mailAccount.outgoingUserName = [emailSettings objectForKey:kEMAIL_OUT_USENAME];
        mailAccount.outgoingPassword = [emailSettings objectForKey:kEMAIL_OUT_PASSWORD];
        mailAccount.outgoingPort = [emailSettings objectForKey:kEMAIL_OUT_PORT];
        mailAccount.pop3Deleteable = [[emailSettings objectForKey:kEMAIL_POP3_DELETABLE] boolValue];
        mailAccount.periodSyncSchedule = [emailSettings objectForKey:kEMAIL_PERIOD_SYNC_SCHEDULE];
        mailAccount.useNotify = [[emailSettings objectForKey:kEMAIL_USE_NOTIFY] boolValue];
        mailAccount.incomingUseSSL = [emailSettings objectForKey:kEMAIL_INC_USE_SSL];
        mailAccount.outgoingRequireAuth = [emailSettings objectForKey:kEMAIL_OUT_REQUIRE_AUTH];
        mailAccount.outgoingSecurityType = [emailSettings objectForKey:kEMAIL_OUT_SECURITY_TYPE];
        mailAccount.emailKeeping = [emailSettings objectForKey:kEMAIL_KEEPING];
        mailAccount.signature = [emailSettings objectForKey:kEMAIL_SIGNATURE];
        mailAccount.useEncrypted = [[emailSettings objectForKey:kEMAIL_USE_ENCRYPTED] boolValue];
        mailAccount.password = [emailSettings objectForKey:kEMAIL_INC_PASSWORD];
        mailAccount.extend1 = [emailSettings objectForKey:kEMAIL_DESCRIPTION];
        if ([[emailSettings objectForKey:kEMAIL_ACCOUNT_TYPE] intValue] == 0) {
            mailAccount.incomingHost = [emailSettings objectForKey:kEMAIL_SERVER_MICROSORT];
            mailAccount.outgoingHost = [emailSettings objectForKey:kEMAIL_DOMAIN_MICROSORT];
        }
        
        [[EmailFacade share] updateMailAccount:mailAccount];
        
        [KeyChainSecurity storeString:[emailSettings objectForKey:kEMAIL_ADDRESS] Key:kEMAIL_ADDRESS];
        
        [KeyChainSecurity storeString:_YES Key:kIS_LOGGED_IN_EMAIL];//Set flag login email to YES, so user click on Menu will navigate to Inbox
    }
    //Update owner info
    NSString *ownerJid = [self getJid:YES];
    [self updateContactInfo:ownerJid];
    
    //get account detail
    [self getDetailAccount];
    
    //Restore Contact here
    [self restoreContact:STATUS_APPROVED_AND_PENDING_AND_RECEIVED];
    
}

#pragma mark - Backup/Restore Contact functions -
/*
 *  Description: backup contact
 *  @param status: status of friend. APPROVED/ PENDING /RECEIVED
 *  @param fullJid :full jid of friend
 *  Author: Parker
 */
- (void) backupContact:(NSString*)fullJid friendStatus:(NSString*)status{
    NSLog(@"%s %@ %ld", __PRETTY_FUNCTION__, fullJid, (long)status);
    
    if (fullJid.length == 0)
        return;
    
    if (status.length == 0)
        return;
    
    NSString *version = [NSString stringWithFormat:@"%f", [[NSDate date] timeIntervalSince1970]];
    
    NSMutableDictionary *dictData = [NSMutableDictionary new];
    //BK Contact info
    Contact *contactObj = [self getContact:fullJid];
    if (!contactObj) {
        NSLog(@"backup contact does not exist");
        return;
    }
    
    [dictData setValue:contactObj.jid ? contactObj.jid : @"" forKey:kCONTACT_JID];
    [dictData setValue:contactObj.maskingid ? contactObj.maskingid : @"" forKey:kCONTACT_MASKINGID];
    [dictData setValue:contactObj.customerName ? contactObj.customerName : @"" forKey:kCONTACT_CUSTOMER_NAME];
    [dictData setValue:contactObj.statusMsg ? contactObj.statusMsg : @"" forKey:kCONTACT_STATUS_MSG];
    [dictData setValue:contactObj.serverMSISDN ? contactObj.serverMSISDN : @"" forKey:kCONTACT_SERVER_MSISDN];
    [dictData setValue:contactObj.contactType ? contactObj.contactType : @"" forKey:kCONTACT_CONTACT_TYPE];
    [dictData setValue:contactObj.contactState ? contactObj.contactState : @"" forKey:kCONTACT_CONTACT_STATE];

    //BK Contact keys
    Key* key = [[AppFacade share] getKey:fullJid];
    if(!key || !key.keyJSON){
        NSLog(@"No Key available for jid %@", fullJid);
    }
    
    if (key.keyJSON) {
        NSData* keyData = [Base64Security decodeBase64String:key.keyJSON];
        if (keyData)
            key.keyJSON = [[NSString alloc] initWithData:[[AppFacade share] decryptDataLocally:keyData]
                                                encoding:NSUTF8StringEncoding];
    }

    NSDictionary * dicKey = [NSDictionary dictionaryWithDictionary:[ChatAdapter decodeJSON:key.keyJSON]];
    
    [dictData setValue:dicKey forKey:kKEY_KEY_JSON];
    [dictData setValue:key.keyVersion ? key.keyVersion : @"" forKey:kKEY_KEY_VERSION];
    //BK request
    Request *requestObj = [self getRequest:fullJid];
    
    [dictData setValue:requestObj.requestType ? requestObj.requestType : @"" forKey:kREQUEST_REQUEST_TYPE];
    [dictData setValue:requestObj.content ? requestObj.content : @"" forKey:kREQUEST_CONTENT];
    [dictData setValue:requestObj.status ? requestObj.status : @"" forKey:kREQUEST_STATUS];
    
    //Encrypt data
    NSString *jsonString = [ChatAdapter generateJSON:dictData];
    NSLog(@"Data json backup contact: %@", jsonString);
    NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    data =  [[AppFacade share] encryptDataLocally:data];
    NSString *encrytedBase64String = [Base64Security generateBase64String:data];
    
    if(!encrytedBase64String.length > 0)
        return;
    
    //Parameters API
    NSMutableDictionary *backupParameter = [[NSMutableDictionary alloc] init];
    [backupParameter setObject:PUT forKey:kAPI_REQUEST_METHOD];
    [backupParameter setObject:NORMAL forKey:kAPI_REQUEST_KIND];
    [backupParameter setObject:[self getMaskingId] forKey:kMASKINGID];
    [backupParameter setObject:[self getTokentTenant] forKey:kTOKEN];
    [backupParameter setObject:[self getIMEI] forKey:kIMEI];
    [backupParameter setObject:[self getIMSI] forKey:kIMSI];
    [backupParameter setObject:UPDATE forKey:kCMD];
    [backupParameter setObject:status forKey:kSTATUS];
    [backupParameter setObject:contactObj.maskingid forKey:kFRIEND_MASKING_ID];
    [backupParameter setObject:encrytedBase64String forKey:kDATA];
    [backupParameter setObject:version forKey:kVERSION];
    
    [[AccountAdapter share] backupContact:backupParameter callback:^(BOOL success, NSString *message, NSDictionary *response, NSError *error) {
        
        if ([[AppFacade share] preProcessResponse:response])
            return ;
        
        if (success) {
            NSLog(@"Backup contact for jid '%@' successfully", fullJid);
            
            contactObj.extend1 = [NSString stringWithFormat:@"%d",1]; // backup success.
            [[DAOAdapter share] commitObject:contactObj];
            
        }else{
            NSLog(@"Backup contact for jid '%@' failed", fullJid);
            
            contactObj.extend1 = [NSString stringWithFormat:@"%d",0];// backup failed. Used to call backup again
            [[DAOAdapter share] commitObject:contactObj];
            if (response){
                // if Token is invalid or expire
                NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
                    [self backupContact:fullJid friendStatus:status];
                }];
            
                NSDictionary* retryDictionary = @{kRETRY_OPERATION:operation,
                                                  kRETRY_TIME:kRETRY_API_COUNTER,
                                                  kSTATUS_CODE : [response objectForKey:kSTATUS_CODE]};
                [[AppFacade share] downloadTokenAgain:retryDictionary];
             }
        }
    }];
    
}

/*
 *  Description: restore contact
 *  @param status: status of friend. 100 - APPROVED list 010 - PENDING list 001 - RECEIVED list 110 - APPROVED and PENDING list
 *  Author: Parker
 */
- (void) restoreContact:(NSString*)status{
    NSLog(@"%s %ld", __PRETTY_FUNCTION__, (long)status);
    
    if (status.length == 0)
        return;
    
    //Parameters API
    NSMutableDictionary *backupParameter = [[NSMutableDictionary alloc] init];
    [backupParameter setObject:PUT forKey:kAPI_REQUEST_METHOD];
    [backupParameter setObject:NORMAL forKey:kAPI_REQUEST_KIND];
    [backupParameter setObject:[self getMaskingId] forKey:kMASKINGID];
    [backupParameter setObject:[self getTokentTenant] forKey:kTOKEN];
    [backupParameter setObject:[self getIMEI] forKey:kIMEI];
    [backupParameter setObject:[self getIMSI] forKey:kIMSI];
    [backupParameter setObject:GET forKey:kCMD];
    [backupParameter setObject:status forKey:kSTATUS];
    
    [[CWindow share] showLoading:kLOADING_LOADING];
    [[AccountAdapter share] restoreContact:backupParameter callback:^(BOOL success, NSString *message, NSDictionary *response, NSError *error) {
        NSLog(@"%s: %@",__PRETTY_FUNCTION__, response);
        [[CWindow share] hideLoading];
        if ([[AppFacade share] preProcessResponse:response])
            return;
        if (success) {
            NSArray *objectsDic = [response objectForKey:kDATA];
            if (objectsDic.count > 0){
                for (NSDictionary *contactDic in objectsDic) {
                    NSDictionary *contactInfo;
                    NSString *contactString = [contactDic objectForKey:@"data"];
                    if ([[contactDic objectForKey:@"status"] isEqualToString:APPROVED])
                        contactInfo = [self decryptContactInfomation:contactString];
                    else if ([[contactDic objectForKey:@"status"] isEqualToString:PENDING])
                        contactInfo = [self decryptContactInfomation:contactString];
                    else if ([[contactDic objectForKey:@"status"] isEqualToString:RECEIVED])
                       contactInfo = [self decryptContactInfomation:contactString];
                    [self restoreContactInfoToDatabase:contactInfo];
                }
                [self loadContactRequest];
            }
            
            [KeyChainSecurity storeString:_YES Key:kIS_RESTORED_ALL_CONTACT];
            //Call get sync blocked contact list
            [self synchronizeBlockList:@"" action:GET];
        }
        else{
            [KeyChainSecurity storeString:_NO Key:kIS_RESTORED_ALL_CONTACT];// Used to re-call restore contact in case failed
             if (response){
                 NSInvocationOperation* operation=  [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(restoreContact:) object:status];
            
                 NSDictionary* retryDictionary = @{kRETRY_OPERATION:operation,
                                              kRETRY_TIME:kRETRY_API_COUNTER,
                                              kSTATUS_CODE : [response objectForKey:kSTATUS_CODE]};
                 [[AppFacade share] downloadTokenAgain:retryDictionary];
             }
        }
    }];

}

- (NSDictionary *)decryptContactInfomation:(NSString *)encryptedString
{
    NSLog(@"%s: %@", __PRETTY_FUNCTION__, encryptedString);
    
    NSDictionary *contactDic = nil;
    NSArray* arrContent = [encryptedString componentsSeparatedByString:@"WHWHWHW"];
    NSString *jsonString = [arrContent objectAtIndex:0];
    if (jsonString) {
        NSData* data =  [[AppFacade share] decryptDataLocally:[Base64Security decodeBase64String:jsonString]];
        if (data) {
            NSString *decryptedDataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            contactDic = [ChatAdapter decodeJSON:decryptedDataString];
        }
    }
    return contactDic;
}

-(void)restoreContactInfoToDatabase:(NSDictionary*)contactDic{
    NSLog(@"%s %@", __PRETTY_FUNCTION__, contactDic);
    if (!contactDic)
        return;
    Contact *contactObj = [self getContact:[contactDic objectForKey:kCONTACT_JID]];
    if (!contactObj) {
        contactObj = [Contact new];
        contactObj.jid = [contactDic objectForKey:kCONTACT_JID];
        contactObj.maskingid = [contactDic objectForKey:kCONTACT_MASKINGID];
    }
    contactObj.customerName = [contactDic objectForKey:kCONTACT_CUSTOMER_NAME];
    contactObj.statusMsg = [contactDic objectForKey:kCONTACT_STATUS_MSG];
    contactObj.serverMSISDN = [contactDic objectForKey:kCONTACT_SERVER_MSISDN];
    contactObj.contactType = [contactDic objectForKey:kCONTACT_CONTACT_TYPE];
    contactObj.contactState = [contactDic objectForKey:kCONTACT_CONTACT_STATE];
    
    [[DAOAdapter share] commitObject:contactObj];
    
    NSDictionary *dicKey = [contactDic objectForKey:kKEY_KEY_JSON];
    
    if (dicKey && [dicKey count] > 0) {
        Key* key = [[AppFacade share] getKey:[contactDic objectForKey:kCONTACT_JID]];
        if(!key){
            key = [Key new];
             key.keyId = [contactDic objectForKey:kCONTACT_JID];
        }
        
        key.keyJSON = [ChatAdapter generateJSON:dicKey];
        if (key.keyJSON) {
            NSData* keyData = [[AppFacade share] encryptDataLocally:[key.keyJSON dataUsingEncoding:NSUTF8StringEncoding]];
            if (keyData)
                key.keyJSON = [Base64Security generateBase64String:keyData];
        }
        key.keyVersion = [contactDic objectForKey:kKEY_KEY_VERSION];
        
        [[DAOAdapter share] commitObject:key];
    }
    
    //BK request
    Request *requestObj = [self getRequest:[contactDic objectForKey:kCONTACT_JID]];
    
    if(!requestObj){
        requestObj = [Request new];
        requestObj.requestJID = [contactDic objectForKey:kCONTACT_JID];
    }
    
    requestObj.requestType = [contactDic objectForKey:kREQUEST_REQUEST_TYPE];
    requestObj.content = [contactDic objectForKey:kREQUEST_CONTENT];
    requestObj.status = [contactDic objectForKey:kREQUEST_STATUS];
    
    NSString *requestType = [NSString stringWithFormat:@"%@", [contactDic objectForKey:kREQUEST_REQUEST_TYPE]];
    
    //request type is nil no need to save
    if (requestType != nil && ![requestType isEqual:STRING_EMPTY]) { // prevent crash
        [[DAOAdapter share] commitObject:requestObj];
    }
    //Update contact info. Avatar..
    [self updateContactInfo:[contactDic objectForKey:kCONTACT_JID]];
}

#pragma mark - Common functions -
-(NSString*)getDeviceName{
    return [[ProfileAdapter share] getDeviceName];
}

-(NSString*)getDeviceVersion{
   return [[ProfileAdapter share] getDeviceVersion];
}

-(NSString*)getDeviceModel{
    return [[ProfileAdapter share] getDeviceModel];
}

-(NSString*)getJid:(BOOL)withHost{
    NSString *jid = [KeyChainSecurity getStringFromKey:kJID];
    if(jid.length == 0)
        return @"";
    if (withHost)
        jid = [jid stringByAppendingFormat:@"@%@", [KeyChainSecurity getStringFromKey:kJID_HOST]];
    return jid;
}

-(NSString*)getMaskingId{
    if ([KeyChainSecurity getStringFromKey:kMASKINGID])
        return [KeyChainSecurity getStringFromKey:kMASKINGID];
    return @"";
}

-(NSString*) getPasscode{
    if( [KeyChainSecurity getStringFromKey:kPASSWORD])
        return [KeyChainSecurity getStringFromKey:kPASSWORD];
    return @"";
}

-(NSString*) getTokentTenant{
    if ([KeyChainSecurity getStringFromKey:kTENANTTOKEN])
        return [KeyChainSecurity getStringFromKey:kTENANTTOKEN];
    return @"";
}

-(NSString*) getTokentCentral{
    if ([KeyChainSecurity getStringFromKey:kCENTRALTOKEN])
        return [KeyChainSecurity getStringFromKey:kCENTRALTOKEN];
    return @"";
}

-(void)setPasscode:(NSString*) passcode{
    [KeyChainSecurity storeString:passcode Key:kPASSWORD];
}

-(BOOL)comparePasscode:(NSString*)passcode{
    NSString* hash256Passcode = [AESSecurity hashSHA256:passcode];
    return [hash256Passcode isEqualToString:[KeyChainSecurity getStringFromKey:kPASSWORD]];
}

-(NSString*)getAccountStatus{
    return [KeyChainSecurity getStringFromKey:kACCOUNT_STATUS];
}

-(void)setValue:(NSString*)value forKey:(NSString*)key{
    [KeyChainSecurity storeString:value Key:key];
}

-(BOOL)getRegisterFlag{
   NSString *registerFlag = [KeyChainSecurity getStringFromKey:kIS_REGISTER];
    return [registerFlag isEqualToString:IS_YES];
}

-(BOOL)getSyncContactFlag{
    NSString *syncFlag =  [KeyChainSecurity getStringFromKey:kIS_SYNC_CONTACT];
    return [syncFlag isEqualToString:IS_YES];
}

-(BOOL)getFreeTrialedFlag{
    NSString *freeFlag =  [KeyChainSecurity getStringFromKey:kIS_FREE_TRIAL];
    return [freeFlag isEqualToString:IS_YES];
}

-(BOOL)getBackupProfileFlag{
    NSString *backupFlag =  [KeyChainSecurity getStringFromKey:kIS_BACKUP_ACCOUNT];
    return [backupFlag isEqualToString:IS_YES];
}

-(BOOL)getReloginFlag{
    NSString *reloginFlag =  [KeyChainSecurity getStringFromKey:kIS_RE_LOGIN_ACCOUNT];
    return [reloginFlag isEqualToString:IS_YES];
}

-(BOOL)getRestoreProfileFlag{
    NSString *restoreFlag =  [KeyChainSecurity getStringFromKey:kIS_RESTORE_ACCOUNT];
    return [restoreFlag isEqualToString:IS_YES];
}

-(BOOL)getUpdateMasterKeyFlag{
    NSString *masterKeyFlag =  [KeyChainSecurity getStringFromKey:kIS_UPDATED_PASS_BACKUP_FILE];
    return [masterKeyFlag isEqualToString:IS_YES];
}

-(BOOL)getRestoreContactFlag{
    NSString *restoreContactFlag =  [KeyChainSecurity getStringFromKey:kIS_RESTORED_ALL_CONTACT];
    return [restoreContactFlag isEqualToString:IS_YES];
}

-(void)setTermAndConditionFlag:(NSString *)value{
    [KeyChainSecurity storeString:value Key:kIS_ACCEPTED_TERM_AND_CONDITION];
}

-(BOOL)getTermAndConditionFlag{
    NSString *termAndCondition =  [KeyChainSecurity getStringFromKey:kIS_ACCEPTED_TERM_AND_CONDITION];
    return [termAndCondition isEqualToString:IS_YES];
}

//My Profile
-(NSString*)getDisplayName{
    return [[ProfileAdapter share] getProfileName];
}

-(NSString*)getProfileStatus{
    return [[ProfileAdapter share] getProfileStatus];
}

- (void)setProfileStatus:(NSString *)statusString
{
    // arpana added to resolve bug id 9228
  if(! [[NotificationFacade share] isInternetConnected])
  {
      [[CAlertView new] showError:NSLocalizedString(ERROR_CANNOT_UPDATE_STATUS_OFFLINE_TRY_AGAIN,nil)];
      return;
  }
    [[CWindow share] showLoading:kLOADING_UPDATING];
    [[XMPPAdapter share] setStatusMessage:statusString callback:^(BOOL success, NSString *message, NSDictionary *response, NSError *error) {
        NSDictionary *logDic;
        [[CWindow share] hideLoading];
        if (success) {
            [[ProfileAdapter share] setProfileStatus:statusString];
            [statusProfileDelegate cancelStatusView];
            logDic = @{
                       LOG_CLASS : NSStringFromClass(self.class),
                       LOG_CATEGORY: CATEGORY_PROFILE_CHANGE_STATUS,
                       LOG_MESSAGE: [NSString stringWithFormat:@"PROFILE CHANGE STATUS SUCCESS: STATUS: %@, Response: %@",statusString,response],
                       LOG_EXTRA1: @"",
                       LOG_EXTRA2: @""
                       };
            [[LogFacade share] logErrorWithDic:logDic];
        } else {
            [[CAlertView new] showError:message];
            logDic = @{
                       LOG_CLASS : NSStringFromClass(self.class),
                       LOG_CATEGORY: CATEGORY_PROFILE_CHANGE_STATUS,
                       LOG_MESSAGE: [NSString stringWithFormat:@"SYNC CONTACT FAIL: Response: %@, ERROR: %@",response,error],
                       LOG_EXTRA1: @"",
                       LOG_EXTRA2: @""
                       };
            [[LogFacade share] logErrorWithDic:logDic];
        }
    }];
}

-(NSString*)getXmppHostName{
    return [KeyChainSecurity getStringFromKey:kHOST];
}

-(NSString*)getXmppMUCHostName{
    return [KeyChainSecurity getStringFromKey:kHOSTMUC];
}

-(NSString*)getIMEI{
    return [KeyChainSecurity getStringFromKey:kIMEI];
}

-(NSString*)getIMSI{
    return [KeyChainSecurity getStringFromKey:kIMSI];
}

-(void)storeIMSIAndIMEI{
    if (![KeyChainSecurity getStringFromKey:kIMEI]) {
        [KeyChainSecurity storeString:[self getIMEIOfDevice] Key:kIMEI];
    }
    if (![KeyChainSecurity getStringFromKey:kIMSI]) {
        [KeyChainSecurity storeString:[self generateUDID] Key:kIMSI];
    }
}

-(NSString*)getIMEIOfDevice{
    return [[ProfileAdapter share] getIMEIOfDevice];
}

-(NSString*)generateUDID{
    return [[ProfileAdapter share] generateUDID];
}

-(NSString*) getTimeZone
{
    return [[ProfileAdapter share] getTimeZone];
}

-(BOOL) blockContact:(NSString*) fullJID{
    Contact* contact = [self getContact:fullJID];
    contact.contactState = [NSNumber numberWithInt:kCONTACT_STATE_BLOCKED];
    BOOL result = [[DAOAdapter share] commitObject:contact];
    if (result){
        [chatViewDelegate displaySingleStatus];
        [contactInfoDelegate buildView];
        [self loadFriendArray];
        [self loadBlockedUsersArray];
        
    }
    return result;
}

-(BOOL) unblockContact:(NSString*) fullJID{
    [[XMPPFacade share] sendLastActivityQueryToJID:fullJID];
    
    BOOL result = FALSE;
    Contact* contact = [self getContact:fullJID];
    if([contact.contactState integerValue] == kCONTACT_STATE_BLOCKED){
        contact.contactState = [NSNumber numberWithInt:kCONTACT_STATE_OFFLINE];
        result = [[DAOAdapter share] commitObject:contact];
    }
    
    if (result){
        [chatViewDelegate displaySingleStatus];
        [contactInfoDelegate buildView];
        [self loadFriendArray];
        [self loadBlockedUsersArray];
    }
    return result;
}

-(void) callContactUpdateDelegate{
    //Call delegate to update info.
    [contactSearchMIDDelegate refreshSearchResult];
    [contactPopupDelegate displayInfo];
    [self loadFriendArray];
    [chatViewDelegate displayName];
    [contactBookDelegate updateContactInfoSuccess];
    [[ChatFacade share] reloadChatBoxList];
    [notificationListDelegate reloadNotificationPage];
}

-(void) updateContactInfo:(NSString*) fullJID{
    NSOperationQueue *updateContactOperation = [[NSOperationQueue alloc] init];
    [updateContactOperation addOperationWithBlock:^{
        NSString* JID = [[fullJID componentsSeparatedByString:@"@"] objectAtIndex:0];
        if(JID.length == 0)
            return;
        
        NSDictionary *getFriendvCard = @{kAPI_REQUEST_METHOD: POST,
                                         kAPI_REQUEST_KIND: NORMAL,
                                         kMASKINGID: [self getMaskingId],
                                         kTOKEN: [self getTokentTenant],
                                         kJID: JID,
                                         kHOST: [self getXmppHostName],
                                         kIMSI: [self getIMSI],
                                         kIMEI: [self getIMEI]
                                         };
        
        [[ContactAdapter share] getFriendvCard:getFriendvCard callback:^(BOOL success, NSString *message, NSDictionary *response, NSError *error){
            
            if ([[AppFacade share] preProcessResponse:response])
                return ;
            
            if (success) {
                NSDictionary* contactInfo = [[XMPPAdapter share] parsevCardInfoFromXMLString:[response objectForKey:kVCARD]];
                NSLog(@"%s: SUCCESSED", __PRETTY_FUNCTION__);
                //NSLog(@"%s updateContactInfo %@", __PRETTY_FUNCTION__, contactInfo);
                if ([[contactInfo objectForKey:kXMPP_USER_MASKING_ID] isEqualToString:[self getMaskingId]]) {
                    //Owner info
                    NSData* avatarData = [contactInfo objectForKey:kAVATAR_IMAGE_DATA];
                    if (avatarData){
                        NSOperationQueue *ownerOperation = [[NSOperationQueue alloc] init];
                        [ownerOperation addOperationWithBlock:^{
                            NSData* imageDataBlockEncrypt = [[AppFacade share] encryptDataLocally:avatarData];
                            [[ProfileAdapter share] setProfileAvatar:imageDataBlockEncrypt];
                        }];
                    }
                    return;
                }
                Contact* contact = [self getContact:fullJID];
                if (contact) {
                    NSData* avatarData = [contactInfo objectForKey:kAVATAR_IMAGE_DATA];
                    if (avatarData) {
                        [[ContactAdapter share] setContactAvatar:fullJID
                                                            data:[[AppFacade share] encryptDataLocally:avatarData]];
                        contact.avatarURL = fullJID;
                    }
                    NSString* serversideName = [[NSString alloc] initWithData:[Base64Security decodeBase64String:[contactInfo objectForKey:kXMPP_USER_DISPLAYNAME]] encoding:NSUTF8StringEncoding];
                    contact.serversideName = serversideName;
                    NSString *email = [contactInfo objectForKey:kXMPP_USER_EMAIL];
                    contact.email = email;
                    [[DAOAdapter share]commitObject:contact];
                    [self callContactUpdateDelegate];
                }

            }
            else{
                NSLog(@"%s:FAILED", __PRETTY_FUNCTION__);
                // if Token is invalid or expire
                 if (response){
                    NSInvocationOperation* operation=  [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(updateContactInfo:) object:fullJID];
                    NSDictionary* retryDictionary = @{kRETRY_OPERATION:operation,kRETRY_TIME:kRETRY_API_COUNTER,
                                                      kSTATUS_CODE : [response objectForKey:kSTATUS_CODE]};
                    [[AppFacade share] downloadTokenAgain:retryDictionary];
                 }
            }
        }];
    }];
}

-(void) deleteFriend:(NSString*)contactJid{
    Contact* contact = [self getContact:contactJid];
    
    
    if (!contact) {
        NSLog(@"Contact jid %@ is not exist in database.", contactJid);
        return;
    }
    
    NSDictionary *removeContactDic = @{kAPI_REQUEST_METHOD: POST,
                                     kAPI_REQUEST_KIND: NORMAL,
                                     kMASKINGID: [self getMaskingId],
                                     kTOKEN: [self getTokentTenant],
                                     kCENTRALTOKEN: [self getTokentCentral],
                                     kIMSI: [self getIMSI],
                                     kIMEI: [self getIMEI],
                                     kFRIEND_MASKING_ID: contact.maskingid
                                     };
    [[CWindow share] showLoading:kLOADING_DELETING];
    [[ContactAdapter share] removeFriendByMaskingId:removeContactDic callback:^(BOOL success, NSString *message, NSDictionary *response, NSError *error){
        [[CWindow share] hideLoading];
        
        if ([[AppFacade share] preProcessResponse:response])
            return ;
        
        if (success) {
           
            [contactEditDelegate deleteFriendSuccess];
            
            contact.contactType = [NSNumber numberWithInt:kCONTACT_TYPE_KRYPTO_USER];
            contact.contactState = [NSNumber numberWithInt:kCONTACT_STATE_DELETED];
            Request* request = [self getRequest:contactJid];
            [[DAOAdapter share] commitObject:contact];
            [[DAOAdapter share] deleteObject:request];
            
            [self backupContact:contactJid friendStatus:REMOVED];
            
        }else{
            [contactEditDelegate deleteFriendFailed];
             if (response){
                // if Token is invalid or expire
                NSInvocationOperation* operation=  [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(deleteFriend:) object:contactJid];
                NSDictionary* retryDictionary = @{kRETRY_OPERATION:operation,
                                                  kRETRY_TIME:kRETRY_API_COUNTER,
                                                  kSTATUS_CODE : [response objectForKey:kSTATUS_CODE]};
                [[AppFacade share] downloadTokenAgain:retryDictionary];
             }
        }
    }];


}

- (void)didSuccessRemoveContact:(NSString *)contactJID
{
    Contact *ct = [self getContact:contactJID];
    if (![ct isEqual:[NSNull null]]) {
        ct.contactType = [NSNumber numberWithInt:kCONTACT_TYPE_KRYPTO_USER];
        ct.contactState = [NSNumber numberWithInt:kCONTACT_STATE_DELETED];
        [[DAOAdapter share] commitObject:ct];
        [[NotificationFacade share] insertNewNoticeWithID:contactJID type:kNOTICEBOARD_TYPE_DELETE_CONTACT];
        
        [[NotificationFacade share] notifyRemovedContactReceived:contactJID];
        [[NotificationFacade share] setUnreadNotification:[[NotificationFacade share] getNumberUnreadNotices] atMenuIndex:SideBarNotificationIndex];
        [contactNotificationDelegate showNotifiView:HAVE_NEW_NOTIFICATION_MESSAGE];
        [self loadFriendArray];
    }
    
    Request *req = [self getRequest:contactJID];
    if (![req isEqual:[NSNull null]]) {
        [[DAOAdapter share] deleteObject:req];
    }
    //backup contact REMOVED
    [self backupContact:contactJID friendStatus:REMOVED];
}

- (void)wasRemovedContactFromFriend:(NSString *)contactJID
{
    [self didSuccessRemoveContact:contactJID];
    // do anything else here, eg: show notification tell was removed contact from his friend...
}

#define PRESENCE_AVAILABLE @"available"
-(void) updateContactPresence:(NSDictionary*) presence{
    Contact* contact = [self getContact:[presence objectForKey:kPRESENCE_FROM_USER_JID]];
    if (contact) {
        if (((NSString*)[presence objectForKey:kPRESENCE_STATUS]) && [[presence objectForKey:kPRESENCE_TYPE] isEqualToString:PRESENCE_AVAILABLE])
            contact.statusMsg = [presence objectForKey:kPRESENCE_STATUS];
        
        int contactState = [contact.contactState intValue];
        if (contactState != kCONTACT_STATE_BLOCKED && contactState != kCONTACT_STATE_DELETED) {
            if ([[presence objectForKey:kPRESENCE_TYPE] isEqualToString:PRESENCE_AVAILABLE]){
                contact.contactState = [NSNumber numberWithInteger:kCONTACT_STATE_ONLINE];
            }
            else{
                contact.contactState = [NSNumber numberWithInteger:kCONTACT_STATE_OFFLINE];
                contact.extend2 = [self generateLastSeenStatus:[NSDate date]];
            }
        }
        [[DAOAdapter share] commitObject:contact];
        
        [self loadFriendArray];
        [chatViewDelegate displaySingleStatus];
        [contactPopupDelegate displayInfo];
        [contactInfoDelegate buildView];
    }
}

-(void) updateContactLastActivity:(NSDate*) lastActivityDate JID:(NSString*) fullJID{
    NSInteger lastActTS = [NSDate date].timeIntervalSince1970 -lastActivityDate.timeIntervalSince1970;
    Contact *contact = [self getContact:fullJID];
    
    if(!contact)
        return;
    
    if(lastActTS > 0){
        contact.extend2 = [self generateLastSeenStatus:lastActivityDate];
        [[DAOAdapter share] commitObject:contact];
        [chatViewDelegate displaySingleStatus];
    }
    else{
        NSLog(@"Friend is online at the moment");
        if([contact.contactState integerValue] == kCONTACT_STATE_ONLINE
           || [contact.contactState integerValue] == kCONTACT_STATE_BLOCKED
           || [contact.contactState integerValue] == kCONTACT_STATE_DELETED){
            return;
        }
        
        contact.contactState = [NSNumber numberWithInt:kCONTACT_STATE_ONLINE];
        BOOL result = [[DAOAdapter share] commitObject:contact];
        if(result){
            [self loadFriendArray];
            [chatViewDelegate displaySingleStatus];
            [contactPopupDelegate displayInfo];
            [contactInfoDelegate buildView];
        }
    }
}

-(void) updateContactStateWhenDisconnect{
    NSString* query = [NSString stringWithFormat:@"contactType = '%d'", kCONTACT_TYPE_FRIEND];
    NSArray* arrayContact = [[DAOAdapter share] getObjects:[Contact class] condition:query];
    for(Contact *item in arrayContact){
        if([item.contactState integerValue] == kCONTACT_STATE_ONLINE){
            item.contactState = [NSNumber numberWithInt:kCONTACT_STATE_OFFLINE];
            item.extend2 = [self generateLastSeenStatus:[NSDate date]];
            [[DAOAdapter share] commitObject:item];
            
        }
    }
    [self loadFriendArray];
    [chatViewDelegate displaySingleStatus];
    [contactPopupDelegate displayInfo];
    [contactInfoDelegate buildView];
}

-(void) updateContactStateWhenReconnect{
    NSString* query = [NSString stringWithFormat:@"contactType = '%d'", kCONTACT_TYPE_FRIEND];
    NSArray* arrayContact = [[DAOAdapter share] getObjects:[Contact class] condition:query];
    for(Contact *item in arrayContact){
        [[XMPPFacade share] sendLastActivityQueryToJID:item.jid];
    }
}

-(UIImage*) updateContactAvatar:(NSString*) fullJID{
    Contact* contact = [self getContact:fullJID];
    if (contact) {
        NSData* avatar = [[ContactAdapter share] getContactAvatar:fullJID];
        avatar = [[AppFacade share] decryptDataLocally:avatar];
        if (avatar){
            return [UIImage imageWithData:avatar];
        }
    }
    return [UIImage imageNamed:IMG_C_EMPTY];
}

-(NSString*) generateLastSeenStatus:(NSDate*) lastActivitydate{
    
    NSString *strLastActivityDate = [ChatAdapter convertDateToString: [NSNumber numberWithInteger:lastActivitydate.timeIntervalSince1970] format:FORMAT_DATE];
    NSString *strToday = [ChatAdapter convertDateToString:[[NSNumber alloc] initWithInteger:[NSDate date].timeIntervalSince1970] format:FORMAT_DATE];
    
    if([strLastActivityDate isEqual:strToday]){
        return [NSString stringWithFormat:_LAST_SEEN_TODAY_AT,
                [ChatAdapter convertDateToString:[NSNumber numberWithInteger:lastActivitydate.timeIntervalSince1970] format:FORMAT_FULL_TIME]];
    }
    
    return [NSString stringWithFormat:_LAST_SEEN,
            [ChatAdapter convertDateToString:[NSNumber numberWithInteger:lastActivitydate.timeIntervalSince1970] format:FORMAT_FULL_DATE]];
}

-(NSString*) getContactName:(NSString*) fullJID{
    if ([fullJID isEqualToString:[self getJid:YES]])
        return _YOU;
    Contact* contact = [self getContact:fullJID];
    if (!contact)
        return kUNKNOWN;
    
    if (contact.customerName.length > 0)
        return contact.customerName;
    if(contact.phonebookName.length > 0)
        return contact.phonebookName;
    if (contact.serversideName.length > 0)
        return contact.serversideName;
    return contact.maskingid;
}

-(Contact*) getContact:(NSString*) contactJid{
    NSString* queryCondition = [NSString stringWithFormat:@"jid = '%@'", contactJid];
    return (Contact*)[[DAOAdapter share] getObject:[Contact class] condition:queryCondition];
}

-(Contact*) getContactByServerMSISDN:(NSString*) MSISDN{
    NSString* queryCondition = [NSString stringWithFormat:@"serverMSISDN = '%@'", MSISDN];
    return (Contact*)[[DAOAdapter share] getObject:[Contact class] condition:queryCondition];
}

-(Request*) getRequest:(NSString*) requestJid{
    NSString* queryCondition = [NSString stringWithFormat:@"requestJID = '%@'", requestJid];
    return (Request*)[[DAOAdapter share] getObject:[Request class] condition:queryCondition];
}

-(NSString*)processIdentity:(NSString*)strData{
    if(strData.length <= 0)
        return nil;
    NSArray* identityArray = [strData componentsSeparatedByString:kAES_SEPARATOR];
    if ([identityArray count] != 2)
        return nil;
    
    NSData* partEncKey = [Base64Security decodeBase64String:[identityArray objectAtIndex:0]];
    NSData* partAES = [Base64Security decodeBase64String:[identityArray objectAtIndex:1]];
    if (!partAES || !partEncKey)
        return nil;
    
    NSData* realKey = [RSASecurity decryptRSA:[Base64Security generateBase64String:partEncKey]
                                 b64PublicExp:[KeyChainSecurity getStringFromKey:kMOD2_EXPONENT]
                                   b64Modulus:[KeyChainSecurity getStringFromKey:kMOD2_MODULUS]
                                b64PrivateExp:[KeyChainSecurity getStringFromKey:kMOD2_PRIVATE]];
    if (!realKey)
        return nil;
    NSString* identitySend = [Base64Security generateBase64String:[AESSecurity decryptAES256WithKey:realKey
                                                                                               Data:partAES]];
    if (!identitySend)
        return nil;
    
    return identitySend;
}

-(NSString*) compareIdentityFromRequest:(NSString*)requestJID
                         serverIdentity:(NSString*)serverIdentity{
    NSString* queryRequest = [NSString stringWithFormat:@"requestJID = '%@'", requestJID];
    Request* request = (Request*)[[DAOAdapter share] getObject:[Request class] condition:queryRequest];
    NSString* base64Content = request.content;
    if (!base64Content)
        return nil;
    
    NSData* identityData = [Base64Security decodeBase64String:base64Content];
    if (!identityData)
        return nil;
    
    NSString* identityString = [[NSString alloc] initWithData:identityData encoding:NSUTF8StringEncoding];
    if (!identityString)
        return nil;
    NSArray* arrIdentity = [identityString componentsSeparatedByString:kAES_SEPARATOR];
    if ([arrIdentity count] != 2)
        return nil;
    NSData* partKey = [Base64Security decodeBase64String:[arrIdentity objectAtIndex:0]];
    NSData* partAES = [Base64Security decodeBase64String:[arrIdentity objectAtIndex:1]];
    if(!partKey || !partAES)
        return nil;
    NSData* realKey = [RSASecurity decryptRSA:[Base64Security generateBase64String:partKey]
                                 b64PublicExp:[KeyChainSecurity getStringFromKey:kMOD2_EXPONENT]
                                   b64Modulus:[KeyChainSecurity getStringFromKey:kMOD2_MODULUS]
                                b64PrivateExp:[KeyChainSecurity getStringFromKey:kMOD2_PRIVATE]];
    if (!realKey)
        return nil;
    
    NSData* identityKey = [AESSecurity decryptAES256WithKey:realKey Data:partAES];
    if (!identityKey)
        return nil;
    NSString* strKey = [[NSString alloc] initWithData:identityKey encoding:NSUTF8StringEncoding];
    NSArray* arrKey = [strKey componentsSeparatedByString:kMSG_SEPARATOR];
    NSString* identity0 = [arrKey objectAtIndex:0];
    
    if (![[Base64Security generateBase64String:identity0] isEqualToString:[Base64Security generateBase64String:serverIdentity]]) {
        return nil;
    }
    return [AESSecurity hashSHA256:[arrKey objectAtIndex:1]];
}

- (NSArray*)getAllKryptoMembers{
    NSString *queryCondition = [NSString stringWithFormat:@"contactType = %d", kCONTACT_TYPE_KRYPTO_USER];
    NSMutableArray* allContactNumber = [[[DAOAdapter share] getObjects:[Contact class] condition:queryCondition] mutableCopy];
    NSMutableArray* arrAllContactNumber = [NSMutableArray new];
    NSString* dialCode =  [self getDialCodeFromMSISDN];
    if ([dialCode isEqualToString:kUNKNOWN])
        dialCode = nil;
    NSMutableArray* arrAllNumberPhoneBook = [[self getAllNumberPhoneBook] mutableCopy];
    
    for (Contact *contact in allContactNumber) {
        if (contact.serverMSISDN.length > 0) {
            NSString * contactNumberString = [[ContactAdapter share] handlePhoneNumber:contact.serverMSISDN];
            
            if ([arrAllNumberPhoneBook containsObject:contactNumberString])
                [arrAllContactNumber addObject:contact];
        }
    }

    return [arrAllContactNumber copy];
}

- (NSMutableArray*)getAllNumberPhoneBook{
    NSMutableDictionary *allContactPhoneBook = [[[ContactAdapter share] getAllContactsInAddressBook] mutableCopy];
    NSMutableArray *arrContactPhoneBookKey = [[allContactPhoneBook allKeys] mutableCopy] ;
    NSMutableArray *tempNumberContact = [[NSMutableArray alloc] init];
    
    NSString* dialCode =  [self getDialCodeFromMSISDN];
    if ([dialCode isEqualToString:kUNKNOWN])
        dialCode = nil;

    for (id aKey in arrContactPhoneBookKey) {
        NSMutableArray* arrSamePrefix = [allContactPhoneBook objectForKey:aKey];
        for (NSDictionary* contactInfo in [arrSamePrefix mutableCopy]) {
            NSString* phoneNo = [[ContactAdapter share] handlePhoneNumber:[contactInfo objectForKey:@"mobile"]];
            [tempNumberContact addObject:phoneNo];
        }
    }
    
    return [tempNumberContact copy];
}

-(NSArray *)getContactsAddressBook{
    NSLog(@"%s" ,__PRETTY_FUNCTION__);
    NSArray *normalPhoneBook;
    NSMutableArray *normalContactPB =  [[[ContactAdapter share] getContactsAddressBook] mutableCopy];
    NSMutableArray *kryptoMembers = [[self getAllKryptoMembers] mutableCopy];
    NSMutableArray *arrKryptoPhoneNumbers = [NSMutableArray array];
    NSMutableArray *toDelete = [NSMutableArray array];
    
    for (Contact *contact in kryptoMembers) {
        if (contact.serverMSISDN.length > 0) {
            NSString *contactNumberString = [[ContactAdapter share] handlePhoneNumber:contact.serverMSISDN];
            [arrKryptoPhoneNumbers addObject:contactNumberString];
        }
    }
    
    if (arrKryptoPhoneNumbers.count > 0)
        for (NSDictionary *normalContact in normalContactPB) {
            NSString *numberInPhoneBookString = [[normalContact objectForKey:@"mobile"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            if ([arrKryptoPhoneNumbers containsObject:numberInPhoneBookString]) {
                [toDelete addObject:normalContact];
            }
        }
    [normalContactPB removeObjectsInArray:toDelete];
    normalContactPB = [self filterDuplicatePhoneNum:normalContactPB] ;
    
    normalPhoneBook =  [normalContactPB copy];
    return normalPhoneBook;
}

-(NSMutableArray *)filterDuplicatePhoneNum:(NSArray *)contactArray
{
    NSSet *resultSet = [NSSet setWithArray:[contactArray valueForKeyPath:@"mobile"]];
    
    if (resultSet.count == contactArray.count)
        return [contactArray mutableCopy];
    
    NSMutableArray *newContactArray = [NSMutableArray new];
    for (NSString *phoneNum in [resultSet allObjects]) {
        for (NSDictionary *contact in contactArray) {
            NSString *contactNumber = [[contact objectForKey:@"mobile"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            
            if ([phoneNum isEqualToString:contactNumber]){
                [ newContactArray addObject:contact];
                break;
            }
        }
    }
    
    return newContactArray ;
}


-(NSArray *)getSymbolicContactsAddressBook{
    NSLog(@"%s" ,__PRETTY_FUNCTION__);
    NSArray *symbolContactPhoneBook;
    NSMutableArray *symbolContactPB =  [[[ContactAdapter share] getSymbolicContactsAddressBook] mutableCopy];
    NSMutableArray *kryptoMembers = [[self getAllKryptoMembers] mutableCopy];

    NSMutableArray *arrKryptoPhoneNumbers = [NSMutableArray array];
    NSMutableArray *toDelete = [NSMutableArray array];
    for (Contact *contact in kryptoMembers) {
        
        if (contact.serverMSISDN.length > 0) {
             NSString *contactNumberString = [[ContactAdapter share] handlePhoneNumber:contact.serverMSISDN];
            [arrKryptoPhoneNumbers addObject:contactNumberString];
        }
        
    }
    
    if (arrKryptoPhoneNumbers.count > 0){
        for (NSDictionary *symbolPhoneBook in symbolContactPB) {
            NSString *numberInPhoneBookString = [[symbolPhoneBook objectForKey:@"mobile"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            if ([arrKryptoPhoneNumbers containsObject:numberInPhoneBookString]) {
                [toDelete addObject:symbolPhoneBook];
            }
        }
    }


    [symbolContactPB removeObjectsInArray:toDelete];
    
    symbolContactPhoneBook =  [symbolContactPB copy];
    return symbolContactPhoneBook;
}

-(NSDictionary *)getAllContactsInAddressBook{
    NSLog(@"%s" ,__PRETTY_FUNCTION__);
    NSMutableDictionary *allContactPB = [[NSMutableDictionary alloc] initWithDictionary:
                                         [[ContactAdapter share] getAllContactsInAddressBook]];
    NSMutableArray *allContactNumber = [[[DAOAdapter share] getAllObject:[Contact class]] mutableCopy];
    NSMutableArray *arrContactKey = [[allContactPB allKeys] mutableCopy] ;
    NSMutableDictionary *tempContactPB = [[NSMutableDictionary alloc] init];
    
    
    NSMutableArray *arrAllContactNumber = [NSMutableArray array];
    NSString* MSISDN = [self getMSISDN];
    
    NSString* dialCode =  [self getDialCodeFromMSISDN];
    if ([dialCode isEqualToString:kUNKNOWN])
        dialCode = nil;
    
    if ([MSISDN length] > 0)
        [arrAllContactNumber addObject:MSISDN];
    
    for (Contact *contact in allContactNumber) {
        if (contact.serverMSISDN.length > 0) {
            NSString *contactNumberString = [[ContactAdapter share] handlePhoneNumber:contact.serverMSISDN];
            [arrAllContactNumber addObject:contactNumberString];
        }
    }
    
    for (id aKey in arrContactKey) {
        NSMutableArray* arrSamePrefix = [[NSMutableArray alloc] initWithArray:[allContactPB objectForKey:aKey]];
        for (NSDictionary* contactInfo in [arrSamePrefix mutableCopy]) {
            NSString* phoneNo = [[ContactAdapter share] handlePhoneNumber:[contactInfo objectForKey:@"mobile"]];
            if ([arrAllContactNumber containsObject:phoneNo]) {
                [arrSamePrefix removeObjectAtIndex:[[arrSamePrefix mutableCopy] indexOfObject:contactInfo]];
            }
        }
        if (arrSamePrefix.count > 0) {
            [tempContactPB setObject:arrSamePrefix forKey:aKey];
        }
    }
    
    tempContactPB = [[self filterDicContactBook:tempContactPB] mutableCopy];
    return [tempContactPB copy];
}

-(NSDictionary *)filterDicContactBook: (NSDictionary *)ContactBookDic {
    NSMutableArray *arrContactKey = [[ContactBookDic allKeys] mutableCopy] ;
    NSMutableArray *arrContactNumber = [NSMutableArray new];
    NSMutableDictionary *tempContactPB = [[NSMutableDictionary alloc] init];
    
    for (id aKey in arrContactKey) {
        NSMutableArray* arrSamePrefix = [[NSMutableArray alloc] initWithArray:[ContactBookDic objectForKey:aKey]];
        for (NSDictionary* contactInfo in [arrSamePrefix mutableCopy]) {
            NSString* phoneNo = [[contactInfo objectForKey:@"mobile"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            if ([arrContactNumber containsObject:phoneNo])
                [arrSamePrefix removeObjectAtIndex:[[arrSamePrefix mutableCopy] indexOfObject:contactInfo]];
            else
                [arrContactNumber addObject:phoneNo];
        }
        if (arrSamePrefix.count > 0) {
            [tempContactPB setObject:arrSamePrefix forKey:aKey];
        }
    }
    
    return [tempContactPB copy];
}

-(BOOL) isFriend:(NSString*) contactJID{
    Contact* contact = ((Contact*)[self getContact:contactJID]);
    if (!contact)
        return FALSE;
    return ([contact.contactType integerValue] == kCONTACT_TYPE_FRIEND);
}

-(BOOL) isBlocked:(NSString*) contactJID{
    return ([((Contact*)[self getContact:contactJID]).contactState integerValue] == kCONTACT_STATE_BLOCKED);
}

- (BOOL)isAccountRemoved{
    return ([[KeyChainSecurity getStringFromKey:kIS_ACCOUNT_REMOVED] isEqual:IS_YES]);
}

-(void) searchContact:(NSString*) text{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        NSString* query = [NSString stringWithFormat:@"contactType = '%d' AND contactState != '%d' AND contactState != '%d'", kCONTACT_TYPE_FRIEND, kCONTACT_STATE_BLOCKED, kCONTACT_STATE_DELETED];
        NSArray* arrayContact = [[DAOAdapter share] getObjects:[Contact class] condition:query];
        NSString *searchText = text;
        NSArray *search = nil;
        if (searchText.length > 0){
            search = [arrayContact filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"serversideName contains [c] %@ || customerName contains [c] %@ || phonebookName contains [c] %@ || maskingid contains [c] %@ ", searchText,searchText,searchText, searchText]];
        }
        else
            search = [arrayContact mutableCopy];
        
        search = [search sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2){
            Contact *contact1 = (Contact*) obj1;
            Contact *contact2 = (Contact*) obj2;
            
            NSString *contactName1 = [[self getContactName:contact1.jid] lowercaseString];
            NSString *contactName2 = [[self getContactName:contact2.jid] lowercaseString];
            
            return [contactName1 compare:contactName2];
        }];
        
        [contactListDelegate reloadSearchContactList:search];
        [NewGroupViewDelegate reloadContactSearchList:search];
        [chatComposeDelegate reloadComposeSearchList:search];
        [unblockUsersDelegate reloadUnblockUserSearchList:search];
        [forwardListDelegate reloadForwardList:search];
    }];
}

-(void) searchUserMember:(NSString*) text{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        NSMutableArray* arrUserMemberStore = [[self getAllKryptoMembers] mutableCopy];
        NSArray *search = nil;
        if (text.length > 0) {
            search = [arrUserMemberStore filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"serversideName contains [c] %@ || customerName contains [c] %@ || phonebookName contains [c] %@ || maskingid contains [c] %@ ", text, text, text, text]];
        }
        else
            search = arrUserMemberStore;
        [contactBookDelegate reloadSearchMemberContact:search];
    }];
}

-(void) searchPhoneBookFriend:(NSString*) text{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        NSMutableDictionary* arrAllContactsPhoneBook = [[self getAllContactsInAddressBook] mutableCopy];
        NSMutableArray* arrNormalContactStore = [[self getContactsAddressBook] mutableCopy];
        NSMutableArray* arrSimbolicContactStore = [[self getSymbolicContactsAddressBook] mutableCopy];
        NSMutableDictionary* arrResult = [NSMutableDictionary new];
        
        if(text.length > 0)
        {
            NSArray* arrNormalContact = [self searchContactKeyword:text withNormalContact:arrNormalContactStore];
            NSArray* arrSymbolicContact = [self searchSymbolicContactKeyword:text withSymbolicContact:arrSimbolicContactStore];
            arrResult = [self sortArrayWithNormalContact:arrNormalContact andSymbolicContact:arrSymbolicContact];
        }
        else
            arrResult = arrAllContactsPhoneBook;
        
        [contactBookDelegate reloadSearchContactPhoneBook:arrResult];
    }];
}

-(NSMutableDictionary*) sortArrayWithNormalContact:(NSArray*) arrNormalContact andSymbolicContact:(NSArray*) arrSymbolicContact{
    
    NSMutableDictionary* allContactsPhoneBook = [[NSMutableDictionary alloc] init];
    if(arrNormalContact.count == 0 && arrSymbolicContact.count == 0)
        return allContactsPhoneBook;
    
    for (NSDictionary *temp in arrNormalContact)
    {
        NSString* fullName = [temp objectForKey:@"contactFirstLast"];
        NSString* firstLetter = @"";
        if(fullName.length > 0){
            firstLetter = [[fullName substringToIndex:1] capitalizedString];
        }
        
        BOOL found = NO;
        for (NSString *str in [allContactsPhoneBook allKeys]){
            if ([[str capitalizedString] isEqualToString:firstLetter]){
                found = YES;
                break;
            }
        }
        
        if (!found){
            [allContactsPhoneBook setValue:[[NSMutableArray alloc] init] forKey:firstLetter];
        }
    }
    
    
    if(arrSymbolicContact.count > 0){
        [allContactsPhoneBook setValue:[[NSMutableArray alloc] init] forKey:@"#"];
    }
    
    for (NSDictionary *temp in arrNormalContact){
        NSString* firstLetter = [[[temp objectForKey:@"contactFirstLast"] substringToIndex:1] capitalizedString];
        if ([allContactsPhoneBook objectForKey:firstLetter]) {
            [[allContactsPhoneBook objectForKey:firstLetter] addObject:temp];
        }
    }
    
    for (NSDictionary *temp in arrSymbolicContact){
        if ([allContactsPhoneBook objectForKey:@"#"]) {
            [[allContactsPhoneBook objectForKey:@"#"] addObject:temp];
        }
    }
    
    return allContactsPhoneBook;
}

//check search text
- (NSArray*)searchContactKeyword:(NSString*)searchText withNormalContact:(NSMutableArray*)arrNormalContact
{
    NSArray *search = [arrNormalContact filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"contactFirstLast contains [c] %@", searchText]];
    
    return search;
}

// Search Symbolic contacts
- (NSArray*)searchSymbolicContactKeyword:(NSString*)searchText withSymbolicContact:(NSMutableArray*)arrSymbolicContact
{
    NSArray *search = [arrSymbolicContact filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"contactFirstLast contains [c] %@", searchText]];
    return search;
}

- (void) searchEmailFriendName:(NSString *) searchText friendArray:(NSArray *)friendsArray isAddParticipant:(BOOL)isAddParticipant
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        BOOL isEmptyText = [searchText isEqualToString:@""] || [searchText length] == 0 ;
        if(isEmptyText)
        {
            if (!isAddParticipant)
            {
                dispatch_async(dispatch_get_main_queue(), ^(void){
                    [findEmailContactDelegate buildEmailContactsData];
                });
            }
        }
        else
        {
             NSArray *search = [friendsArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"serversideName contains [c] %@ || customerName contains [c] %@ || phonebookName contains [c] %@  || maskingid contains [c] %@ ", searchText,searchText,searchText,searchText]];
            
            if (search > 0)
            {
                dispatch_async(dispatch_get_main_queue(), ^(void){
                    [findEmailContactDelegate searchResult:search];
                });
            }
        }
    });
}


#pragma mark Reset account functions

-(void) resetAccount{
    [CWindow share].firstLaunch = YES;
    [self resetDefaults];
    [[AppFacade share] deleteAllTablesDB];
    [[AppFacade share] checkFirstRun];
    [[CWindow share] showLoginFirstScreen];
}

- (void)resetDefaults {
    NSUserDefaults * defs = [NSUserDefaults standardUserDefaults];
    NSDictionary * dict = [defs dictionaryRepresentation];
    for (id key in dict) {
        [defs removeObjectForKey:key];
    }
    [defs synchronize];
}

#pragma mark Process Failed case API
-(void) processAgainForFailedCases{

    //Check if backup profile failed then call backup once again
    if (![[ContactFacade share] getBackupProfileFlag]) {
        [[ContactFacade share] backupProfile];
    }
    //Check if restore profile failed then call backup once again
    if (![[ContactFacade share] getRestoreProfileFlag] && [[ContactFacade share] getReloginFlag] ) {
        [[ContactFacade share] restoreProfile];
    }
    //upload masterekey if failed
    if (![[ContactFacade share] getUpdateMasterKeyFlag] && ([[ContactFacade share] getRegisterFlag] || [[ContactFacade share] getRestoreProfileFlag])) {
        [[ContactFacade share] uploadMasterKey];
    }
    //Process backup contact again if failed
    NSArray *contacts = (NSArray*)[[DAOAdapter share] getAllObject:[Contact class]];
    
    for (Contact *contactObj in contacts) {
        if(![contactObj isKindOfClass:[Contact class]])
            continue;
        if (contactObj.extend1 != 0)//backup failed is 0
            continue;
        Request *requestObj = [[ContactFacade share] getRequest:contactObj.jid];
        if (!requestObj)
            continue;
        
        NSInteger contactType = [contactObj.contactType integerValue];
        switch (contactType) {
            case kCONTACT_TYPE_FRIEND:{
                NSInteger requestStatus = [requestObj.status integerValue];
                switch (requestStatus) {
                    case kREQUEST_STATUS_APPROVED:{
                        NSLog(@"Backup contact %@ again for status APPROVED",contactObj.jid);
                        [[ContactFacade share] backupContact:contactObj.jid friendStatus:APPROVED];
                    }break;
                }
            }break;
            case kCONTACT_TYPE_NOT_FRIEND:{
                NSInteger requestStatus = [requestObj.status integerValue];
                switch (requestStatus) {
                    case kREQUEST_STATUS_PENDING:{
                        if ([requestObj.requestType integerValue] == kREQUEST_TYPE_SEND) {
                            NSLog(@"Backup contact %@ again for status PENDING",contactObj.jid);
                            [[ContactFacade share] backupContact:contactObj.jid friendStatus:PENDING];
                        }
                        else if ([requestObj.requestType integerValue] == kREQUEST_TYPE_RECEIVE){
                            NSLog(@"Backup contact %@ again for status RECEIVED",contactObj.jid);
                            [[ContactFacade share] backupContact:contactObj.jid friendStatus:RECEIVED];
                        }
                    }break;
                }
            }break;
        }
    }
    
    //Call restore contact again if restore contact failed.
    if ([self getReloginFlag] && ![self getRestoreContactFlag]) {
        [self restoreContact:STATUS_APPROVED_AND_PENDING_AND_RECEIVED];
    }
}

- (void) synchronizeBlockList:(NSString*)blocked_jid_list  action:(NSString*)action{
    __block NSString* blockList = blocked_jid_list;
    __block NSString* actionType = action;
    NSDictionary *synchronizeDic = @{kTOKEN: [self getTokentTenant],
                               kMASKINGID: [self getMaskingId],
                               kIMSI: [self getIMSI],
                               kIMEI: [self getIMEI],
                               kBLOCKED_JID_LIST: blocked_jid_list,
                               kAPI_REQUEST_METHOD: POST,
                               kAPI_REQUEST_KIND: NORMAL,
                               kACTION:action
                               };
    
    [[ContactAdapter share] synchronizeBlockList:synchronizeDic callback:^(BOOL success, NSString *message, NSDictionary *response, NSError *error) {
        if (success) {
            if (response[kBLOCKED_JID_LIST] && [actionType isEqual:GET]) {
                [self updateBlockUserList:response[kBLOCKED_JID_LIST] isBlock:YES];
            }
            else{
                if ([actionType isEqual:kBLOCK_USERS])
                    [self updateBlockUserList:blockList isBlock:YES];
                if ([actionType isEqual:kUNBLOCK_USERS])
                    [self updateBlockUserList:blockList isBlock:NO];
            }
            [unblockUsersDelegate synchronizeBlockListSuccess];
            [blockUsersDelegate synchronizeBlockListSuccess];
            [contactInfoDelegate synchronizeBlockListSuccess];
            [blockUsersCellDelegate synchronizeBlockListSuccess];
        }
        else{
            [contactInfoDelegate synchronizeBlockListFailed];
            [blockUsersDelegate synchronizeBlockListFailed];
            [unblockUsersDelegate synchronizeBlockListFailed];
            [blockUsersCellDelegate synchronizeBlockListFailed];
            
            if (response) {
                // if token fail, retry 5 times.
                SEL  currentSelector = @selector(synchronizeBlockList:action:);
                NSMethodSignature * methSig          = [self methodSignatureForSelector: currentSelector];
                NSInvocation      * invocation       = [NSInvocation invocationWithMethodSignature: methSig];
                [invocation setSelector: currentSelector];
                [invocation setTarget: self];
                [invocation setArgument: &blockList atIndex: 2];
                [invocation setArgument: &actionType atIndex: 3];
                NSInvocationOperation* operation=  [[NSInvocationOperation alloc] initWithInvocation:invocation];
                
                NSDictionary* retryDictionary = @{kRETRY_OPERATION:operation,
                                                  kRETRY_TIME:kRETRY_API_COUNTER,
                                                  kSTATUS_CODE : [response objectForKey:kSTATUS_CODE]};
                [[AppFacade share] downloadTokenAgain:retryDictionary];
            }
            
        }
    }];
}

- (void) updateBlockUserList:(NSString*)blockList isBlock:(BOOL)isBlock{
     NSArray* arrBlockUser = [blockList componentsSeparatedByString:@","];
    for (NSString* jid in arrBlockUser) {
        if (isBlock) {
            [[ContactFacade share] blockContact:jid];
        }
        else{
            [[ContactFacade share] unblockContact:jid];
        }
    }
}

- (void) getTransactionHistory{
    NSDictionary *transactionHistoryDic = @{kTOKEN: [self getTokentTenant],
                                     kMASKINGID: [self getMaskingId],
                                     kIMSI: [self getIMSI],
                                     kIMEI: [self getIMEI],
                                     kAPI_REQUEST_METHOD: PUT,
                                     kAPI_REQUEST_KIND: NORMAL};
    
    [[ContactAdapter share] getTransactionHistory:transactionHistoryDic callback:^(BOOL success, NSString *message, NSDictionary *response, NSError *error) {
        if (success) {
            NSLog(@"transaction history: %@", response);
            NSMutableArray* arrayOfTransaction = [self createTransactionHistoryArray:response];
            [webMyAccountDelegate getTransactionHistorySuccess:arrayOfTransaction];
        }
        else{
            [webMyAccountDelegate getTransactionHistoryFail];
        }
    }];
}

/*
 *Author: Juriaan
 *internal method. Please do not add it in .h file.
*/

- (NSMutableArray*) createTransactionHistoryArray:(NSDictionary*)response{
    NSMutableArray* arrayOfTransactionHistory =[NSMutableArray new];
    
    NSArray* arrayOfTransaction = response[@"TRANSACTION_HISTORY"];
    
    for (NSDictionary* transactionItem in arrayOfTransaction) {
        NSString* transactionMethod = ([transactionItem[kTRANSACTION_METHOD] isEqual:TRANSACTION_METHOD_NORMAL])? @"NORMAL": transactionItem[kTRANSACTION_METHOD];
      
        NSDictionary* anSection =  @{kTRANSACTION_DATE:transactionItem[kTRANSACTION_DATE],
                                     kSERVICE_SECTION:transactionItem[kSERVICE_SECTION],
                                     kTRANSACTION_METHOD:transactionMethod,
                                     kAMOUNT:transactionItem[kAMOUNT],
                                     KSTATUS_SECTION:transactionItem[KSTATUS_SECTION]};
         [arrayOfTransactionHistory addObject:anSection];
    }
    return arrayOfTransactionHistory;
}
@end
