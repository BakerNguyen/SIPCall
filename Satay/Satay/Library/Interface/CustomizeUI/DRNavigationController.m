//
//  DRNavigationController.m
//  Satay
//
//  Created by Duong (Daryl) H. DANG on 6/11/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import "DRNavigationController.h"

@interface DRNavigationController ()

//@property (nonatomic) BOOL isSwitchView;
@property (nonatomic, strong) UIViewController *viewControllerInAnimate;

@end

@interface UINavigationController (DMNavigationController)

- (void)didShowViewController:(UIViewController *)viewController animated:(BOOL)animated;

@end

@implementation DRNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)pushViewController:(UIViewController *)viewController
                  animated:(BOOL)animated
{
    /* use for debug later.
    for (UIViewController *viewController1 in self.viewControllers) {
        NSLog(@"Current : %@",viewController1);
    }
    
    NSLog(@"push: %@",viewController);
    NSLog(@"new: %@",self.newestView);
    */
    
    // if current ViewController is animate push or pop is the same with viewController input we skip.
    // if viewController input already in ViewController of navigation we skip.
    if (![self.viewControllerInAnimate isEqual:viewController] && ![self.viewControllers containsObject:viewController]) {
        self.viewControllerInAnimate = viewController;
        @try {
            [super pushViewController:viewController animated:animated];
        } @catch (NSException * exception) {
            NSLog(@"Exception: [%@]:%@",[exception  class], exception );
             [super popToViewController:viewController animated:animated];
        } @finally {
            
        }
    }
}


-(UIViewController *)popViewControllerAnimated:(BOOL)animated
{
    UIViewController *ret = [super popViewControllerAnimated:(BOOL)animated];
    self.viewControllerInAnimate = ret;
    return ret;
}

- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated
{
    NSArray *arrPopViewController = [super popToRootViewControllerAnimated:animated];
    self.viewControllerInAnimate = [arrPopViewController firstObject];
    return arrPopViewController;
}

- (void)didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [super didShowViewController:viewController animated:animated];
    self.viewControllerInAnimate = nil; // Done push or pop we remove this.
}


@end
