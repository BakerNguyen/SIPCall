//
//  ChatRoomAdapter.h
//  ChatDomain
//
//  Created by Daniel Nguyen on 3/9/15.
//  Copyright (c) 2015 mTouche. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ChatRoomAdapter : NSObject

+ (ChatRoomAdapter *)share;

+ (NSString*)generateRoomJid;

typedef void (^requestCompleteBlock)(BOOL success, NSString *message ,NSDictionary *response, NSError *error);

/**
 * create ChatRoom in server tenant
 * @author Daniel
 * @parameter parametersDic must have value for keys: MASKING, TOKEN, IMSI, IMEI, ROOMJID, ROOMNAME, ROOMPASSWORD, MEMBERJIDLIST
 * @callback with response include: STATUS_CODE, STATUS_MSG, SUCCESS
 */
- (void)createChatRoom:(NSDictionary *)parametersDic callback:(requestCompleteBlock)callback;

/**
 * get ChatRoom in server central
 * @author Daniel
 * @parameter parametersDic must have value for keys: MASKING, TOKEN, IMSI, IMEI, ROOMJID
 * @callback with response include: STATUS_CODE, STATUS_MSG, SUCCESS, CHATROOMS (a dictionary object withkeys: ROOM and MEMBERS)
 */
- (void)getChatRoom:(NSDictionary *)parametersDic callback:(requestCompleteBlock)callback;

/**
 * add member to chat room
 * @author Daniel
 * @parameter parametersDic must have value for keys: MASKING, TOKEN, IMSI, IMEI, ROOMJID, MEMBERMASKINGID
 * @callback with response include: STATUS_CODE, STATUS_MSG, SUCCESS
 */
- (void)addMemberToChatRoom:(NSDictionary *)parametersDic callback:(requestCompleteBlock)callback;

/**
 * leave from chat room
 * @author Daniel
 * @parameter parametersDic must have value for keys: MASKING, TOKEN, IMSI, IMEI, ROOMJID, MEMBERMASKINGID, KILLROOM (optional 0 or 1)
 * @callback with response include: STATUS_CODE, STATUS_MSG, SUCCESS
 */
- (void)leaveFromChatRoom:(NSDictionary *)parametersDic callback:(requestCompleteBlock)callback;

/**
 * update name for chat room
 * @author Daniel
 * @parameter parametersDic must have value for keys: MASKING, TOKEN, IMSI, IMEI, ROOMJID, ROOMNAME
 * @callback with response include: STATUS_CODE, STATUS_MSG, SUCCESS
 */
- (void)updateNameForChatRoom:(NSDictionary *)parametersDic callback:(requestCompleteBlock)callback;

/**
 * upload MUC key to central
 * @author Daniel
 * @parameter parametersDic must have value for keys: MASKING, TOKEN, IMSI, IMEI, ROOMJID, GROUPKEY
 * @callback with response include: STATUS_CODE, STATUS_MSG, SUCCESS, VER
 */
- (void)uploadMUCKey:(NSDictionary *)parametersDic callback:(requestCompleteBlock)callback;

/**
 * get MUC key from central
 * @author Daniel
 * @parameter parametersDic must have value for keys: MASKING, TOKEN, IMSI, IMEI, ROOMJID, VER
 * @callback with response include: STATUS_CODE, STATUS_MSG, SUCCESS, KEY
 */
- (void)getMUCKey:(NSDictionary *)parametersDic callback:(requestCompleteBlock)callback;

/**
 * retrieve Group Conversation from tenant
 * @author Daniel
 * @parameter parametersDic mus have value for keys:
 * @callback with response include:
 */
- (void)retrieveGroupConversation:(NSDictionary *)parametersDic callback:(requestCompleteBlock)callback;

/**
 *  @author Daniel Nguyen, 15-04-08 18:04
 *
 *  @brief  send notice group
 *
 *  @param parametersDic must have value for keys: Maskingid, Imsi, Imei, Token, Roomjid, Roomhost, Roomname, Memberjidlist, Messagetype, Roomlogourl
 *  @param callback      with response include: STATUS_CODE, STATUS_MSG, SUCCESS
 */
- (void)sendNoticeGroup:(NSDictionary *)parametersDic callback:(requestCompleteBlock)callback;

@end
