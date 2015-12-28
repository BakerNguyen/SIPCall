//
//  ChatListCell.h
//  JuzChatV2
//
//  Created by TrungVN on 9/24/13.
//  Copyright (c) 2013 mTouche. All rights reserved.
//
#import <UIKit/UIKit.h>

@interface ChatListCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel* lblTime;
@property (nonatomic, weak) IBOutlet UILabel* lblName;
@property (nonatomic, weak) IBOutlet UILabel* lblStatus;
@property (nonatomic, weak) IBOutlet UIImageView* imgAvatar;
@property (nonatomic, weak) IBOutlet UIView* separateView;
@property (nonatomic, weak) IBOutlet UILabel* lblUnreadMessage;
@property (weak, nonatomic) IBOutlet UIImageView *imgCall;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *widthCallIConConstrant;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *horizontalSpaceStatusAndImgCall;

@end
