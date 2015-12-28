//
//  ContactAdapter.m
//  ContactDomain
//
//  Created by enclave on 1/20/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import "ContactAdapter.h"
#import "ContactServerAdapter.h"
//import address book
#import <AddressBookUI/AddressBookUI.h>
//import logging
#import "CocoaLumberjack.h"
#import "ProfileAdapter.h"

#import "NBPhoneNumber.h"
#import "NBPhoneNumberDesc.h"
#import "NBPhoneNumberUtil.h"
#import "NBNumberFormat.h"

//NSString
#define isEmptyString(string) [[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""] || !string

#define REGEX_PHONE_NUMBER @"[+0-9]{7,20}$"

#define ALPHA_NUMERIC @"ABCDEFGHIJKLMNOPQRSTUVWXYZ01234567890"

#define CONTACT_AVATAR_FOLDERNAME @"CONTACT_AVATARS"

//APIs
#define kAPI @"API"
#define kAPI_VERSION @"API_VERSION"

#define API_CHECK_IDENTITY @"JnRpwLc"
#define API_CHECK_IDENTITY_VERSION @"v1"

#define API_GET_IDENTITY @"KwTucoj"
#define API_GET_IDENTITY_VERSION @"v1"

#define API_APPROVE_IDENTITY @"VnaPuQe"
#define API_APPROVE_IDENTITY_VERSION @"v1"

#define API_REJECT_IDENTITY @"qMhVpYDs8q"
#define API_REJECT_IDENTITY_VERSION @"v1"

#define API_GET_FRIEND_PUBLIC_KEY @"gEykItu"
#define API_GET_FRIEND_PUBLIC_KEY_VERSION @"v1"

#define API_GET_FRIEND_INFO @"IpZZL0S"
#define API_GET_FRIEND_INFO_VERSION @"v1"

#define API_SEARCH_FRIENDS @"ZeNhuumVX1"
#define API_SEARCH_FRIENDS_VERSION @"v1"

#define API_SEARCH_CONTACTS @"TQsdDwV9kL"
#define API_SEARCH_CONTACTS_VERSION @"v1"

#define API_REMOVE_FRIEND @"HViM9ZgORr"
#define API_REMOVE_FRIEND_VERSION @"v1"

#define API_GET_VCARD @"AMDgtfwjpa"
#define API_GET_VCARD_VERSION @"v1"

#define API_HTTP_FRIEND_REQUEST @"pdiheXrWRV"
#define API_HTTP_FRIEND_REQUEST_VERSION @"v1"

#define API_HTTP_FRIEND_REQUEST_RESPONSE @"LbvYbrSEY9"
#define API_HTTP_FRIEND_REQUEST_RESPONSE_VERSION @"v1"

#define API_HTTP_FRIEND_REQUEST_LIST @"iDQn1hFotH"
#define API_HTTP_FRIEND_REQUEST_LIST_VERSION @"v1"

#define API_SYNCHRONIZE_BLOCK_LIST @"aslmQunzC7"
#define API_SYNCHRONIZE_BLOCK_LIST_VERSION @"v1"

#define API_GET_TRANSACTION_HISTORY @"v5yJFFdkyu"
#define API_GET_TRANSACTION_HISTORY_VERSION @"v1"

//Logging
#ifdef DEBUG
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelOff;
#endif

@interface ContactAdapter ()
{
    NSMutableArray *contactsAddressBook;
    NSMutableArray *symbolicContactsAddressBook;
    NSMutableDictionary *sortedContactsAddressBook;
    NSMutableArray *phoneNumbersList;
    NSDictionary *countryNameWithDialCode;
    NSOperationQueue *operationQueue;
    NSInvocationOperation *invOperation;
}

@end

@implementation ContactAdapter

+(ContactAdapter *)share{
    static dispatch_once_t once;
    static ContactAdapter * share;
    dispatch_once(&once, ^{
        share = [self new];
    });
    return share;
}

-(void)getAddressPhoneBook{
    
    invOperation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(getAddressBook) object:nil];
    
    if (!operationQueue) {
        operationQueue = [[NSOperationQueue alloc] init];
    }
    
    [operationQueue addOperation:invOperation] ;
    [operationQueue waitUntilAllOperationsAreFinished];
}

-(NSDictionary *)getAllContactsInAddressBook{
    if(sortedContactsAddressBook.count == 0)
        [self getAddressPhoneBook];
    return sortedContactsAddressBook;
}

-(NSArray *)getContactsAddressBook{
    if(contactsAddressBook.count == 0)
        [self getAddressPhoneBook];
    return contactsAddressBook;
}

-(NSArray *)getSymbolicContactsAddressBook{
    if(symbolicContactsAddressBook.count == 0)
        [self getAddressPhoneBook];
    return symbolicContactsAddressBook;
}

-(NSArray *)getPhoneNumberListInContactAddressBook{
    if(phoneNumbersList.count == 0)
        [self getAddressPhoneBook];
    return phoneNumbersList;
}


