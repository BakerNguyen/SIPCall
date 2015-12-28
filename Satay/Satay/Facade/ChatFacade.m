//
//  ChatFacade.m
//  Satay
//
//  Created by Daniel Nguyen on 3/10/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import "ChatFacade.h"

@implementation ChatFacade

@synthesize tempRoomCreating;
@synthesize groupCreateDelegate;
@synthesize contactInfoDelegate;
@synthesize chatViewDelegate;
@synthesize chatListDelegate;
@synthesize windowDelegate;
@synthesize viewPhotoDelegate;
@synthesize chatListEditDelegate;
@synthesize incomingNotificationDelegate;
@synthesize manageStorageDelegate;
@synthesize sideBarDelegate;

+ (ChatFacade *)share
{
    static dispatch_once_t once;
    static ChatFacade * share;
    dispatch_once(&once, ^{
        share = [self new];
    });
    return share;
}

#pragma mark - Call APIs -
- (void)createChatRoomWithInfo:(NSDictionary *)chatRoomInfo
{
    NSLog(@"%s chatRoomInfo: %@", __PRETTY_FUNCTION__, chatRoomInfo);
    [windowDelegate showLoading:kLOADING_PROCESSING];
    
    // remove domain in fullJID, use for params
    NSMutableDictionary *params = [chatRoomInfo mutableCopy];
    if([chatRoomInfo objectForKey:kMEMBER_JID_LIST])
        [params setObject:[chatRoomInfo objectForKey:kMEMBER_JID_LIST] forKey:kMEMBER_JID_LIST];
    
    [[ChatRoomAdapter share] createChatRoom:params callback:^(BOOL success, NSString *message, NSDictionary *response, NSError *error) {
        NSLog(@"%s %@", __PRETTY_FUNCTION__, response);
        NSDictionary *logDic;
        if (success) {
            //1. gen random AES -> group Key -> upload to server
            NSData *mucKey = [AESSecurity randomDataOfLength:32];
            NSLog(@"GROUP KEY (AES-BASED64): %@", [Base64Security generateBase64String:mucKey]);
            NSMutableArray *members = [[[chatRoomInfo objectForKey:kMEMBER_JID_LIST] componentsSeparatedByString:@","] mutableCopy];
            NSMutableDictionary *memberKeys = [NSMutableDictionary new];
            
            // get blocked friend in members list
            NSMutableArray *blockedContacts = [[NSMutableArray alloc] init];
            if ([response objectForKey:@"BLOCKED_JID_LIST"]) {
                blockedContacts = [[[response objectForKey:@"BLOCKED_JID_LIST"] componentsSeparatedByString:@","] mutableCopy];
            }
            
            // remove blocked contact, don't invite them
            for (int index=0; index<[blockedContacts count]; index++) {
                for (int index2=0; index2<[members count]; index2++) {
                    if ([[blockedContacts objectAtIndex:index] isEqualToString:[members objectAtIndex:index2]]) {
                        [members removeObjectAtIndex:index2];
                        break;
                    }
                }
            }
            
            // for members keys
            for (NSString *memberJID in members) {
                Key *key = [[AppFacade share] getKey:memberJID];
                if (key.keyJSON) {
                    NSData* keyData = [Base64Security decodeBase64String:key.keyJSON];
                    if (keyData)
                        key.keyJSON = [[NSString alloc] initWithData:[[AppFacade share] decryptDataLocally:keyData]
                                                            encoding:NSUTF8StringEncoding];
                }
                NSDictionary *pubKeys = [ChatAdapter decodeJSON:key.keyJSON];
                NSData *rsa = [RSASecurity encryptRSA:mucKey b64PublicExp:[pubKeys objectForKey:kMOD1_EXPONENT] b64Modulus:[pubKeys objectForKey:kMOD1_MODULUS]];
                // using full jid in here
                if (rsa) {
                    [memberKeys setObject:[Base64Security generateBase64String:rsa] forKey:memberJID];
                } else {
                    NSLog(@"MemberJID: %@\nKEY: %@\nPUBLIC KEYs: %@\nRSA: %@", memberJID, key, pubKeys, rsa);
                }
            }
            
            // for myself
            NSString *myJIDFull = [NSString stringWithFormat:@"%@@%@", [KeyChainSecurity getStringFromKey:kJID], [KeyChainSecurity getStringFromKey:kHOST]];
            //NSString *myJID = [KeyChainSecurity getStringFromKey:kJID];
            NSData *myRSA = [RSASecurity encryptRSA:mucKey b64PublicExp:[KeyChainSecurity getStringFromKey:kMOD1_EXPONENT] b64Modulus:[KeyChainSecurity getStringFromKey:kMOD1_MODULUS]];
            [memberKeys setObject:[Base64Security generateBase64String:myRSA] forKey:myJIDFull];
            
            NSString *mucKeyString = [ChatAdapter generateJSON:memberKeys];
            NSDictionary *keyInfo = @{kROOMJID: [response objectForKey:kROOMJID],
                                      kGROUP_KEY: mucKeyString,
                                      kMUC_KEY: mucKey,
                                      kMEMBER_JID_LIST: [members componentsJoinedByString:@","],//[chatRoomInfo objectForKey:kMEMBER_JID_LIST],
                                      kROOM_PASSWORD: [chatRoomInfo objectForKey:kROOM_PASSWORD],
                                      kROOM_IMAGE_URL: @"",
                                      kIS_ADD_PARTICIPANT: @"0",
                                      kROOMNAME: [params objectForKey:kROOMNAME],
                                      kROOM_TS: [NSNumber numberWithDouble:[[NSDate new] timeIntervalSince1970]],
                                      kXMPP_MUC_HOST_NAME: [response objectForKey:@"HOST"]
                                     };
            
            [self uploadMUCKey:keyInfo];
            [[LogFacade share] createEventWithCategory:Chat_Category
                                                action:composeGroup_Action
                                                 label:openChat_Label];
            logDic = @{
                       LOG_CLASS : NSStringFromClass(self.class),
                       LOG_CATEGORY: CATEGORY_MUC_CREATE,
                       LOG_MESSAGE: [NSString stringWithFormat:@"MUC CREATE SUCCESS: ParaDic: %@, Response: %@",params,response],
                       LOG_EXTRA1: @"",
                       LOG_EXTRA2: @""
                       };
            [[LogFacade share] logInfoWithDic:logDic];
        }
        else{
            [groupCreateDelegate didFailCreateGroup];

            // if Token is invalid or expire
            if (response) {
                NSInvocationOperation* operation=  [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(createChatRoomWithInfo:) object:chatRoomInfo];
                
                NSDictionary* retryDictionary = @{kRETRY_OPERATION:operation,kRETRY_TIME:kRETRY_API_COUNTER,
                                                  kSTATUS_CODE : [response objectForKey:kSTATUS_CODE]};
                [[AppFacade share] downloadTokenAgain:retryDictionary];
            }
            
            logDic = @{
                       LOG_CLASS : NSStringFromClass(self.class),
                       LOG_CATEGORY: CATEGORY_MUC_CREATE,
                       LOG_MESSAGE: [NSString stringWithFormat:@"MUC CREATE FAIL: ParaDic: %@, Response: %@, ERROR: %@",params,response,error],
                       LOG_EXTRA1: @"",
                       LOG_EXTRA2: @""
                       };
            [[LogFacade share] logErrorWithDic:logDic];
        }
    }];
}

- (void)getChatRoom:(NSString *)roomjid forJoin:(BOOL)isJoin
{
    //MASKING, TOKEN, IMSI, IMEI, ROOMJID
    NSDictionary *params = @{kIMEI: [[ContactFacade share] getIMEI],
                             kIMSI: [[ContactFacade share] getIMSI],
                             kTOKEN: [[ContactFacade share] getTokentCentral],
                             kROOMJID: roomjid,
                             kMASKINGID: [[ContactFacade share] getMaskingId],
                             kAPI_REQUEST_METHOD: PUT,
                             kAPI_REQUEST_KIND: NORMAL
                             };
    [[ChatRoomAdapter share] getChatRoom:params callback:^(BOOL success, NSString *message, NSDictionary *response, NSError *error) {
        //NSLog(@"%s %@", __PRETTY_FUNCTION__, response);
        if ([response isEqual:[NSNull null]]) {
            // re-try because "Error AFHTTPRequest", maybe server error or network error...
            NSLog(@"%s re-try because \"Error AFHTTPRequest\", maybe server error or network error...", __PRETTY_FUNCTION__);
            return;
        }
        
        if (success) {
            // call get muc key api
            NSArray *roomsResponse = (NSArray*)[response objectForKey:@"CHATROOMS"];
            NSInteger countRooms = [roomsResponse count];
            
            if(countRooms <= 0){
                NSLog(@"ERROR:countRooms = %d", [roomsResponse count]);
                return;
            }
            
            for (int j = 0 ; j < countRooms; j++) {
                NSDictionary *roomOBJ = [[[response objectForKey:@"CHATROOMS"] objectAtIndex:j] objectForKey:@"ROOM"];
                
                NSTimeZone *inputTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
                NSDateFormatter *inputDateFormatter = [[NSDateFormatter alloc] init];
                [inputDateFormatter setTimeZone:inputTimeZone];
                [inputDateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                
                NSDate *groupDate = [inputDateFormatter dateFromString:[roomOBJ objectForKey:@"create_timestamp"]];
                
                NSNumber *timeStamp = [NSNumber numberWithDouble:[groupDate timeIntervalSince1970]];
                
                NSDictionary *info = @{kROOMJID: ([roomOBJ objectForKey:@"room_id"]) ? [roomOBJ objectForKey:@"room_id"] : @"",
                                       kMUC_KEY_VER: @"",//([roomOBJ objectForKey:@"cur_key_version"] && ![[roomOBJ objectForKey:@"cur_key_version"] isEqual:[NSNull null]]) ? [roomOBJ objectForKey:@"cur_key_version"] : @"", -> get all muc keys (for add/kick/re-add many time
                                       kIS_JOIN: (isJoin) ? @"1" : @"0",
                                       kMUC_ROOM_PASSWORD: ([roomOBJ objectForKey:@"password"] && ![[roomOBJ objectForKey:@"password"] isEqual:[NSNull null]]) ? [roomOBJ objectForKey:@"password"] : @"",
                                       kROOM_TS: timeStamp ? timeStamp : @"",
                                       kXMPP_MUC_HOST_NAME: [roomOBJ objectForKey:@"host"] ? [roomOBJ objectForKey:@"host"] : @""
                                       };
                NSLog(@"%s %@", __PRETTY_FUNCTION__, info);
                NSString *strMemberList = @"";
                NSArray *members = [[[response objectForKey:@"CHATROOMS"] objectAtIndex:j] objectForKey:@"MEMBERS"];
                // store members list to DB, it can use in further
                
                if (members) {
                    for (NSDictionary *tmp in members) {
                        
                        NSString* contactJID = [tmp objectForKey:@"jid"];
                        
                        if ([strMemberList length] > 0)
                            strMemberList = [strMemberList stringByAppendingFormat:@",%@", contactJID];
                        else
                            strMemberList = [strMemberList stringByAppendingString:contactJID];
                        
                        if ([contactJID isEqualToString:[[ContactFacade share] getJid:NO]])
                            continue;
                        
                        Contact *contact = [[ContactFacade share] getContact:contactJID];
                        if (!contact) {
                            contact = [Contact new];
                            contact.jid = contactJID;
                            contact.maskingid = [tmp objectForKey:@"masking_id"];
                            contact.contactType = [NSNumber numberWithInt:kCONTACT_TYPE_KRYPTO_USER];
                            [[DAOAdapter share] commitObject:contact];
                            [[ContactFacade share] updateContactInfo:contact.jid];
                        }
                    }
                }
                
                if (isJoin) {
                    NSDictionary *newRoomObj = @{kMEMBER_JID_LIST: strMemberList,
                                                 kROOM_PASSWORD: [roomOBJ objectForKey:@"password"],
                                                 kROOMNAME: [roomOBJ objectForKey:@"name"],
                                                 kROOM_TS: [info objectForKey:kROOM_TS],
                                                 kROOM_IMAGE_URL: [roomOBJ objectForKey:@"url"],
                                                 kXMPP_MUC_HOST_NAME: [info objectForKey:kXMPP_MUC_HOST_NAME],
                                                 kIS_MUC_ADMIN: [[roomOBJ objectForKey:@"owner_jid"] isEqualToString:[[ContactFacade share] getJid:NO]]? @"1": @"0",
                                                 kGROUP_OWNER: [roomOBJ objectForKey:@"owner_jid"]
                                                 };
                    
                    if (!tempRoomCreating) {
                        tempRoomCreating = [NSMutableDictionary new];
                    }
                    
                    [tempRoomCreating setObject:newRoomObj forKey:[info objectForKey:kROOMJID]];
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^(void){
                        [self saveGroupChatInfo:[info objectForKey:kROOMJID]];
                    }];
                } else {
                    //store the group info to local DB
                }
                
                NSLog(@"di lay muc key");
                if ([[ContactFacade share] getReloginFlag]){//restore-relogin
                    NSMutableDictionary *groupInfo = [info mutableCopy];
                    [groupInfo removeObjectForKey:kMUC_KEY_VER];
                    [groupInfo setValue:@"" forKey:kMUC_KEY_VER];//set empty to get all group keys
                    [self getMucKey:groupInfo];
                    
                }else{
                    [self getMucKey:info];
                }
                
                //Download group avatar
                NSOperationQueue *downloadGroupAvatar = [[NSOperationQueue alloc] init];
                [downloadGroupAvatar addOperationWithBlock:^{
                    NSString *urlGroupAvatar = [roomOBJ objectForKey:@"url"];
                    if (urlGroupAvatar.length <= 0)
                        return;
                    
                    [ChatAdapter downloadMedia:[NSURL URLWithString:urlGroupAvatar]
                                 downloadBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead){}
                                      callback:^(BOOL success, NSString *message, NSDictionary *response, NSError *error) {
                                          NSLog(@"%s %@", __PRETTY_FUNCTION__, response);
                                          NSData *imgData = [response objectForKey:kDATA];
                                          if (!imgData)
                                              return;
                                          NSString *roomJidFull = [NSString stringWithFormat:@"%@@%@", [info objectForKey:kROOMJID],[info objectForKey:kXMPP_MUC_HOST_NAME]];
                                          [[ContactAdapter share] setContactAvatar:roomJidFull
                                                                              data:[[AppFacade share]
                                                                                    encryptDataLocally:imgData]];
                                      }];
                }];
            }
        }
        else {
            // oh die :(
            NSInteger statusCode = 0;
            if ([response objectForKey:kSTATUS_CODE] && ![[response objectForKey:kSTATUS_CODE] isEqual:[NSNull null]]) {
                statusCode = [[response objectForKey:kSTATUS_CODE] integerValue];
            }
            
            switch (statusCode) {
                case 20030:
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:[NSString stringWithFormat:@"%@%@", kJOIN_FREFIX, roomjid]];// Chatroom not found, so remove info in NSDefault
                    break;
                    
                default:
                    break;
            }
            
            if (isJoin) {
                // call re-try or mark a FLAG here
            }
        }
    }];
}

- (void)uploadMUCKey:(NSDictionary *)keyInfo
{
    // MASKING, TOKEN, IMSI, IMEI, ROOMJID, GROUPKEY
    NSDictionary *params = @{kIMEI: [[ContactFacade share] getIMEI],
                             kIMSI: [[ContactFacade share] getIMSI],
                             kTOKEN: [[ContactFacade share] getTokentCentral],
                             kMASKINGID: [[ContactFacade share] getMaskingId],
                             kROOMJID: [keyInfo objectForKey:kROOMJID],
                             kGROUP_KEY: [keyInfo objectForKey:kGROUP_KEY],
                             kAPI_REQUEST_METHOD: POST,
                             kAPI_REQUEST_KIND: NORMAL
                            };
    
    [[ChatRoomAdapter share] uploadMUCKey:params callback:^(BOOL success, NSString *message, NSDictionary *response, NSError *error) {
        NSLog(@"%s %@", __PRETTY_FUNCTION__, response);
        if (success) {
            // store chatroom jid and AES key to Key table
            NSString *mucKeyString = [Base64Security generateBase64String:[keyInfo objectForKey:kMUC_KEY]];
            NSDictionary *keyDic = @{kMUC_KEY:mucKeyString};
            
            Key *key = [Key new];
            key.keyId = [NSString stringWithFormat:@"%@@%@", [keyInfo objectForKey:kROOMJID], [keyInfo objectForKey:kXMPP_MUC_HOST_NAME]];
            key.keyJSON = [ChatAdapter generateJSON:keyDic];
            //Encrypt keyJSON value before insert into DB.
            if (key.keyJSON) {
                NSData* keyData = [[AppFacade share] encryptDataLocally:[key.keyJSON dataUsingEncoding:NSUTF8StringEncoding]];
                if (keyData)
                    key.keyJSON = [Base64Security generateBase64String:keyData];
            }
            key.keyVersion = [response objectForKey:kMUC_KEY_VER];
            key.updateTS = [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]];
            
            [[DAOAdapter share] commitObject:key];
            
            if ([[keyInfo objectForKey:kIS_ADD_PARTICIPANT] isEqualToString:@"0"]) {
                // after create room
                NSDictionary *roomObj = @{kMEMBER_JID_LIST: [keyInfo objectForKey:kMEMBER_JID_LIST],
                                          kROOM_PASSWORD: [keyInfo objectForKey:kROOM_PASSWORD],
                                          kROOMNAME: [keyInfo objectForKey:kROOMNAME],
                                          kROOM_TS: [keyInfo objectForKey:kROOM_TS],
                                          kROOM_IMAGE_URL: [keyInfo objectForKey:kROOM_IMAGE_URL],
                                          kIS_MUC_ADMIN: @"1",
                                          kXMPP_MUC_HOST_NAME: [keyInfo objectForKey:kXMPP_MUC_HOST_NAME],
                                          kGROUP_OWNER: [[ContactFacade share] getJid:NO]
                                          };
                
                if (!tempRoomCreating) {
                    tempRoomCreating = [NSMutableDictionary new];
                }
                
                [tempRoomCreating setObject:roomObj forKey:[keyInfo objectForKey:kROOMJID]];
                
                // create the MUC with chatroom info
                NSDictionary *createRoomDic = @{kMUC_ROOM_JID: [keyInfo objectForKey:kROOMJID],
                                                kMUC_ROOM_PASSWORD: [keyInfo objectForKey:kROOM_PASSWORD],
                                                kXMPP_MUC_HOST_NAME: [keyInfo objectForKey:kXMPP_MUC_HOST_NAME]
                                                };
                //MUC_ROOM_JID, MUC_ROOM_PASSWORD, XMPP_MUC_HOST_NAME
                [[XMPPFacade share] createChatRoom:createRoomDic];
            }
            else {
                // after add member(s) to chatroom
                // update members list
                NSString *fullRoomJid = [NSString stringWithFormat:@"%@@%@", [keyInfo objectForKey:kROOMJID], [keyInfo objectForKey:kXMPP_MUC_HOST_NAME]];
                // or manual send notice via David's http post from
                //Maskingid, Imsi, Imei, Token, Roomjid, Roomhost, Roomname, Memberjidlist, Messagetype, Roomlogourl
                
                NSDictionary *groupUpdateDic = @{kROOMJID:[keyInfo objectForKey:kROOMJID],
                                                 kIMEI: [[ContactFacade share] getIMEI],
                                                 kIMSI: [[ContactFacade share] getIMSI],
                                                 kTOKEN: [[ContactFacade share] getTokentTenant],
                                                 kROOM_HOST: [keyInfo objectForKey:kXMPP_MUC_HOST_NAME],
                                                 kMASKINGID: [[ContactFacade share] getMaskingId],
                                                 kMESSAGETYPE: [kBODY_MT_NOTI_GRP_ADD lowercaseString],
                                                 kMEMBER_JID_LIST: [keyInfo objectForKey:kMEMBER_JID_LIST],
                                                 kOCCUPANTS: [keyInfo objectForKey:kOCCUPANTS],
                                                 kROOMNAME: [Base64Security generateBase64String:[self getGroupName:fullRoomJid]],
                                                 kROOMLOGOURL: [self getGroupLogoUrl:fullRoomJid]
                                                 };
                [self sendNoticeForGroupUpdate:groupUpdateDic];

                // invite new members
                
                NSArray *members = [[keyInfo objectForKey:kOCCUPANTS] componentsSeparatedByString:@","];
                for (NSString* toJID in members) {
                    if (toJID.length <= 0)
                        continue;
                    NSDictionary *msgObj = @{kMUC_ROOM_JID:[keyInfo objectForKey:kROOMJID],
                                             kXMPP_TO_JID:toJID,
                                             kMUC_ROOM_PASSWORD: [keyInfo objectForKey:kROOM_PASSWORD],
                                             kMUC_ROOM_INVITE_MESSAGE: @"Join me :)",
                                             kXMPP_MUC_HOST_NAME: [keyInfo objectForKey:kXMPP_MUC_HOST_NAME]
                                             };
                    //MUC_ROOM_JID, XMPP_MUC_HOST_NAME, XMPP_TO_JID, MUC_ROOM_INVITE_MESSAGE
                    
                    [[XMPPFacade share] addUserToChatRoom:msgObj];
                }
            }
            
        } else {
            // failed -
            [[CWindow share] hideLoading];
            if ([[keyInfo objectForKey:kIS_ADD_PARTICIPANT] isEqualToString:@"0"])
                [groupCreateDelegate didFailCreateGroup];
            else{
                [contactInfoDelegate enableTableMemberListInteraction:TRUE];
                [[CAlertView new] showError:ERROR_ADD_FAILED_PLEASE_TRY_LATER];
            }
            
            if (response) {
                // if Token is invalid or expire
                NSInvocationOperation* operation=  [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(uploadMUCKey:) object:keyInfo];
                NSDictionary* retryDictionary = @{kRETRY_OPERATION:operation,kRETRY_TIME:kRETRY_API_COUNTER,
                                                  kSTATUS_CODE : [response objectForKey:kSTATUS_CODE]};
                [[AppFacade share] downloadTokenAgain:retryDictionary];
            }
        }
    }];
}

