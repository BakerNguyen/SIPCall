//
//  SignUp.m
//  KryptoChat
//
//  Created by enclave on 2/10/15.
//  Copyright (c) 2015 mTouche. All rights reserved.
//

#import "SignUp.h"
#import "LogInFirstScreen.h"
#import "ContactBook.h"
@interface SignUp (){



}

@end

@implementation SignUp

@synthesize txtFieldSetPassword, txtFieldConfirmPassword, txtFieldDisplayName;
@synthesize labelKryptoID, labelHintKryptoID;
@synthesize scrollView;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    txtFieldSetPassword.delegate = self;
    txtFieldConfirmPassword.delegate = self;
    txtFieldDisplayName.delegate = self;
    
    self.navigationItem.title = TITLE_SETUP_PROFILE;
    //self.navigationItem.leftBarButtonItem = [UIBarButtonItem createLeftButtonTitle:_CANCEL Target:self Action:@selector(backToGetStated)];
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem createRightButtonTitle:_DONE Target:self Action:@selector(checkPassword)];
    

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];

    // Do any additional setup after loading the view from its nib.
    
    scrollView.scrollEnabled = YES;
    [scrollView setContentSize:CGSizeMake(320, 650)];
    [self.view addSubview:scrollView];
    
    [ContactFacade share].setPasswordDelegate = self;
    [ContactFacade share].uploadKeysDelegate = self;
    self.navigationItem.rightBarButtonItem.enabled=NO; // arpana added this to resolve bug 8939
}

-(void)dismissKeyboard {
    [self.view endEditing:YES];
}

- (void) viewWillAppear:(BOOL)animated{
    [txtFieldSetPassword becomeFirstResponder];

    NSLog(@"Masking id %@", [[ContactFacade share] getMaskingId]);
    labelKryptoID.text = [NSString stringWithFormat:@"%@ %@",LABEL_KRYPTO_ID, [[ContactFacade share] getMaskingId]];
}

- (void)viewDidAppear:(BOOL)animated{
    [txtFieldSetPassword becomeFirstResponder];
}

+(SignUp *)share{
    static dispatch_once_t once;
    static SignUp * share;
    dispatch_once(&once, ^{
        share = [self new];
    });
    return share;
}

- (void) signUpAccount {
    [[ContactFacade share] updatePasscodeAndMasterKeyLocal:txtFieldConfirmPassword.text withType:UploadPasswordForRegister];
    [[ContactFacade share] updatePasscodeToServerwithType:UploadPasswordForRegister
                                          retryUploadTime:[kRETRY_API_COUNTER intValue]];

}

-(void) setPasswordToServerSuccess{
    [[ContactFacade share] setTermAndConditionFlag:IS_YES];
    //Upload key to server
    [[ContactFacade share] uploadKeysToServer];
}

-(void) setPasswordToServerFailed{
    [[CAlertView new] showError:ERROR_SET_PASS_KEY_TO_SERVER];
}

