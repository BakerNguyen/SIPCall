//
//  ChatFacade.h
//  Satay
//
//  Created by Daniel Nguyen on 3/10/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ChatDomain/ChatDomain.h>

#define kMASKINGID @"MASKINGID"
#define kMEMBER_MASKINGID @"MEMBERMASKINGID"
#define kMESSAGETYPE @"MESSAGETYPE"
#define kOCCUPANTS @"OCCUPANTS"
#define kSENDER_JID @"SENDER_JID"
#define kROOMJID @"ROOMJID"
#define kROOMNAME @"ROOMNAME"
#define kMUC_ROOM_HOST @"MUC_ROOM_HOST"
#define kROOM_HOST @"ROOMHOST"
#define kROOM_TS @"ROOM_TS"
#define kROOM_EXT1 @"ROOM_EXT1"
#define kROOM_EXT2 @"ROOM_EXT2"
#define kROOM_IMAGE_URL @"ROOM_IMAGE_URL"
#define kROOMLOGOURL @"ROOMLOGOURL"
#define kROOM_IMAGE_DATA @"ROOM_IMAGE_DATA"
#define kROOM_PASSWORD @"ROOMPASSWORD"
#define kMUC_KEY @"MUCKEY"
#define kMUC_KEY_S @"KEY"
#define kMUC_KEY_VER @"VER"
#define kMUC_KEY_VERSION @"VERSION"
#define kGROUP_KEY @"GROUPKEY"
#define kMEMBER_JID_LIST @"MEMBERJIDLIST"
#define kGROUP_OWNER @"GROUP_OWNER"
#define kIS_JOIN @"IS_JOIN"
#define kMUC_NICKNAME @"NICKNAME"
#define kIS_MUC_ADMIN @"IS_MUC_ADMIN"
#define kIS_ADD_PARTICIPANT @"IS_ADD_PARTICIPANT"
#define kKILL_ROOM @"KILLROOM"
#define kROOM_NOTICE_DELAY_DATE @"ROOM_NOTICE_DELAY_DATE"
#define kCHAT_STATE_TYPE_NUMBER @"CHAT_STATE_TYPE_NUMBER"
#define kCHAT_STATE_FROM_JID @"CHAT_STATE_FROM_JID"
#define kCHAT_STATE_TYPE @"CHAT_STATE_TYPE"

// 0 = kicked, 1 = leave, 2 active, 3 inactive
#define kGROUP_MEMBER_STATE_ACTIVE 2
#define kGROUP_MEMBER_STATE_INACTIVE 3
#define kGROUP_MEMBER_STATE_KICKED 0
#define kGROUP_MEMBER_STATE_LEAVE 1

// 0 = admin, 1 = member
#define kGROUP_MEMBER_ROLE_ADMIN 0
#define kGROUP_MEMBER_ROLE_MEMBER 1

//define message type can be send and receive between A and B. or from -999 Jalvis.
#define MSG_TYPE_TEXT    @"TXT"
#define MSG_TYPE_IMAGE   @"IMG"
#define MSG_TYPE_VIDEO   @"VID"
#define MSG_TYPE_AUDIO   @"AUD"
#define MSG_TYPE_SIP     @"SIP"
#define MSG_TYPE_NOT_GRP_CREATE @"NOT_GRP_CREATE"
#define MSG_TYPE_NOT_GRP_ADD @"NOT_GRP_ADD"
#define MSG_TYPE_NOT_GRP_JOIN @"NOT_GRP_JOIN"
#define MSG_TYPE_NOT_GRP_LEFT @"NOT_GRP_LEFT"
#define MSG_TYPE_NOT_GRP_KICK @"NOT_GRP_KICK"
#define MSG_TYPE_NOT_GRP_CHG_NAME @"NOT_GRP_CHG_NAME"
#define MSG_TYPE_NOT_GRP_CHG_LOGO @"NOT_GRP_CHG_LOGO"
#define MSG_TYPE_NOT_MESSAGE_DESTROY @"NOT_MESSAGE_DESTROY"

// Chat state type
#define CHAT_STATE_TYPE_COMPOSING @"Composing"

