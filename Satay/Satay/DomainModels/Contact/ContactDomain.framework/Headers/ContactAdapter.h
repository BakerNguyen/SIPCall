//
//  ContactAdapter.h
//  ContactDomain
//
//  Created by enclave on 1/20/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ContactAdapter : NSObject

typedef void (^requestCompleteBlock)(BOOL success, NSString *message ,NSDictionary *response, NSError *error);

/*
 *Singleton of this object
 *Author Trung
 *Purpose, use this method to prevent re-new object.
 */
+ (ContactAdapter *)share;

/*
 * Get Address Phone Book. Run this one first before getting others.
 * @author Parker
 * Method request iOS 6.0 and above
 */
-(void)getAddressPhoneBook;

/*
 * Get all contact list in address book include contacts with symbolic.
 * @author Parker
 */
-(NSDictionary *)getAllContactsInAddressBook;

/*
 * Get all normal contacts in address book.
 * @author Parker
 */
-(NSArray *)getContactsAddressBook;

/*
 * Get all symbolic contacts in address book.
 * @author Parker
 */
-(NSArray *)getSymbolicContactsAddressBook;

/*
 *  Handle phone number with prefix dial code.
 *  Change phoneNumber follow this rule
 *  If we don't have dialCode, we keep current phone number.
 *  If we have dialCode, we will replce like this:
 *  0xxx > [dialCode]xxx
 *  84xxx > +84xxx
 *  +84xxx > +84xxx
 *
 * @parameter phoneNumber: the phone number need to handle
 * @return phone number with prefix dial code if dial code is existing.
 * @author Daryl/Parker
 */
-(NSString *)handlePhoneNumber:(NSString *)phoneNumber;

/*
 * Get all phone number in contact address book.
 * @author Parker
 */
-(NSArray *)getPhoneNumberListInContactAddressBook;

/**
 * Set contact's avatar to local.
 * @author Parker
 * @parameter jid: contact's jid
 * @parameter avatarData: NSData of image
 * @return true false
 */
-(BOOL) setContactAvatar:(NSString*)jid data:(NSData*) avatarData;

/**
 * Get contact avatar from local
 * @author Parker
 * @parameter jid: contact's jid
 * @return NSData* of image
 */
-(NSData*) getContactAvatar:(NSString*)jid;

/**
 * Description: Update a given blocked users list to server database
 * @author Parker
 * @parameter parametersDic must have value for keys:API_REQUEST_METHOD(POST/GET),API_REQUEST_KIND(Upload/Download/Normal), MASKING_ID, TOKEN, IMEI, IMSI, BLOCKED_JID_LIST,ACTION(UPDATE,GET)
 * BLOCKED_JID_LIST : A list of full jid of blocked members 
 Optional. In case ACTION is "UPDATE", BLOCKED_JID_LIST can be accepted with empty value.
 * ACTION:UPDATE,GET 
 Required.
 If ACTION is “UPDATE”, the blocked list is updated for owner user in database. Otherwise, it will returns the real blocked list in database.
 * @return callback with response include: STATUS_CODE, STATUS_MSG, SUCCESS, BLOCKED_JID_LIST
 */
-(void)synchronizeBlockList:(NSDictionary*)parametersDic callback:(requestCompleteBlock)callback;

/**
 * Get user infor
 * @author Parker
 * @parameter parametersDic must have value for keys:API_REQUEST_METHOD(POST/GET),API_REQUEST_KIND(Upload/Download/Normal), MASKING_ID, TOKEN, IMEI, IMSI, USER_MASKING_ID
 * @return callback with response include: STATUS_CODE, STATUS_MSG, SUCCESS,  ACCOUNT(JID,HOST)
 */
-(void)getFriendInformation:(NSDictionary*)parametersDic callback:(requestCompleteBlock)callback;

/**
 * Get user vCard
 * @author Daniel
 * @parameter parametersDic must have value for keys:API_REQUEST_METHOD(POST/GET),API_REQUEST_KIND(Upload/Download/Normal), JID, HOST, MASKING_ID, TOKEN, IMEI, IMSI.
 * @return callback with response include: STATUS_CODE, STATUS_MSG, SUCCESS, VCARD(XML)
 */
-(void)getFriendvCard:(NSDictionary*)parametersDic callback:(requestCompleteBlock)callback;

/**
 * check Identity
 * @author Parker
 * @parameter parametersDic must have value for keys:API_REQUEST_METHOD(POST/GET),API_REQUEST_KIND(Upload/Download/Normal), MASKING_ID, TOKEN, IMEI, IMSI, ALICE_MASKING_ID
 * @return callback with response include: STATUS_CODE, STATUS_MSG, SUCCESS,  DATA(SHA256 of $pub2an.$pub2ae.$pub2bn.$pub2be)
 */
-(void)checkIdentity:(NSDictionary*)parametersDic callback:(requestCompleteBlock)callback;

/**
 * Description: Get Identity.
 * @author Parker
 * @parameter parametersDic must have value for keys:API,API_REQUEST_METHOD(POST/GET),API_REQUEST_KIND(Upload/Download/Normal),MASKING_ID, TOKEN, IMEI, IMSI, BOB_MASKING_ID
 * @return callback with response include: SUCCESS, STATUS_CODE, STATUS_MSG, PUB2AN, PUB2AE, PUB2A_KEY, DATA
 */
-(void)getIdentity:(NSDictionary*)parametersDic callback:(requestCompleteBlock)callback;

/**
 * Description: Approve Identity.
 * @author Parker
 * @parameter parametersDic must have value for keys:API,API_REQUEST_METHOD(POST/GET),API_REQUEST_KIND(Upload/Download/Normal),MASKING_ID, TOKEN(sender), BOB_MASKING_ID, HASH, GET_IDENTITY
 * @return callback with response include: SUCCESS, STATUS_CODE, STATUS_MSG, PUB2AN, PUB2AE, PUB2A_KEY, DATA
 */
