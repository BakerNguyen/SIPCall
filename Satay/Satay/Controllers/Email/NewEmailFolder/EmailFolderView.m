//
//  EmailFolder.m
//  Satay
//
//  Created by Arpana Sakpal on 3/19/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import "EmailFolderView.h"
#import "NewFolderEmail.h"
#import "EmailInbox.h"
@interface EmailFolderView ()
{
    int selectedRow;
    NSString *userName;
    BOOL isUpdated;
    MailFolder *mailFolderObj;
    MailHeader *mailHeaderObj;
    
    NSMutableArray* allFolderNames;
}
@end

@implementation EmailFolderView
@synthesize tblEmailFolder;
@synthesize moveEmails;
@synthesize isMoveEmail;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.rightBarButtonItem=[UIBarButtonItem createRightButtonTitle:_ADD Target:self Action:@selector(addMoreFolderName)];
    self.navigationItem.leftBarButtonItem=[UIBarButtonItem createLeftButtonTitle:_BACK Target:self Action:@selector(backToPreviousView)];
    self.navigationItem.title=TITLE_MOVE_TO;
    
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = 2.0; //seconds
    [self.tblEmailFolder addGestureRecognizer:lpgr];
    
    mailFolderObj = [MailFolder new];
    
    allFolderNames = [[NSMutableArray alloc] init];
    
    [self changeLanguage];
}

- (void)changeLanguage
    {
        [self.navigationItem setTitle:NSLocalizedString(TITLE_MOVE_TO, nil)];
        [self.navigationItem.leftBarButtonItem setTitle:NSLocalizedString(_BACK,nil)];
        [self.navigationItem.rightBarButtonItem setTitle:NSLocalizedString(_ADD,nil)];
     }
-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self getAllEmailFolder];
    [tblEmailFolder reloadData];
}

- (void) getAllEmailFolder
{
    allFolderNames= [[[EmailFacade share] getAllEmailFolders] mutableCopy];
    if (allFolderNames.count == 0)
    {
        [[EmailFacade share] createDefaultEmailFolders];
        allFolderNames= [[[EmailFacade share] getAllEmailFolders] mutableCopy];
        [tblEmailFolder reloadData];
    }
}