#pragma mark AB lifecycle
////////////////////////////////////////////////////////////////////////////////////
-(void)getAddressBook
{
    // Request authorization to Address Book
    ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
    switch (ABAddressBookGetAuthorizationStatus()) {
        case kABAuthorizationStatusNotDetermined:
        {
            ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
                // First time access has been granted, add the contact
                [self scanAddressBook:addressBookRef];
            });
        }
            break;
        case kABAuthorizationStatusAuthorized:
            [self scanAddressBook:addressBookRef];
            break;
            
        default:
            DDLogError(@"%s: Failed", __PRETTY_FUNCTION__);
            break;
    }
    
    [self sortArray];
}

-(void) sortArray{
    sortedContactsAddressBook = [[NSMutableDictionary alloc] init];
    if(contactsAddressBook.count == 0 && symbolicContactsAddressBook.count == 0)
        return;
    
    BOOL found;
    
    for (NSDictionary *temp in contactsAddressBook)
    {
        NSString* fullName = [temp objectForKey:@"contactFirstLast"];
        NSString* firstLetter = @"";
        if(fullName.length > 0){
            firstLetter = [[fullName substringToIndex:1] capitalizedString];
        }
        
        found = NO;
        for (NSString *str in [sortedContactsAddressBook allKeys]){
            if ([[str capitalizedString] isEqualToString:firstLetter]){
                found = YES;
                break;
            }
        }
        
        if (!found){
            [sortedContactsAddressBook setValue:[[NSMutableArray alloc] init] forKey:firstLetter];
        }
    }
    
    
    if(symbolicContactsAddressBook.count > 0){
        [sortedContactsAddressBook setValue:[[NSMutableArray alloc] init] forKey:@"#"];
    }
    
    for (NSDictionary *temp in contactsAddressBook){
        NSString* firstLetter = [[[temp objectForKey:@"contactFirstLast"] substringToIndex:1] capitalizedString];
        if ([sortedContactsAddressBook objectForKey:firstLetter]) {
            [[sortedContactsAddressBook objectForKey:firstLetter] addObject:temp];
        }
    }
    
    for (NSDictionary *temp in symbolicContactsAddressBook){
        if ([sortedContactsAddressBook objectForKey:@"#"]) {
            [[sortedContactsAddressBook objectForKey:@"#"] addObject:temp];
        }
    }
}


