//
//  AdvanceCell.m
//  Satay
//
//  Created by Nghia (William) T. VO on 7/31/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import "AdvanceCell.h"

@implementation AdvanceCell

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
    _lblContent.hidden = YES;
    _btnSwitch.hidden = YES;
}

@end
