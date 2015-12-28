//
//  GroupInfoFriendCell.m
//  KryptoChat
//
//  Created by TrungVN on 6/25/14.
//  Copyright (c) 2014 mTouche. All rights reserved.
//

#import "GroupInfoFriendCell.h"

@implementation GroupInfoFriendCell

@synthesize lblName, lblStatus, imgAvatar;
@synthesize lblGroupAdmin;
@synthesize underLine;
@synthesize uniqueTag;

-(void) willMoveToSuperview:(UIView *)newSuperview{
    imgAvatar.layer.cornerRadius = imgAvatar.frame.size.width/2;
    lblStatus.hidden = TRUE;
}

@end