-(void)scanAddressBook:(ABAddressBookRef)addressBook
{
    contactsAddressBook = [NSMutableArray new];
    symbolicContactsAddressBook = [NSMutableArray new];
    sortedContactsAddressBook = [NSMutableDictionary new];
    phoneNumbersList = [NSMutableArray new];
    
    NSMutableDictionary *dateCreationDict = [NSMutableDictionary new];
    
    NSArray *people = (__bridge_transfer NSArray *)ABAddressBookCopyArrayOfAllPeople(addressBook);
    if (people == nil){
        DDLogInfo(@"%s: NO RECORD", __PRETTY_FUNCTION__);
        CFRelease(addressBook);
        return;
    }
    
    NSInteger recordCount = [people count];
    
    //Add dialcode for phonenumber here
    countryNameWithDialCode = [[ProfileAdapter share] getCurrentCountryNameWithDialCode];
    NSString *dialCode = [countryNameWithDialCode objectForKey:kDIAL_CODE];
    
    for (int i = 0; i < recordCount; i++)
    {
        ABRecordRef person = (__bridge ABRecordRef)[people objectAtIndex:i];
        
        NSString *firstName = @"";
        NSString *middleName = @"";
        NSString *lastName = @"";
        NSDate *dateCreation = nil;
        
        if (ABRecordCopyValue(person, kABPersonFirstNameProperty))
            firstName = (__bridge_transfer NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty);
        if (ABRecordCopyValue(person, kABPersonMiddleNameProperty))
            middleName = (__bridge_transfer NSString *)ABRecordCopyValue(person, kABPersonMiddleNameProperty);
        if (ABRecordCopyValue(person, kABPersonLastNameProperty))
            lastName = (__bridge_transfer NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty);
        if(ABRecordCopyValue(person, kABPersonCreationDateProperty))
            dateCreation = (__bridge_transfer NSDate *)ABRecordCopyValue(person, kABPersonCreationDateProperty);
        
        ABMultiValueRef phones = (ABMultiValueRef)ABRecordCopyValue(person, kABPersonPhoneProperty);
        NSString* mobileNo = @"";
        NSString* mobileLabel;
        NSString* phonetype = @"";
        NSString* mobileDisplay = @"";
        for (int i=0; i < ABMultiValueGetCount(phones); i++) {
            mobileLabel = (__bridge NSString*)ABMultiValueCopyLabelAtIndex(phones, i);
            if([mobileLabel isEqualToString:(NSString *)kABPersonPhoneMobileLabel])
                phonetype = @"Mobile:";
            else if ([mobileLabel isEqualToString:(NSString*)kABPersonPhoneIPhoneLabel])
                phonetype = @"iPhone:";
            else
                phonetype = @"Tel:";
            mobileNo = (__bridge NSString*)ABMultiValueCopyValueAtIndex(phones, i);
            NSArray* words = [mobileNo componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            mobileNo = [words componentsJoinedByString:@""];
            mobileDisplay = [[NSString alloc] initWithFormat:@"%@%@",phonetype, mobileNo];
        //}
        
        BOOL isDuplicateContact = NO;
        NSArray *allKeys = [dateCreationDict allKeys];
        if(![allKeys containsObject:mobileNo])
            [dateCreationDict setObject:dateCreation forKey:mobileNo];
        else
            isDuplicateContact = YES;
        
        //If same number with mutiple name, will only take the latest name user save
        if(isDuplicateContact){
            if([dateCreation compare:[dateCreationDict objectForKey:mobileNo]] == NSOrderedSame
               || [dateCreation compare:[dateCreationDict objectForKey:mobileNo]] == NSOrderedAscending)
                continue;
            else{ // NSOrderedDescending
                NSDictionary *removeContact =[NSDictionary new];
                if (contactsAddressBook.count > 0) {
                    for(NSDictionary *contactInfo in contactsAddressBook){
                        if([[contactInfo objectForKey:@"mobile"] isEqualToString:mobileNo]){
                            removeContact = contactInfo;
                            break;
                        }
                    }
                    [contactsAddressBook removeObject:removeContact];
                }
            }
        }
        
        //CFRelease(phones);
        NSString *contactFirstLast;
        
        if (firstName.length == 0 && middleName.length == 0 && lastName.length == 0)
            contactFirstLast = @"No Name";
        if(firstName.length > 0){
            contactFirstLast = firstName;
            contactFirstLast = [contactFirstLast stringByAppendingString:@" "];
        }
            
        if (middleName.length > 0){
            contactFirstLast = [contactFirstLast stringByAppendingString:middleName];
            contactFirstLast = [contactFirstLast stringByAppendingString:@" "];
        }
        if (lastName.length > 0){
            contactFirstLast = [contactFirstLast stringByAppendingString:lastName];
            contactFirstLast = [contactFirstLast stringByAppendingString:@" "];
        }
        
        if (mobileNo.length == 0)
            continue;
        if (contactFirstLast.length == 0)
            continue;
        if (mobileDisplay.length == 0)
            continue;
        
        // add dialcode for phone number
         //mobileNo = [self handlePhoneNumber:mobileNo];
        mobileNo = [self handlePhoneNumber:mobileNo countryCode:[countryNameWithDialCode objectForKey:kCOUNTRY_CODE]];
        
        NSDictionary *contactInfo = @{@"contactFirstLast" : contactFirstLast,
                                      @"mobile" : mobileNo,
                                      @"mobileDisplay" : mobileDisplay,};
        
        NSCharacterSet *blockedCharacters = [NSCharacterSet characterSetWithCharactersInString:ALPHA_NUMERIC];
        
        //All contact has name start by special character should be in "#" section.
        NSString *firstLetter = [[contactFirstLast substringToIndex:1] capitalizedString];
        BOOL isAlphaNumeric =   ([firstLetter rangeOfCharacterFromSet:blockedCharacters].location == NSNotFound);
        
        if(isAlphaNumeric || isEmptyString(contactFirstLast))
            [symbolicContactsAddressBook addObject:contactInfo];
        else
            [contactsAddressBook addObject:contactInfo];
        
        ABMutableMultiValueRef phoneNumbers = ABRecordCopyValue(person, kABPersonPhoneProperty);
        CFIndex phoneNumberCount = ABMultiValueGetCount( phoneNumbers );
        
        for (int k=0; k<phoneNumberCount; k++ )
        {
            CFStringRef phoneNumberLabel = ABMultiValueCopyLabelAtIndex( phoneNumbers, k );
            CFStringRef phoneNumberValue = ABMultiValueCopyValueAtIndex( phoneNumbers, k );
            
            NSString *strPhoneNoValue = [NSString stringWithFormat:@"%@",phoneNumberValue];
            strPhoneNoValue = [strPhoneNoValue stringByReplacingOccurrencesOfString:@" " withString:@""];
            strPhoneNoValue = [strPhoneNoValue stringByReplacingOccurrencesOfString:@"(" withString:@""];
            strPhoneNoValue = [strPhoneNoValue stringByReplacingOccurrencesOfString:@")" withString:@""];
            strPhoneNoValue = [strPhoneNoValue stringByReplacingOccurrencesOfString:@"-" withString:@""];
            strPhoneNoValue = [strPhoneNoValue stringByReplacingOccurrencesOfString:@"\u00a0" withString:@""];
            
            if (![self validatePhoneNumberWithString:strPhoneNoValue] ){
                DDLogError(@"%s, Invalid Entry %@:%@",__PRETTY_FUNCTION__, contactFirstLast, strPhoneNoValue );
                //remove object invalid phone number here
                for (NSDictionary *contactBooks in contactsAddressBook) {
                    if ([[contactBooks objectForKey:@"mobile"] isEqualToString:strPhoneNoValue]) {
                        [contactsAddressBook removeObject:contactBooks];
                    }
                }
                for (NSDictionary *contactBooks in symbolicContactsAddressBook) {
                    if ([[contactBooks objectForKey:@"mobile"] isEqualToString:strPhoneNoValue]) {
                        [symbolicContactsAddressBook removeObject:contactBooks];
                    }
                }
                continue;
            }

            //strPhoneNoValue = [self handlePhoneNumber:strPhoneNoValue];
            strPhoneNoValue = [self handlePhoneNumber:strPhoneNoValue countryCode:[countryNameWithDialCode objectForKey:kCOUNTRY_CODE]];
            
            [phoneNumbersList addObject:strPhoneNoValue];

            if (phoneNumberLabel)
                CFRelease(phoneNumberLabel);
            
            if(phoneNumberValue)
                CFRelease(phoneNumberValue);
        }
        
        if(phoneNumbers)
            CFRelease(phoneNumbers);
        
        }
         CFRelease(phones);
    }
    
    
    CFRelease(addressBook);
    
}

-(NSString*)handlePhoneNumber:(NSString*)phoneNumber countryCode:(NSString*)countryCode{

    NBPhoneNumberUtil *phoneUtil = [[NBPhoneNumberUtil alloc] init];
    NSError *anError = nil;
    NBPhoneNumber *myNumber = [phoneUtil parse:phoneNumber
                                 defaultRegion:countryCode error:&anError];
//    if (anError == nil) {
//        // Should check error
//        NSLog(@"isValidPhoneNumber ? [%@]", [phoneUtil isValidNumber:myNumber] ? @"YES":@"NO");
//        
//        // E164          : +436766077303
//        NSLog(@"E164          : %@", [phoneUtil format:myNumber
//                                          numberFormat:NBEPhoneNumberFormatE164
//                                                 error:&anError]);
//        // INTERNATIONAL : +43 676 6077303
//        NSLog(@"INTERNATIONAL : %@", [phoneUtil format:myNumber
//                                          numberFormat:NBEPhoneNumberFormatINTERNATIONAL
//                                                 error:&anError]);
//        // NATIONAL      : 0676 6077303
//        NSLog(@"NATIONAL      : %@", [phoneUtil format:myNumber
//                                          numberFormat:NBEPhoneNumberFormatNATIONAL
//                                                 error:&anError]);
//        // RFC3966       : tel:+43-676-6077303
//        NSLog(@"RFC3966       : %@", [phoneUtil format:myNumber
//                                          numberFormat:NBEPhoneNumberFormatRFC3966
//                                                 error:&anError]);
//    } else {
//        NSLog(@"Error : %@", [anError localizedDescription]);
//    }
    
    NSString *latestPhoneNumber = [NSString stringWithFormat:@"%@%@", myNumber.countryCode , myNumber.nationalNumber];
    
    if (!myNumber) {
        return phoneNumber;
    }else{
        //DDLogInfo(@"Phone Number : %@", latestPhoneNumber);
        return latestPhoneNumber;
    }
}

-(NSString *)handlePhoneNumber:(NSString *)phoneNumber
{
    if (!phoneNumber) {
        DDLogError(@"Your phone number is nil");
        return nil;
    }
    
    if ([phoneNumber isEqualToString:@""]) {
        DDLogError(@"Your phone number is invalid");
        return @"";
    }
    
    phoneNumber = [phoneNumber stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    //Add dialcode for phonenumber here
    if (!countryNameWithDialCode) {
          countryNameWithDialCode = [[ProfileAdapter share] getCurrentCountryNameWithDialCode];
    }
    NSString *dialCode = [countryNameWithDialCode objectForKey:kDIAL_CODE];
    
    if ([dialCode isEqualToString:kUNKNOWN])
        return phoneNumber;
    
    NSString *result = phoneNumber;
    if([phoneNumber rangeOfString:@"0"].location == 0) // case 0xxx > [dialCode]xxx
    {
        NSRange range = NSMakeRange(0,1);
        result = [phoneNumber stringByReplacingCharactersInRange:range withString:dialCode];
    }else if ([phoneNumber rangeOfString:@"+"].location == 0){ // case +84xxx > 84xxx
        NSRange range = NSMakeRange(0,1);
        result = [phoneNumber stringByReplacingCharactersInRange:range withString:@""];
    }else{
        if ([phoneNumber rangeOfString:dialCode].location == 0) { /// case 84xxx > 84xxx
            result = phoneNumber;
        }
    }
    
    return result;
}


-(BOOL) validatePhoneNumberWithString:(NSString *)aString{
    NSString * const regularExpression = REGEX_PHONE_NUMBER;
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regularExpression
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    if (error) {
        DDLogError(@"%s: %@",__PRETTY_FUNCTION__,[error localizedDescription]);
    }
    
    NSUInteger numberOfMatches = [regex numberOfMatchesInString:aString
                                                        options:0
                                                          range:NSMakeRange(0, [aString length])];
    return (numberOfMatches > 0);
}

#pragma mark contact methods
-(BOOL) setContactAvatar:(NSString*)jid data:(NSData*) avatarData{
    
    if (jid.length == 0) {
        DDLogError(@"%s: jid NULL", __PRETTY_FUNCTION__);
        return FALSE;
    }
    if (avatarData.length == 0) {
        DDLogError(@"%s: avatarData NULL", __PRETTY_FUNCTION__);
        return FALSE;
    }
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* folderPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:CONTACT_AVATAR_FOLDERNAME];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:folderPath])
        [[NSFileManager defaultManager] createDirectoryAtPath:folderPath
                                  withIntermediateDirectories:NO
                                                   attributes:nil
                                                        error:nil];
    
    NSString* filePath = [folderPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg",jid]];
    BOOL writeSuccess = [avatarData writeToFile:filePath atomically:YES];
    if(!writeSuccess)
        DDLogError(@"%s: write Avatar of %@ FAILED",__PRETTY_FUNCTION__, jid);
    return writeSuccess;
}

