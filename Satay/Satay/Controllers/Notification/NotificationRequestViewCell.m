//
//  NtificationRequestViewCell.m
//  Satay
//
//  Created by Arpana Sakpal on 1/20/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import "NotificationRequestViewCell.h"

@implementation NotificationRequestViewCell
@synthesize profileImage,notifyContent;

-(void) willMoveToSuperview:(UIView *)newSuperview{
    profileImage.layer.cornerRadius = profileImage.frame.size.width/2;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}



@end
