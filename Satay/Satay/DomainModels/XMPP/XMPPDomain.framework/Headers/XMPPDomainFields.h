//
//  XMPPDomainFields.h
//  XMPPDomain
//
//  Created by Daniel Nguyen on 2/2/15.
//  Copyright (c) 2015 mTouche. All rights reserved.
//

#ifndef XMPPDomain_XMPPDomainFields_h
#define XMPPDomain_XMPPDomainFields_h

#define kXMPP_HOST_NAME         @"XMPP_HOST_NAME"
#define kXMPP_MUC_HOST_NAME     @"XMPP_MUC_HOST_NAME"
#define kXMPP_PORT_NUMBER       @"XMPP_PORT_NUMBER"
#define kXMPP_RESOURCE          @"XMPP_RESOURCE"

#define kPRESENCE_TYPE          @"PRESENCE_TYPE"
#define kPRESENCE_STATUS        @"PRESENCE_STATUS"
#define kPRESENCE_FROM_USER     @"PRESENCE_FROM_USER"
#define kPRESENCE_FROM_USER_JID @"PRESENCE_FROM_USER_JID"

#define kPRESENCE_STATUS_TEXT_ONLINE        @"Online"
#define kPRESENCE_STATUS_TEXT_BUSY          @"Busy"
#define kPRESENCE_STATUS_TEXT_AWAY          @"Away"
#define kPRESENCE_STATUS_TEXT_OFFLINE       @"Offline"
#define kPRESENCE_STATUS_TEXT_AVAILABLE     @"available"
#define kPRESENCE_STATUS_TEXT_UNAVAILABLE   @"unavailable"

// for user
#define kXMPP_USER_JID          @"XMPP_USER_JID"
#define kXMPP_FROM_JID          @"XMPP_FROM_JID"
#define kXMPP_TO_JID            @"XMPP_TO_JID"
#define kXMPP_USER_PASSWORD     @"XMPP_USER_PASSWORD"
#define kXMPP_USER_DISPLAYNAME  @"XMPP_USER_DISPLAYNAME"
#define kXMPP_USER_MASKING_ID   @"XMPP_USER_MASKING_ID"
#define kXMPP_USER_EMAIL        @"XMPP_USER_EMAIL"
#define kXMPP_ERROR             @"XMPP_ERROR"
#define kXMPP_JID_KIND          @"XMPP_JID_KIND"
#define kXMPP_JID_KIND_MUC      @"jid_muc"
#define kXMPP_JID_KIND_S        @"jid_single"

// for subscription
#define kXMPP_SUBSCRIPTION_BODY         @"XMPP_SUBSCRIPTION_BODY"
#define kXMPP_SUBSCRIPTION_ID           @"XMPP_SUBSCRIPTION_ID"
#define kXMPP_SUBSCRIPTION_TYPE         @"XMPP_SUBSCRIPTION_TYPE"
#define kXMPP_SUBSCRIPTION_TYPE_FROM    1
#define kXMPP_SUBSCRIPTION_TYPE_TO      2
#define kXMPP_SUBSCRIPTION_TYPE_BOTH    3

// for chat command
#define kXMPP_BODY_MESSAGE_TYPE             @"mt"
#define kXMPP_BODY_MESSAGE_CONTENT          @"ct"
#define kXMPP_BODY_MESSAGE_SELF_DESTROY     @"sd"

#define kXMPP_BODY_MESSAGE_TYPE_TEXT        @"txt"
#define kXMPP_BODY_MESSAGE_TYPE_IMAGE       @"img"
#define kXMPP_BODY_MESSAGE_TYPE_VIDEO       @"vid"
#define kXMPP_BODY_MESSAGE_TYPE_AUDIO       @"aud"

#define kXMPP_MESSAGE_STREAM_TYPE          @"XMPP_MESSAGE_TYPE"
#define kXMPP_MESSAGE_STREAM_TYPE_MUC      @"XMPP_MESSAGE_TYPE_MUC"
#define kXMPP_MESSAGE_STREAM_TYPE_SINGLE   @"XMPP_MESSAGE_TYPE_SINGLE"

#define kSUB_BODY_MT_IDEN_XCHANGE_ADD       @"iden_xchange_add"
#define kSUB_BODY_MT_IDEN_XCHANGE_APPROVE   @"iden_xchange_approve"
#define kSUB_BODY_MT_IDEN_XCHANGE_ERROR     @"iden_xchange_error"
#define kSUB_BODY_MT_IDEN_XCHANGE_DENY      @"iden_xchange_denied"
#define kSUB_BODY_MT_IDEN_XCHANGE_DELETE    @"iden_xchange_delete"
#define kSUB_BODY_MT_IDEN_XCHANGE_DONE      @"iden_xchange_done"

// for vcard update
#define kVCARD_UPDATE_NONE          0
#define kVCARD_UPDATE_AVATAR        1
#define kVCARD_UPDATE_DISPLAYNAME   2

