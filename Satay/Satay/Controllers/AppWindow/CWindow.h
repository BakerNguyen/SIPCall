//
//  CWindow.h
//  Satay
//
//  Created by TrungVN on 1/14/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JASidePanelController.h"
#import <MessageUI/MessageUI.h>

@class DRNavigationController;
@interface CWindow : UIWindow <CWindowDelegate,MFMailComposeViewControllerDelegate>

+(CWindow *)share;

@property (nonatomic, retain) JASidePanelController* menuController;
@property (nonatomic, retain) DRNavigationController* popupController;

@property BOOL firstLaunch;

-(void) showContactList;
-(void) showChatList;
-(void) showMailBox;
-(void) showSecureNote;
-(void) showNotification;
-(void) showSetting;

-(void) showLoginFirstScreen;
-(void) showTutorial;
-(void) showLoginScreen;
-(void) showPaymentOption;
-(void) showSignUp;

-(void) showApplication;
-(void) showPasswordView:(NSInteger)viewType;

-(void) showMyProfile;
-(void) showSyncContacts;
-(void) showPopup:(UIViewController*) rootViewController;
-(void) showBrowser:(NSString*) url;
-(void) showLoading:(NSString*) loadingContent;
-(void) hideLoading;
-(void) hidePopupWindow:(BOOL) animated;

//Email
-(void)showEmailLogin;

//SIP
-(void) showVoiceCallView;
-(void) showIncomingCallView;
-(void) showInitIncomingCallView;
-(void) showCallTimeOutView;

//Send out email
-(void) showEmail:(NSString *)toAddress
            title:(NSString *)title
             body:(NSString *)body
  attacthmentData:(NSData *) attData
attacthmentDataType:(NSString *)type
attacthmentFileName:(NSString *)name;

@end