#define VIDEO_SIZE_LIMIT 10
#define IMAGE_SIZE_LIMIT 2
#define AUDIO_SIZE_LIMIT 2
#define VIDEO_SIZE_LIMIT_BYTE 10*1024*1024
#define IMAGE_SIZE_LIMIT_BYTE 2*1024*1024
#define AUDIO_SIZE_LIMIT_BYTE 2*1024*1024

typedef enum XMPPUpdateElement XMPPUpdateFlag;

@interface ChatFacade : NSObject {
    NSMutableDictionary *tempRoomCreating;
    NSObject <NewGroupCreateDelegate> *groupCreateDelegate;
    NSObject <ContactInfoDelegate> *contactInfoDelegate;
    NSObject <ChatViewDelegate> *chatViewDelegate;
    NSObject <ChatListDelegate> *chatListDelegate;
    NSObject <CWindowDelegate> *windowDelegate;
    NSObject <ViewPhotoDelegate> *viewPhotoDelegate;
    NSObject <ChatListEditDelegate> *chatListEditDelegate;
    NSObject <IncomingNotificationDelegate> *incomingNotificationDelegate;
    NSObject <ManageStorageDelegate> *manageStorageDelegate;
    NSObject <SideBarDelegate> *sideBarDelegate;
}

@property (nonatomic, retain) NSMutableDictionary *tempRoomCreating;
@property (nonatomic, retain) NSObject *groupCreateDelegate;
@property (nonatomic, retain) NSObject *contactInfoDelegate;
@property (nonatomic, retain) NSObject *chatViewDelegate;
@property (nonatomic, retain) NSObject *chatListDelegate;
@property (nonatomic, retain) NSObject *windowDelegate;
@property (nonatomic, retain) NSObject *viewPhotoDelegate;
@property (nonatomic, retain) NSObject *chatListEditDelegate;
@property (nonatomic, retain) NSObject *incomingNotificationDelegate;
@property (nonatomic, retain) NSObject *manageStorageDelegate;
@property (nonatomic, retain) NSObject *sideBarDelegate;

+ (ChatFacade *)share;

typedef void (^reqCompleteBlock)(BOOL success, NSString *message ,NSDictionary *response, NSError *error);

- (void)createChatRoomWithInfo:(NSDictionary *)chatRoomInfo;
- (void)didSuccessCreateChatRoom:(NSString *)roomJid;
- (void)didSuccessJoinChatRoom:(NSString *)roomJid isRejoined:(BOOL) isRejoined;
- (void)getChatRoom:(NSString *)roomjid forJoin:(BOOL)isJoin;
- (void)uploadMUCKey:(NSDictionary *)keyInfo;
- (void)getMucKey:(NSDictionary *)keyInfo;
- (void)queryAddMembersToChatRoom:(NSString *)roomJID;
- (void)leaveFromChatRoom:(NSDictionary *)infoObj;
- (void)kickMember:(NSDictionary *)infoObj;
- (void)addMember:(NSDictionary *)infoObj;
- (void)setChatRoomName:(NSDictionary*)infoObj callback:(reqCompleteBlock)callback;

/**
 * set Chat Room Logo
 *
 * @param: NSDictionary *info = @{kMUC_ROOM_JID: @"room_jid", // jid without domain
 *                                kROOM_IMAGE_DATA: UIImageJPEGRepresentation([UIImage imageNamed:IMG_ICON], 1.0)
 *                               };
 * @author Daniel
 */
- (void)setChatRoomLogo:(NSDictionary *)infoObj;

/**
 * save GroupChat Info to local DB after create or join new group
 * @param: roomJID must have, other info will store to temp object when create or receive room info
 * @author Daniel
 */
- (BOOL)saveGroupChatInfo:(NSString *)roomJID;
/**
 * update GroupChat Info
 * @param:
 * NSDictionary *groupInfo = @{kMUC_ROOM_JID: @"roomJID",           --> NOT NULL
 *                             kROOMNAME: @"roomName",             --> optional
 *                             kROOM_IMAGE_URL: @"roomIMAGEURL",    --> optional
 *                             kROOM_TS: @"roomTS",                 --> optional
 *                             kROOM_EXT1: @"ext1",                 --> optional
 *                             kROOM_EXT2: @"ext2"                  --> optional
 *                             };
 *
 * @author Daniel
 */
