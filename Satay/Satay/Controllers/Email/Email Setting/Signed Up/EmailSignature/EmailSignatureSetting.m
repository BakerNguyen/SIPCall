//
//  EmailSignatureSetting.m
//  Satay
//
//  Created by Arpana Sakpal on 3/13/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import "EmailSignatureSetting.h"
#import "EmailSetting.h"

@interface EmailSignatureSetting ()
{
    MailAccount *mailAccountObj;
    NSString *userName;
    BOOL isUpdatedDB;
    
}
@end

@implementation EmailSignatureSetting

@synthesize txtViewSignature;

@synthesize signatureText;



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil parent:(id)_parent
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        parent = _parent;
        
        screenWidth = [[UIScreen mainScreen] applicationFrame].size.width;
        screenHeight = [[UIScreen mainScreen] applicationFrame].size.height;

        
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
 
    self.navigationItem.title=TITLE_SIGNATURE_SETTING;
    
    self.navigationItem.leftBarButtonItem=[UIBarButtonItem createLeftButtonTitle:_CANCEL
                                                                          Target:self
                                                                          Action:@selector(cancelSignatureView)];
    
    self.navigationItem.rightBarButtonItem=[UIBarButtonItem createRightButtonTitle:_SAVE
                                                                            Target:self
                                                                            Action:@selector(saveSignature)];
    
    // change  navigation rightbarbutton title Color for disable status
    
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    txtViewSignature.delegate = self;
    txtViewSignature.font = [UIFont systemFontOfSize:FONT_TEXT_SIZE_15];
    [txtViewSignature setFrame:CGRectMake(10, 0, screenWidth, screenHeight)];
    txtViewSignature.contentSize = CGSizeMake(screenWidth,screenHeight);
    
    UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(displayKeyboard)];
    [tapGesture setCancelsTouchesInView:NO];
    [txtViewSignature addGestureRecognizer:tapGesture];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showKeyboard:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(hideKeyboard:)
                                                 name:UIKeyboardWillHideNotification object:nil];

}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [txtViewSignature becomeFirstResponder];
    userName=[[EmailFacade share]getEmailAddress];
    mailAccountObj=[[EmailFacade share]getMailAccount:userName];
    txtViewSignature.text = mailAccountObj.signature;
}

-(void) cancelSignatureView{
    
    txtViewSignature.text = signatureText;
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

-(void) saveSignature{
    
    signatureText = txtViewSignature.text;
    mailAccountObj.signature=signatureText;
    
    isUpdatedDB=[[EmailFacade share]updateMailAccount:mailAccountObj];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    
    return YES;
    
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    // Enable Save button
    self.navigationItem.rightBarButtonItem.enabled = YES;
    return YES;
}

-(void) displayKeyboard{
    if ([txtViewSignature isFirstResponder]){
        [txtViewSignature resignFirstResponder];
    }
    else{
        [txtViewSignature becomeFirstResponder];
    }
}

-(void) showKeyboard:(NSNotification*) notifi{
    CGRect _keyboardEndFrame;
    [[notifi.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue:&_keyboardEndFrame];
    CGFloat keyboardHeight = _keyboardEndFrame.size.height;
    [txtViewSignature changeWidth:txtViewSignature.width Height:self.view.height - keyboardHeight];
    
    [txtViewSignature scrollRectToVisible:CGRectMake(1, txtViewSignature.contentSize.height, 1, 1) animated:NO];
}

-(void) hideKeyboard:(NSNotification*) notifi{
    CGRect _keyboardEndFrame;
    [[notifi.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue:&_keyboardEndFrame];
    CGFloat keyboardHeight = _keyboardEndFrame.size.height;
    [txtViewSignature changeWidth:txtViewSignature.width Height:txtViewSignature.height + keyboardHeight];
}

@end
