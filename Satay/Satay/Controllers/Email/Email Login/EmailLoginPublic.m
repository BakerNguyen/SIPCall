//
//  EmailLoginPublic.m
//  Satay
//
//  Created by Arpana Sakpal on 3/10/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import "EmailLoginPublic.h"
#import "LoginMicrosoftExchange.h"
#import "EmailLoginOffice.h"
#import "BackgroundTask.h"

@interface EmailLoginPublic ()

@end

@implementation EmailLoginPublic
@synthesize emailAccountType;
@synthesize lblShowPassword;
@synthesize btnShowPassword;
@synthesize txtFieldPassword,txtFieldUserName;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}


+(LoginMicrosoftExchange *)share{
    
    static dispatch_once_t once;
    static LoginMicrosoftExchange * share;
    dispatch_once(&once, ^{
        share = [[self alloc] init];
    });
    return share;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title=[ self EmailTypeTitle ];
    self.navigationItem.rightBarButtonItem=[UIBarButtonItem createRightButtonTitle:_NEXT Target:self Action:@selector(nextView)];
    self.navigationItem.leftBarButtonItem=[UIBarButtonItem createLeftButtonTitle:_CANCEL Target:self Action:@selector(cancelThisView)];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    
    btnShowPassword.layer.cornerRadius = btnShowPassword.width / 2;
    btnShowPassword.layer.borderWidth = 1.0;
    btnShowPassword.layer.borderColor = [UIColor darkGrayColor].CGColor;
    [btnShowPassword setImage:nil forState:UIControlStateNormal];


    [txtFieldUserName setReturnKeyType:UIReturnKeyNext];
    [txtFieldPassword setReturnKeyType:UIReturnKeyGo];
    txtFieldPassword.delegate = self;
    txtFieldUserName.delegate = self;
    //color for  disabled status of uibarbutton
    
    [EmailFacade share].emailLoginDelegate = self;

}

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    [txtFieldUserName becomeFirstResponder];
    
    switch (emailAccountType)
    {
        case 0:
            txtFieldUserName.text = @"@example.onmicrosoft.com";
            break;
        case 1:
            txtFieldUserName.text = @"@gmail.com";
            break;
        case 2:
            txtFieldUserName.text = @"@yahoo.com";
            break;
        case 3:
            txtFieldUserName.text = @"@hotmail.com";
            break;
        case 4:
            txtFieldUserName.text = @"@example.com";
            break;
        default:
            break;
    }
    
    self.navigationItem.leftBarButtonItem.enabled = YES;
    self.navigationItem.rightBarButtonItem.enabled = YES;
}


