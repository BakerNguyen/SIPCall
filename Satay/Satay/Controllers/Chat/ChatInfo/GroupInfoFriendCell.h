//
//  GroupInfoFriendCell.h
//  KryptoChat
//
//  Created by TrungVN on 6/25/14.
//  Copyright (c) 2014 mTouche. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GroupInfoFriendCell : UITableViewCell

@property (nonatomic, retain) NSString* uniqueTag;

@property (nonatomic, retain) IBOutlet UILabel* lblName;
@property (nonatomic, retain) IBOutlet UILabel* lblStatus;
@property (nonatomic, retain) IBOutlet UIImageView* imgAvatar;
@property (weak, nonatomic) IBOutlet UIView *underLine;

@property (nonatomic, retain) IBOutlet UILabel* lblGroupAdmin;

@end
