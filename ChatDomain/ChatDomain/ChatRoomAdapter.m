//
//  ChatRoomAdapter.m
//  ChatDomain
//
//  Created by Daniel Nguyen on 3/9/15.
//  Copyright (c) 2015 mTouche. All rights reserved.
//

#import "ChatRoomAdapter.h"
#import "ChatServerAdapter.h"
#import "CocoaLumberjack.h"
#import "DDLog.h"
#import "AFNetworking.h"
#import "JSONHelper.h"

//APIs
#define kAPI @"API"
#define kAPI_VERSION @"API_VERSION"

#define API_CREATE_CHATROOM @"aQabATDPeK"
#define API_CREATE_CHATROOM_VERSION @"v2"

#define API_GET_CHATROOM @"Kn79U7gTzF"
#define API_GET_CHATROOM_VERSION @"v2"

#define API_ADD_MEMBER_TO_CHATROOM @"4aP3ofWfja"
#define API_ADD_MEMBER_TO_CHATROOM_VERSION @"v2"

#define API_LEAVE_FROM_CHATROOM @"V8vXZVAT4a"
#define API_LEAVE_FROM_CHATROOM_VERSION @"v2"

#define API_UPDATE_NAME_FOR_CHATROOM @"uFRMPGgrkJ"
#define API_UPDATE_NAME_FOR_CHATROOM_VERSION @"v2"

#define API_CREATE_STICKY_CHATROOM @"7K0opb5FPC"
#define API_CREATE_STICKY_CHATROOM_VERSION @"v2"

#define API_UPLOAD_MUC_KEY @"n0JvUHU7fc"
#define API_UPLOAD_MUC_KEY_VERSION @"v1"

#define API_GET_MUC_KEY @"iFhmy9j6X0"
#define API_GET_MUC_KEY_VERSION @"v1"

#define API_RETRIEVE_GROUP_CONVERSATION @"jmJj6XBkIY"
#define API_RETRIEVE_GROUP_CONVERSATION_VERSION @"v2"

#define API_SEND_NOTICE_GROUP @"5qjLN0gXwS"
#define API_SEND_NOTICE_GROUP_VERSION @"v1"

//Logging
#ifdef DEBUG
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelError;
#endif

@implementation ChatRoomAdapter

+ (ChatRoomAdapter *)share
{
    static dispatch_once_t once;
    static ChatRoomAdapter * share;
    dispatch_once(&once, ^{
        share = [self new];
        // Configure CocoaLumberjack
    });
    return share;
}

NSString *lettersROOM = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
+ (NSString*)generateRoomJid
{
    NSMutableString *randomString = [NSMutableString stringWithCapacity: 25];
    for (int i=0; i<25; i++) {
        [randomString appendFormat: @"%C", [lettersROOM characterAtIndex: arc4random_uniform((int)[lettersROOM length])]];
    }
    return [randomString lowercaseString];
}

- (void)createChatRoom:(NSDictionary *)parametersDic callback:(requestCompleteBlock)callback
{
    if (!parametersDic) {
        DDLogError(@"%s: FAILED parametersDic NULL", __PRETTY_FUNCTION__);
        return;
    }
    
    void (^createChatRoomCallBack)(BOOL success, NSString *message ,NSDictionary *response, NSError *error);
    
    createChatRoomCallBack = callback;
    NSMutableDictionary *parameters = [parametersDic mutableCopy];
    [parameters setObject:API_CREATE_CHATROOM forKey:kAPI];
    [parameters setObject:API_CREATE_CHATROOM_VERSION forKey:kAPI_VERSION];
    
    [[ChatServerAdapter share] requestService:parameters tenantServer:YES
                               uploadProgress:(uploadProgress) nil
                                     callback:^(BOOL success, NSString *message, NSDictionary *response, NSError *error) {
        createChatRoomCallBack(success, message, response, error);
    }];
}

