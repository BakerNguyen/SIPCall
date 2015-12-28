//
//  ChatListm
//  JuzChatV2
//
//  Created by TrungVN on 9/24/13.
//  Copyright (c) 2013 mTouche. All rights reserved.
//
#import "ChatListCell.h"


@implementation ChatListCell

@synthesize lblName, lblStatus, lblTime, imgAvatar, lblUnreadMessage, imgCall;
@synthesize separateView;

-(void) willMoveToSuperview:(UIView *)newSuperview{
    imgAvatar.layer.cornerRadius = imgAvatar.width/2;
    lblUnreadMessage.layer.cornerRadius = lblUnreadMessage.width/2;
}

-(void) setSelected:(BOOL)selected{
    [self setBackgroundColor:selected ? CELL_HIGHLIGHTED_BG_COLOR : [UIColor clearColor]];
}

-(void) setHighlighted:(BOOL)highlighted{
    [self setBackgroundColor:highlighted ? CELL_HIGHLIGHTED_BG_COLOR : [UIColor clearColor]];
}

@end
