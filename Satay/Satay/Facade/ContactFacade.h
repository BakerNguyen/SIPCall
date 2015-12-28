//
//  ContactFacade.h
//  Satay
//
//  Created by enclave on 2/4/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ContactDomain/ContactDomain.h>

//Url krypto TNC
#define URL_TERMS_CONDITIONS @"http://www.onekrypto.com/tnc.html"

#define kACCOUNT_STATUS @"account_status"
#define ACCOUNT_ACTIVE @"active"
#define ACCOUNT_INACTIVE @"inactive"
#define ACCOUNT_PENDING @"pending"

//Define values for request method and request kind
#define POST @"POST"
#define GET @"GET"
#define PUT @"PUT"
#define DOWNLOAD @"Download"
#define UPLOAD @"Upload"
#define NORMAL @"Normal"

#define UPDATE @"UPDATE"
#define kSTATUS @"STATUS"
#define kVERSION @"VERSION"
#define kACTION @"ACTION"
#define kBLOCK_USERS @"BLOCK_USERS"
#define kUNBLOCK_USERS @"UNBLOCK_USERS"
//Define parameters for API
#define kIMEI @"IMEI"
#define kIMSI @"IMSI"
#define kPLATFORM @"PLATFORM"
#define kDEVICE_NAME @"DEVICE_NAME"
#define kOS_VERSION @"OS_VERSION"
#define kAPP_VERSION @"APP_VERSION"
#define kDEVICE_ID @"DEVICE_ID"
#define kCOUNTRY_CODE @"COUNTRY_CODE"
#define kTIMEZONE_OFFSET @"TIMEZONE_OFFSET"
#define kSERVICE_ID @"SERVICE_ID"
#define kXMPP_PSW_FLAG @"XMPPPSWFLAG"
#define kSOURCE_COUNTRY @"SOURCE_COUNTRY"
#define kMSISDN_LIST @"MSISDN_LIST"
#define kCODE @"CODE"
#define kOTPCode @"OTP"
#define kBLOCKED_JID_LIST @"BLOCKED_JID_LIST"

//Force Version
#define kFORCE_VERSION_IOS @"FORCE_VERSION_IOS"
#define APP_URL_IN_APP_STORE @"itms://itunes.com/apps/zipitchat"


#define kHOST @"HOST"// xmpp host. = JID_HOST
#define kHOSTMUC @"HOSTMUC"

#define APP_VERSION [NSString stringWithFormat:@"v%@.%@", [[NSBundle mainBundle]infoDictionary][@"CFBundleShortVersionString"], [[NSBundle mainBundle]infoDictionary][@"CFBundleVersion"]]
#define IOS_PLATFORM @"1"

//Account define
#define kJID @"JID"
#define kJID_PASSWORD @"JID_PASSWORD"
#define kJID_HOST @"JID_HOST"
#define kTOKEN @"TOKEN"
#define kCENTRALTOKEN @"CENTRALTOKEN"
#define kTENANTTOKEN @"TENANTTOKEN"
#define kENC_MASTER_KEY @"ENC_MASTER_KEY"
#define kDISPLAY_NAME @"DISPLAY_NAME"
#define kAVATAR @"AVATAR"
#define kPUSH_ID @"PUSH_ID"
#define kPASSWORD @"PASSWORD"
#define kREUPLOAD_PASSWORD @"REUPLOAD_PASSWORD"
#define kDEVICE_TOKEN @"DEVICE_TOKEN"
//Sync contact define
#define kMSISDN @"MSISDN"
#define kPHONE_NUMBER @"PHONE_NUMBER"
#define kCOUNTRY_CODE @"COUNTRY_CODE"
#define kDIAL_CODE @"DIAL_CODE"
#define kCOUNTRY_NAME @"COUNTRY_NAME"
#define kVERIFICATION_CODE @"VERIFICATION_CODE"
#define kOTP_MESSAGE_ID @"MESSAGE_ID"
#define kEXIST @"EXIST"
#define kUNKNOWN @"UNKNOWN"

//Reponse define.
#define kDATA @"DATA"
#define kVCARD @"VCARD"
#define kMEDIA @"MEDIA"
#define kDOWNLOAD_URL @"DOWNLOAD_URL"
#define kTHUMBNAIL @"THUMBNAIL"
#define kFILENAME @"FILENAME"
#define kFILESIZE @"FILESIZE"
#define kMIME_TYPE @"MIME_TYPE"

