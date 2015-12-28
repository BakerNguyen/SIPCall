//
//  VerificationViewController.m
//  KryptoChat
//
//  Created by ENCLAVEIT on 4/25/14.
//  Copyright (c) 2014 mTouche. All rights reserved.
//

#import "Verification.h"
#import "VerificationCell.h"
#import "SyncContacts.h"
#import "MyProfile.h"
#import "ContactBook.h"
#import "BWStatusBarOverlay.h"
#import "SignUp.h"
#import "ChatList.h"
#define RESEND_LIMIT 5

@interface Verification (){
    NSString *fullNumberPhone;
    NSString *verificationCode;
    
    UILabel *timeLabel;
    int secondsLeft;
    NSTimer* resetTimeAutoSycn; //use NSTimer to reset 60 seconds when syncing.
    int numberOfResendCode;
}

@end

@implementation Verification

@synthesize paddingView;
@synthesize tblViewVerification;
@synthesize txtFieldVerCode;
@synthesize countryCode, phoneNumber;

@synthesize tapHere;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

+(Verification *)share{
    static dispatch_once_t once;
    static Verification * share;
    dispatch_once(&once, ^{
        share = [self new];
    });
    return share;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [ContactFacade share].verificationDelegate = self;
    
    self.navigationItem.title = TITLE_VERIFICATION;
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem createLeftButtonTitle:_BACK Target:self Action:@selector(backToSyncContacts)];
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem createRightButtonTitle:_DONE Target:self Action:@selector(verifyOTP)];
    
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    
    tblViewVerification.autoresizingMask = (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight);
    [tblViewVerification setDelegate:self];
    [tblViewVerification setDataSource:self];
    [tblViewVerification setBackgroundColor:COLOR_247247247];
    [tblViewVerification setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    tblViewVerification.scrollEnabled = NO;
    tblViewVerification.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    CGFloat tapHereX = [UIScreen mainScreen].bounds.size.width/2 - 90;
    if ((([[UIScreen mainScreen] bounds].size.height-568)?NO:YES)) {
        tapHere = [[UIButton alloc] initWithFrame:CGRectMake(tapHereX, 150, 180 , 44)];
    }else{
        tapHere = [[UIButton alloc] initWithFrame:CGRectMake(tapHereX, 70, 180 , 44)];
    }
   
    [tapHere setTitle:LABEL_TAP_HERE_TO_RESEND_CODE forState:UIControlStateNormal];
    [tapHere setTitleColor:COLOR_48147213 forState:UIControlStateNormal];
    tapHere.titleLabel.font = [UIFont systemFontOfSize:FONT_TEXT_SIZE_15];
    tapHere.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [tapHere addTarget:self action:@selector(tapHereTapped) forControlEvents:UIControlEventTouchUpInside];

    [tblViewVerification reloadData];
    // Create Tap here

    tapHere.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    
    //Tab on status bar will dismiss
    [BWStatusBarOverlay setActionBlock:^{
        NSLog(@"You pressed dismis Status Bar auto sync contact");
        [BWStatusBarOverlay dismiss];
    }];
}

-(void) backToSyncContacts{
    
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:animated];

    fullNumberPhone =  [[ContactFacade share] getFullNumber:countryCode phoneNumber:phoneNumber];
    numberOfResendCode = 0;
    //[self showCountDownTimer];
    
}
- (void)verifyOTP{
    
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusDenied){
        //Settings >Privacy >  Contacts - not allow
        CAlertView* alertView = [CAlertView new];
        [alertView showError:[CONSENT_CONTACT stringByAppendingString:LABEL_ENABEL_ACCESS_TO_YOUR_CONTACTS_IN_IPHONE]];
        [alertView setOnButtonTouchUpInside:^(CAlertView *alertView, int buttonIndex) {
            [CWindow share].rootViewController = [[DRNavigationController alloc] initWithRootViewController:[SyncContacts share]];
        }];
        return;
    }
    
    
    [[ContactFacade share] verifyOTP:fullNumberPhone otpCode:verificationCode resendCode:NO];
}

