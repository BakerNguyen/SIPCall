//
//  UnblockUserCell.m
//  Satay
//
//  Created by Vi (Violet) T.T. DAO on 5/14/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import "UnblockUserCell.h"

@implementation UnblockUserCell

@synthesize avatar, lblName;

-(void) willMoveToSuperview:(UIView *)newSuperview{    
    avatar.layer.cornerRadius = avatar.frame.size.width/2;
    avatar.clipsToBounds = YES;
}


@end
