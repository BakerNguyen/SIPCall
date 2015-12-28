//
//  StatusProfile.m
//  KryptoChat
//
//  Created by ENCLAVEIT on 4/21/14.
//  Copyright (c) 2014 mTouche. All rights reserved.
//

#import "StatusProfile.h"


#define MAX_LENGHT_TEXT 100

@interface StatusProfile ()
{
    //CAlertView *alert;
}

@end

@implementation StatusProfile

@synthesize hintTextColor;
@synthesize txtViewStatus;
@synthesize lblNumberRest;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        screenWidth = [[UIScreen mainScreen] applicationFrame].size.width;
        screenHeight = [[UIScreen mainScreen] applicationFrame].size.height;
        hintTextColor = [[UIColor alloc] initWithRed:128/255.0f green:128/255.0f blue:128/255.0f alpha:1];
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    txtViewStatus.delegate = self;
    txtViewStatus.font = [UIFont systemFontOfSize:FONT_TEXT_SIZE_15];
    
    [txtViewStatus becomeFirstResponder];
    txtViewStatus.text = [[ContactFacade share] getProfileStatus];
    
    int numberRest = MAX_LENGHT_TEXT - (int)txtViewStatus.text.length;
    lblNumberRest.text = [NSString stringWithFormat:@"%d",numberRest];
    lblNumberRest.textColor = [[UIColor alloc] initWithRed:170/255.0f green:170/255.0f blue:170/255.0f alpha:1];
    lblNumberRest.font = [UIFont systemFontOfSize:FONT_TEXT_SIZE_14];
    
    self.navigationItem.title = LABEL_WHATS_UP;
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem createRightButtonTitle:_SAVE Target:self Action:@selector(saveStatusProfile)];
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem createLeftButtonTitle:_CANCEL Target:self Action:@selector(cancelStatusView)];
    
    [ContactFacade share].statusProfileDelegate = self;
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    txtViewStatus.text = [[ProfileAdapter share] getProfileStatus].length > 0 ? [[ProfileAdapter share] getProfileStatus] : DEFAULT_STATUS_AVAILABLE;
    [self updateLblNumberRest:[txtViewStatus text]];
    [txtViewStatus becomeFirstResponder];
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
}

-(void) cancelStatusView{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void) saveStatusProfile{
    [[ContactFacade share] setProfileStatus:[txtViewStatus.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
    [[LogFacade share] createEventWithCategory:Profile_Category action:whatUp_Action label:labelAction];
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    [self updateLblNumberRest:[textView text]];
}

-(void) updateLblNumberRest:(NSString *)strToCheck
{
    int newLength = (int) [strToCheck length];
    int numberRest = MAX_LENGHT_TEXT - newLength;
    [lblNumberRest setText: [NSString stringWithFormat:@"%d", numberRest]];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    NSUInteger newLength = [textView.text length] + [text length] - range.length;
    if([text isEqualToString:@"\n"])
    {
        [txtViewStatus resignFirstResponder];
    }
    if (newLength > 0) {
        if(newLength > MAX_LENGHT_TEXT && newLength < UINT32_MAX)
        {
            [[CAlertView new] showError:mERROR_STATUS_CANNOT_EXCEED_MORE_THEN_100WORDS];
            return NO;
        }
        else
        {
            // Enable Save button
            self.navigationItem.rightBarButtonItem.enabled = YES;
            int numberRest = MAX_LENGHT_TEXT - (int)newLength;
            lblNumberRest.text = [NSString stringWithFormat:@"%d",numberRest];
        }
    }
    else {
        lblNumberRest.text = [NSString stringWithFormat:@"%d",MAX_LENGHT_TEXT];
    }
    return YES;
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary *keyboardInfo = [notification userInfo];
    CGRect keyboardEndFrame;
    [[keyboardInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardEndFrame];
    
    lblNumberRest.frame = CGRectMake(screenWidth-46,screenHeight-keyboardEndFrame.size.height-70,42,21);
    
    keyboardInfo = nil;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
}


@end
