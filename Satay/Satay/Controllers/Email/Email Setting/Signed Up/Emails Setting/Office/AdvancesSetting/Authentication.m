//
//  Authentication.m
//  Satay
//
//  Created by Arpana Sakpal on 3/12/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import "Authentication.h"
#import "Advanced.h"
@interface Authentication ()
{
    NSString *userName;
    MailAccount *mailAccountObj;
}
@end

@implementation Authentication
@synthesize tblAuthentication;
@synthesize checkedIndexPath;
@synthesize allValues;
@synthesize authenticationStr;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil parent:(id)_parent
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        parent = _parent;
        
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.hidesBackButton=YES;
    allValues = [NSMutableArray arrayWithObjects:kEmailAuthentication_Password, kEmailAuthentication_MD5Challenger, kEmailAuthentication_NTLM, kEmailAuthentication_HTTP_MD5, @"", nil];
    tblAuthentication.scrollEnabled=NO;
    self.navigationItem.leftBarButtonItem=[UIBarButtonItem createLeftButtonTitle:_BACK
                                                                          Target:self
                                                                          Action:@selector(cancelToEmailVC)];
    self.navigationItem.rightBarButtonItem=[UIBarButtonItem createRightButtonTitle:_SAVE
                                                                            Target:self
                                                                            Action:@selector(processNext)];
    self.navigationItem.title=TITLE_AUTHENTICATION;
    
    userName=[[EmailFacade share]getEmailAddress];
    mailAccountObj=[[EmailFacade share]getMailAccount:userName];
    authenticationStr = [allValues objectAtIndex:mailAccountObj.outgoingRequireAuth.integerValue];
}

- (void)processNext{
    // access database >> update email authentication >> pop view
    NSInteger indexAllValues = [allValues indexOfObject: authenticationStr];
    
    NSNumber *val = [NSNumber numberWithInteger:indexAllValues];
    mailAccountObj.outgoingRequireAuth=[val stringValue];
    [[EmailFacade share] updateMailAccount:mailAccountObj];
    mailAccountObj = [[EmailFacade share] getMailAccount:[[EmailFacade share] getEmailAddress]];
    
    [self.navigationController popViewControllerAnimated:YES];
    
}
- (void)cancelToEmailVC{
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (void)didReceiveMemoryWarning {
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
        
        return 500;
        
    }else if (indexPath.row == 0) {
        
        return 20;
        
    }else
        
        return 41;
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return 6;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    int n = (int)indexPath.row;
    if (n == 5 || n == 0) {
        
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.accessoryView = nil;
        
    }else{
        
        // Checked the selected row
        if (self.checkedIndexPath) {
            
            UITableViewCell *uncheckCell = [tableView cellForRowAtIndexPath:self.checkedIndexPath];
            uncheckCell.accessoryType = UITableViewCellAccessoryNone;
            
        }
        if ([self.checkedIndexPath isEqual:indexPath]) {
            
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            
        }
        else{
            
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            self.checkedIndexPath = indexPath;
            
            authenticationStr = cell.textLabel.text;
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
    if (n == 5 || n == 0) {
        
        cell.accessoryView = nil;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor colorWithRed:128/255.0 green:128/255.0 blue:128/255.0 alpha:0.1];
        cell.userInteractionEnabled = NO;
        [cell setSeparatorInset:UIEdgeInsetsMake(0,0, 0,0)];
        
    } else{
        
        // Configure the cell.
        cell.textLabel.text = [allValues objectAtIndex:n-1];//[indexPath row]
        cell.textLabel.font = [UIFont systemFontOfSize:16];
        if ([cell.textLabel.text isEqualToString:authenticationStr]) {
            
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            self.checkedIndexPath = indexPath;
            
        } else{
            
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        
        if ( n == 4) {
            
            [cell setSeparatorInset:UIEdgeInsetsMake(0,0, 0,0)];
            
        }
        
    }
    
    
    return cell;
}


@end