#define kKEY_VERSION @"KEY_VERSION"
//response account
#define kXMPP_PASSWORD @"XMPP_PASSWORD"
#define kXMPP_HOST @"XMPP_HOST"

//Define values for parameters of API http friend request
#define REQUEST @"REQUEST"
#define CANCEL @"CANCEL"
#define SMS_REQUEST @"SMS_REQUEST"
#define APPROVED @"APPROVED"
#define DENIED @"DENIED"
#define REMOVED @"REMOVED"

//search friend, add friend define for dic parameters
#define kFRIEND_MASKING_ID @"FRIENDMASKINGID"
#define kCMD @"CMD"
#define kRESPONSE @"RESPONSE"
#define kRECIPIENT_MSISDN @"RECIPIENTMSISDN"
#define kRECIPIENT_MASKING_ID @"RECIPIENTMASKINGID"
#define kBOB_MASKING_ID @"BOBMASKINGID"
#define kALICE_MASKING_ID @"ALICEMASKINGID"
#define kSENDERMASKINGID @"SENDERMASKINGID"
#define kACCOUNT @"ACCOUNT"
#define kSTATUS_DES @"STATUS_DESC"
#define kUSER_STATUS @"USER_STATUS"
#define kHASH @"HASH"
#define kGET_IDENTITY @"GET_IDENTITY"
#define kREQUEST_TAG @"kREQUEST_TAG"
#define kSUB_END_DATE @"SUB_END_DATE"
#define kSUB_START_DATE @"SUB_START_DATE"
#define kACCOUNT_URL @"URL"
#define kCONTACT_TYPE @"CONTACT_TYPE"
#define kCONTACT_TYPE_FRIEND 0
#define kCONTACT_TYPE_NOT_FRIEND 1
#define kCONTACT_TYPE_KRYPTO_USER 2
#define kCONTACT_STATE_ONLINE 0
#define kCONTACT_STATE_OFFLINE 1
#define kCONTACT_STATE_BLOCKED 2
#define kCONTACT_STATE_DELETED 3

//Transaction
#define kTRANSACTION_DATE @"transaction_date"
#define kSERVICE_SECTION @"service"
#define kTRANSACTION_METHOD @"transaction_method"
#define kAMOUNT @"amount"
#define KSTATUS_SECTION @"status"

//Remove
#define kIS_ACCOUNT_REMOVED @"IS_ACCOUNT_REMOVED"

#define ERROR_CODE_FRIEND_REQUEST_NOT_FOUND 4093
#define ERROR_CODE_FRIEND_REQUEST_DENIED 4094

// 0 = send, 1 = receive
#define kREQUEST_TYPE_SEND 0
#define kREQUEST_TYPE_RECEIVE 1

// 0 = pending, 1 = approved, 2 = denied
#define kREQUEST_STATUS_PENDING 0
#define kREQUEST_STATUS_APPROVED 1
#define kREQUEST_STATUS_DENY 2

// 0 = pending, 1 = approved, 2 = denied
#define kCHATBOX_STATE_DISPLAY 0
#define kCHATBOX_STATE_NOTDISPLAY 1

//Register
#define IS_YES @"YES"
#define IS_NO @"NO"
#define kIS_REGISTER @"IS_REGISTER"
#define kIS_FREE_TRIAL @"IS_FREE_TRIAL"
#define kIS_SYNC_CONTACT @"IS_SYNC_CONTACT"
#define kIS_ACCEPTED_TERM_AND_CONDITION @"IS_ACCEPTED_TERM_AND_CONDITION"

//API response
#define kSTATUS_CODE @"STATUS_CODE"
#define kSTATUS_MSG @"STATUS_MSG"

//Backup/Restore define
#define kBACKUP_FILE_VERSION @"backup_file_version"

#define kVersionKeyFormat @"com.mtouche.version.type"

