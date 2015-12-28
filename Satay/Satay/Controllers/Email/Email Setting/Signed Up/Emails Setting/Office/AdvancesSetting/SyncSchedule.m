//
//  SyncSchedule.m
//  Satay
//
//  Created by Arpana Sakpal on 3/12/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import "SyncSchedule.h"
#import "EmailLoginOffice.h"
#import "Advanced.h"
#import "EmailLoginOffice.h"
#import "BackgroundTask.h"
@interface SyncSchedule ()
{
    MailAccount *mailAccountObj;
    BOOL isUpdatedDB;
    NSString *userName;
}
@end

@implementation SyncSchedule

@synthesize tblViewSyncSchedule;
@synthesize checkedIndexPath;
@synthesize allValues;
@synthesize syncScheduleString;
@synthesize numSyncString;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil parent:(id)_parent
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        parent = _parent;
        // Custom initialization
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title=TITLE_SYNC_SCHEDULE;
    self.navigationItem.hidesBackButton = YES;
    
    allValues = [NSMutableArray arrayWithObjects:kEmailSyncSchedule_Never, kEmailSyncSchedule_5Minutes, kEmailSyncSchedule_15Minutes, kEmailSyncSchedule_1Hour, kEmailSyncSchedule_2Hours, nil];
    
    tblViewSyncSchedule.scrollEnabled = NO;
    
    self.navigationItem.leftBarButtonItem=[UIBarButtonItem createLeftButtonTitle:_BACK Target:self Action:@selector(cancelToEmailVC)];
    
    self.navigationItem.rightBarButtonItem=[UIBarButtonItem createRightButtonTitle:_SAVE Target:self Action:@selector(processNext)];
    
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    userName=[[EmailFacade share]getEmailAddress];
    mailAccountObj=[[EmailFacade share ]getMailAccount:userName];
}

- (void)processNext
{
    if ([parent isKindOfClass:[EmailLoginOffice class]])
    {
        ((EmailLoginOffice*)parent).strSyncSchedule = syncScheduleString;
        [((EmailLoginOffice*)parent).tblBottom reloadData];
    }
    else if ([parent isKindOfClass:[Advanced class]])
    {
        mailAccountObj.periodSyncSchedule=[NSNumber numberWithInteger:[[EmailFacade share]getOrderSyncSchedule:syncScheduleString]];
        mailAccountObj.syncSchedule = syncScheduleString;
        isUpdatedDB=[[EmailFacade share]updateMailAccount:mailAccountObj];
        mailAccountObj = [[EmailFacade share] getMailAccount:[[EmailFacade share] getEmailAddress]];
        if(isUpdatedDB)
        {
            [[EmailFacade share] startNewSyncSchedule:mailAccountObj.periodSyncSchedule.integerValue];
            ((Advanced *)parent).strSyncSchedule=syncScheduleString;
        }
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)cancelToEmailVC
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


////////////////////////////////////////////////////////////////////////////////////
#pragma mark UITableView
////////////////////////////////////////////////////////////////////////////////////

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.row == 6) {
        
        return 568;
        
    }else if (indexPath.row == 0) {
        
        return 20;
        
    }else
        return 41;
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return 7;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [self.tblViewSyncSchedule deselectRowAtIndexPath:indexPath animated:YES];
    
    int n = (int)indexPath.row;
    
    if (n == 0 || n == 6)
    {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.userInteractionEnabled = NO;
    }
    
    else
    {
        if (self.checkedIndexPath)
        {
            UITableViewCell *uncheckCell = [tableView cellForRowAtIndexPath:self.checkedIndexPath];
            uncheckCell.accessoryType = UITableViewCellAccessoryNone;
        }
        if ([self.checkedIndexPath isEqual:indexPath])
        {
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        else
        {
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            self.checkedIndexPath = indexPath;
            syncScheduleString = cell.textLabel.text;
            numSyncString=n-1;
        }
    }
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *CellIdentifier = @"CellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (nil == cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier];
    }
    
    int n = (int)indexPath.row;
    
    if (n == 0 || n == 6) {
        [cell setSeparatorInset:UIEdgeInsetsMake(0,0, 0,0)];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = COLOR_247247247;
    }
    else
    {
        if (n == 5)
        {
            [cell setSeparatorInset:UIEdgeInsetsMake(0,0, 0,0)];
        }
        
        cell.textLabel.font = [UIFont systemFontOfSize:16];
        // Configure the cell.
        cell.textLabel.text = [allValues
                               objectAtIndex:n-1];
        
        if ([cell.textLabel.text isEqualToString:syncScheduleString]) {
            
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            self.checkedIndexPath = indexPath;
        }
        else
        {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    return cell;
}


@end