-(void) backToPreviousView{
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

-(void) addMoreFolderName{
    
    NewFolderEmail *new = [NewFolderEmail new];
    [self.navigationController pushViewController:new animated:YES];
    
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [allFolderNames count] ;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    mailFolderObj = [allFolderNames objectAtIndex:indexPath.row];
    if (isMoveEmail) {
        for (MailHeader *mailHeader in moveEmails) {
            [[EmailFacade share] moveEmail:mailHeader.uid toFolder:[mailFolderObj.folderIndex doubleValue]];
        }
        [[CWindow share] showMailBox];
    }else{
        if ([mailFolderObj.folderIndex isEqualToNumber:[NSNumber numberWithInt:1]]) {
            [[CWindow share] showMailBox];
        }else{
            EmailInbox *viewEmailInFolder = [[EmailInbox alloc] initWithNibName:@"EmailInbox" bundle:nil];
            viewEmailInFolder.folderIndex = [mailFolderObj.folderIndex doubleValue];
            [self.navigationController pushViewController:viewEmailInFolder animated:YES];
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"CellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (nil == cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier];
    }
   
    if (allFolderNames.count > 0) {
        mailFolderObj = [allFolderNames objectAtIndex:indexPath.row];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSInteger numberOfEmailInFolder = [[defaults objectForKey:[NSString stringWithFormat:@"%ld",(long)mailFolderObj.folderIndex.integerValue]] integerValue];
        
        switch (mailFolderObj.folderIndex.integerValue)
        {
            case kINDEX_FOLDER_INBOX:
                cell.imageView.image = [UIImage imageNamed:IMG_ALL_ICON_INBOX];
                break;
            case kINDEX_FOLDER_RECYCLE_BIN:
                cell.imageView.image = [UIImage imageNamed:IMG_ALL_ICON_RECYCLE];
                break;
            case kINDEX_FOLDER_JUNK:
                cell.imageView.image = [UIImage imageNamed:IMG_ALL_ICON_JUNK];
                break;
            case kINDEX_FOLDER_SAVED_EMAILS:
                cell.imageView.image = [UIImage imageNamed:IMG_ALL_ICON_SAVED_EMAILS];
                break;
            case kINDEX_FOLDER_DRAFTS:
                cell.imageView.image = [UIImage imageNamed:IMG_ALL_ICON_DRAFT];
                break;
            case kINDEX_FOLDER_SENT:
                cell.imageView.image = [UIImage imageNamed:IMG_ALL_ICON_SENT];
                break;
            case kINDEX_FOLDER_OUTBOX:
                cell.imageView.image = [UIImage imageNamed:IMG_ALL_ICON_OUTBOX];
                break;
            default:
                cell.imageView.image = [UIImage imageNamed:IMG_INBOX_ICON_ALL];
                break;
        }
        
        if (numberOfEmailInFolder > 0) {
            cell.textLabel.text = [NSString stringWithFormat:@"%@ (%ld)", mailFolderObj.folderName, (long)numberOfEmailInFolder];
        }
        else {
            cell.textLabel.text = mailFolderObj.folderName;
        }
    }
      return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    mailFolderObj= allFolderNames[indexPath.row];
    if ([mailFolderObj.folderName isEqualToString:FOLDER_INBOX] ||
        [mailFolderObj.folderName isEqualToString:FOLDER_RECYCLE_BIN] ||
        [mailFolderObj.folderName isEqualToString:FOLDER_JUNK] ||
        [mailFolderObj.folderName isEqualToString:FOLDER_SAVED_EMAILS] ||
        [mailFolderObj.folderName isEqualToString:FOLDER_DRAFTS] ||
        [mailFolderObj.folderName isEqualToString:FOLDER_SENT] ||
        [mailFolderObj.folderName isEqualToString:FOLDER_OUTBOX])
    {
        [[CAlertView new] showError:NSLocalizedString(mError_CanNotDeleteSelectedFolder, nil)];
    }
    else
    {
        if ([[EmailFacade share] getEmailHeadersInFolder:mailFolderObj.folderIndex.intValue].count > 0)
        {
            [[CAlertView new] showError:NSLocalizedString(mError_OnlyEmptyFoldersCanBeDeleted, nil)];
            return;
        }
        NSString *alertTitle = [NSString stringWithFormat:mWarning_DeleteEmptyFolder, mailFolderObj.folderName];
        selectedRow = (int)indexPath.row;
        [[CAlertView new] showWarning:alertTitle TARGET:self ACTION:@selector(deleteFolder)];
    }
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    CGPoint p = [gestureRecognizer locationInView:self.tblEmailFolder];
    
    NSIndexPath *indexPath = [self.tblEmailFolder indexPathForRowAtPoint:p];
    
    if (indexPath == nil)
    {
        NSLog(@"long press on table view but not on a row");
    }
    else if (gestureRecognizer.state == UIGestureRecognizerStateBegan)
    {
        MailFolder *folderInfo = allFolderNames[indexPath.row];
        if ([folderInfo.folderName isEqualToString:FOLDER_INBOX] ||
            [folderInfo.folderName isEqualToString:FOLDER_RECYCLE_BIN] ||
            [folderInfo.folderName isEqualToString:FOLDER_JUNK] ||
            [folderInfo.folderName isEqualToString:FOLDER_SAVED_EMAILS] ||
            [folderInfo.folderName isEqualToString:FOLDER_DRAFTS] ||
            [folderInfo.folderName isEqualToString:FOLDER_SENT] ||
            [folderInfo.folderName isEqualToString:FOLDER_OUTBOX])
        {
            NSLog(@"long press on table view at row %ldl", (long)indexPath.row);
        }
        else
        {
            // push view newfolder email
            NewFolderEmail *newFolder = [NewFolderEmail new];
            newFolder.folderName = folderInfo.folderName;
            [self.navigationController pushViewController:newFolder animated:YES];
        }
    }
    else
    {
        NSLog(@"gestureRecognizer.state = %ld", (long)gestureRecognizer.state);
    }
}

- (void)deleteFolder
{
     mailFolderObj = allFolderNames[selectedRow];
     [allFolderNames removeObjectAtIndex:selectedRow];
    [[EmailFacade share]deleteEmailFolder:mailFolderObj.folderName];
    [tblEmailFolder reloadData];
}



@end
