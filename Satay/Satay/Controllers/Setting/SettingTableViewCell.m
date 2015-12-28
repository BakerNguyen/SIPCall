//
//  SettingTableViewCell.m
//  Satay
//
//  Created by Duong (Daryl) H. DANG on 5/18/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import "SettingTableViewCell.h"

@implementation SettingTableViewCell

- (void)awakeFromNib {
    // Initialization code
    [self initCellView];
    
}

-(void)prepareForReuse
{
    [self initCellView];
}

-(void)initCellView
{
    self.lblInfo.textColor = [UIColor blackColor];
    self.lblTitle.textColor = [UIColor blackColor];
    self.userInteractionEnabled = YES;
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    self.selectionStyle=UITableViewCellSelectionStyleNone;
    self.btnSwitch.hidden = YES;
    [self.btnSwitch removeTarget:nil action:NULL forControlEvents:UIControlEventValueChanged];
    self.lblInfo.hidden = YES;

}

@end
