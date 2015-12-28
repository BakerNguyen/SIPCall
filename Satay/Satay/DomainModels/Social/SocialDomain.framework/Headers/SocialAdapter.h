//
//  SocialAdapter.h
//  SocialDomain
//
//  Created by Ba (Baker) V. NGUYEN on 6/17/15.
//  Copyright (c) 2015 Ba (Baker) V. NGUYEN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol SocialDomainDelegete
@optional
- (void)messageComposeViewController:(NSString*) message;
- (void)mailComposeController:(NSString*)message;
@end


@interface SocialAdapter : NSObject
{
    NSObject <SocialDomainDelegete> *socialDomainDelegete;
}
@property (nonatomic, retain) NSObject* socialDomainDelegete;
@property (nonatomic, retain) UIViewController *smsViewControler;

+ (SocialAdapter*) share;
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
 * login facebook
 * @parameter is NSString
 * @author Baker
 */
- (void) loginFaceBook;

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


@end
