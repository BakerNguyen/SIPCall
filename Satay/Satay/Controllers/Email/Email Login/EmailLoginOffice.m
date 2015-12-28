//
//  EmailLoginOffice.m
//  Satay
//
//  Created by Arpana Sakpal on 3/3/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import "EmailLoginOffice.h"
#import "SetUpEmail.h"
#import "DeleteEmailFromServer.h"
#import "SyncSchedule.h"
@interface EmailLoginOffice ()
{
    NSUserDefaults *defaultUser;
    SetUpEmail *setUpEmailVC;
    NSInteger emailType;
}

@end

@implementation EmailLoginOffice
@synthesize scrollView;
@synthesize segControlImaPop;
@synthesize txtFieldEmail;
@synthesize txtIncomeHostName, txtIncomeUserName, txtIncomePassword, txtIncomeServerPort;
@synthesize txtOutgoHostName, txtOutgoUserName, txtOutgoPassword, txtOutgoServerPort;
@synthesize lblDeleteEmail,lblSyncSchedule,lblTitleDeleteEmail,lblTitleSyncSchedule;
@synthesize strEmailDeletion,strSyncSchedule;
@synthesize tblBottom,numberOfRow;


@synthesize strEmailAddress, strPassWord,isImap;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil parent:(id)_parent
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _parent = _parent;
        // Custom initialization
    }
    return self;
}
+(EmailLoginOffice *)share{
    
    static dispatch_once_t once;
    static EmailLoginOffice * share;
    dispatch_once(&once, ^{
        share = [[self alloc] init];
    });
    return share;
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
     _alertView = [[CAlertView alloc] init];
    
    ///SegmentController view//
    segControlImaPop.selectedSegmentIndex = 1;
    [segControlImaPop addTarget:self
                          action:@selector(actionSegControl:)
                forControlEvents:UIControlEventValueChanged];
    
    
    //New Account info textFields view//
    [txtFieldEmail setDelegate:self];
    [txtIncomeHostName setDelegate:self];
    [txtIncomeUserName setDelegate:self];
    [txtIncomePassword setDelegate:self];
    [txtOutgoHostName setDelegate:self];
    [txtOutgoUserName setDelegate:self];
    [txtOutgoPassword setDelegate:self];
    [txtIncomeServerPort setDelegate:self];
    [txtOutgoServerPort setDelegate:self];
    
    [scrollView setContentSize:CGSizeMake(320,900)];
    
    emailType = 5; //POP default
    txtFieldEmail.text = strEmailAddress;
    
    txtIncomeUserName.text = strEmailAddress;
    txtIncomePassword.text = strPassWord;
    
    txtOutgoUserName.text = strEmailAddress;
    txtOutgoPassword.text = strPassWord;
    
    setUpEmailVC = [SetUpEmail new];
    defaultUser = [NSUserDefaults standardUserDefaults];
    
    self.navigationItem.title=TITLE_NEW_ACCOUNT;
    self.navigationItem.rightBarButtonItem=[UIBarButtonItem createRightButtonTitle:_SAVE Target:self Action:@selector(processSave)];
    self.navigationItem.leftBarButtonItem=[UIBarButtonItem createLeftButtonTitle:_CANCEL Target:self Action:@selector(cancelToEmailVC)];

    tblBottom.backgroundColor = COLOR_247247247;
    tblBottom.scrollEnabled = NO;
   
    lblTitleDeleteEmail.frame = CGRectMake(18, 5, 200, 30);
    lblTitleDeleteEmail.font = [UIFont systemFontOfSize:16];
    lblTitleDeleteEmail.text = LABEL_DELETE_EMAIL_FROM_SERVER;
    
    lblDeleteEmail.frame = CGRectMake(200, 5, tblBottom.width, 30);
    
    lblTitleSyncSchedule.frame = CGRectMake(18, 5, 200, 30);
    lblTitleSyncSchedule.font = [UIFont systemFontOfSize:16];
    lblTitleSyncSchedule.text = LABEL_SYNC_SCHEDULE;
    
    lblSyncSchedule.frame = CGRectMake(200, 5, tblBottom.width, 30);
    
    strEmailDeletion = kEmailDeletion_Never;
    strSyncSchedule = kEmailSyncSchedule_5Minutes;
    
    tblBottom.delegate = self;
    tblBottom.dataSource = self;
    
    numberOfRow = 4;
    isImap = FALSE;


}