-(NSData*) getContactAvatar:(NSString*)jid{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* folderPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:CONTACT_AVATAR_FOLDERNAME];
    if(!folderPath || [folderPath isEqualToString:@""]){
        DDLogError(@"%s: Avatar link is not set", __PRETTY_FUNCTION__);
        return NULL;
    }
    
    NSString* filePath = [folderPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg",jid]];
    NSFileManager* fileManager = [NSFileManager defaultManager];
    BOOL success = [fileManager fileExistsAtPath:filePath];
    if(!success){
        DDLogError(@"%s: Contact Avatar (jid: %@) file is not existed", __PRETTY_FUNCTION__, jid);
        return NULL;
    }
    NSData* returnData = [NSData dataWithContentsOfFile:filePath];
    return returnData;
}

#pragma mark API methods of add friend
void (^requestCompleteCallBack)(BOOL success, NSString *message ,NSDictionary *response, NSError *error);


-(void)synchronizeBlockList:(NSDictionary*)parametersDic
                   callback:(requestCompleteBlock)callback{
    if (!parametersDic) {
        DDLogError(@"%s: parametersDic NULL.", __PRETTY_FUNCTION__);
        return;
    }
    void (^synchronizeBlockListCallBack)(BOOL success, NSString *message ,
                                         NSDictionary *response, NSError *error);
    
    synchronizeBlockListCallBack = callback;
    NSMutableDictionary *parameters = [parametersDic mutableCopy];
    [parameters setObject:API_SYNCHRONIZE_BLOCK_LIST forKey:kAPI];
    [parameters setObject:API_SYNCHRONIZE_BLOCK_LIST_VERSION forKey:kAPI_VERSION];
    
    [[ContactServerAdapter share] requestService:parameters
                                    tenantServer:YES
                                        callback:^(BOOL success, NSString *message, NSDictionary *response, NSError *error) {
        if (success) {
            DDLogInfo(@"%s: SUCCESS", __PRETTY_FUNCTION__);
            synchronizeBlockListCallBack(YES, @"synchronize block list successfully.", response, nil);
        }else{
            DDLogError(@"%s: FAILED", __PRETTY_FUNCTION__);
            synchronizeBlockListCallBack(NO, @"synchronize block list failed.", response, error);
        }
    }];
    
}

