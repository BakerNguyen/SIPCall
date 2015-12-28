//
//  EnablePasswordLock.m
//  Satay
//
//  Created by Vi (Violet) T.T. DAO on 5/11/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import "EnablePasswordLock.h"

@interface EnablePasswordLock ()

@end

@implementation EnablePasswordLock

@synthesize txtFieldConfirmPassword;
@synthesize txtFieldSetPassword;

+(EnablePasswordLock *)share{
    static dispatch_once_t once;
    static EnablePasswordLock * share;
    dispatch_once(&once, ^{
        share = [self new];
    });
    return share;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.txtFieldSetPassword.delegate = self;
    self.txtFieldConfirmPassword.delegate = self;
    [ContactFacade share].enablePasswordLockDelegate = self;
    
    self.title = TITLE_SETUP_PROFILE;
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem createRightButtonTitle:_DONE Target:self Action:@selector(doneView)];
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem createLeftButtonTitle:_BACK Target:self Action:@selector(backView)];
    
    self.navigationItem.rightBarButtonItem.enabled = NO;
    self.view.backgroundColor = COLOR_230230230;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self resetView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark Interact UI
-(void) doneView{
    if([txtFieldSetPassword.text isEqual:txtFieldConfirmPassword.text]){
        [[AppFacade share] setPasswordLockFlag:IS_YES];
        [[ContactFacade share] updatePasscodeAndMasterKeyLocal:txtFieldSetPassword.text withType:UploadPasswordForEnablePswLock];
        [[ContactFacade share] updatePasscodeToServerwithType:UploadPasswordForEnablePswLock
                                              retryUploadTime:[kRETRY_API_COUNTER intValue]];
    }
    else{
        [[CAlertView new] showError:mError_PasswordNotMatch];
    }
    
    [self resetView];
}

-(void)backView{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)resetView{
    txtFieldSetPassword.text = txtFieldConfirmPassword.text = @"";
    self.navigationItem.rightBarButtonItem.enabled = NO;
    [txtFieldSetPassword becomeFirstResponder];
}

#pragma mark UITextfield delegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSString *actualText = [textField.text stringByReplacingCharactersInRange:range withString:string];

    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    if(actualText.length > 5){
        if((textField == txtFieldSetPassword && txtFieldConfirmPassword.text.length > 5)
           ||(textField == txtFieldConfirmPassword && txtFieldSetPassword.text.length > 5))
            self.navigationItem.rightBarButtonItem.enabled = YES;
    }
    
    return (actualText.length <= CHARACTER_LIMIT_PASSWORD);
}

#pragma mark EnablePasswordLock delegate
-(void) enablePasswordLockSuccess{
    NSLog(@"enable Password lock Success");
     [KeyChainSecurity storeString:IS_NO Key:kREUPLOAD_PASSWORD];
    [self backView];
}

-(void) enablePasswordLockFailed{
    NSString* stringKey = [NSString stringWithFormat:@"%@-%d",IS_YES,UploadPasswordForEnablePswLock];
    [KeyChainSecurity storeString:stringKey Key:kREUPLOAD_PASSWORD];
    NSLog(@"Update passcode offline, will try to recall it after online");
    [self backView];
}


@end
