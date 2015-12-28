//
//  FriendListCell.m
//  JuzChatV2
//
//  Created by TrungVN on 9/20/13.
//  Copyright (c) 2013 mTouche. All rights reserved.
//
#import "ContactCell.h"


@implementation ContactCell

@synthesize separateView;
@synthesize lblBuddyName, lblStatus, imgAvatar;

-(void) willMoveToSuperview:(UIView *)newSuperview{
    imgAvatar.layer.cornerRadius = imgAvatar.width/2;
    imgAvatar.contentMode = UIViewContentModeScaleAspectFill;
}

-(void) setSelected:(BOOL)selected{
    [self setBackgroundColor:[UIColor clearColor]];
}

-(void) setHighlighted:(BOOL)highlighted{
    [self setBackgroundColor:highlighted ? CELL_HIGHLIGHTED_BG_COLOR:[UIColor clearColor]];
}

@end