//Define key for backup contact info
#define kCONTACT_JID @"JID"
#define kCONTACT_MASKINGID @"MASKING_ID"
#define kCONTACT_CUSTOMER_NAME @"CUSTOM_NAME"
#define kCONTACT_SERVER_MSISDN @"MSISDN"
#define kCONTACT_STATUS_MSG @"STATUS_MSG"
#define kCONTACT_CONTACT_TYPE @"CONTACT_TYPE"
#define kCONTACT_CONTACT_STATE @"CONTACT_STATE"
//Define key for backup contact key
#define kKEY_KEY_JSON @"KEY_JSON"
#define kKEY_KEY_VERSION @"KEY_VERSION"
//Define key for backup contact request
#define kREQUEST_REQUEST_TYPE @"REQUEST_TYPE"
#define kREQUEST_CONTENT @"REQUEST_CONTENT"
#define kREQUEST_STATUS @"REQUEST_STATUS"
//Define value of status backup api
#define PENDING @"PENDING"
#define RECEIVED @"RECEIVED"
#define STATUS_PENDING @"010"
#define STATUS_RECEIVED @"001"
#define STATUS_APPROVED @"100"
#define STATUS_APPROVED_AND_PENDING @"110"
#define STATUS_APPROVED_AND_PENDING_AND_RECEIVED @"111"

#define kBACKUP_VERSION @"VERSION"
#define kBACKUP_EMAIL_SETTING @"EMAIL_SETTING"
#define kBACKUP_KEYS @"MYPK"
#define kBACKUP_GROUP_KEYS @"GROUP_KEYS"

#define BACKUP_FILE_EXTENSION @"krypto"
#define kMASTERKEY @"MASTERKEY"
#define kIS_BACKUP_ACCOUNT @"IS_BACKUP_ACCOUNT"
#define kIS_UPDATED_PASS_BACKUP_FILE @"IS_UPDATED_PASS_BACKUP_FILE"
#define kIS_RE_LOGIN_ACCOUNT @"ISLOGIN"
#define kIS_RESTORE_ACCOUNT @"IS_RESTORE_ACCOUNT"
#define kIS_RESTORED_ALL_CONTACT @"IS_RESTORED_ALL_CONTACT"

//Limit passcode text
#define CHARACTER_LIMIT_PASSWORD 16

#define kRESEND_LIMIT @"RESEND_LIMIT"


typedef enum{
    UploadPasswordForRegister,
    UploadPasswordForChangePsw,
    UploadPasswordForEnablePswLock
} UploadPasswordToServerType;

typedef enum {
    LockAccess,
    LockChangePasscode,
    LockPasswordLock
} LockType;

