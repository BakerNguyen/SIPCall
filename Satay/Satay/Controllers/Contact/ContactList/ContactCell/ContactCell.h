//
//  FriendListCell.h
//  JuzChatV2
//
//  Created by TrungVN on 9/20/13.
//  Copyright (c) 2013 mTouche. All rights reserved.
//
#import <UIKit/UIKit.h>

@interface ContactCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIView* separateView;
@property (nonatomic, weak) IBOutlet UILabel* lblBuddyName;
@property (nonatomic, weak) IBOutlet UILabel* lblStatus;
@property (nonatomic, weak) IBOutlet UIImageView* imgAvatar;

@end
