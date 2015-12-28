//
//  CLabel.m
//  Satay
//
//  Created by TrungVN on 2/3/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import "CLabel.h"

@implementation UILabel (Customize)

-(void) fitLabelWidth :(CGFloat) width {
    CGRect frame = self.frame;
    frame.size.width = width;
    frame.size.height = frame.size.height;
    self.frame = frame;
    
    [self sizeToFit];
}

@end