-(void) cancelThisView{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)nextView
{
    [self.view endEditing:YES];
    self.navigationItem.leftBarButtonItem.enabled = NO;
    self.navigationItem.rightBarButtonItem.enabled = NO;
    if (![[EmailFacade share] checkValidEmailAddress:[txtFieldUserName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]])
    {
        _alertView = [CAlertView new];
        [_alertView showError:ERROR_INVALID_EMAIL];
        self.navigationItem.leftBarButtonItem.enabled = YES;
        self.navigationItem.rightBarButtonItem.enabled = YES;
        return;
    }
    
    NSString *emailAddress = [txtFieldUserName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *emailPassword = [txtFieldPassword.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
      if (self.emailAccountType == 0)
    {
        LoginMicrosoftExchange *newAccountMicrosoft = [LoginMicrosoftExchange share];
        newAccountMicrosoft.strEmailAddress = emailAddress;
        newAccountMicrosoft.strEmailPassword = emailPassword;
        [self.navigationController pushViewController:newAccountMicrosoft animated:YES];
    }
    else if (self.emailAccountType == 4)
    {
        EmailLoginOffice *newAccount = [EmailLoginOffice share];
        newAccount.strEmailAddress = emailAddress;
        newAccount.strPassWord = emailPassword;
        [self.navigationController pushViewController:newAccount animated:YES];
    }
    else
    {
        //Stop background task first
        [[BackgroundTask share] stopBackgroundTask];
        
        NSDictionary *emailAccount = @{
                                          kEMAIL_ADDRESS: emailAddress,
                                          kEMAIL_PASSWORD: emailPassword,
                                          kEMAIL_ACCOUNT_TYPE: [NSNumber numberWithInt:emailAccountType]
                                          };
        
        [[EmailFacade share] loginEmailAccountType:emailAccount];
    }
}

-(void) loginEmailAccountSuccess{
    self.navigationItem.leftBarButtonItem.enabled = YES;
    self.navigationItem.rightBarButtonItem.enabled = YES;
    [[CWindow share] showMailBox];
}
-(void) loginEmailAccountFailedWithError:(NSError*)error{
    self.navigationItem.leftBarButtonItem.enabled = YES;
    self.navigationItem.rightBarButtonItem.enabled = YES;
    if (error)
        [[CAlertView new] showError:error.localizedDescription];
}

-(void) updateEmailAccountToServerFailed:(NSString*)username{
    self.navigationItem.leftBarButtonItem.enabled = YES;
    self.navigationItem.rightBarButtonItem.enabled = YES;
    CAlertView* alertView = [CAlertView new];
    NSMutableArray *buttonsName  = [NSMutableArray arrayWithObjects:NSLocalizedString(ALERT_BUTTON_RESET_EMAIL,nil),NSLocalizedString(ALERT_BUTTON_USE_NEW_EMAIL,nil), nil];
    [alertView showInfo_2btn:NSLocalizedString(ERROR_EMAIL_HAS_BEEN_USED,nil) ButtonsName:buttonsName];
    [alertView setOnButtonTouchUpInside:^(CAlertView *alertView, int buttonIndex)
     {
         if(buttonIndex ==0) //yes
         {
             [[EmailFacade share] resetEmailAccount:username];
         }
         else
         {
             [[CWindow share] showEmailLogin];
         }
         
     }];
}

-(void) resetEmailAccountSuccess{
    [self nextView];
}

-(void) resetEmailAccountFailed{
     [[CAlertView new] showError:NSLocalizedString(ERROR_RESET_EMAIL_SERVER_ERROR, nil)];
}

-(id) initWithCAlertView:(CAlertView *)theCAlertView{
    
    if (self = [super init]) {
        _alertView = theCAlertView;
    }
    return self;
    
}

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    if ([textField isEqual:txtFieldUserName]) {
        textField.selectedTextRange = [textField
                                       textRangeFromPosition:textField.beginningOfDocument
                                       toPosition:textField.beginningOfDocument];
        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dismissKeyboard {
    
    [self.view endEditing:YES];
}

- (NSString *)EmailTypeTitle
{
    switch (emailAccountType) {
        case 1:
            return @"Gmail";
            break;
        case 2:
            return @"Yahoo";
            break;
        case 3:
            return @"Hotmail";
            break;
        case 4:
            return @"Office";
            break;
        case 0:
            return @"MicrosoftExchange";
            break;
        default:
            return @"Login";
            break;
    }
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    if([textField isEqual:txtFieldUserName])
    {
        [txtFieldPassword becomeFirstResponder];
    }
    else
    {
        [self nextView];
    }
    return TRUE;
}


- (IBAction)clickedBtnShowPassword:(id)sender
{
    if (btnShowPassword.selected == NO)
    {
        btnShowPassword.selected = YES;
        [btnShowPassword setImage:[UIImage imageNamed:IMG_CHECKMARK] forState:UIControlStateNormal];
        txtFieldPassword.secureTextEntry = NO;
    }else{
        btnShowPassword.selected = NO;
        [btnShowPassword setImage:nil forState:UIControlStateNormal];
        txtFieldPassword.secureTextEntry = YES;
    }
    

}
@end
