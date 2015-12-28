//
//  CWindow.m
//  Satay
//
//  Created by TrungVN on 1/14/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import "CWindow.h"
#import "SideBar.h"
#import "ContactList.h"
#import "ChatList.h"
#import "NotificationController.h"
#import "SettingsViewController.h"
#import "SecNoteList.h"
#import "LogInFirstScreen.h"
#import "Tutorial.h"
#import "LogIn.h"
#import "PasscodeView.h"
#import "PaymentOption.h"
#import "MyProfile.h"
#import "SignUp.h"
#import "EmailLoginFirstView.h"
#import "EmailLoginOffice.h"
#import "EmailInbox.h"
#import "IncomingNotification.h"
#import "VoiceCallView.h"
#import "IncomingCallView.h"
#import "InitIncomingCallView.h"
#import "CallTimeOutView.h"
#import "DRNavigationController.h"

@implementation CWindow
@synthesize menuController;
@synthesize popupController;
@synthesize firstLaunch;

+(CWindow *)share{
    static dispatch_once_t once;
    static CWindow * share;
    dispatch_once(&once, ^{
        share = [[self alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        [share makeKeyAndVisible];
        share.backgroundColor = WINDOW_BG_COLOR;
        share.menuController = [JASidePanelController new];
        share.menuController.leftPanel = [SideBar share];
        share.menuController.centerPanel = [[DRNavigationController new] initWithRootViewController:[UIViewController new]];
        share.rootViewController = share.menuController;
        share.popupController = [DRNavigationController new];
        [share showApplication];
        share.menuController.leftGapPercentage = 265.5/share.width;
      
        [share addSubview:[IncomingNotification share]];       
        [AppFacade share].windowDelegate = share;
        [ChatFacade share].windowDelegate = share;
        
        //load view 1st.
        [[ContactList share] viewDidLoad];
        [[ChatList share] viewDidLoad];
        [[ChatView share] viewDidLoad];
        [[SettingsViewController share] viewDidLoad];
    });
    return share;
}

-(void)showContactList{
    menuController.centerPanel = [[DRNavigationController alloc] initWithRootViewController:[ContactList share]];
    [SideBar share].selectedIndex = 0;
    [[SideBar share].tblMenu reloadData];
}

-(void)showChatList{
    [[LogFacade share] createEventWithCategory:Contact_Category action:chatClick_Action label:labelAction];
    menuController.centerPanel = [[DRNavigationController alloc] initWithRootViewController:[ChatList share]];
    [SideBar share].selectedIndex = 1;
    [[SideBar share].tblMenu reloadData];
}

-(void)showMailBox
{
    [[LogFacade share] createEventWithCategory:Contact_Category action:emailClick_Action label:labelAction];
    [[LogFacade share] trackingScreen:Email_Category];
    menuController.centerPanel = [[DRNavigationController alloc]initWithRootViewController:[EmailInbox share]];
    [SideBar share].selectedIndex = 2;
    [[SideBar share].tblMenu reloadData];
}

-(void)showEmailLogin
{
    menuController.centerPanel=[[DRNavigationController alloc]initWithRootViewController:[EmailLoginFirstView share]];
    [SideBar share].selectedIndex = 2;
    [[SideBar share].tblMenu reloadData];
}

-(void)showSecureNote
{
    menuController.centerPanel = [[DRNavigationController alloc] initWithRootViewController:[SecNoteList share]];
    [SideBar share].selectedIndex = 3;
    [[SideBar share].tblMenu reloadData];
}

-(void)showNotification{
    menuController.centerPanel = [[DRNavigationController alloc] initWithRootViewController:[ NotificationController share]];
    [SideBar share].selectedIndex = 4;
    [[SideBar share].tblMenu reloadData];
}

-(void)showSetting
{
    menuController.centerPanel = [[DRNavigationController alloc] initWithRootViewController:[SettingsViewController share]];
    [SideBar share].selectedIndex = 5;
    [[SideBar share].tblMenu reloadData];
}

-(void) showPopup:(UIViewController *)rootViewController{
    [popupController setNavigationBarHidden:FALSE];
    [popupController setViewControllers:@[rootViewController] animated:NO];
    
    if (IS_OS_8_OR_LATER)
        [popupController setModalPresentationStyle:UIModalPresentationOverFullScreen];
    else
        self.rootViewController.modalPresentationStyle = UIModalPresentationCurrentContext;
    [self.rootViewController presentViewController:popupController animated:YES completion:nil];
}

-(void) showBrowser:(NSString*) url{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

-(void) showLoginFirstScreen{
    self.rootViewController = [[DRNavigationController alloc] initWithRootViewController:[LogInFirstScreen share]];
}

-(void) showTutorial{
     self.rootViewController = [Tutorial share];
}

-(void) showLoginScreen{
    self.rootViewController = [[DRNavigationController alloc] initWithRootViewController:[LogIn share]];
}

-(void) showPaymentOption{
    self.rootViewController =[[DRNavigationController alloc] initWithRootViewController:[PaymentOption share]];
}

-(void) showApplication{
    if(firstLaunch){
        self.rootViewController = menuController;
        [[ChatFacade share] countChatBoxList] > 0 ? [self showChatList] : [self showContactList];
        [[ContactFacade share] processAgainForFailedCases];
    }
    firstLaunch = NO;
}

-(void) showSyncContacts{
    self.rootViewController = [[DRNavigationController alloc] initWithRootViewController:[SyncContacts share]];
}

-(void) showSignUp{
    self.rootViewController = [[DRNavigationController alloc] initWithRootViewController:[SignUp share]];
}

-(void) showPasswordView:(NSInteger)viewType{
    [PasscodeView share].viewType = viewType;
    [self hidePopupWindow:NO];
    [self.rootViewController.view addSubview:[PasscodeView share].view];
    [[PasscodeView share] viewWillAppear:YES];
}

-(void) showLoading:(NSString*) loadingContent{
    for (UIWindow *window in [[UIApplication sharedApplication] windows]) {
        if(CGRectEqualToRect (window.frame, self.frame)){
            MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:window animated:YES];
            [self bringSubviewToFront:hud];
            [self endEditing:YES];
            if(loadingContent){
                hud.labelText = loadingContent;
            }
        }
    }
}

-(void) hideLoading{
    for (UIWindow *window in [[UIApplication sharedApplication] windows]) {
        [MBProgressHUD hideAllHUDsForView:window animated:YES];
    }
}

-(void) hidePopupWindow:(BOOL) animated{
    [self.rootViewController dismissViewControllerAnimated:animated completion:nil];
    if([menuController isKindOfClass:[JASidePanelController class]])
        [menuController showCenterPanelAnimated:YES];
}

-(void) showVoiceCallView {
    [self endEditing:YES];
    [self.rootViewController.view addSubview:[VoiceCallView share].view];
    [self hidePopupWindow:NO];
}

-(void) showIncomingCallView {
    [self endEditing:YES];
    [self.rootViewController.view addSubview:[IncomingCallView share].view];
    [self hidePopupWindow:NO];

}

-(void) showInitIncomingCallView {
    [self.rootViewController.view addSubview:[InitIncomingCallView share].view];
    [self hidePopupWindow:NO];

}

-(void) showCallTimeOutView {
    [self endEditing:YES];
    [self.rootViewController.view addSubview:[CallTimeOutView share].view];
    [self hidePopupWindow:NO];

}

-(void) showEmail:(NSString *)toAddress
            title:(NSString *)title
             body:(NSString *)body
  attacthmentData:(NSData *) attData
attacthmentDataType:(NSString *)type
attacthmentFileName:(NSString *)name
{
    MFMailComposeViewController *composer=[[MFMailComposeViewController alloc]init];
    [composer setMailComposeDelegate:self];
    NSDictionary *navbarTitleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor blackColor] forKey:NSForegroundColorAttributeName];
    [composer.navigationBar setTitleTextAttributes:navbarTitleTextAttributes];
    if ([MFMailComposeViewController canSendMail]) {
        
        [composer setToRecipients:[NSArray arrayWithObjects:toAddress,  nil]];
        [composer setSubject:title];
        
        [composer setMessageBody:body isHTML:NO];
        [composer setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
        if (attData.length > 0 && type.length >0 && name.length > 0) {
            [composer addAttachmentData:attData mimeType:type fileName:name];
        }
        [self.rootViewController  presentViewController:composer animated:YES completion:nil];
    }
    [self hideLoading];
    [SettingsViewController share].tblSettingMenu.userInteractionEnabled = YES;
}

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error
{
    switch (result) {
        case MFMailComposeResultSent:
        case MFMailComposeResultSaved:
            if ([[KeyChainSecurity getStringFromKey:IS_SEND_LOG] isEqualToString:@"YES"]) {
                [[LogFacade share] clearAllActivityLogs];
            }
        case MFMailComposeResultCancelled:
            [KeyChainSecurity storeString:@"NO" Key:IS_CRASH];
            [KeyChainSecurity storeString:@"NO" Key:IS_SEND_LOG];
            break;
            
        default:
            break;
    }
    [controller dismissViewControllerAnimated:YES completion:NULL];
}


@end
