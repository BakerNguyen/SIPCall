//
//  DisplayName.m
//  KryptoChat
//
//  Created by ENCLAVEIT on 1/16/15.
//  Copyright (c) 2014 mTouche. All rights reserved.
//

#import "DisplayName.h"

@interface DisplayName (){
    BOOL isChangeGroupName;
}
@end

@implementation DisplayName

@synthesize txtViewDisplayName;
@synthesize lblNumberRest;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    txtViewDisplayName.delegate = self;
    txtViewDisplayName.font = [UIFont systemFontOfSize:FONT_TEXT_SIZE_15];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationItem.title = TITLE_DISPLAY_NAME;
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem createRightButtonTitle:_SAVE Target:self
                                                                              Action:@selector(saveDisplayName)];
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem createLeftButtonTitle:_CANCEL Target:self
                                                                              Action:@selector(cancelDisplayNameView)];
    
    txtViewDisplayName.text = [[ContactFacade share] getDisplayName];

    int numberRest = MAX_LENGHT_TEXT_NAME - (int)txtViewDisplayName.text.length;
    lblNumberRest.text = [NSString stringWithFormat:@"%d",numberRest];
    lblNumberRest.textColor = [[UIColor alloc] initWithRed:170/255.0f green:170/255.0f blue:170/255.0f alpha:1];
    lblNumberRest.font = [UIFont systemFontOfSize:FONT_TEXT_SIZE_14];
    
    [ContactFacade share].displaynameDelegate = self;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];

}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [txtViewDisplayName becomeFirstResponder];
}

-(void) cancelDisplayNameView{
    [self.navigationController popViewControllerAnimated:YES];
    self.navigationItem.rightBarButtonItem.enabled = TRUE;
    [[LogFacade share] createEventWithCategory:Profile_Category action:changeDisplayName_Action label:labelAction];
}
-(void) updateDisplayNameFailed{
    self.navigationItem.rightBarButtonItem.enabled = TRUE;
    [[CAlertView new] showError:ERROR_CANNOT_UPDATE_YOUR_NAME];
}

-(void) saveDisplayName{
    self.navigationItem.rightBarButtonItem.enabled = FALSE;
    NSString *displayname = [Base64Security generateBase64String:[txtViewDisplayName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
    [[ContactFacade share] updateDisplayName:displayname];
}

-(void) showLoadingView{
    if (self.navigationController.viewControllers.count > 0 &&
        [self.navigationController.viewControllers[self.navigationController.viewControllers.count -1] isKindOfClass:[DisplayName class]] )
        [[CWindow share] showLoading:kLOADING_UPDATING_NAME];
}

- (void)textViewDidChange:(UITextView *)textView
{
    NSUInteger newLength = textView.text.length;
    
    int numberRest = MAX_LENGHT_TEXT_NAME - (int)textView.text.length;
    lblNumberRest.text = [NSString stringWithFormat:@"%d",numberRest];
    if (newLength > MAX_LENGHT_TEXT_NAME){
        [textView deleteBackward];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    NSUInteger newLength = [textView.text length] + [text length] - range.length;
    if([text isEqualToString:@"\n"])
    {
        [txtViewDisplayName resignFirstResponder];
    }
    if (newLength > 0) {
        if(newLength > MAX_LENGHT_TEXT_NAME && newLength < UINT32_MAX)
        {
            [[CAlertView new] showError:mERROR_DISPLAYNAME_CANNOT_EXCEED_MORE_THEN_20WORDS];
            return NO;
        }
        else
        {
            // Enable Save button
            self.navigationItem.rightBarButtonItem.enabled = YES;
            int numberRest = MAX_LENGHT_TEXT_NAME - (int)newLength;
            lblNumberRest.text = [NSString stringWithFormat:@"%d",numberRest];
        }
    }
    else {
        lblNumberRest.text = [NSString stringWithFormat:@"%d",MAX_LENGHT_TEXT_NAME];
    }
    return YES;
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary *keyboardInfo = [notification userInfo];
    CGRect keyboardEndFrame;
    [[keyboardInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardEndFrame];
    [lblNumberRest changeXAxis:self.view.width - 25 YAxis:self.view.height - keyboardEndFrame.size.height - 25];
    keyboardInfo = nil;
}

+(DisplayName *)share{
    static dispatch_once_t once;
    static DisplayName * share;
    dispatch_once(&once, ^{
        share = [self new];
        

    });
    return share;
}

@end