- (void)getMucKey:(NSDictionary *)keyInfo
{
    // After receive the invitation to chatroom, will call API to get MUC Key from server.
    // If ok, store the key to local DB, then send xmpp comand to join the chat room.
    // MASKINGID, TOKEN, IMSI, IMEI, ROOMJID, VER
    NSDictionary *params = @{kMASKINGID: [[ContactFacade share] getMaskingId],
                             kTOKEN: [[ContactFacade share] getTokentCentral],
                             kIMSI: [[ContactFacade share] getIMSI],
                             kIMEI: [[ContactFacade share] getIMEI],
                             kROOMJID: [keyInfo objectForKey:kROOMJID],
                             kMUC_KEY_VER: [keyInfo objectForKey:kMUC_KEY_VER],
                             kAPI_REQUEST_METHOD: POST,
                             kAPI_REQUEST_KIND: NORMAL
                             };
    
    [[ChatRoomAdapter share] getMUCKey:params callback:^(BOOL success, NSString *message, NSDictionary *response, NSError *error) {
        NSLog(@"%s %@", __PRETTY_FUNCTION__, response);
        if (success) {
            // if request this method for join chatroom
            BOOL isJoin = ([[keyInfo objectForKey:kIS_JOIN] isEqualToString:@"1"]) ? TRUE : FALSE;
            // store key to local db
            // send xmpp command to join chat rom
            // latest API response a nsarray of KEYS for group key, the [response objectForKey:kMUC_KEY_S] must be change to get
            NSArray *arrGroupKeys = (NSArray *)[response objectForKey:kGROUP_KEY];
            
            if ([arrGroupKeys count]>0) {

                NSString *roomJID = [NSString stringWithFormat:@"%@@%@", [keyInfo objectForKey:kROOMJID], [keyInfo objectForKey:kXMPP_MUC_HOST_NAME]];
                
                for (int i=0; i<[arrGroupKeys count]; i++) {
                    NSDictionary *keyObj = [arrGroupKeys objectAtIndex:i];
                    if (![[keyObj objectForKey:kMUC_KEY_S] length] > 0) {
                        break;
                    }
                    
                    BOOL isLatest = FALSE;
                    if ([keyObj objectForKey:@"LAST"]) {
                        isLatest = [[keyObj objectForKey:@"LAST"] boolValue];
                    }
                    
                    NSData *tmpDecryptKey = [RSASecurity decryptRSA:[keyObj objectForKey:kMUC_KEY_S] b64PublicExp:[KeyChainSecurity getStringFromKey:kMOD1_EXPONENT] b64Modulus:[KeyChainSecurity getStringFromKey:kMOD1_MODULUS] b64PrivateExp:[KeyChainSecurity getStringFromKey:kMOD1_PRIVATE]];
                    NSString *mucKeyString = [Base64Security generateBase64String:tmpDecryptKey];
                    NSString *mucKeyVersion = [keyObj objectForKey:kMUC_KEY_VER];
                    
                    if (mucKeyString && mucKeyVersion) {
                        //save to db
                        NSDictionary *keyJSON = @{kMUC_KEY:mucKeyString};
                        
                        Key *key = [[AppFacade share] getKeyForGroup:roomJID andVersion:mucKeyVersion];
                        if (!key) {
                            key = [Key new];
                            key.keyId = roomJID;
                        }
                        key.keyJSON = [ChatAdapter generateJSON:keyJSON];
                        if (key.keyJSON) {
                            NSData* keyData = [[AppFacade share] encryptDataLocally:[key.keyJSON dataUsingEncoding:NSUTF8StringEncoding]];
                            if (keyData)
                                key.keyJSON = [Base64Security generateBase64String:keyData];
                        }
                        key.keyVersion = mucKeyVersion;

                        key.updateTS = [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]];
                        //NSLog(@"key.updateTS: %@", key.updateTS);
                        if (isLatest) {
                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                key.updateTS = [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]];
                                [[DAOAdapter share] commitObject:key];
                            });
                        }
                        
                        [[DAOAdapter share] commitObject:key];
                    }
                }
                
                if (isJoin) {
                    NSMutableDictionary *objInfo = [NSMutableDictionary new];
                    [objInfo setObject:roomJID forKey:kMUC_ROOM_JID];
                    [objInfo setObject:[[ContactFacade share] getJid:YES] forKey:kXMPP_USER_DISPLAYNAME];
                    [objInfo setObject:[keyInfo objectForKey:kMUC_ROOM_PASSWORD] forKey:kMUC_ROOM_PASSWORD];
                    
                    ChatBox *cb = [[AppFacade share] getChatBox:roomJID];
                    if (cb && cb.extend2) {
                        NSDictionary *ext2 = [ChatAdapter decodeJSON:cb.extend2];
                        if ([[ext2 objectForKey:@"joined"] isEqualToString:@"1"] && [cb.updateTS doubleValue] > 0) {
                            [objInfo setObject:[NSString stringWithFormat:@"%@", cb.updateTS] forKey:kMUC_HISTORY];
                        }
                    }
                    
                    GroupMember* groupMember = [[AppFacade share] getGroupMember:roomJID
                                                                         userJID:[[ContactFacade share] getJid:YES]];
                    NSTimeInterval kickTime = [[ChatAdapter convertDate:groupMember.extend1
                                                                 format:FORMAT_DATE_DETAIL_ACCOUNT] doubleValue];
                    NSTimeInterval addTime = [[ChatAdapter convertDate:groupMember.extend2
                                                                format:FORMAT_DATE_DETAIL_ACCOUNT] doubleValue];
                    
                    NSLog(@"kickTime %f", kickTime);
                    NSLog(@"addTime %f", addTime);
                    
                    if(addTime > 0 && kickTime > addTime){
                        [objInfo setObject:[NSString stringWithFormat:@"%@", [NSNumber numberWithInt:addTime]]
                                    forKey:kMUC_HISTORY];
                    }
                    
                    NSLog(@"objInfo %@", objInfo);
                    
                    [[XMPPFacade share] joinToChatRoom:objInfo];
                    
                    if ([[ContactFacade share] getReloginFlag]){//restore chatbox when restore group chat
                        if (!cb) {
                            [[ChatFacade share] createChatBox:roomJID isMUC:YES];
                            //Update create time for group chat
                            ChatBox *chatBoxObj = [[AppFacade share] getChatBox:roomJID];
                            if([[keyInfo objectForKey:kROOM_TS] doubleValue] > 0)
                                chatBoxObj.updateTS = [keyInfo objectForKey:kROOM_TS];
                            [[DAOAdapter share] commitObject:chatBoxObj];
                        }
                        [self rejoinGroups];
                    }
                }
            }
        }
        else if(response){
            NSInvocationOperation* operation=  [[NSInvocationOperation alloc] initWithTarget:self
                                                                                    selector:@selector(getMucKey:)
                                                                                      object:keyInfo];
            NSDictionary* retryDictionary = @{kRETRY_OPERATION:operation,
                                              kRETRY_TIME:kRETRY_API_COUNTER,
                                              kSTATUS_CODE : [response objectForKey:kSTATUS_CODE]};
            [[AppFacade share] downloadTokenAgain:retryDictionary];
        }
    }];

}

- (void)leaveFromChatRoom:(NSDictionary *)infoObj
{
    NSLog(@"%s %@", __PRETTY_FUNCTION__, infoObj);
    Contact *target = [[ContactFacade share] getContact:[infoObj objectForKey:kXMPP_TO_JID]];
    NSString *myJID = [[ContactFacade share] getJid:YES];
    
    // if user is not member of this room, just delete chatbox
    GroupMember *gm = [[AppFacade share] getGroupMember:[infoObj objectForKey:kMUC_ROOM_JID] userJID:myJID];
    ChatBox *cb = (ChatBox *)[[AppFacade share] getChatBox:[infoObj objectForKey:kMUC_ROOM_JID]];
    if (!gm || ![gm.memberState isEqualToNumber:[NSNumber numberWithInt:kGROUP_MEMBER_STATE_ACTIVE]]) {
        if (cb) {
            cb.chatboxState = [NSNumber numberWithInt:kCHATBOX_STATE_NOTDISPLAY];
            [[ChatFacade share] removeAllChatBoxMessage:cb.chatboxId];
            [[DAOAdapter share] commitObject:cb];
        }
        [[ChatFacade share] reloadChatBoxList];
        [chatListEditDelegate doneLeaveChatBox:nil];
        [chatListDelegate doneLeaveChatBox:nil];
        return;
    }
    
    BOOL isKick = ![[infoObj objectForKey:kXMPP_TO_JID] isEqualToString:myJID];
    
    if (!target && isKick) {
        [chatListEditDelegate doneLeaveChatBox:ERROR_CANNOT_LEAVE_OR_KICK_ALERT];
        [chatListDelegate doneLeaveChatBox:ERROR_CANNOT_LEAVE_OR_KICK_ALERT];
        return;
    }
    
    NSString *groupJid = [[[infoObj objectForKey:kMUC_ROOM_JID] componentsSeparatedByString:@"@"] objectAtIndex:0];
    NSString *groupHost = [[[infoObj objectForKey:kMUC_ROOM_JID] componentsSeparatedByString:@"@"] objectAtIndex:1];
    
    NSString *memberMaskingId = isKick ? target.maskingid: [[ContactFacade share] getMaskingId];
    [windowDelegate showLoading:isKick ? kLOADING_KICKING:kLOADING_LEAVING];
    
    // MASKING, TOKEN, IMSI, IMEI, ROOMJID, MEMBERMASKINGID, KILLROOM (optional 0 or 1)
    NSDictionary *leaveDic = @{kMASKINGID: [[ContactFacade share] getMaskingId],
                               kIMSI: [[ContactFacade share] getIMSI],
                               kIMEI: [[ContactFacade share] getIMEI],
                               kTOKEN: [[ContactFacade share] getTokentTenant],
                               kCENTRALTOKEN: [[ContactFacade share] getTokentCentral],
                               kROOMJID: groupJid,
                               kROOM_HOST: groupHost,
                               kMEMBER_MASKINGID: memberMaskingId,
                               kKILL_ROOM: @"0",
                               kAPI_REQUEST_METHOD: PUT,
                               kAPI_REQUEST_KIND: NORMAL
                               };
    
    [[ChatRoomAdapter share] leaveFromChatRoom:leaveDic callback:^(BOOL success, NSString *message, NSDictionary *response, NSError *error) {
        NSDictionary *logDic;
        [windowDelegate hideLoading];
        NSLog(@"%s %@", __PRETTY_FUNCTION__, response);
        if (success) {
            if (isKick) {
                // send xmpp command to tell target know he was kicked by admin.
                [[XMPPFacade share] kickMemberFromChatRoom:infoObj];
                logDic = @{
                           LOG_CLASS : NSStringFromClass(self.class),
                           LOG_CATEGORY: CATEGORY_MUC_KICK,
                           LOG_MESSAGE: [NSString stringWithFormat:@"MUC KICK SUCCESS: ParaDic: %@, Response: %@",leaveDic,response],
                           LOG_EXTRA1: @"",
                           LOG_EXTRA2: @""
                           };
                [[LogFacade share] logInfoWithDic:logDic];
                
            } else {
                if (cb)
                    [[ChatFacade share] removeAllChatBoxMessage:cb.chatboxId];
                
                [[XMPPFacade share] leaveChatRoom:infoObj];
                [chatViewDelegate backView];
                logDic = @{
                           LOG_CLASS : NSStringFromClass(self.class),
                           LOG_CATEGORY: CATEGORY_MUC_LEAVE,
                           LOG_MESSAGE: [NSString stringWithFormat:@"MUC LEAVE SUCESS: ParaDic: %@, Response: %@",leaveDic,response],
                           LOG_EXTRA1: @"",
                           LOG_EXTRA2: @""
                           };
                [[LogFacade share] logInfoWithDic:logDic];
            }
            
            // call API to send notice to all members
            NSArray *arrMembers = [self getMembersList:[infoObj objectForKey:kMUC_ROOM_JID]];// in this step, all members still included the leaved/kicked occupant
            NSString *strMembers = @"";
            for (GroupMember *gm in arrMembers) {
                if ([strMembers length] > 0){
                    strMembers = [strMembers stringByAppendingString:@","];
                }
                strMembers = [strMembers stringByAppendingString:gm.jid];
            }
            
            NSDictionary *groupUpdateDic = @{kROOMJID:[[[infoObj objectForKey:kMUC_ROOM_JID] componentsSeparatedByString:@"@"] objectAtIndex:0],
                                             kIMEI: [[ContactFacade share] getIMEI],
                                             kIMSI: [[ContactFacade share] getIMSI],
                                             kTOKEN: [[ContactFacade share] getTokentTenant],
                                             kROOM_HOST: [[[infoObj objectForKey:kMUC_ROOM_JID] componentsSeparatedByString:@"@"] objectAtIndex:1],
                                             kMASKINGID: [[ContactFacade share] getMaskingId],
                                             kMESSAGETYPE: isKick ? [kBODY_MT_NOTI_GRP_KICK lowercaseString] : [kBODY_MT_NOTI_GRP_LEFT lowercaseString],
                                             kMEMBER_JID_LIST: strMembers,
                                             kOCCUPANTS: [infoObj objectForKey:kXMPP_TO_JID],
                                             kROOMNAME: @"",
                                             kROOMLOGOURL: @""
                                             };
            [self sendNoticeForGroupUpdate:groupUpdateDic];
            [chatListEditDelegate doneLeaveChatBox:nil];
            [chatListDelegate doneLeaveChatBox:nil];
        }
        else {
            [windowDelegate hideLoading];
            if (isKick){
                [chatListEditDelegate doneLeaveChatBox:ERROR_KICK_FAILED];
                [contactInfoDelegate enableTableMemberListInteraction:TRUE];
                logDic = @{
                           LOG_CLASS : NSStringFromClass(self.class),
                           LOG_CATEGORY: CATEGORY_MUC_KICK,
                           LOG_MESSAGE: [NSString stringWithFormat:@"MUC KICK FAIL: ParaDic: %@, Response: %@, ERROR: %@",leaveDic,response,error],
                           LOG_EXTRA1: @"",
                           LOG_EXTRA2: @""
                           };
                [[LogFacade share] logErrorWithDic:logDic];
            }
            else{
                if ([error.domain isEqualToString:NSURLErrorDomain])
                {
                    [chatListDelegate doneLeaveChatBox:ERROR_NO_INTERNET_CONNECTION];
                    [chatListEditDelegate doneLeaveChatBox:ERROR_NO_INTERNET_CONNECTION];
                
                }else{
                    [chatListEditDelegate doneLeaveChatBox:ERROR_LEAVE_FAILED];
                    [chatListDelegate doneLeaveChatBox:ERROR_LEAVE_FAILED];
                }
                
                //[self reloadChatBoxList];
                logDic = @{
                           LOG_CLASS : NSStringFromClass(self.class),
                           LOG_CATEGORY: CATEGORY_MUC_LEAVE,
                           LOG_MESSAGE: [NSString stringWithFormat:@"MUC LEAVE FAIL: ParaDic: %@, Response: %@, ERROR: %@",leaveDic,response,error],
                           LOG_EXTRA1: @"",
                           LOG_EXTRA2: @""
                           };
                [[LogFacade share] logErrorWithDic:logDic];
            }
            if (response){
                NSInvocationOperation* operation=  [[NSInvocationOperation alloc] initWithTarget:self
                                                                                        selector:@selector(leaveFromChatRoom:)
                                                                                          object:infoObj];
                NSDictionary* retryDictionary = @{kRETRY_OPERATION:operation,
                                                  kRETRY_TIME:kRETRY_API_COUNTER,
                                                  kSTATUS_CODE : [response objectForKey:kSTATUS_CODE]};
                
                [[AppFacade share] downloadTokenAgain:retryDictionary];
            }
        }
    }];
}

- (void)kickMember:(NSDictionary *)infoObj
{
    if ([[ContactFacade share] isAccountRemoved]) {
        [[CAlertView new] showError:ERROR_ACCOUNT_REMOVED];
        return;
    }
    
    if (![[NotificationFacade share] isInternetConnected]){
        [[CAlertView new] showError:NO_INTERNET_CONNECTION_TRY_LATER];
        return;
    }
    
    if ([self isAdmin:[infoObj objectForKey:kMUC_ROOM_JID]]) {
        [contactInfoDelegate enableTableMemberListInteraction:FALSE];
        [self leaveFromChatRoom:infoObj];
    }
}

- (void)addMember:(NSDictionary *)infoObj
{
    if (![self isAdmin:[infoObj objectForKey:kMUC_ROOM_JID]])
        return;
    
    //MASKING, TOKEN, IMSI, IMEI, ROOMJID, MEMBERMASKINGID
    NSDictionary *addDic = @{kROOMJID: [[[infoObj objectForKey:kMUC_ROOM_JID] componentsSeparatedByString:@"@"] objectAtIndex:0],
                             kTOKEN: [[ContactFacade share] getTokentTenant],
                             kCENTRALTOKEN: [[ContactFacade share] getTokentCentral],
                             kIMSI: [[ContactFacade share] getIMSI],
                             kIMEI: [[ContactFacade share] getIMEI],
                             kMASKINGID: [[ContactFacade share] getMaskingId],
                             kMEMBER_MASKINGID: [infoObj objectForKey:kMEMBER_MASKINGID],
                             kROOM_HOST: [[ContactFacade share] getXmppMUCHostName],
                             kAPI_REQUEST_METHOD: PUT,
                             kAPI_REQUEST_KIND: NORMAL
                             };
    
    [[ChatRoomAdapter share] addMemberToChatRoom:addDic callback:^(BOOL success, NSString *message, NSDictionary *response, NSError *error) {
        NSLog(@"%s %@", __PRETTY_FUNCTION__, response);
        if (success) {
            //1. gen random AES -> group Key -> upload to server
            NSData *mucKey = [AESSecurity randomDataOfLength:32];
            NSLog(@"GROUP KEY (AES-BASED64): %@", [Base64Security generateBase64String:mucKey]);
            NSArray *members = [[infoObj objectForKey:kMEMBER_JID_LIST] componentsSeparatedByString:@","];// new members are adding
            NSString *strNewMembers = [infoObj objectForKey:kMEMBER_JID_LIST] ? [infoObj objectForKey:kMEMBER_JID_LIST] : @"";
            
            NSMutableArray *oldMembers = [[self getMembersList:[infoObj objectForKey:kMUC_ROOM_JID]] mutableCopy];
            if ([oldMembers count] > 0) {
                for (int i=0; i<[oldMembers count]; i++) {
                    GroupMember *gm = (GroupMember *)[oldMembers objectAtIndex:i];
                    NSString *tmpJID = gm.jid;
                    [oldMembers replaceObjectAtIndex:i withObject:tmpJID];
                }
            }
            [oldMembers addObjectsFromArray:members];
            NSLog(@"%s New Members: %@", __PRETTY_FUNCTION__, oldMembers);
            NSMutableDictionary *memberKeys = [NSMutableDictionary new];
            
            // for members
            NSString *myJIDFull = [[ContactFacade share] getJid:YES];
            //for notice API
            NSString *allMembersJID = [oldMembers componentsJoinedByString:@","];
            for (NSString *memberJID in oldMembers) {
                if ([memberJID isEqualToString:myJIDFull]) {
                    // for myself
                    NSData *myRSA = [RSASecurity encryptRSA:mucKey
                                               b64PublicExp:[KeyChainSecurity getStringFromKey:kMOD1_EXPONENT]
                                                 b64Modulus:[KeyChainSecurity getStringFromKey:kMOD1_MODULUS]];
                    if (myRSA) {
                        [memberKeys setObject:[Base64Security generateBase64String:myRSA] forKey:myJIDFull];
                    } else {
                        NSLog(@"%s Error: RSA for %@ is nil!", __PRETTY_FUNCTION__, myJIDFull);
                    }
                }
                else {
                    Key *key = [[AppFacade share] getKey:memberJID];
                    if (key.keyJSON) {
                        NSData* keyData = [Base64Security decodeBase64String:key.keyJSON];
                        if(keyData)
                            key.keyJSON = [[NSString alloc] initWithData:[[AppFacade share] decryptDataLocally:keyData]
                                                                encoding:NSUTF8StringEncoding];
                    }
                    NSDictionary *pubKeys = [ChatAdapter decodeJSON:key.keyJSON];
                    NSData *rsa = [RSASecurity encryptRSA:mucKey
                                             b64PublicExp:[pubKeys objectForKey:kMOD1_EXPONENT]
                                               b64Modulus:[pubKeys objectForKey:kMOD1_MODULUS]];
                    // using full jid in here
                    if (rsa) {
                        [memberKeys setObject:[Base64Security generateBase64String:rsa] forKey:memberJID];
                    } else {
                        NSLog(@"%s Error: RSA for %@ is nil!", __PRETTY_FUNCTION__, memberJID);
                    }
                }
            }
            
            NSString *mucKeyString = [ChatAdapter generateJSON:memberKeys];
            NSDictionary *keyInfo = @{kROOMJID: [addDic objectForKey:kROOMJID],
                                      kGROUP_KEY: mucKeyString,
                                      kMUC_KEY: mucKey,
                                      kMEMBER_JID_LIST: allMembersJID,
                                      kOCCUPANTS: strNewMembers,
                                      kROOM_PASSWORD: [infoObj objectForKey:kROOM_PASSWORD],
                                      kROOM_IMAGE_URL: @"",
                                      kIS_ADD_PARTICIPANT: @"1",
                                      kROOMNAME: [infoObj objectForKey:kROOMNAME],
                                      kROOM_TS: [NSNumber numberWithDouble:[[NSDate new] timeIntervalSince1970]],
                                      kXMPP_MUC_HOST_NAME: [addDic objectForKey:kROOM_HOST]
                                      };
            
            [self uploadMUCKey:keyInfo];
        }
        else if (response){
            // if Token is invalid or expire
            NSInvocationOperation* operation=  [[NSInvocationOperation alloc] initWithTarget:self
                                                                                    selector:@selector(addMember:)
                                                                                      object:infoObj];
            NSDictionary* retryDictionary = @{kRETRY_OPERATION:operation,
                                              kRETRY_TIME:kRETRY_API_COUNTER,
                                              kSTATUS_CODE : [response objectForKey:kSTATUS_CODE]};
            [[AppFacade share] downloadTokenAgain:retryDictionary];
        }
        [windowDelegate hideLoading];
    }];
}


