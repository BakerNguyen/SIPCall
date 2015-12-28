//
//  LoginPasswordCell.m
//  Satay
//
//  Created by enclave on 1/27/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import "LoginPasswordCell.h"
#import "Themer.h"

@interface LoginPasswordCell ()

@end

@implementation LoginPasswordCell

@synthesize txtLogin,cellNaming_PlaceHolder;

- (void)viewDidLoad
{
    txtLogin.secureTextEntry = YES;
    
    txtLogin.delegate = self;
    
}

- (void)layoutSubviews
{
    
    txtLogin.secureTextEntry = YES;
    
    txtLogin.delegate = self;
    txtLogin.layer.borderWidth = 0;
    [txtLogin setTextColor:[UIColor blackColor]];
    [txtLogin setValue:COLOR_170170170 forKeyPath:@"_placeholderLabel.textColor"];
    txtLogin.borderStyle = UITextBorderStyleNone;
    txtLogin.placeholder =cellNaming_PlaceHolder;
    
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    
    NSString * actual_text = [textField.text stringByReplacingCharactersInRange:range withString:string];
   
    [self.delegate LogInPasswordCellAction:actual_text count:(int)newLength];
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

@end
