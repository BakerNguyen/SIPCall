//
//  UIDelegate.h
//  Satay
//
//  Created by TrungVN on 3/5/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

//SecNoteListDelegate
@protocol SecNoteListDelegate
@optional
-(void) reloadNoteList:(NSArray*) arrNote;
@end

//NotificationListDelegate
@protocol NotificationListDelegate
@optional
-(void) reloadNotificationPage;
@end

//IncomingNotificationDelegate
@protocol IncomingNotificationDelegate
@optional
-(void) showNotifyMessage:(id) message groupName :(id)groupName;
-(void) showNotifyRequest:(id) request;
-(void) showNotifyRemovedContact:(NSString *) fullJID;
-(void) showNotifyNewEmail:(int) numberNewEmail;
@end
//ManageStorageDelegate
@protocol ManageStorageDelegate
@optional

- (void) deleteStorageSuccees;

@end
//ContactNotificationDelegate
@protocol ContactNotificationDelegate
@optional
-(void) showNoInternet:(NSString*) notifyContent;
-(void) showNotifiView:(NSString*) notifyContent;
-(void) hideInternetView:(int) type;
-(void) hideNotification;
-(void) showConnecting;
@end

@protocol ChatListNotificationDelegate
@optional
-(void) showNoInternet:(NSString*) notifyContent;
-(void) hideInternetView:(int) type;
-(void) showConnecting;
@end

//ForwardListDelegate
@protocol ForwardListDelegate
@optional
-(void) reloadForwardList:(NSArray*) arrFriend;
@end

//ContactInfoDelegate
@protocol ContactInfoDelegate
@optional
-(void) buildView;
-(void) resetView;
-(void) displayPhotoBrower:(NSMutableArray*) photoArray
                photoIndex:(NSInteger) photoIndex;
-(void) enableSaveMediaButton:(BOOL)isEnable;
-(void) updateRoomLogoFailed;
-(void) synchronizeBlockListSuccess;
-(void) synchronizeBlockListFailed;
-(void) enableTableMemberListInteraction:(BOOL) isEnable;
@end

//ChatViewDelegate
@protocol ChatViewDelegate
@optional
-(void) addMessage:(NSString*) messageId;
-(void) updateStatus:(NSString*) messageId;
-(void) updateState:(NSString*) messageId;
-(void) updateCell:(NSString*) messageId;
-(void) displayName;
-(void) displaySingleStatus;
-(void) displayGroupStatus;
-(void) resetContent;
-(void) displayPhotoBrower:(NSMutableArray*) photoArray
                photoIndex:(NSInteger) photoIndex
              showGridView:(BOOL)showGridView;
-(void) backView;
-(void) showCellLoading:(NSString*) messageId
               progress:(CGFloat) progress;
-(void) hideCellLoading:(NSString*) messageId;
-(void) showButtonRetry:(NSString*) messageId;
-(void) hideButtonRetry:(NSString*) messageId;
-(void) handleSingleChatState:(NSDictionary *)userInfo;
-(void) stopAudioPlaying:(NSString*) messageID;
-(void) enableSaveMediaButton:(BOOL)isEnable;
-(void) sendBigMediaFileFailed:(NSInteger) limit;
-(void) handleAudioRecordWhileResetEmail;
@end

//NewGroupCreateDelegate
@protocol NewGroupCreateDelegate
@optional
- (void)didFailCreateGroup;
- (void)didSuccessCreateGroup:(NSString *)roomJid memberList:(NSString*)memberList;
- (void)didSuccessUploadGroipLogo:(NSString *)roomJid;
- (void)didFailUploadGroipLogo:(NSString *)roomJid;
@end

//ViewPhotoDelegate
@protocol ViewPhotoDelegate
@optional

- (void) showProfileImage:(UIImage *)profileImage;

@end

//CWindowDelegate
@protocol CWindowDelegate
@optional
-(void) showLoading:(NSString*) loadingContent;
-(void) hideLoading;
@end

//ContactListDelegate
@protocol ChatListDelegate
@optional
-(void) reloadChatList:(NSArray*) chatboxArray;
-(void) showChatView:(NSString*) chatBoxId;
-(void) reloadSearchChatList:(NSArray *)chatboxArray;
-(void) reloadComposeButton:(NSArray *) contactArray;
-(void) callChangeState;
-(void) doneLeaveChatBox:(NSString *)errString;

@end

//ContactListDelegate
@protocol ChatListEditDelegate
@optional
-(void) doneLeaveChatBox:(NSString *)errString;

@end

//ContactPopupDelegate
@protocol FindEmailContact
@optional
- (void)reloadEmailContactList:(NSArray *)contactArray;
- (void) buildEmailContactsData;
- (void) searchResult:(NSArray *)searchResult;
@end

//ContactPopupDelegate
@protocol ChatComposeDelegate
@optional
- (void)reloadComposeList:(NSArray *)contactArray;
- (void)reloadComposeSearchList:(NSArray *)contactArray;
-(void) callChangeState;
@end

//ContactPopupDelegate
@protocol NewGroupViewDelegate
@optional
- (void)reloadContactSearchList:(NSArray *)contactArray;
@end

