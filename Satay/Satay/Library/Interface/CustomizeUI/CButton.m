//
//  CButton.m
//  Satay
//
//  Created by TrungVN on 1/20/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import "CButton.h"

@implementation UIButton (Customize)

-(void) alignCenter{
    [self setTitleEdgeInsets:UIEdgeInsetsMake(0.0, -self.imageView.frame.size.width, -self.imageView.frame.size.width, 0.0)];
    [self setImageEdgeInsets:UIEdgeInsetsMake(-self.imageView.frame.size.width/2, 0.0, 0.0, -self.titleLabel.bounds.size.width)];
    self.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.numberOfLines = 0;
    [self setTitleEdgeInsets:UIEdgeInsetsMake(0.0, -self.imageView.frame.size.width, -self.imageView.frame.size.width, 0.0)];

}

@end
