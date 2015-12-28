//
//  ContactBookCell.h
//  KryptoChat
//
//  Created by TrungVN on 5/6/14.
//  Copyright (c) 2014 mTouche. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContactBookCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UIImageView* checkBox;

@property (nonatomic, retain) IBOutlet UIView* containerView;

@property (nonatomic, retain) IBOutlet UIImageView* imgAvatar;
@property (nonatomic, retain) IBOutlet UILabel* lblName;
@property (nonatomic, retain) IBOutlet UILabel* lblStatus;
@property (nonatomic, retain) IBOutlet UIView* separateView;

@property (strong, nonatomic) IBOutlet UIImageView *iconKrypto;


@end
