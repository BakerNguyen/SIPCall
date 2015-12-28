//
//  EmailSettingMicrosoft.m
//  Satay
//
//  Created by Arpana Sakpal on 3/11/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import "EmailSettingMicrosoft.h"
#import "Advanced.h"
#import "BackgroundTask.h"

@interface EmailSettingMicrosoft ()
{
    MailAccount *mailAccountObj;
    NSString *userName;
    BOOL isUpdatedDB;
}
@end

@implementation EmailSettingMicrosoft
@synthesize txtFieldEmail,txtFieldDescription,txtFieldDomain,txtFieldPassword,txtFieldServer,txtFieldUsername;
@synthesize scrollView;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem=[UIBarButtonItem createLeftButtonTitle:_CANCEL Target:self Action:@selector(cancelToEmailVC)];
    self.navigationItem.rightBarButtonItem=[UIBarButtonItem createRightButtonTitle:_SAVE Target:self Action:@selector(processSave)];
    // Change color of right uibarbutton for disabled status
    self.navigationItem.title=TITLE_EMAIL_SETTING;
    [txtFieldEmail setDelegate:self];
    [txtFieldServer setDelegate:self];
    [txtFieldDomain setDelegate:self];
    [txtFieldUsername setDelegate:self];
    [txtFieldPassword setDelegate:self];
    [txtFieldDescription setDelegate:self];
    
    [scrollView setDelegate:self];
    [scrollView setContentSize:CGSizeMake(320, 650)];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    
    [txtFieldEmail setUserInteractionEnabled:NO];
    userName=[[EmailFacade share]getEmailAddress];
    mailAccountObj=[[EmailFacade share ]getMailAccount:userName];
    
  
    txtFieldEmail.text = userName;
    txtFieldServer.text = mailAccountObj.incomingHost;
    txtFieldDomain.text =  mailAccountObj.outgoingHost;
    txtFieldUsername.text = userName;
    txtFieldDescription.text = mailAccountObj.extend1;
    txtFieldPassword.text=[[EmailFacade share]decryptString:mailAccountObj.password];
    
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


-(id) initWithCAlertView:(CAlertView *)theCAlertView{
    
    if (self = [super init]) {
        _alertView = theCAlertView;
    }
    return self;
}

-(void) cancelToEmailVC{
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

-(void) processSave{
    // DDLogCVerbose(@"Save clicked");
    
    if(![self validateForm])
        return;

    mailAccountObj.incomingHost=txtFieldServer.text;
    mailAccountObj.outgoingHost=txtFieldDomain.text;
    mailAccountObj.extend1=txtFieldDescription.text;
    mailAccountObj.displayName = txtFieldUsername.text;
    mailAccountObj.password = [[EmailFacade share] encryptString:[txtFieldPassword.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
    mailAccountObj.incomingPassword = [[EmailFacade share] encryptString:[txtFieldPassword.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
    mailAccountObj.outgoingPassword = [[EmailFacade share] encryptString:[txtFieldPassword.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
    isUpdatedDB=[[EmailFacade share]updateMailAccount:mailAccountObj];
    
    if (isUpdatedDB)
    {
        [_alertView showInfo:mSuccess_SavedEmailInformation];

    }

       [self.navigationController popViewControllerAnimated:YES];
    
}


-(BOOL) validateForm{
    
    if(![[EmailFacade share] checkValidEmailAddress:txtFieldEmail.text]){
        
        [_alertView showError:ERROR_INVALID_EMAIL];
        return NO;
        
    }else if(txtFieldUsername.text.length == 0){
        
        [_alertView showError:mError_UserNameRequired];
        return NO;
        
    }
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    return YES;
    
}

- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    
    if (newLength > 0) {
        
        if (textField == txtFieldUsername) {
            
            self.navigationItem.rightBarButtonItem.enabled = YES;
            
        }
        
        // Return NO if newLength >=MAX_LENGHT_TEXT
        if(newLength >= 255 && range.length == 0){
            
            return NO;
            
        }
        
    }
    else {
          self.navigationItem.rightBarButtonItem.enabled = YES;
        // Disable the button
        //self.navigationItem.rightBarButtonItem.enabled = NO;
        
    }
    
    return YES;
    
}
- (void) deleteEmailAccountSuccess
{
    [[BackgroundTask share] stopBackgroundTask];
    [[CWindow share] showEmailLogin];
}

-(void) deleteEmailAccountFailed{
    [[CAlertView new] showError:NSLocalizedString(ERROR_SERVER_GOT_PROBLEM,nil)];
}

-(void)deleteEmailAccount{
    [[EmailFacade share] deleteEmailAccount];
}

- (IBAction)clickedBtnDeleteAccount:(id)sender {
    _alertView = [CAlertView new];
    [_alertView showWarning:mWarning_DeleteEmailAccount TARGET:self ACTION:@selector(deleteEmailAccount)];
}

- (IBAction)clickedBtnAdvance:(id)sender
{
    Advanced *advancedController = [[Advanced alloc] initWithNibName:@"Advanced" bundle:nil];
    [self.navigationController pushViewController:advancedController animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
