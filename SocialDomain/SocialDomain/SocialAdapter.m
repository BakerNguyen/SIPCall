//
//  SocialAdapter.m
//  SocialDomain
//
//  Created by Ba (Baker) V. NGUYEN on 6/17/15.
//  Copyright (c) 2015 Ba (Baker) V. NGUYEN. All rights reserved.
//

#import "SocialAdapter.h"
#import <MessageUI/MessageUI.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>
#import <Social/Social.h>

@interface SocialAdapter() <MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate, FBSDKLoginButtonDelegate>
{
   
}
@end

@implementation SocialAdapter
@synthesize socialDomainDelegete;
@synthesize smsViewControler;

+ (SocialAdapter*) share{
    static dispatch_once_t once;
    static SocialAdapter * share;
    dispatch_once(&once, ^{
        share = [self new];
    });
    return share;
}

/*
 * Check can send SMS or not
 * @parameter is NSString
 * @author Baker
 */
- (BOOL) canSendSMS {
    if(![MFMessageComposeViewController canSendText]) {
        return NO;
    }
    return YES;
}

/*
 * send SMS
 * @parameter is NSString
 * @author Baker
 */
- (void)sendSMS:(NSString*)message viewController:(UIViewController*) viewController {
    if(![MFMessageComposeViewController canSendText]) {
        return;
    }
    
    //NSArray *recipents = @[@"12345678", @"72345524"];
    MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
    messageController.messageComposeDelegate = self;

    NSDictionary *navbarTitleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor blackColor] forKey:NSForegroundColorAttributeName];
    [messageController.navigationBar setTitleTextAttributes:navbarTitleTextAttributes];

    //[messageController setRecipients:recipents];
    [messageController setBody:message];    
    // Present message view controller on screen
    [viewController presentViewController:messageController animated:YES completion:nil];
}

/*
 * send message delegate
 * @parameter is NSString
 * @author Baker
 */
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult) result {
    switch (result) {
        case MessageComposeResultCancelled:
            [socialDomainDelegete messageComposeViewController:@"MessageComposeResultCancelled"];
            break;
        case MessageComposeResultFailed:
            [socialDomainDelegete messageComposeViewController:@"MessageComposeResultFailed"];
            break;
        case MessageComposeResultSent:
            [socialDomainDelegete messageComposeViewController:@"MessageComposeResultSent"];
            break;
        default:
            break;
    }
}

- (BOOL) canSendEmail {
    if (![MFMailComposeViewController canSendMail]) {
        return NO;
    }
    return YES;
}
- (void) sendEmail:(NSString*)title body:(NSString*)body viewController:(UIViewController*)viewController isHTML:(BOOL)isHTML{
    if (![MFMailComposeViewController canSendMail]) {
        return;
    }
    
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    NSDictionary *navbarTitleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor blackColor] forKey:NSForegroundColorAttributeName];
    [mc.navigationBar setTitleTextAttributes:navbarTitleTextAttributes];
        UIColor *defaultColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
    [mc.navigationBar setTintColor:defaultColor];
    [mc setSubject:title];
    [mc setMessageBody:body isHTML:isHTML];
    // Present mail view controller on screen
    [viewController presentViewController:mc animated:YES completion:nil];
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            [socialDomainDelegete mailComposeController:@"MFMailComposeResultCancelled"];
            break;
        case MFMailComposeResultSaved:
            [socialDomainDelegete mailComposeController:@"MFMailComposeResultSaved"];
            break;
        case MFMailComposeResultSent:
            [socialDomainDelegete mailComposeController:@"MFMailComposeResultSent"];
            break;
        case MFMailComposeResultFailed:
            [socialDomainDelegete mailComposeController:@"MFMailComposeResultFailed"];
            break;
        default:
            break;
    }
}

- (void) loginFaceBook {
    FBSDKLoginButton *loginButton = [[FBSDKLoginButton alloc] init];
    loginButton.delegate = self;
    loginButton.readPermissions = @[@"public_profile", @"email", @"user_friends"];
    [loginButton sendActionsForControlEvents:UIControlEventTouchUpInside];
}

- (BOOL) postToFacebookIfAlreadyLoginFBinSetting:(NSString*)message icon:(NSString*)iconName viewController:(UIViewController*) viewController {
    // Post to facebook if already login facebook in setting.
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        [controller setInitialText:message];
        [controller addImage:[UIImage imageNamed:iconName]];
        [viewController presentViewController:controller animated:YES completion:nil];
        return YES;
    }
    return NO;
}

- (BOOL) checkFacebookAppIsInstalled {
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"fb://"]]) {
        return YES;
    }
    return NO;
}

- (void) facebookShareLinkContent:(NSString*)title url:(NSString*)url imgLogo:(NSString*)logo description:(NSString*)description viewController:(UIViewController*)viewController {
    FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
    content.contentURL = [NSURL URLWithString:url];
    content.contentTitle = title;
    content.contentDescription = description;
    content.imageURL = [NSURL URLWithString:logo];
    [FBSDKShareDialog showFromViewController:viewController
                                 withContent:content
                                    delegate:nil];
}

- (BOOL) checkTwitterAccountIsAdded {
    // If Twitter account already add in setting.
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {        
        return YES;
    }
    return NO;
}

- (BOOL) postToTwitterIfAlreadyLoginInSetting:(NSString *)message icon:(NSString *)iconName viewController:(UIViewController *)viewController {
    // If Twitter account already add in setting.
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
        SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        [controller setInitialText:message];
        [controller addImage:[UIImage imageNamed:iconName]];
        [viewController presentViewController:controller animated:YES completion:nil];
        return YES;
    }
    return NO;
}

@end