- (BOOL)updateGroupChatInfo:(NSDictionary *)groupInfo;
/**
 *  @author Daniel Nguyen, 15-03-30 09:03
 *
 *  @brief  Save Member to GroupMember table
 *
 *  @param jid     full jid of member
 *  @param roomjid full jid of group
 *  @param state   0 = kicked, 1 = leave, 2 active, 3 inactive
 *  @param role    0 = admin, 1 = member
 */
- (void)saveMember:(NSString *)jid toGroup:(NSString *)roomjid withState:(int)state andRole:(int)role;
- (NSMutableArray *)rejoinGroups;
- (void)updateForLeaveGroupChat:(NSString *)groupJid;

- (NSMutableArray *)getAllOwnerGroup;

/*Daryl Apr-15-2015: Method deprecated
- (void)updateForKickedOutGroupChat:(NSString *)groupJid;
*/

- (NSString *)getGroupName:(NSString *)groupId;
- (NSString *)getGroupPassword:(NSString *)groupId;
- (NSArray *)getMembersList:(NSString *)groupId;
- (NSArray *)getMemberContactsList:(NSString *)groupId;
- (NSString *)getGroupLogoUrl:(NSString *)groupId;
- (UIImage *)updateGroupLogo:(NSString *)fullJID;

/*
 *Check this account is admin of group with chatBoxId or not.
 *@Author TrungVN
 */
- (BOOL) isAdmin:(NSString*) chatBoxId;

// For notice MUC events
/**
 *  @author Daniel Nguyen, 15-04-23 13:04
 *  @brief  Notice the created a group event, save to local db
 *  @param infoObj = @{kROOMJID: @"full room jid", kJID: @"admin full jid"};
 */
- (void)noticeGroupCreated:(NSDictionary *)infoObj;
/**
 *  @author Daniel Nguyen, 15-04-23 16:04
 *  @brief  Notice the member joined to group chat
 *  @param infoObj @{kROOMJID: @"full room jid", kJID: @"member full jid"};
 */
- (void)noticeGroupMemberJoin:(NSDictionary *)infoObj;
/**
 *  @author Daniel Nguyen, 15-04-01 11:04
 *  @brief  Notice to changed group name, save to local db
 *  @param infoObj = @{kROOMJID: @"full room jid", kROOMNAME: @"new_name"};
 */
- (void)noticeGroupRenamed:(NSDictionary *)infoObj;
/**
 *  @author Daniel Nguyen, 15-04-01 11:04
 *  @brief  Notice to changed group logo, save to local db
 *  @param infoObj = @{kROOMJID: @"full room jid", kROOM_IMAGE_URL: @"new_url"};
 */
- (void)noticeGroupLogo:(NSDictionary *)infoObj;
/**
 *  @author Daniel Nguyen, 15-04-01 11:04
 *  @brief  Notice for a member was kicked out by admin
 *  @param infoObj = @{kROOMJID: @"full room jid", kJID: @"full member jid"};
 */
- (void)noticeGroupKickOut:(NSDictionary *)infoObj;

/**
 *  @author Daniel Nguyen, 15-04-01 11:04
 *  @brief  Notice for a member was added by admin
 *  @param infoObj = @{kROOMJID: @"full room jid", kJID: @"full member jid"};
 * currently deprecated.
- (void)noticeGroupAddedMember:(NSDictionary *)infoObj;
  */

/**
 *  @author Daniel Nguyen, 15-04-01 11:04
 *  @brief  Notice for a member did leave himself
 *  @param infoObj = @{kROOMJID: @"full room jid", kJID: @"full member jid"};
 */
- (void)noticeGroupMemberLeaved:(NSDictionary *)infoObj;

/* *Group Important Method.
 * After delegate XMPPFacade: xmppDomain:(XMPPAdapter *)sender 
 didReceiveMessage:(NSDictionary *)message
 * @Author TrungVN
 * Process messageNotification to display.
 */