- (void)setChatRoomName:(NSDictionary *)infoObj callback:(reqCompleteBlock)callback
{
    __block NSDictionary* blkInfoObj = infoObj;
    __block reqCompleteBlock blkCallback = callback;
    
    void (^setChatRoomNameBlock)(BOOL success, NSString *message ,NSDictionary *response, NSError *error) = callback;
    // MASKING, TOKEN, IMSI, IMEI, ROOMJID, ROOMNAME
    NSDictionary *setNameDic = @{kMASKINGID: [[ContactFacade share] getMaskingId],
                                 kTOKEN: [[ContactFacade share] getTokentTenant],
                                 kCENTRALTOKEN: [[ContactFacade share] getTokentCentral],
                                 kIMSI: [[ContactFacade share] getIMSI],
                                 kIMEI: [[ContactFacade share] getIMEI],
                                 kROOMJID: [[[infoObj objectForKey:kROOMJID] componentsSeparatedByString:@"@"] objectAtIndex:0],
                                 kROOMNAME: [infoObj objectForKey:kROOMNAME],
                                 kAPI_REQUEST_METHOD: PUT,
                                 kAPI_REQUEST_KIND: NORMAL,
                                 kROOM_HOST: [[[infoObj objectForKey:kROOMJID] componentsSeparatedByString:@"@"] objectAtIndex:1]
                                 };
    
    [[ChatRoomAdapter share] updateNameForChatRoom:setNameDic callback:^(BOOL success, NSString *message, NSDictionary *response, NSError *error) {
        NSLog(@"%s %@", __PRETTY_FUNCTION__, response);
        setChatRoomNameBlock(success, message, response, error);
        NSDictionary *logDic;
        if (success) {
            // call API to send notice to all members
            NSArray *arrMembers = [self getMembersList:[infoObj objectForKey:kROOMJID]];
            NSString *strMembers = @"";
            for (GroupMember *gm in arrMembers) {
                if ([strMembers length] > 0) {
                    strMembers = [strMembers stringByAppendingString:@","];
                }
                strMembers = [strMembers stringByAppendingString:gm.jid];
            }
            
            NSDictionary *groupUpdateDic = @{kROOMJID:[[[infoObj objectForKey:kROOMJID] componentsSeparatedByString:@"@"] objectAtIndex:0],
                                             kIMEI: [[ContactFacade share] getIMEI],
                                             kIMSI: [[ContactFacade share] getIMSI],
                                             kTOKEN: [[ContactFacade share] getTokentTenant],
                                             kROOM_HOST: [[[infoObj objectForKey:kROOMJID] componentsSeparatedByString:@"@"] objectAtIndex:1],
                                             kMASKINGID: [[ContactFacade share] getMaskingId],
                                             kMESSAGETYPE: [kBODY_MT_NOTI_GRP_CHG_NAME lowercaseString],
                                             kMEMBER_JID_LIST: strMembers,
                                             kOCCUPANTS: [[ContactFacade share] getJid:YES],
                                             kROOMNAME: [infoObj objectForKey:kROOMNAME],
                                             kROOMLOGOURL: @""
                                             };
            [self sendNoticeForGroupUpdate:groupUpdateDic];
            logDic = @{
                       LOG_CLASS : NSStringFromClass(self.class),
                       LOG_CATEGORY: CATEGORY_MUC_CHANGE_NAME,
                       LOG_MESSAGE: [NSString stringWithFormat:@"MUC CHANGE NAME SUCCESS: ParaDic: %@, Response: %@",setNameDic,response],
                       LOG_EXTRA1: @"",
                       LOG_EXTRA2: @""
                       };
            [[LogFacade share] logInfoWithDic:logDic];
        }
        else
        {
            if (response){
                SEL  currentSelector = @selector(setChatRoomName:callback:);
                NSMethodSignature * methSig          = [self methodSignatureForSelector: currentSelector];
                NSInvocation      * invocation       = [NSInvocation invocationWithMethodSignature: methSig];
                [invocation setSelector: currentSelector];
                [invocation setTarget: self];
                [invocation setArgument: &blkInfoObj atIndex: 2];
                [invocation setArgument: &blkCallback atIndex: 3];
                NSInvocationOperation* operation =  [[NSInvocationOperation alloc] initWithInvocation:invocation];
                NSDictionary* retryDictionary = @{kRETRY_OPERATION:operation,
                                                  kRETRY_TIME:kRETRY_API_COUNTER,
                                                  kSTATUS_CODE : [response objectForKey:kSTATUS_CODE]};
                
                [[AppFacade share] downloadTokenAgain:retryDictionary];
            }
            logDic = @{
                       LOG_CLASS : NSStringFromClass(self.class),
                       LOG_CATEGORY: CATEGORY_MUC_CHANGE_NAME,
                       LOG_MESSAGE: [NSString stringWithFormat:@"MUC CHANGE NAME FAIL: ParaDic: %@, Response: %@, ERROR: %@",setNameDic,response,error],
                       LOG_EXTRA1: @"",
                       LOG_EXTRA2: @""
                       };
            [[LogFacade share] logErrorWithDic:logDic];
        }
    }];
}

- (void)setChatRoomLogo:(NSDictionary *)infoObj
{
    NSLog(@"%s %@", __PRETTY_FUNCTION__, infoObj);
    
    [windowDelegate showLoading:kLOADING_UPDATING];
    [[ChatFacade share] uploadMediaFile:[infoObj objectForKey:kROOM_IMAGE_DATA]
                              messageId:nil
                              targetJID:[infoObj objectForKey:kMUC_ROOM_JID]
                             uploadType:kUPLOAD_TYPE_LOGO_MUC];
}

#pragma mark - Logic methods -
- (void)queryAddMembersToChatRoom:(NSString *)roomJID
{
    /*
    NSDictionary *roomObj = @{kMEMBER_JID_LIST: @"ddd",
                              kROOM_PASSWORD: @"",
                              kXMPP_MUC_HOST_NAME: @""
                              };
     */
    NSDictionary *roomObj = [tempRoomCreating objectForKey:roomJID];
    if (roomObj) {
        NSArray *members = [[roomObj objectForKey:kMEMBER_JID_LIST] componentsSeparatedByString:@","];
        for (NSString* toJID in members) {
            if (toJID.length <= 0)
                continue;
            
            NSDictionary *msgObj = @{kMUC_ROOM_JID:roomJID,
                                     kXMPP_TO_JID:toJID,
                                     kMUC_ROOM_PASSWORD: [roomObj objectForKey:kROOM_PASSWORD],
                                     kMUC_ROOM_INVITE_MESSAGE: @"Join me :)",
                                     kXMPP_MUC_HOST_NAME: [roomObj objectForKey:kXMPP_MUC_HOST_NAME]
                                     };
            [[XMPPFacade share] addUserToChatRoom:msgObj];
        }
    }
}

- (BOOL)saveGroupChatInfo:(NSString *)roomJID
{
    NSDictionary *roomObj = [tempRoomCreating objectForKey:roomJID];
    if (roomObj) {
        NSLog(@"saveGroupChatInfo %@", roomObj);
        
        NSString *roomJidFull = [NSString stringWithFormat:@"%@@%@", roomJID, [roomObj objectForKey:kXMPP_MUC_HOST_NAME]];
        GroupObj *tmp = [[AppFacade share] getGroupObj:roomJidFull];
        
        if (!tmp) {
            tmp = [GroupObj new];
            tmp.groupId = roomJidFull;
            tmp.groupPassword = [roomObj objectForKey:kROOM_PASSWORD];
        }
        tmp.groupName = [[NSString alloc] initWithData:[Base64Security decodeBase64String:[roomObj objectForKey:kROOMNAME]] encoding:NSUTF8StringEncoding];
        tmp.groupImageURL = [roomObj objectForKey:kROOM_IMAGE_URL];
        tmp.updateTS = [roomObj objectForKey:kROOM_TS];
        [[DAOAdapter share] commitObject:tmp];
        
        // Get old Member List
        NSMutableArray *oldMemberList = [[self getMembersList:roomJidFull] mutableCopy];
        
        // next: save to GroupMember table
        // for current user
        GroupMember *gMem = [[AppFacade share] getGroupMember:roomJidFull
                                                      userJID:[[ContactFacade share] getJid:YES]];
        if (!gMem) {
            gMem = [GroupMember new];
            gMem.groupId = roomJidFull;
            gMem.jid = [[ContactFacade share] getJid:YES];
            gMem.memberColor = [UIColor randomHexColor];
        }
        
        NSTimeInterval kickTime = [[ChatAdapter convertDate:gMem.extend1
                                                     format:FORMAT_DATE_DETAIL_ACCOUNT] doubleValue];
        NSTimeInterval addTime = [[ChatAdapter convertDate:gMem.extend2
                                                    format:FORMAT_DATE_DETAIL_ACCOUNT] doubleValue];
        
        NSLog(@"kickTime %f", kickTime);
        NSLog(@"addTime %f", addTime);
        
        if(kickTime > 0 && kickTime > addTime){
            gMem.memberState = [NSNumber numberWithInt:kGROUP_MEMBER_STATE_KICKED];
        }
        else{
            gMem.memberState = [NSNumber numberWithInt:kGROUP_MEMBER_STATE_ACTIVE];
        }
        
        if ([[roomObj objectForKey:kIS_MUC_ADMIN] isEqualToString:@"1"])
            gMem.memberRole = [NSNumber numberWithInt:kGROUP_MEMBER_ROLE_ADMIN];
        else
            gMem.memberRole = [NSNumber numberWithInt:kGROUP_MEMBER_ROLE_MEMBER];
        
        [[DAOAdapter share] commitObject:gMem];
        // for other members of group
        NSArray *arrMemberList = [[roomObj objectForKey:kMEMBER_JID_LIST] componentsSeparatedByString:@","];
        
        NSMutableArray *activeMemberJIDList =[NSMutableArray new];
        [activeMemberJIDList addObject: [[ContactFacade share] getJid:YES]]; // add myself
        
        for (NSString* tmpJID in arrMemberList) {
            if([tmpJID isEqualToString:[[ContactFacade share] getJid:YES]])
                continue;
            if(tmpJID.length <= 0)
                continue;
            
            [[ContactFacade share] requestContactInfo:tmpJID];
            GroupMember *gMem = [[AppFacade share] getGroupMember:roomJidFull userJID:tmpJID];
            if (!gMem) { // new member
                gMem = [GroupMember new];
                gMem.groupId = roomJidFull;
                gMem.jid = tmpJID;
            }
            
            // Active member
            [activeMemberJIDList addObject:tmpJID];
           
            
            if(gMem.extend1.length > 0){
                NSLog(@"YOU WAS KICKED AT %@", gMem.extend1);
                NSLog(@"UPDATE ROOM TS %@", [ChatAdapter convertDateToString:[roomObj objectForKey:kROOM_TS]
                                                                      format:FORMAT_DATE_DETAIL_ACCOUNT]);
            }
            else{
                gMem.memberState = [NSNumber numberWithInt:kGROUP_MEMBER_STATE_ACTIVE];
                if ([[roomObj objectForKey:kGROUP_OWNER] isEqualToString:[[tmpJID componentsSeparatedByString:@"@"] objectAtIndex:0]]) {
                    gMem.memberRole = [NSNumber numberWithInt:kGROUP_MEMBER_ROLE_ADMIN];
                } else {
                    gMem.memberRole = [NSNumber numberWithInt:kGROUP_MEMBER_ROLE_MEMBER];
                }
            }

            gMem.memberColor = [UIColor randomHexColor];
            [[DAOAdapter share] commitObject:gMem];
        }
        
       // update the old member list
        for (GroupMember *groupMember in [oldMemberList mutableCopy]) {
            if (![activeMemberJIDList containsObject:groupMember.jid]) // remove active member,
            {
                groupMember.memberState = [NSNumber numberWithInt:kGROUP_MEMBER_STATE_LEAVE];
                [[DAOAdapter share] commitObject:groupMember];
            }            
        }
    }
    
    return NO;
}

- (BOOL)updateGroupChatInfo:(NSDictionary *)groupInfo
{
    NSLog(@"%s %@", __PRETTY_FUNCTION__, groupInfo);
    if (![groupInfo objectForKey:kROOMJID])
        return FALSE;
    
    GroupObj *groupObj = [[AppFacade share] getGroupObj:[groupInfo objectForKey:kROOMJID]];
    
    if (groupObj) {
        NSString* groupName = [groupInfo objectForKey:kROOMNAME];
        if (![groupName isEqual:[NSNull null]] && groupName.length > 0) {
            groupObj.groupName = [[NSString alloc] initWithData:[Base64Security decodeBase64String:groupName] encoding:NSUTF8StringEncoding];
        }
        
        if ([groupInfo objectForKey:kROOM_IMAGE_URL])
            groupObj.groupImageURL = [groupInfo objectForKey:kROOM_IMAGE_URL];
        if ([groupInfo objectForKey:kROOM_TS])
            groupObj.updateTS = [groupInfo objectForKey:kROOM_TS];
        if ([groupInfo objectForKey:kROOM_EXT1])
            groupObj.extend1 = [groupInfo objectForKey:kROOM_EXT1];
        if ([groupInfo objectForKey:kROOM_EXT2])
            groupObj.extend2 = [groupInfo objectForKey:kROOM_EXT2];
    }
    [[DAOAdapter share] commitObject:groupObj];
    [contactInfoDelegate buildView];
    return TRUE;
}

- (void)saveMember:(NSString *)jid toGroup:(NSString *)roomjid withState:(int)state andRole:(int)role
{
     NSLog(@"%s Jid:%@,RoomJid: %@, State:%d, Role: %d", __PRETTY_FUNCTION__, jid, roomjid, state, role);
    if (!jid.length > 0 || !roomjid.length > 0) {
        return;
    }

    GroupMember *tmpGM = [[AppFacade share] getGroupMember:roomjid userJID:jid];
    if (tmpGM) {
        tmpGM.memberState = [NSNumber numberWithInt:state];
        tmpGM.memberRole = [NSNumber numberWithInt:role];
        [[DAOAdapter share] commitObject:tmpGM];
    }
    else {
        tmpGM = [GroupMember new];
        tmpGM.groupId = roomjid;
        tmpGM.jid = jid;
        tmpGM.memberState = [NSNumber numberWithInt:state];
        tmpGM.memberRole = [NSNumber numberWithInt:role];
        tmpGM.memberJoinTS = [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]];
        
        [[DAOAdapter share] commitObject:tmpGM];
    }
    
}

- (NSMutableArray *)rejoinGroups
{
    // get all room and re-join to chat
    NSString *queryCondition = [NSString stringWithFormat:@"jid = '%@' AND memberState == '2'", [[ContactFacade share] getJid:YES]];
    NSArray *tmp = [[DAOAdapter share] getObjects:[GroupMember class] condition:queryCondition];
    NSMutableArray *joinedArrayRoomJID = [NSMutableArray new];
    
    if ([tmp count]>0) {
        [joinedArrayRoomJID removeAllObjects];
        for (GroupMember *gm in tmp) {
            //NSLog(@"%@ re-join back to group %@", gm.jid, gm.groupId);
            [joinedArrayRoomJID addObject:gm.groupId];
            GroupObj *go = [[AppFacade share] getGroupObj:gm.groupId];
            if(!go)
                continue;
            
            NSMutableDictionary *objInfo = [NSMutableDictionary new];
            [objInfo setObject:go.groupId forKey:kMUC_ROOM_JID];
            [objInfo setObject:gm.jid forKey:kXMPP_USER_DISPLAYNAME];
            [objInfo setObject:go.groupPassword forKey:kMUC_ROOM_PASSWORD];
            
            ChatBox *cb = [[AppFacade share] getChatBox:go.groupId];
            if (cb && [cb.updateTS doubleValue] > 0) {
                [objInfo setObject:[NSString stringWithFormat:@"%@", cb.updateTS] forKey:kMUC_HISTORY];
            }
            
            NSLog(@"re-join info: %@", objInfo);
            [[XMPPFacade share] joinToChatRoom:objInfo];
        }
    }
    
    return joinedArrayRoomJID;
}

- (NSMutableArray *)getAllOwnerGroup
{
    NSArray *arrAllGroupObject = [[DAOAdapter share] getAllObject:[GroupObj class]];
    NSMutableArray *joinedArrayRoomJID = [NSMutableArray new];
    
    for (GroupObj *groupObject in arrAllGroupObject) {
        if ([[ChatFacade share] isAdmin:groupObject.groupId])
            [joinedArrayRoomJID addObject:groupObject];
    }

    return joinedArrayRoomJID;
}

- (void)updateForLeaveGroupChat:(NSString *)groupJid
{
    NSLog(@"%s %@", __PRETTY_FUNCTION__, groupJid);
    //NSString *queryConditionGM = [NSString stringWithFormat:@"jid = '%@' AND groupId = '%@'", [[ContactFacade share] getJid:YES], groupJid];
    //GroupMember *tmpGM = (GroupMember *)[[DAOAdapter share] getObject:[GroupMember class] condition:queryConditionGM];
    GroupMember *tmpGM = [[AppFacade share] getGroupMember:groupJid userJID:[[ContactFacade share] getJid:YES]];
    
    // remove chatBox
    ChatBox* chatBox = [[AppFacade share] getChatBox:groupJid];
    if (chatBox) {
        if (tmpGM && ![tmpGM.memberState isEqualToNumber:[NSNumber numberWithInt:kGROUP_MEMBER_STATE_KICKED]]) {
            [[DAOAdapter share] deleteObject:tmpGM];
            chatBox.chatboxState = [NSNumber numberWithInt:kCHATBOX_STATE_NOTDISPLAY];
            // remove from GroupObj
            GroupObj* groupObj = [[AppFacade share] getGroupObj:groupJid];
            if (groupObj)
                [[DAOAdapter share] deleteObject:groupObj];
        }
        chatBox.updateTS = [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]];
        [[DAOAdapter share] commitObject:chatBox];
    }
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^(void){
        [[ChatFacade share] reloadChatBoxList];
    }];
}
 
- (void)didSuccessCreateChatRoom:(NSString *)roomJid
{
    // for admin, must save group to db first.
    NSDictionary *roomObj = [tempRoomCreating objectForKey:[[roomJid componentsSeparatedByString:@"@"] objectAtIndex:0]];
    
    NSString *queryCondition = [NSString stringWithFormat:@"groupId = '%@'", roomJid];
    GroupObj *tmp = (GroupObj *)[[DAOAdapter share] getObject:[GroupObj class] condition:queryCondition];
    
    if (!tmp) {
        GroupObj *group = [GroupObj new];
        group.groupId = roomJid;
        group.groupPassword = [roomObj objectForKey:kROOM_PASSWORD];
        group.groupName = [[NSString alloc] initWithData:[Base64Security decodeBase64String:[roomObj objectForKey:kROOMNAME]] encoding:NSUTF8StringEncoding];
        group.groupImageURL = [roomObj objectForKey:kROOM_IMAGE_URL];
        group.updateTS = [roomObj objectForKey:kROOM_TS];
        [[DAOAdapter share] commitObject:group];
    }
    
    NSString* memberList = roomObj[kMEMBER_JID_LIST];
    [groupCreateDelegate didSuccessCreateGroup:roomJid  memberList:memberList];
}

- (void)didSuccessJoinChatRoom:(NSString *)roomJid isRejoined:(BOOL) isRejoined;
{
    ChatBox *chatBox = [[AppFacade share] getChatBox:roomJid];
    if (chatBox) {
        chatBox.chatboxState = [NSNumber numberWithInt:kCHATBOX_STATE_DISPLAY];
        [[DAOAdapter share] commitObject:chatBox];
    }else{
        [[ChatFacade share] createChatBox:roomJid isMUC:YES];
        chatBox = [[AppFacade share] getChatBox:roomJid];
    }
    
    if(isRejoined){
        //TrungVN: just return, why need update contact delegate here?
        //[[ContactFacade share] callContactUpdateDelegate];
        return;
    }
    
    chatBox.isGroup = YES;
    NSDictionary *ext2 = @{@"joined":@"1"};
    chatBox.extend2 = [ChatAdapter generateJSON:ext2];
    [[DAOAdapter share] commitObject:chatBox];
    
    // don't call send notice for joined event if sender is group admin
    if ([[ChatFacade share] isAdmin:roomJid]) {
        NSLog(@"%s: I'm Admin!", __PRETTY_FUNCTION__);
        return;
    }
    // notice for joined to group
    NSArray *arrMembers = [self getMembersList:roomJid];
    NSString *strMembers = @"";
    for (GroupMember *gm in arrMembers) {
        if ([gm.jid isEqualToString:[[ContactFacade share] getJid:YES]])
            continue;
        if ([strMembers length] > 0) {
            strMembers = [strMembers stringByAppendingString:@","];
        }
        strMembers = [strMembers stringByAppendingString:gm.jid];
    }

    if ([[roomJid componentsSeparatedByString:@"@"] count] == 2) {
        NSDictionary *groupUpdateDic = @{kROOMJID:[[roomJid componentsSeparatedByString:@"@"] objectAtIndex:0],
                                         kIMEI: [[ContactFacade share] getIMEI],
                                         kIMSI: [[ContactFacade share] getIMSI],
                                         kTOKEN: [[ContactFacade share] getTokentTenant],
                                         kROOM_HOST: [[roomJid componentsSeparatedByString:@"@"] objectAtIndex:1],
                                         kMASKINGID: [[ContactFacade share] getMaskingId],
                                         kMESSAGETYPE: [kBODY_MT_NOTI_GRP_JOIN lowercaseString],
                                         kMEMBER_JID_LIST: strMembers,
                                         kOCCUPANTS: [[ContactFacade share] getJid:YES],
                                         kROOMNAME: [Base64Security generateBase64String:[[ChatFacade share] getGroupName:roomJid]],
                                         kROOMLOGOURL: [[ChatFacade share] getGroupLogoUrl:roomJid]
                                         };
        [self sendNoticeForGroupUpdate:groupUpdateDic];
        
        // sent to myself db
        NSDate *delayedDate = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@%@", kJOIN_FREFIX, [[roomJid componentsSeparatedByString:@"@"] objectAtIndex:0]]];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:[NSString stringWithFormat:@"%@%@", kJOIN_FREFIX, [[roomJid componentsSeparatedByString:@"@"] objectAtIndex:0]]];
        [[NSUserDefaults standardUserDefaults] synchronize];
        NSMutableDictionary *infoDic = [[NSMutableDictionary alloc] init];
        [infoDic setObject:roomJid forKey:kROOMJID];
        [infoDic setObject:[[ContactFacade share] getJid:YES] forKey:kOCCUPANTS];
        [infoDic setObject:delayedDate forKey:kROOM_NOTICE_DELAY_DATE];
        [self noticeGroupMemberJoin:infoDic];
    }
}