-(void)viewWillDisappear:(BOOL)animated{
    [[BWStatusBarOverlay shared] dismiss];
    [resetTimeAutoSycn invalidate];
    resetTimeAutoSycn = nil;
}

- (void) showCountDownTimer{
    //Set countdown timer for sync contact top bar.
    secondsLeft = 60;
    
    [BWStatusBarOverlay showSuccessWithMessage:timeLabel.text duration:5000 animated:YES];
    [BWStatusBarOverlay shared].textLabel.textColor = [UIColor whiteColor];
    [[BWStatusBarOverlay shared].contentView setBackgroundColor:[UIColor blueColor]];
    
    resetTimeAutoSycn = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateTime) userInfo:nil repeats:YES];
    
    [self updateTime];
}

- (void) updateTime
{
    [BWStatusBarOverlay shared].textLabel.text = @"";
    [BWStatusBarOverlay shared].textLabel.textAlignment = NSTextAlignmentCenter;
    [[BWStatusBarOverlay shared].textLabel setFont:[UIFont systemFontOfSize:12]];
    [BWStatusBarOverlay shared].textLabel.textColor = [UIColor whiteColor];
    
    if (secondsLeft > 0) {
        secondsLeft --;
        [BWStatusBarOverlay shared].textLabel.text = [NSString stringWithFormat:AUTO_SYNC_CONTACT_AFTER,secondsLeft];
    }else{
        [resetTimeAutoSycn invalidate];
        resetTimeAutoSycn = nil;
        [BWStatusBarOverlay dismiss];
        verificationCode = [[ContactFacade share] getVerificationCode];
        [self setVerificationCodeForTextField];
        
        [[BWStatusBarOverlay shared] dismiss];
        [self checkAuthorzation];
    }
}

- (void)setVerificationCodeForTextField{
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
    
    VerificationCell *cell = (VerificationCell *)[tblViewVerification cellForRowAtIndexPath:indexPath];
    cell.txtFieldForCell.text = verificationCode ;
}

- (void) checkAuthorzation{
    
    switch (ABAddressBookGetAuthorizationStatus()) {
        case kABAuthorizationStatusNotDetermined:
        case kABAuthorizationStatusDenied:
        case kABAuthorizationStatusRestricted:{
            ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
            ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
                if (granted) {
                    // First time access has been granted, add the contact
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self processSyncContacts];
                    });
                } else {
                    // User denied access
                    // Display an alert telling user the contact could not be added
                    [resetTimeAutoSycn invalidate];
                    resetTimeAutoSycn = nil;
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [BWStatusBarOverlay dismiss];
                        
                        CAlertView* alertView = [CAlertView new];
                        
                        [alertView showError:[CONSENT_CONTACT stringByAppendingString:LABEL_ENABEL_ACCESS_TO_YOUR_CONTACTS_IN_IPHONE]];
                        [alertView setOnButtonTouchUpInside:^(CAlertView *alertView, int buttonIndex) {
                            [CWindow share].rootViewController = [[DRNavigationController alloc] initWithRootViewController:[SyncContacts share]];
                        }];
                    });
                }
            });
                
        }break;
        case kABAuthorizationStatusAuthorized:
            [self processSyncContacts];
            break;
        default:
            break;
    }
}
-(void) processSyncContacts{

    [self hideKeyboard];
    [self.view endEditing:YES];
    
    secondsLeft = 0;
    [BWStatusBarOverlay dismiss];
    
    [[ContactFacade share] syncContactsWithServer];

}

