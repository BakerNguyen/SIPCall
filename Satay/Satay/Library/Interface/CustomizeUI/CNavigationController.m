//
//  CNavigationController.m
//  Satay
//
//  Created by TrungVN on 1/15/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import "CNavigationController.h"



@implementation UINavigationController (Customize)

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[self navigationBar] setBackgroundImage:[UIImage imageFromColor:NAV_BAR_COLOR]
                               forBarMetrics:UIBarMetricsDefault];
    [self.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:NAV_BAR_TITLE_COLOR, NSForegroundColorAttributeName,nil]];
    
    [[self navigationBar] setShadowImage:[UIImage new]];
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return [self.topViewController shouldAutorotateToInterfaceOrientation:toInterfaceOrientation];
}

@end
