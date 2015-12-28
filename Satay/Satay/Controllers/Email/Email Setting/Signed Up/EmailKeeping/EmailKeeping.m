//
//  EmailKeeping.m
//  Satay
//
//  Created by Arpana Sakpal on 3/13/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import "EmailKeeping.h"
#import "EmailSetting.h"
@interface EmailKeeping ()
{
    MailAccount *mailAccount;
}
@end

@implementation EmailKeeping
@synthesize tblEmailKeeping;
@synthesize checkedIndexPath;
@synthesize allValues;
@synthesize emailKeepingStr;




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
    
    self.navigationItem.hidesBackButton = YES;
    self.view.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.1];
    

    allValues=[NSMutableArray arrayWithObjects:kEmailKeeping_3Days,kEmailKeeping_1Week, kEmailKeeping_1Month,kEmailKeeping_3Months, kEmailKeeping_Never,@"", nil];
    tblEmailKeeping.delegate=self;
    tblEmailKeeping.dataSource=self;
    tblEmailKeeping.scrollEnabled = NO;
    NSString *userName = [[EmailFacade share]getEmailAddress];
    mailAccount = [[EmailFacade share]getMailAccount:userName];

}

- (void)closeViewEmailKeeping
{
    
    self.view.hidden = YES;
    
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
    
    if (indexPath.row == 5) {
        
        return 268;
        
    }else
        
        return 62;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return 6;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tblEmailKeeping deselectRowAtIndexPath:indexPath animated:YES];

    int n = (int)indexPath.row;

    if (n > 4)
    {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.accessoryView = nil;
        self.view.hidden = YES;
    }
    else
    {
        // Check the selected row
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

            emailKeepingStr = cell.textLabel.text;
        }
    }
    
    NSInteger indexAllValues = [allValues indexOfObject:emailKeepingStr];

    NSNumber *val = [NSNumber numberWithInteger:indexAllValues];
    switch (val.integerValue)
    {
        case 0:
            mailAccount.emailKeeping = [NSNumber numberWithInt:kEMAIL_KEEPING_3_DAYS];
            break;
        case 1:
            mailAccount.emailKeeping = [NSNumber numberWithInt:kEMAIL_KEEPING_1_WEEK];
            break;
        case 2:
            mailAccount.emailKeeping = [NSNumber numberWithInt:kEMAIL_KEEPING_1_MONTH];
            break;
        case 3:
            mailAccount.emailKeeping = [NSNumber numberWithInt:kEMAIL_KEEPING_3_MONTHS];
            break;
        case 4:
            mailAccount.emailKeeping = [NSNumber numberWithInt:kEMAIL_KEEPING_NEVER];
        default:
            break;
    }
    [[EmailFacade share] updateMailAccount:mailAccount];
    mailAccount = [[EmailFacade share] getMailAccount:[[EmailFacade share] getEmailAddress]];
    ((EmailSetting *)parent).mailAccountObj = mailAccount;
    [((EmailSetting *)parent).tblEmailSetting reloadData];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellIdentifier";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (nil == cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    int n = (int)indexPath.row;

    if (n > 4)
    {
        //cell.selected = NO;
        cell.accessoryView = nil;
        // cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor colorWithRed:128 / 255.0 green:128 / 255.0 blue:128 / 255.0 alpha:0.1];
    }
    else
    {
        // Configure the cell.
        cell.textLabel.text = [allValues objectAtIndex:n];
        cell.textLabel.font = [UIFont systemFontOfSize:16];
        
        if (indexPath.row == mailAccount.emailKeeping.integerValue)
        {
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