// for avatar
#define kAVATAR_IS_ME           @"AVATAR_IS_ME"
#define kAVATAR_TARGET_JID      @"AVATAR_TARGET_JID"
#define kAVATAR_IMAGE_DATA      @"AVATAR_IMAGE_DATA"

// for text message
#define kSEND_TEXT_MESSAGE_VALUE    @"SEND_TEXT_MESSAGE_VALUE"
#define kSEND_TEXT_TARGET_JID       @"SEND_TEXT_TARGET_JID"
#define kSEND_TEXT_MESSAGE_ID       @"SEND_TEXT_MESSAGE_ID"
#define kTEXT_MESSAGE_BODY          @"TEXT_MESSAGE_BODY"
#define kTEXT_MESSAGE_FROM          @"TEXT_MESSAGE_FROM"
#define kTEXT_MESSAGE_TO            @"TEXT_MESSAGE_TO"
#define kTEXT_MESSAGE_DELAYED_DATE  @"TEXT_MESSAGE_DELAYED_DATE"
#define kTEXT_MESSAGE_TYPE          @"TEXT_MESSAGE_TYPE"
#define kTEXT_MESSAGE_ID            @"TEXT_MESSAGE_ID"
#define kTEXT_MESSAGE_ERROR         @"TEXT_MESSAGE_ERROR"

#define kMESSAGE_STATUS                     @"MESSAGE_STATUS"
#define kMESSAGE_STATUS_READ                @"30"
#define kMESSAGE_STATUS_DELIVERED           @"20"
#define kMESSAGE_STATUS_DELIVERED_FAILED    @"21"
#define kMESSAGE_STATUS_SENT                @"10"
#define kMESSAGE_STATUS_PENDING             @"11"
#define kMESSAGE_STATUS_RECEIVED            @"12"
#define kMESSAGE_STATUS_MEDIA_DOWNLOADED    @"13"
#define kMESSAGE_STATUS_DELETED_BY_USER     @"14"
#define kMESSAGE_STATUS_INTERUPTED          @"15"
#define kMESSAGE_STATUS_NOT_UPLOADED        @"16"
#define kMESSAGE_STATUS_NOT_DOWNLOADED      @"17"
#define kMESSAGE_STATUS_SEND_FAILED         @"18"

// for ROOM
#define kMUC_ROOM_JID                   @"MUC_ROOM_JID"
#define kMUC_ROOM_PASSWORD              @"MUC_ROOM_PASSWORD"
#define kMUC_ROOM_AFFILIATION           @"MUC_ROOM_AFFILIATION"
#define kMUC_ROOM_ROLE                  @"MUC_ROOM_ROLE"
#define kMUC_SEND_TEXT_MESSAGE_VALUE    @"MUC_SEND_TEXT_MESSAGE_VALUE"
#define kMUC_SEND_TEXT_TARGET_ROOMJID   @"MUC_SEND_TEXT_TARGET_ROOMJID"
#define kMUC_ROOM_INVITE_MESSAGE_FULL   @"MUC_ROOM_INVITE_MESSAGE_FULL"
#define kMUC_ROOM_INVITE_MESSAGE        @"MUC_ROOM_INVITE_MESSAGE"
#define kMUC_ROOM_INVITE_MESSAGE_TXT    @"Join me for conference"
#define kMUC_HISTORY                    @"MUC_HISTORY"

#define kMUC_ACTOR      @"MUC_ACTOR"
#define kMUC_OCCUPANT   @"MUC_OCCUPANT"

#define kAFFILIATION_NONE       @"none"
#define kAFFILIATION_OWNER      @"owner"
#define kAFFILIATION_MEMBER     @"member"
#define kAFFILIATION_ADMIN      @"admin"
#define kAFFILIATION_OUTCAST    @"outcast"

#define kROLE_MODERATOR         @"moderator"
#define kROLE_NONE              @"none"
#define kROLE_PARTICIPANT       @"participant"
#define kROLE_VISITOR           @"visitor"

// for Chat State
#define kCHAT_STATE_TYPE                    @"CHAT_STATE_TYPE"
#define kCHAT_STATE_TYPE_NUMBER             @"CHAT_STATE_TYPE_NUMBER"
#define kCHAT_STATE_TARGET_JID              @"CHAT_STATE_TARGET_JID"
#define kCHAT_STATE_FROM_JID                @"CHAT_STATE_FROM_JID"
#define kCHAT_STATE_TYPE_ACTIVE             1
#define kCHAT_STATE_TYPE_INACTIVE           2
#define kCHAT_STATE_TYPE_COMPOSING          3
#define kCHAT_STATE_TYPE_PAUSED             4
#define kCHAT_STATE_TYPE_GONE               5
#define kCHAT_STATE_TYPE_ACTIVE_STRING     @"Active"
#define kCHAT_STATE_TYPE_INACTIVE_STRING   @"Inactive"
#define kCHAT_STATE_TYPE_COMPOSING_STRING  @"Composing"
#define kCHAT_STATE_TYPE_PAUSED_STRING     @"Paused"
#define kCHAT_STATE_TYPE_GONE_STRING       @"Gone"

#endif
