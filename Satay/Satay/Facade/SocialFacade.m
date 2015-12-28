//
//  SocialFacade.m
//  SocialDemo
//
//  Created by Ba (Baker) V. NGUYEN on 6/18/15.
//  Copyright (c) 2015 Ba (Baker) V. NGUYEN. All rights reserved.
//

#import "SocialFacade.h"

@implementation SocialFacade

@synthesize socialDelegate;
@synthesize showViewController;

+(SocialFacade *)share {
    static dispatch_once_t once;
    static SocialFacade * share;
    dispatch_once(&once, ^{
        share = [self new];
    });
    return share;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [SocialAdapter share].socialDomainDelegete = self;
    }
    
    return self;
}

- (BOOL) canSendSMS {
    return [[SocialAdapter share] canSendSMS];
}

- (void)sendSMS:(NSString*)message viewController:(UIViewController*) viewController {
    [[SocialAdapter share] sendSMS:message viewController:viewController];
}

- (void)messageComposeViewController:(NSString *)message {
    [socialDelegate messageComposeViewController:message];
    [showViewController dismissViewControllerAnimated:YES completion:^(){
        //[[CWindow share] setTintColor:[UIColor whiteColor]];
        [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
        
    }];
    
}

- (BOOL)canSendEmail {
    return [[SocialAdapter share] canSendEmail];
}

- (void)sendEmail:(NSString *)title body:(NSString *)body viewController:(UIViewController *)viewController isHTML:(BOOL)isHTML {
    [[SocialAdapter share] sendEmail:title body:body viewController:viewController isHTML:isHTML];
}

- (void)mailComposeController:(NSString *)message {
    [socialDelegate mailComposeController:message];
    [showViewController dismissViewControllerAnimated:YES completion:^(){
//        [[CWindow share] setTintColor:[UIColor whiteColor]];
        [[UINavigationBar appearance]setTintColor:[UIColor whiteColor]];

    }];
}

- (BOOL) checkFacebookAppIsInstalled {
    return [[SocialAdapter share] checkFacebookAppIsInstalled];
}

- (BOOL) postToFacebookIfAlreadyLoginFBinSetting:(NSString*)message icon:(NSString*)iconName viewController:(UIViewController*) viewController {
    return [[SocialAdapter share] postToFacebookIfAlreadyLoginFBinSetting:message icon:iconName viewController:viewController];
}

- (void) facebookShareLinkContent:(NSString*)title url:(NSString*)url imgLogo:(NSString*)logo description:(NSString*)description viewController:(UIViewController*)viewController {
    [[SocialAdapter share] facebookShareLinkContent:title url:url imgLogo:logo description:description viewController:viewController];
}

- (BOOL) checkTwitterAccountIsAdded {
    return [[SocialAdapter share] checkTwitterAccountIsAdded];
}

- (BOOL) postToTwitterIfAlreadyLoginInSetting:(NSString*)message icon:(NSString*)iconName viewController:(UIViewController*) viewController{
    return [[SocialAdapter share] postToTwitterIfAlreadyLoginInSetting:message icon:iconName viewController:viewController];
}

- (void) showActionSheet:(UIViewController*)viewController {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"SMS", @"Email", @"Twitter", nil];
    
    actionSheet.tag = 2001 ;
    [actionSheet showInView:viewController.view];
}


- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == 2001) {
        switch (buttonIndex) {
            case 0:
            {
                //SMS
                if ([[SocialFacade share] canSendSMS]) {
//                    NSDictionary *navbarTitleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
//                                                               [UIColor blueColor],NSForegroundColorAttributeName,
//                                                              nil];
//                    NSDictionary *navbarTitleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor yellowColor] forKey:NSForegroundColorAttributeName];
//                    
//                    [[UINavigationBar appearance] setTitleTextAttributes:navbarTitleTextAttributes];
                    [[SocialFacade share] sendSMS:[NSString stringWithFormat:SOCIAL_SMS, SOCIAL_URL, [[ContactFacade share] getMaskingId]] viewController:showViewController];
//                    [[CWindow share] setTintColor:[UIColor blueColor]];
//                    [[UINavigationBar appearance]setTintColor:[UIColor blueColor]];

                } else {
                    //UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:SOCIAL_ERROR_TITLE message:SOCIAL_SMS_ERROR delegate:nil cancelButtonTitle:SOCIAL_CANCEL_BUTTON_TEXT otherButtonTitles:nil];
                    //[warningAlert show];
                    [[CAlertView new] showError:SOCIAL_SMS_ERROR];
                }
                break;
            }
            case 1:
            {
                //Email
                if ([[SocialFacade share] canSendEmail]) {
                    //                    [[CWindow share] setTintColor:[UIColor blueColor]];
//                    [[UINavigationBar appearance]setTintColor:[UIColor blueColor]];
                    [[SocialFacade share] sendEmail:SOCIAL_EMAIL_TITLE body:[NSString stringWithFormat:SOCIAL_EMAIL_BODY, SOCIAL_URL] viewController:showViewController isHTML:NO];
                    
//                    [[CWindow share] setTintColor:[UIColor blueColor]];
//                    [[UINavigationBar appearance]setTintColor:[UIColor blueColor]];

                    
                } else {
                    //UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:SOCIAL_ERROR_TITLE message:SOCIAL_EMAIL_ERROR delegate:nil cancelButtonTitle:SOCIAL_CANCEL_BUTTON_TEXT otherButtonTitles:nil];
                    //[warningAlert show];
                    [[CAlertView new] showError:SOCIAL_EMAIL_ERROR];
                }
                break;
            }
                /* Daryl comment follow requirement at backlog 12465
            case 2:
            {
                //Facebook
                if ([[SocialFacade share] postToFacebookIfAlreadyLoginFBinSetting:[NSString stringWithFormat:SOCIAL_FACEBOOK, SOCIAL_URL] icon:SOCIAL_ICON viewController:showViewController]) {
                    break;
                }
                [[SocialFacade share] facebookShareLinkContent:SOCIAL_FACEBOOK_TITLE url:SOCIAL_URL imgLogo:SOCIAL_LOGO description:SOCIAL_FACEBOOK_DESCRIPTION viewController:showViewController];

                break;
            }
                 */
            case 2:
            {
                //Twitter
                if ([[SocialAdapter share] checkTwitterAccountIsAdded]) {
                    [[SocialFacade share] postToTwitterIfAlreadyLoginInSetting:[NSString stringWithFormat:SOCIAL_TWITTER, SOCIAL_URL] icon:@"" viewController:showViewController];
                } else {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=TWITTER"]];
                }
                break;
            }
            default:
                break;
        }
    }
}

@end
