//
//  EmailSettingNotSignUp.m
//  Satay
//
//  Created by Arpana Sakpal on 3/13/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import "EmailSettingNotSignUp.h"
#import "CWindow.h"
#import "EmailLoginFirstView.h"
@interface EmailSettingNotSignUp ()

@end

@implementation EmailSettingNotSignUp
@synthesize tblView;
@synthesize lblEmailKeeping, lblSetUpEmail;


+ (EmailSettingNotSignUp *)share
{
    static dispatch_once_t once;
    static EmailSettingNotSignUp *share;

    dispatch_once(&once, ^{
        share = [[self alloc] init];
    });
    return share;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];

    if (self)
    {
    }

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    [tblView setDelegate:self];
    [tblView setDataSource:self];
    [tblView setScrollEnabled:NO];
    [tblView setBackgroundColor:COLOR_247247247];

    self.navigationItem.rightBarButtonItem = [UIBarButtonItem createRightButtonTitle:_CLOSE Target:self Action:@selector(closeViewEmailSetting)];
    self.navigationItem.title = TITLE_SETTING;

    self.navigationItem.hidesBackButton = YES;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewDidLoad];
    [[LogFacade share] trackingScreen:Email_Category];
}

- (void)closeViewEmailSetting
{
    [[self navigationController] popViewControllerAnimated:TRUE];
    //[[CWindow share].menuController showLeftPanelAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
    {
        return 41;
    }
    else
    {
        return 568;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
    {
        [CWindow share].menuController.centerPanel = [[UINavigationController alloc]initWithRootViewController:[EmailLoginFirstView share]];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"CellIdentifier";
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellID];

    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }

    if (indexPath.row == 0)
    {
        lblSetUpEmail.frame = CGRectMake(20, 0, 100, 41);

        lblSetUpEmail.text = LABEL_SET_UP_EMAIL;
        [cell addSubview:lblSetUpEmail];

        lblEmailKeeping.frame  = CGRectMake(200, 0, 90, 41);

        lblEmailKeeping.text = LABEL_NONE;
        [cell addSubview:lblEmailKeeping];

        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    }
    else
    {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = COLOR_247247247;
    }

    return cell;
}

@end
