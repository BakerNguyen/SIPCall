//
//  EmailSetting.m
//  Satay
//
//  Created by Arpana Sakpal on 3/13/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import "EmailSetting.h"
#import "CWindow.h"
#import "EmailSettingNormal.h"
#import "EmailSettingPopImap.h"
#import "EmailSettingMicrosoft.h"
#import "EmailSettingNormal.h"
#import "EmailSignatureSetting.h"
#import "EmailSettingCell.h"
@interface EmailSetting ()
{
    NSString *userName;
    BOOL isUpdatedDB;
}

@end

@implementation EmailSetting
@synthesize tblEmailSetting;
@synthesize popOver;
@synthesize emailKeepingVC, mailAccountObj;
@synthesize emailSignature;
@synthesize closeButton;
@synthesize signatureStr;
@synthesize lblDot,lblGeneral;
@synthesize btnEmail;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


+(EmailSetting *)share{
    static dispatch_once_t once;
    static EmailSetting * share;
    dispatch_once(&once, ^{
        share = [[self alloc] init];
    });
    return share;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.rightBarButtonItem=[UIBarButtonItem createRightButtonTitle:_CLOSE Target:self Action:@selector(closeViewEmailSetting)];
    
    self.navigationItem.leftBarButtonItem=[UIBarButtonItem createLeftButtonTitle:_MENU Target:self Action:@selector(backToMenuSideBar)];
    
    self.navigationItem.title=TITLE_SETTING;
    self.view.backgroundColor = COLOR_247247247;
    
    lblGeneral.frame = CGRectMake(20, 17, 280, 30);
    lblGeneral.text = LABEL_GENERAL;
    
    lblDot.frame = CGRectMake(80, 17, 5, 30);
    lblDot.text = @".";
        
    btnEmail.frame = CGRectMake(83, 17, 60, 30);
    [btnEmail setTitle:_EMAIL forState:UIControlStateNormal];

    NSMutableAttributedString *mat = [btnEmail.titleLabel.attributedText mutableCopy];
    [mat addAttributes:@{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)} range:NSMakeRange (0, mat.length)];
    btnEmail.titleLabel.attributedText = mat;
    
    emailKeepingVC = [[EmailKeeping alloc] initWithNibName:@"EmailKeeping" bundle:nil parent:self];
    [emailKeepingVC.view setFrame:CGRectMake(0, 0, emailKeepingVC.view.frame.size.width, emailKeepingVC.view.frame.size.height)];
    emailKeepingVC.view.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.1];
    [self.view addSubview:emailKeepingVC.view];
    
    emailKeepingVC.view.hidden = YES;
    emailSignature = [[EmailSignatureSetting alloc] initWithNibName:@"EmailSignatureSetting" bundle:nil parent:self];
    
    
    tblEmailSetting.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void) viewWillAppear:(BOOL)animated
{
    userName=[[EmailFacade share]getEmailAddress];
    mailAccountObj=[[EmailFacade share]getMailAccount:userName];
    [tblEmailSetting reloadData];
}

-(void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
    
    [tblEmailSetting reloadData];
}

- (void)backToMenuSideBar
{
    [[CWindow share].menuController showLeftPanelAnimated:YES];
    
    
}
- (void)closeViewEmailSetting
{
    if ((emailKeepingVC.view.hidden == NO) && (emailKeepingVC != nil)) {
        
        emailKeepingVC.view.hidden = YES;
        //self.navigationItem.leftBarButtonItem=nil; // to hide navigation bar button
        self.navigationItem.title=TITLE_SETTING;
    self.navigationItem.leftBarButtonItem=[UIBarButtonItem createLeftButtonTitle:_MENU Target:self Action:@selector(backToMenuSideBar)];
        
    }else{
        
        [self.navigationController popViewControllerAnimated:YES];
        
    }
    
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)closeViewEmailKeeping
{
    emailKeepingVC.view.hidden = YES;
}