#pragma mark - Support Methods -
- (void) deleteStorage:(NSArray *)selectedChatBox
{
    for (ChatBox *chatBox in selectedChatBox)
    {
        NSMutableArray* arrayMedia = [[self getMediaMessage:chatBox.chatboxId
                                                      limit:MAXFLOAT] mutableCopy];
        for (Message *message in arrayMedia)
        {
            if(![[ChatFacade share] isMediaFileExisted:message.messageId])
                continue;
            
            [ChatAdapter deleteEncData:message.messageId];
            [ChatAdapter deleteRawData:message.messageId];
            message.messageStatus = MESSAGE_STATUS_CONTENT_DELETED;
            [[DAOAdapter share] commitObject:message];
        }
    }
    [manageStorageDelegate deleteStorageSuccees];
}

- (unsigned long long)getAmountOfMediaFileSize:(ChatBox*)chatBox
{
    NSMutableArray* arrayMedia = [[self getMediaMessage:chatBox.chatboxId
                                                  limit:MAXFLOAT] mutableCopy];
    unsigned long long totalBype = 0;
    for (Message* message in arrayMedia)
    {
        NSInteger messageType = [self messageType:message.messageType];
        if (messageType == MediaTypeImage || messageType == MediaTypeAudio || messageType == MediaTypeVideo)
            totalBype += message.mediaFileSize.integerValue;
    }
    return totalBype;
}

- (NSMutableArray*) getChatBoxHasMedia
{
    NSString* queryList = [NSString stringWithFormat:@"chatboxState = '%d'", kCHATBOX_STATE_DISPLAY];
    NSArray* arrChatBox = [[DAOAdapter share] getObjects:[ChatBox class] condition:queryList
                                                 orderBy:@"updateTS"
                                            isDescending:YES limit:MAXFLOAT];
    NSMutableArray *chatBoxHasMedia = [NSMutableArray new];
    for (ChatBox *chatBox in arrChatBox){
        if ([self countMediaMessageExisted:chatBox.chatboxId] > 0){
            [chatBoxHasMedia addObject:chatBox];
        }
    }
    return chatBoxHasMedia;
}

- (NSString *)getGroupName:(NSString *)groupId
{
    GroupObj *groupObj = [[AppFacade share] getGroupObj:groupId];
    if (groupObj) {
        if ([groupObj.groupName length]) {
            return groupObj.groupName;
        } else {
            return [[groupId componentsSeparatedByString:@"@"] objectAtIndex:0];
        }
    }
    return @"";
}

- (NSString *)getGroupPassword:(NSString *)groupId
{
    GroupObj *groupObj = [[AppFacade share] getGroupObj:groupId];
    if (groupObj && groupObj.groupPassword.length > 0) {
        return groupObj.groupPassword;
    }
    return @"";
}

- (NSArray *)getMembersList:(NSString *)groupId
{
    NSString *queryMembersList = [NSString stringWithFormat:@"groupId = '%@' AND (memberState = '2' OR memberState ='3')", groupId];
    NSArray *arr = [[DAOAdapter share] getObjects:[GroupMember class] condition:queryMembersList];
    return arr;
}

- (NSArray *)getMemberContactsList:(NSString *)groupId
{
    NSArray *arr = [self getMembersList:groupId];
    NSMutableArray *arrContact = [NSMutableArray new];
    
    for (GroupMember *gm in arr) {
        if (![gm.jid isEqualToString:[[ContactFacade share] getJid:YES]]) {
            Contact *contact = [[ContactFacade share] getContact:gm.jid];
            if (contact && ![arrContact containsObject:contact]) {
                [arrContact addObject:contact];
            }
        }
    }
    
    return arrContact;
}

- (NSString *)getGroupLogoUrl:(NSString *)groupId
{
    GroupObj *groupObj = [[AppFacade share] getGroupObj:groupId];
    if (groupObj && groupObj.groupImageURL.length > 0)
        return groupObj.groupImageURL;
    return @"";
}

- (UIImage *)updateGroupLogo:(NSString *)fullJID
{
    GroupObj* groupObj = [[AppFacade share] getGroupObj:fullJID];
    if (groupObj) {
        NSData* avatar = [[ContactAdapter share] getContactAvatar:fullJID];
        avatar  = [[AppFacade share] decryptDataLocally:avatar];
        if (avatar){
            return [UIImage imageWithData:avatar];
        }
    }
    return [UIImage imageNamed:IMG_CHAT_GROUP_EMPTY];
}

- (BOOL) isAdmin:(NSString*) chatBoxId{
    NSString *queryCondition = [NSString stringWithFormat:@"jid = '%@' AND groupId = '%@' AND memberRole = '%d'", [[ContactFacade share] getJid:YES], chatBoxId, kGROUP_MEMBER_ROLE_ADMIN];
    GroupMember *GM = (GroupMember *)[[DAOAdapter share] getObject:[GroupMember class] condition:queryCondition];
    return GM ? TRUE : FALSE;
}

- (BOOL) isKickedByOwner:(NSString*) chatBoxId{
    NSString *queryCondition = [NSString stringWithFormat:@"groupId = '%@' AND jid = '%@' AND memberState = '%d'", chatBoxId, [[ContactFacade share] getJid:YES], kGROUP_MEMBER_STATE_KICKED];
    GroupMember *GM = (GroupMember*)[[DAOAdapter share] getObject:[GroupMember class] condition:queryCondition];
    return GM ? TRUE : FALSE;
}

#pragma mark - For notice MUC events -
- (void)noticeGroupCreated:(NSDictionary *)infoObj
{
    NSLog(@"%s %@", __PRETTY_FUNCTION__, infoObj);
    [[NSOperationQueue mainQueue] addOperationWithBlock:^(void){
        ChatBox *chatBox = [[AppFacade share] getChatBox:[infoObj objectForKey:kROOMJID]];
        if (!chatBox) {
            [[ChatFacade share] createChatBox:[infoObj objectForKey:kROOMJID] isMUC:YES];
            chatBox = [[AppFacade share] getChatBox:[infoObj objectForKey:kROOMJID]];
        }
        chatBox.chatboxState = [NSNumber numberWithInt:[[infoObj objectForKey:kOCCUPANTS] isEqualToString:[[ContactFacade share] getJid:YES]] ? kCHATBOX_STATE_DISPLAY:kCHATBOX_STATE_NOTDISPLAY];
        
        NSString* JID = [infoObj objectForKey:kOCCUPANTS];
        
        //NSDictionary *ext2 = @{@"joined":@"1"};
        // marked joined for admin only in this notice case
        NSMutableDictionary *ext2 = [NSMutableDictionary new];
        if ([JID isEqualToString:[[ContactFacade share] getJid:YES]]) {
            [ext2 setObject:@"1" forKey:@"joined"];
        } else {
            [ext2 setObject:@"0" forKey:@"joined"];
        }
        
        chatBox.extend2 = [ChatAdapter generateJSON:ext2];
        [[DAOAdapter share] commitObject:chatBox];
        
        NSDate* delayedDate = [infoObj objectForKey:kROOM_NOTICE_DELAY_DATE];
        Message* message = [Message new];
        message.messageId = [ChatAdapter generateMessageId];
        message.chatboxId = [infoObj objectForKey:kROOMJID];
        message.messageContent = [NSString stringWithFormat:__MESSAGE_GROUP_HAS_CREATED,
                                  [[ContactFacade share] getContactName:JID]];
        message.senderJID = JID;
        message.messageType = MSG_TYPE_NOT_GRP_CREATE;
        message.messageStatus = MESSAGE_STATUS_SENT;
        message.sendTS = delayedDate ?
        [NSNumber numberWithInt:[delayedDate timeIntervalSince1970]] :
        [NSNumber numberWithInt:[[NSDate date] timeIntervalSince1970]];
        message.isEncrypted = FALSE;
        message.selfDestructDuration = 0;
        if ([[ContactFacade share] getContactName:JID].length > 0) {
            [[DAOAdapter share] commitObject:message];
            [chatViewDelegate addMessage:message.messageId];
        }

        [[ContactFacade share] callContactUpdateDelegate];
        
        if(![self isAdmin:message.chatboxId]){
            NSString *groupName = [[NSString alloc] initWithData:[Base64Security decodeBase64String:[infoObj objectForKey:kROOMNAME]] encoding:NSUTF8StringEncoding];
            [[NotificationFacade share] notifyMessageReceived:message groupName:groupName];
        }else{
            message.readTS = message.sendTS;
            [[DAOAdapter share] commitObject:message];
        }
    }];
}

- (void)noticeGroupMemberJoin:(NSDictionary *)infoObj
{
    NSLog(@"%s %@", __PRETTY_FUNCTION__, infoObj);
    [[NSOperationQueue mainQueue] addOperationWithBlock:^(void){
        NSDate* delayedDate = [infoObj objectForKey:kROOM_NOTICE_DELAY_DATE];
        NSString* JID = [infoObj objectForKey:kOCCUPANTS];
        
        // ignore the kicked member notice "he joined"
        GroupMember *gm = [[AppFacade share] getGroupMember:[infoObj objectForKey:kROOMJID] userJID:JID];
        if (!gm || [gm.memberState isEqualToNumber:[NSNumber numberWithInt:kGROUP_MEMBER_STATE_KICKED]]) {
            return;
        }
        
        Message* message = [Message new];
        message.messageId = [infoObj objectForKey:kTEXT_MESSAGE_ID] ? [infoObj objectForKey:kTEXT_MESSAGE_ID] : [ChatAdapter generateMessageId];
        message.chatboxId = [infoObj objectForKey:kROOMJID];
        message.messageContent = [NSString stringWithFormat:__MESSAGE_GROUP_JOIN,
                                  [[ContactFacade share] getContactName:JID]];
        message.senderJID = JID;
        message.messageType = MSG_TYPE_NOT_GRP_JOIN;
        message.messageStatus = MESSAGE_STATUS_SENT;
        message.sendTS = delayedDate ?
        [NSNumber numberWithInt:[delayedDate timeIntervalSince1970]] :
        [NSNumber numberWithInt:[[NSDate date] timeIntervalSince1970]];
        message.isEncrypted = FALSE;
        message.selfDestructDuration = 0;
        
        ChatBox *chatBox = [[AppFacade share] getChatBox:[infoObj objectForKey:kROOMJID]];
        if (!chatBox) {
            [[ChatFacade share] createChatBox:[infoObj objectForKey:kROOMJID] isMUC:YES];
            chatBox = [[AppFacade share] getChatBox:[infoObj objectForKey:kROOMJID]];
        }
        chatBox.updateTS = delayedDate ? [NSNumber numberWithInteger:[delayedDate timeIntervalSince1970]] : [NSNumber numberWithInteger:[[NSDate date] timeIntervalSince1970]];
        
        if ([JID isEqualToString:[[ContactFacade share] getJid:YES]]) {
            NSMutableDictionary *ext2 = [NSMutableDictionary new];
            [ext2 setObject:@"1" forKey:@"joined"];
            chatBox.extend2 = [ChatAdapter generateJSON:ext2];
        }
        [[DAOAdapter share] commitObject:chatBox];
        
        if ([[ContactFacade share] getContactName:JID].length > 0) {
            [[DAOAdapter share] commitObject:message];
            [chatViewDelegate addMessage:message.messageId];
        }
        
        [chatViewDelegate displayGroupStatus];
        [[ContactFacade share] callContactUpdateDelegate];
        [contactInfoDelegate buildView];
        [contactInfoDelegate enableTableMemberListInteraction:TRUE];
        if([self isAdmin:message.chatboxId] && [[ChatFacade share] isMineMessage:message]){
            message.readTS = message.sendTS;
            [[DAOAdapter share] commitObject:message];
        }
        else{
            NSString *groupName = [[NSString alloc] initWithData:[Base64Security decodeBase64String:[infoObj objectForKey:kROOMNAME]] encoding:NSUTF8StringEncoding];
            [[NotificationFacade share] notifyMessageReceived:message groupName:groupName];
        }
    }];
}

- (void)noticeGroupRenamed:(NSDictionary *)infoObj
{
    NSLog(@"%s %@", __PRETTY_FUNCTION__, infoObj);
    if ([[infoObj objectForKey:kROOMNAME] isEqual:[NSNull null]])
        return;// if no new group name, nothing to do.
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^(void){
        [self updateGroupChatInfo:infoObj];
        
        NSString *groupNewName = [[NSString alloc] initWithData:[Base64Security decodeBase64String:[infoObj objectForKey:kROOMNAME]] encoding:NSUTF8StringEncoding];
        NSDate* delayedDate = [infoObj objectForKey:kROOM_NOTICE_DELAY_DATE];
        NSString* JID = [infoObj objectForKey:kOCCUPANTS];
        Message* message = [Message new];
        message.messageId = [infoObj objectForKey:kTEXT_MESSAGE_ID] ? [infoObj objectForKey:kTEXT_MESSAGE_ID] : [ChatAdapter generateMessageId];
        message.chatboxId = [infoObj objectForKey:kROOMJID];
        message.messageContent = [NSString stringWithFormat:__MESSAGE_GROUP_NAME_HAS_UPDATED,
                                  [[ContactFacade share] getContactName:JID], groupNewName];
        message.senderJID = JID;
        message.messageType = MSG_TYPE_NOT_GRP_CHG_NAME;
        message.messageStatus = MESSAGE_STATUS_SENT;
        message.sendTS = delayedDate ?
        [NSNumber numberWithInt:[delayedDate timeIntervalSince1970]] :
        [NSNumber numberWithInt:[[NSDate date] timeIntervalSince1970]];
        message.isEncrypted = FALSE;
        message.selfDestructDuration = 0;
        if([[ChatFacade share] isMineMessage:message])
            message.readTS = [NSNumber numberWithInt:[[NSDate date] timeIntervalSince1970]];
        
        ChatBox *chatBox = [[AppFacade share] getChatBox:[infoObj objectForKey:kROOMJID]];
        if (!chatBox) {
            [[ChatFacade share] createChatBox:[infoObj objectForKey:kROOMJID] isMUC:YES];
            chatBox = [[AppFacade share] getChatBox:[infoObj objectForKey:kROOMJID]];
        }
        chatBox.updateTS = delayedDate ? [NSNumber numberWithInteger:[delayedDate timeIntervalSince1970]] : [NSNumber numberWithInteger:[[NSDate date] timeIntervalSince1970]];
        [[DAOAdapter share] commitObject:chatBox];
        
        [[DAOAdapter share] commitObject:message];
        [chatViewDelegate addMessage:message.messageId];
        
        [[ContactFacade share] callContactUpdateDelegate];
        if(![JID isEqual:[[ContactFacade share] getJid:YES]]){
            NSString *groupName = [[NSString alloc] initWithData:[Base64Security decodeBase64String:[infoObj objectForKey:kROOMNAME]] encoding:NSUTF8StringEncoding];
            [[NotificationFacade share] notifyMessageReceived:message groupName:groupName];
        }
    }];
}

- (void)noticeGroupLogo:(NSDictionary *)infoObj
{
    NSLog(@"%s %@", __PRETTY_FUNCTION__, infoObj);
    [ChatAdapter downloadMedia:[NSURL URLWithString:[infoObj objectForKey:kROOM_IMAGE_URL]]
                 downloadBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {}
                      callback:^(BOOL success, NSString *message, NSDictionary *response, NSError *error) {
                          NSData *imgData = [response objectForKey:kDATA];
                          [[ContactAdapter share] setContactAvatar:[infoObj objectForKey:kROOMJID]
                                                              data:[[AppFacade share] encryptDataLocally:imgData]];
                          [[ContactFacade share] callContactUpdateDelegate];}
     ];
    
    [self updateGroupChatInfo:infoObj];
    NSDate* delayedDate = [infoObj objectForKey:kROOM_NOTICE_DELAY_DATE];
    NSString* JID = [infoObj objectForKey:kOCCUPANTS];
    Message* message = [Message new];
    message.messageId = [infoObj objectForKey:kTEXT_MESSAGE_ID] ? [infoObj objectForKey:kTEXT_MESSAGE_ID] : [ChatAdapter generateMessageId];
    message.chatboxId = [infoObj objectForKey:kROOMJID];
    message.messageContent = [NSString stringWithFormat:__MESSAGE_GROUP_LOGO_HAS_UPDATED,
                              [[ContactFacade share] getContactName:JID]];
    message.senderJID = JID;
    message.messageType = MSG_TYPE_NOT_GRP_CHG_LOGO;
    message.messageStatus = MESSAGE_STATUS_SENT;
    message.sendTS = delayedDate ?
    [NSNumber numberWithInt:[delayedDate timeIntervalSince1970]] :
    [NSNumber numberWithInt:[[NSDate date] timeIntervalSince1970]];
    message.isEncrypted = FALSE;
    message.selfDestructDuration = 0;
    if([[ChatFacade share] isMineMessage:message])
        message.readTS = [NSNumber numberWithInt:[[NSDate date] timeIntervalSince1970]];
    ChatBox *chatBox = [[AppFacade share] getChatBox:[infoObj objectForKey:kROOMJID]];
    if (!chatBox) {
        [[ChatFacade share] createChatBox:[infoObj objectForKey:kROOMJID] isMUC:YES];
        chatBox = [[AppFacade share] getChatBox:[infoObj objectForKey:kROOMJID]];
    }
    chatBox.updateTS = delayedDate ? [NSNumber numberWithInteger:[delayedDate timeIntervalSince1970]] : [NSNumber numberWithInteger:[[NSDate date] timeIntervalSince1970]];
    [[DAOAdapter share] commitObject:chatBox];
    
    if(![JID isEqual:[[ContactFacade share] getJid:YES]]){
        NSString *groupName = [[NSString alloc] initWithData:[Base64Security decodeBase64String:[infoObj objectForKey:kROOMNAME]] encoding:NSUTF8StringEncoding];
        [[NotificationFacade share] notifyMessageReceived:message groupName:groupName];
    }
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^(void){
        [[DAOAdapter share] commitObject:message];
        [chatViewDelegate addMessage:message.messageId];
    }];
}

- (void)noticeGroupKickOut:(NSDictionary *)infoObj
{
    NSLog(@"%s %@", __PRETTY_FUNCTION__, infoObj);
    if ([[infoObj objectForKey:kOCCUPANTS] isEqualToString:[[ContactFacade share] getJid:YES]]) {
        // the admin has kick you, reset the Stream Management to disable all this group message at the moment
        //[[XMPPFacade share] resetStreamManagement];
        NSDictionary *leaveDic = @{kMUC_ROOM_JID: [infoObj objectForKey:kROOMJID],
                                   kXMPP_TO_JID: [[ContactFacade share] getJid:YES]};
        [[XMPPFacade share] leaveChatRoom:leaveDic];
    }
    
    GroupMember *gm = [[AppFacade share] getGroupMember:[infoObj objectForKey:kROOMJID]
                                                userJID:[infoObj objectForKey:kOCCUPANTS]];
    if (!gm) {
        gm = [GroupMember new];
        gm.groupId = [infoObj objectForKey:kROOMJID];
        gm.jid = [infoObj objectForKey:kOCCUPANTS];
        [[DAOAdapter share] commitObject:gm];
    }
    
    gm.memberState = [NSNumber numberWithInt:kGROUP_MEMBER_STATE_KICKED];
    [[DAOAdapter share] commitObject:gm];
    
    NSDate* delayedDate = [infoObj objectForKey:kROOM_NOTICE_DELAY_DATE];
    NSString* JID = [infoObj objectForKey:kOCCUPANTS];
    NSString* senderJID = [infoObj objectForKey:kSENDER_JID];
    
    Message* message = [Message new];
    message.messageId = [infoObj objectForKey:kTEXT_MESSAGE_ID] ? [infoObj objectForKey:kTEXT_MESSAGE_ID] : [ChatAdapter generateMessageId];
    message.chatboxId = [infoObj objectForKey:kROOMJID];
    message.messageContent = [NSString stringWithFormat:__MESSAGE_GROUP_KICK,
                              [[ContactFacade share] getContactName:senderJID],
                              [[ContactFacade share] getContactName:JID]];
    message.senderJID = JID;
    message.messageType = MSG_TYPE_NOT_GRP_KICK;
    message.messageStatus = MESSAGE_STATUS_SENT;
    message.sendTS = delayedDate ?
    [NSNumber numberWithInt:[delayedDate timeIntervalSince1970]] :
    [NSNumber numberWithInt:[[NSDate date] timeIntervalSince1970]];
    message.isEncrypted = FALSE;
    message.selfDestructDuration = 0;
    [[DAOAdapter share] commitObject:message];
    
    //update kicked TS;
    gm.extend1 = [ChatAdapter convertDateToString:message.sendTS format:FORMAT_DATE_DETAIL_ACCOUNT];
    [[DAOAdapter share] commitObject:gm];
    
    ChatBox *chatBox = [[AppFacade share] getChatBox:[infoObj objectForKey:kROOMJID]];
    if (!chatBox) {
        [[ChatFacade share] createChatBox:[infoObj objectForKey:kROOMJID] isMUC:YES];
        chatBox = [[AppFacade share] getChatBox:[infoObj objectForKey:kROOMJID]];
    }
    chatBox.updateTS = message.sendTS;
    [[DAOAdapter share] commitObject:chatBox];
    
    if(![self isAdmin:message.chatboxId]){
        NSString *groupName = [[NSString alloc] initWithData:[Base64Security decodeBase64String:[infoObj objectForKey:kROOMNAME]] encoding:NSUTF8StringEncoding];
        [[NotificationFacade share] notifyMessageReceived:message groupName:groupName];
    }
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [chatViewDelegate addMessage:message.messageId];
        [chatViewDelegate displayGroupStatus];
        [[ContactFacade share] callContactUpdateDelegate];
        [contactInfoDelegate buildView];
        [contactInfoDelegate enableTableMemberListInteraction:TRUE];
    }];
}

