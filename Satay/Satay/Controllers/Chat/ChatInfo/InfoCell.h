//
//  InfoCell.h
//  KryptoChat
//
//  Created by TrungVN on 6/9/14.
//  Copyright (c) 2014 mTouche. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InfoCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UIView* topBorder;
@property (nonatomic, retain) IBOutlet UILabel* lblTitle;
@property (nonatomic, retain) IBOutlet UIView* bottomBorder;
@property (weak, nonatomic) IBOutlet UILabel *lbTitleContent;
@property (weak, nonatomic) IBOutlet UIImageView *indicator;
@property (weak, nonatomic) IBOutlet UISwitch *btnSwitch;


@property (nonatomic, retain) IBOutlet UILabel* lblHint;

@end
