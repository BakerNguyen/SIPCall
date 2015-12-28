//
//  LoginMicrosoftExchange.h
//  Satay
//
//  Created by Arpana Sakpal on 3/12/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginMicrosoftExchange :UIViewController<UIScrollViewDelegate, UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;

@property (strong, nonatomic) IBOutlet UITextField *txtFieldEmail;
@property (strong, nonatomic) IBOutlet UITextField *txtFieldServer;
@property (strong, nonatomic) IBOutlet UITextField *txtFieldDomain;
@property (strong, nonatomic) IBOutlet UITextField *txtFieldUsername;
@property (strong, nonatomic) IBOutlet UITextField *txtFieldPassword;
@property (strong, nonatomic) IBOutlet UITextField *txtFieldDescription;

@property (strong, nonatomic) NSString *strEmailAddress;
@property (strong, nonatomic) NSString *strEmailPassword;

@property (strong, nonatomic) CAlertView *alertView;

/**
 *  Initialize custom alertview
 *
 *  @param theCAlertView alertview
 *
 *  @return this view controller
 *  @author Arpana
 * date 20-Mar-2015
 */
-(id) initWithCAlertView:(CAlertView *)theCAlertView;
+(LoginMicrosoftExchange *)share;

@end