-(void) uploadKeysToServerSuccess{
    if (![[txtFieldDisplayName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]) {
        NSString *displayname = [Base64Security generateBase64String:txtFieldDisplayName.text];
        [[ContactFacade share] updateDisplayName:displayname];
    }
    if ([[ContactFacade share] getMSISDN].length > 0 && [[ContactFacade share] getSyncContactFlag]) {
        NSOperationQueue *mainQueue = [NSOperationQueue mainQueue];
        [mainQueue addOperationWithBlock:^{
            [self.navigationController pushViewController:[ContactBook share] animated:YES];
        }];
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        [queue addOperationWithBlock:^{
            [[ContactBook share] getDataForDisplaying];
        }];
    }
    else if([[ContactFacade share] getMSISDN].length == 0 && ![[ContactFacade share] getSyncContactFlag]){
        [[CWindow share] showApplication];
    }
   
    [[ContactBook share].tblMemberPhoneBook reloadData];
}
-(void) uploadKeysToServerFailed{
    [[CAlertView new] showError:ERROR_UPLOAD_KEY_TO_SERVER];
}


- (void)checkPassword{
    [self dismissKeyboard];
    if ([txtFieldSetPassword.text isEqualToString:txtFieldConfirmPassword.text])
        [self displayTermsAndConditionsAlert];
    else{
        CAlertView* alertView = [CAlertView new];
        [alertView showError:ERROR_PASSCODE_DOES_NOT_MATCH];
        [alertView setOnButtonTouchUpInside:^(CAlertView *alertView, int buttonIndex) {
        }];
    }
}


-(void)displayTermsAndConditionsAlert{
    CAlertView* showTNC = [CAlertView new];
    NSMutableArray *buttonsName  = [NSMutableArray arrayWithObjects:ALERT_BUTTON_CANCEL,ALERT_BUTTON_I_ACCEPT, nil];
    
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 260, 210)];
    contentView.backgroundColor = [UIColor clearColor];
    
    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(20, 50, 220, 30)];
    label1.textColor = [UIColor blackColor];
    [label1 setFont:[UIFont systemFontOfSize:14]];
    label1.textAlignment = NSTextAlignmentCenter;
    label1.text = TO_USE_ONE_KRYPTO_ON_THIS_DEVICE;
    [contentView addSubview:label1];
    
    UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(20, 70, 220, 30)];
    label2.textColor = [UIColor blackColor];
    [label2 setFont:[UIFont systemFontOfSize:14]];
    label2.textAlignment = NSTextAlignmentCenter;
    label2.text = YOU_MUST_ACCEPT_THE_NEW;
    [contentView addSubview:label2];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(59, 90, 150, 30)];
    [button addTarget:self action:@selector(switchToTNCView) forControlEvents:UIControlEventTouchUpInside];
    NSMutableAttributedString *commentString = [[NSMutableAttributedString alloc] initWithString:TERM_AND_CONDITIONS];
    [commentString addAttribute:NSUnderlineStyleAttributeName
                          value:[NSNumber numberWithInteger:NSUnderlineStyleSingle]
                          range:NSMakeRange(0, [commentString length] -1)];
    [button setAttributedTitle:commentString forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [button.titleLabel setTextColor:[UIColor blueColor]];
    [contentView addSubview:button];
    
    UILabel *label3 = [[UILabel alloc] initWithFrame:CGRectMake(20, 120, 220, 80)];
    label3.textColor = [UIColor blackColor];
    [label3 setFont:[UIFont systemFontOfSize:13]];
    label3.textAlignment = NSTextAlignmentCenter;
    label3.text = THIS_APP_WILL_GATHER;
    label3.numberOfLines = 0;
    [contentView addSubview:label3];
    
    showTNC.containerView = contentView;
    [showTNC showInfo_2btn:nil ButtonsName:buttonsName];
    
    [showTNC setOnButtonTouchUpInside:^(CAlertView *alertView, int buttonIndex)
     {
         if(buttonIndex == 1)
             [self signUpAccount];
         else
             [[ContactFacade share] setTermAndConditionFlag:IS_NO];
     }];
    
    [self.view endEditing:YES];
}

- (void)switchToTNCView
{
    [[CWindow share] showBrowser:URL_TERMS_CONDITIONS];
}



- (void) backToGetStated {
    [[CWindow share] showLoginFirstScreen];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    if(textField == txtFieldDisplayName)
    {
        if (newLength > MAX_LENGHT_TEXT_NAME && newLength < UINT32_MAX){
            [[CAlertView new] showError:mERROR_DISPLAYNAME_CANNOT_EXCEED_MORE_THEN_20WORDS];
            return NO; // return NO to not change text
        }else
            return YES;
    }
    
    // only allow number.
    if (![[AppFacade share] checkString:string withRegularExpression:@"^[0-9]*$"])
        return NO;
    
    NSString* newString = [NSString stringWithFormat:@"%@%@",txtFieldSetPassword.text,string];
    if (newString.length == 0)
        return YES;
    
    if (newLength > 5) {
        // if both password and confirm password is not empty and length > 5,
        // then enable Done button.
        
        BOOL isCellPassEmpty = [[txtFieldSetPassword.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""] ;
        BOOL isConfirmPassEmpty = [[txtFieldConfirmPassword.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""] ;
        if (!isCellPassEmpty && !isConfirmPassEmpty)
            self.navigationItem.rightBarButtonItem.enabled = YES;
        else
            self.navigationItem.rightBarButtonItem.enabled = NO;
    }
    else{
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
    return ((newLength <= MAX_LENGHT_TEXT_16));
}

@end
