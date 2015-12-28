//
//  InAppPurchaseCell.m
//  Satay
//
//  Created by enclave on 1/27/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import "InAppPurchaseCell.h"
//#import "UIButton+AppStore.h"
#import "InAppPurchase.h"


@implementation InAppPurchaseCell
@synthesize lbl_period,btn_pricetag,pricetag;

-(void)viewDidLoad
{


}

- (void)layoutSubviews
{
   // UIColor *blue = [UIColor colorWithRed:0.041 green:0.375 blue:0.998 alpha:1.000];
   // btn_pricetag = [UIButton ASButtonWithFrame:CGRectMake(197, 12, 90, 40)  Color:blue title:pricetag];
    
    [btn_pricetag addTarget:self action:@selector(chooseInAppPurchase:) forControlEvents:UIControlEventTouchUpInside];
    [[self contentView] addSubview:btn_pricetag];
}

-(void)chooseInAppPurchase:(id)sender
{
    if(![InAppPurchase share].IAPSelected)
    {
        if(btn_pricetag.tag==0) //First time press
        {
            [btn_pricetag setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            btn_pricetag.layer.borderColor = [[UIColor grayColor] CGColor];
            btn_pricetag.enabled = NO;
            btn_pricetag.tag=1;
            //[self.delegate InAppPurchaseButtonAction:product];
            [InAppPurchase share].IAPSelected = YES;
        }
        else
        {
           // DDLogCVerbose(@"Wait...loading.");
        }
    }
    else
    {
         // [[CAlertView new] showError:ERROR_ONLY_CAN_CHOOSE_ONE_TYPE_IAP];
        
    }
}

@end