@interface ContactFacade : NSObject{
    NSObject <ContactSearchMIDDelegate> *contactSearchMIDDelegate;
    NSObject <ContactHeaderDelegate> *contactHeaderDelegate;
    NSObject <ContactListDelegate> *contactListDelegate;
    NSObject <ContactRequestDelegate> *contactRequestDelegate;
    NSObject <ContactPendingDelegate> *contactPendingDelegate;
    NSObject <MyProfileDelegate> *myProfileDelegate;
    NSObject <DisplaynameDelegate> *displaynameDelegate;
    NSObject <StatusProfileDelegate> *statusProfileDelegate;
    NSObject <CheckMSISDNDelegate> *checkMSISDNDelegate;
    NSObject <UpdateMSISDNDelegate> *updateMSISDNDelegate;
    NSObject <SendVerificationCodeDelegate> *sendVerificationCodeDelegate;
    NSObject <SyncContactsDelegate> *syncContactDelegate;
    NSObject <ChatViewDelegate> *chatViewDelegate;
    NSObject <NewGroupViewDelegate> *NewGroupViewDelegate;
    NSObject <ContactPopupDelegate> *contactPopupDelegate;
    NSObject <ContactInfoDelegate> *contactInfoDelegate;
    NSObject <GetStartedDelegate> *getStartedDelegate;
    NSObject <RegisterAccountDelegate> *registerAccountDelegate;
    NSObject <SetPasswordDelegate> *setPasswordDelegate;
    NSObject <UploadKeysDelegate> *uploadKeysDelegate;
    NSObject <ContactBookDelegate> *contactBookDelegate;
    NSObject <ContactEditDelegate> *contactEditDelegate;
    NSObject <ChatComposeDelegate> *chatComposeDelegate;
    NSObject <FindEmailContact> *findEmailContactDelegate;
    NSObject <ForwardListDelegate> *forwardListDelegate;
    NSObject <ContactNotificationDelegate> *contactNotificationDelegate;
    NSObject <ChangePasswordDelegate> *changePasswordDelegate;
    NSObject <EnablePasswordLockDelegate> *enablePasswordLockDelegate;
    NSObject <NotificationListDelegate> *notificationListDelegate;
    NSObject <BlockUsersDelegate> *blockUsersDelegate;
    NSObject <UnblockUsersDelegate> *unblockUsersDelegate;
    NSObject <SignInAccountDelegate> *signInAccountDelegate;
    NSObject <VerificationDelegate> *verificationDelegate;
    NSObject <ChatListDelegate> *chatListDelegate;
    NSObject <WebMyAccountDelegate> *webMyAccountDelegate;
    NSObject <BlockUsersCellDelegate> *blockUsersCellDelegate;
    NSObject <ContactNotSyncDelegate> *contactNotSyncDelegate;
}
@property (nonatomic, retain) NSObject* contactSearchMIDDelegate;
@property (nonatomic, retain) NSObject* contactHeaderDelegate;
@property (nonatomic, retain) NSObject* contactListDelegate;
@property (nonatomic, retain) NSObject* contactRequestDelegate;
@property (nonatomic, retain) NSObject* contactPendingDelegate;
@property (nonatomic, retain) NSObject* myProfileDelegate;
@property (nonatomic, retain) NSObject* displaynameDelegate;
@property (nonatomic, retain) NSObject* statusProfileDelegate;
@property (nonatomic, retain) NSObject* checkMSISDNDelegate;
@property (nonatomic, retain) NSObject* updateMSISDNDelegate;
@property (nonatomic, retain) NSObject* sendVerificationCodeDelegate;
@property (nonatomic, retain) NSObject* syncContactDelegate;
@property (nonatomic, retain) NSObject* NewGroupViewDelegate;
@property (nonatomic, retain) NSObject* chatViewDelegate;
@property (nonatomic, retain) NSObject* contactPopupDelegate;
@property (nonatomic, retain) NSObject* contactInfoDelegate;
@property (nonatomic, retain) NSObject* getStartedDelegate;
@property (nonatomic, retain) NSObject* registerAccountDelegate;
@property (nonatomic, retain) NSObject* setPasswordDelegate;
@property (nonatomic, retain) NSObject* uploadKeysDelegate;
@property (nonatomic, retain) NSObject* contactBookDelegate;
@property (nonatomic, retain) NSObject* contactEditDelegate;
@property (nonatomic, retain) NSObject* chatComposeDelegate;
@property (nonatomic, retain) NSObject* findEmailContactDelegate;
@property (nonatomic, retain) NSObject* forwardListDelegate;
@property (nonatomic, retain) NSObject* contactNotificationDelegate;
@property (nonatomic, retain) NSObject* changePasswordDelegate;
@property (nonatomic, retain) NSObject* enablePasswordLockDelegate;
@property (nonatomic, retain) NSObject* notificationListDelegate;
@property (nonatomic, retain) NSObject* blockUsersDelegate;
@property (nonatomic, retain) NSObject* unblockUsersDelegate;
@property (nonatomic, retain) NSObject* signInAccountDelegate;
@property (nonatomic, retain) NSObject* verificationDelegate;
@property (nonatomic, retain) NSObject* chatListDelegate;
@property (nonatomic, retain) NSObject* webMyAccountDelegate;
@property (nonatomic, retain) NSObject* blockUsersCellDelegate;
@property (nonatomic, retain) NSObject* contactNotSyncDelegate;
+(ContactFacade *)share;

typedef void (^reqCompleteBlock)(BOOL success, NSString *message ,NSDictionary *response, NSError *error);

//ContactDom
/* *Set status account of user to Pending. It will update in keychain store
 *
 * @Author Parker
 *
 */

-(void)setAccountStatusPending;
/* *
 * Check Account Status. Will be call everytime use launch app. Base on status it will navigate user to correct view
 *
 * @Author Parker
 *
 */
-(void)checkAccountStatus;

/* *
 * Login account to tenant server.
 * @Author Parker
 *
 */
-(void)loginAccount:(NSDictionary*)retryInfo;

