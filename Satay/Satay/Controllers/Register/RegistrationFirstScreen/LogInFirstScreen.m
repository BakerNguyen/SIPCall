//
//  LogInFirstScreen.m
//  Satay
//
//  Created by Parker on 2/2/15.
//  Copyright (c) 2014 mTouche. All rights reserved.
//

#import "LogInFirstScreen.h"
#import "SyncContacts.h"

@interface LogInFirstScreen ()

@end

@implementation LogInFirstScreen

@synthesize btnGetStarted,btnLogIn;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    CGSize result = [[UIScreen mainScreen] bounds].size;
    NSString* suffix = @"";
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        // Jurian : Bug 6372:[ios][UI]UI image is display unexpectedly.
        if(result.height == 480)
        {
            suffix = @"_4";
        }
        else if(result.height == 568)
        {
            // iPhone 5
            suffix = @"_5";
        }
        else {
            // iPhone 6
            suffix = @"_6";
            
        }
    }
    else{
        // Waiting launch screen for ipad version
        /*
         From Janice:
         She said we no need cater for ipad ver for satay
         We will have branch new version for iPad later.
         Therefore, we will use this image like temporary solution;
         */
        suffix = @"_5";
    }
    
    NSString* imgName = [NSString stringWithFormat:@"gs_0%d%@.png", 1, suffix];
    self.imageView.image = [UIImage imageNamed:imgName];
    [self.view sendSubviewToBack:self.imageView];
    
    [ContactFacade share].getStartedDelegate = self;
    [ContactFacade share].registerAccountDelegate = self;
    
    //Set account status is pending
    [[ContactFacade share] setAccountStatusPending];
}

-(void)viewWillAppear:(BOOL)animated
{
    btnGetStarted.layer.borderColor = COLOR_24317741.CGColor;
    btnGetStarted.layer.borderWidth = 1;
    btnGetStarted.layer.cornerRadius = 5;
    self.navigationController.navigationBar.hidden = YES;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.hidden = NO;
}

- (void)getStarted {
#warning needed to removed in future.
    //This code part only for VNese testing with jailbroken device. need to remove later.
    if ([[[[ContactFacade share] getCurrentCountryNameWithDialCode] objectForKey:kCOUNTRY_CODE] isEqualToString:@"VN"]) {
        //Register free trial account
        if (![[ContactFacade share] getRegisterFlag] || ![[ContactFacade share] getRegisterFlag]) {
            [[ContactFacade share] getStartedAccount];
        }else{
            [self.navigationController pushViewController:[SyncContacts share] animated:YES];
        }
        
        return;
    }
    //-------------------
    
    if ([AppFacade isJailbroken]) {
        [[CAlertView new] showError:ERROR_JAILBROKEN];
    }
    else{
        //Register free trial account
        if (![[ContactFacade share] getRegisterFlag]) {
             [[ContactFacade share] getStartedAccount];
        }else{
            [self.navigationController pushViewController:[SyncContacts share] animated:YES];
        }
    }
}

-(void) getStartedSuccess{
    [[ContactFacade share] registerAccount:1];
}
-(void) getStartedFailed{
    [[CAlertView new] showError:ERROR_CAN_NOT_REGISTER_ACCOUNT];
}

-(void) registerAccountSuccess{
    //Move to Sign Up view to enter pass
    [[ContactFacade share] getDetailAccount];
    [self.navigationController pushViewController:[SyncContacts share] animated:YES];
}
-(void) registerAccountFailed{
    [[CAlertView new] showError:ERROR_CAN_NOT_REGISTER_ACCOUNT];
}

- (IBAction)login:(id)sender {
    [[CWindow share] showLoginScreen];
}

+(LogInFirstScreen *)share{
    static dispatch_once_t once;
    static LogInFirstScreen * share;
    dispatch_once(&once, ^{
        share = [self new];
    });
    return share;
}

@end