-(void)approveIdentity:(NSDictionary*)parametersDic callback:(requestCompleteBlock)callback;

/**
 * Description: Identity Reject (Tenant).
 * Note: This API will be use later. current using xmpp for reject friend request
 * @author Parker
 * @parameter parametersDic must have value for keys:API,API_REQUEST_METHOD(POST/GET),API_REQUEST_KIND(Upload/Download/Normal),MASKING_ID(sender), TOKEN(sender), BOB_MASKING_ID
 * @return callback with response include: SUCCESS, STATUS_CODE, STATUS_MSG,
 */
-(void)rejectIdentity:(NSDictionary*)parametersDic callback:(requestCompleteBlock)callback;

/**
 * Description: Get friend public key.
 * @author Parker
 * @parameter parametersDic must have value for keys:API,API_REQUEST_METHOD(POST/GET),API_REQUEST_KIND(Upload/Download/Normal),MASKING_ID, TOKEN(Token of the own user), IMEI, IMSI, F_MASKING_ID,
 * @return callback with response include: SUCCESS, STATUS_CODE, STATUS_MSG, N, E, VERSION
 */
-(void)getFriendPublicKey:(NSDictionary*)parametersDic callback:(requestCompleteBlock)callback;

/**
 * Description: Search friend by masking id.
 * @author Parker
 * @parameter parametersDic must have value for keys:API,API_REQUEST_METHOD(POST/GET),API_REQUEST_KIND(Upload/Download/Normal), MASKING_ID, TOKEN, FRIEND_MASKING_ID, IMEI, IMSI.
 * @return callback with response include: SUCCESS, STATUS_CODE, STATUS_MSG, ACCOUNT(MASKING_ID, JID, DISPLAY_NAME, USER_STATUS, EMAIL)
 */
-(void)searchFriendByMaskingId:(NSDictionary*)parametersDic callback:(requestCompleteBlock)callback;

/**
 * Description: Search contacts (tenant). use this in sync contact
 * @author Parker
 * @parameter parametersDic must have value for keys:API,API_REQUEST_METHOD(POST/GET),API_REQUEST_KIND(Upload/Download/Normal), MASKING_ID, TOKEN, SOURCE_COUNTRY, MSISDN_LIST,  IMEI, IMSI.
 * @return callback with response include: SUCCESS, STATUS_CODE, STATUS_MSG, CONTACTS(SOURCE_MSISDN,JID,MSISDN,USER_STATUS)
 */
-(void)searchContactsTenant:(NSDictionary*)parametersDic callback:(requestCompleteBlock)callback;

/**
 * Description: Remove friend by masking id (tenant).
 * @author Parker
 * @parameter parametersDic must have value for keys:API,API_REQUEST_METHOD(POST/GET),API_REQUEST_KIND(Upload/Download/Normal), MASKING_ID, TOKEN, FRIEND_MASKING_ID
 * @return callback with response include: SUCCESS, STATUS_CODE, STATUS_MSG,
 */
-(void)removeFriendByMaskingId:(NSDictionary*)parametersDic callback:(requestCompleteBlock)callback;


/**
 * Description: Send a friend request or cancel friend request (tenant).
 * @author Parker
 * @parameter parametersDic must have value for keys:API,API_REQUEST_METHOD(POST/GET/PUT),API_REQUEST_KIND(Upload/Download/Normal), MASKINGID, IMSI, IMEI, TOKEN (tenant), CENTRALTOKEN, RECIPIENTMSISDN or RECIPIENTMASKINGID, CMD (REQUEST, CANCEL, SMS_REQUEST)
 * @return callback with response include: SUCCESS, STATUS_CODE, STATUS_MSG, DATA
 */
-(void)httpFriendRequest:(NSDictionary*)parametersDic callback:(requestCompleteBlock)callback;

/**
 * Description: get response friend request from server (tenant).
 * @author Parker
 * @parameter parametersDic must have value for keys:API,API_REQUEST_METHOD(POST/GET/PUT),API_REQUEST_KIND(Upload/Download/Normal), MASKINGID, IMSI, IMEI, TOKEN (tenant), CENTRALTOKEN, SENDERMASKINGID, RESPONSE (APPROVED, DENIED)
 * @return callback with response include: SUCCESS, STATUS_CODE, STATUS_MSG, DATA
 */
-(void)httpFriendRequestResponse:(NSDictionary*)parametersDic callback:(requestCompleteBlock)callback;

/**
 * Description: get all pending friend requests from server (tenant).
 * @author Daniel
 * @parameter parametersDic must have value for keys:API,API_REQUEST_METHOD(POST/GET/PUT),API_REQUEST_KIND(Upload/Download/Normal), MASKINGID, IMSI, IMEI, TOKEN (tenant), CENTRALTOKEN
 * @return callback with response include: SUCCESS, STATUS_CODE, STATUS_MSG, DATA
 */
-(void)httpFriendRequestList:(NSDictionary*)parametersDic callback:(requestCompleteBlock)callback;

/**
 * Description: get all transaction history (tenant).
 * @author Jurian
 * @parameter parametersDic must have value for keys:API,API_REQUEST_METHOD(PUT),API_REQUEST_KIND(Upload/Download/Normal), MASKINGID, IMSI, IMEI, TOKEN (tenant)
 * @return callback with response include: SUCCESS, STATUS_CODE, STATUS_MSG, DATA
 */
-(void)getTransactionHistory:(NSDictionary*)parametersDic callback:(requestCompleteBlock)callback;
@end