-(void)getFriendInformation:(NSDictionary*)parametersDic callback:(requestCompleteBlock)callback{
    if (!parametersDic) {
        DDLogError(@"%s: parametersDic NULL.", __PRETTY_FUNCTION__);
        return;
    }
    void (^getFriendInformationCallBack)(BOOL success, NSString *message ,NSDictionary *response, NSError *error);
    getFriendInformationCallBack =  callback;
    NSMutableDictionary *parameters = [parametersDic mutableCopy];
    [parameters setObject:API_GET_FRIEND_INFO forKey:kAPI];
    [parameters setObject:API_GET_FRIEND_INFO_VERSION forKey:kAPI_VERSION];
    
    [[ContactServerAdapter share] requestService:parameters tenantServer:NO callback:^(BOOL success, NSString *message, NSDictionary *response, NSError *error) {
        if (success) {
            DDLogInfo(@"%s: SUCCESS", __PRETTY_FUNCTION__);
            getFriendInformationCallBack(YES, @"Get friend information successfully.", response, nil);
        }else{
            DDLogError(@"%s: FAILED", __PRETTY_FUNCTION__);
            getFriendInformationCallBack(NO, @"Get friend information failed.", response, error);
        }
    }];
    
}

- (void)getFriendvCard:(NSDictionary *)parametersDic callback:(requestCompleteBlock)callback
{
    if (!parametersDic) {
        DDLogError(@"%s: parametersDic NULL.", __PRETTY_FUNCTION__);
        return;
    }
    void (^getFriendvCardCallBack)(BOOL success, NSString *message ,NSDictionary *response, NSError *error);
    getFriendvCardCallBack = callback;
    NSMutableDictionary *parameters = [parametersDic mutableCopy];
    [parameters setObject:API_GET_VCARD forKey:kAPI];
    [parameters setObject:API_GET_VCARD_VERSION forKey:kAPI_VERSION];
    
    [[ContactServerAdapter share] requestService:parameters tenantServer:YES callback:^(BOOL success, NSString *message, NSDictionary *response, NSError *error) {
        if (success) {
            DDLogInfo(@"%s: SUCCESS", __PRETTY_FUNCTION__);
            getFriendvCardCallBack(YES, @"Get vCard successfully.", response, nil);
        }else{
            DDLogError(@"%s: FAILED", __PRETTY_FUNCTION__);
            getFriendvCardCallBack(NO, @"Get vCard failed.", response, error);
        }
    }];
}