-(void) syncContactsSuccess{
    
    NSLog(@"%@", self.navigationController.viewControllers);
    NSArray* arrayMessage = self.navigationController.viewControllers;
    if (arrayMessage.count == 3 && (arrayMessage[0]== [MyProfile share])){
        [self.navigationController popToViewController:[MyProfile share] animated:YES];
    }
    
    if ([[ContactFacade share] getReloginFlag]) {
        if ([ContactFacade share].isAccountExpired) {
            [[CWindow share] showPaymentOption];
            return;
        }
        
        CWindow.share.rootViewController = CWindow.share.menuController;
        [[ChatFacade share] countChatBoxList] > 0 ? [CWindow.share showChatList] : [CWindow.share showContactList];
        if ([[ChatFacade share] countChatBoxList] > 0) {
            [[ChatList share].navigationController pushViewController:[ContactBook share] animated:NO];
        }
        else
            [[ContactList share].navigationController pushViewController:[ContactBook share] animated:NO];
        
    }
    else {// if pushed from sync contact, then display sign up next. sign up and Add Friend page.
        if (arrayMessage.count > 0 &&
            [arrayMessage[arrayMessage.count -1] isKindOfClass:[Verification class]] )
                [CWindow share].rootViewController = [[DRNavigationController alloc] initWithRootViewController:[SignUp share]];
        
    }
    
    if (arrayMessage.count != 2) {
        [[ContactBook share] getDataForDisplaying];
        [[ContactBook share].tblMemberPhoneBook reloadData];
    }

}

-(void) syncContactsFailed{
     NSArray* arrayMessage = self.navigationController.viewControllers;
    if (arrayMessage.count == 3){
        if (arrayMessage[0]== [MyProfile share])
             [self.navigationController popToViewController:[MyProfile share] animated:YES];
        else
            [[CWindow share] showApplication];
    }else{
        [[ContactBook share] getDataForDisplaying];
        [[ContactBook share].tblMemberPhoneBook reloadData];
        [[ContactBook share].tblPhoneBook reloadData];
    }
    
    [[CAlertView new] showError:ERROR_SYNC_CONTACTS];
}


-(void) verifyOTPSuccess{
    [self checkAuthorzation];
}


-(void) hideKeyboard{
    
    [txtFieldVerCode resignFirstResponder];
    static NSString *cellID = @"VerificationCell";
    
    VerificationCell *cell = (VerificationCell *)[tblViewVerification dequeueReusableCellWithIdentifier:cellID];
    
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"VerificationCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
  //  VerificationCell *cell = [[VerificationCell alloc] init];
    for (UIView *contentView in [[cell contentView] subviews]) {
        if([contentView isKindOfClass:[UIView class]]){
            for (UITextField *textField in [contentView subviews]) {
                if ([textField isKindOfClass:[UITextField class] ] ) {//&& [textField isFirstResponder]
                    [textField resignFirstResponder];
                    break;
                }
            }
        }
    }

    
}


-(void)dismissKeyboard {
    [self.view endEditing:YES];
}

