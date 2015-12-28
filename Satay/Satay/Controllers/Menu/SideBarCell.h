//
//  SideBarCell.h
//  KryptoChat
//
//  Created by TrungVN on 4/14/14.
//  Copyright (c) 2014 mTouche. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SideBarCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UIImageView* imgCell;
@property (nonatomic, retain) IBOutlet UILabel* lblCell;
@property (nonatomic, retain) IBOutlet UILabel* lblNumberNotification;
@property (weak, nonatomic) IBOutlet UIView *bottomBar;

@end
