//
//  CSecureTextField.m
//  Satay
//
//  Created by Vi (Violet) T.T. DAO on 5/29/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import "CSecureTextField.h"

@implementation UITextField (Customize)


-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [self becomeFirstResponder];
}

-(BOOL) gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    if (self.secureTextEntry) {
        return NO;
    }
    return [super gestureRecognizerShouldBegin:gestureRecognizer];
}

@end
