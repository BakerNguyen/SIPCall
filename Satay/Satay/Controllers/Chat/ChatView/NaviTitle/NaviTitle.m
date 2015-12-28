//
//  NaviTitle.m
//  JuzChatV2
//
//  Created by Low Ker Jin on 8/26/13.
//  Copyright (c) 2013 mTouche. All rights reserved.
//
#import "NaviTitle.h"
#import "ChatView.h"

@implementation NaviTitle
@synthesize title, subTitle;

-(void) setFrame:(CGRect)frame{
    [super setFrame:CGRectMake(0.0, 0.0, [UIScreen mainScreen].bounds.size.width, 44.0)];
}

-(void) willMoveToSuperview:(UIView *)newSuperview{
    [title changeXAxis:(self.width - title.width)/2 YAxis:title.y];
    [subTitle changeXAxis:(self.width - subTitle.width)/2 YAxis:subTitle.y];
    
    [title addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:[ChatView share] action:@selector(showChatSetting)]];
    [subTitle addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:[ChatView share] action:@selector(showChatSetting)]];
}

@end
