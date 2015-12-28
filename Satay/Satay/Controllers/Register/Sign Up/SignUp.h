//
//  SignUp.h
//  KryptoChat
//
//  Created by enclave on 2/10/15.
//  Copyright (c) 2015 mTouche. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SignUp : UIViewController <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *txtFieldSetPassword;
@property (weak, nonatomic) IBOutlet UITextField *txtFieldConfirmPassword;
@property (weak, nonatomic) IBOutlet UITextField *txtFieldDisplayName;
@property (weak, nonatomic) IBOutlet UILabel *labelKryptoID;
@property (weak, nonatomic) IBOutlet UILabel *labelHintKryptoID;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
+(SignUp *)share;

@end