- (void)noticeGroupAddedMember:(NSDictionary *)infoObj
{
    NSLog(@"%s %@", __PRETTY_FUNCTION__, infoObj);
    if (![infoObj objectForKey:kOCCUPANTS] || [[infoObj objectForKey:kOCCUPANTS] isEqual:[NSNull null]])
        return;
    
    NSArray *newMembers = [[infoObj objectForKey:kOCCUPANTS] componentsSeparatedByString:@","];
    for (NSString* memberJID in newMembers) {
        NSLog(@"NEW OCCUPANT %@", memberJID);
        GroupMember *gm = [[AppFacade share] getGroupMember:[infoObj objectForKey:kROOMJID]
                                                    userJID:memberJID];
        
        if (!gm) {
            gm = [GroupMember new];
            gm.groupId = [infoObj objectForKey:kROOMJID];
            gm.jid = memberJID;
        }
        
        gm.memberState = [NSNumber numberWithInt:kGROUP_MEMBER_STATE_ACTIVE];
        gm.memberRole = [NSNumber numberWithInt:kGROUP_MEMBER_ROLE_MEMBER];
        
        if([infoObj objectForKey:kROOM_NOTICE_DELAY_DATE]){
            NSTimeInterval delayedTime = [[infoObj objectForKey:kROOM_NOTICE_DELAY_DATE] timeIntervalSince1970];
            NSNumber* delayedNumber = [NSNumber numberWithInt:delayedTime];
            gm.extend2 = [ChatAdapter convertDateToString:delayedNumber format:FORMAT_DATE_DETAIL_ACCOUNT];
            [[DAOAdapter share] commitObject:gm];
            
            ChatBox *chatBox = [[AppFacade share] getChatBox:[infoObj objectForKey:kROOMJID]];
            chatBox.updateTS = delayedNumber;
            [[DAOAdapter share] commitObject:chatBox];
        }
    }
    
    [self getChatRoom:[[[infoObj objectForKey:kROOMJID] componentsSeparatedByString:@"@"] objectAtIndex:0]
              forJoin:NO];
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [chatViewDelegate displayGroupStatus];
        [[ContactFacade share] callContactUpdateDelegate];
        [contactInfoDelegate buildView];
        [contactInfoDelegate enableTableMemberListInteraction:TRUE];
    }];
}

- (void)noticeGroupMemberLeaved:(NSDictionary *)infoObj
{
    NSLog(@"%s %@ \n Update for GroupMember, mark this member is LEAVED.", __PRETTY_FUNCTION__, infoObj);
    
    GroupMember *gm = (GroupMember *)[[DAOAdapter share] getObject:[GroupMember class] condition:[NSString stringWithFormat:@"groupId = '%@' AND jid = '%@'", [infoObj objectForKey:kROOMJID], [infoObj objectForKey:kOCCUPANTS]]];
    if (gm) {
        gm.memberState = [NSNumber numberWithInt:kGROUP_MEMBER_STATE_LEAVE];
        [[DAOAdapter share] commitObject:gm];
    }
    
    NSDate* delayedDate = [infoObj objectForKey:kROOM_NOTICE_DELAY_DATE];
    
    NSString* JID = [infoObj objectForKey:kOCCUPANTS];
    
    //if myself leave, do not need a message.
    if ([JID isEqualToString:[[ContactFacade share] getJid:YES]])
        return;
    
    Message* message = [Message new];
    message.messageId = [infoObj objectForKey:kTEXT_MESSAGE_ID] ? [infoObj objectForKey:kTEXT_MESSAGE_ID] : [ChatAdapter generateMessageId];
    message.chatboxId = [infoObj objectForKey:kROOMJID];
    message.messageContent = [NSString stringWithFormat:__MESSAGE_GROUP_LEFT,
                              [[ContactFacade share] getContactName:JID]];
    message.senderJID = JID;
    message.messageType = MSG_TYPE_NOT_GRP_LEFT;
    message.messageStatus = MESSAGE_STATUS_SENT;
    message.sendTS = delayedDate ?
    [NSNumber numberWithInt:[delayedDate timeIntervalSince1970]] :
    [NSNumber numberWithInt:[[NSDate date] timeIntervalSince1970]];
    
    message.isEncrypted = FALSE;
    message.selfDestructDuration = 0;
    [[DAOAdapter share] commitObject:message];
    
    ChatBox *chatBox = [[AppFacade share] getChatBox:[infoObj objectForKey:kROOMJID]];
    if (!chatBox) {
        [[ChatFacade share] createChatBox:[infoObj objectForKey:kROOMJID] isMUC:YES];
        chatBox = [[AppFacade share] getChatBox:[infoObj objectForKey:kROOMJID]];
    }
    chatBox.updateTS = delayedDate ? [NSNumber numberWithInteger:[delayedDate timeIntervalSince1970]] : [NSNumber numberWithInteger:[[NSDate date] timeIntervalSince1970]];
    [[DAOAdapter share] commitObject:chatBox];
    
    if(![JID isEqual:[[ContactFacade share] getJid:YES]]){
        NSString *groupName = [[NSString alloc] initWithData:[Base64Security decodeBase64String:[infoObj objectForKey:kROOMNAME]] encoding:NSUTF8StringEncoding];
        [[NotificationFacade share] notifyMessageReceived:message groupName:groupName];
    }
    else{
        message.readTS = message.sendTS;
        [[DAOAdapter share] commitObject:message];
    }
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^(void){
        [chatViewDelegate addMessage:message.messageId];
        [chatViewDelegate displayGroupStatus];
        [[ContactFacade share] callContactUpdateDelegate];
    }];
}

- (BOOL)receiveNotification:(NSDictionary*)messageNotification {
    NSLog(@"%s, %@",__PRETTY_FUNCTION__, messageNotification);
    NSDictionary* notiDic = [ChatAdapter decodeJSON:[messageNotification objectForKey:kTEXT_MESSAGE_BODY]];
    NSLog(@"%s, %@",__PRETTY_FUNCTION__, notiDic);
    
    NSDate* delayedDate = [messageNotification objectForKey:kTEXT_MESSAGE_DELAYED_DATE] ? [messageNotification objectForKey:kTEXT_MESSAGE_DELAYED_DATE] : [NSDate date];
    
    NSString *messageID = [messageNotification objectForKey:kTEXT_MESSAGE_ID];
    if (messageID) {
        Message *notiMess = [[AppFacade share] getMessage:messageID];
        if (notiMess) {
            return FALSE;//NOTICE MESSAGE IS SAME ID WILL BE DISCARDED
        }
    }
    
    NSString *mt = [[notiDic objectForKey:kXMPP_BODY_MESSAGE_TYPE] uppercaseString];
    GroupObj *group = [[AppFacade share] getGroupObj:[notiDic objectForKey:@"room_jid"]];
    
    NSMutableDictionary *infoDic = [[NSMutableDictionary alloc] init];
    if (messageID) {
        [infoDic setObject:messageID forKey:kTEXT_MESSAGE_ID];
    }
    
    if ([notiDic objectForKey:@"room_jid"]) {
        [infoDic setObject:[notiDic objectForKey:@"room_jid"] forKey:kROOMJID];
    }
    if ([notiDic objectForKey:@"jid"]) {
        [infoDic setObject:[notiDic objectForKey:@"jid"] forKey:kJID];
    }
    if ([notiDic objectForKey:@"occupants"]) {
        [infoDic setObject:[notiDic objectForKey:@"occupants"] forKey:kOCCUPANTS];
    }
    if ([notiDic objectForKey:@"sender_jid"]) {
        NSString *senderjid = [notiDic objectForKey:@"sender_jid"];
        if ([senderjid rangeOfString:@"@"].length == 0) {
            senderjid = [senderjid stringByAppendingFormat:@"@%@", [[ContactFacade share] getXmppHostName]];
        }
        [infoDic setObject:senderjid forKey:kSENDER_JID];
    }
    if ([notiDic objectForKey:@"room_name"]) {
        [infoDic setObject:[notiDic objectForKey:@"room_name"] forKey:kROOMNAME];
    } else {
        if (group) {
            [infoDic setObject:group.groupName forKey:kROOMNAME];
        } else {
            [infoDic setObject:@"" forKey:kROOMNAME];
        }
    }
    if ([notiDic objectForKey:@"room_logo_url"]) {
        [infoDic setObject:[notiDic objectForKey:@"room_logo_url"] forKey:kROOM_IMAGE_URL];
    } else {
        if (group) {
            [infoDic setObject:group.groupImageURL forKey:kROOM_IMAGE_URL];
        } else {
            [infoDic setObject:@"" forKey:kROOM_IMAGE_URL];
        }
    }
    [infoDic setObject:delayedDate forKey:kROOM_NOTICE_DELAY_DATE];
    
    /*
    NSDictionary *info = @{kROOMJID: [notiDic objectForKey:@"room_jid"] ? [notiDic objectForKey:@"room_jid"] : @"",
                           kJID: [notiDic objectForKey:@"jid"] ? [notiDic objectForKey:@"jid"] : @"",
                           kOCCUPANTS: [notiDic objectForKey:@"occupants"] ? [notiDic objectForKey:@"occupants"] : @"",
                           kROOMNAME: [notiDic objectForKey:@"room_name"] ? [notiDic objectForKey:@"room_name"] : [Base64Security generateBase64String:group.groupName],
                           kROOM_IMAGE_URL: [notiDic objectForKey:@"room_logo_url"] ? [notiDic objectForKey:@"room_logo_url"] : group.groupImageURL,
                           kROOM_NOTICE_DELAY_DATE: delayedDate
                           };
    */
    if ([mt isEqualToString:kBODY_MT_NOT_INV_MSISDN]) {
        [[ContactFacade share]resetMSISDNNumber];
        return TRUE;
    }
    
    if ([mt isEqualToString:kBODY_MT_NOT_EAC_CHANGED]){
        [[ContactFacade share] updateContactInfo:[notiDic objectForKey:@"jid"]];
        return TRUE;
    }
    
    if ([mt isEqualToString:kBODY_MT_NOT_EAC_RESET]){
        [[EmailFacade share] updateEmailOfContact:[notiDic objectForKey:@"jid"]];
        return TRUE;
    }
    
    if ([mt isEqualToString:kBODY_MT_NOT_INV_EMAIL_ACCOUNT]){
        [[EmailFacade share] showAlertResetEmailAccount];
        return TRUE;
    }
    
    if ([mt isEqualToString:kBODY_MT_NOTI_CHANGE_DISPLAY_NAME]) {
        [[ContactFacade share] updateContactInfo:[infoDic objectForKey:kJID]];
        return TRUE;
    }
    
    if ([mt isEqualToString:kBODY_MT_NOTI_CHANGE_AVATAR]) {
        [[ContactFacade share] updateContactInfo:[infoDic objectForKey:kJID]];
        return TRUE;
    }
    
    if ([mt isEqualToString:kBODY_MT_NOTI_GRP_CREATE]) {
        [self noticeGroupCreated:infoDic];
        return TRUE;
    }
    
    if ([mt isEqualToString:kBODY_MT_NOTI_GRP_JOIN]) {
        [self noticeGroupMemberJoin:infoDic];
        return TRUE;
    }
    
    if ([mt isEqualToString:kBODY_MT_NOTI_GRP_ADD]) {
        [self noticeGroupAddedMember:infoDic];
        return TRUE;
    }
    
    if ([mt isEqualToString:kBODY_MT_NOTI_GRP_KICK]) {
        [self noticeGroupKickOut:infoDic];
        return TRUE;
    }
    
    if ([mt isEqualToString:kBODY_MT_NOTI_GRP_LEFT]) {
        [self noticeGroupMemberLeaved:infoDic];
        return TRUE;
    }
    
    if ([mt isEqualToString:kBODY_MT_NOTI_GRP_CHG_LOGO]) {
        [self noticeGroupLogo:infoDic];
        return TRUE;
    }
    
    if ([mt isEqualToString:kBODY_MT_NOTI_GRP_CHG_NAME]) {
        [self noticeGroupRenamed:infoDic];
        return TRUE;
    }
    
    if ([mt isEqualToString:kBODY_MT_NOTI_DELETE_CONTACT]) {
        [[ContactFacade share] wasRemovedContactFromFriend:[infoDic objectForKey:kJID]];
        return TRUE;
    }
    
    if ([mt isEqualToString:[kBODY_MT_IDEN_XCHANGE_ADD uppercaseString]]) {
        NSMutableDictionary *addFriendDic = [NSMutableDictionary new];
        if ([notiDic objectForKey:@"jid"]) {
            [addFriendDic setObject:[notiDic objectForKey:@"jid"] forKey:kJID];
        }
        if ([notiDic objectForKey:kBODY_MESSAGE_CONTENT]) {
            [addFriendDic setObject:[notiDic objectForKey:kBODY_MESSAGE_CONTENT] forKey:kBODY_MESSAGE_CONTENT];
        }
        if (addFriendDic) {
            [[ContactFacade share] didReceiveFriendRequest:addFriendDic];
        }
    }
    
    if ([mt isEqualToString:[kBODY_MT_IDEN_XCHANGE_DENY uppercaseString]]) {
        /*
         {
         id = ef36024cb61d4466612210541a532d55;
         jid = "33c0e1e4963a0c0b4a03568e04daa7df1b8c345c@snim.mtouche-mobile.com";
         mt = "iden_xchange_denied";
         }
         */
        NSMutableDictionary *friendDic = [NSMutableDictionary new];
        if ([notiDic objectForKey:@"jid"]) {
            [friendDic setObject:[notiDic objectForKey:@"jid"] forKey:kJID];
        }
        
        if (friendDic) {
            [[ContactFacade share] didReceiveFriendDenied:friendDic];
        }
    }
    
    if ([mt isEqualToString:[kBODY_MT_IDEN_XCHANGE_APPROVE uppercaseString]]) {
        NSMutableDictionary *friendDic = [NSMutableDictionary new];
        if ([notiDic objectForKey:@"jid"]) {
            [friendDic setObject:[notiDic objectForKey:@"jid"] forKey:kJID];
        }
        
        if (friendDic) {
            [[ContactFacade share] didReceiveFriendApprove:friendDic];
        }
    }
    
    return TRUE;
}

#define KICK_PRESENCE @"307"
#define SERVER_MUC_SHUTDOWN_PRESENCE @"332"
#define LEAVE_PRESENCE @"110"

- (void)handleNoticeFromPresence:(NSDictionary *)presenceDic
{
    NSLog(@"handleNoticeFromPresence %@", presenceDic);
    if ([[presenceDic objectForKey:kPRESENCE_TYPE] isEqualToString:kPRESENCE_STATUS_TEXT_UNAVAILABLE]) {
        //this is kick or leave presence
        if ([[presenceDic objectForKey:kPRESENCE_STATUS] isEqualToString:KICK_PRESENCE]) {
            // kick presence
            if ([[presenceDic objectForKey:kMUC_OCCUPANT] isEqualToString:[presenceDic objectForKey:kXMPP_TO_JID]]) {
                // the admin has kick you
                NSLog(@"the admin (%@) has kick you", [presenceDic objectForKey:kMUC_ACTOR]);
                [[XMPPFacade share] leaveChatRoom:presenceDic];
                return;
            }
        }
        
        if ([[presenceDic objectForKey:kPRESENCE_STATUS] isEqualToString:SERVER_MUC_SHUTDOWN_PRESENCE]) {
            return;
        }
        
        if ([[presenceDic objectForKey:kPRESENCE_STATUS] isEqualToString:LEAVE_PRESENCE]) {
            if ([[presenceDic objectForKey:kMUC_OCCUPANT] isEqualToString:[presenceDic objectForKey:kXMPP_TO_JID]]) {
                NSLog(@"you just leaved");
                [self updateForLeaveGroupChat:[presenceDic objectForKey:kMUC_ROOM_JID]];
            }
            return;
        }
    }
}

- (void)sendNoticeForGroupUpdate:(NSDictionary *)groupDic
{
    // Maskingid, Imsi, Imei, Token, Roomjid, Roomhost, Roomname, Memberjidlist, Messagetype, Roomlogourl
    NSLog(@"%s %@", __PRETTY_FUNCTION__, groupDic);
    NSMutableDictionary *tmp = [groupDic mutableCopy];
    [tmp setObject:PUT forKey:kAPI_REQUEST_METHOD];
    [tmp setObject:NORMAL forKey:kAPI_REQUEST_KIND];
    [[ChatRoomAdapter share] sendNoticeGroup:tmp callback:^(BOOL success, NSString *message, NSDictionary *response, NSError *error) {
        NSLog(@"%s %@", __PRETTY_FUNCTION__, response);
        if (success) {
            NSString *mt = [[groupDic objectForKey:kMESSAGETYPE] uppercaseString];
            if ([mt isEqualToString:kBODY_MT_NOTI_GRP_CREATE]) {
                NSArray *members = [[groupDic objectForKey:kMEMBER_JID_LIST] componentsSeparatedByString:@","];
                for (NSString* toJID in members) {
                    if (toJID.length <= 0)
                        continue;
                    NSDictionary *msgObj = @{kMUC_ROOM_JID:[groupDic objectForKey:kROOMJID],
                                             kXMPP_TO_JID:toJID,
                                             kMUC_ROOM_PASSWORD: [groupDic objectForKey:kROOM_PASSWORD],
                                             kMUC_ROOM_INVITE_MESSAGE: @"Join me :)",
                                             kXMPP_MUC_HOST_NAME: [groupDic objectForKey:kROOM_HOST]
                                             };
                    
                    [[XMPPFacade share] addUserToChatRoom:msgObj];
                }
            }
        }
        // if Token is invalid or expire
        if ([response objectForKey:kSTATUS_CODE]){
            NSInvocationOperation* operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(sendNoticeForGroupUpdate:) object:groupDic];
            
            NSDictionary* retryDictionary = @{kRETRY_OPERATION:operation,
                                              kRETRY_TIME:kRETRY_API_COUNTER,
                                              kSTATUS_CODE : [response objectForKey:kSTATUS_CODE]};
            [[AppFacade share] downloadTokenAgain:retryDictionary];
        }
    }];
}

#pragma mark - Chat Handler -
- (NSUInteger)getNumberAllChatBoxUnreadMessage
{
    NSString* queryMessage = [NSString stringWithFormat:@"readTS IS NULL"];
    NSMutableArray* arrMessage = [[[DAOAdapter share] getObjects:[Message class] condition:queryMessage] mutableCopy];
    
    for (Message* message in [arrMessage mutableCopy]) {
        if(((ChatBox*)[[AppFacade share] getChatBox:message.chatboxId]).chatboxState == [NSNumber numberWithInt:kCHATBOX_STATE_NOTDISPLAY])
           [arrMessage removeObject:message];
    }
    
    return arrMessage.count;
}

-(BOOL) sendText:(NSString*) stringContent
       chatboxId:(NSString*) chatboxId{
    
    if(!stringContent || [stringContent isEqualToString:@""])
        return FALSE;
    if(!chatboxId || [chatboxId isEqualToString:@""])
        return FALSE;
    
    ChatBox* chatBox = [[AppFacade share] getChatBox:chatboxId];
    if(!chatBox)
        return FALSE;
    
    Message* message = [Message new];
    message.messageId = [ChatAdapter generateMessageId];
    message.chatboxId = chatboxId;
    message.messageContent = stringContent;
    message.senderJID = [[ContactFacade share] getJid:YES];
    message.messageType = MESSAGE_TYPE_TEXT;
    message.messageStatus = MESSAGE_STATUS_PENDING;
    message.sendTS = [NSNumber numberWithInteger:[[NSDate date] timeIntervalSince1970]];
    message.readTS = message.sendTS;
    message.isEncrypted = [chatBox.encSetting boolValue];
    message.selfDestructDuration = chatBox.destructTime? chatBox.destructTime : [NSNumber numberWithInt:0];
    [[DAOAdapter share] commitObject:message];
    
    chatBox.updateTS = message.sendTS;
    chatBox.chatboxState = [NSNumber numberWithInt:kCHATBOX_STATE_DISPLAY];
    [[DAOAdapter share] commitObject:chatBox];
    
    NSMutableDictionary* xmppDic = [NSMutableDictionary new];
    [xmppDic setObject:message.messageType forKey:kBODY_MESSAGE_TYPE];
    [xmppDic setObject:stringContent forKey:kBODY_MESSAGE_CONTENT];
    [xmppDic setObject:message.selfDestructDuration forKey:kBODY_MESSAGE_SELF_DESTROY];
    NSString* xmppBody = [ChatAdapter generateJSON:xmppDic];
    if (message.isEncrypted){
        xmppBody = [self encryptMessage:xmppBody chatboxId:chatboxId];
        message.messageContent = [Base64Security generateBase64String:[[AppFacade share] encryptDataLocally:[stringContent dataUsingEncoding:NSUTF8StringEncoding]]];
        if (message.messageContent.length > 0) {
            [[DAOAdapter share] commitObject:message];
        }
    }

    if(!xmppBody){
        NSLog(@"Cannot encrypt message");
        return FALSE;
    }
    
    NSString *messageType = (chatBox.isGroup) ? kXMPP_MESSAGE_STREAM_TYPE_MUC : kXMPP_MESSAGE_STREAM_TYPE_SINGLE;
    NSDictionary *msgObj = @{kSEND_TEXT_MESSAGE_VALUE: xmppBody,
                             kSEND_TEXT_TARGET_JID: chatboxId,
                             kSEND_TEXT_MESSAGE_ID: message.messageId,
                             kXMPP_MESSAGE_STREAM_TYPE: messageType
                             };
    [[XMPPFacade share] sendTextMessage:msgObj];
    
    if (!chatBox.isAlwaysDestruct) {
        chatBox.destructTime = [NSNumber numberWithInt:0];
        [[DAOAdapter share] commitObject:chatBox];
    }
    
    [chatViewDelegate addMessage:message.messageId];
    
    return TRUE;
}

-(BOOL) sendAudio:(NSString*) sourcePath
        chatboxId:(NSString*) chatboxId{
    if(sourcePath.length == 0)
        return FALSE;
    if(chatboxId.length == 0)
        return FALSE;
    
    NSData* rawContent = [[NSFileManager defaultManager] contentsAtPath:sourcePath];
    if(rawContent.length > AUDIO_SIZE_LIMIT_BYTE) {
        // This audio's size is larger than 2 MB
        [chatViewDelegate sendBigMediaFileFailed:AUDIO_SIZE_LIMIT];
        return FALSE;
    }

    ChatBox* chatBox = [[AppFacade share] getChatBox:chatboxId];
    if(!chatBox)
        return FALSE;
    
    [[LogFacade share] createEventWithCategory:Conversation_Category
                                           action:sendAudio_Action
                                            label:send_Label];
    
    NSString* messageId = [ChatAdapter generateMessageId];
    
    Message* message = [Message new];
    message.messageId = messageId;
    message.chatboxId = chatboxId;
    message.messageContent = messageId;
    message.senderJID = [[ContactFacade share] getJid:YES];
    message.messageType = [MESSAGE_TYPE_AUDIO uppercaseString];
    message.messageStatus = MESSAGE_STATUS_PENDING;
    //message.mediaLocalURL = filePath; // this is currently not using.
    message.sendTS = [NSNumber numberWithInteger:[[NSDate date] timeIntervalSince1970]];
    message.readTS = message.sendTS;
    message.isEncrypted = [chatBox.encSetting boolValue];
    message.selfDestructDuration = chatBox.destructTime;
    
    [[DAOAdapter share] commitObject:message];
    [chatViewDelegate addMessage:message.messageId];
    
    chatBox.updateTS = message.sendTS;
    chatBox.chatboxState = [NSNumber numberWithInt:kCHATBOX_STATE_DISPLAY];
    [[DAOAdapter share] commitObject:chatBox];
    
    //uploading things.
    NSData* sendingOutData = rawContent;
    if(message.isEncrypted){
        NSData* key = [AESSecurity randomDataOfLength:32];
        NSData* encContent = [AESSecurity encryptAES256WithKey:key
                                                          Data:rawContent];
        
        sendingOutData = encContent;
        
        //store the key so after upload will send it inside xmpp.
        message.extend2 = [[ChatFacade share] encryptKeyAES:key chatboxId:chatboxId];
        [[DAOAdapter share] commitObject:message];
    }
    
    NSData* dataLocally = [[AppFacade share] encryptDataLocally:rawContent];
    [ChatAdapter cacheAudioData:messageId
                        rawData:dataLocally];
    
    NSInteger uploadType = [[AppFacade share] getChatBox:chatboxId].isGroup ? kUPLOAD_TYPE_USER_TO_MUC : kUPLOAD_TYPE_USER_TO_USER;
    
    [[ChatFacade share] uploadMediaFile:sendingOutData
                              messageId:messageId
                              targetJID:message.chatboxId
                             uploadType:uploadType];
    return TRUE;
}