-(void)checkIdentity:(NSDictionary*)parametersDic callback:(requestCompleteBlock)callback{
    if (!parametersDic) {
        DDLogError(@"%s: parametersDic NULL.", __PRETTY_FUNCTION__);
        return;
    }
    void (^checkIdentityCallBack)(BOOL success, NSString *message ,NSDictionary *response, NSError *error);
    checkIdentityCallBack =  callback;
    NSMutableDictionary *parameters = [parametersDic mutableCopy];
    [parameters setObject:API_CHECK_IDENTITY forKey:kAPI];
    [parameters setObject:API_CHECK_IDENTITY_VERSION forKey:kAPI_VERSION];
    
    [[ContactServerAdapter share] requestService:parameters tenantServer:NO callback:^(BOOL success, NSString *message, NSDictionary *response, NSError *error) {
        if (success) {
            DDLogInfo(@"%s: SUCCESS", __PRETTY_FUNCTION__);
            checkIdentityCallBack(YES, @"Check Identity successfully.", response, nil);
        }else{
            DDLogError(@"%s: FAILED", __PRETTY_FUNCTION__);
            checkIdentityCallBack(NO, @"Check Identity failed.", response, error);
        }
    }];
    
}

-(void)getIdentity:(NSDictionary*)parametersDic callback:(requestCompleteBlock)callback{
    if (!parametersDic) {
        DDLogError(@"%s: parametersDic NULL.", __PRETTY_FUNCTION__);
        return;
    }
    void (^getIdentityCallBack)(BOOL success, NSString *message ,NSDictionary *response, NSError *error);
    getIdentityCallBack =  callback;
    NSMutableDictionary *parameters = [parametersDic mutableCopy];
    [parameters setObject:API_GET_IDENTITY forKey:kAPI];
    [parameters setObject:API_GET_IDENTITY_VERSION forKey:kAPI_VERSION];
    
    [[ContactServerAdapter share] requestService:parameters tenantServer:NO callback:^(BOOL success, NSString *message, NSDictionary *response, NSError *error) {
        if (success) {
            DDLogInfo(@"%s: SUCCESS", __PRETTY_FUNCTION__);
            getIdentityCallBack(YES, @"Get Identity successfully.", response, nil);
        }else{
            DDLogError(@"%s: FAILED", __PRETTY_FUNCTION__);
            getIdentityCallBack(NO, @"Get Identity failed.", response, error);
        }
    }];
}

-(void)approveIdentity:(NSDictionary*)parametersDic callback:(requestCompleteBlock)callback{
    if (!parametersDic) {
        DDLogError(@"%s: parametersDic NULL.", __PRETTY_FUNCTION__);
        return;
    }
    void (^approveIdentityCallBack)(BOOL success, NSString *message ,NSDictionary *response, NSError *error);
    approveIdentityCallBack =  callback;
    NSMutableDictionary *parameters = [parametersDic mutableCopy];
    [parameters setObject:API_APPROVE_IDENTITY forKey:kAPI];
    [parameters setObject:API_APPROVE_IDENTITY_VERSION forKey:kAPI_VERSION];
    
    [[ContactServerAdapter share] requestService:parameters tenantServer:YES callback:^(BOOL success, NSString *message, NSDictionary *response, NSError *error) {
        if (success) {
            DDLogInfo(@"%s: SUCCESS", __PRETTY_FUNCTION__);
            approveIdentityCallBack(YES, @"Approve Identity successfully.", response, nil);
        }else{
            DDLogError(@"%s: FAILED", __PRETTY_FUNCTION__);
            approveIdentityCallBack(NO, @"Approve Identity failed.", response, error);
        }
    }];
}

-(void)rejectIdentity:(NSDictionary*)parametersDic callback:(requestCompleteBlock)callback{
    if (!parametersDic) {
        DDLogError(@"%s: parametersDic NULL.", __PRETTY_FUNCTION__);
        return;
    }
    void (^rejectIdentityCallBack)(BOOL success, NSString *message ,NSDictionary *response, NSError *error);
    rejectIdentityCallBack =  callback;
    NSMutableDictionary *parameters = [parametersDic mutableCopy];
    [parameters setObject:API_REJECT_IDENTITY forKey:kAPI];
    [parameters setObject:API_REJECT_IDENTITY_VERSION forKey:kAPI_VERSION];
    
    [[ContactServerAdapter share] requestService:parameters tenantServer:YES callback:^(BOOL success, NSString *message, NSDictionary *response, NSError *error) {
        if (success) {
            DDLogInfo(@"%s: SUCCESS", __PRETTY_FUNCTION__);
            rejectIdentityCallBack(YES, @"Reject Identity successfully.", response, nil);
        }else{
            DDLogError(@"%s: FAILED", __PRETTY_FUNCTION__);
            rejectIdentityCallBack(NO, @"Reject Identity failed.", response, error);
        }
    }];

}

