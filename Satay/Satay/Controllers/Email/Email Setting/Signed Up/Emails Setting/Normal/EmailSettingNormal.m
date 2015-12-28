//
//  EmailSettingNormal.m
//  Satay
//
//  Created by Arpana Sakpal on 3/12/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import "EmailSettingNormal.h"
#import "Advanced.h"
#import "BackgroundTask.h"

@interface EmailSettingNormal ()
{
    MailAccount *mailAccountObj;
    NSString *userName;
    BOOL isUpdatedDB;
}
@end

@implementation EmailSettingNormal
@synthesize lblEmailAddress, txtFielPassword;
@synthesize emailAddress, passWord;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title=TITLE_EMAIL_SETTING;
    // Do any additional setup after loading the view from its nib.
    
    _alertView = [[CAlertView alloc] init];
    
    self.navigationItem.leftBarButtonItem=[UIBarButtonItem createLeftButtonTitle:_BACK Target:self Action:@selector(cancelEmailSetting)];
    
    self.navigationItem.rightBarButtonItem=[UIBarButtonItem createRightButtonTitle:_SAVE Target:self Action:@selector(processSaveEmailSetting)];
    
    // change Color of navigationItem.rightBarButtonItem title for disable status
    
    
    [self.navigationItem.rightBarButtonItem setEnabled:true];
    
    [txtFielPassword setDelegate:self];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    
    [EmailFacade share].emailSettingDelegate = self;
}

- (void) viewWillAppear:(BOOL)animated
{
    userName=[[EmailFacade share]getEmailAddress];
    mailAccountObj=[[EmailFacade share]getMailAccount:userName];
    passWord=[[EmailFacade share]decryptString:mailAccountObj.password];
    lblEmailAddress.text=userName;
    txtFielPassword.text=passWord;
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
    //Validate form
    if(![self validateForm])
        return;
    mailAccountObj.password = [[EmailFacade share] encryptString:[txtFielPassword.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
    mailAccountObj.incomingPassword = [[EmailFacade share] encryptString:[txtFielPassword.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
    mailAccountObj.outgoingPassword = [[EmailFacade share] encryptString:[txtFielPassword.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
    isUpdatedDB=[[EmailFacade share]updateMailAccount:mailAccountObj];
    [self.navigationController popViewControllerAnimated:YES];
    [_alertView showInfo:mSuccess_SavedEmailInformation];
  
}

-(BOOL) validateForm{
    if(txtFielPassword.text.length == 0){
        [_alertView showError:mError_PasswordRequired];
        return NO;
    }
    return YES;
}

-(id) initWithCAlertView:(CAlertView *)theCAlertView{
    
    if (self = [super init]) {
        _alertView = theCAlertView;
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)clickedBtnDelete:(id)sender {
    
    [_alertView showWarning:mWarning_DeleteEmailAccount TARGET:self ACTION:@selector(deleteEmailAccount)];
    
    
}

- (IBAction)clickBtnAdvanced:(id)sender {
    Advanced *advancedController = [[Advanced alloc] initWithNibName:@"Advanced" bundle:nil];

    [self.navigationController pushViewController:advancedController animated:YES];
    
}

-(void)deleteEmailAccount{
    [[EmailFacade share] deleteEmailAccount];
}

-(void) deleteEmailAccountSuccess{
    [[BackgroundTask share] stopBackgroundTask];
    [[CWindow share] showEmailLogin];
}
-(void) deleteEmailAccountFailed{
    [[CAlertView new] showError:NSLocalizedString(ERROR_SERVER_GOT_PROBLEM,nil)];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    return YES;
    
}

- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    if (newLength > 0) {
        
        self.navigationItem.rightBarButtonItem.enabled = YES;
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


@end
