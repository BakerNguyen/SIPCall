//
//  EmailSettingPopImaViewController.m
//  Satay
//
//  Created by Arpana Sakpal on 3/11/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import "EmailSettingPopImap.h"
#import "Advanced.h"
#import "BackgroundTask.h"

@interface EmailSettingPopImap ()
{
    MailAccount *mailAccountObj;
    NSString *userName;
    BOOL isUpdatedDB;
}
@end

@implementation EmailSettingPopImap

@synthesize emailAddress, passWord;
@synthesize scrollView;
@synthesize txtFieldEmail;
@synthesize txtFieldIncomeHostName,txtFieldIncomePassword,txtFieldIncomeServerPort,txtFieldIncomeUserName;
@synthesize txtFieldOutgoHostName,txtFieldOutgoPassword,txtFieldOutgoServerPort,txtFieldOutgoUserName;



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

-(id) initWithCAlertView:(CAlertView *)theCAlertView{
    
    if (self = [super init]) {
        _alertView = theCAlertView;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem=[UIBarButtonItem createLeftButtonTitle:_BACK Target:self Action:@selector(cancelEmailSetting)];
    self.navigationItem.rightBarButtonItem=[UIBarButtonItem createRightButtonTitle:_SAVE Target:self Action:@selector(processSaveEmailSetting)];
    self.navigationItem.title=TITLE_EMAIL_SETTING;
    
    [txtFieldEmail setDelegate:self];
    [txtFieldIncomeHostName setDelegate:self];
    [txtFieldIncomeUserName setDelegate:self];
    [txtFieldIncomePassword setDelegate:self];
    [txtFieldOutgoHostName setDelegate:self];
    [txtFieldOutgoUserName setDelegate:self];
    [txtFieldOutgoPassword setDelegate:self];
    
    [scrollView setDelegate:self];
    [scrollView setContentSize:CGSizeMake(320, 700)];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    
    [txtFieldEmail setUserInteractionEnabled:NO];
    
    userName=[[EmailFacade share]getEmailAddress];
    mailAccountObj=[[EmailFacade share]getMailAccount:userName];
    txtFieldEmail.text=userName;
    txtFieldIncomeHostName.text=mailAccountObj.incomingHost;
    txtFieldIncomeUserName.text=mailAccountObj.incomingUserName;
    txtFieldIncomePassword.text=[[EmailFacade share] decryptString:mailAccountObj.incomingPassword];
    txtFieldIncomeServerPort.text=mailAccountObj.incomingPort;
    txtFieldOutgoHostName.text=mailAccountObj.outgoingHost;
    txtFieldOutgoUserName.text=mailAccountObj.outgoingUserName;
    txtFieldOutgoPassword.text=[[EmailFacade share] decryptString:mailAccountObj.outgoingPassword];
    txtFieldOutgoServerPort.text=mailAccountObj.outgoingPort;
    
    [EmailFacade share].emailSettingDelegate = self;
}

- (BOOL) canPerformAction:(SEL)action withSender:(id)sender
{
    if (action == @selector(copy:))
        return NO;
    return [super canPerformAction:action withSender:sender];
}

-(void)dismissKeyboard {
    [self.view endEditing:YES];
}

-(void) cancelEmailSetting{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void) processSaveEmailSetting{
    // DDLogCVerbose(@"Save email setting");
    //Validate form
   
    if(![self validateForm])
    return;
    
    NSString *password = [[EmailFacade share] encryptString:txtFieldIncomePassword.text];
    NSString *incomingPassword = [[EmailFacade share] encryptString:txtFieldIncomePassword.text];
    NSString *outgoingPassword = [[EmailFacade share] encryptString:txtFieldOutgoPassword.text];
    mailAccountObj.password = password;
    mailAccountObj.incomingHost=txtFieldIncomeHostName.text;
    mailAccountObj.incomingUserName= txtFieldIncomeUserName.text;
    mailAccountObj.incomingPassword=incomingPassword;
    mailAccountObj.incomingPort=txtFieldIncomeServerPort.text;
    mailAccountObj.outgoingHost=txtFieldOutgoHostName.text;
    mailAccountObj.outgoingUserName=txtFieldOutgoUserName.text;
    mailAccountObj.outgoingPassword=outgoingPassword;
    mailAccountObj.outgoingPort=txtFieldOutgoServerPort.text;
    
    isUpdatedDB=[[EmailFacade share]updateMailAccount:mailAccountObj];

    [self.navigationController popViewControllerAnimated:YES];
    [_alertView showInfo:mSuccess_SavedEmailInformation];
    
}

-(BOOL) validateForm{
    
    if (![[EmailFacade share] checkValidEmailAddress:txtFieldEmail.text]) {
        
        [_alertView showError:ERROR_INVALID_EMAIL];
        return NO;
        
    } else if (txtFieldIncomeUserName.text.length == 0) {
        
        [_alertView showError:mError_UserNameRequired];
        return NO;
        
    } else if (txtFieldIncomeServerPort.text.length == 0 || txtFieldOutgoServerPort.text.length == 0) {
        
        [_alertView showError:mError_ServerPortRequired];
        return NO;
        
    }
    
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)clickedBtnAdvanced:(id)sender
{
    Advanced *advancedController = [[Advanced alloc] initWithNibName:@"Advanced" bundle:nil];
    
    if (mailAccountObj.accountType.intValue == 0)
    {
        advancedController.isImapEmail = TRUE;
        
    } else{
        advancedController.isImapEmail = FALSE;
    }
    [self.navigationController pushViewController:advancedController animated:YES];
    
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    if ([textField isEqual:txtFieldIncomeHostName])
        [txtFieldIncomeUserName becomeFirstResponder];
    else if ([textField isEqual:txtFieldIncomeUserName])
        [txtFieldIncomePassword becomeFirstResponder];
    else if ([textField isEqual:txtFieldIncomePassword])
        [txtFieldIncomeServerPort becomeFirstResponder];
    else if ([textField isEqual:txtFieldIncomeServerPort])
        [txtFieldOutgoHostName becomeFirstResponder];
    else if ([textField isEqual:txtFieldOutgoHostName])
        [txtFieldOutgoUserName becomeFirstResponder];
    else if ([textField isEqual:txtFieldOutgoUserName])
        [txtFieldOutgoPassword becomeFirstResponder];
    else if ([textField isEqual:txtFieldOutgoPassword])
        [txtFieldOutgoServerPort becomeFirstResponder];
    else if(self.navigationItem.rightBarButtonItem.enabled){
        [self processSaveEmailSetting];
    }else
        [_alertView showError:mError_inputInformationRequired];
    return YES;
    
}

-(void) deleteEmailAccountSuccess{
    [[BackgroundTask share] stopBackgroundTask];
    [[CWindow share] showEmailLogin];
}
-(void) deleteEmailAccountFailed{
    [[CAlertView new] showError:NSLocalizedString(ERROR_SERVER_GOT_PROBLEM,nil)];
}

- (IBAction)clickedBtnDelete:(id)sender
{
    _alertView = [CAlertView new];
    [_alertView showWarning:mWarning_DeleteEmailAccount TARGET:self ACTION:@selector(deleteEmailAccount)];
}
- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    
    if (newLength > 0) {
        if (textField == txtFieldIncomeUserName) {
            self.navigationItem.rightBarButtonItem.enabled = YES;
        }
        // Return NO if newLength >=MAX_LENGHT_TEXT
        if(newLength >= 255 && range.length == 0){
            return NO;
        }
        
    }
    else {
        // Disable the button
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
    
    return YES;
    
}

-(void)deleteEmailAccount{
    [[EmailFacade share] deleteEmailAccount];
}

@end
