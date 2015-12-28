//
//  EmailSettingNormal.h
//  Satay
//
//  Created by Arpana Sakpal on 3/12/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EmailSettingNormal : UIViewController<UITextFieldDelegate>
@property (strong, nonatomic) CAlertView *alertView;

@property (strong, nonatomic) NSString *emailAddress;
@property (strong, nonatomic) NSString *passWord;

@property (strong, nonatomic) IBOutlet UILabel *lblEmailAddress;
@property (strong, nonatomic) IBOutlet UITextField *txtFielPassword;
@property (strong, nonatomic) IBOutlet UIButton *btnDeleteAccount;

/**
 *  Action click button delete accoutn
 *
 *  @param sender button delete
 *  @author Arpana
 */
- (IBAction)clickedBtnDelete:(id)sender;

/**
 *  Action click button advance
 *
 *  @param sender button advance
 *  @author Arpana
 */
- (IBAction)clickBtnAdvanced:(id)sender;

-(id) initWithCAlertView:(CAlertView *)theCAlertView;


@end