-(void)getFriendPublicKey:(NSDictionary*)parametersDic callback:(requestCompleteBlock)callback{
    if (!parametersDic) {
        DDLogError(@"%s: parametersDic NULL.", __PRETTY_FUNCTION__);
        return;
    }
    void (^getFriendPublicKeyCallBack)(BOOL success, NSString *message ,NSDictionary *response, NSError *error);
    getFriendPublicKeyCallBack =  callback;
    NSMutableDictionary *parameters = [parametersDic mutableCopy];
    [parameters setObject:API_GET_FRIEND_PUBLIC_KEY forKey:kAPI];
    [parameters setObject:API_GET_FRIEND_PUBLIC_KEY_VERSION forKey:kAPI_VERSION];
    
    [[ContactServerAdapter share] requestService:parameters tenantServer:NO callback:^(BOOL success, NSString *message, NSDictionary *response, NSError *error) {
        if (success) {
            DDLogInfo(@"%s: SUCCESS", __PRETTY_FUNCTION__);
            getFriendPublicKeyCallBack(YES, @"Get friend public key successfully.", response, nil);
        }else{
            DDLogError(@"%s: FAILED", __PRETTY_FUNCTION__);
            getFriendPublicKeyCallBack(NO, @"Get friend public key failed.", response, error);
        }
    }];

}

-(void)searchFriendByMaskingId:(NSDictionary*)parametersDic callback:(requestCompleteBlock)callback{
    if (!parametersDic) {
        DDLogError(@"%s: parametersDic NULL.", __PRETTY_FUNCTION__);
        return;
    }
    void (^searchFriendByMaskingIdCallBack)(BOOL success, NSString *message ,NSDictionary *response, NSError *error);
    searchFriendByMaskingIdCallBack =  callback;
    NSMutableDictionary *parameters = [parametersDic mutableCopy];
    [parameters setObject:API_SEARCH_FRIENDS forKey:kAPI];
    [parameters setObject:API_SEARCH_FRIENDS_VERSION forKey:kAPI_VERSION];
    
    [[ContactServerAdapter share] requestService:parameters tenantServer:YES callback:^(BOOL success, NSString *message, NSDictionary *response, NSError *error) {
        if (success) {
            DDLogInfo(@"%s: SUCCESS", __PRETTY_FUNCTION__);
            searchFriendByMaskingIdCallBack(YES, @"Search friends successfully.", response, nil);
        }else{
            DDLogError(@"%s: FAILED", __PRETTY_FUNCTION__);
            searchFriendByMaskingIdCallBack(NO, @"Search friend by maskind id failed.", response, error);
        }
    }];

}

-(void)searchContactsTenant:(NSDictionary*)parametersDic callback:(requestCompleteBlock)callback{
    if (!parametersDic) {
        DDLogError(@"%s: parametersDic NULL.", __PRETTY_FUNCTION__);
        return;
    }
    void (^searchContactsTenantCallBack)(BOOL success, NSString *message ,NSDictionary *response, NSError *error);
    searchContactsTenantCallBack =  callback;
    NSMutableDictionary *parameters = [parametersDic mutableCopy];
    [parameters setObject:API_SEARCH_CONTACTS forKey:kAPI];
    [parameters setObject:API_SEARCH_CONTACTS_VERSION forKey:kAPI_VERSION];
    
    [[ContactServerAdapter share] requestService:parameters tenantServer:YES callback:^(BOOL success, NSString *message, NSDictionary *response, NSError *error) {
        if (success) {
            DDLogInfo(@"%s: SUCCESS", __PRETTY_FUNCTION__);
            searchContactsTenantCallBack(YES, @"Search contacts successfully.", response, nil);
        }else{
            DDLogError(@"%s: FAILED", __PRETTY_FUNCTION__);
            searchContactsTenantCallBack(NO, @"Search contacts failed.", response, error);
        }
    }];
}

-(void)removeFriendByMaskingId:(NSDictionary*)parametersDic callback:(requestCompleteBlock)callback{
    if (!parametersDic) {
        DDLogError(@"%s: parametersDic NULL.", __PRETTY_FUNCTION__);
        return;
    }
    void (^removeFriendByMaskingIdCallBack)(BOOL success, NSString *message ,NSDictionary *response, NSError *error);
    removeFriendByMaskingIdCallBack =  callback;
    NSMutableDictionary *parameters = [parametersDic mutableCopy];
    [parameters setObject:API_REMOVE_FRIEND forKey:kAPI];
    [parameters setObject:API_REMOVE_FRIEND_VERSION forKey:kAPI_VERSION];
    
    [[ContactServerAdapter share] requestService:parameters tenantServer:YES callback:^(BOOL success, NSString *message, NSDictionary *response, NSError *error) {
        if (success) {
            DDLogInfo(@"%s: SUCCESS", __PRETTY_FUNCTION__);
            removeFriendByMaskingIdCallBack(YES, @"Remove friend successfully.", response, nil);
        }else{
            DDLogError(@"%s: FAILED", __PRETTY_FUNCTION__);
            removeFriendByMaskingIdCallBack(NO, @"Remove friend failed.", response, error);
        }
    }];
}

