//
//  AddFriendButton.m
//  KryptoChat
//
//  Created by Kuan Khim Yoong on 5/9/14.
//  Copyright (c) 2014 mTouche. All rights reserved.
//

#import "AddFriendCounterButton.h"

@implementation AddFriendCounterButton
@synthesize isAddButton;
@synthesize btnAddRequest;

-(void) willMoveToSuperview:(UIView *)newSuperview{
    btnAddRequest.layer.masksToBounds = YES;
    btnAddRequest.layer.cornerRadius = 5.0;
    btnAddRequest.titleLabel.textAlignment = NSTextAlignmentCenter;
    btnAddRequest.layer.borderColor = COLOR_24317741.CGColor;
    btnAddRequest.layer.borderWidth = 1;
    
    [btnAddRequest setBackgroundImage:[UIImage imageFromColor:COLOR_878787] forState:UIControlStateHighlighted];
}

-(void)setButtonTitle: (NSString*) lblTitle{
    [btnAddRequest setTitle:lblTitle forState:UIControlStateNormal];
    [btnAddRequest setTitle:lblTitle forState:UIControlStateHighlighted];
}

@end