////////////////////////////////////////////////////////////////////////////////////
#pragma mark UITableView
////////////////////////////////////////////////////////////////////////////////////

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    int n =(int) indexPath.row;
    
    if (n == 0) {
        
        return 64;
        
    } else if(n==10) {
        
        return 130;
        
    } else if (n%2 == 0) {
        
        return 49;
        
    }else
        
        return 41;
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return 11;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [self.tblEmailSetting deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.row)
    {
            case 1:
            {
                //DDLogCVerbose(@"Push to email keeping");
                emailKeepingVC.view.hidden = NO;
                emailKeepingVC.navigationItem.hidesBackButton = YES;
                self.navigationItem.title=TITLE_EMAIL_KEEPING;
                self.navigationItem.rightBarButtonItem=[UIBarButtonItem createRightButtonTitle:_CLOSE Target:self Action:@selector(closeViewEmailSetting)];
              //  self.navigationItem.rightBarButtonItem=nil;//to hide navigation bar button
            }
            break;
            case 3:
            {
                //DDLogCVerbose(@"Push to signature setting");
                // Setup value to push
                emailSignature.signatureText = mailAccountObj.signature;
                [self.navigationController pushViewController:emailSignature animated:YES];
            
            }
            break;
            case 7:
            {
                if (mailAccountObj.accountType.intValue==4)
                {
                    // email is pop / Imap
                    EmailSettingPopImap *controller = [[EmailSettingPopImap alloc] initWithNibName:@"EmailSettingPopImap" bundle:nil];
                    [self.navigationController pushViewController:controller animated:YES];
                    
                                                      }
                else if (mailAccountObj.accountType.intValue==0)
                {
                    // email is Microsoft exchange
                    EmailSettingMicrosoft *controller = [[EmailSettingMicrosoft alloc] initWithNibName:@"EmailSettingMicrosoft" bundle:nil];
                    [self.navigationController pushViewController:controller animated:YES];
                }
                else
                {
                    // If email is Yahoo, Gmail, Hotmail...

                    EmailSettingNormal *controller = [[EmailSettingNormal alloc] initWithNibName:@"EmailSettingNormal" bundle:nil];
                    [self.navigationController pushViewController:controller animated:YES];

                }
              
            }
            break;
            
        default:
            break;
    }
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *CellIdentifier = @"EmailSettingCell";
    
    EmailSettingCell *cell = [tblEmailSetting dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"EmailSettingCell" owner:nil options:nil];
        cell = (EmailSettingCell*)[nib objectAtIndex:0];
    }

    
    int n = (int)indexPath.row;
    
    if (n%2 == 0) {
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
    }
    
    
    switch (indexPath.row) {
            
        case 0:
        {
            [cell.contentView addSubview:lblGeneral];
            cell.backgroundColor = COLOR_247247247;
            
            [cell.contentView addSubview:lblDot];
            [cell.contentView addSubview:btnEmail];
            
        }
            break;
        case 1:
        {
            cell.lblTitle.hidden = NO;
            cell.lblTitle.text = LABEL_EMAIL_KEEPING;
            
            cell.lblValue.hidden = NO;
            switch (mailAccountObj.emailKeeping.integerValue)
            {
                    case kEMAIL_KEEPING_3_DAYS:
                        cell.lblValue.text = kEmailKeeping_3Days;
                        break;
                    case kEMAIL_KEEPING_1_WEEK:
                        cell.lblValue.text = kEmailKeeping_1Week;
                        break;
                    case kEMAIL_KEEPING_1_MONTH:
                        cell.lblValue.text = kEmailKeeping_1Month;
                        break;
                    case kEMAIL_KEEPING_3_MONTHS:
                        cell.lblValue.text = kEmailKeeping_3Months;
                        break;
                    case kEMAIL_KEEPING_NEVER:
                        cell.lblValue.text = kEmailKeeping_Never;
                        break;
                    default:
                        break;
            }
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
            break;
        case 3:
        {
            cell.lblTitle.hidden = NO;
            cell.lblTitle.text = LABEL_SIGNATURE_SETTING;
            cell.lblValue.hidden = NO;
            cell.lblValue.text = mailAccountObj.signature;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
            break;
        case 5:
        {
            cell.lblTitle.hidden = NO;
            cell.lblTitle.text = LABEL_ENCRYPTED_SETTING;
            
            cell.btnSwitch.hidden = NO;
            [cell.btnSwitch addTarget:self
                               action:@selector(switchEncryptedAction:)
                      forControlEvents:(UIControlEventTouchUpInside | UIControlEventTouchDragExit)];
            if (mailAccountObj.useEncrypted == 1)
                
                [cell.btnSwitch setOn:YES animated:YES];
            else
                [cell.btnSwitch setOn:NO animated:YES];
        }
            break;
        case 7:
        {
            cell.lblTitle.hidden = NO;
            cell.lblTitle.text = LABEL_EMAIL_SETTING;
            cell.lblValue.hidden = NO;
            cell.lblValue.text = userName ;
            
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
            break;
        case 9:
        {
            cell.lblTitle.hidden = NO;
            cell.lblTitle.text = LABEL_EMAIL_NOTIFICATION;
            cell.btnSwitch.hidden = NO;
            
            [cell.btnSwitch addTarget:self
                               action:@selector(switchNotificationAction:)
                     forControlEvents:(UIControlEventTouchUpInside | UIControlEventTouchDragExit)];
            
            if (mailAccountObj.useNotify == 1)
                [cell.btnSwitch setOn:YES animated:YES];
            else
                [cell.btnSwitch setOn:NO animated:YES];
        }
            break;
        default:
            break;
    }
    
    return cell;
    
}
//method of switch
- (void)switchNotificationAction:(id)sender{
    UISwitch *switchNotice = (UISwitch *)sender;
    if (switchNotice.isOn) {
        mailAccountObj.useNotify = 1;
    }else{
        mailAccountObj.useNotify = 0;
    }

    isUpdatedDB=[[EmailFacade share]updateMailAccount:mailAccountObj];
    mailAccountObj = [[EmailFacade share] getMailAccount:[[EmailFacade share] getEmailAddress]];
}

- (void)switchEncryptedAction:(id)sender{
    
    UISwitch *switchEncrypt = (UISwitch *)sender;
    if (switchEncrypt.isOn) {
        mailAccountObj.useEncrypted=1;
    }else{
        mailAccountObj.useEncrypted=0;
    }
    
    isUpdatedDB=[[EmailFacade share]updateMailAccount:mailAccountObj];
    mailAccountObj = [[EmailFacade share] getMailAccount:[[EmailFacade share] getEmailAddress]];
}

@end
