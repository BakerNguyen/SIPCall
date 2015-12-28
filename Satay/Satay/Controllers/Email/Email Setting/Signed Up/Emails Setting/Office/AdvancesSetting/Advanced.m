//
//  Advanced.m
//  Satay
//
//  Created by Arpana Sakpal on 3/12/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import "Advanced.h"
#import "Authentication.h"
#import "SyncSchedule.h"
#import "DeleteEmailFromServer.h"
#import "EmailLoginOffice.h"
#import "AdvanceCell.h"
@interface Advanced ()
{
    MailAccount *mailAccountObj;
    NSString *userName;
    BOOL isUpdatedDB;
}
@end

@implementation Advanced
@synthesize tblViewAdvanced,topLine;
@synthesize isImapEmail;
@synthesize strEmailDeletion,strSyncSchedule,strAuthentication;



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
    
    tblViewAdvanced.backgroundColor=COLOR_247247247;
    if(isImapEmail== false)
        numberOfRow =8;
    else
        numberOfRow=6;
    
    self.navigationItem.title=TITLE_ADVANCED;
    self.navigationItem.leftBarButtonItem=[UIBarButtonItem createLeftButtonTitle:_BACK Target:self Action:@selector(cancelToEmailVC)];
    self.navigationItem.rightBarButtonItem=[UIBarButtonItem createRightButtonTitle:_SAVE Target:self Action:@selector(processNext)];
}