-(BOOL) sendImage:(UIImage*) image
        chatboxId:(NSString*) chatboxId{
    if(!image || image.size.width == 0)
        return FALSE;
    if(chatboxId.length == 0)
        return FALSE;
    
    ChatBox* chatBox = [[AppFacade share] getChatBox:chatboxId];
    if(!chatBox)
        return FALSE;
    
    NSData* rawContent = UIImageJPEGRepresentation(image, 0.7);
    if (rawContent.length > 512000)
        rawContent = [ChatAdapter scaleImage:image rate:2];
    
    if(rawContent.length > IMAGE_SIZE_LIMIT_BYTE) {
        //This image's size is larger than 2 MB
        [chatViewDelegate sendBigMediaFileFailed:IMAGE_SIZE_LIMIT];
        return FALSE;
    }
    
    [[LogFacade share] createEventWithCategory:Conversation_Category
                                        action:sendPhoto_Action
                                         label:send_Label];
    
    NSString* messageId = [ChatAdapter generateMessageId];
    
    Message* message = [Message new];
    message.messageId = messageId;
    message.chatboxId = chatboxId;
    message.messageContent = messageId;
    message.senderJID = [[ContactFacade share] getJid:YES];
    message.messageType = [MESSAGE_TYPE_IMAGE uppercaseString];
    message.messageStatus = MESSAGE_STATUS_PENDING;
    //message.mediaLocalURL = filePath;
    message.sendTS = [NSNumber numberWithInteger:[[NSDate date] timeIntervalSince1970]];
    message.readTS = message.sendTS;
    message.isEncrypted = [chatBox.encSetting boolValue];
    message.selfDestructDuration = chatBox.destructTime;
    message.extend1 = [Base64Security generateBase64String:[ChatAdapter scaleImage:image rate:20]];
    
    [[DAOAdapter share] commitObject:message];
    chatBox.updateTS = message.sendTS;
    chatBox.chatboxState = [NSNumber numberWithInt:kCHATBOX_STATE_DISPLAY];
    [[DAOAdapter share] commitObject:chatBox];
    
    //uploading things.
    NSData* sendingOutData = rawContent;
    if(message.isEncrypted){
        NSData* key = [AESSecurity randomDataOfLength:32];
        NSData* encContent = [AESSecurity encryptAES256WithKey:key
                                                          Data:rawContent];
        
        
        
        sendingOutData = encContent;
        
        //store the key so after upload will send it inside xmpp.
        message.extend2 = [[ChatFacade share] encryptKeyAES:key chatboxId:chatboxId];
        [[DAOAdapter share] commitObject:message];
    }
    
    NSData* dataLocally = [[AppFacade share] encryptDataLocally:rawContent];
    [ChatAdapter cacheImageData:messageId
                        rawData:dataLocally];
    
    [[NotificationFacade share] playSoundMessage:message];
    [chatViewDelegate addMessage:message.messageId];
    NSInteger uploadType = [[AppFacade share] getChatBox:chatboxId].isGroup ? kUPLOAD_TYPE_USER_TO_MUC : kUPLOAD_TYPE_USER_TO_USER;
    [[ChatFacade share] uploadMediaFile:sendingOutData
                              messageId:messageId
                              targetJID:message.chatboxId
                             uploadType:uploadType];

    return TRUE;
}

-(BOOL) sendVideo:(NSURL*) videoURL
        chatboxId:(NSString*) chatboxId{
    if (!videoURL || !chatboxId)
        return FALSE;
    
    ChatBox* chatBox = [[AppFacade share] getChatBox:chatboxId];
    if(!chatBox)
        return FALSE;
    
    [[LogFacade share] createEventWithCategory:Conversation_Category
                                           action:sendVideo_Action
                                            label:send_Label];
    
    //1. generate thumbnail data.
    //2. get full video data.
    //3. process.
    //4. delete the temp data after send success if message is encrypted
    
    NSString* messageId = [ChatAdapter generateMessageId];
    [windowDelegate showLoading:kLOADING_PROCESSING];
    
    [ChatAdapter generateVideoThumbnail:videoURL callback:^(BOOL success, NSData *thumbnailData) {
        if (!thumbnailData){
            [windowDelegate hideLoading];
            [[CAlertView new] showError:_ALERT_FAILED_SEND_VIDEO];
            return;
        }
        [ChatAdapter cacheThumbData:messageId rawData:[[AppFacade share] encryptDataLocally:thumbnailData]];
        [ChatAdapter generateVideoData:videoURL callback:^(BOOL success, NSData *videoData) {
            NSLog(@"Video message %@ length %f", messageId, videoData.length/1024.0/1024.0);
            if (videoData.length > VIDEO_SIZE_LIMIT_BYTE) {
                // This video's size is larger than 10 MB
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    [windowDelegate hideLoading];
                    [chatViewDelegate sendBigMediaFileFailed:VIDEO_SIZE_LIMIT];
                }];
                return;
            }
            NSData* dataLocally = [[AppFacade share] encryptDataLocally:videoData];
            if (dataLocally){
                NSString* filePath = [ChatAdapter cacheVideoData:messageId
                                                         rawData:dataLocally];
                Message* message = [Message new];
                message.messageId = messageId;
                message.chatboxId = chatboxId;
                message.messageContent = messageId;
                message.senderJID = [[ContactFacade share] getJid:YES];
                message.messageType = [MESSAGE_TYPE_VIDEO uppercaseString];
                message.messageStatus = MESSAGE_STATUS_PENDING;
                message.mediaLocalURL = filePath;
                message.sendTS = [NSNumber numberWithInteger:[[NSDate date] timeIntervalSince1970]];
                message.readTS = message.sendTS;
                message.isEncrypted = [chatBox.encSetting boolValue];
                message.selfDestructDuration = chatBox.destructTime;
                message.extend1 = [Base64Security generateBase64String:thumbnailData];
                
                [[DAOAdapter share] commitObject:message];
                
                chatBox.updateTS = message.sendTS;
                chatBox.chatboxState = [NSNumber numberWithInt:kCHATBOX_STATE_DISPLAY];
                [[DAOAdapter share] commitObject:chatBox];
                
                NSData* sendingOutData = videoData;
                if(message.isEncrypted){
                    NSData* key = [AESSecurity randomDataOfLength:32];
                    NSData* encContent = [AESSecurity encryptAES256WithKey:key
                                                                      Data:videoData];
                    
                    sendingOutData = encContent;
                    
                    //store the key so after upload will send it inside xmpp.
                    message.extend2 = [[ChatFacade share] encryptKeyAES:key chatboxId:chatboxId];
                    [[DAOAdapter share] commitObject:message];
                }
                
                NSInteger uploadType = [[AppFacade share] getChatBox:chatboxId].isGroup ? kUPLOAD_TYPE_USER_TO_MUC : kUPLOAD_TYPE_USER_TO_USER;
                
                [[ChatFacade share] uploadMediaFile:sendingOutData
                                          messageId:messageId
                                          targetJID:message.chatboxId
                                         uploadType:uploadType];
                
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    [chatViewDelegate addMessage:message.messageId];
                    [windowDelegate hideLoading];
                }];
            }
            else{
                [windowDelegate hideLoading];
                [[CAlertView new] showError:_ALERT_FAILED_SEND_VIDEO];
            }
        }];
    }];
    
    return TRUE;
}

-(NSData*) imageData:(NSString*) messageId{
    Message* message = [[AppFacade share] getMessage:messageId];
    if(!message)
        return nil;
    NSData* imageLocal = [ChatAdapter imageRawData:messageId];
    NSData* imageRaw = [[AppFacade share] decryptDataLocally:imageLocal];
    return imageRaw;
}

-(NSData*) audioData:(NSString*) messageId{
    Message* message = [[AppFacade share] getMessage:messageId];
    if(!message)
        return nil;
    NSData* audioLocal = [ChatAdapter audioRawData:messageId];
    NSData* audioRaw = [[AppFacade share] decryptDataLocally:audioLocal];
    return audioRaw;
}

-(NSData*) videoData:(NSString*) messageId{
    Message* message = [[AppFacade share] getMessage:messageId];
    if(!message)
        return nil;
    
    NSData* videoLocal = [ChatAdapter videoRawData:messageId];
    NSData* videoRaw = [[AppFacade share] decryptDataLocally:videoLocal];
    return videoRaw;
}

-(NSData*) thumbData:(NSString*) messageId{
    NSData* thumbData =  [ChatAdapter thumbRawData:messageId];
    return [[AppFacade share] decryptDataLocally:thumbData];
}

-(void) copyToClipboard:(NSString*) content{
    if (content.length > 0)
        [[UIPasteboard generalPasteboard] setString:content];
}

-(void) saveMediaToLibrary:(Message*) message{
    switch ([self messageType:message.messageType]) {
        case MediaTypeImage:{
            UIImage* savedImage = [UIImage imageWithData:[self imageData:message.messageId]];
            if (savedImage) {
                UIImageWriteToSavedPhotosAlbum(savedImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
            }
            else{
                [[CAlertView new] showError:ERROR_SAVE_IMAGE_FAIL];
            }
        }
            break;
        case MediaTypeVideo:{
            NSData* videoData = [[ChatFacade share] videoData:message.messageId];
            UISaveVideoAtPathToSavedPhotosAlbum([self createTempURL:videoData], self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
        }
            break;
        default:
            break;
    }
}

- (void) image: (UIImage *) image didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo{
    [chatViewDelegate enableSaveMediaButton:TRUE];
    [contactInfoDelegate enableSaveMediaButton:TRUE];
    
    if (!error)
        [[CAlertView new] showInfo:INFO_SAVE_IMAGE_SUCCESSFUL];
    else
        [[CAlertView new] showError:ERROR_SAVE_IMAGE_FAIL];
}

- (void) video: (NSString *) videoPath didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo{
    [chatViewDelegate enableSaveMediaButton:TRUE];
    [contactInfoDelegate enableSaveMediaButton:TRUE];
    
    if (!error)
        [[CAlertView new] showInfo:INFO_SAVE_VIDEO_SUCCESSFUL];
    else
        [[CAlertView new] showError:ERROR_SAVE_VIDEO_FAIL];
    
    [self removeTempURLFile];
}

-(NSInteger) messageType:(NSString*) messageType{
    messageType = [messageType uppercaseString];
    if([messageType isEqual:MSG_TYPE_TEXT])
        return MediaTypeText;
    if([messageType isEqual:MSG_TYPE_IMAGE])
        return MediaTypeImage;
    if([messageType isEqual:MSG_TYPE_VIDEO])
        return MediaTypeVideo;
    if([messageType isEqual:MSG_TYPE_AUDIO])
        return MediaTypeAudio;
    if ([messageType isEqual:MSG_TYPE_SIP]) {
        return MediaTypeSIP;
    }
    
    if([messageType isEqual:MSG_TYPE_NOT_GRP_ADD] ||
       [messageType isEqual:MSG_TYPE_NOT_GRP_CHG_LOGO] ||
       [messageType isEqual:MSG_TYPE_NOT_GRP_CHG_NAME] ||
       [messageType isEqual:MSG_TYPE_NOT_GRP_KICK] ||
       [messageType isEqual:MSG_TYPE_NOT_GRP_LEFT] ||
       [messageType isEqual:MSG_TYPE_NOT_MESSAGE_DESTROY] ||
       [messageType isEqual:MSG_TYPE_NOT_GRP_CREATE] ||
       [messageType isEqual:MSG_TYPE_NOT_GRP_JOIN])
        return MediaTypeNotification;
    
    return -1000;
}

-(NSString*) getChatBoxLastMessage:(NSString*) chatboxId{
    Message* message = [[self getHistoryMessage:chatboxId limit:1] firstObject];
    
    switch ([self messageType:message.messageType]) {
        case MediaTypeSIP:{
            return message.messageContent;
        }
            break;
        case MediaTypeText:{
            if (message.isEncrypted) {
                NSData* data = [Base64Security decodeBase64String:message.messageContent];
                data = [[AppFacade share] decryptDataLocally:data];
                return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            }
            else{
                return message.messageContent;
            }
        }
            break;
        case MediaTypeAudio:
            return __MESSAGE_AUDIO;
            break;
        case MediaTypeImage:
            return __MESSAGE_IMAGE;
            break;
        case MediaTypeVideo:
            return __MESSAGE_VIDEO;
            break;
        case MediaTypeNotification:
            return message.messageContent;
            break;
        default:
            return @"";
            break;
    }
}

-(NSString*) getChatBoxTimeStamp:(NSNumber*) timeNumber{
    NSString *chatTimeStampDate = [ChatAdapter convertDateToString:timeNumber format:FORMAT_DATE];
    NSString *today = [ChatAdapter convertDateToString:[[NSNumber alloc] initWithInteger:[NSDate date].timeIntervalSince1970] format:FORMAT_DATE];
    
    if([chatTimeStampDate isEqual:today]){
        return [ChatAdapter convertDateToString:timeNumber format:FORMAT_FULL_TIME];
    }
    
    return [ChatAdapter convertDateToString:timeNumber format:FORMAT_DATE_MMMDDYYYHMMA];
}

-(NSString*) getChatBoxUnreadCount:(NSString*) chatboxId{
    NSString* queryMessage = [NSString stringWithFormat:@"chatboxId = '%@' AND readTS IS NULL", chatboxId];
    NSArray* arrMessage = [[DAOAdapter share] getObjects:[Message class] condition:queryMessage];
    
    if (!arrMessage.count > 0)
        return nil;
    if (arrMessage.count > 9)
        return @"9+";
    return [NSString stringWithFormat:@"%lu", (unsigned long)arrMessage.count];
}

-(BOOL) removeAllChatBoxMessage:(NSString*) chatboxId{
    NSString* queryMessage = [NSString stringWithFormat:@"chatboxId = '%@'", chatboxId];
    NSArray* arrMessage = [[DAOAdapter share] getObjects:[Message class] condition:queryMessage];
    
    BOOL result = TRUE;
    for (Message* message in arrMessage) {
        result = [[DAOAdapter share] deleteObject:message];
    }
    if (result) {
        ChatBox* chatBox = [[AppFacade share] getChatBox:chatboxId];
        if(!chatBox.isGroup){
            chatBox.chatboxState = [NSNumber numberWithInt:kCHATBOX_STATE_NOTDISPLAY];
        }
        
        [windowDelegate showLoading:kLOADING_DELETING];
        [[DAOAdapter share] commitObject:chatBox];
        [chatViewDelegate resetContent];
        [contactInfoDelegate buildView];
        [self reloadChatBoxList];
        [sideBarDelegate reloadNotificationCount:[self getNumberAllChatBoxUnreadMessage] MenuID:SideBarChatIndex];
        [windowDelegate hideLoading];
    }
    return result;
}

-(void) receiveMessageStatus:(NSDictionary *)messageStatus{
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        NSString* messageId = [messageStatus objectForKey:kTEXT_MESSAGE_ID];
        Message* message = [[AppFacade share] getMessage:messageId];
        if(!message)
            return;
        
        if([[messageStatus objectForKey:kMESSAGE_STATUS] intValue] == [kMESSAGE_STATUS_RECEIVED intValue])
            message.messageStatus = MESSAGE_STATUS_DELIVERED;
        if([[messageStatus objectForKey:kMESSAGE_STATUS] intValue] == [kMESSAGE_STATUS_SENT intValue])
            message.messageStatus = MESSAGE_STATUS_SENT;
        [[DAOAdapter share] commitObject:message];
        
        dispatch_async(dispatch_get_main_queue(), ^(void){
            [chatViewDelegate updateStatus:messageId];
        });
    });
}

//this heavy method will use async to process messages coming.
-(void) receiveMessage:(NSDictionary*) messageContent{
    if ([[AppFacade share] getMessage:[messageContent objectForKey:kTEXT_MESSAGE_ID]]) {
        NSLog(@"MESSAGE IS SAME ID WILL BE DISCARDED");
        return;
    }

    NSString *messType = [messageContent objectForKey:kTEXT_MESSAGE_TYPE];
    NSString* xmppBody = [messageContent objectForKey:kTEXT_MESSAGE_BODY];
    NSString* chatboxId = [messType isEqualToString:@"chat"] ? [messageContent objectForKey:kTEXT_MESSAGE_FROM] : [messageContent objectForKey:kMUC_ROOM_JID];
    NSDate* delayedDate = [messageContent objectForKey:kTEXT_MESSAGE_DELAYED_DATE];
    NSString* keyVersion = @"";
    if ([xmppBody componentsSeparatedByString:kINFO_SEPARATOR].count > 1) {
        keyVersion = [[xmppBody componentsSeparatedByString:kINFO_SEPARATOR] objectAtIndex:1];
    }
    
    BOOL isEncMessage = [self isEncryptMessage:xmppBody];
    if (isEncMessage){
        xmppBody = [self decryptMessage:xmppBody chatBoxId:chatboxId];
    }
    if([Base64Security isValidBase64:xmppBody]){
        NSData* xmppData = [Base64Security decodeBase64String:xmppBody];
        if (xmppData.length > 0)
            xmppBody = [[NSString alloc] initWithData:xmppData encoding:NSUTF8StringEncoding];
    }
    
    if (!xmppBody){
        NSLog(@"SOMETHING WRONG WITH DECRYPTED\n%@", [messageContent objectForKey:kTEXT_MESSAGE_BODY]);
        return;
    }
    
    //message belong to sip
    if ([[SIPFacade share] isIncommingCallReceived:xmppBody]) {
        return;
    }
    
    NSDictionary* xmppDic = [ChatAdapter decodeJSON:xmppBody];
    ChatBox* chatBox = [[AppFacade share] getChatBox:chatboxId];
    if (!chatBox){
        [self createChatBox:chatboxId isMUC:(![messType isEqualToString:@"chat"])];
        chatBox = [[AppFacade share] getChatBox:chatboxId];
    }
    
    //check if contact blocked return.
    if ([[ContactFacade share] isBlocked:chatboxId])
        return;
    //check if not friend return.
    if(![[ContactFacade share] isFriend:chatboxId] && !chatBox.isGroup)
        return;
    
    //check if group and was not active return.
    GroupMember *gm = [[AppFacade share] getGroupMember:chatBox.chatboxId
                                                userJID:[[ContactFacade share] getJid:YES]];
    if (gm) {
        NSTimeInterval kickTime = [[ChatAdapter convertDate:gm.extend1
                                                     format:FORMAT_DATE_DETAIL_ACCOUNT] doubleValue];
        NSTimeInterval addTime = [[ChatAdapter convertDate:gm.extend2
                                                    format:FORMAT_DATE_DETAIL_ACCOUNT] doubleValue];
        
        NSLog(@"kicked %@", gm.extend1);
        NSLog(@"added %@", gm.extend2);
        
        if(kickTime > 0 && kickTime > addTime){
            NSTimeInterval delayed = [delayedDate timeIntervalSince1970];
            if (delayed > kickTime)
                return;
            if(!delayed && [[NSDate date] timeIntervalSince1970] > kickTime)
                return;
        }
    }
    
    Message* message = [Message new];
    message.messageId = [messageContent objectForKey:kTEXT_MESSAGE_ID];
    message.chatboxId = chatboxId;
    message.messageContent = [xmppDic objectForKey:kBODY_MESSAGE_CONTENT];
    message.senderJID = [messageContent objectForKey:kTEXT_MESSAGE_FROM];
    message.messageType = [[xmppDic objectForKey:kBODY_MESSAGE_TYPE] uppercaseString];
    message.mediaServerURL = [xmppDic objectForKey:kBODY_MESSAGE_DOWNLOAD_URL];
    message.mediaFileSize = [xmppDic objectForKey:kBODY_MESSAGE_FILESIZE];
    message.extend1 = [xmppDic objectForKey:kBODY_MESSAGE_THUMBNAIL]; //thumbnail.
    message.extend2 = [xmppDic objectForKey:kBODY_MESSAGE_AES_KEY]; //keyaes
    message.sendTS = delayedDate ?
    [NSNumber numberWithInt:[delayedDate timeIntervalSince1970]] :
    [NSNumber numberWithInt:[[NSDate date] timeIntervalSince1970]];
    message.isEncrypted = isEncMessage;
    message.selfDestructDuration = [NSNumber numberWithInteger:[[xmppDic objectForKey:kBODY_MESSAGE_SELF_DESTROY] integerValue]];
    if ([[ChatFacade share] isMineMessage:message]) {
        message.messageStatus = MESSAGE_STATUS_SENT;
    }
    if (keyVersion.length > 0) {
        message.keyVersion = keyVersion;
    }
    [[DAOAdapter share] commitObject:message];
    
    //chatBox.updateTS = message.sendTS;// [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]];
    if (chatBox.updateTS < message.sendTS)
        chatBox.updateTS = message.sendTS;// because maybe older messages (in offline messages) come later
    
    chatBox.chatboxState = [NSNumber numberWithInt:kCHATBOX_STATE_DISPLAY];
    [[DAOAdapter share] commitObject:chatBox];
    
    if (message.isEncrypted && [self messageType:message.messageType] == MediaTypeText) {
        message.messageContent = [Base64Security generateBase64String:[[AppFacade share] encryptDataLocally:[message.messageContent dataUsingEncoding:NSUTF8StringEncoding]]];
        if (message.messageContent.length > 0) {
            [[DAOAdapter share] commitObject:message];
        }
    }

    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [chatViewDelegate addMessage:message.messageId];
        [self reloadChatBoxList];
        [[NotificationFacade share] notifyMessageReceived:message groupName:nil];
    }];
}

