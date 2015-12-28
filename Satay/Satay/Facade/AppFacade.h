//
//  AppFacade.h
//  Satay
//
//  Created by TrungVN on 1/20/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <DBDomain/DBControl.h>
#import <NotifyDomain/NotifyDomain.h>
#import <ChatDomain/ChatDomain.h>
#import <SecurityDomain/SecurityDomain.h>
#import <NoteDomain/NoteDomain.h>

#import "XMPPFacade.h"
#import "ContactFacade.h"
#import "ChatFacade.h"
#import "EmailFacade.h"
#import "NotificationFacade.h"
#import "SecureNoteFacade.h"
#import "LogFacade.h"
#import "SIPFacade.h"
#import "SocialFacade.h"

#define kFILE @"FILE"
#define FIRSTRUN @"FIRSTRUN"

#define kUPLOAD_TYPE_USER_TO_USER 1
#define kUPLOAD_TYPE_USER_TO_MUC 2
#define kUPLOAD_TYPE_LOGO_MUC 3
//Keys pair define
#define kMOD1_MODULUS @"PUB1_N"
#define kMOD1_EXPONENT @"PUB1_E"
#define kMOD1_PRIVATE @"PUB1_P"
#define kMOD2_MODULUS @"PUB2_N"
#define kMOD2_EXPONENT @"PUB2_E"
#define kMOD2_PRIVATE @"PUB2_P"
#define kMOD3_MODULUS @"PUB3_N"
#define kMOD3_EXPONENT @"PUB3_E"
#define kMOD3_PRIVATE @"PUB3_P"
#define kS_KEY_VERSION @"VERSION"

//Login
#define kCOUNT_ENTER_WRONG_PWD @"COUNT_ENTER_WRONG_PWD"

//Setting acc
#define kENABLE_PASSWORD_LOCK @"ENABLE_PASSWORD_LOCK"

//Retry time
#define kRETRY_API_COUNTER @"5"
#define kRETRY_OPERATION @"RETRY_OPERATION"
#define kRETRY_TIME @"RETRY_TIME"
#define IS_OS_8_OR_LATER (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1)
#define ERROR_CODE_TOKEN_NOT_FOUND 4004
#define ERROR_CODE_EXPIRED_COMMAND_TOKEN_TENANT 4005
#define ERROR_CODE_EXPIRED_COMMAND_TOKEN_CENTRAL 20005
#define ERROR_CODE_INVALID_TOKEN 2003
typedef enum
{
    typeCaptureVideo = 1,
    typeCaptureImage = 2,
    typeVideoLibrary = 3,
    typePhotoLibrary = 4,
} CameraAccessType;

@interface AppFacade : NSObject {
    NSObject <ChatViewDelegate> *chatViewDelegate;
    NSObject <CWindowDelegate> *windowDelegate;
    NSObject <ContactInfoDelegate> *contactInfoDelegate;
    NSObject <AppSettingDelegate> *appSettingDelegate;
}
@property (nonatomic, retain) NSObject* chatViewDelegate;
@property (nonatomic, retain) NSObject* windowDelegate;
@property (nonatomic, retain) NSObject* contactInfoDelegate;
@property (nonatomic, retain) NSObject* appSettingDelegate;

/*
 * singleton of this file.
 * @Author TrungVN
*/
+(AppFacade *)share;
/*
 * Create local master key
 * @Author TrungVN
 */
-(void) createLocalKey;
/*
 * Reset local master key
 * @Author TrungVN
 */
-(void) resetLocalKey:(NSString*) oldPassword;
/*
 *Encrypt data of file locally
 * @Author TrungVN
 */
-(NSData*) encryptDataLocally:(NSData*) inputData;
/*
 *Decrypt data of file locally
 * @Author TrungVN
 */
-(NSData*) decryptDataLocally:(NSData*) inputData;
/*
 * Open or Create sqlite DB, name of DB default is "Satay"
 * @Author TrungVN
 */
-(void) connectDB;
/*
 * checkFirstRun of application
 * @Author TrungVN
 * If application first installed >> the default keystore in keychain will be reset all.
 */
-(void) checkFirstRun;
/*
 * getChatBox object from DB client
 * input param is chatboxId of ChatBox*
 * return nil or ChatBox* if have
 * @Author TrungVN
 */
-(ChatBox*) getChatBox:(NSString*) chatboxId;
/*
 * getMessage object from DB client
 * input param is messageId of Message* object
 * return nil or Message* if have
 * @Author TrungVN
 */
-(Message*) getMessage:(NSString*) messageId;
/*
 * getKey object from DB client
 * input param is keyId of Key* object
 * return nil or Key* if have
 * @Author TrungVN
 */
-(Key*) getKey:(NSString*) keyId;

/**
 *  @author Daniel Nguyen, 15-04-08 11:04
 *  @brief  get Key object from DB client, for group chat because a group can be store many key items in Key table
 *  @param keyId       keyId of Key* object
 *  @param key_version keyVersion for Key* object
 *  @return return nil or Key* if have
 */
