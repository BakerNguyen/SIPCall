//
//  SyncContacts.m
//  KryptoChat
//
//  Created by ENCLAVEIT on 4/23/14.
//  Copyright (c) 2014 mTouche. All rights reserved.
//

#import "SyncContacts.h"
#import "CountryCell.h"
#import "PasscodeView.h"
#import "SignUp.h"
@interface SyncContacts ()


@end

@implementation SyncContacts

@synthesize tblSyncContact;
@synthesize lblPreNumberPhone;
@synthesize txtNumPhone;
@synthesize paddingView;

@synthesize countryListViewController;
@synthesize verificationViewController;
@synthesize countryName;
@synthesize countryCode;
@synthesize phoneNumber;
@synthesize dialCode;

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
    // Do any additional setup after loading the view from its nib.
    
    [ContactFacade share].syncContactDelegate = self;
    
    
    
    self.navigationItem.title = TITLE_PHONE_NUMBER;
    //self.navigationItem.leftBarButtonItem = [UIBarButtonItem createLeftButtonTitle:_CANCEL Target:self Action:@selector(cancelSyncContactView)];
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem createRightButtonTitle:_NEXT Target:self Action:@selector(nextSync)];
    
    self.navigationItem.rightBarButtonItem.enabled = NO;
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem createLeftButtonTitle:_BACK Target:self Action:@selector(backView)];
    
    tblSyncContact.autoresizingMask = (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight);
    [tblSyncContact setDelegate:self];
    [tblSyncContact setDataSource:self];
    tblSyncContact.separatorStyle = UITableViewCellSeparatorStyleNone;
    [tblSyncContact setBackgroundColor:COLOR_247247247];
    tblSyncContact.scrollEnabled = NO;
    
    [ContactFacade share].checkMSISDNDelegate = self;
    [ContactFacade share].updateMSISDNDelegate = self;
    [ContactFacade share].sendVerificationCodeDelegate = self;
    
    [self setCountryConfig];

    [[UITextField appearance] setTintColor:[UIColor blackColor]];
}

-(void) backView{
    
    NSLog(@"getRegisterFlag: %hhd", [[ContactFacade share] getRegisterFlag]);
    NSLog(@"getSyncContactFlag: %hhd", [[ContactFacade share] getSyncContactFlag]);
    NSLog(@"getReloginFlag: %hhd", [[ContactFacade share] getReloginFlag]);
    NSLog(@"getFreeTrialedFlag: %hhd", [[ContactFacade share] getFreeTrialedFlag]);
    NSLog(@"ViewControllers: %@", self.navigationController.viewControllers);
    
    if ([[ContactFacade share] getRegisterFlag] && ![[ContactFacade share] getFreeTrialedFlag]) {//sign up
        if (![[ContactFacade share] getReloginFlag] && ![[ContactFacade share] getSyncContactFlag]) {
            [[ContactFacade share] resetSignUpAndSignInAccount];
            [[CWindow share] showLoginFirstScreen];
        }
        if ([[ContactFacade share] getReloginFlag] && ![[ContactFacade share] getSyncContactFlag]) {
            [[ContactFacade share] resetSignUpAndSignInAccount];
            [[CWindow share] showLoginScreen];
        }
        
    }else{//Relogin and Profile
        [self.navigationController popViewControllerAnimated:YES];
    }
}


-(void)dismissKeyboard {
    [self.view endEditing:YES];
}

-(void)showKeyboard{
    [txtNumPhone becomeFirstResponder];
}

-(void)viewWillAppear:(BOOL)animated{
  
    [super viewWillAppear:animated];
    
    self.navigationItem.hidesBackButton = YES;
    
    [tblSyncContact reloadData];
}
-(void)viewDidAppear:(BOOL)animated
{
    if(![PasscodeView share].view.superview){
        [txtNumPhone becomeFirstResponder];
    }
}
-(void) cancelSyncContactView{
    
    [self showCancelPopup];
    
}

-(void) showCancelPopup
{
    [self.view endEditing:YES];
    CAlertView *alertView = [CAlertView new];
    alertView.tag=88;
    NSMutableArray *buttonsName  = [NSMutableArray arrayWithObjects:ALERT_BUTTON_NO_THANKS, ALERT_BUTTON_SYNC_NOW, nil];
    
    [alertView showInfo_2btn:SYNC_CONTACTS_TO_CHAT_WITH_YOUR_FRIENDS
                 ButtonsName:buttonsName];
    [alertView setOnButtonTouchUpInside:^(CAlertView *alertView, int buttonIndex)
     {
         if (buttonIndex == 0)
         {
             
             __block bool backToPreviousView = NO;
             
             [self dismissViewControllerAnimated:YES completion:^{
                 backToPreviousView =YES;
                 
             }];
             
             if(!backToPreviousView)
             {
                 [[CWindow share] showApplication];
             }
             [alertView close];
         }
         else
         {
             NSLog(@"stay on current page");
         }
     }];
    
}

