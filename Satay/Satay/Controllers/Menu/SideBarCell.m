//
//  SideBarCell.m
//  KryptoChat
//
//  Created by TrungVN on 4/14/14.
//  Copyright (c) 2014 mTouche. All rights reserved.
//

#import "SideBarCell.h"

@implementation SideBarCell

@synthesize imgCell, lblCell, lblNumberNotification, bottomBar;

-(void) willMoveToSuperview:(UIView *)newSuperview{
    self.backgroundColor = [UIColor clearColor];
    lblNumberNotification.layer.cornerRadius = lblNumberNotification.frame.size.width/2;
}

-(void) setHighlighted:(BOOL)highlighted{
    [self.imgCell setHighlighted:highlighted];
    [self.lblCell setHighlighted:highlighted];
    if(highlighted)
        self.lblCell.font = [UIFont boldSystemFontOfSize:15];
    else
        self.lblCell.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15];
}

-(void) setSelected:(BOOL)selected{
    [self.imgCell setHighlighted:selected];
    [self.lblCell setHighlighted:selected];
    
    if(selected)
        self.lblCell.font = [UIFont boldSystemFontOfSize:15];
    else
        self.lblCell.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15];
}

@end