- (void)getChatRoom:(NSDictionary *)parametersDic callback:(requestCompleteBlock)callback
{
    if (!parametersDic) {
        DDLogError(@"%s: FAILED parametersDic NULL", __PRETTY_FUNCTION__);
        return;
    }
    
    void (^getChatRoomCallBack)(BOOL success, NSString *message ,NSDictionary *response, NSError *error);
    
    getChatRoomCallBack = callback;
    NSMutableDictionary *parameters = [parametersDic mutableCopy];
    [parameters setObject:API_GET_CHATROOM forKey:kAPI];
    [parameters setObject:API_GET_CHATROOM_VERSION forKey:kAPI_VERSION];
    
    [[ChatServerAdapter share] requestService:parameters tenantServer:NO
                               uploadProgress:(uploadProgress) nil
                                     callback:^(BOOL success, NSString *message, NSDictionary *response, NSError *error) {
        getChatRoomCallBack(success, message, response, error);
    }];
}

- (void)addMemberToChatRoom:(NSDictionary *)parametersDic callback:(requestCompleteBlock)callback
{
    if (!parametersDic) {
        DDLogError(@"%s: FAILED parametersDic NULL", __PRETTY_FUNCTION__);
        return;
    }
    
    void (^addMemberToChatRoomCallBack)(BOOL success, NSString *message ,NSDictionary *response, NSError *error);
    
    addMemberToChatRoomCallBack = callback;
    NSMutableDictionary *params = [parametersDic mutableCopy];
    [params setObject:API_ADD_MEMBER_TO_CHATROOM forKey:kAPI];
    [params setObject:API_ADD_MEMBER_TO_CHATROOM_VERSION forKey:kAPI_VERSION];
    
    [[ChatServerAdapter share] requestService:params
                                 tenantServer:YES
                               uploadProgress:(uploadProgress) nil
                                     callback:^(BOOL success, NSString *message, NSDictionary *response, NSError *error) {
        addMemberToChatRoomCallBack(success, message, response, error);
    }];
}

- (void)leaveFromChatRoom:(NSDictionary *)parametersDic callback:(requestCompleteBlock)callback
{
    if (!parametersDic) {
        DDLogError(@"%s: FAILED parametersDic NULL", __PRETTY_FUNCTION__);
        return;
    }
    
    void (^leaveFromChatRoomCallBack)(BOOL success, NSString *message ,NSDictionary *response, NSError *error);
    
    leaveFromChatRoomCallBack = callback;
    NSMutableDictionary *params = [parametersDic mutableCopy];
    [params setObject:API_LEAVE_FROM_CHATROOM forKey:kAPI];
    [params setObject:API_LEAVE_FROM_CHATROOM_VERSION forKey:kAPI_VERSION];
    
    [[ChatServerAdapter share] requestService:params tenantServer:YES
                                uploadProgress:(uploadProgress) nil
                                     callback:^(BOOL success, NSString *message, NSDictionary *response, NSError *error) {
        leaveFromChatRoomCallBack(success, message, response, error);
    }];
}

- (void)updateNameForChatRoom:(NSDictionary *)parametersDic callback:(requestCompleteBlock)callback
{
    if (!parametersDic) {
        DDLogError(@"%s: FAILED parametersDic NULL", __PRETTY_FUNCTION__);
        return;
    }
    
    void (^updateNameForChatRoomCallBack)(BOOL success, NSString *message ,NSDictionary *response, NSError *error);
    
    updateNameForChatRoomCallBack = callback;
    NSMutableDictionary *params = [parametersDic mutableCopy];
    [params setObject:API_UPDATE_NAME_FOR_CHATROOM forKey:kAPI];
    [params setObject:API_UPDATE_NAME_FOR_CHATROOM_VERSION forKey:kAPI_VERSION];
    
    [[ChatServerAdapter share] requestService:params tenantServer:YES
                               uploadProgress:(uploadProgress) nil
                                     callback:^(BOOL success, NSString *message, NSDictionary *response, NSError *error) {
        updateNameForChatRoomCallBack(success, message, response, error);
    }];
}

