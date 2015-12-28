//
//  VerificationCell.m
//  KryptoChat
//
//  Created by ENCLAVEIT on 4/25/14.
//  Copyright (c) 2014 mTouche. All rights reserved.
//

#import "VerificationCell.h"

@implementation VerificationCell

@synthesize leftLabelForCell;
@synthesize rightLabelForCell;
@synthesize txtFieldForCell;


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
