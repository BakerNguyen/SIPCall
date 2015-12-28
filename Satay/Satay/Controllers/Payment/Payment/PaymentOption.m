//
//  PaymentOption.m
//  Satay
//
//  Created by enclave on 1/27/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import "PaymentOption.h"
//#import "UIButton+AppStore.h"
#import "PasscodeView.h"
#import "InAppPurchase.h"
#import "LogIn.h"
#import "CButton.h"

#import "Themer.h"

@interface PaymentOption ()

@end

@implementation PaymentOption
@synthesize bntRestore_IAP,btnInAppPurchase;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationItem setHidesBackButton:NO];
    
    [self setTitle:TITLE_PAYMENT_OPTION];
    
    btnInAppPurchase.layer.borderColor = bntRestore_IAP.layer.borderColor  = [COLOR_48147213 CGColor];
    
}



- (IBAction)press_button:(UIButton *)sender {
    sender.backgroundColor = COLOR_48147213;
    
}


- (IBAction)release_button:(UIButton *)sender {
    sender.backgroundColor = [UIColor whiteColor];
    
}


+(PaymentOption *)share{
    static dispatch_once_t once;
    static PaymentOption * share;
    dispatch_once(&once, ^{
        share = [self new];
    });
    return share;
}
@end
