//
//  ComposeViewCell.h
//  KryptoChat
//
//  Created by TrungVN on 4/22/14.
//  Copyright (c) 2014 mTouche. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatComposeCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UIImageView* checkBox;

@property (nonatomic, retain) IBOutlet UIView* containerView;

@property (nonatomic, retain) IBOutlet UIImageView* imgAvatar;
@property (nonatomic, retain) IBOutlet UILabel* lblName;
@property (nonatomic, retain) IBOutlet UILabel* lblStatus;
@property (nonatomic, retain) IBOutlet UIView* separateView;

-(void) displayCell:(Contact*) contactInfo;

@end
