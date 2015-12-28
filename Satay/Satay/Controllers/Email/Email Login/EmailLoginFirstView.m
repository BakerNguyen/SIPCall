//
//  EmailLoginFirstView.m
//  Satay
//
//  Created by Arpana Sakpal on 3/10/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import "EmailLoginFirstView.h"
#import "EmailLoginPublic.h"
@interface EmailLoginFirstView ()

@end

@implementation EmailLoginFirstView

+(EmailLoginFirstView *)share{
    static dispatch_once_t once;
    static EmailLoginFirstView * share;
    dispatch_once(&once, ^{
        share = [[self alloc] init];
    });
    return share;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title=TITLE_EMAIL;
    //Create some email folders default
    [[EmailFacade share] createDefaultEmailFolders];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated{
    [[LogFacade share] trackingScreen:Email_Category];
}

- (IBAction)clickdBtnloginToMicrosoftExchange:(id)sender
{
    EmailLoginPublic *public=[[EmailLoginPublic alloc]initWithNibName:@"EmailLoginPublic" bundle:nil ];
    public.emailAccountType=0;
    [self.navigationController pushViewController:public animated:YES];
}

- (IBAction)clickedBtnloginToGmail:(id)sender
{
    EmailLoginPublic *public=[[EmailLoginPublic alloc]initWithNibName:@"EmailLoginPublic" bundle:nil ];
    public.emailAccountType=1;
    [self.navigationController pushViewController:public animated:YES];
    
}

- (IBAction)clickedBtnloginToYahoo:(id)sender
{
    EmailLoginPublic *public=[[EmailLoginPublic alloc]initWithNibName:@"EmailLoginPublic" bundle:nil ];
    public.emailAccountType=2;
    [self.navigationController pushViewController:public animated:YES];
}

- (IBAction)clickedBtnloginToHotmail:(id)sender
{
    EmailLoginPublic *public=[[EmailLoginPublic alloc]initWithNibName:@"EmailLoginPublic" bundle:nil ];
    public.emailAccountType=3;
    [self.navigationController pushViewController:public animated:YES];
}

- (IBAction)clickedBtnloginToOtherMail:(id)sender
{
    EmailLoginPublic *public=[[EmailLoginPublic alloc]initWithNibName:@"EmailLoginPublic" bundle:nil ];
    public.emailAccountType=4;
    [self.navigationController pushViewController:public animated:YES];
}
@end