/* *
 * Sign in account with masking id and password.
 * parameters:
    maskingID, user masking id
    password, password
 * @Author Parker
 *
 */
-(void)signInAccount:(NSString*)maskingID password:(NSString*)password;

/* *
 * Reset keys chain of sign up and sign in account.
 * @Author Parker
 *
 */
-(void)resetSignUpAndSignInAccount;

/* *
 * Get started account. First step for login
 * @Author Parker
 *
 */
-(void)getStartedAccount;



/* *
 * Register account. Second step for login
 * @Author Parker
 * @parameters: serviceId. The service to register. 
 1    Free Trial
 2    3 Months
 3    6 Months
 4    12 Months
 5    Life Time
 6    1 Month
 *
 */
-(void)registerAccount:(int)serviceId;

/* *
 * Update passcode to tenant server
 * @parameters: passcode. 
 * @parameters: 
 * updateType: UploadPasswordForRegister,UploadPasswordForChangePsw,UploadPasswordForEnablePswLock
 * retryTime: the number of retry time when token is corrent but upload fail due to connection issue.
 * @Author Parker, Jurian
 */
-(void)updatePasscodeToServerwithType:(NSInteger)updateType retryUploadTime:(NSInteger)retryTime;

/*
 * Update old passcode and update master key local
 * Author : Jurian
 */
- (void) updatePasscodeAndMasterKeyLocal:(NSString*)passcode withType:(NSInteger)type;
/* *
 * Update key to tenant server
 * @parameters: passcode.
 *
 * @Author Parker
 */
-(void)uploadKeysToServer;

/* *
 * Update display name
 * @parameters: displayNameBased64.
 *
 * @Author Parker
 */
-(void)updateDisplayName:(NSString *)displayNameBased64;

/* *
 * Upload avatar to server
 * @parameters: avatarImage.
 *
 * @Author Parker
 */
-(void)uploadAvatar:(UIImage *)avatarImage;

/* *
 * Get profile avatar
 * @return: UIImage of avatar.
 *
 * @Author Parker
 */
-(UIImage *)getProfileAvatar;

/* *
 * Get passcode
 * @return: string of passcode.
 *
 * @Author Parker
 */
-(NSString*)getPasscode;

/* *
 * Set passcode
 * @paramemters: passcode
 * @return: set passcode.
 *
 * @Author Parker
 */
-(void)setPasscode:(NSString*) passcode;

/* *
 * Compare passcode
 * @paramemters: passcode
 * @return: True/False.
 *
 * @Author Parker
 */
-(BOOL)comparePasscode:(NSString*)passcode;

//Device info
/* *
 * Get xmpp host name
 * @return: String of xmpp.
 *
 * @Author Daniel
 */
-(NSString*)getXmppHostName;

/* *
 * Get host name of xmpp muc
 * @return: String of xmpp host.
 *
 * @Author Daniel
 */
-(NSString*)getXmppMUCHostName;

/* *
 * Get IMEI of device
 * @return: String of IMEI.
 *
 * @Author Parker
 */
-(NSString*)getIMEI;

/* *
 * Get IMSI of device
 * @return: String of IMSI.
 *
 * @Author Parker
 */
-(NSString*)getIMSI;

//My Profile
/* *
 * Get display name
 * @return: String of display name.
 *
 * @Author Parker
 */
-(NSString*)getDisplayName;

/* *
 * Get status profile
 * @return: String of status.
 *
 * @Author Parker
 */
-(NSString*)getProfileStatus;

/* *
 * Set profile status
 * @paramemters: statusString.
 *
 * @Author Parker
 */
- (void)setProfileStatus:(NSString *)statusString;

//Send out friend request;
/* *
 * Send friend request by masking id
 * @paramemters: maskingId.
 *
 * @Author Parker
 */
-(void) searchFriendByMaskingId:(NSString*)maskingId;

/* *
 * Add friend
 * @paramemters: bobMaskindId. friend masking id
 *
 * @Author Parker
 */
-(void) addFriend:(NSString*)bobMaskindId;

/* *
 * receive approve friend
 * @paramemters: approveInfo. xmpp info
 *
 * @Author Daniel
 */
- (void)didReceiveApprove:(NSDictionary *)approveInfo;

/* *
 * receive approve friend (new flow)
 * @paramemters: approveInfo. xmpp info
 *
 * @Author Daniel
 */
