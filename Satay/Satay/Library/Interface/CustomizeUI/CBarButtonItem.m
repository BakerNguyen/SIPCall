//
//  CBarButtonItem.m
//  Satay
//
//  Created by TrungVN on 1/20/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import "CBarButtonItem.h"

@implementation UIBarButtonItem (Customize)

+(UIBarButtonItem*) createLeftButtonTitle:(NSString*) title
                                   Target:(id) target
                                   Action:(SEL)action{
    UIButton* button = [[UIButton alloc] initWithFrame:CGRectMake(-30, 0, 60, 40)];
    [button setTitle:title forState:UIControlStateNormal];
    [[button titleLabel] setFont:[UIFont systemFontOfSize:15]];
    [button setTitleColor:COLOR_131131131 forState:UIControlStateDisabled];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    if([target respondsToSelector:action])
        [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [button sizeToFit];
    
    return [[UIBarButtonItem alloc] initWithCustomView:button];
}

+(UIBarButtonItem*) createRightButtonTitle:(NSString*) title
                                    Target:(id) target
                                    Action:(SEL)action{
    UIButton* button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 85, 40)];
    [button setTitle:title forState:UIControlStateNormal];
    [[button titleLabel] setFont:[UIFont systemFontOfSize:15]];
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [button setTitleColor:COLOR_131131131 forState:UIControlStateDisabled];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button sizeToFit];
    if([target respondsToSelector:action])
        [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];    
    
    return [[UIBarButtonItem alloc] initWithCustomView:button];
}

@end