#define JPG @"jpg"
#define M4A @"m4a"
#define MP4 @"mp4"
#define ENC @"enc"
-(void) uploadMediaFile:(NSData*) fileData
              messageId:(NSString*) messageId
              targetJID:(NSString*) fullJID
             uploadType:(NSInteger) uploadType{
    NSLog(@"%s %ld %@ %@ %ld", __PRETTY_FUNCTION__, (unsigned long)fileData.length, messageId, fullJID, (long)uploadType);
    if (!fileData || !fullJID || !uploadType)
        return;
    NSArray* arrTargetJID = [fullJID componentsSeparatedByString:@"@"];
    if (arrTargetJID.count != 2 && uploadType == kUPLOAD_TYPE_USER_TO_USER)
        return;
    Message* messageObj = [[AppFacade share] getMessage:messageId];
    if (uploadType != kUPLOAD_TYPE_LOGO_MUC && !messageObj)
        return;
    
    NSString* fileExtension = JPG;
    switch ([self messageType:messageObj.messageType]) {
        case MediaTypeImage:
            fileExtension = JPG;
            break;
        case MediaTypeAudio:
            fileExtension = M4A;
            break;
        case MediaTypeVideo:
            fileExtension = MP4;
            break;
        default:
            break;
    }
    if (messageObj.isEncrypted)
        fileExtension = ENC;
    NSString* fileName = [messageObj.messageId stringByAppendingPathExtension:fileExtension];
    
    if (uploadType == kUPLOAD_TYPE_LOGO_MUC)
        fileName = [NSString stringWithFormat:@"%@.%@", [arrTargetJID objectAtIndex:0], fileExtension];
    
    NSMutableDictionary *uploadDic = [NSMutableDictionary new];
    __block NSData *fileDataBlock = fileData;
    switch (uploadType) {
        case kUPLOAD_TYPE_USER_TO_USER:
            [uploadDic setObject:POST forKey:kAPI_REQUEST_METHOD];
            [uploadDic setObject:UPLOAD forKey:kAPI_REQUEST_KIND];
            //[uploadDic setObject:[[ContactFacade share] getTokentCentral] forKey:kCENTRALTOKEN];
            [uploadDic setObject:[[ContactFacade share] getTokentCentral] forKey:kTOKEN];
            [uploadDic setObject:[[ContactFacade share] getJid:NO] forKey:kFROMJID];
            [uploadDic setObject:[[ContactFacade share] getXmppHostName] forKey:kFROMHOST];
            [uploadDic setObject:[arrTargetJID objectAtIndex:0] forKey:kTOJID];
            [uploadDic setObject:[arrTargetJID objectAtIndex:1] forKey:kTOHOST];
            [uploadDic setObject:[NSNumber numberWithInteger:uploadType] forKey:kUPLOAD_TYPE];
            [uploadDic setObject:fileExtension forKey:kUPLOAD_FILE];
            [uploadDic setObject:fileDataBlock forKey:kAPI_UPLOAD_FILEDATA];
            [uploadDic setObject:kFILE forKey:kAPI_UPLOAD_NAMEUPLOAD];
            [uploadDic setObject:fileExtension forKey:kAPI_UPLOAD_FILETYPE];
            [uploadDic setObject:fileName forKey:kAPI_UPLOAD_FILENAME];
            break;
        case kUPLOAD_TYPE_USER_TO_MUC:
            [uploadDic setObject:POST forKey:kAPI_REQUEST_METHOD];
            [uploadDic setObject:UPLOAD forKey:kAPI_REQUEST_KIND];
            [uploadDic setObject:[[ContactFacade share] getTokentCentral] forKey:kTOKEN];
            [uploadDic setObject:[[ContactFacade share] getJid:NO] forKey:kFROMJID];
            [uploadDic setObject:[[ContactFacade share] getXmppHostName] forKey:kFROMHOST];
            [uploadDic setObject:[NSNumber numberWithInteger:uploadType] forKey:kUPLOAD_TYPE];
            [uploadDic setObject:fileExtension forKey:kUPLOAD_FILE];
            
            [uploadDic setObject:fileDataBlock forKey:kAPI_UPLOAD_FILEDATA];
            [uploadDic setObject:kFILE forKey:kAPI_UPLOAD_NAMEUPLOAD];
            [uploadDic setObject:fileExtension forKey:kAPI_UPLOAD_FILETYPE];
            [uploadDic setObject:fileName forKey:kAPI_UPLOAD_FILENAME];
            [uploadDic setObject:[arrTargetJID objectAtIndex:0] forKey:kROOMID];
            break;
        case kUPLOAD_TYPE_LOGO_MUC:
            [uploadDic setObject:POST forKey:kAPI_REQUEST_METHOD];
            [uploadDic setObject:UPLOAD forKey:kAPI_REQUEST_KIND];
            [uploadDic setObject:[[ContactFacade share] getTokentCentral] forKey:kTOKEN];
            [uploadDic setObject:[[ContactFacade share] getJid:NO] forKey:kFROMJID];
            [uploadDic setObject:[[ContactFacade share] getXmppHostName] forKey:kFROMHOST];
            [uploadDic setObject:[NSNumber numberWithInteger:uploadType] forKey:kUPLOAD_TYPE];
            [uploadDic setObject:fileExtension forKey:kUPLOAD_FILE];
            
            [uploadDic setObject:fileDataBlock forKey:kAPI_UPLOAD_FILEDATA];
            [uploadDic setObject:kFILE forKey:kAPI_UPLOAD_NAMEUPLOAD];
            [uploadDic setObject:fileExtension forKey:kAPI_UPLOAD_FILETYPE];
            [uploadDic setObject:fileName forKey:kAPI_UPLOAD_FILENAME];
            [uploadDic setObject:[arrTargetJID objectAtIndex:0] forKey:kROOMID];
            break;
        default:
            break;
    }
    if (uploadDic.count == 0)
        return;
    
    if (messageObj) {
        messageObj.mediaFileSize = [NSNumber numberWithLongLong:fileData.length];
        messageObj.messageStatus = MESSAGE_STATUS_UPLOADING;
        [[DAOAdapter share] commitObject:messageObj];
        [chatViewDelegate updateStatus:messageObj.messageId];
    }
    
    [chatViewDelegate showCellLoading:messageObj.messageId
                             progress:0.0];
    
    id uploadBlock = ^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead){
        [chatViewDelegate showCellLoading:messageObj.messageId
                                 progress:((double)totalBytesRead/totalBytesExpectedToRead)];
    };
    
    id callback = ^(BOOL success, NSString *message, NSDictionary *response, NSError *error){
        [windowDelegate hideLoading];
        [chatViewDelegate hideCellLoading:messageId];
        [DeviceSecurity clearDeviceCache];
        
        NSDictionary* logDic = @{LOG_CLASS : NSStringFromClass(self.class),
                                 LOG_CATEGORY: CATEGORY_MUC_CHANGE_PHOTO,
                                 LOG_MESSAGE: [NSString stringWithFormat:@"MUC CHANGE PHOTO %@: ParaDic: %@, Response: %@",success ? @"SUCCESSED":@"FAILED", uploadDic,response],
                                 LOG_EXTRA1: @"",
                                 LOG_EXTRA2: @""};
        if (success) {
            
            switch (uploadType) {
                case kUPLOAD_TYPE_LOGO_MUC:
                {
                    [[ContactAdapter share] setContactAvatar:fullJID
                                                        data:[[AppFacade share] encryptDataLocally:fileData]];
                    NSDictionary *groupInfo = @{kROOMJID: fullJID,
                                                kROOM_IMAGE_URL: [[response objectForKey:kMEDIA] objectForKey:kDOWNLOAD_URL]};
                    [[ChatFacade share] updateGroupChatInfo:groupInfo];
                    // send notice to all members of group
                    
                    NSArray *arrMembers = [[ChatFacade share] getMembersList:[groupInfo objectForKey:kROOMJID]];
                    NSString *strMembers = @"";
                    for (GroupMember *gm in arrMembers) {
                        if ([strMembers length] > 0)
                            strMembers = [strMembers stringByAppendingString:@","];
                        strMembers = [strMembers stringByAppendingString:gm.jid];
                    }
                    NSDictionary *groupUpdateDic = @{kROOMJID:[[[groupInfo objectForKey:kROOMJID] componentsSeparatedByString:@"@"] objectAtIndex:0],
                                                     kIMEI: [[ContactFacade share] getIMEI],
                                                     kIMSI: [[ContactFacade share] getIMSI],
                                                     kTOKEN: [[ContactFacade share] getTokentTenant],
                                                     kROOM_HOST: [[[groupInfo objectForKey:kROOMJID] componentsSeparatedByString:@"@"] objectAtIndex:1],
                                                     kMASKINGID: [[ContactFacade share] getMaskingId],
                                                     kMESSAGETYPE: [kBODY_MT_NOTI_GRP_CHG_LOGO lowercaseString],
                                                     kMEMBER_JID_LIST: strMembers,
                                                     kOCCUPANTS: [[ContactFacade share] getJid:YES],
                                                     kROOMNAME: [Base64Security generateBase64String:[[ChatFacade share] getGroupName:[groupInfo objectForKey:kROOMJID]]],
                                                     kROOMLOGOURL: [groupInfo objectForKey:kROOM_IMAGE_URL]
                                                     };
                    [[ChatFacade share] sendNoticeForGroupUpdate:groupUpdateDic];
                }
                    break;
                    
                default:
                    [self processUploadSuccess:[response objectForKey:kMEDIA]
                                       message:messageObj];
                    [chatViewDelegate hideButtonRetry:messageObj.messageId];
                    break;
            }
            
            [[LogFacade share] logInfoWithDic:logDic];
        }
        else{
            [contactInfoDelegate updateRoomLogoFailed];
            if([self messageType:messageObj.messageType] == MediaTypeAudio)
                [chatViewDelegate updateCell:messageObj.messageId];
            [chatViewDelegate showButtonRetry:messageId];
            Message* message = [[AppFacade share] getMessage:messageId];
            if (message) {
                message.messageStatus = MESSAGE_STATUS_UPLOADED_FAILED;
                [[DAOAdapter share] commitObject:message];
                [chatViewDelegate updateStatus:messageId];
            }
            
            [[LogFacade share] logErrorWithDic:logDic];
        }
    };
    
    switch (uploadType) {
            /*
        case kUPLOAD_TYPE_USER_TO_USER:
            [ChatAdapter uploadMediaTenant:uploadDic
                               uploadBlock:uploadBlock
                                  callback:callback];
            break;
             */
        case kUPLOAD_TYPE_USER_TO_USER:
        case kUPLOAD_TYPE_USER_TO_MUC:
        case kUPLOAD_TYPE_LOGO_MUC:
            [ChatAdapter uploadMediaCentral:uploadDic
                                uploadBlock:uploadBlock
                                   callback:callback];
            break;
            
        default:
            break;
    }
    
    [self removeTempURLFile];
}

-(BOOL) processUploadSuccess:(NSDictionary*) responseDic
                     message:(Message*)message{
    if (!responseDic || !message)
        return FALSE;
    
    NSMutableDictionary* xmppDic = [NSMutableDictionary new];
    [xmppDic setObject:message.messageContent forKey:kBODY_MESSAGE_CONTENT];
    [xmppDic setObject:message.messageType forKey:kBODY_MESSAGE_TYPE];
    [xmppDic setObject:message.selfDestructDuration forKey:kBODY_MESSAGE_SELF_DESTROY];
    if (message.extend2.length > 0) //keyAES
        [xmppDic setObject:message.extend2 forKey:kBODY_MESSAGE_AES_KEY];
    if ([responseDic objectForKey:kDOWNLOAD_URL])
        [xmppDic setObject:[responseDic objectForKey:kDOWNLOAD_URL] forKey:kBODY_MESSAGE_DOWNLOAD_URL];
    if (message.extend1.length > 1) //thumbnail
        [xmppDic setObject:message.extend1 forKey:kBODY_MESSAGE_THUMBNAIL];
    if ([responseDic objectForKey:kFILENAME])
        [xmppDic setObject:[responseDic objectForKey:kFILENAME] forKey:kBODY_MESSAGE_FILENAME];
    if ([responseDic objectForKey:kFILESIZE])
        [xmppDic setObject:[responseDic objectForKey:kFILESIZE] forKey:kBODY_MESSAGE_FILESIZE];
    if ([responseDic objectForKey:kMIME_TYPE])
        [xmppDic setObject:[responseDic objectForKey:kMIME_TYPE] forKey:kBODY_MESSAGE_MIME_TYPE];
    
    NSString* xmppBody = [ChatAdapter generateJSON:xmppDic];
    if (message.isEncrypted){
        xmppBody = [self encryptMessage:xmppBody chatboxId:message.chatboxId];
    }
    if(!xmppBody){
        NSLog(@"Cannot encrypt message");
        return FALSE;
    }
    
    NSString *messageType = [[AppFacade share] getChatBox:message.chatboxId].isGroup ? kXMPP_MESSAGE_STREAM_TYPE_MUC : kXMPP_MESSAGE_STREAM_TYPE_SINGLE;
    
    NSDictionary *msgOBJ = [[NSDictionary alloc] initWithObjectsAndKeys:xmppBody, kSEND_TEXT_MESSAGE_VALUE, message.chatboxId, kSEND_TEXT_TARGET_JID, message.messageId, kSEND_TEXT_MESSAGE_ID, messageType, kXMPP_MESSAGE_STREAM_TYPE, nil];
    [[XMPPFacade share] sendTextMessage:msgOBJ];
    
    ChatBox* chatBox = [[AppFacade share] getChatBox:message.chatboxId];
    if (chatBox && !chatBox.isAlwaysDestruct) {
        chatBox.destructTime = [NSNumber numberWithInt:0];
        [[DAOAdapter share] commitObject:chatBox];
    }
    
    /*after send success if message is encrypted, need to:
     3. remove send encrypt content.
     4. remove message.extend2
     */
   
    if (message.isEncrypted) {
        message.extend2 = @"";
        [[DAOAdapter share] commitObject:message];
    }
    
    [chatViewDelegate updateCell:message.messageId];

    return TRUE;
}

-(void) downloadMediaMessage:(Message*) messageDO{
    if (!messageDO)
        return;
    NSURL* url = [NSURL URLWithString:messageDO.mediaServerURL];
    if (!url)
        return;
    
    [chatViewDelegate showCellLoading:messageDO.messageId
                             progress:0.0];
    
    id downloadBlock = ^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead){
        [chatViewDelegate showCellLoading:messageDO.messageId
                                 progress:((double)totalBytesRead/totalBytesExpectedToRead)];
    };
    
    [ChatAdapter downloadMedia:url downloadBlock:downloadBlock callback:^(BOOL success, NSString *message, NSDictionary *response, NSError *error){
        [chatViewDelegate hideCellLoading:messageDO.messageId];
        if (success){
            if ([self processDownloadData:[response objectForKey:kDATA] message:messageDO])
                [chatViewDelegate updateCell:messageDO.messageId];
            else{
                [[CAlertView new] showError:ERROR_RAWDATA_NOT_READY_ALERT_FAILED];
            }
        }
        else
            [[CAlertView new] showError:_ALERT_FAILED_DOWNLOAD];
    }];
}

-(BOOL) processDownloadData:(NSData*) data
                    message:(Message*)message{
    NSData* rawData = data;
   
    if (message.isEncrypted) {
        NSData* keyAES = [[ChatFacade share] decryptKeyAES:message.extend2
                                                 chatBoxId:message.chatboxId
                                                keyVersion:message.keyVersion];
        rawData = [AESSecurity decryptAES256WithKey:keyAES
                                               Data:rawData];
    }
    NSData* dataLocally = [[AppFacade share] encryptDataLocally:rawData];
    if (!dataLocally)
        return FALSE;
    
    switch ([self messageType:message.messageType]) {
        case MediaTypeAudio:
            [ChatAdapter cacheAudioData:message.messageId
                                rawData:dataLocally];
            break;
        case MediaTypeImage:
            [ChatAdapter cacheImageData:message.messageId
                                rawData:dataLocally];
            break;
        case MediaTypeVideo:{
            NSString* rawVideoLink = [ChatAdapter cacheVideoData:message.messageId
                                                         rawData:rawData];
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            rawVideoLink = [[paths objectAtIndex:0] stringByAppendingPathComponent:rawVideoLink];
            NSURL* videoURL = [NSURL fileURLWithPath:rawVideoLink];
            
            [ChatAdapter generateVideoThumbnail:videoURL callback:^(BOOL success, NSData *thumbnailData) {
                if (thumbnailData) {
                    [ChatAdapter cacheThumbData:message.messageId
                                        rawData:[[AppFacade share] encryptDataLocally:thumbnailData]];
                    [ChatAdapter cacheVideoData:message.messageId
                                        rawData:dataLocally];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [chatViewDelegate updateCell:message.messageId];
                    });
                }
                else{
                    [[CAlertView new] showError:_ALERT_FAILED_CREATE_THUMBNAIL];
                }
            }];
        }
            
            break;
        default:
            break;
    }
    
    if (message.isEncrypted) {
        message.extend2 = @"";
        [[DAOAdapter share] commitObject:message];
    }
    
    return TRUE;
}

- (NSString*) getCaptionOfMediaMessage:(Message*) messageDO{
    NSString* senderName;
    if ([messageDO.senderJID isEqual:[KeyChainSecurity getStringFromKey:kJID]])
        senderName = _YOU;
    else
        senderName = [[ContactFacade share] getContactName:messageDO.senderJID];
    
    NSString* date = [ChatAdapter convertDateToString:messageDO.sendTS format:FORMAT_DATE_MMMDDYYYHMMA];
    
    NSString* returnString = [NSString stringWithFormat:LABEL_PHOTOBROWSER, senderName, date];
    return returnString;
}

-(void) displayPhotoBrower:(Message*) messageDO
              showGridView:(BOOL)showGridView{
    NSMutableArray* arrayMedia = [[self getMediaMessage:messageDO.chatboxId limit:MAXFLOAT] mutableCopy];
    NSMutableArray* arrayPhoto = [NSMutableArray new];
    NSInteger index = 0;
    
    for (Message* message in arrayMedia) {
        switch ([self messageType:message.messageType]) {
            case MediaTypeImage:{
                UIImage* image = [UIImage imageWithData:[[ChatFacade share] imageData:message.messageId]];
                if (image){
                    MWPhoto* photo = [MWPhoto photoWithImage:image];
                    photo.caption = [self getCaptionOfMediaMessage:message];
                    NSMutableDictionary* contentDic = [NSMutableDictionary new];
                    [contentDic setObject:message.messageId forKey:kTEXT_MESSAGE_ID];
                    [contentDic setObject:photo forKey:kMEDIA];
                    [arrayPhoto addObject:contentDic];
                }
            }
                break;
            case MediaTypeAudio:{
                MWPhoto* photo = [MWPhoto photoWithImage:[UIImage imageNamed:IMG_CHAT_B_VOICE]];
                photo.caption = [self getCaptionOfMediaMessage:message];
                NSMutableDictionary* contentDic = [NSMutableDictionary new];
                [contentDic setObject:message.messageId forKey:kTEXT_MESSAGE_ID];
                [contentDic setObject:photo forKey:kMEDIA];
                [arrayPhoto addObject:contentDic];
            }
                
                break;
            case MediaTypeVideo:{
                UIImage* image = [UIImage imageWithData:[[ChatFacade share] thumbData:message.messageId]];
                if (image){
                    MWPhoto* photo = [MWPhoto photoWithImage:image];
                    photo.caption = [self getCaptionOfMediaMessage:message];
                    NSMutableDictionary* contentDic = [NSMutableDictionary new];
                    [contentDic setObject:message.messageId forKey:kTEXT_MESSAGE_ID];
                    [contentDic setObject:photo forKey:kMEDIA];
                    [arrayPhoto addObject:contentDic];
                }
            }
                break;
            default:
                break;
        }
        if ([messageDO.messageId isEqual:message.messageId])
            index = [arrayPhoto count] - 1;
    }
    
    [chatViewDelegate displayPhotoBrower:arrayPhoto
                              photoIndex:index
                            showGridView:showGridView];
    
    [contactInfoDelegate displayPhotoBrower:arrayPhoto
                                 photoIndex:index];
}

-(void) updateChatBoxDestroyTime:(NSString*) chatboxId
                isAlwaysDestruct:(BOOL) isAlwaysDestruct
                          second:(NSInteger) second{
    ChatBox* chatbox = [[AppFacade share] getChatBox:chatboxId];
    if (!chatbox)
        return;
    chatbox.destructTime = [NSNumber numberWithInteger:second];
    chatbox.isAlwaysDestruct = isAlwaysDestruct;
    [[DAOAdapter share] commitObject:chatbox];
}

-(void) startDestroyMessage:(NSString*) messageId{
    Message* message = [[AppFacade share] getMessage:messageId];
    if ([message.messageStatus isEqualToString:MESSAGE_STATUS_PENDING]
        || [message.messageStatus isEqualToString:MESSAGE_STATUS_UPLOADED_FAILED]
        || [message.messageStatus isEqualToString:MESSAGE_STATUS_UPLOADING])
        return;
    if (!message || ([message.selfDestructDuration integerValue] == 0))
        return;
    
    if (message.selfDestructTS){
        NSTimeInterval destroyTime = [message.selfDestructTS doubleValue];
        NSTimeInterval currentTime = [[NSDate date] timeIntervalSince1970];
        CGFloat interval = (destroyTime - currentTime) > 0 ? destroyTime - currentTime : 0;
        [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(destroyMessage:) userInfo:messageId repeats:NO];
        
    }
    else{
        message.selfDestructTS = [NSNumber numberWithDouble:([[NSDate date] timeIntervalSince1970] + [message.selfDestructDuration doubleValue])];
        
        [[DAOAdapter share] commitObject:message];
        [NSTimer scheduledTimerWithTimeInterval:[message.selfDestructDuration doubleValue]
                                         target:self selector:@selector(destroyMessage:)
                                       userInfo:messageId repeats:NO];
    }
    [chatViewDelegate updateState:messageId];
}