- (BOOL)receiveNotification:(NSDictionary*)messageNotification;
- (void)handleNoticeFromPresence:(NSDictionary*)presenceDic;
- (void)sendNoticeForGroupUpdate:(NSDictionary *)groupDic;

/*
 * sendTextMessage to xmpp target is chatboxId
 * @Author TrungVN
 * process text from UI, create Message* object, encrypt message content (if needed).
 * connect to XMPP Facade to send message to xmpp server.
 */
-(BOOL) sendText:(NSString*) stringContent
       chatboxId:(NSString*) chatboxId;
/*
 * sendAudioMessage to xmpp target is chatboxId
 * @Author TrungVN
 * process audio url store file, create Message* object, encrypt message audio data and message content (if needed).
 * connect to XMPP Facade to send message to xmpp server.
 */
-(BOOL) sendAudio:(NSString*) sourcePath
        chatboxId:(NSString*) chatboxId;
/*
 * sendImageMessage to xmpp target is chatboxId
 * @Author TrungVN
 * process UIImage, resize it, store it locally.
 * create Message* object, encrypt message image data and message content (if needed).
 * connect to XMPP Facade to send message to xmpp server.
 */
-(BOOL) sendImage:(UIImage*) image
        chatboxId:(NSString*) chatboxId;
/*
 * send Video Message to xmpp target is chatboxId
 * @Author TrungVN
 * process videoURL, get video data, store it locally, create thumbnail of video and store.
 * create Message* object, encrypt message video data and message content (if needed).
 * connect to XMPP Facade to send message to xmpp server.
 */
-(BOOL) sendVideo:(NSURL*) videoURL
        chatboxId:(NSString*) chatboxId;

/** this comment is for all 4 type of getting data below
 * get the base imageData of the message base on it message
 * the data will be pull from rawData or decrypted from encryptedData and response back.
 * @Author TrungVN
 */
-(NSData*) imageData:(NSString*) messageId;
-(NSData*) audioData:(NSString*) messageId;
-(NSData*) videoData:(NSString*) messageId;
-(NSData*) thumbData:(NSString*) messageId;

/*
 * Encrypte key AES base on contact key.
 * chatboxId is equal contact jid
 * @Author TrungVN
 */
-(NSString*) encryptKeyAES:(NSData*) keyData
                 chatboxId:(NSString*) chatboxId;

/*
 * Encrypte xmpp message content base on contact key or group key.
 * chatboxId is equal contact jid or groupjid
 * @Author TrungVN
 */
-(NSString*) encryptMessage:(NSString*) xmppContent
                  chatboxId:(NSString*) chatboxId;
/*
 * Encrypte xmpp message identity base on contact key or group key.
 * chatboxId is equal contact jid or groupjid
 * @Author TrungVN
 */
-(NSString*) encryptIdentity:(NSString*) xmppContent
                   chatboxId:(NSString*) chatboxId;
/*
 * Decrypt xmpp message content base on contact key or group key.
 * chatboxId is equal contact jid or groupjid
 * @Author TrungVN
 */
-(NSString*) decryptMessage:(NSString*) xmppContent
                  chatBoxId:(NSString*) chatBoxId;

/*
 * decryptKeyAES content base on contact key.
 * chatboxId is equal contact jid
 * @Author TrungVN
 */
-(NSData*) decryptKeyAES:(NSString*) base64Key
               chatBoxId:(NSString*) chatBoxId
              keyVersion:(NSString*) keyVersion;

/*
 *copy content to clipboard of iOS
 *@Author TrungVN
 */
-(void) copyToClipboard:(NSString*) content;
/*
 *Save message Media data to iPhone share library, include video and image.
 *@Author TrungVN
 */
-(void) saveMediaToLibrary:(Message*) message;
/*
 *return messageType number defined under base on messageType string.
 *return -1000 if the messageType string is not the correct one.
 *@Author TrungVN
 */
typedef enum {
    MediaTypeText,
    MediaTypeVideo,
    MediaTypeAudio,
    MediaTypeImage,
    MediaTypeSIP,
    MediaTypeNotification
} MediaType;
-(NSInteger) messageType:(NSString*) messageType;

