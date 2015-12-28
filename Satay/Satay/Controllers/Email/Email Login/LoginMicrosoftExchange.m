//
//  LoginMicrosoftExchange
//  Satay
//
//  Created by Arpana Sakpal on 3/12/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import "LoginMicrosoftExchange.h"
#import "SetUpEmail.h"
@interface LoginMicrosoftExchange ()
{
    NSUserDefaults *defaultUser;

}
@end

@implementation LoginMicrosoftExchange


@synthesize txtFieldEmail, txtFieldServer, txtFieldDomain, txtFieldUsername,txtFieldPassword,txtFieldDescription;
@synthesize scrollView;

@synthesize strEmailAddress,strEmailPassword;

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
    self.navigationItem.title=TITLE_NEW_ACCOUNT;
    _alertView = [[CAlertView alloc] init];
    self.navigationItem.leftBarButtonItem=[UIBarButtonItem createLeftButtonTitle:_CANCEL
                                                                          Target:self
                                                                          Action:@selector(cancelToEmailVC)];
 
    self.navigationItem.rightBarButtonItem=[UIBarButtonItem createLeftButtonTitle:_SAVE
                                                                           Target:self
                                                                           Action:@selector(processNext)];
    
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
    
    defaultUser = [NSUserDefaults standardUserDefaults];
}
- (BOOL) canPerformAction:(SEL)action withSender:(id)sender
{
    if (action == @selector(copy:))
        return NO;
    return [super canPerformAction:action withSender:sender];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    txtFieldEmail.text = strEmailAddress;
    txtFieldPassword.text = strEmailPassword;
    txtFieldUsername.text = strEmailAddress;
    [txtFieldEmail becomeFirstResponder];
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

-(void) processNext{
    
    if(![self validateForm])
        return;
    // Done then got to Set Up Email
    SetUpEmail *setUpEmailVC = [SetUpEmail new];
    setUpEmailVC.emailAddress = txtFieldEmail.text;
    setUpEmailVC.emailPassWord =strEmailPassword;
    setUpEmailVC.serverMicrosoft = txtFieldServer.text;
    setUpEmailVC.domainMicrosoft = txtFieldDomain.text;
    setUpEmailVC.descriptionMicrosoft = txtFieldDescription.text;
    setUpEmailVC.emailType = 0;// Set email Type = 0 for Microsoft exchange
    setUpEmailVC.incommingUserName = txtFieldUsername.text;
    
    [self.navigationController pushViewController:setUpEmailVC animated:YES];
}


-(BOOL) validateForm{
    
    if (![[EmailFacade share] checkValidEmailAddress:[txtFieldEmail.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]]){
        
        [_alertView showError:ERROR_INVALID_EMAIL];
        return NO;
        
    } else if (txtFieldUsername.text.length == 0) {
        
        [_alertView showError:mError_UserNameRequired];
        return NO;
        
    }
    
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    if ([textField isEqual:txtFieldEmail])
        [txtFieldServer becomeFirstResponder];
    else if ([textField isEqual:txtFieldServer])
        [txtFieldDomain becomeFirstResponder];
    else if ([textField isEqual:txtFieldDomain])
        [txtFieldUsername becomeFirstResponder];
    else if ([textField isEqual:txtFieldUsername])
        [txtFieldPassword becomeFirstResponder];
    else if ([textField isEqual:txtFieldPassword])
        [txtFieldDescription becomeFirstResponder];
    else if(self.navigationItem.rightBarButtonItem.enabled){
        [self processNext];
    }else
        [_alertView showError:mError_inputInformationRequired];
    return YES;
    
}

- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    
    if (newLength > 0) {
        
        if ((txtFieldEmail.text.length > 0) &&
            (txtFieldServer.text.length > 0) &&
            (txtFieldDomain.text.length > 0) &&
            (txtFieldUsername.text.length > 0) &&
            (txtFieldPassword.text.length > 0))
        {
            self.navigationItem.rightBarButtonItem.enabled = YES;
        }
        
        // Return NO if newLength >=MAX_LENGHT_TEXT
        if(newLength >= 255 && range.length == 0){
            
            return NO;
            
        }
        
    } else {
        
        // Disable the button
        self.navigationItem.rightBarButtonItem.enabled = NO;
        
    }
    
    return YES;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