- (void)didReceiveFriendApprove:(NSDictionary *)approveInfo;

/* *
 * receive denied friend request (new flow)
 * @paramemters: approveInfo. xmpp info
 *
 * @Author Daniel
 */
- (void)didReceiveFriendDenied:(NSDictionary *)deniedInfo;

/* *
 * get all pending requests. It's called by recipient. (new flow)
 * @paramemters: none
 *
 * @Author Daniel
 */
- (void)getFriendPendingRequests;

/* *
 * Was approved from friend/Approved friend request
 * @paramemters: info. xmpp info
 *
 * @Author Daniel
 */
-(void) friendRequestApproved:(NSDictionary*) info wasApprovedFromFriend:(BOOL)wasApprovedFromFriend;
/* *
 * Was Denied from request of friend.
 * @paramemters: requestJID. jid of friend
 *
 * @Author Daniel
 */
-(void) wasDeniedFromRequest:(NSString *)requestJID;

//Receive friend request;
/* *
 * Did recieve request.
 * @paramemters: requestInfo. request info
 *
 * @Author Daniel
 */
-(void) didReceiveRequest:(NSDictionary*) requestInfo;

/* *
 * Did recieve request (new flow).
 * @paramemters: requestInfo. request info
 *
 * @Author Daniel
 */
- (void)didReceiveFriendRequest:(NSDictionary *)requestInfo;

/* *
 * Approve request.
 * @paramemters: requestJID. jid of friend
 *
 * @Author Daniel
 */
-(void) approveRequest:(NSString*)requestJID;

/* *
 * Approve request (new flow).
 * @paramemters: requestJID. jid of friend
 *
 * @Author Daniel
 */
- (void)responseFriendRequest:(NSString *)requestJID responseType:(NSString *)responseType;

/* *
 * Deny request.
 * @paramemters: requestJID. jid of friend
 *
 * @Author Daniel
 */
-(BOOL) denyRequest:(NSString*)requestJID;

-(void) removeDeniedRequest:(NSString *)requestJID;
-(void) loadContactRequest;
-(void) loadFriendArray;
-(void) displayNewRequest;
-(void) displayNewPending;

/* *
 * Call friend request to server (send friend request/ cancel friend request/ sms friend request).
 * @paramemters: 
    contactJid. jid of friend
    requestType: REQUEST/CANCEL/SMS_REQUEST
 *
 * @Author Parker
 */
-(void) friendRequestWithContactJid:(NSString*)contactJid requestType:(NSString*)requestType requestInfo:(NSDictionary*)requestInfo;

//Request Contact info
- (void) requestContactInfo:(NSString *)fullJid;

//Delete Contact
-(void) deleteFriend:(NSString*)contactJid;
- (void)didSuccessRemoveContact:(NSString *)contactJID;
- (void)wasRemovedContactFromFriend:(NSString *)contactJID;

-(void)getFriendPublicKey:(NSString *)bobMaskindIdPara callback:(reqCompleteBlock)callbackPara;

-(NSString*) getJid:(BOOL)withHost;
/* *
 * Get maskind id
 * @return: string of masking id
 *
 * @Author Parker
 */
-(NSString*) getMaskingId;

/* *
 * Get Token tenant
 * @return: string of tokent tenant
 *
 * @Author Parker
 */
-(NSString*) getTokentTenant;

/* *
 * Get Token central
 * @return: string of central token
 *
 * @Author Parker
 */
-(NSString*) getTokentCentral;

//TrungVN added, will add comment later.
-(BOOL) blockContact:(NSString*) fullJID;
-(BOOL) unblockContact:(NSString*) fullJID;
-(void) updateContactInfo:(NSString*) fullJID;
-(void) callContactUpdateDelegate; //<< this for update all displaying things.
-(void) updateContactPresence:(NSDictionary*) presence;
-(UIImage*) updateContactAvatar:(NSString*) fullJID;
-(NSString*) getContactName:(NSString*) fullJID;
-(Contact*) getContact:(NSString*) contactJid;
-(Request*) getRequest:(NSString*) requestJid;
-(NSString*)processIdentity:(NSString*)strData;
-(NSString*) compareIdentityFromRequest:(NSString*)requestJID
                         serverIdentity:(NSString*)serverIdentity;

