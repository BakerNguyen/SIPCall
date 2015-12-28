//
//  ContactBookCell.m
//  KryptoChat
//
//  Created by TrungVN on 5/6/14.
//  Copyright (c) 2014 mTouche. All rights reserved.
//

#import "ContactBookCell.h"

@implementation ContactBookCell

@synthesize lblName, lblStatus, separateView, imgAvatar;
@synthesize containerView;
@synthesize checkBox;

-(void) willMoveToSuperview:(UIView *)newSuperview{
    imgAvatar.layer.cornerRadius = imgAvatar.width/2;
}

@end

