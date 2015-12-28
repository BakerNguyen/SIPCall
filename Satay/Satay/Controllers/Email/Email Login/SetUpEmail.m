//
//  SetUpEmail.m
//  Satay
//
//  Created by Arpana Sakpal on 3/3/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//


#import "SetUpEmail.h"
#import "BackgroundTask.h"

@interface SetUpEmail ()

@end

@implementation SetUpEmail

@synthesize scrollView;
@synthesize txtFieldAccountName, txtFieldYourName;
@synthesize emailType,emailAddress,emailPassWord;

@synthesize incommingUserName, incommingHost, incommingPassword, incommingPort;

@synthesize outgoingUserName, outgoingHost ,outgoingPassword, outgoingPort;

@synthesize delEmailFromServer, syncSchedule;

@synthesize serverMicrosoft, domainMicrosoft, descriptionMicrosoft;



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
   
    _alertView = [[CAlertView alloc] init];
    
    self.navigationItem.title=TITLE_NEW_ACCOUNT;
    self.navigationItem.rightBarButtonItem=[UIBarButtonItem createRightButtonTitle:_DONE
                                                                            Target:self
                                                                            Action:@selector(processDone)];
    self.navigationItem.leftBarButtonItem=[UIBarButtonItem createLeftButtonTitle:_CANCEL
                                                                          Target:self
                                                                          Action:@selector(cancelSetUpVC)];
    
    // Color for disable status

    self.navigationItem.title=TITLE_SET_UP_EMAIL;
    self.navigationItem.rightBarButtonItem.enabled=NO;
    
    [txtFieldAccountName setDelegate:self];
    [txtFieldYourName setDelegate:self];
    
    [scrollView setDelegate:self];
    [scrollView setContentSize:CGSizeMake(320, 600)];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    
    txtFieldAccountName.text = emailAddress;
    
}

-(void)dismissKeyboard {
    [self.view endEditing:YES];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [txtFieldAccountName becomeFirstResponder];
}

-(id) initWithCAlertView:(CAlertView *)theCAlertView{
    
    if (self = [super init]) {
        _alertView = theCAlertView;
    }
    return self;
}

-(void) cancelSetUpVC{
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(void) processDone
{
    [self.view endEditing:YES];
    
    if(![self validateForm])
        return;
    
    //Stop background task first
    [[BackgroundTask share] stopBackgroundTask];
    switch (emailType)
    {
        case 0: // microsoft exchange(0)
        {
            NSDictionary *emailAccount = @{
                                           kEMAIL_ADDRESS: emailAddress,
                                           kEMAIL_PASSWORD: emailPassWord,
                                           kEMAIL_ACCOUNT_TYPE: [NSNumber numberWithInteger:emailType],
                                           kEMAIL_INC_HOST: serverMicrosoft,
                                           kEMAIL_INC_USENAME: emailAddress,
                                           kEMAIL_INC_PASSWORD: emailPassWord,
                                           kEMAIL_OUT_HOST: domainMicrosoft,
                                           kEMAIL_OUT_USENAME: emailAddress,
                                           kEMAIL_OUT_PASSWORD: emailPassWord,
                                           kEMAIL_DESCRIPTION: descriptionMicrosoft,
                                           kEMAIL_DISPLAYNAME: txtFieldYourName.text,
                                           kEMAIL_PERIOD_SYNC_SCHEDULE: [NSNumber numberWithInteger:syncSchedule],
                                           };
            
            [[EmailFacade share] loginEmailAccountType:emailAccount];
        }
            break;
        case 4:// IMAP office(4)
        {
            NSDictionary *emailAccount = @{
                                           kEMAIL_ADDRESS: emailAddress,
                                           kEMAIL_PASSWORD: emailPassWord,
                                           kEMAIL_ACCOUNT_TYPE: [NSNumber numberWithInteger:emailType],
                                           kEMAIL_INC_HOST: incommingHost,
                                           kEMAIL_INC_USENAME: incommingUserName,
                                           kEMAIL_INC_PASSWORD: incommingPassword,
                                           kEMAIL_INC_PORT: [NSNumber numberWithInteger:incommingPort],
                                           kEMAIL_OUT_HOST: outgoingHost,
                                           kEMAIL_OUT_USENAME: outgoingUserName,
                                           kEMAIL_OUT_PASSWORD: outgoingPassword,
                                           kEMAIL_OUT_PORT: [NSNumber numberWithInteger:outgoingPort],
                                           kEMAIL_DISPLAYNAME: txtFieldYourName.text,
                                           kEMAIL_PERIOD_SYNC_SCHEDULE: [NSNumber numberWithInteger:syncSchedule]
                                           };
            
            [[EmailFacade share] loginEmailAccountType:emailAccount];
        }
            break;
        case 5://POP office(5)
        {
            NSDictionary *emailAccount = @{
                                           kEMAIL_ADDRESS: emailAddress,
                                           kEMAIL_PASSWORD: emailPassWord,
                                           kEMAIL_ACCOUNT_TYPE: [NSNumber numberWithInteger:emailType],
                                           kEMAIL_INC_HOST: incommingHost,
                                           kEMAIL_INC_USENAME: incommingUserName,
                                           kEMAIL_INC_PASSWORD: incommingPassword,
                                           kEMAIL_INC_PORT: [NSNumber numberWithInteger:incommingPort],
                                           kEMAIL_OUT_HOST: outgoingHost,
                                           kEMAIL_OUT_USENAME: outgoingUserName,
                                           kEMAIL_OUT_PASSWORD: outgoingPassword,
                                           kEMAIL_OUT_PORT: [NSNumber numberWithInteger:outgoingPort],
                                           kEMAIL_DISPLAYNAME: txtFieldYourName.text,
                                           kEMAIL_PERIOD_SYNC_SCHEDULE: [NSNumber numberWithInteger:syncSchedule],
                                           kEMAIL_POP3_DELETABLE: [NSNumber numberWithInteger:delEmailFromServer]
                                           };
            
            [[EmailFacade share] loginEmailAccountType:emailAccount];
        }
            break;
        default:
            break;
    }
}

-(BOOL) validateForm{
    if(![[EmailFacade share] checkValidEmailAddress:[txtFieldAccountName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]]){
        [_alertView showError:ERROR_INVALID_EMAIL];
        return NO;
    }else if(txtFieldYourName.text.length == 0){
        [_alertView showError:mError_UserNameRequired];
        return NO;
    }
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    if ([textField isEqual:txtFieldAccountName])
        [txtFieldYourName becomeFirstResponder];
    else if(self.navigationItem.rightBarButtonItem.enabled){
        [self processDone];
    }else
        [_alertView showError:mError_inputInformationRequired];
    return YES;
    
}

- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    
    if ((txtFieldYourName.text.length > 0) && (txtFieldAccountName.text.length > 0))
        self.navigationItem.rightBarButtonItem.enabled = YES;
    
    if (newLength > 0)
    {
        if(newLength >= 255 && range.length == 0)
            return NO;
    }
    else
    {
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
