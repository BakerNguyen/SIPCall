//
//  EnablePasswordLock.h
//  Satay
//
//  Created by Vi (Violet) T.T. DAO on 5/11/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EnablePasswordLock : UIViewController<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *txtFieldSetPassword;
@property (weak, nonatomic) IBOutlet UITextField *txtFieldConfirmPassword;

+(EnablePasswordLock *)share;

-(void) enablePasswordLockSuccess;
-(void) enablePasswordLockFailed;

@end