- (void)nextSync
{
    [self.view endEditing:YES];
    CAlertView * alertView = [CAlertView new];
    
    if ([countryListViewController.countryName isEqualToString:kUNKNOWN]) {
        [alertView showError:mERROR_INVALID_COUNTRY_NAME];
        return;
    }
    
    if (![[ContactFacade share] checkMSISDNValid:txtNumPhone.text]) {
        [alertView showError:mERROR_INVALID_PHONENUMBER];
        return;
    }
    phoneNumber = txtNumPhone.text;
    NSMutableArray *buttonsName  = [NSMutableArray arrayWithObjects:@"Cancel",@"OK", nil];
    NSString *phoneNum = [NSString stringWithFormat:@"(+%@) %@",dialCode,phoneNumber];
    NSString *confirmString = [NSString stringWithFormat:CONSENT_CONTACT,phoneNum];
    [alertView showInfo_2btn:confirmString ButtonsName:buttonsName];
    [alertView setOnButtonTouchUpInside:^(CAlertView *alertView, int buttonIndex)
     {
         
         if(buttonIndex ==1) //press OK button
         {
             if([[ContactFacade share] getReloginFlag])
             {
                 [[ContactFacade share] sendVerfificationCode:countryCode
                                                  phoneNumber:[[ContactFacade share]
                                                               getFullNumber:countryCode phoneNumber:phoneNumber]
                                                   resendCode:NO];
             }
             else{
                 [[ContactFacade share] validateMSISDNWithServer:countryCode phoneNumber:phoneNumber];
             }
        }
         
     }];
}

-(void) msisdnExisted:(NSString*)countrycode phoneNumber:(NSString*)phonenumber{
    
    self.navigationItem.rightBarButtonItem.enabled = YES;
    
    CAlertView *alertView = [CAlertView new];
    NSMutableArray *buttonsName  = [NSMutableArray arrayWithObjects: [_NO capitalizedString], [_YES capitalizedString], nil];
    
    [alertView showInfo_2btn:THIS_NUMBER_HAS_BEEN_USED
                 ButtonsName:buttonsName];
    [alertView setOnButtonTouchUpInside:^(CAlertView *alertView, int buttonIndex)
     {
         if (buttonIndex == 0)// tap No
         {
             NSLog(@"UseNewNumber");
             txtNumPhone.text = @"";
             [txtNumPhone becomeFirstResponder];
         }
         else // tap yes
         {
             [self.view endEditing:YES];
             [[ContactFacade share] updateMSISDNToServer:countrycode phoneNumber:phonenumber];
         }
     }];
}

-(void) checkMSISDNSuccess:(NSString*)countrycode phoneNumber:(NSString*)phonenumber{
    self.navigationItem.rightBarButtonItem.enabled = YES;
    [[ContactFacade share] updateMSISDNToServer:countrycode phoneNumber:phonenumber];
}
-(void) checkMSISDNFailed{
    self.navigationItem.rightBarButtonItem.enabled = YES;
    [[CAlertView new] showError:ERROR_SERVER_GOT_PROBLEM];
}

-(void) updateMSISDNSuccess:(NSString*)countrycode phoneNumber:(NSString*)phonenumber{
    self.navigationItem.rightBarButtonItem.enabled = YES;
    [[ContactFacade share] sendVerfificationCode:countrycode phoneNumber:phonenumber resendCode:NO];
}
-(void) updateMSISDNFailed{
    self.navigationItem.rightBarButtonItem.enabled = YES;
    [[CAlertView new] showError:ERROR_COUNTRY_NOT_SUPPORTED];
}

-(void) sendVerfificationCodeSuccess{
    if ([[ContactFacade share] getReloginFlag]) {
        NSString* phoneNumberFull = [[ContactFacade share] getFullNumber:countryCode phoneNumber:phoneNumber];
        [KeyChainSecurity storeString:countryCode Key:kCOUNTRY_CODE];
        [KeyChainSecurity storeString:phoneNumber Key:kPHONE_NUMBER];
        [KeyChainSecurity storeString:phoneNumberFull Key:kMSISDN];
        [KeyChainSecurity storeString:dialCode Key:kDIAL_CODE];
    }
    
    if (![self.navigationController.topViewController isEqual:[Verification share]]) {
        verificationViewController = [[Verification alloc] init];
        verificationViewController.countryCode = countryCode;
        verificationViewController.phoneNumber = phoneNumber;
        [self.navigationController pushViewController:verificationViewController animated:YES];
    }
    
}
-(void) sendVerfificationCodeSuccessFailed{
    [[CAlertView new] showError:CANNOT_SEND_VERIFY_CODE_NOW];
}

-(void)setCountryConfig{
    NSDictionary *countryWithDialCode = [[ContactFacade share] getCurrentCountryNameWithDialCode];
    [self setupPresentCountryData:countryWithDialCode];
}