- (void) changeEmailType:(BOOL)type{
    
    if (type)
    {
        numberOfRow = 2;
        isImap = TRUE;
    }
    else
    {
        numberOfRow = 4;
        isImap = FALSE;
    }
    [tblBottom reloadData];
}
-(void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
    [tblBottom reloadData];
}

- (void)dismissKeyboard {
    
    [self.view endEditing:YES];
}

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    [txtFieldEmail becomeFirstResponder];
}

- (BOOL) canPerformAction:(SEL)action withSender:(id)sender
{
    if (action == @selector(copy:))
        return NO;
    return [super canPerformAction:action withSender:sender];
}

- (void)cancelToEmailVC{
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (void)processSave{

    //Validate form
    if(![self validateForm])
        return;

    setUpEmailVC.emailAddress = strEmailAddress;
    setUpEmailVC.emailPassWord = strPassWord;
    setUpEmailVC.incommingHost = txtIncomeHostName.text;
    setUpEmailVC.incommingUserName = txtIncomeUserName.text;
    setUpEmailVC.incommingPassword = txtIncomePassword.text;
    setUpEmailVC.incommingPort = [txtIncomeServerPort.text intValue];
    setUpEmailVC.outgoingHost = txtOutgoHostName.text;
    setUpEmailVC.outgoingUserName = txtOutgoUserName.text;
    setUpEmailVC.outgoingPassword = txtOutgoPassword.text;
    setUpEmailVC.outgoingPort = [txtOutgoServerPort.text intValue];
    setUpEmailVC.delEmailFromServer = [[EmailFacade share] getOrderDeleteEmailFromServer:strEmailDeletion];
    setUpEmailVC.syncSchedule = [[EmailFacade share] getOrderSyncSchedule:strSyncSchedule];
    setUpEmailVC.emailType = emailType;
    
    [self.navigationController pushViewController:setUpEmailVC animated:YES];
}




- (BOOL)validateForm{
    
    if(![[EmailFacade share] checkValidEmailAddress:[txtFieldEmail.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]]) {
        [_alertView showError:ERROR_INVALID_EMAIL];
        return NO;
    }else if(txtIncomeUserName.text.length == 0){
        [_alertView showError:mError_UserNameRequired];
        return NO;
    } else if (txtIncomeServerPort.text.length == 0 || txtOutgoServerPort.text.length == 0) {
        [_alertView showError:mError_ServerPortRequired];
        return NO;
    }
    
    return YES;
}

- (id)initWithCAlertView:(CAlertView *)theCAlertView{
    if (self = [super init]) {
        _alertView = theCAlertView;
    }
    return self;
}


- (void)actionSegControl:(id)sender
{
    NSInteger selectedSegment = segControlImaPop.selectedSegmentIndex;
    
    if (selectedSegment == 0)
    {
        emailType = 4;//IMAP
        self.navigationItem.rightBarButtonItem = [UIBarButtonItem createRightButtonTitle:_NEXT
                                                                                  Target:self
                                                                                  Action:@selector(processSave)];
    }
    else{
        emailType = 5;// POP
        self.navigationItem.rightBarButtonItem = [UIBarButtonItem createRightButtonTitle:_SAVE
                                                                                  Target:self
                                                                                  Action:@selector(processSave)];
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    if ([textField isEqual:txtFieldEmail])
        [txtIncomeHostName becomeFirstResponder];
    else if ([textField isEqual:txtIncomeHostName])
        [txtIncomeUserName becomeFirstResponder];
    else if ([textField isEqual:txtIncomeUserName])
        [txtIncomePassword becomeFirstResponder];
    else if ([textField isEqual:txtIncomePassword])
        [txtIncomeServerPort becomeFirstResponder];
    else if ([textField isEqual:txtIncomeServerPort])
        [txtOutgoHostName becomeFirstResponder];
    else if ([textField isEqual:txtOutgoHostName])
        [txtOutgoUserName becomeFirstResponder];
    else if ([textField isEqual:txtOutgoUserName])
        [txtOutgoPassword becomeFirstResponder];
    else if ([textField isEqual:txtOutgoPassword])
        [txtOutgoServerPort becomeFirstResponder];
    else if(self.navigationItem.rightBarButtonItem.enabled){
        [self processSave];
    }else
        [_alertView showError:mError_inputInformationRequired];
    return YES;
    
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    
    if (newLength > 0) {
        
        if ((txtFieldEmail.text.length > 0) && (txtIncomeHostName.text.length > 0) && (txtIncomeUserName.text.length > 0) &&(txtIncomePassword.text.length >0) &&(txtIncomeServerPort.text.length >0) && (txtOutgoHostName.text.length > 0) && (txtOutgoServerPort.text.length > 0)) {
            self.navigationItem.rightBarButtonItem.enabled = YES;
        }
        
        // Return NO if newLength >=MAX_LENGHT_TEXT
        if(newLength >= 255 && range.length == 0){
            
            return NO;
            
        }
        
    }
    else {
        
        // Disable the button
        self.navigationItem.rightBarButtonItem.enabled = NO;
        
    }
    
    return YES;
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

////////////////////////////////////////////////////////////////////////////////////
#pragma mark UITableView
////////////////////////////////////////////////////////////////////////////////////

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (isImap) {
        
        if (indexPath.row == 1) {
            
            return 550;
            
        }else
            
            return 41;
        
    } else {
        
        if (indexPath.row == 1) {
            
            return 20;
            
        }else if (indexPath.row == 3) {
            
            return 400;
            
        }else
            
            return 41;
    }
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return numberOfRow;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tblBottom deselectRowAtIndexPath:indexPath animated:YES];
 

    //[self.tblBottom deselectRowAtIndexPath:indexPath animated:YES];
    
    int n = (int)[indexPath row];
   
    
    if (isImap)
    {
        
        if (n == 0)
        {
           
            SyncSchedule *syncScheduleVC= [[SyncSchedule alloc] initWithNibName:@"SyncSchedule" bundle:nil parent:self];
            syncScheduleVC.syncScheduleString = strSyncSchedule;
            
            [((EmailLoginOffice *)parent).navigationController pushViewController:syncScheduleVC animated:YES];
        }
        else
        {
            
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            cell.userInteractionEnabled = NO;
            
        }
    }
    else
    {
        if (n==0)
        {
          
            DeleteEmailFromServer *emailDeleteFromServer= [[DeleteEmailFromServer alloc] initWithNibName:@"DeleteEmailFromServer" bundle:nil parent:self];
            emailDeleteFromServer.emailDeletionStr = strEmailDeletion;
            [self.navigationController pushViewController:emailDeleteFromServer animated:YES];
         
            
            // [((EmailLoginOffice *)parent).navigationController pushViewController:emailDeleteFromServer animated:YES];
            
        }
        else if (n ==2)
        {
           
            SyncSchedule *syncScheduleVC= [[SyncSchedule alloc] initWithNibName:@"SyncSchedule" bundle:nil parent:self];
            syncScheduleVC.syncScheduleString = strSyncSchedule;
            [self.navigationController pushViewController:syncScheduleVC animated:YES];
            
            
          // [((EmailLoginOffice *)parent).navigationController pushViewController:syncScheduleVC animated:YES];
            
        }
        else
        {

            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            cell.userInteractionEnabled = NO;
        }
    }
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"CellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                  reuseIdentifier:CellIdentifier];

    
    if (isImap)
    {
        
        switch (indexPath.row)
        {
                
            case 0:
            {
                
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                [cell.contentView addSubview:lblTitleSyncSchedule];
                [cell.contentView addSubview:lblSyncSchedule];
                
                lblSyncSchedule.text = strSyncSchedule ;
                
            }
                break;
            case 1:
            {
                
                cell.backgroundColor = COLOR_230230230;
                cell.userInteractionEnabled = NO;
                
            }
                break;
                
            default:
                
                break;
        }
        
    }
    
    else
    {
        
        switch (indexPath.row)
        {
                
            case 0:
            {
                
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                [cell.contentView addSubview:lblTitleDeleteEmail];
               
                [cell.contentView addSubview:lblDeleteEmail];
                
                lblDeleteEmail.text = strEmailDeletion;
                
            }
             break;
            
            case 1:
            {
                
                cell.accessoryType = UITableViewCellAccessoryNone;
                cell.backgroundColor = COLOR_230230230;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                
            }
                break;
            case 2:
            {
                
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                [cell.contentView addSubview:lblTitleSyncSchedule];
                [cell.contentView addSubview:lblSyncSchedule];
                
                lblSyncSchedule.text = strSyncSchedule ;
                
            }
                break;
            case 3:
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