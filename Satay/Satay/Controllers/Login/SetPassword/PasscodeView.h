//
//  SetPassword.h
//  Satay
//
//  Created by enclave on 1/27/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PasscodeView : UIViewController<UITextFieldDelegate,UIAlertViewDelegate, AppSettingDelegate>

@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UITextField *txtPasscode;
@property (weak, nonatomic) IBOutlet UIButton *btnOk;
@property (strong, nonatomic) IBOutlet UIButton *btnClose;
@property (nonatomic, retain) IBOutlet UIImageView* appIcon;

@property NSInteger viewType;
@property (nonatomic, retain) NSString* firstPasscode;

+(PasscodeView *)share;

-(void) setPasscode;
-(void) changePasscode;
-(void) accessApplication;

-(void) resetPasscodeView;

-(void) changePasswordToServerSuccess;
-(void) changePasswordToServerFailed;

- (IBAction)closeView:(id)sender;

@end
