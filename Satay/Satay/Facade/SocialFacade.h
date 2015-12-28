//
//  SocialFacade.h
//  SocialDemo
//
//  Created by Ba (Baker) V. NGUYEN on 6/18/15.
//  Copyright (c) 2015 Ba (Baker) V. NGUYEN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SocialDomain/SocialDomain.h>
#import "UIDelegate.h"

@interface SocialFacade : NSObject <SocialDomainDelegete, UIActionSheetDelegate> {
    NSObject <SocialDelegate> *socialDelegate;
}

@property (nonatomic, retain) NSObject *socialDelegate;
@property (nonatomic, retain) UIViewController* showViewController;

+(SocialFacade *)share;

/*
 * Check can send SMS or not
 * @parameter is NSString
 * @author Baker
 */
- (BOOL) canSendSMS;

/*
 * send SMS
 * @parameter is NSString
 * @author Baker
 */
- (void)sendSMS:(NSString*)message viewController:(UIViewController*) viewController;

/*
 * Check can send Email or not
 * @parameter is NSString
 * @author Baker
 */
- (BOOL) canSendEmail;

/*
 * send Email
 * @parameter is NSString
 * @author Baker
 */
- (void) sendEmail:(NSString*)title body:(NSString*)body viewController:(UIViewController*)viewController isHTML:(BOOL)isHTML;

/*
 * post to facebook if facebook app already installed in Setting
 * @parameter is NSString
 * @author Baker
 */
- (BOOL) postToFacebookIfAlreadyLoginFBinSetting:(NSString*)message icon:(NSString*)iconName viewController:(UIViewController*) viewController;

/*
 * Check facebook is installed or not
 * @parameter is NSString
 * @author Baker
 */
- (BOOL) checkFacebookAppIsInstalled;

/*
 * post to facebook if facebook app already installed in Setting
 * @parameter is NSString
 * @author Baker
 */
- (void) facebookShareLinkContent:(NSString*)title url:(NSString*)url imgLogo:(NSString*)logo description:(NSString*)description viewController:(UIViewController*)viewController;

/*
 * Check twitter account is already added in setting
 * @parameter is NSString
 * @author Baker
 */
- (BOOL) checkTwitterAccountIsAdded;

/*
 * post to facebook if facebook app already installed in Setting
 * @parameter is NSString
 * @author Baker
 */
- (BOOL) postToTwitterIfAlreadyLoginInSetting:(NSString*)message icon:(NSString*)iconName viewController:(UIViewController*) viewController;

/*
 * Show action sheet
 * @parameter is NSString
 * @author Baker
 */
- (void) showActionSheet:(UIViewController*)viewController;

@end
