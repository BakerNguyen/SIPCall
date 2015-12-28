//
//  SettingsViewController.m
//  Satay
//
//  Created by Arpana Sakpal on 2/4/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import "AppDelegate.h"
#import "SettingsViewController.h"
#import "EmailSetting.h"
#import "PasscodeView.h"
#import "EmailSettingNotSignUp.h"
#import "EnablePasswordLock.h"
#import "BlockUsersController.h"
#import "SettingTableViewCell.h"
#import "ManageStorageView.h"
#import "FAQ.h"
#import "ContactUs.h"


@interface SettingsViewController ()

@end

@implementation SettingsViewController
@synthesize lblnetworkStatus;
@synthesize tblSettingMenu;


+(SettingsViewController *)share
{
    static dispatch_once_t once;
    static SettingsViewController * share;
    dispatch_once(&once, ^{
        share = [[self alloc] init];
    });
    return share;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [XMPPFacade share].appSettingDelegate = self;
    [AppFacade share].appSettingDelegate = self;
    
    self.title=TITLE_SETTING;
    lblnetworkStatus.text = mNETWORK_DISCONNECTED;
    lblnetworkStatus.textColor = [UIColor redColor];
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [tblSettingMenu reloadData];
    [self updateNetworkStatus:[[XMPPFacade share] isXMPPConnected]];
    [[LogFacade share] trackingScreen:Setting_Category];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Interact UI

- (IBAction)attachCrashLogFileChange:(id)sender
{
    UISwitch *button=(UISwitch *)sender;
    if (button.on)
    {
        [[LogFacade share] setEnableSendCrashViaEmail:YES];
    }
    else
    {
        [[LogFacade share] setEnableSendCrashViaEmail:NO];
    }
}
- (IBAction)notificationChange:(id)sender
{
    UISwitch *button=(UISwitch *)sender;
    if (button.on)
    {
        [[NotificationFacade share] setNotificationAlertInAppFlag:IS_YES];
    }
    else
    {
        [[NotificationFacade share] setNotificationAlertInAppFlag:IS_NO];
    }
    
}

- (IBAction)passwordLockChange:(id)sender {
    UISwitch *button = (UISwitch*)sender;
    if(button.on){
        [self.navigationController pushViewController:[EnablePasswordLock share] animated:YES];
    }
    else{
        [[CWindow share] showPasswordView:LockPasswordLock];
    }
}

- (IBAction)notificationSoundChange:(id)sender
{
    UISwitch *button=(UISwitch *)sender;
    if (button.on)
    {
        [[NotificationFacade share] setNotificationSoundInAppFlag:IS_YES];
    }
    else
    {
        [[NotificationFacade share] setNotificationSoundInAppFlag:IS_NO];
    }
}

-(void)remoteLogSetting:(id)sender
{
    UISwitch *button=(UISwitch *)sender;
    if (button.on)
    {
        [[LogFacade share] remoteLogEnable:YES];
    }
    else
    {
        [[LogFacade share] remoteLogEnable:NO];
    }

    [self.tblSettingMenu reloadData];
}

////////////////////////////////////////////////////
#pragma mark UITableView

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 11;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section==0)
    {
        return 20;
    }
    return 5;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    switch (sectionIndex)
    {
        case 0:
            return 4;
            break;
            
        case 1:
            return 2;
            break;
        case 2:
            return 2;
            break;
        case 3:
            return 2;
            break;
        case 4:
            return 1;
            break;
        case 5:
            return 1;
            break;
        case 6:
            return 1;
            break;
        case 7:
            return 1;
            break;
        case 8:
            return 1;
            break;
        case 9:
            return 1;
            break;
        case 10:
            return 1;
            break;
        default:
            return 1;
            break;
    }
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SettingCell";
    
    SettingTableViewCell *cell = [tblSettingMenu dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"SettingTableViewCell" owner:nil options:nil];
        cell = (SettingTableViewCell*)[nib objectAtIndex:0];
    }
    
    switch (indexPath.section) {
        case 0:
        {
            switch (indexPath.row)
            {
                case 0:
                    cell.lblTitle.text = LABEL_CONTACT_US;
                    break;
                    
                case 1:
                    cell.lblTitle.text = LABEL_TERMS_AND_CONDITIONS;
                    break;
                case 2:
                    cell.lblTitle.text = LABEL_TELL_A_FRIEND;
                    break;
                /* Daryl comment follow requirement at backlog 12465
                case 3:
                    cell.lblTitle.text = LABEL_FEEDBACK;
                    break;
                case 4:
                    cell.lblTitle.text = LABEL_REVIEW;
                    break;
                 */
                case 3:
                    cell.lblTitle.text = LABEL_FAQ;
                    break;
            }
        }break;
            
        case 1:
        {
            switch (indexPath.row)
            {
                case 0:
                {
                    cell.lblTitle.text = LABEL_MY_ACCOUNT;
                }
                    break;
                
                case 1:
                {
                    //get expiry date from database
                    cell.lblTitle.text = LABEL_SERVICE_EXPIRY;
                    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
                    [dateFormat setDateFormat:@"MMM dd,YYYY"];
                    cell.lblInfo.text = [self convertServerDateToLocal:[KeyChainSecurity getStringFromKey:kSUB_END_DATE]];
                    cell.lblInfo.hidden = NO;
                    cell.accessoryType = UITableViewCellAccessoryNone;

                }
                    break;
            }
        }
            break;
        case 2:
        {
            
            switch (indexPath.row) {
                case 0:
                    cell.lblTitle.text = LABEL_STATUS_BAR_NOTIFICATION;
                    cell.btnSwitch.on = [[[NotificationFacade share] getNotificationAlertInAppFlag] boolValue];
                    cell.btnSwitch.hidden = NO;
                    [cell.btnSwitch addTarget:self action:@selector(notificationChange:) forControlEvents:UIControlEventValueChanged];
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    break;
                case 1:
                    cell.lblTitle.text  = LABEL_NOTIFICATION_SOUND;
                    cell.btnSwitch.on = [[[NotificationFacade share] getNotificationSoundInAppFlag] boolValue];
                    cell.btnSwitch.hidden = NO;
                    [cell.btnSwitch addTarget:self action:@selector(notificationSoundChange:) forControlEvents:UIControlEventValueChanged];
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    break;
                    
                default:
                    break;
            }
        }
            break;
            
        case 3:
        {
            switch (indexPath.row) {
                case 0:
                    cell.lblTitle.text  = LABEL_PWD_LOCK;
                    cell.btnSwitch.on = [[[AppFacade share] getPasswordLockFlag] boolValue];
                    cell.btnSwitch.hidden = NO;
                    [cell.btnSwitch addTarget:self action:@selector(passwordLockChange:) forControlEvents:UIControlEventValueChanged];
                    cell.accessoryType = UITableViewCellAccessoryNone;

                    break;
                case 1:
                    cell.lblTitle.text = LABEL_CHANGE_PASSWORD;
                    if ([[[AppFacade share] getPasswordLockFlag] boolValue])
                    {
                        cell.userInteractionEnabled = YES;
                        [cell.lblTitle setTextColor:[UIColor blackColor]];
                    }
                    else
                    {
                        cell.userInteractionEnabled = NO;
                        [cell.lblTitle setTextColor:COLOR_128128128];
                    }
                    break;
                    
                default:
                    break;
            }
        }
            break;
            
        case 4:
        {
            cell.lblTitle.text = LABEL_BLOCKED_USERS;
        }
            break;
            
        case 5:
        {
           
            cell.lblTitle.text = LABEL_APP_VERSION;
            cell.lblInfo.text = APP_VERSION;
            cell.lblInfo.hidden = NO;
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
            break;
            
        case 6:
        {
            cell.lblTitle.text = LABEL_NETWORK_STATUS;
            cell.lblInfo.text = lblnetworkStatus.text;
            cell.lblInfo.textColor = lblnetworkStatus.textColor;
            cell.lblInfo.hidden = NO;
            cell.accessoryType = UITableViewCellAccessoryNone;
        }break;
        
        case 7:
        {
            cell.lblTitle.text = LABEL_MANAGE_STORAGE;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }break;
            
        case 8:
        {
            
            cell.lblTitle.text =LABEL_EMAIL_SETTING;
            
        }break;
        case 9:
        {
            cell.lblTitle.text  = LABEL_ATTACH_THE_CRASH_LOG_FILE;
            cell.btnSwitch.on = [[LogFacade share] getEnableSendCrashViaEmail] ;
            cell.btnSwitch.hidden = NO;
            [cell.btnSwitch addTarget:self action:@selector(attachCrashLogFileChange:) forControlEvents:UIControlEventValueChanged];
            cell.accessoryType = UITableViewCellAccessoryNone;
            
        }break;
        case 10:
        {
            switch (indexPath.row) {
                case 0:
                    
                {/* Daryl comment this
                    cell.lblTitle.text  = @"Log Debug Activities";
                    cell.btnSwitch.on = [[LogFacade share] isRemoteLogEnable] ;
                    cell.btnSwitch.hidden = NO;
                    [cell.btnSwitch addTarget:self action:@selector(remoteLogSetting:) forControlEvents:UIControlEventValueChanged];
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }break;
                    
                case 1:
                {
                     */
                    cell.lblTitle.text = LABEL_SEND_LOG_VIA_EMAIL;
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    cell.userInteractionEnabled = YES;
                    /*
                    if ([[LogFacade share] isRemoteLogEnable])
                    {
                        cell.userInteractionEnabled = YES;
                        cell.lblTitle.textColor = [UIColor blackColor];
                    }
                    else
                    {
                        cell.userInteractionEnabled = NO;
                        cell.lblTitle.textColor = COLOR_148148148;
                        
                    }
                     */
                }break;
                    
                default:
                    break;
            }
            
        }break;

        default:
            break;
    }
    

    
    cell.lblTitle.font = [UIFont systemFontOfSize:16.0f];
   
    
    return cell;

}

