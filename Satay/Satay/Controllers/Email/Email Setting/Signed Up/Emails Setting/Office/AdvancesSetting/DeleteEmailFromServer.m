//
//  DeleteEmailFromServer.m
//  Satay
//
//  Created by Arpana Sakpal on 3/12/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import "DeleteEmailFromServer.h"
#import "EmailLoginOffice.h"
#import "Advanced.h"
#import "EmailLoginOffice.h"
@interface DeleteEmailFromServer ()
{
    MailAccount *mailAccountObj;
}
@end

@implementation DeleteEmailFromServer


@synthesize tblDeleteEmail;
@synthesize emailDeletionStr;
@synthesize checkedIndexPath;
@synthesize allValues;
@synthesize parent;
@synthesize lblTitle,viewTitle;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil parent:(id)_parent
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        parent = _parent;
        
          }
    return self;
}
+(DeleteEmailFromServer *)share{
    static dispatch_once_t once;
    static DeleteEmailFromServer * share;
    dispatch_once(&once, ^{
        share = [[self alloc] init];
    });
    return share;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    
    self.navigationItem.leftBarButtonItem=[UIBarButtonItem createLeftButtonTitle:_BACK
                                                                          Target:self
                                                                          Action:@selector(cancelEmailDeleteFromServerVC)];
    
    self.navigationItem.rightBarButtonItem=[UIBarButtonItem createRightButtonTitle:_SAVE
                                                                            Target:self
                                                                            Action:@selector(processSave)];
  
    
    // Color of self.navigationItem.rightBarButtonItem title for disable status
    self.navigationItem.title = LABEL_DELETE_EMAIL_FROM_SERVER;

    allValues = [NSMutableArray arrayWithObjects:kEmailDeletion_Never, kEmailDeletion_FromInbox, nil];
    mailAccountObj=[[EmailFacade share]getMailAccount:[[EmailFacade share] getEmailAddress]];
    emailDeletionStr = [allValues objectAtIndex:mailAccountObj.storeProtocol.integerValue];
    tblDeleteEmail.scrollEnabled = NO;

}

-(void)cancelEmailDeleteFromServerVC{
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

-(void)processSave{
    
    NSInteger indexAllValues = [allValues indexOfObject: emailDeletionStr];
    mailAccountObj.storeProtocol = [NSString stringWithFormat:@"%ld",(long)indexAllValues];
    [[EmailFacade share] updateMailAccount:mailAccountObj];
    mailAccountObj = [[EmailFacade share] getMailAccount:[[EmailFacade share] getEmailAddress]];
    
    if ([parent isKindOfClass:[EmailLoginOffice class]])
    {
        ((EmailLoginOffice*)parent).strEmailDeletion = emailDeletionStr;
        [((EmailLoginOffice*)parent).tblBottom reloadData];
    }
    else if([parent isKindOfClass:[Advanced class]])
    {
        ((Advanced *)parent).strEmailDeletion=emailDeletionStr;
    }
 
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
    
    int n = (int)indexPath.row;
    
    if (n == 0) {
        
        return 20;
        
    }else if (n == 1 || n == 2) {
        
        return 41;
        
    }else
        
        return 560;
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return 4;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [self.tblDeleteEmail deselectRowAtIndexPath:indexPath animated:YES];
    
    int n = (int)indexPath.row;
    
    if (n == 0 || n == 3) {
        
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.userInteractionEnabled = NO;
        
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
            
            emailDeletionStr = cell.textLabel.text;

              
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
    
    if (n == 0 || n== 3) {
        
        [cell setSeparatorInset:UIEdgeInsetsMake(0,0, 0,0)];
        cell.backgroundColor = COLOR_247247247;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
    }else if(n==1 || n==2){
        
        if (n== 2) {
            
            [cell setSeparatorInset:UIEdgeInsetsMake(0,0, 0,0)];
            
        }
        
        cell.textLabel.font = [UIFont systemFontOfSize:16];
        cell.textLabel.text = [allValues
                               objectAtIndex:n-1];
        
        if ([cell.textLabel.text isEqualToString:emailDeletionStr]) {
            
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            self.checkedIndexPath = indexPath;
            
        }
        else{
            
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        
    }
    
    return cell;
}


@end