-(void) destroyMessage:(NSTimer*) timer{
    Message* message = [[AppFacade share] getMessage:[timer userInfo]];
    if (!message || [message.messageType isEqualToString:MSG_TYPE_NOT_MESSAGE_DESTROY])
        return;
    
    if([[ChatFacade share] messageType:message.messageType]  == MediaTypeAudio)
        [self stopCurrentAudioPlaying:message.messageId];
    
    message.messageContent = __MESSAGE_REMOVED;
    message.messageType = MSG_TYPE_NOT_MESSAGE_DESTROY;
    
    [ChatAdapter deleteEncData:message.messageId];
    [ChatAdapter deleteRawData:message.messageId];
    
    [[DAOAdapter share] commitObject:message];
    [chatViewDelegate updateCell:message.messageId];
    [self reloadChatBoxList];
}

-(void) reloadChatBoxList{
    NSString* queryList = [NSString stringWithFormat:@"chatboxState = '%d'", kCHATBOX_STATE_DISPLAY];
    NSArray* arrChatBox = [[DAOAdapter share] getObjects:[ChatBox class] condition:queryList orderBy:@"updateTS" isDescending:YES limit:MAXFLOAT];
    [chatListDelegate reloadChatList:arrChatBox];
}

-(NSUInteger) countChatBoxList{
    NSString* queryList = [NSString stringWithFormat:@"chatboxState = '%d'", kCHATBOX_STATE_DISPLAY];
    NSArray* arrChatBox = [[DAOAdapter share] getObjects:[ChatBox class] condition:queryList];
    return arrChatBox.count;
}

-(NSUInteger) countMediaMessageExisted:(NSString*) chatboxId{
    NSMutableArray* arrMediaMessages = [[self getMediaMessage:chatboxId limit:MAXFLOAT] mutableCopy];
    NSUInteger count = 0;
    for (Message* message in arrMediaMessages){
        if ([ChatAdapter isMediaFileExisted:message.messageId]) {
            count++;
        }
    }
    return count;
}

-(void) moveToChatView:(NSString*) chatBoxId{
    [chatListDelegate showChatView:chatBoxId];
}

-(BOOL) isEncryptMessage:(NSString*) xmppBody{
    return ([xmppBody rangeOfString:kENC_SIGNAL].location != NSNotFound);
}

- (NSString *)getFullTimeString:(NSNumber *)timestamp{
    return [ChatAdapter convertDateToString:timestamp format:FORMAT_DATE_MMMDDYYYHMMA];
}

-(NSArray*) getHistoryMessage:(NSString*) chatboxId
                        limit:(int)limit{
    NSString* queryCondition = [NSString stringWithFormat:@"chatboxId = '%@'", chatboxId];
    return [[DAOAdapter share] getObjects:[Message class]
                                condition:queryCondition
                                  orderBy:@"sendTS"
                             isDescending:YES
                                    limit:limit];
}

-(NSArray*) getMediaMessage:(NSString*) chatboxId limit:(int)limit{
    NSString* queryCondition = [NSString stringWithFormat:@"chatboxId = '%@' AND (messageStatus != '%@' OR messageStatus IS NULL) AND (messageType = '%@' OR messageType = '%@' OR messageType = '%@')", chatboxId, MESSAGE_STATUS_CONTENT_DELETED, MESSAGE_TYPE_IMAGE.uppercaseString, MESSAGE_TYPE_AUDIO.uppercaseString, MESSAGE_TYPE_VIDEO.uppercaseString];
    
    return [[DAOAdapter share] getObjects:[Message class]
                                condition:queryCondition
                                  orderBy:@"sendTS"
                             isDescending:FALSE
                                    limit:limit];
}

-(BOOL) updateMessageReadTS:(Message*) message{
    BOOL value = NO;
    if ([message.readTS doubleValue] == 0) {
        message.readTS = [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]];
        value = [[DAOAdapter share] commitObject:message];
        [sideBarDelegate updateChatRowUnreadNumber];
    }
    return value;
}

-(BOOL) isMineMessage:(Message*) message{
    return [message.senderJID isEqualToString:[[ContactFacade share] getJid:YES]];
}

-(BOOL) createChatBox:(NSString*) chatboxId isMUC:(BOOL)isMUC{
    if (!chatboxId)
        return FALSE;
    ChatBox* chatBox = [[AppFacade share] getChatBox:chatboxId];
    if (chatBox)
        return FALSE;
    chatBox = [ChatBox new];
    chatBox.chatboxId = chatboxId;
    chatBox.encSetting = [NSNumber numberWithBool:TRUE];
    chatBox.notificationSetting = [NSNumber numberWithBool:TRUE];
    chatBox.soundSetting = [NSNumber numberWithBool:TRUE];
    chatBox.destructTime = [NSNumber numberWithInt:0];
    chatBox.chatboxState = [NSNumber numberWithInt:isMUC ? kCHATBOX_STATE_DISPLAY: kCHATBOX_STATE_NOTDISPLAY];
    chatBox.updateTS = [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]];
    chatBox.isGroup = isMUC;
    return [[DAOAdapter share] commitObject:chatBox];
}

-(NSString*) encryptKeyAES:(NSData*) keyData
                 chatboxId:(NSString*) chatboxId{
    Key* key = [[AppFacade share] getKey:chatboxId];
    if ([[AppFacade share] getChatBox:chatboxId].isGroup) {
        key = [[AppFacade share] getLatestKeyForGroup:chatboxId];
    }
    if(!key || !key.keyJSON){
        NSLog(@"NO KEY 1 AVAILABLE");
        return nil;
    }
    
    if (key.keyJSON) {
        NSData* keyData = [Base64Security decodeBase64String:key.keyJSON];
        if (keyData)
            key.keyJSON = [[NSString alloc] initWithData:[[AppFacade share] decryptDataLocally:keyData]
                                                encoding:NSUTF8StringEncoding];
    }
    
    NSDictionary* dicKey = [ChatAdapter decodeJSON:key.keyJSON];
    if (!dicKey) {
        return nil;
    }
    
    if (key.keyJSON) {
        NSData* keyData = [Base64Security decodeBase64String:key.keyJSON];
        if (keyData)
            key.keyJSON = [[NSString alloc] initWithData:[[AppFacade share] decryptDataLocally:keyData]
                                                encoding:NSUTF8StringEncoding];
    }
    
    NSString* base64Key = nil;
    
    //single media.
    if (![[AppFacade share] getChatBox:chatboxId].isGroup){
        base64Key = [Base64Security generateBase64String:
                                [RSASecurity encryptRSA:keyData
                                           b64PublicExp:[dicKey objectForKey:kMOD1_EXPONENT]
                                             b64Modulus:[dicKey objectForKey:kMOD1_MODULUS]]];
    }
    //group media.
    else{
        NSString *keyStr = [[ChatAdapter decodeJSON:key.keyJSON] objectForKey:kMUC_KEY];
        NSData *keyMUC = [Base64Security decodeBase64String:keyStr];
        
        base64Key = [Base64Security generateBase64String:[AESSecurity encryptAES256WithKey:keyMUC
                                                                                      Data:keyData]];
    }

    return base64Key;
}

-(NSString*) encryptMessage:(NSString*) xmppContent
                  chatboxId:(NSString*) chatboxId{
    Key* key = [[AppFacade share] getKey:chatboxId];
    if ([[AppFacade share] getChatBox:chatboxId].isGroup) {
        key = [[AppFacade share] getLatestKeyForGroup:chatboxId];
    }
    if(!key || !key.keyJSON){
        NSLog(@"NO KEY 1 AVAILABLE");
        return nil;
    }
    if (key.keyJSON) {
        NSData* keyData = [Base64Security decodeBase64String:key.keyJSON];
        if (keyData)
            key.keyJSON = [[NSString alloc] initWithData:[[AppFacade share] decryptDataLocally:keyData]
                                                encoding:NSUTF8StringEncoding];
    }
    
    if (![[AppFacade share] getChatBox:chatboxId].isGroup) {
        NSData* contentData = [xmppContent dataUsingEncoding:NSUTF8StringEncoding];
        NSData* key32 = [AESSecurity randomDataOfLength:32];
        NSDictionary* dicKey = [ChatAdapter decodeJSON:key.keyJSON];
        
        //using key 1 here.
        NSString* base64Key = [Base64Security generateBase64String:
                               [RSASecurity encryptRSA:key32
                                          b64PublicExp:[dicKey objectForKey:kMOD1_EXPONENT]
                                            b64Modulus:[dicKey objectForKey:kMOD1_MODULUS]]];
        NSString* base64Content = [Base64Security generateBase64String:[AESSecurity encryptAES256WithKey:key32 Data:contentData]];
        
        NSString* strEncrypt = kENC_SIGNAL;
        strEncrypt = [strEncrypt stringByAppendingString:kMSG_SEPARATOR];
        strEncrypt = [strEncrypt stringByAppendingString:base64Key];
        strEncrypt = [strEncrypt stringByAppendingString:kAES_SEPARATOR];
        strEncrypt = [strEncrypt stringByAppendingString:base64Content];
        strEncrypt = [strEncrypt stringByAppendingString:kMSG_SEPARATOR];
        strEncrypt = [strEncrypt stringByAppendingString:[self encryptIdentity:xmppContent chatboxId:chatboxId]];
        strEncrypt = [strEncrypt stringByAppendingString:kINFO_SEPARATOR];
        if (key.keyVersion) {
            strEncrypt = [strEncrypt stringByAppendingString:key.keyVersion];
        } else {
            if ([dicKey objectForKey:kS_KEY_VERSION]) {
                strEncrypt = [strEncrypt stringByAppendingString:[dicKey objectForKey:kS_KEY_VERSION]];
            }
        }
        
        return strEncrypt;
    } else {
        NSData *contentData = [xmppContent dataUsingEncoding:NSUTF8StringEncoding];
        NSString *keyStr = [[ChatAdapter decodeJSON:key.keyJSON] objectForKey:kMUC_KEY];
        NSData *keyData = [Base64Security decodeBase64String:keyStr];
        NSString *key_version = key.keyVersion;
        //NSDictionary *keyDic = @{kMUC_KEY:mucKeyString}
        //using MUC key (AES) here.
        
        NSString *base64Content = [Base64Security generateBase64String:[AESSecurity encryptAES256WithKey:keyData Data:contentData]];
        NSString *strEncrypt = kENC_SIGNAL;
        strEncrypt = [strEncrypt stringByAppendingString:kMSG_SEPARATOR];
        strEncrypt = [strEncrypt stringByAppendingString:base64Content];
        strEncrypt = [strEncrypt stringByAppendingString:kMSG_SEPARATOR];
        strEncrypt = [strEncrypt stringByAppendingString:kINFO_SEPARATOR];
        strEncrypt = [strEncrypt stringByAppendingString:key_version];
        
        return strEncrypt;
    }
    
    return nil;
}

-(NSString*) encryptIdentity:(NSString*) xmppContent
                   chatboxId:(NSString*) chatboxId{
    Key* key = [[AppFacade share] getKey:chatboxId];
    if(!key || !key.keyJSON){
        NSLog(@"NO KEY 3 AVAILABLE");
        return nil;
    }
    if (key.keyJSON) {
        NSData* keyData = [Base64Security decodeBase64String:key.keyJSON];
        if (keyData)
            key.keyJSON = [[NSString alloc] initWithData:[[AppFacade share] decryptDataLocally:keyData]
                                                encoding:NSUTF8StringEncoding];
    }
    NSDictionary* dicKey = [ChatAdapter decodeJSON:key.keyJSON];
    NSString* hash256Content = [AESSecurity hashSHA256:xmppContent];
    //NSString* identityContent = [NSString stringWithFormat:@"%@%@%@",hash256Content,kAES_SEPARATOR,chatboxId];
    NSData* identityData = [hash256Content dataUsingEncoding:NSUTF8StringEncoding];
    //using key 3 here and identityData must not > 117 length. or will return null.
    NSData* encIdentiy = [RSASecurity encryptRSA:identityData
                                    b64PublicExp:[dicKey objectForKey:kMOD3_EXPONENT]
                                      b64Modulus:[dicKey objectForKey:kMOD3_MODULUS]];
    NSString* base64Identity = [Base64Security generateBase64String:encIdentiy];
    
    return base64Identity;
}

-(void) searchChatRoom:(NSString*) text{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^(void){
        NSMutableArray* arrResult = [NSMutableArray new];
        NSString* queryList = [NSString stringWithFormat:@"chatboxState = '%d'", kCHATBOX_STATE_DISPLAY];
        NSArray* arrChatBox = [[DAOAdapter share] getObjects:[ChatBox class] condition:queryList orderBy:@"updateTS"        isDescending:YES limit:MAXFLOAT];
        
        if (text.length > 0){
            NSString *name = nil;
            int indexCounter = 0;
            
            for (ChatBox* sTemp in arrChatBox)
            {
                if(!sTemp.isGroup)
                    name = [[ContactFacade share] getContactName:sTemp.chatboxId];
                else
                    name = [[ChatFacade share] getGroupName:sTemp.chatboxId];
                NSRange titleResultsRange = [name rangeOfString:text options:NSCaseInsensitiveSearch];
                
                if (titleResultsRange.length > 0)
                    [arrResult addObject:sTemp];
                
                indexCounter++;
            }
        }
        else
            arrResult = [arrChatBox mutableCopy];
        [chatListDelegate reloadSearchChatList:arrResult];
    }];
}


-(NSString*) decryptMessage:(NSString*) xmppContent
                  chatBoxId:(NSString*) chatBoxId{
    @try {
        if (!xmppContent || !chatBoxId)
            return nil;
        Key* key = [[AppFacade share] getKey:chatBoxId];
        if ([[AppFacade share] getChatBox:chatBoxId].isGroup) {
            NSArray* xmppContentArray = [xmppContent componentsSeparatedByString:kINFO_SEPARATOR];
            NSString *keyVer = nil;
            if (xmppContentArray.count > 1) {
                keyVer = [xmppContentArray objectAtIndex:1];
                key = [[AppFacade share] getKeyForGroup:chatBoxId andVersion:keyVer];
            }
        }
        
        if (!key || !key.keyJSON)
            return nil;
        
        NSData* keyData = [Base64Security decodeBase64String:key.keyJSON];
        if (keyData)
            key.keyJSON = [[NSString alloc] initWithData:[[AppFacade share] decryptDataLocally:keyData]
                                                encoding:NSUTF8StringEncoding];
        
        NSDictionary* keyDic = [ChatAdapter decodeJSON:key.keyJSON];
        if (!keyDic)
            return nil;
        NSArray* arrContent = [xmppContent componentsSeparatedByString:kMSG_SEPARATOR];
        if([arrContent count] != 3)
            return nil;
        
        if ([[AppFacade share] getChatBox:chatBoxId].isGroup) {
            NSString *keyStr = [[ChatAdapter decodeJSON:key.keyJSON] objectForKey:kMUC_KEY];
            NSData *keyData = [Base64Security decodeBase64String:keyStr];
            //NSString *key_version = key.keyVersion;
            if ([[xmppContent componentsSeparatedByString:kINFO_SEPARATOR] count]!=2)
                return nil;
            NSString *encContent = [arrContent objectAtIndex:1];
            NSData *encContentData = [Base64Security decodeBase64String:encContent];
            NSData *decContentData = [AESSecurity decryptAES256WithKey:keyData Data:encContentData];
            return [[NSString alloc] initWithData:decContentData encoding:NSUTF8StringEncoding];
        }
        else {
            NSArray* arrAES = [[arrContent objectAtIndex:1] componentsSeparatedByString:kAES_SEPARATOR];
            if ([arrAES count] != 2)
                return nil;
            NSString* AESEncKey = [arrAES objectAtIndex:0];
            NSString* AESContent = [arrAES objectAtIndex:1];
            
            if (!AESEncKey || !AESContent)
                return nil;
            NSData* AESKey = [RSASecurity decryptRSA:AESEncKey
                                        b64PublicExp:[KeyChainSecurity getStringFromKey:kMOD1_EXPONENT]
                                          b64Modulus:[KeyChainSecurity getStringFromKey:kMOD1_MODULUS]
                                       b64PrivateExp:[KeyChainSecurity getStringFromKey:kMOD1_PRIVATE]];
            if (!AESKey)
                return nil;
            
            NSData* contentData = [AESSecurity decryptAES256WithKey:AESKey Data:[Base64Security decodeBase64String:AESContent]];
            if (!contentData)
                return nil;
            NSString* content = [[NSString alloc] initWithData:contentData encoding:NSUTF8StringEncoding];
            return content;
        }
        
        return nil;
    }
    @catch (NSException *exception) {
        NSLog(@"decryptMessage xmppContent: %@",xmppContent);
        NSLog(@"Exception: %@",exception.description);
    }
}

-(NSData*) decryptKeyAES:(NSString*) base64Key
               chatBoxId:(NSString*) chatBoxId
              keyVersion:(NSString*) keyVersion{
    if (!base64Key.length > 0 || !chatBoxId.length > 0)
        return nil;
    Key* key = [[AppFacade share] getKey:chatBoxId];
    if ([[AppFacade share] getChatBox:chatBoxId].isGroup) {
        key = [[AppFacade share] getKeyForGroup:chatBoxId andVersion:keyVersion];
    }
    
    if (!key || !key.keyJSON)
        return nil;
    if (key.keyJSON) {
        NSData* keyData = [Base64Security decodeBase64String:key.keyJSON];
        if (keyData)
            key.keyJSON = [[NSString alloc] initWithData:[[AppFacade share] decryptDataLocally:keyData]
                                                encoding:NSUTF8StringEncoding];
    }
    NSDictionary* keyDic = [ChatAdapter decodeJSON:key.keyJSON];
    if (!keyDic)
        return nil;
    
    NSData* keyOriginal = nil;
    
    //single media.
    if (![[AppFacade share] getChatBox:chatBoxId].isGroup){
        keyOriginal = [RSASecurity decryptRSA:base64Key
                                 b64PublicExp:[KeyChainSecurity getStringFromKey:kMOD1_EXPONENT]
                                   b64Modulus:[KeyChainSecurity getStringFromKey:kMOD1_MODULUS]
                                b64PrivateExp:[KeyChainSecurity getStringFromKey:kMOD1_PRIVATE]];
    }
    //group media.
    else{
        NSString *keyStr = [[ChatAdapter decodeJSON:key.keyJSON] objectForKey:kMUC_KEY];
        NSData *keyMUC = [Base64Security decodeBase64String:keyStr];
        keyOriginal = [AESSecurity decryptAES256WithKey:keyMUC
                                                   Data:[Base64Security decodeBase64String:base64Key]];
    }
    
    return keyOriginal;
}

-(BOOL)reUploadProcess:(Message*) messsageReupload{
    NSData* sendingOutData = nil;
    
    switch ([[ChatFacade share] messageType:messsageReupload.messageType]) {
        case MediaTypeImage:
            sendingOutData = [ChatAdapter imageRawData:messsageReupload.messageId];
            break;
        case MediaTypeAudio:
            sendingOutData = [ChatAdapter audioRawData:messsageReupload.messageId];
            break;
        case MediaTypeVideo:
            sendingOutData = [ChatAdapter videoRawData:messsageReupload.messageId];
            break;
        default:
            break;
    }
    
    sendingOutData = [[AppFacade share] decryptDataLocally:sendingOutData];
    
    if(!sendingOutData)
        return FALSE;
    
    if(messsageReupload.isEncrypted){
        NSData* key = [AESSecurity randomDataOfLength:32];
        NSData* encContent = [AESSecurity encryptAES256WithKey:key
                                                          Data:sendingOutData];
        sendingOutData = encContent;
        
        //store the key so after upload will send it inside xmpp.
        messsageReupload.extend2 = [[ChatFacade share] encryptKeyAES:key chatboxId:messsageReupload.chatboxId];
        [[DAOAdapter share] commitObject:messsageReupload];
    }
    NSInteger uploadType = [[AppFacade share] getChatBox:messsageReupload.chatboxId].isGroup ? kUPLOAD_TYPE_USER_TO_MUC : kUPLOAD_TYPE_USER_TO_USER;
    
    messsageReupload.messageStatus = MESSAGE_STATUS_PENDING;
    messsageReupload.sendTS = [NSNumber numberWithInteger:[[NSDate date] timeIntervalSince1970]];
    messsageReupload.readTS = messsageReupload.sendTS;
    [[DAOAdapter share] commitObject:messsageReupload];
    
    [self uploadMediaFile:sendingOutData
                messageId:messsageReupload.messageId
                targetJID:messsageReupload.chatboxId
               uploadType:uploadType];
    
    return TRUE;
}

-(void) handleChatStateMessage:(NSDictionary *)userInfo{
    if ([[userInfo objectForKey:kCHAT_STATE_TYPE] isEqual:CHAT_STATE_TYPE_COMPOSING]) {
        [chatViewDelegate handleSingleChatState:userInfo];
    }
}

-(void) stopCurrentAudioPlaying:(NSString*) messageID{
    [chatViewDelegate stopAudioPlaying:messageID];
}

- (void) showProfileImageInChatbox:(ChatBox *)chatBox
{
    UIImage *profileImage = [UIImage new];
    if (chatBox.isGroup)
    {
        profileImage = [self updateGroupLogo:chatBox.chatboxId];
    }
    else
    {
        Contact* contact = [[ContactFacade share] getContact:chatBox.chatboxId];
        if (contact){
            profileImage = [[ContactFacade share] updateContactAvatar:contact.jid];
        }
    }
    [viewPhotoDelegate showProfileImage:profileImage];
}

- (BOOL) isMediaFileExisted:(NSString*)fileName{
    return [ChatAdapter isMediaFileExisted:fileName];
}

-(void) updateAllUploadingMessage{
    NSString* queryMessage = [NSString stringWithFormat:@"messageStatus = '%@'", MESSAGE_STATUS_UPLOADING];
    NSArray* arrMessage = [[DAOAdapter share] getObjects:[Message class] condition:queryMessage];
    
    for(Message* message in arrMessage){
        if ([message isKindOfClass:[Message class]]) {
            message.messageStatus = MESSAGE_STATUS_UPLOADED_FAILED;
            [[DAOAdapter share] commitObject:message];
        }
    }
}

#define TEMP @"53bcaa74a813b95f06de9d8f235433b87a115207.mp4"
-(NSString*) createTempURL:(NSData*) rawData{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString* rawLink = [[paths objectAtIndex:0] stringByAppendingPathComponent:TEMP];
    [[NSFileManager defaultManager] createFileAtPath:rawLink
                                            contents:rawData attributes:nil];
    
    return rawLink;
}

-(void) removeTempURLFile{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString* rawVideoLink = [[paths objectAtIndex:0] stringByAppendingPathComponent:TEMP];
    [[NSFileManager defaultManager] removeItemAtPath:rawVideoLink error:nil];
}

@end