/*
 *getChatBoxLastMessage base on time of a chatbox
 *@Author TrungVN
 */
-(NSString*) getChatBoxLastMessage:(NSString*) chatboxId;
/*
 *getChatBoxTimeStamp string base on latest update time of a chatbox
 *@Author TrungVN
 */
-(NSString*) getChatBoxTimeStamp:(NSNumber*) timeNumber;
/*
 *getChatBoxUnreadCount 1,2,3 ... 9+, base on the message that's not read in the chatbox
 *@Author TrungVN
 */
-(NSString*) getChatBoxUnreadCount:(NSString*) chatboxId;
/*
 *removeAllChatBoxMessage of the chatbox
 *@Author TrungVN
 */
-(BOOL) removeAllChatBoxMessage:(NSString*) chatboxId;

/*
 * After delegate XMPPFacade: xmppDomain:(XMPPAdapter *)sender didReceiveReceiptResponse:
 * @Author TrungVN
 * Process messageStatus dictionary to display
 */
-(void) receiveMessageStatus:(NSDictionary*) messageStatus;

/* *Important Method.
 * After delegate XMPPFacade: xmppDomain:(XMPPAdapter *)sender didReceiveMessage:(NSDictionary *)message
 * @Author TrungVN
 * Process receive dictionary messageContent to display.
 */
-(void) receiveMessage:(NSDictionary*) messageContent;

/*
 * uploadMediaFile
 * fileData is data to upload to server
 * messageId using for 1-1 and 1-MUC upload media file.
 * targetJID: fullJID, this is chatBoxId
 * uploadType: there are 3 types to be accepted.
 * @Author TrungVN
 */
-(void) uploadMediaFile:(NSData*) fileData
              messageId:(NSString*) messageId
              targetJID:(NSString*) fullJID
             uploadType:(NSInteger) uploadType;

/*
 * this is process the message when upload success and got the download link.
 * try to send the xmpp message.
 * @Author TrungVN
 */
-(BOOL) processUploadSuccess:(NSDictionary*) responseDic
                     message:(Message*)message;

/*
 * base on the url store in Message* .mediaServerURL
 * download the media file.
 * @Author TrungVN
 */
-(void) downloadMediaMessage:(Message*) messageDO;

/*
 * base on data downloaded
 * we process the message, displaying, storing in cache.
 * @Author TrungVN
 */
-(BOOL) processDownloadData:(NSData*) data
                    message:(Message*)message;

/*
 * DisplayPhotoBrowser base on messageDO we clicked.
 * @Author TrungVN
 */
-(void) displayPhotoBrower:(Message*) messageDO
              showGridView:(BOOL)showGridView;

/*
 * updateChatBoxDestroyTime using in SelfTimer view.
 * update the setting into DB.
 * @Author TrungVN
 */
-(void) updateChatBoxDestroyTime:(NSString*) chatboxId
                isAlwaysDestruct:(BOOL) isAlwaysDestruct
                          second:(NSInteger) second;

/*
 * startDestroyMessage start counting time the message
 * the message will be ignore if the status is pending.
 * @Author TrungVN
 */
-(void) startDestroyMessage:(NSString*) messageId;

/*
 * destroyMessage, this is when the nstimer count down at destroy time.
 * the message will be update status to mark as deleted and delete the real data.
 * @Author TrungVN
 */
-(void) destroyMessage:(NSTimer*) timer;

/*
 * reloadChatBoxList by reget the data from database
 * and call chatListDelegate to reload.
 * @Author TrungVN
 */
-(void) reloadChatBoxList;

/*
 * moveToChatView using the chatBoxId info.
 * @Author TrungVN
 */
-(void) moveToChatView:(NSString*) chatBoxId;

/*
 * check the xmppBody string is an encrypted message using the signal kENC_SIGNAL
 * @Author TrungVN
 */
-(BOOL) isEncryptMessage:(NSString*) xmppBody;

/*
 * getFullTimeString base on timestamp will return the string date
 * with format #define FORMAT_FULL_DATE @"d/M/YY h:mm a"
 * @Author TrungVN
 */
