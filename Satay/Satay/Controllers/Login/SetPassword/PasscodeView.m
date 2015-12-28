//
//  SetPassword.m
//  Satay
//
//  Created by enclave on 1/27/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import "PasscodeView.h"
#import "CWindow.h"
#import "Interface.h"

@implementation PasscodeView{
    NSString *newPasscodeTemp;
}

@synthesize btnOk, btnClose;
@synthesize lblTitle,txtPasscode;
@synthesize appIcon;
@synthesize viewType;
@synthesize firstPasscode;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [ContactFacade share].changePasswordDelegate = self;
    
    appIcon.layer.cornerRadius = 5;
    txtPasscode.layer.borderWidth = 0;
    [txtPasscode setValue:[UIColor blackColor] forKeyPath:@"_placeholderLabel.textColor"];
    [txtPasscode becomeFirstResponder];
    [[UITextField appearance] setTintColor:[UIColor blackColor]];
    
    CALayer* leftBorder = [CALayer new];
    CALayer* rightBorder = [CALayer new];
    [leftBorder setFrame:CGRectMake(0, txtPasscode.height-4, 1, 4)];
    [rightBorder setFrame:CGRectMake(txtPasscode.width-1, txtPasscode.height-4, 1, 4)];
    
    leftBorder.backgroundColor = rightBorder.backgroundColor = [UIColor blackColor].CGColor;
    
    [txtPasscode.layer addSublayer:leftBorder];
    [txtPasscode.layer addSublayer:rightBorder];
}

-(void) viewWillAppear:(BOOL)animated{
    [self resetPasscodeView];
    [self.view changeWidth:self.view.superview.width Height:self.view.superview.height];
    
    [btnOk removeTarget:nil action:nil forControlEvents:UIControlEventAllEvents];
    switch (viewType) {
        case LockAccess:{
            btnClose.hidden = TRUE;
            lblTitle.text = TITLE_LOGIN;
            [btnOk addTarget:self action:@selector(accessApplication) forControlEvents:UIControlEventTouchUpInside];
        }
            break;
        case LockPasswordLock:{
            btnClose.hidden = FALSE;
            lblTitle.text = LABEL_CURRENT_PASSWORD;
            [btnOk addTarget:self action:@selector(offPasswordLock) forControlEvents:UIControlEventTouchUpInside];
        }
            break;
        case LockChangePasscode:{
            btnOk.tag = 1;
            btnClose.hidden = FALSE;
            lblTitle.text = LABEL_CURRENT_PASSWORD;
            [btnOk addTarget:self action:@selector(changePasscode) forControlEvents:UIControlEventTouchUpInside];
        }
            break;
        default:
            break;
    }
    
    [txtPasscode becomeFirstResponder];
}

#pragma mark Off password lock

-(void) offPasswordLock{
    if([[ContactFacade share] comparePasscode:txtPasscode.text]){
        [[AppFacade share] removeCountWrongPasswordKey];
        [[AppFacade share] setPasswordLockFlag:IS_NO];
        [self closeView:btnClose];
        [[LogFacade share] createEventWithCategory:Setting_Category action:passcodeLockOff_Action label:@"Off"];
    }
    else{
        [self showAlertCountWrongPassword];
    }
    
    [self resetPasscodeView];
}

#pragma mark [Setting] Change password function

-(void) changePasscode{
    switch (btnOk.tag) {
        case 1:
            if([[ContactFacade share] comparePasscode:txtPasscode.text]){
                btnOk.tag = 2;
                lblTitle.text = LABEL_ENTER_NEW_PASSWORD;
                [[AppFacade share] removeCountWrongPasswordKey];
            }else{
                [self showAlertCountWrongPassword];
            }
            break;
            
        case 2:
            btnOk.tag = 3;
            lblTitle.text = LABEL_CONFIRM_NEW_PASSWORD;
            newPasscodeTemp = txtPasscode.text;
            break;
            
        case 3:
            if([newPasscodeTemp isEqual:txtPasscode.text]){
                [[ContactFacade share] updatePasscodeAndMasterKeyLocal:txtPasscode.text withType:UploadPasswordForChangePsw];
                [[ContactFacade share] updatePasscodeToServerwithType:UploadPasswordForChangePsw
                                                      retryUploadTime:[kRETRY_API_COUNTER intValue]];
                return;
            }else{
                CAlertView *alert = [CAlertView new];
                [alert showError:mError_PasswordNotMatch];
                [alert setOnButtonTouchUpInside:^(CAlertView *alertView, int buttonIndex){
                    btnOk.tag = 2;
                    lblTitle.text = LABEL_ENTER_NEW_PASSWORD;
                }];
            }
            break;
            
        default:
            break;
    }
    
    [self resetPasscodeView];
}

