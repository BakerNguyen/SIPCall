//
//  EmailSettingMicrosoft.h
//  Satay
//
//  Created by Arpana Sakpal on 3/11/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EmailSettingMicrosoft : UIViewController<UIScrollViewDelegate, UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UITextField *txtFieldEmail;
@property (strong, nonatomic) IBOutlet UITextField *txtFieldServer;
@property (strong, nonatomic) IBOutlet UITextField *txtFieldDomain;
@property (strong, nonatomic) IBOutlet UITextField *txtFieldUsername;
@property (strong, nonatomic) IBOutlet UITextField *txtFieldPassword;
@property (strong, nonatomic) IBOutlet UITextField *txtFieldDescription;

@property (strong, nonatomic) IBOutlet UIButton *btnDeleteAccount;

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

/**
 *  Action click button delete accoutn
 *
 *  @param sender button delete
 *  @author Arpana
 */
- (IBAction)clickedBtnDeleteAccount:(id)sender;

/**
 *  Action click button advance
 *
 *  @param sender button advance
 *  @author Arpana
 */
- (IBAction)clickedBtnAdvance:(id)sender;

@end