-(void)httpFriendRequest:(NSDictionary*)parametersDic callback:(requestCompleteBlock)callback{
    
    if (!parametersDic) {
        DDLogError(@"%s: parametersDic NULL.", __PRETTY_FUNCTION__);
        return;
    }
    void (^httpFriendRequestCallBack)(BOOL success, NSString *message ,NSDictionary *response, NSError *error);
    httpFriendRequestCallBack =  callback;
    NSMutableDictionary *parameters = [parametersDic mutableCopy];
    [parameters setObject:API_HTTP_FRIEND_REQUEST forKey:kAPI];
    [parameters setObject:API_HTTP_FRIEND_REQUEST_VERSION forKey:kAPI_VERSION];
    
    [[ContactServerAdapter share] requestService:parameters tenantServer:YES callback:^(BOOL success, NSString *message, NSDictionary *response, NSError *error) {
        if (success) {
            DDLogInfo(@"%s: SUCCESS", __PRETTY_FUNCTION__);
            httpFriendRequestCallBack(YES, @"Call http friend request successfully.", response, nil);
        }else{
            DDLogError(@"%s: FAILED", __PRETTY_FUNCTION__);
            httpFriendRequestCallBack(NO, @"Call http friend request failed.", response, error);
        }
    }];

}

-(void)httpFriendRequestResponse:(NSDictionary*)parametersDic callback:(requestCompleteBlock)callback{
    
    if (!parametersDic) {
        DDLogError(@"%s: parametersDic NULL.", __PRETTY_FUNCTION__);
        return;
    }
    void (^httpFriendRequestResponseCallBack)(BOOL success, NSString *message ,NSDictionary *response, NSError *error);
    httpFriendRequestResponseCallBack =  callback;
    NSMutableDictionary *parameters = [parametersDic mutableCopy];
    [parameters setObject:API_HTTP_FRIEND_REQUEST_RESPONSE forKey:kAPI];
    [parameters setObject:API_HTTP_FRIEND_REQUEST_RESPONSE_VERSION forKey:kAPI_VERSION];
    
    [[ContactServerAdapter share] requestService:parameters tenantServer:YES callback:^(BOOL success, NSString *message, NSDictionary *response, NSError *error) {
        if (success) {
            DDLogInfo(@"%s: SUCCESS", __PRETTY_FUNCTION__);
            httpFriendRequestResponseCallBack(YES, @"Call http friend request response successfully.", response, nil);
        }else{
            DDLogError(@"%s: FAILED", __PRETTY_FUNCTION__);
            httpFriendRequestResponseCallBack(NO, @"Call http friend request response failed.", response, error);
        }
    }];
}

-(void)httpFriendRequestList:(NSDictionary*)parametersDic callback:(requestCompleteBlock)callback{
    if (!parametersDic) {
        DDLogError(@"%s: parametersDic NULL.", __PRETTY_FUNCTION__);
        return;
    }
    void (^httpFriendRequestListCallBack)(BOOL success, NSString *message ,NSDictionary *response, NSError *error);
    httpFriendRequestListCallBack =  callback;
    NSMutableDictionary *parameters = [parametersDic mutableCopy];
    [parameters setObject:API_HTTP_FRIEND_REQUEST_LIST forKey:kAPI];
    [parameters setObject:API_HTTP_FRIEND_REQUEST_LIST_VERSION forKey:kAPI_VERSION];
    
    [[ContactServerAdapter share] requestService:parameters tenantServer:YES callback:^(BOOL success, NSString *message, NSDictionary *response, NSError *error) {
        if (success) {
            DDLogInfo(@"%s: SUCCESS", __PRETTY_FUNCTION__);
            httpFriendRequestListCallBack(YES, @"Call http friend request List successfully.", response, nil);
        }else{
            DDLogError(@"%s: FAILED", __PRETTY_FUNCTION__);
            httpFriendRequestListCallBack(NO, @"Call http friend request list failed.", response, error);
        }
    }];
}

-(void)getTransactionHistory:(NSDictionary*)parametersDic callback:(requestCompleteBlock)callback{
    if (!parametersDic) {
        DDLogError(@"%s: parametersDic NULL.", __PRETTY_FUNCTION__);
        return;
    }
    void (^getTransactionHistoryCallBack)(BOOL success, NSString *message ,NSDictionary *response, NSError *error);
    getTransactionHistoryCallBack =  callback;
    NSMutableDictionary *parameters = [parametersDic mutableCopy];
    [parameters setObject:API_GET_TRANSACTION_HISTORY forKey:kAPI];
    [parameters setObject:API_GET_TRANSACTION_HISTORY_VERSION forKey:kAPI_VERSION];
    
    [[ContactServerAdapter share] requestService:parameters tenantServer:YES callback:^(BOOL success, NSString *message, NSDictionary *response, NSError *error) {
        if (success) {
            DDLogInfo(@"%s: SUCCESS", __PRETTY_FUNCTION__);
            getTransactionHistoryCallBack(YES, @"Get transaction history successfully.", response, nil);
        }else{
            DDLogError(@"%s: FAILED", __PRETTY_FUNCTION__);
            getTransactionHistoryCallBack(NO, @"Get transaction history failed.", response, error);
        }
    }];
}

@end