-(Key*) getKeyForGroup:(NSString*)keyId
            andVersion:(NSString *)key_version;

/**
 *  @description:  get all group keys version of one group
 *  @author: Parker, 15-06-10
 *  @param keyId  is group id
 *  @return return NSArray
 */
-(NSArray*) getAllGroupKeys:(NSString*) keyId;

/**
 *  @author Daniel Nguyen, 15-04-08 11:04
 *  @brief  get latest Key object from DB client
 *  @param keyId keyId of Key* object
 *  @return return nil or Key* if have
 */
-(Key*) getLatestKeyForGroup:(NSString*)keyId;

/*
 * get GroupObj object from DB client
 * input param is groupId of ChatBox*
 * return nil or GroupObj* if have
 * @Author Daniel
 */
- (GroupObj *)getGroupObj:(NSString *)groupId;
/*
 * get GroupMember object from DB client
 * input param is groupId of ChatBox* and userJID of Contact*.
 * return nil or GroupMember* if have
 * @Author Daniel
 * @TrungVN Comment
 */
- (GroupMember*) getGroupMember:(NSString*) groupId
                        userJID:(NSString*) userJID;

/**
 *  Delelte all tables in database when reset account
 *  Author: Violet
 */
-(void) deleteAllTablesDB;

/**
 *  Get password lock flag
 *  Returns 'YES' if password lock is enable, else returns 'NO'
 *  Author:Violet
 */
-(NSString*)getPasswordLockFlag;

/**
 *  Set passoword lock flag
 *  Author: Violet
 */
-(void)setPasswordLockFlag:(NSString*)value;

/**
 *  Get value of cound wrong passwork key
 *  Author:Violet
 */
-(NSString*)getCountWrongPasswordKey;

/**
 *  Set value for count wrong password key
 *  Author: Violet
 */
-(void)setCountWrongPasswordKey:(NSString*)value;

/**
 *  Remove count wrong password key
 *  Author: Violet
 */
-(void)removeCountWrongPasswordKey;

/**
 *  Reload Setting view controller
 *  Author: Violet
 */
-(void) reloadSettingViewController;

/**
 *  Check string if it match with regular expression
 *  Author: Daryl
 */
-(BOOL)checkString: (NSString *)string withRegularExpression:(NSString *)RegEx;

/*
 * If token using in api fail, this function will be called to download new token
 * Authour: Jurian
 * Sample Parameter
 kTARGET : self,
 kPARAMATER:@{kRETRY_ONE_PARAMATER:bobMaskindId}};
 */
-(void)downloadTokenAgain:(NSDictionary*)retryInfo;

/*
 * Call retry download successful.
 * Authour: Jurian
 */
- (void)callRetryFunctionAfterSuccessful:(NSDictionary*)retryInfo;

/*
 * Add blackView to prevent user get data from snapshot.
 * Authour: Jurian
 */
- (void)addBlankViewForSnapShotPrevention:(UIWindow*)window ;

/*
 * Remove blackView when user use app again
 * Authour: Jurian
 */
- (void)removeBlankViewForSnapShotPrevention:(UIWindow*)window;

/*
 * Remove cache database inside application for fixing security issue.
 * Task 11232:[iOS][Security Issues] - SCD-014 (Medium risk) Cached data information leakage
 * Authour: Jurian
 */
-(void)removeCacheDataInsideApp;

/*
 * Reupload passcode to server incase user update offline or upload passcode unsuccesful.
 * Authour: Jurian
 */
- (void)callReUploadPasscodeToServer;

/*
 * Check if user is running in Jailbroken device or not.
 * Task 11308:[iOS] - CASE 12 - Security Issue - Application continues to work on Jailbroken/Rooted device
 * Authour: Jurian
 */
+(BOOL)isJailbroken;

/**
 Comparing two versions and returning the result of the comparision.
 @param strVer1 the first version
 @param strVer2 the second version
 @return -1 if (strVer1 older than strVer2), 0 if (strVer1 equals to strVer2), and 1 if (strVer1 newer than strVer2)
 @author Ashkan Ferdowsi
 */
-(int) compareVersion: (NSString*) strVer1 withVersion: (NSString*) strVer2;

/*
 * Check if string contain weblink or not.
 * Authour: Daryl
 */
-(BOOL)isStringContainWebLink:(NSString*) str;
/*
 * Check if string contain phone number or not.
 * Authour: Daryl
 */
-(BOOL)isStringContainPhoneNumber:(NSString *)str;

/*
 * preprocess all response before continue as usually flow.
 * Authour: Parker/TrungVN
 */
-(BOOL)preProcessResponse:(NSDictionary*)response;

/**
 * Execute a block in the background, and when it's finished, execute another block (UI..)
 * Author: Parker
 */
- (NSOperation *)executeBlock:(void (^)(void))block
                      inQueue:(NSOperationQueue *)queue
                   completion:(void (^)(BOOL finished))completion;

@end