-(NSString*) convertServerDateToLocal:(NSString*)dateStr
{
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
    [dateFormat setDateFormat:FORMAT_DATE_DETAIL_ACCOUNT];
    NSDate *date = [dateFormat dateFromString:dateStr]; //CONVERT STRING TO DATE
    [dateFormat setDateFormat:@"MMM dd,yyyy"];
    
    return  [dateFormat stringFromDate:date];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tblSettingMenu deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.section) {
        case 0:
        {
            switch (indexPath.row) {
                case 0:
                    [self.navigationController pushViewController:[ContactUs share] animated:YES];
                    break;
                case 1:
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.onekrypto.com/tnc.html"]];
                    break;
                case 2:
                    /* handle Tell a friend  */
                    [SocialFacade share].showViewController = self;
                    [[SocialFacade share] showActionSheet:self];
                    [[LogFacade share] createEventWithCategory:Setting_Category
                                                        action:tellaFriend_Action
                                                         label:labelAction];
                    break;
                    /*
                case 3:
                    handle Feed back
                    [[LogFacade share] createEventWithCategory:Setting_Category
                                                           action:feedback_Action
                                                            label:labelAction];
                    break;
                case 4:
                    handle Review
                    [[LogFacade share] createEventWithCategory:Setting_Category
                                                        action:reviewClick_Action
                                                         label:labelAction];
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:REVIEW_APP_URL, REVIEW_APP_ID]]];
                    break;
                    */
                case 3:
                    /* handle FAQ */
                    [[LogFacade share] createEventWithCategory:Setting_Category
                                                        action:LABEL_FAQ
                                                         label:labelAction];
                    [self pushFAQView];
                    break;
            }            
        }break;
        case 1:
        {
            switch (indexPath.row) {
                case 0:
                {
                    [[LogFacade share] createEventWithCategory:Setting_Category
                                                           action:myAccountClick_Action
                                                            label:labelAction];
                    WebMyAccount *accountDetail=[WebMyAccount new];
                    [self.navigationController pushViewController:accountDetail animated:YES];

                }
                    break;
                case 1:
                {
                    
                    
                }break;
            }
        }break;
        case 2:
        {
            
        }break;
        case 3:
        {
            switch (indexPath.row) {
                case 0:
                    //password lock
                    break;
                case 1:
                    [[CWindow share] showPasswordView:LockChangePasscode];
                    break;
                    
                default:
                    break;
            }
        }break;
        case 4:
        {
            [[ContactFacade share] loadBlockedUsersArray];
            [self.navigationController pushViewController:[BlockUsersController share] animated:YES];
            
        }break;
        case 5:
        {
            [self updateJuzChatVersion];
        }
            break;
        case 6:
            break;
        case 7:
        {
            [[LogFacade share] createEventWithCategory:Setting_Category
                                                   action:manageStorage_Action
                                                    label:labelAction];
            ManageStorageView *manageStorage = [ManageStorageView new];
            [self.navigationController pushViewController:manageStorage animated:YES];
        }break;
        case 8:
        {
            MailAccount *emailAccount = [[EmailFacade share] getMailAccount:[[EmailFacade share] getEmailAddress]];
            if (emailAccount)
            {
                EmailSetting *emailSetting = [[EmailSetting alloc]initWithNibName:@"EmailSetting" bundle:nil];
                [self.navigationController pushViewController:emailSetting animated:YES];
            }
            else
            {
                EmailSettingNotSignUp *emailSettingNotSignUp = [[EmailSettingNotSignUp alloc]initWithNibName:@"EmailSettingNotSignUp"
                                                                                           bundle:nil];
                [self.navigationController pushViewController:emailSettingNotSignUp animated:YES];
            }
            
        }break;
        case 9:
        {
            
        }break;
            
        case 10:
        {
            self.tblSettingMenu.userInteractionEnabled = NO;
            [[CWindow share] showLoading:kLOADING_LOADING];
            [[LogFacade share] sendRemoteLogViaEmail];
        }break;
        default:
            break;
    }
}

-(void) pushFAQView
{
    if(![[NotificationFacade share] isInternetConnected]){
        [[CAlertView new] showError:NO_INTERNET_CONNECTION_TRY_LATER];
        return;
    }
    
    [self.navigationController pushViewController:[FAQ share] animated:YES];
}

-(void) updateNetworkStatus:(BOOL) isXMPPConnected
{
     if(isXMPPConnected){
        lblnetworkStatus.text = mNETWORK_CONNECTED;
        lblnetworkStatus.textColor = COLOR_121209116;
    }
    else{
        lblnetworkStatus.text = mNETWORK_DISCONNECTED;
        lblnetworkStatus.textColor = [UIColor redColor];
    }
    [tblSettingMenu reloadData];
}

-(void) reloadSettingsTable{
    [tblSettingMenu reloadData];
}

-(void) updateJuzChatVersion{
    NSLog(@"updateJuzChatVersion");
}

@end
