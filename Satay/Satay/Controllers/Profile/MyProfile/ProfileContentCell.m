//
//  ProfileContentCell.m
//  KryptoChat
//
//  Created by ENCLAVEIT on 4/18/14.
//  Copyright (c) 2014 mTouche. All rights reserved.
//

#import "ProfileContentCell.h"

@implementation ProfileContentCell

@synthesize labelCell;
@synthesize contentCell;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}




@end