-(NSString *)getFullTimeString:(NSNumber *)timestamp;

/*
 * getHistoryMessage of a chatboxId
 * int limit message want to get.
 * @Author TrungVN
 */
-(NSArray*) getHistoryMessage:(NSString*) chatboxId
                        limit:(int) limit;

/*
 * getMediaMessage of a chatboxId
 * int limit message want to get.
 * @Author TrungVN
 */
-(NSArray*) getMediaMessage:(NSString*) chatboxId
                      limit:(int) limit;

/*
 * updateMessageReadTS of a message
 * @Author TrungVN
 */
-(BOOL) updateMessageReadTS:(Message*) message;

/*
 * isMineMessage return TRUE or FALSE
 * knowing the message belong to our account or not.
 * @Author TrungVN
 */
-(BOOL) isMineMessage:(Message*) message;

/*
 * create a default chatBox with chatboxId is string input.
 * BOOL isMUC make this chatBox.isGroup value is TRUE or FALSE.
 * @Author TrungVN
 */
-(BOOL) createChatBox:(NSString*) chatboxId isMUC:(BOOL)isMUC;

/*
 * reUpload message
 * @Author Sirius
 */
-(BOOL) reUploadProcess:(Message*) messsageReupload;

/**
 *  Search chatroom
 *  Author: Sirius
 */
-(void) searchChatRoom:(NSString*) text;

/**
 *  Count chabox list which is displayed.
 *  Author: Sirius
 */
-(NSUInteger) countChatBoxList;

/**
 *  Count media message existed in chat box.
 *  Author: Sirius
 */
-(NSUInteger) countMediaMessageExisted:(NSString*) chatboxId;

/**
 *  Show friend/group avatar in chat box
 *
 *  @param chatBox current chat box
 *  @author William
 *  date 13-May-2015
 */
- (void) showProfileImageInChatbox:(ChatBox *)chatBox;

/*
 *Check this account is kicked by owner of group with chatBoxId or not.
 *@Author Violet
 */
- (BOOL) isKickedByOwner:(NSString*) chatBoxId;
/**
 *  Get all chat box has media message
 *
 *  @return return array of chat box has media message
 *  @author William
 *  date 18-May-2015
 */
- (NSMutableArray*) getChatBoxHasMedia;

/**
 *  Get amount of all media file size in chat box
 *
 *  @param chatBox selected chat box
 *
 *  @return size of all media file
 *  @author William
 *  date 18-May-2015
 */
- (unsigned long long) getAmountOfMediaFileSize:(ChatBox*)chatBox;

/**
 *  Delete storage of seleteted chat box
 *
 *  @param selectedChatBox array of selected chat box
 *  @author William
 *  date 19-May-2015
 */
- (void) deleteStorage:(NSArray *)selectedChatBox;

/**
 *  Handle chat state (is typing... message) of chat view
 *  Author: Violet
 */
-(void) handleChatStateMessage:(NSDictionary *)userInfo;

/**
 *  Stop specific audio is playing with messageID. If messageID is nil then stop any audio is playing
 *  Author: Violet
 */
-(void) stopCurrentAudioPlaying:(NSString*) messageID;

/**
 *  Get number of all unread message in all chat box
 *
 *  @return number of unread message
 *  @author: William
 *  date 3-Jun-2015
 */
- (NSUInteger)getNumberAllChatBoxUnreadMessage;

/**
 *  Check if the media file is exist or not
 *  @return BOOLEAN value
 *  @author: Violet
 */
- (BOOL) isMediaFileExisted:(NSString*)fileName;

/**
 * update all uploading message status to uploaded failed.
 * this method for the purpose when user close the application immediately when uploading message so need to change it status to failed.
 *  @author: Trung
 */

-(void) updateAllUploadingMessage;

/**
 * createTempURL for rawData to NSString
 * this method for the purpose to create video and audio temp url to process.
 * @author: Trung
 */
-(NSString*) createTempURL:(NSData*) rawData;

/**
 * removeTempURL
 * this method for the purpose to prevent video and audio temp url leak info.
 * @author: Trung
 */
-(void) removeTempURLFile;

@end