//ContactPopupDelegate
@protocol ContactPopupDelegate
@optional
-(void) displayInfo;
@end

//ContactSearchMIDDelegate
@protocol ContactSearchMIDDelegate
@optional
-(void) showSearchResult:(NSDictionary*) searchResult;
-(void) refreshSearchResult;
-(void) failedSearchResult;
-(void) addFriendSuccess;
-(void) addFriendFailed;
-(void) approveFriendSuccess;
-(void) approveFriendFailed;
@end
//ContactHeaderDelegate
@protocol ContactHeaderDelegate
@optional
-(void) showNewRequest:(NSArray*) arrRequest;
-(void) hideNewRequest;
-(void) showPending:(NSArray*)arrPending;
-(void) hidePending;
@end

//ContactListDelegate
@protocol ContactListDelegate
@optional
-(void) reloadContactList:(NSArray*) contactArray;
-(void) reloadSearchContactList:(NSArray*) contactArray;
-(void) callChangeState;
-(void) addFriend;
@end

//ContactRequestDelegate
@protocol ContactRequestDelegate
@optional
-(void) displayRequest:(NSArray*) arrRequest;
-(void) backViewWhenNoRequest;
@end
//ContactPendingDelegate
@protocol ContactPendingDelegate
@optional
-(void) displayPending:(NSArray*) pendingList;
-(void) backViewWhenNoPending;
-(void) cancelFriendRequestFailed;
-(void) cancelFriendRequestSuccess;
-(void) resendFriendFailed;
-(void) resendFriendSuccess;
@end

//DisplaynameDelegate
@protocol DisplaynameDelegate
@optional
-(void) cancelDisplayNameView;
-(void) updateDisplayNameFailed;
-(void) showLoadingView;
@end

//StatusProfileDelegate
@protocol StatusProfileDelegate
@optional
-(void) cancelStatusView;
@end
//CheckMSISDNDelegate
@protocol CheckMSISDNDelegate
@optional
-(void) msisdnExisted:(NSString*)countrycode phoneNumber:(NSString*)phonenumber;
-(void) checkMSISDNSuccess:(NSString*)countrycode phoneNumber:(NSString*)phonenumber;
-(void) checkMSISDNFailed;
@end
//UpdateMSISDNDelegate
@protocol UpdateMSISDNDelegate
@optional
-(void) updateMSISDNSuccess:(NSString*)countrycode phoneNumber:(NSString*)phonenumber;
-(void) updateMSISDNFailed;
@end
//SendVerificationCodeDelegate
@protocol SendVerificationCodeDelegate
@optional
-(void) sendVerfificationCodeSuccess;
-(void) sendVerfificationCodeSuccessFailed;
@end
//SyncContactsDelegate
@protocol SyncContactsDelegate
@optional
-(void)showKeyboard;
-(void) setupPresentCountryData:(NSDictionary *) countryData;
@end

//GetStartedDelegate
@protocol GetStartedDelegate
@optional
-(void) getStartedSuccess;
-(void) getStartedFailed;
@end

//RegisterAccountDelegate
@protocol RegisterAccountDelegate
@optional
-(void) registerAccountSuccess;
-(void) registerAccountFailed;
@end

//SetPasswordDelegate
@protocol SetPasswordDelegate
@optional
-(void) setPasswordToServerSuccess;
-(void) setPasswordToServerFailed;
@end

//ChangePasswordDelegate
@protocol ChangePasswordDelegate
@optional
-(void) changePasswordToServerSuccess;
-(void) changePasswordToServerFailed;

@end

@protocol EnablePasswordLockDelegate
@optional
-(void) enablePasswordLockSuccess;
-(void) enablePasswordLockFailed;
@end

//UploadKeysDelegate
@protocol UploadKeysDelegate
@optional
-(void) uploadKeysToServerSuccess;
-(void) uploadKeysToServerFailed;
@end

//SignInAccountDelegate
@protocol SignInAccountDelegate
@optional
-(void) signInAccountSuccess;
-(void) signInAccountMaskingIDInvalid;
-(void) signInAccountNotFound;
-(void) signInAccountWrongPassword;
-(void) signInAccountFailed;
-(void) signInAccountBlocked;
-(void) serverMainternanceNotification:(NSString*)mainteranceMSG;
@end

//ContactBookDelegate
@protocol ContactBookDelegate
@optional
-(void) addKryptoFriendSuccess:(NSString*)friendJID;
-(void) addKryptoFriendFailed:(NSString*)friendJID;
-(void) updateContactInfoSuccess;
-(void) reloadSearchContactPhoneBook:(NSMutableDictionary*) allContactPhoneBook;
-(void) reloadSearchMemberContact:(NSArray*) arrResultMemberContact;
-(void) syncContactsSuccess;
-(void) syncContactsFailed;
-(void) callChangeState;
- (void) moveToNotSyncView;
@end

//ContactEditDelegate
@protocol ContactEditDelegate
@optional
-(void) deleteFriendSuccess;
-(void) deleteFriendFailed;
@end

