//
//  SetUpEmail.h
//  Satay
//
//  Created by Arpana Sakpal on 3/3/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SetUpEmail : UIViewController<UITextFieldDelegate, UIScrollViewDelegate>


@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UITextField *txtFieldAccountName;
@property (strong, nonatomic) IBOutlet UITextField *txtFieldYourName;

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

@property NSInteger emailType;
@property (strong, nonatomic) NSString *emailAddress;
@property (strong, nonatomic) NSString *emailPassWord;
@property (strong, nonatomic) NSString *incommingHost;
@property (strong, nonatomic) NSString *incommingUserName;
@property (strong, nonatomic) NSString *incommingPassword;
@property NSInteger incommingPort;
@property (strong, nonatomic) NSString *outgoingHost;
@property (strong, nonatomic) NSString *outgoingUserName;
@property (strong, nonatomic) NSString *outgoingPassword;
@property NSInteger outgoingPort;
@property NSInteger delEmailFromServer;
@property NSInteger syncSchedule;

@property (strong, nonatomic) NSString *serverMicrosoft;
@property (strong, nonatomic) NSString *domainMicrosoft;
@property (strong, nonatomic) NSString *descriptionMicrosoft;

@end