-(void) setupPresentCountryData:(NSDictionary *) countryData{
    // Set up data for country list view
    countryListViewController = [[CountryList alloc] init];
    countryListViewController.countryName = [countryData objectForKey:kCOUNTRY_NAME];
    countryListViewController.dialCode = [countryData objectForKey:kDIAL_CODE];
    countryListViewController.countryCode = [countryData objectForKey:kCOUNTRY_CODE];
}


////////////////////////////////////////////////////////////////////////////////////
#pragma mark UITableView
////////////////////////////////////////////////////////////////////////////////////

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.section) {
        case 1:
            return 100;
            break;
        default:
            return 44;
            break;
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    switch (indexPath.section) {
        case 0:
        {
            switch (indexPath.row) {
                case 0:
                {
                    countryListViewController.countryName = self.countryName;
                    [self.navigationController pushViewController:countryListViewController animated:YES];
                }break;
                    
                default:
                    break;
            }
            
        }break;
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
    
    static NSString *cellID = @"CountryCell";
    CountryCell *cell = (CountryCell *)[tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CountryCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    switch (indexPath.section) {
        case 0:{
            
            switch (indexPath.row) {
                case 0:
                {
                    cell.txtFieldNumPhone.hidden = TRUE;
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
                    // Country name
                    if ([countryListViewController.countryName isEqualToString:kUNKNOWN]) {
                        cell.lblCountryCell.text = LABEL_CHOOSE_A_COUNTRY;
                    }else{
                        cell.lblCountryCell.text = countryListViewController.countryName;
                    }
                    countryName = cell.lblCountryCell.text;
                    
                    countryCode = countryListViewController.countryCode;
                    
                }break;
                case 1:
                {
                    txtNumPhone = cell.txtFieldNumPhone;
                    // Prefix phone number
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    cell.lblCountryCell.font = [UIFont systemFontOfSize:FONT_TEXT_SIZE_15];
                    cell.layer.borderWidth = 1;
                    cell.layer.borderColor  = COLOR_211211211.CGColor;
                    paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 14, 14, 40)];
                    cell.txtFieldNumPhone.leftView = paddingView;
                    cell.txtFieldNumPhone.leftViewMode = UITextFieldViewModeAlways;
                    cell.txtFieldNumPhone.font = [UIFont systemFontOfSize:FONT_TEXT_SIZE_15];
                    cell.txtFieldNumPhone.layer.borderWidth = 1;
                    cell.txtFieldNumPhone.layer.borderColor  = COLOR_211211211.CGColor;
                    cell.txtFieldNumPhone.keyboardType = UIKeyboardTypeNumberPad;
                    cell.txtFieldNumPhone.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NUMBER_WITHOUT_COUNTRY_CODE attributes:@{NSForegroundColorAttributeName: COLOR_170170170}];
                    cell.txtFieldNumPhone.delegate = self;
                    phoneNumber = cell.txtFieldNumPhone.text;
                    // Country code
                    if ([countryListViewController.dialCode isEqualToString:kUNKNOWN]) {
                        cell.lblCountryCell.text = @"";
                    }else{
                        cell.lblCountryCell.text = countryListViewController.dialCode;
                    }
                    
                    dialCode = cell.lblCountryCell.text;
                    
                }break;
                    
                default:
                    break;
            }
        }break;
        case 1:{
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = COLOR_247247247;
            cell.lblCountryCell.font = [UIFont systemFontOfSize:14.0f];
            cell.lblCountryCell.textColor = COLOR_128128128;
            cell.lblCountryCell.lineBreakMode = NSLineBreakByWordWrapping;
            cell.lblCountryCell.numberOfLines = 2;
            cell.lblCountryCell.text = PLEASE_CONFIRM_YOUR_COUNTRY_CODE;
            cell.txtFieldNumPhone.hidden = TRUE;
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                           initWithTarget:self
                                           action:@selector(dismissKeyboard)];
            
            [cell addGestureRecognizer:tap];
            
        }break;
            
        default:
            break;
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    for (UIView *contentView in [[cell contentView] subviews]) {
        if([contentView isKindOfClass:[UIView class]]){
            for (UITextField *textField in [contentView subviews]) {
                if ([textField isKindOfClass:[UITextField class] ] && [textField isFirstResponder]) {
                    [textField resignFirstResponder];
                    break;
                }
            }
        }
    }
    
}



- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    
    if (newLength > 0) {
        
        // Enable Save button
        self.navigationItem.rightBarButtonItem.enabled = YES;
        //Store phone number
        phoneNumber = [textField.text stringByAppendingString:string];
        // Return NO if newLength >=MAX_LENGHT_TEXT
        if(newLength >= MAX_LENGHT_TEXT_12 && range.length == 0){
            return NO;
        }
        
    }
    else {
        // Disable the button
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
    return YES;
}

+(SyncContacts *)share{
    static dispatch_once_t once;
    static SyncContacts * share;
    dispatch_once(&once, ^{
        share = [self new];
    });
    return share;
}

@end
