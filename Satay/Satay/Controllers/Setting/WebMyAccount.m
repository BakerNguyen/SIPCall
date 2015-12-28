//

//  WebMyAccount.m

//  Satay

//

//  Created by Arpana Sakpal on 2/5/15.

//  Copyright (c) 2015 enclave. All rights reserved.

//



#import "WebMyAccount.h"
#import "NotificationFacade.h"
#import "TransactionHistory.h"

@interface WebMyAccount (){
    CGFloat screenWidth;
    CGFloat screenHeight;
    UIActionSheet* actionSheetHistory;
}

@end



@implementation WebMyAccount

@synthesize kryptoID,started,end,accountStatus,deviceName,webContentMyAccount,container;



-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil

{
    
    self=[super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self)
        
    {
        
        screenWidth = [[UIScreen mainScreen] applicationFrame].size.width;
        screenHeight = [[UIScreen mainScreen] applicationFrame].size.height;
        
    }
    
    return self;
    
}

-(void)viewDidDisappear:(BOOL)animated

{
    [super viewDidDisappear:YES];
    
    [[UIApplication sharedApplication]setStatusBarHidden:NO];
    
    self.navigationController.navigationBar.hidden=NO;
    
}



- (void)viewDidLoad

{
    [ContactFacade share].webMyAccountDelegate = self;
    [super viewDidLoad];
    self.title=TITLE_MY_ACCOUNT;
    
    UIButton* btnBack = [[UIButton alloc] initWithFrame:CGRectMake(10, 0, 50, 40)];
    [btnBack addTarget:self action:@selector(backclick:) forControlEvents:UIControlEventTouchUpInside];
    [btnBack setTitle:_BACK forState:UIControlStateNormal];
    [btnBack.titleLabel setFont:[UIFont systemFontOfSize:15]];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btnBack];
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem createRightButtonTitle:_MORE Target:self Action:@selector(displayActionTransaction)];
    webContentMyAccount.delegate= self;
    // update background container for all size.
    [container changeWidth:screenWidth-container.frame.origin.x*2  Height:container.frame.size.height];
    
}

- (void)displayActionTransaction{
    actionSheetHistory = [[UIActionSheet alloc] initWithTitle:nil
                                delegate:self
                       cancelButtonTitle:_CANCEL
                  destructiveButtonTitle:nil
                       otherButtonTitles:_TRANSACTION, nil];
    [actionSheetHistory showInView:self.view];
}

- (void) getTransactionHistorySuccess:(NSArray*)arrayOfTransaction{
    [[CWindow share] hideLoading];
    [TransactionHistory share].arrayOfTransactionHistory = arrayOfTransaction;
    [self.navigationController pushViewController:[TransactionHistory share] animated:YES];
}

- (void) getTransactionHistoryFail{
    [[CWindow share] hideLoading];
    [TransactionHistory share].arrayOfTransactionHistory = nil;
    [self.navigationController pushViewController:[TransactionHistory share] animated:YES];
}

- (void) openWapPage{
    NSString* url = [KeyChainSecurity getStringFromKey:kACCOUNT_URL];
    
    NSString* accountPage = @"account.php";
    NSString* historyPage = @"history.php";
    url = [url stringByReplacingOccurrencesOfString:accountPage withString:historyPage];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    kryptoID.text = [[ContactFacade share] getMaskingId];
    deviceName.text = [[ContactFacade share] getDeviceName];
    
    NSString* accountStatusString = [KeyChainSecurity getStringFromKey:kACCOUNT_STATUS];
    if ([[accountStatusString lowercaseString] isEqual:ACCOUNT_ACTIVE]) {
        [accountStatus setTextColor:COLOR_2017620];
         accountStatus.text = [ACCOUNT_ACTIVE capitalizedString];
    }
    else{
        [accountStatus setTextColor:COLOR_2336262];
        accountStatus.text = [ACCOUNT_INACTIVE capitalizedString];
    }
    
    started.text = [self convertServerDateToLocal:[KeyChainSecurity getStringFromKey:kSUB_START_DATE]];
    end.text = [self convertServerDateToLocal:[KeyChainSecurity getStringFromKey:kSUB_END_DATE]];
    
    if (started.text == nil || [started.text isEqual:@""]) {
        [[ContactFacade share] getDetailAccount];
        [[CWindow share] showLoading:kLOADING_UPDATING];
    }
}



- (IBAction)backclick:(id)sender {
    [[self navigationController] popViewControllerAnimated:YES];
    
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
    
}

- (void)getDetailAccountSuccess{
    started.text    = [self convertServerDateToLocal:[KeyChainSecurity getStringFromKey:kSUB_START_DATE]];
    end.text        = [self convertServerDateToLocal:[KeyChainSecurity getStringFromKey:kSUB_END_DATE]];
    [[CWindow share] hideLoading];
}

/*
 Jurian, Get the expired date
 Larry request No. 7 in document
 */
-(NSString*) convertServerDateToLocal:(NSString*)dateStr
{
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
    [dateFormat setDateFormat:FORMAT_DATE_DETAIL_ACCOUNT];
    NSDate *date = [dateFormat dateFromString:dateStr]; //CONVERT STRING TO DATE
    [dateFormat setDateFormat:@"MMM dd, yyyy"];
    
    return  [dateFormat stringFromDate:date];
}

- (void)getDetailAccountFail{
    [[CWindow share] hideLoading];
    [[CAlertView new] showError:ERROR_SERVER_GOT_PROBLEM];
}

#pragma mark -  UIActionSheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (buttonIndex)
    {
        case 0://transaction history
            if (![[NotificationFacade share] isInternetConnected]){
                [[CAlertView new] showError:ERROR_REQUIRE_INTERNET];
            }
            else{
                [[CWindow share] showLoading:kLOADING_LOADING];
                [[ContactFacade share] getTransactionHistory];
            }
            break;
            
    }
}

+(WebMyAccount *)share
{
    static dispatch_once_t once;
    static WebMyAccount * share;
    dispatch_once(&once, ^{
        share = [[self alloc] init];
    });
    return share;
}

@end