//Sync contact
/* *
 * Get all contries.
 * @return: array of countries name
 *
 * @Author Parker
 */
- (NSArray*)getAllCountries;

/* *
 * Get all countries with dial codes.
 * @return: dictionary of countries
 *
 * @Author Parker
 */
- (NSDictionary*)getAllCountriesWithDialCodes;

/* *
 * Get the current country name with dial code.
 * @return: dictionary of country
 *
 * @Author Parker
 */
- (NSDictionary*) getCurrentCountryNameWithDialCode;

/* *
 * Get all countries with country code with dial code.
 * @return: array of countries dictionary
 *
 * @Author Parker
 */
- (NSArray*)getAllCountriesWithCountryCodesAndDialCodes;

/* *
 * Get MSISDN.
 * @return: String of MSISDN
 *
 * @Author Parker
 */
-(NSString*)getMSISDN;

/* *
 * Get number phone from MSISDN.
 * @return: String of number phone
 *
 * @Author Parker
 */
-(NSString*)getNumberPhoneFromMSISDN;

/* *
 * Get verification code.
 * @return: String of 4 digits of verification code
 *
 * @Author Parker
 */
-(NSString*) getVerificationCode;

/**
 *  Check Phonenumber valid or not
 *
 *  @param phoneNumber user phone number
 *
 *  @return YES is phoneNumber is valid. NO if phoneNumber is invalid
 *  @Author Daryl
 */
-(BOOL) checkMSISDNValid:(NSString *)phoneNumber;

/* *
 * Check MSISDN.
 * @parameters: country code and phone number
 *
 * @Author Parker
 */
-(void) validateMSISDNWithServer:(NSString *)countryCode phoneNumber:(NSString*)phoneNumber;

/* *
 * Update MSISDN to server.
 * @parameters: country code and phone number
 *
 * @Author Parker
 */
-(void) updateMSISDNToServer:(NSString *)countryCode phoneNumber:(NSString*)phoneNumber;

/* *
 * Send verification code to server.
 * @parameters: country code ,phone number, resendCode(resend or not)
 *
 * @Author Parker
 */
-(void) sendVerfificationCode:(NSString *)countryCode phoneNumber:(NSString*)phoneNumber resendCode:(BOOL)resendCode;

/* *
 * Verify valid of verification code OTP
 * @parameters: phone number
 * @Author Jurian
 */
- (void) verifyOTP:(NSString*)phoneNumber otpCode:(NSString*)verificationCode resendCode:(BOOL)resendCode;
/* *
 * Sync contacts with server.
 * @parameters: country code ,phone number, resendCode(resend or not)
 *
 * @Author Parker
 */
-(void) syncContactsWithServer;

/* *
 * Get address phone book. Check and access phone book
 *
 * @Author Parker
 */
- (void)getAddressPhoneBook;

//Device Info
/* *
 * Get device name.
 * @return: string of device name
 *
 * @Author Parker
 */
-(NSString*)getDeviceName;

/* *
 * Get device version.
 * @return: string of device version
 *
 * @Author Parker
 */
-(NSString*)getDeviceVersion;

/* *
 * Get device model.
 * @return: string of device model
 *
 * @Author Parker
 */
-(NSString*)getDeviceModel;

//All flags
-(void)setTermAndConditionFlag:(NSString *)value;
-(BOOL)getRegisterFlag;
-(BOOL)getTermAndConditionFlag;
-(BOOL)getSyncContactFlag;
-(BOOL)getFreeTrialedFlag;
-(BOOL)getReloginFlag;
-(BOOL)getBackupProfileFlag;
-(BOOL)getRestoreProfileFlag;
-(BOOL)getUpdateMasterKeyFlag;

-(NSString*)getAccountStatus;

//setvalue for key
-(void)setValue:(NSString*)value forKey:(NSString*)key;

//DB functions
- (NSArray*)getAllKryptoMembers;


//Adressbook
/* *
 * Get normal contacts address book.
 * @return: array of normal contacts
 *
 * @Author Parker
 */
-(NSArray *)getContactsAddressBook;

/* *
 * Get symbolic contacts address book.
 * @return: array of symbolic contacts
 *
 * @Author Parker
 */
