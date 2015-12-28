//
//  ResetEmailFinalPage.m
//  Satay
//
//  Created by Arpana Sakpal on 3/16/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import "ResetEmailFinalPage.h"
#import "CWindow.h"
#import "EmailLoginFirstView.h"
@interface ResetEmailFinalPage ()

@end

@implementation ResetEmailFinalPage

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title=TITLE_RESET_EMAIL;
    self.navigationItem.rightBarButtonItem=[UIBarButtonItem createRightButtonTitle:_CLOSE Target:self Action:@selector(closeViewEmailReset)];
        self.navigationItem.hidesBackButton = YES;

}

-(void) closeViewEmailReset {
    [CWindow share].menuController.centerPanel=[[UINavigationController alloc] initWithRootViewController:[EmailLoginFirstView share]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