- (void)processNext
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)cancelToEmailVC
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)clickedSwitchUseSSL:(id)sender
{
    UISwitch *switchSSL = (UISwitch *)sender;
    if(switchSSL.isOn)
        isUseSSL = 1;
    else
        isUseSSL = 0;
    
    mailAccountObj.incomingUseSSL = [NSString stringWithFormat:@"%d", isUseSSL];
    [[EmailFacade share] updateMailAccount:mailAccountObj];
    mailAccountObj = [[EmailFacade share] getMailAccount:[[EmailFacade share] getEmailAddress]];
    [tblViewAdvanced reloadData];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    userName=[[EmailFacade share]getEmailAddress];
    mailAccountObj=[[EmailFacade share]getMailAccount:userName];
    
    if (mailAccountObj.storeProtocol.integerValue == 0)
        strEmailDeletion = kEmailDeletion_Never;
    else if (mailAccountObj.storeProtocol.integerValue == 1)
        strEmailDeletion = kEmailDeletion_FromInbox;
    // Default values
    if (mailAccountObj.syncSchedule.length > 0)
        strSyncSchedule = mailAccountObj.syncSchedule;
    else
        strSyncSchedule = kEmailSyncSchedule_5Minutes;// default values
    
    NSArray* arrAuthen = [NSMutableArray arrayWithObjects:kEmailAuthentication_Password, kEmailAuthentication_MD5Challenger, kEmailAuthentication_NTLM, kEmailAuthentication_HTTP_MD5, @"", nil];
    strAuthentication = [arrAuthen objectAtIndex:mailAccountObj.outgoingRequireAuth.integerValue];
    [tblViewAdvanced reloadData];
}
- (void)closeViewEmailKeeping
{
    
    self.view.hidden = YES;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (isImapEmail) {
        if (indexPath.row == 0) {
            return 20;
        }else if (indexPath.row == 5){
            return 400;
        }else if (indexPath.row == 2){
            return 50;
        }else
            return 41;
    }else {
        if (indexPath.row == 2 || indexPath.row == 0) {
            return 20;
        }else if (indexPath.row == 7){
            return 400;
        }else if (indexPath.row == 4){
            return 50;
        }else
            return 41;
    }
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return numberOfRow;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger n = indexPath.row;
    if (isImapEmail)
    {
        if (n == 1)
        {
            SyncSchedule *syncScheduleVC= [[SyncSchedule alloc] initWithNibName:nil bundle:nil parent:self];
            syncScheduleVC.syncScheduleString = strSyncSchedule;
            mailAccountObj.periodSyncSchedule=[NSNumber numberWithInteger:[[EmailFacade share]getOrderSyncSchedule:strSyncSchedule]];
            [((Advanced *)parent).navigationController pushViewController:syncScheduleVC animated:YES];
            [self.navigationController pushViewController:syncScheduleVC animated:YES];
        }
        if (n == 4)
        {
            Authentication *authenticationController = [[Authentication alloc] initWithNibName:nil bundle:nil parent:self];
            mailAccountObj.syncSchedule=strSyncSchedule;
            [self.navigationController pushViewController:authenticationController animated:YES];
        }
    }
    else
    {
        if (n== 1)
        {
            DeleteEmailFromServer *emailDeleteFromServerVC = [[DeleteEmailFromServer alloc] initWithNibName:nil bundle:nil parent:self];
            emailDeleteFromServerVC.emailDeletionStr = strEmailDeletion;
            [((Advanced *)parent).navigationController pushViewController:emailDeleteFromServerVC animated:YES];
            [self.navigationController pushViewController:emailDeleteFromServerVC animated:YES];
        }
        
        if (n == 3)
        {
            SyncSchedule *syncController = [[SyncSchedule alloc] initWithNibName:nil bundle:nil parent:self];
            syncController.syncScheduleString = strSyncSchedule;
            mailAccountObj.periodSyncSchedule=[NSNumber numberWithInteger:[[EmailFacade share]getOrderSyncSchedule:strSyncSchedule]];
            [((Advanced *)parent).navigationController pushViewController:syncController animated:YES];
            [self.navigationController pushViewController:syncController animated:YES];
        }
        if (n == 6)
        {
            Authentication *authenticationController = [[Authentication alloc] initWithNibName:nil bundle:nil parent:self];
            [self.navigationController pushViewController:authenticationController animated:YES];
        }
    }
    isUpdatedDB=[[EmailFacade share]updateMailAccount:mailAccountObj];
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *CellIdentifier = @"AdvanceCell";
    
    AdvanceCell *cell = [tblViewAdvanced dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"AdvanceCell" owner:nil options:nil];
        cell = (AdvanceCell*)[nib objectAtIndex:0];
    }
    
    NSInteger n = indexPath.row;
    if (isImapEmail)
    {
        switch (n)
        {
            case 0:
            {
                cell.accessoryType = UITableViewCellAccessoryNone;
                cell.backgroundColor = COLOR_247247247;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
                break;
            case 1:
            {
                cell.lblTitle.hidden = NO;
                cell.lblTitle.text = LABEL_SYNC_SCHEDULE;
                cell.lblContent.hidden = NO;
                cell.lblContent.text = strSyncSchedule;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
                break;
            case 2:
            {
                cell.backgroundColor = COLOR_247247247;
                cell.lblTitle.hidden = NO;
                cell.lblTitle.text = LABEL_INCOMING_SETTING;
                cell.lblTitle.font = [UIFont systemFontOfSize:15];
                cell.userInteractionEnabled = NO;
            }
                break;
            case 3:
            {
                cell.lblTitle.hidden = NO;
                cell.lblTitle.text = LABEL_USE_SSL;
                cell.lblTitle.font = [UIFont systemFontOfSize:15];
                cell.btnSwitch.hidden = NO;
                [cell.btnSwitch addTarget:self
                                   action:@selector(clickedSwitchUseSSL:)
                         forControlEvents:(UIControlEventTouchUpInside | UIControlEventTouchDragExit)];
                if ([mailAccountObj.incomingUseSSL  isEqual: @"1"])
                    [cell.btnSwitch setOn:YES animated:YES];
                else if ([mailAccountObj.incomingUseSSL  isEqual: @"0"])
                    [cell.btnSwitch setOn:NO animated:YES];
            }
                break;
            case 4:
            {
                cell.lblTitle.hidden = NO;
                cell.lblTitle.text = LABEL_AUTHENTICATION;
                cell.lblTitle.font = [UIFont systemFontOfSize:15];
                cell.lblContent.hidden = NO;
                cell.lblContent.text = strAuthentication;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
                break;
            case 5:
            {
                cell.backgroundColor = COLOR_247247247;
                cell.userInteractionEnabled = NO;
            }
                break;
            default:
                break;
        }
    }
    else
    {
        switch (n)
        {
            case 0:
            {
                cell.userInteractionEnabled = NO;
            }
            case 2:
            {
                cell.accessoryType = UITableViewCellAccessoryNone;
                cell.backgroundColor =COLOR_247247247;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
                break;
            case 1:
            {
                cell.lblTitle.hidden = NO;
                cell.lblTitle.text = LABEL_DELETE_EMAIL_FROM_SERVER;
                cell.lblContent.hidden = NO;
                cell.lblContent.text = strEmailDeletion;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
                break;
            case 3:
            {
                cell.lblTitle.hidden = NO;
                cell.lblTitle.text = LABEL_SYNC_SCHEDULE;
                cell.lblContent.hidden = NO;
                cell.lblContent.text = strSyncSchedule;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
                break;
            case 4:
            {
                cell.backgroundColor = COLOR_247247247;
                cell.lblTitle.hidden = NO;
                cell.lblTitle.text = LABEL_INCOMING_SETTING;
                cell.lblTitle.font = [UIFont systemFontOfSize:15];
                cell.userInteractionEnabled = NO;
            }
                break;
            case 5:
            {
                cell.lblTitle.hidden = NO;
                cell.lblTitle.text = LABEL_USE_SSL;
                cell.lblTitle.font = [UIFont systemFontOfSize:15];
                cell.btnSwitch.hidden = NO;
                [cell.btnSwitch addTarget:self
                                   action:@selector(clickedSwitchUseSSL:)
                         forControlEvents:(UIControlEventTouchUpInside | UIControlEventTouchDragExit)];
                if ([mailAccountObj.incomingUseSSL  isEqual: @"1"])
                    [cell.btnSwitch setOn:YES animated:YES];
                else if ([mailAccountObj.incomingUseSSL  isEqual: @"0"])
                    [cell.btnSwitch setOn:NO animated:YES];
            }
                break;
            case 6:
            {
                cell.lblTitle.hidden = NO;
                cell.lblTitle.text = LABEL_AUTHENTICATION;
                cell.lblTitle.font = [UIFont systemFontOfSize:15];
                cell.lblContent.hidden = NO;
                cell.lblContent.text = strAuthentication;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
                break;
            case 7:
            {
                cell.backgroundColor = COLOR_247247247;
                cell.userInteractionEnabled = NO;
            }
                break;
            default:
                break;
        }
    }
    
    return cell;
}



@end
