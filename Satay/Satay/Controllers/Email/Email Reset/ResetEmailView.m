//
//  ResetEmailView.m
//  Satay
//
//  Created by Arpana Sakpal on 3/16/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import "ResetEmailView.h"
#include "CWindow.h"
#include "EmailLoginFirstView.h"
@interface ResetEmailView ()

@end

@implementation ResetEmailView

@synthesize emailAccount;



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Create buttons for navigation
    self.navigationItem.title=TITLE_RESET_EMAIL;
    self.navigationItem.leftBarButtonItem=[UIBarButtonItem createLeftButtonTitle:_CANCEL Target:self Action:@selector(cancelViewEmailReset)];

    self.navigationItem.leftBarButtonItem.enabled = YES;

 //   DDLogCVerbose(@"------- Email: %@", emailAccount);
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    
}

-(void) cancelViewEmailReset
{
    [CWindow share].menuController.centerPanel=[[UINavigationController alloc] initWithRootViewController:[EmailLoginFirstView share]];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)clickedBtnEmailReset:(id)sender
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.buttonResetEmail.enabled = NO;
  //  [[EmailManager share] sendEmailForResetToServer:self Email:emailAccount];
}

@end
