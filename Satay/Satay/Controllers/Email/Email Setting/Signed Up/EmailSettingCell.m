//
//  EmailSettingCell.m
//  Satay
//
//  Created by Nghia (William) T. VO on 7/30/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import "EmailSettingCell.h"

@implementation EmailSettingCell

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
    _lblTitle.hidden = YES;
    _lblValue.hidden = YES;
    _btnSwitch.hidden = YES;
}

@end
