//
//  EmailSettingPopImaViewController.h
//  Satay
//
//  Created by Arpana Sakpal on 3/11/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EmailSettingPopImap : UIViewController<UITextFieldDelegate, UIScrollViewDelegate>
@property (strong, nonatomic) NSString *emailAddress;
@property (strong, nonatomic) NSString *passWord;
@property (strong, nonatomic) CAlertView *alertView;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;

@property (strong, nonatomic) IBOutlet UITextField *txtFieldEmail;
@property (strong, nonatomic) IBOutlet UITextField *txtFieldIncomeHostName;
@property (strong, nonatomic) IBOutlet UITextField *txtFieldIncomeUserName;
@property (strong, nonatomic) IBOutlet UITextField *txtFieldIncomePassword;
@property (strong, nonatomic) IBOutlet UITextField *txtFieldIncomeServerPort;
@property (strong, nonatomic) IBOutlet UITextField *txtFieldOutgoHostName;
@property (strong, nonatomic) IBOutlet UITextField *txtFieldOutgoUserName;
@property (strong, nonatomic) IBOutlet UITextField *txtFieldOutgoPassword;
@property (strong, nonatomic) IBOutlet UITextField *txtFieldOutgoServerPort;

@property (strong, nonatomic) IBOutlet UIButton *btnDeleteAccount;

/**
 *  Action click button advance
 *
 *  @param sender button advance
 *  @author Arpana
 */
- (IBAction)clickedBtnAdvanced:(id)sender;

/**
 *  Action click button delete accoutn
 *
 *  @param sender button delete
 *  @author Arpana
 */
- (IBAction)clickedBtnDelete:(id)sender;

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

@end
