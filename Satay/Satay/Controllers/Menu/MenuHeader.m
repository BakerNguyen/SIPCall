//
//  MenuHeader.m
//  KryptoChat
//
//  Created by TrungVN on 4/14/14.
//  Copyright (c) 2014 mTouche. All rights reserved.
//

#import "MenuHeader.h"
#import "SideBar.h"
#import "MyProfile.h"

@implementation MenuHeader

@synthesize imgProfile, lblName, lblStatus;

-(void) willMoveToSuperview:(UIView *)newSuperview{
    UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showMyProfile)];
    [self addGestureRecognizer:tapGesture];
    imgProfile.layer.cornerRadius = imgProfile.frame.size.width/2;
}

-(void)showMyProfile{
    [[SideBar share] presentViewController:[[UINavigationController alloc] initWithRootViewController:[MyProfile share]] animated:TRUE completion:nil];
}


@end