////////////////////////////////////////////////////////////////////////////////////
#pragma mark UITableView
////////////////////////////////////////////////////////////////////////////////////

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
	return 2;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.section) {
        case 0:
            return 44;
            break;
        case 1:
            return 200;
            
        default:
            return 44;
            break;
    }
    
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex{
    
    switch (sectionIndex) {
        case 0:
            return 2;
            break;
        case 1:
            return 1;
            break;
        default:
            return 1;
            break;
    }
    
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    static NSString *cellID = @"VerificationCell";
    
    VerificationCell *cell = (VerificationCell *)[tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"VerificationCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    switch (indexPath.section) {
        case 0:
        {
            switch (indexPath.row) {
                case 0:
                {
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    cell.backgroundColor = COLOR_247247247;
                    cell.txtFieldForCell.hidden = YES;
                    cell.userInteractionEnabled = NO;
                    cell.leftLabelForCell.font = [UIFont systemFontOfSize:FONT_TEXT_SIZE_15];
                    cell.leftLabelForCell.text = LABEL_PHONE_NUMBER;
                    
                    cell.rightLabelForCell.font = [UIFont systemFontOfSize:FONT_TEXT_SIZE_15];
                    cell.rightLabelForCell.text = fullNumberPhone;
                    
                }break;
                 case 1:
                {
 
                    paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 24, 24, 40)];
                     cell.txtFieldForCell.leftView = paddingView;
                      cell.txtFieldForCell.leftViewMode = UITextFieldViewModeAlways;
                      cell.txtFieldForCell.font = [UIFont systemFontOfSize:FONT_TEXT_SIZE_15];
                      cell.txtFieldForCell.layer.borderWidth = 1;
                      cell.txtFieldForCell.layer.borderColor  = COLOR_211211211.CGColor;
                      cell.txtFieldForCell.keyboardType = UIKeyboardTypeNumberPad;
                    
                    
                      cell.txtFieldForCell.attributedPlaceholder = [[NSAttributedString alloc] initWithString:STAKEHOLDER_4_DIGITS_OF_VERIFICATION attributes:@{NSForegroundColorAttributeName: COLOR_170170170}];
                     cell.txtFieldForCell.delegate = self;
                    
               
                    [cell.txtFieldForCell becomeFirstResponder];
             
                    
                }break;
                    
                default:
                    break;
            }break;
        }
        case 1:
        {
            
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = COLOR_247247247;
            cell.txtFieldForCell.hidden = YES;
            
            cell.leftLabelForCell.font = [UIFont systemFontOfSize:FONT_TEXT_SIZE_14];
            cell.leftLabelForCell.text = @"";//Hint for expiration of verification code
            cell.leftLabelForCell.textColor =  COLOR_128128128;
            
            [cell addSubview:tapHere];
            
        }break;
        default:
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            break;
    }
    
    return cell;
    
    
}

-(void)tapHereTapped{
    //You have exceeded your verification code request of 5 times for today. Please try again tomorrow.
    NSString* today = [ChatAdapter convertDateToString:[[NSNumber alloc] initWithInteger:[NSDate date].timeIntervalSince1970] format:FORMAT_DATE];
    if (numberOfResendCode == RESEND_LIMIT) {
        [KeyChainSecurity storeString:[NSString stringWithFormat:@"%@_%@",IS_YES,today] Key:kRESEND_LIMIT];
        CAlertView* newAlert= [CAlertView new];
        newAlert.lblMessage.numberOfLines = 3;
        [newAlert showInfo:ERROR_RESENT_LIMIT];
        return;
    }
    else{
        NSString* getResendLimitCheck = [KeyChainSecurity getStringFromKey:kRESEND_LIMIT];
        NSArray* arrayOfCheck = [getResendLimitCheck componentsSeparatedByString:@"_"];
        if (arrayOfCheck.count == 2) {
            NSString* dateForChecking = arrayOfCheck[1];
            NSString* isCheckResend = arrayOfCheck[0];
            if ([dateForChecking isEqual:today] && [isCheckResend isEqual:IS_YES]) {
                numberOfResendCode = 5;
                [[CAlertView new] showInfo:ERROR_RESENT_LIMIT];
                return;
            }
        }
    }
    
    numberOfResendCode++;
    self.navigationItem.rightBarButtonItem.enabled = NO;
    //Disable keyboard
    [self.view endEditing:YES];
    
    [[ContactFacade share] sendVerfificationCode:countryCode phoneNumber:fullNumberPhone resendCode:YES];

}


- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    
    if (newLength > 3) {
        
        // Enable Done button
        self.navigationItem.rightBarButtonItem.enabled = YES;

        if(newLength > MAX_LENGHT_TEXT_4 && range.length == 0){
            return NO;
            
        }else{
            verificationCode = [textField.text stringByAppendingString:string];
        }
        
    }
    else {
        
        // Disable the button
        self.navigationItem.rightBarButtonItem.enabled = NO;
        
    }
    
    return YES;
    
    
}





@end