- (void)uploadMUCKey:(NSDictionary *)parametersDic callback:(requestCompleteBlock)callback
{
    if (!parametersDic) {
        DDLogError(@"%s: FAILED parametersDic NULL", __PRETTY_FUNCTION__);
        return;
    }
    
    void (^uploadMUCKeyCallBack)(BOOL success, NSString *message ,NSDictionary *response, NSError *error);
    
    uploadMUCKeyCallBack = callback;
    NSMutableDictionary *params = [parametersDic mutableCopy];
    [params setObject:API_UPLOAD_MUC_KEY forKey:kAPI];
    [params setObject:API_UPLOAD_MUC_KEY_VERSION forKey:kAPI_VERSION];
    
    [[ChatServerAdapter share] requestService:params tenantServer:NO
                               uploadProgress:(uploadProgress) nil
                                     callback:^(BOOL success, NSString *message, NSDictionary *response, NSError *error) {
        uploadMUCKeyCallBack(success, message, response, error);
    }];
}

- (void)getMUCKey:(NSDictionary *)parametersDic callback:(requestCompleteBlock)callback
{
    if (!parametersDic) {
        DDLogError(@"%s: FAILED parametersDic NULL", __PRETTY_FUNCTION__);
        return;
    }
    
    void (^getMUCKeyCallBack)(BOOL success, NSString *message ,NSDictionary *response, NSError *error);
    
    getMUCKeyCallBack = callback;
    NSMutableDictionary *params = [parametersDic mutableCopy];
    [params setObject:API_GET_MUC_KEY forKey:kAPI];
    [params setObject:API_GET_MUC_KEY_VERSION forKey:kAPI_VERSION];
    
    [[ChatServerAdapter share] requestService:params tenantServer:NO
                               uploadProgress:(uploadProgress) nil
                                     callback:^(BOOL success, NSString *message, NSDictionary *response, NSError *error) {
        getMUCKeyCallBack(success, message, response, error);
    }];
}

- (void)retrieveGroupConversation:(NSDictionary *)parametersDic callback:(requestCompleteBlock)callback
{
    if (!parametersDic) {
        DDLogError(@"%s: FAILED parametersDic NULL", __PRETTY_FUNCTION__);
        return;
    }
    
    void (^retrieveGroupConversationCallBack)(BOOL success, NSString *message ,NSDictionary *response, NSError *error);
    
    retrieveGroupConversationCallBack = callback;
    NSMutableDictionary *params = [parametersDic mutableCopy];
    [params setObject:API_RETRIEVE_GROUP_CONVERSATION forKey:kAPI];
    [params setObject:API_RETRIEVE_GROUP_CONVERSATION_VERSION forKey:kAPI_VERSION];
    
    [[ChatServerAdapter share] requestService:params tenantServer:YES
                               uploadProgress:(uploadProgress) nil
                                     callback:^(BOOL success, NSString *message, NSDictionary *response, NSError *error) {
        retrieveGroupConversationCallBack(success, message, response, error);
    }];
}

- (void)sendNoticeGroup:(NSDictionary *)parametersDic callback:(requestCompleteBlock)callback
{
    if (!parametersDic) {
        DDLogError(@"%s: FAILED parametersDic NULL", __PRETTY_FUNCTION__);
        return;
    }
    
    void (^sendNoticeGroupCallBack)(BOOL success, NSString *message ,NSDictionary *response, NSError *error);
    
    sendNoticeGroupCallBack = callback;
    NSMutableDictionary *params = [parametersDic mutableCopy];
    [params setObject:API_SEND_NOTICE_GROUP forKey:kAPI];
    [params setObject:API_SEND_NOTICE_GROUP_VERSION forKey:kAPI_VERSION];
    
    [[ChatServerAdapter share] requestService:params tenantServer:YES
                               uploadProgress:(uploadProgress) nil
                                     callback:^(BOOL success, NSString *message, NSDictionary *response, NSError *error) {
                                         sendNoticeGroupCallBack(success, message, response, error);
                                     }];
}

@end
