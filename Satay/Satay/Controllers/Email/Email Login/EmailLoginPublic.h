//
//  EmailLoginPublic.h
//  Satay
//
//  Created by Arpana Sakpal on 3/10/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EmailLoginPublic : UIViewController<UITextFieldDelegate>


@property int emailAccountType;

@property (strong, nonatomic) IBOutlet UITextField *txtFieldUserName;
@property (strong, nonatomic) IBOutlet UITextField *txtFieldPassword;
@property (strong, nonatomic) IBOutlet UILabel *lblShowPassword;

/**
 *  Action click on button show password
 *
 *  @param sender button show password
 *  @author Arpana
 *  Date 25-Mar-2015
 */
- (IBAction)clickedBtnShowPassword:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *btnShowPassword;

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
@end
