//
//  Tutorial.h
//  JuzChatV2
//
//  Created by TrungVN on 10/7/13.
//  Copyright (c) 2013 mTouche. All rights reserved.
//
#import <UIKit/UIKit.h>
@interface Tutorial : UIViewController <UIScrollViewDelegate>
+ (Tutorial *)share;
@property (nonatomic, strong) IBOutlet UIScrollView* tutScroll;
@property (nonatomic, strong) IBOutlet UIPageControl* pageControl;
@property (nonatomic, strong) IBOutlet UIButton* btnStart;
-(IBAction) startJuzChat:(id)sender;
@end