-(NSArray *)getSymbolicContactsAddressBook;

/* *
 * Get all contacts address book.
 * @return: array of all contacts
 *
 * @Author Parker
 */
-(NSDictionary *)getAllContactsInAddressBook;

/*
 * check a contactJID is friend or not.
 * @Author TrungVN
 */
-(BOOL) isFriend:(NSString*) contactJID;

/*
 * check a contactJID is blocked or not.
 * @Author TrungVN
 */
-(BOOL) isBlocked:(NSString*) contactJID;

/**
 *  Reset account
 *  Author Violet
 */
-(void) resetAccount;

/**
 *  Reset NSUserDefault when reset account
 *  Author: Violet
 */
- (void)resetDefaults;

/**
 *  Search contact
 *  Author: Sirius
 */
-(void) searchContact:(NSString*) text;

/**
 *  Search satay friends and phonebook friends
 *  Author: Sirius
 */
-(void) searchPhoneBookFriend:(NSString*) text;

/**
 *  Search satay friends
 *  Author: Sirius
 */
-(void) searchUserMember:(NSString*) text;

/**
 *  Search friend have email in Find email contacts
 *
 *  @param searchText       search keyword
 *  @param friendsArray     array of friends have email
 *  @param isAddParticipant check for find email for find friend
 *  @author  William
 */
- (void) searchEmailFriendName:(NSString *) searchText friendArray:(NSArray *)friendsArray isAddParticipant:(BOOL) isAddParticipant;

/**
 *  Load the list of block users
 *  Author: Violet
 */
-(void) loadBlockedUsersArray;

/**
 *  Back up profile. include backup keys, email setting, notification
 *  Author: Parker
 */
-(void) backupProfile;

/**
 *  Restore profile.
 *  Author: Parker
 */
- (void)restoreProfile;

/**
 *  Update masterkey to server.
 *  Author: Parker
 */
-(void)uploadMasterKey;

/*
 *  Update last activity of friend
 *  @param lastActivitySec last activity second
 *  @param fullJID         full jid of friend
 *  Author: Violet
 */
-(void) updateContactLastActivity:(NSDate*) lastActivityDate JID:(NSString*) fullJID;

/**
 *  Update state of friend when disconnect internet suddenly
 *  Author: Violet
 */
-(void) updateContactStateWhenDisconnect;

/**
 *  Update state of friend when Reconnect internet
 *  Author: Violet
 */
-(void) updateContactStateWhenReconnect;
/**
 *  Show keyboard at SyncContact page
 *  Author: Violet
 */
-(void) showKeyboardSyncContactView;

/**
 *  Process again all failed case related to API
 *  Author: Parker
 */
-(void) processAgainForFailedCases;

/*
 *  Description: restore contact
 *  @param status: status of friend. 100 - APPROVED list 010 - PENDING list 001 - RECEIVED list 110 - APPROVED and PENDING list
 *  Author: Parker
 */
- (void) restoreContact:(NSString*)status;

/*
 *  Description: backup contact
 *  @param status: status of friend. APPROVED/ PENDING /RECEIVED
 *  @param fullJid :full jid of friend
 *  Author: Parker
 */
- (void) backupContact:(NSString*)fullJid friendStatus:(NSString*)status;

/*
 * Description : Update a given blocked users list to server database
 * @param blocked_jid_list: list of blocked list.
 * @param action: UPDATE/GET
 * Author: Jurian
 */
- (void) synchronizeBlockList:(NSString*)blocked_jid_list  action:(NSString*)action;
/*
 * Description : get detail account from database
 * Author: Jurian
 */
- (void) getDetailAccount;

/**
 *  Reset MSISDN number
 *  @author William
 */
- (void) resetMSISDNNumber;
/**
 *  Get transaction history for displaying
 *  @author Jurian
 */
- (void) getTransactionHistory;

/**
 *  Get Full number with country code number
 *  @author Jurian
 */
- (NSString*) getFullNumber:(NSString *)countryCode phoneNumber:(NSString*)phoneNumber;

/**
 *  Check if this account is removed from server or not
 *  @author Jurian
 */
- (BOOL)isAccountRemoved;
/**
 *  Check if this account is expired from dateServer or not
 *  @author Jurian
 */
- (BOOL) isAccountExpired;
@end