#pragma mark Access Application

-(void) accessApplication{
    if([[ContactFacade share] comparePasscode:txtPasscode.text]){
        [[AppFacade share] removeCountWrongPasswordKey];
        [txtPasscode resignFirstResponder];
        if (!([[ContactFacade share] getReloginFlag] && ![[ContactFacade share] getFreeTrialedFlag]))//No connect xmpp if not finish re-login flow
            [[XMPPFacade share] connectXMPP];
        [[ContactFacade share] showKeyboardSyncContactView];
        [[AppFacade share] callReUploadPasscodeToServer];
        [self.view removeFromSuperview];
    }
    else{
        [self showAlertCountWrongPassword];
        [self resetPasscodeView];
    }
}

- (void)showAlertCountWrongPassword
{
    NSLog(@"Alert wrong password and count 10 times here.");
    int coungWrongPassword = [[[AppFacade share] getCountWrongPasswordKey] intValue] + 1;
    [[AppFacade share] setCountWrongPasswordKey:[NSString stringWithFormat:@"%d", coungWrongPassword]];
    
    if(coungWrongPassword == 10){
        CAlertView *alert = [CAlertView new];
        [alert showError:mError_WrongPasswordTenTimes];
        [alert setOnButtonTouchUpInside:^(CAlertView *alertView, int buttonIndex){
            [self.view removeFromSuperview];
            [[ContactFacade share] resetAccount];
        }];
    }else if(coungWrongPassword == 5){
        [[CAlertView new] showError:[NSString stringWithFormat:mError_WrongPasswordFiveTimes, coungWrongPassword, coungWrongPassword]];
    }else{
        [[CAlertView new] showError:mError_WrongCurrentPassword];
    }
}

#pragma mark Support methods

-(void) resetPasscodeView{
    txtPasscode.text = @"";
    [btnOk setTitleColor:COLOR_128128128 forState:UIControlStateNormal];
    btnOk.layer.borderColor = COLOR_128128128.CGColor;
    btnOk.enabled = NO;
}

#pragma mark Interact UI

- (IBAction)closeView:(id)sender {
    [self.view removeFromSuperview];
    [[AppFacade share] reloadSettingViewController];
}

#pragma mark UITextField delegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    // only allow number.
    NSString *validRegEx =@"^[0-9]*$";
    
    if (![[AppFacade share] checkString:string withRegularExpression:validRegEx]) {
        return NO;
    }
    
    if (textField != txtPasscode)
        return YES;
    
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    if(newLength > 5)
    {
        [btnOk setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        btnOk.layer.borderColor = [UIColor blackColor].CGColor;
        btnOk.enabled = YES;
    }
    else
    {
        [btnOk setTitleColor:COLOR_128128128 forState:UIControlStateNormal];
        btnOk.layer.borderColor = COLOR_128128128.CGColor;
        btnOk.enabled = NO;
    }
    
    return ((newLength <= CHARACTER_LIMIT_PASSWORD));
}

#pragma mark Change password Delegate

-(void) changePasswordToServerSuccess{
    // Don't need to call reupload if upload successful
    [KeyChainSecurity storeString:IS_NO Key:kREUPLOAD_PASSWORD];
    NSLog(@"change Password To Server Success");
    viewType = LockAccess;
    [[CWindow share] hideLoading];
    [self closeView:btnClose];
}

-(void) changePasswordToServerFailed{
    NSLog(@"Update passcode failed with many reason, will try 5 times here.");
    NSString* stringKey = [NSString stringWithFormat:@"%@-%d",IS_YES,UploadPasswordForChangePsw];
    [KeyChainSecurity storeString:stringKey Key:kREUPLOAD_PASSWORD];
    [[CWindow share] hideLoading];
    [self closeView:btnClose];
}

+(PasscodeView *)share{
    static dispatch_once_t once;
    static PasscodeView * share;
    dispatch_once(&once, ^{
        share = [self new];
    });
    return share;
}

@end