//Email part
@protocol EmailLoginDelegate
@optional
-(void) loginEmailAccountSuccess;
-(void) loginEmailAccountFailedWithError:(NSError*)error;
-(void) updateEmailAccountToServerFailed:(NSString*)username;
-(void) resetEmailAccountSuccess;
-(void) resetEmailAccountFailed;
@end


//Email part
@protocol EmailInboxDelegate
@optional
-(void) callChangeState;
@end


@protocol EmailLoadMoreDelegate
@optional
-(void) loadNewEmailsSuccess;
-(void) loadMoreEmailsSuccess;
-(void) loadMoreEmailDetailSuccess:(NSString*)emailUID;
-(void) loadMoreEmailFailed;
-(void) changedEmailPassword;
-(void) disabledLessSecureApp;
-(void) showLoadingView;
-(void) moveToComposeWithEmail:(NSString*)emailContact;
-(void)syncScheduleGetNewEmails:(NSInteger)intTime;
-(void) removeEmailHeader:(NSString *)emailHeaderRemoveUID;
@end
//Email Detail delegate
@protocol EmailDetailDelegate
@optional
-(void) deleteEmailSuccess;
-(void) deleteEmailFailed;
- (void) showEmailAttachments;
- (void) getEmailDetailSucceeded;
- (void) getEmailDetailFailed:(NSString *)message;
@end

//New email folder delegate
@protocol CreateEmailFolderDelegate
@optional
- (void) createFolderSucceded;
- (void) showAlertDuplicateName;
@end
@protocol EmailSettingDelegate
@optional
-(void) deleteEmailAccountSuccess;
-(void) deleteEmailAccountFailed;
@end

@protocol EmailComposeDelegate
@optional
-(void) sendEmailSuccess;
-(void) sendEmailFailed:(NSString *)errorMessage;
-(void) updateTextFieldWithData:(NSMutableArray*)arrayContactSelect;
-(void) resendEmails;
- (void) buildReopenComposeViewData:(NSDictionary *)data;
@end

@protocol SideBarDelegate
@optional
-(void) reloadNotificationCount:(NSInteger)count MenuID:(NSInteger)menuID;
- (void) updateChatRowUnreadNumber;
- (void) updateEmailRowUnreadNumber:(NSInteger)numberNewEmail;
@end

@protocol AppSettingDelegate
@optional
-(void) updateNetworkStatus:(BOOL) isXMPPConnected;
-(void) reloadSettingsTable;
@end

@protocol BlockUsersDelegate
@optional
-(void) reloadBlockList:(NSArray*) blockArr;
-(void) synchronizeBlockListSuccess;
-(void) synchronizeBlockListFailed;
@end

@protocol UnblockUsersDelegate
@optional
-(void) reloadUnblockList:(NSArray*) unblockArr;
-(void) reloadUnblockUserSearchList:(NSArray*) unblockArray;
-(void) synchronizeBlockListSuccess;
-(void) synchronizeBlockListFailed;
@end

//SIPDelegate
@protocol SIPDelegate
@optional
-(void) linphoneCallState:(NSString*) callState message:(NSString*) message;
-(void) linphoneRegistrationState:(NSString*) registrationState;
-(void) linphoneTextReceivedEvent:(NSString*) textReceived;

-(void) linphoneCallEndOrError;
-(void) linphoneCallTimeOut;
-(void) linphoneCallBusy;
-(void) linphoneCallDeclined;
-(void) linphoneCallEnded;
-(void) linphoneCallOutgoingRinging;
-(void) linphoneCallStreamsRunning;
//-(void) linphoneCallIncomingReceived;
-(void) linphoneRegistrationSuccessful;
-(void) linphoneRegistrationFailed;
-(void) noInternetconnection;
-(void) incomingPhoneBookCall;

@end

@protocol VoiceCallViewDelegate
@optional
-(void) CallEnded;
@end

@protocol InitIncomingCallViewDelegate
@optional
-(void) linphoneCallIncomingReceived;
@end

///////////////////////

@protocol VerificationDelegate
@optional
-(void) syncContactsSuccess;
-(void) syncContactsFailed;
-(void) verifyOTPSuccess;
-(void) verifyOTPFail;
@end

//SocialDelegate
@protocol SocialDelegate
@optional
- (void)messageComposeViewController:(NSString *)message;
- (void)mailComposeController:(NSString *)message;
@end

//MyAccountInfoDelegate
@protocol  WebMyAccountDelegate
@optional
- (void)getDetailAccountSuccess;
- (void)getDetailAccountFail;
- (void) getTransactionHistorySuccess:(NSArray*)arrayOfTransaction;
- (void) getTransactionHistoryFail;
@end
@protocol BlockUsersCellDelegate
@optional
-(void) synchronizeBlockListSuccess;
-(void) synchronizeBlockListFailed;
@end
//MyProfileDelegate
@protocol MyProfileDelegate
@optional
-(void) updateAvatarSuccess;
-(void) updateAvatarFailed;
- (void) reloadTableData;
@end

//ContactNotSyncDelegate
@protocol ContactNotSyncDelegate
@optional

@end



















