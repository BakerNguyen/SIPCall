//
//  LogIn.m
//  Satay
//
//  Created by enclave on 1/27/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import "LogIn.h"

#import "CWindow.h"
#import "PaymentOption.h"
#import "SyncContacts.h"

@interface LogIn ()

{
    //UIButton *buttonClose;
    NSString *loginID;
    NSString *password;
    UIActivityIndicatorView * loadingview;
}
@end

@implementation LogIn
@synthesize  LogIn2CellName,tblLogIn,pushView;

int count_maskingid = 0;
int count_password = 0;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem createLeftButtonTitle:_BACK Target:self Action:@selector(back)];
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem createRightButtonTitle:TITLE_LOGIN Target:self Action:@selector(logIn)];
    self.navigationItem.rightBarButtonItem.enabled = NO;
   
    self.navigationItem.title = TITLE_LOGIN;
    
    LogIn2CellName = [[NSMutableArray alloc] initWithArray:@[LABEL_ZIPIT_CHAT_ID,LABEL_PASSWORD]];
    
    tblLogIn.backgroundColor = COLOR_247247247;
    
    loadingview = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    loadingview.layer.backgroundColor = [[UIColor colorWithWhite:0.0f alpha:0.5f] CGColor];
    loadingview.hidesWhenStopped = YES;
    loadingview.frame = CGRectMake(0.0f, 0.0f,
                                   [UIScreen mainScreen].bounds.size.width,
                                   [UIScreen mainScreen].bounds.size.height);
    
    [ContactFacade share].signInAccountDelegate = self;

}

-(void)back
{
    if([pushView isEqualToString:@"payment"])
        [CWindow share].rootViewController = [[UINavigationController alloc] initWithRootViewController:[PaymentOption share]];
    else
        [[CWindow share] showLoginFirstScreen];
    
    pushView = @"";
}
-(void)logIn
{
    [self.view endEditing:YES];
    
    if ([[ContactFacade share] isAccountRemoved]) {
        [[CAlertView new] showError:ERROR_ACCOUNT_REMOVED];
        return;
    }
    
    if(![[NotificationFacade share] isInternetConnected]){
        [[CAlertView new] showError:NO_INTERNET_CONNECTION_TRY_LATER];
        return;
    }
    
    // Call API here
    NSString *maskingid = [loginID uppercaseString];
    [[ContactFacade share] signInAccount:maskingid password:password];
}

-(void) signInAccountSuccess{
    
    //[[CWindow share] showApplicationForLogin];
    [self.navigationController pushViewController:[SyncContacts share] animated:YES];

}

-(void)signInAccountBlocked{
    CAlertView *alert = [CAlertView new];
    [alert showError:mError_WrongPasswordTenTimes];
    [alert setOnButtonTouchUpInside:^(CAlertView *alertView, int buttonIndex){
        [[ContactFacade share] resetAccount];
    }];
}

-(void) serverMainternanceNotification:(NSString*)mainteranceMSG{
    CAlertView *alert = [CAlertView new];
    [alert showInfo:mainteranceMSG];
    [alert setOnButtonTouchUpInside:^(CAlertView *alertView, int buttonIndex){
        [[CWindow share] showApplication];;
    }];
}

-(void) signInAccountFailed{
    [[CAlertView new] showError:NSLocalizedString(ERROR_INVALID_SIGN_IN, nil)];
}

-(void) signInAccountMaskingIDInvalid{
    [[CAlertView new] showError:NSLocalizedString(mError_MaskingIdIsInvalid, nil)];
}

-(void) signInAccountNotFound{
    [[CAlertView new] showError:NSLocalizedString(mError_AccountNotFound, nil)];
}

-(void) signInAccountWrongPassword
{
    int countWrongPassword = [[[AppFacade share] getCountWrongPasswordKey] intValue] + 1;
    [[AppFacade share] setCountWrongPasswordKey:[NSString stringWithFormat:@"%d", countWrongPassword]];
    
    if (countWrongPassword == 5)
        [[CAlertView new] showError:[NSString stringWithFormat:mError_WrongPasswordFiveTimes, countWrongPassword, countWrongPassword]];
    else
        [[CAlertView new] showError:mError_IncorrectPassword];
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [loadingview stopAnimating];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
	return 1;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [LogIn2CellName count];
    
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellID =  @"LogInViewCell";
    
    if(indexPath.row==0)
    {
        LogInViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        
        if(!cell){
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"LogInViewCell" owner:nil options:nil];
            cell = (LogInViewCell*)[nib objectAtIndex:0];
        }
        
        cell.delegate = self;
        NSString *placeHolder  = [LogIn2CellName objectAtIndex:indexPath.row];
        
        cell.cellNaming_PlaceHolder = placeHolder;
        cell.txtLogin.text =@"";
        cell.backgroundColor = [UIColor whiteColor];
        
        return cell;
    }
    else
    {
        LoginPasswordCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        
        if(!cell){
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"LoginPasswordCell" owner:nil options:nil];
            cell = (LoginPasswordCell*)[nib objectAtIndex:0];
        }
        
        cell.delegate = self;
        NSString *placeHolder  = [LogIn2CellName objectAtIndex:indexPath.row];
        
        cell.cellNaming_PlaceHolder = placeHolder;
        cell.txtLogin.text =@"";
        cell.backgroundColor = [UIColor whiteColor];
        
        return cell;
    }
}

-(void)checkLogInButton
{
    if((count_maskingid >5) && (count_password > 5))
        self.navigationItem.rightBarButtonItem.enabled = YES;
    else
        self.navigationItem.rightBarButtonItem.enabled = NO;
}

-(void)LogInPasswordCellAction:(NSString *)name count:(int)text_count
{
    count_password = 0;
    count_password = count_password +text_count;
    password = name;
    [self checkLogInButton];
}

- (void)LogInViewCellAction:(NSString*)name count:(int)text_count
{
    count_maskingid = 0;
    count_maskingid = count_maskingid + text_count;
    loginID = name;
    [self checkLogInButton];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [tblLogIn reloadData];
    count_maskingid = 0;
    count_password = 0;
    self.navigationItem.rightBarButtonItem.enabled = NO;
}

+(LogIn *)share{
    static dispatch_once_t once;
    static LogIn * share;
    dispatch_once(&once, ^{
        share = [self new];
    });
    return share;
}

@end
