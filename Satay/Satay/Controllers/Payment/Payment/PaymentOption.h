//
//  PaymentOption.h
//  Satay
//
//  Created by enclave on 1/27/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Payment_Other.h"

@interface PaymentOption : UIViewController <UIAlertViewDelegate,UINavigationControllerDelegate>

 
@property (weak, nonatomic) IBOutlet UIButton *btnInAppPurchase;
@property (weak, nonatomic) IBOutlet UIButton *bntRestore_IAP;


 
- (IBAction)press_button:(UIButton *)sender;

- (IBAction)release_button:(UIButton *)sender;

+(PaymentOption *)share;
    
@end
