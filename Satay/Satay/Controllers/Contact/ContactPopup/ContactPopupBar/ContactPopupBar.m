//
//  NavBarPopup.m
//  KryptoChat
//
//  Created by TrungVN on 4/18/14.
//  Copyright (c) 2014 mTouche. All rights reserved.
//

#import "ContactPopupBar.h"

@implementation ContactPopupBar

@synthesize lblStatus, lblTitle, btnClose;

-(void) setFrame:(CGRect)frame{
    [super setFrame:CGRectMake(0.0, 0.0, [[UIScreen mainScreen] bounds].size.width, 44.0)];
}

@end
