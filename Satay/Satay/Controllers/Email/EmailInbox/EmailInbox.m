//
//  EmailInbox.m
//  Satay
//
//  Created by Arpana Sakpal on 3/10/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import "EmailInbox.h"
#import "EmailCell.h"
#import "InboxSectionHeader.h"
#import "EditInbox.h"
#import "EmailDetailView.h"
#import "EmailSortBy.h"
#import "EmailFolderView.h"
#import "EmailComposeView.h"
#import "InboxNavigationView.h"
#import "BackgroundTask.h"
#import "VoiceCallView.h"

static NSString *simpleTableIdentifier = @"EmailCell";
@interface EmailInbox ()
{
    NSTimer *refreshDelayer;
    BOOL isUpdated;
    BOOL block;
    NSInteger totalNumberOfInboxMessages;
    NSUInteger unreadMessageCount;
    NSArray *messages;
    
    NSMutableArray *arrayEmail;
    
    NSMutableArray *searchResults;

    BOOL isSearch;
    
    UIRefreshControl *refreshControl;
    
    UIActivityIndicatorView *spinner;
    InboxNavigationView *navTitleView;
    BOOL isDisplayedSortByPopUp, needReload;
    NSMutableArray *arrayEmailSearchCheck;
    // Contains all classified emails to be shown
    NSDictionary *emailsDict;
    // Sorted section key list of the emails to be shown
    NSArray *sectionKeys;
    
    MailAccount *mailAccountObj;
    BackgroundTask *backgroundTask;//background task
    NSMutableArray *fectchEmail;
    NSString *oldestUID, *newestUID;
}

// Current sorting type to sort the emails
@property (assign, nonatomic) EmailSortingType sortingType;
@property (strong, nonatomic) EmailSortBy *sortingTypesVC;

@end

@implementation EmailInbox
@synthesize searchBar;
@synthesize tblInbox ;
@synthesize lblHintDescription;
@synthesize lblMailBoxEmpty;
@synthesize viewHeader,lblDate,lblTitle;

@synthesize folderIndex;

+ (EmailInbox *)share
{
    static dispatch_once_t once;
    static EmailInbox *share;
    
    dispatch_once(&once, ^{
        share = [[self alloc] init];
        [EmailFacade share].loadMoreEmailDelegate = share;
    });
    return share;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    fectchEmail = [NSMutableArray new];
    oldestUID = @"";
    self.lblMailBoxEmpty.hidden=YES;
    self.lblHintDescription.hidden=YES;
    self.searchBar.delegate=self;
    self.tblInbox.delegate=self;
    self.tblInbox.dataSource=self;
    [SIPFacade share].emailInboxDelegate = self;
    //pull down to refresh
    refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self.tblInbox addSubview:refreshControl];
    
    self.navigationItem.rightBarButtonItem=[UIBarButtonItem createRightButtonTitle:_EDIT
                                                                            Target:self
                                                                            Action:@selector(editClick:)];
    
    [self.tblInbox registerNib:[UINib nibWithNibName:@"EmailCell"
                                              bundle:[NSBundle mainBundle]]
                forCellReuseIdentifier:@"EmailCell"];
    
    // Default email sorting type
    self.sortingType = EmailSortingTypeDateASC;
    
    mailAccountObj = [[EmailFacade share] getMailAccount:[[EmailFacade share] getEmailAddress]];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        //Re load email when restore account
        NSInteger numberMailHeader = [[EmailFacade share] getNumberOfEmailHeadersInFolder:kINDEX_FOLDER_INBOX];

        if (numberMailHeader == 0)  //relload email
        {
            int type = [mailAccountObj.accountType intValue];

            if (type != 5) //Imap kind
            {
                [[EmailFacade share] getConfigurationImapAccount];
            }
            else  //Pop kind
            {
                [[EmailFacade share] getConfigurationPopAccount];
            }

            [[EmailFacade share] getEmailHeaders:mailAccountObj.fullEmail];
        }
    });
    
    //Sync schedule get new emails
    int timerSyncSchedule = (int)[[EmailFacade share] getTimerFromPeriodSyncSchedule:[mailAccountObj.periodSyncSchedule integerValue]];
    [self syncScheduleGetNewEmails:timerSyncSchedule];
    self.edgesForExtendedLayout=UIRectEdgeNone;
    [[CWindow share] showLoading:kLOADING_LOADING];
    isSearch = NO;
}

- (void)refresh:(UIRefreshControl *)refreshControl1
{
    self.tblInbox.scrollEnabled = NO;
    [refreshDelayer invalidate];
    refreshDelayer = nil;
    refreshDelayer = [NSTimer scheduledTimerWithTimeInterval:3
                                                     target:self
                                                   selector:@selector(delayedRefresh:)
                                                   userInfo:nil
                                                    repeats:NO];
    if (needReload)
    {
        needReload = NO;
        //Get new emails
        [[EmailFacade share] getNewEmailHeaders];
    }
    
 }


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!folderIndex) {//For first time load email. then folder is Inbox. Else get email from related folder
        folderIndex = 1;//inbox
    }
    
    if (folderIndex != 1)// not inbox
    {
        self.navigationItem.leftBarButtonItem=[UIBarButtonItem createLeftButtonTitle:_BACK
                                                                              Target:self
                                                                              Action:@selector(backToPreviousView:)];
    }
    
    tblInbox.userInteractionEnabled = NO;
    //Get Data to display
    [self getEmailHeaders];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (![self.searchBar.text isEqualToString:@""])
    {
        self.searchBar.text = @"";
        isSearch = NO;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [refreshControl endRefreshing];
}

- (void) viewDidDisappear:(BOOL)animated
{
    [fectchEmail removeAllObjects];
    oldestUID = nil;
    newestUID = nil;
}

-(void)syncScheduleGetNewEmails:(NSInteger)intTime{
    
    if (backgroundTask == nil) {
        backgroundTask = [BackgroundTask share];
    }
    //Stop old background task
    [backgroundTask stopBackgroundTask];
    
    if (intTime != 0)
    {
        //call background task get new email from server
        NSLog(@"Time for syn schedule emails:%li", (long)intTime);
        [backgroundTask startBackgroundTasks:intTime target:self selector:@selector(refresh:)];
    }
}

- (void)getEmailHeaders
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        NSMutableArray *queryHeaders = [[EmailFacade share] getEmailHeadersWithOrderBy:YES
                                                                              inFolder:folderIndex
                                                                                 limit:10
                                                                             oldestUID:oldestUID
                                                                              isGetOld:YES];
        [fectchEmail addObjectsFromArray:queryHeaders];
        [self buildView:fectchEmail];

        unreadMessageCount = [[EmailFacade share] countTotalUnreadEmailInFolderIndex:folderIndex];
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            navTitleView = [InboxNavigationView newView];
            navTitleView.lblEmailAddress.text = [[EmailFacade share] getEmailAddress];
            navTitleView.lblFolderName.text = (unreadMessageCount > 0) ? [NSString stringWithFormat:@"%@ (%ld)", NSLocalizedString(([NSString stringWithFormat:@"%@", [self folderName]]), nil), (long)unreadMessageCount] : NSLocalizedString(([NSString stringWithFormat:@"%@", [self folderName]]), nil);
            self.navigationItem.titleView = navTitleView;
        });
    });
}

- (IBAction)backToPreviousView:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)backToMenu:(id)sender
{
    [[CWindow share] showMailBox];
    [[CWindow share].menuController showLeftPanelAnimated:YES];
}
- (IBAction)editClick:(id)sender
{
    EditInbox *editEmailVC = [[EditInbox alloc] initWithNibName:@"EditInbox" bundle:nil];
    editEmailVC.folderIndex = folderIndex;
    editEmailVC.sortingType = self.sortingType;
    editEmailVC.fectchEmail = [fectchEmail mutableCopy];
    [self.navigationController pushViewController:editEmailVC animated:YES];

}

- (void)changePassword
{
    UIAlertView *dialog = [[UIAlertView alloc] initWithTitle:ENTER_PASSWORD
                                                     message:@""
                                                    delegate:self
                                           cancelButtonTitle:_CANCEL
                                           otherButtonTitles:_OK, nil];
    
    [dialog setAlertViewStyle:UIAlertViewStylePlainTextInput];
    
    // Change keyboard type
    [[dialog textFieldAtIndex:0] setSecureTextEntry:YES];
    [dialog show];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) delayedRefresh:(NSTimer *)timer
{
    self.tblInbox.scrollEnabled = YES;
    [refreshControl endRefreshing];
    refreshDelayer = nil;
}


- (void)registerTableViewCells
{
    // Register cell for inbox table
    [self.tblInbox registerNib:[UINib nibWithNibName:@"EmailCell" bundle:nil]
        forCellReuseIdentifier:simpleTableIdentifier];
    
    // Also register cell for search results table
//    [self.searchDisplayController.searchResultsTableView registerNib:[UINib nibWithNibName:@"EmailCell" bundle:nil] forCellReuseIdentifier:simpleTableIdentifier];
}

-(void)callChangeState{
    [self fixView];
}

///////////////////////////////////////////////////////

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (searchBar.text.length > 0)
    {
        return 1;
    }
    else
    {
        NSLog(@"sectionKeys Count: %lu", (unsigned long)sectionKeys.count);
        return (sectionKeys.count > 0) ? (sectionKeys.count + 1) : 0;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
   if (searchBar.text.length > 0)
    {
        [self searchThroughData];
         return [searchResults count];
    }
    else
    {
        if (section == sectionKeys.count)
        {
            if (folderIndex == 1) // inbox
                return 1;
            else return 0;
        }
        else
        {
            NSString *sectionKey = [sectionKeys objectAtIndex:section];
            NSUInteger numberOfRows = [(NSArray*)[emailsDict objectForKey:sectionKey] count];
            return numberOfRows;
        }
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (folderIndex != 1)
    {
        NSString *sectionKey = [sectionKeys objectAtIndex:indexPath.section];
        NSArray *emailsInSection = [emailsDict objectForKey:sectionKey];

        if (indexPath.section == sectionKeys.count - 1 && indexPath.row == emailsInSection.count - 1)
        {
            NSLog(@"indexPath.section: %ld  indexPath.row: %ld", (long)indexPath.section, (long)indexPath.row);
            [self loadMoreEmails];
        }
    }
    else
    {
        if (indexPath.section == sectionKeys.count)
        {
            NSMutableArray *queryHeaders = [[EmailFacade share] getEmailHeadersWithOrderBy:YES
                                                                                  inFolder:folderIndex
                                                                                     limit:10
                                                                                 oldestUID:oldestUID
                                                                                  isGetOld:YES];
            if (queryHeaders.count > 0 )
            {
                [fectchEmail addObjectsFromArray:queryHeaders];
                [self buildView:fectchEmail];
            }
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
     static NSString *simpleTableIdentifier = @"EmailCell";
    
    EmailCell *cell = (EmailCell *)[self.tblInbox dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    MailHeader *mailHeader;

    if(searchBar.text.length > 0)
    {
        if (indexPath.section >= searchResults.count)
            return cell;

        mailHeader = [searchResults objectAtIndex:indexPath.row];
        cell.lblFrom.text = mailHeader.extend1;
        cell.lblSubject.text = mailHeader.subject;
        cell.lblDescription.text = mailHeader.shortDesc;
         cell.btnLoadMore.hidden = YES;
        if (mailHeader.attachNumber > 0)
            cell.imgAttachment.image = [UIImage imageNamed:IMG_EMAIL_ICON_ATTACH];
        cell.lblDate.text = [ChatAdapter convertDateToString:mailHeader.sendDate format:FORMAT_EMAIL_DATE];
    }
    else if (indexPath.section == sectionKeys.count)
    {
        if (folderIndex != 1)
        {
            cell.btnLoadMore.hidden = YES;
        }
        else if (emailsDict.count > 0)
        {
            // Show more cell
            cell.backgroundColor = [UIColor whiteColor];
            cell.btnLoadMore.hidden = NO;
            [cell.btnLoadMore addTarget:self
                                 action:@selector(loadMoreEmailsAction:)
                       forControlEvents:UIControlEventTouchUpInside];
            cell.btnLoadMore.clipsToBounds = YES;
            cell.btnLoadMore.layer.cornerRadius = 4.0;
            cell.btnLoadMore.layer.borderColor= [UIColor blackColor].CGColor;
            cell.btnLoadMore.layer.borderWidth= 1.0f;
            
        }
    }
    else
    {
        [self configureEmailCell:cell atIndexPath:indexPath];
    
    }
      return cell;
}

- (void)configureEmailCell:(EmailCell *)cell atIndexPath:(NSIndexPath *)indexPath;
{
    if (indexPath.section >= sectionKeys.count) {
        return;
    }
    NSString *sectionKey = [sectionKeys objectAtIndex:indexPath.section];
    NSArray *emailsInSection = [emailsDict objectForKey:sectionKey];
    
    MailHeader *email = [emailsInSection objectAtIndex:indexPath.row];
    
    if (indexPath.section == sectionKeys.count)
    {
        cell.btnLoadMore.hidden = NO;
        [cell.btnLoadMore addTarget:self
                             action:@selector(loadMoreEmailsAction:)
                   forControlEvents:UIControlEventTouchUpInside];
    }
    else
        cell.btnLoadMore.hidden = YES;

    cell.lblDate.text = [ChatAdapter convertDateToString:email.sendDate
                                                  format:FORMAT_EMAIL_TIME];
    cell.lblFrom.text = email.extend1;
    cell.lblSubject.text = email.subject;
    cell.lblDescription.text = [email.shortDesc stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    // If there is any attachment, show icon
    if ([email.attachNumber intValue] > 0)
        cell.imgAttachment.image = [UIImage imageNamed:IMG_EMAIL_ICON_ATTACH];
    
    if ([email.emailStatus intValue] == 1)//Seen
        cell.backgroundColor = [UIColor clearColor];
    else
        cell.backgroundColor = COLOR_231246255;

}


#pragma mark - UITableViewDelegate
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (searchBar.text.length > 0)
    {
        viewHeader = [self headerViewForSearchResultsTable];
    }
    else
    {
        if (section == sectionKeys.count)
        {
            viewHeader = [self headerViewForShowMoreSection];
        }
        else
        {
            if (section < sectionKeys.count)
            {
                NSString *sectionKey = [sectionKeys objectAtIndex:section];
                NSArray *emailsInSection = (NSArray *)[emailsDict objectForKey:sectionKey];
                
                viewHeader = [InboxSectionHeader headerForSectionKey:sectionKey
                                                           itemCount:emailsInSection.count
                                                         sortingType:self.sortingType];

            }
        }
    }
    
    return viewHeader;
}

- (UIView *)headerViewForSearchResultsTable
{
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 80)];
    header.backgroundColor = COLOR_230230230;
    
    UILabel *labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(20, 1, 20, 10)];
    labelTitle.font = [UIFont systemFontOfSize:14];
    labelTitle.textColor = COLOR_148148148;
    labelTitle.text = [NSString stringWithFormat:NSLocalizedString(@"Search results(%i)",nil), searchResults.count];
    labelTitle.textAlignment = NSTextAlignmentLeft;
    [labelTitle sizeToFit];
    
    [header addSubview:labelTitle];
    return header;
}

- (UIView *)headerViewForShowMoreSection
{
    InboxSectionHeader *header = [InboxSectionHeader newHeader];
    
    header.nameLabel.text = NSLocalizedString(ADD_MORE_EMAIL,nil);
    
    return header;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == sectionKeys.count)
    {
        if (folderIndex != 1)
            return 0.0;
        else
            return 75.0;
    }
    else
    {
        return 64.0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == sectionKeys.count)
    {
        return 0;
    }
    else
    {
        return 40.0;
    }}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    [self endSearch];

    if (searchResults.count > 0)
    {
        if (indexPath.section >= searchResults.count)
            return;

        MailHeader *email = [searchResults objectAtIndex:indexPath.row];
        [self navigateToEmailDetailView:email];
        return;
    }

    if (indexPath.section != sectionKeys.count)
    {
        NSString *sectionKey = [sectionKeys objectAtIndex:indexPath.section];
        NSArray *emailsInSection = [emailsDict objectForKey:sectionKey];
        if (indexPath.row >= emailsInSection.count)
            return ;

        MailHeader *email = (MailHeader *)[emailsInSection objectAtIndex:indexPath.row];

        if (folderIndex == kINDEX_FOLDER_DRAFTS)
        {
            // reopen compose
            [self navigateToEmailComposeView:email];
        }
        else
        {
            // View email's detail
            [self navigateToEmailDetailView:email];
        }
    }
}

- (NSString *)folderName
{
    if (folderIndex == 1)
    {
        return TITLE_INBOX;
    }
    else
    {
        MailFolder *currentMailFolder = [[EmailFacade share] getMailFolderFromIndex:folderIndex];
        return currentMailFolder.folderName;
    }
}
#pragma mark - UISearchBarDelegate
-(void)searchBar:(UISearchBar *)theSearchBar textDidChange:(NSString *)searchText
{
    [self searchThroughData];
    [tblInbox reloadData];
}

-(void)searchBarTextDidBeginEditing:(UISearchBar *)theSearchBar {
    [self startSearch];
}
-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    self.searchBar.text = @"";
    [self searchThroughData];
    [tblInbox reloadData];
    [self endSearch];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self.view endEditing:YES];
}

-(void)startSearch
{   isSearch = YES;
    self.navigationController.navigationBarHidden = YES;
    [searchBar setShowsCancelButton:YES];
    [self fixView];
}

-(void)endSearch
{   [self.topSpacing setConstant:0];
    self.searchBar.text = @"";
    [searchBar resignFirstResponder];
    isSearch = NO;
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    self.navigationController.navigationBarHidden = NO;
    [searchBar setShowsCancelButton:NO];
}
-(void)fixView
{
    if (!isSearch)
        return;    
    
    if (![SIPFacade share].isMinimize){
        [self.topSpacing setConstant:0];
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
    }
    else{
        [self.topSpacing setConstant:20];
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
    }
}

- (void)searchThroughData
{
    [searchResults removeAllObjects];
    NSPredicate *resultsPredicate = [NSPredicate predicateWithFormat:@"subject contains[c] %@", self.searchBar.text];
    //isSearch = YES;
    searchResults = [[arrayEmail filteredArrayUsingPredicate:resultsPredicate] mutableCopy];
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [searchBar resignFirstResponder];
}
- (void) moveToComposeWithEmail:(NSString*)emailContact
{
    EmailComposeView *compose = [EmailComposeView  new];
    compose.composeAction = (ComposeEmailAction *)kCOMPOSE_EMAIL_ACTION_COMPOSE;
    compose.toEmailAddress = emailContact;
    [self.navigationController pushViewController:compose animated:YES];
}
- (IBAction)clickedBtnCompose:(id)sender
{
    [self moveToComposeWithEmail:@""];
}

- (IBAction)clickedBtnSortBy:(id)sender
{
    [self showSortingByPopUp];
}

- (IBAction)clickedBtnAllFolder:(id)sender
{
  EmailFolderView  *folder = [EmailFolderView new];
    [self.navigationController pushViewController:folder animated:YES];
 
}

- (void)showSortingByPopUp
{
    if (!isDisplayedSortByPopUp) {
        isDisplayedSortByPopUp = YES;
        
        // Init controller
        self.sortingTypesVC = [[EmailSortBy alloc] initWithNibName:@"EmailSortBy" bundle:nil];;
        self.sortingTypesVC.sortingType = self.sortingType;
        __weak EmailInbox *weakSelf = self;
        self.sortingTypesVC.delegate = (id)weakSelf;
        
        [self.sortingTypesVC.view changeWidth:self.view.width
                                       Height:self.view.height];
        
        // Add subview
        [self.view addSubview:self.sortingTypesVC.view];
        
        self.navigationItem.rightBarButtonItem=[UIBarButtonItem createLeftButtonTitle:_CLOSE
                                                                               Target:self
                                                                               Action:@selector(dismissSortingByPopUp)];

        self.navigationItem.titleView = nil;
        [self.navigationItem setTitle:TITLE_SORT_BY];
        
        
        // Animation
        
        CGRect frame = self.sortingTypesVC.view.frame;
        frame.origin.y = CGRectGetHeight(self.view.frame) - 0; //65
        self.sortingTypesVC.view.frame = frame;
        
        [UIView animateWithDuration:0.25
                         animations:^{
                             CGRect frame = self.sortingTypesVC.view.frame;
                             frame.origin.y = 0; //65
                             self.sortingTypesVC.view.frame = frame;
                         }];
        
    }
    
}

- (void)dismissSortingByPopUp
{
    
    if (isDisplayedSortByPopUp) {
        isDisplayedSortByPopUp  = NO;
        
        // Remove with animation
        [UIView animateWithDuration:0.25
                         animations:^{
                             CGRect frame = self.sortingTypesVC.view.frame;
                             frame.origin.y = CGRectGetHeight(self.view.frame);
                             self.sortingTypesVC.view.frame = frame;
                         } completion:^(BOOL finished) {
                             [self.sortingTypesVC.view removeFromSuperview];
                         }];
        
        //[self.navigationItem setTitle:TITLE_INBOX];
        [self.navigationItem setTitleView:navTitleView];
        self.navigationItem.rightBarButtonItem=[UIBarButtonItem createRightButtonTitle:_EDIT
                                                                                Target:self
                                                                                Action:@selector(editClick:)];
        self.navigationItem.leftBarButtonItem=[UIBarButtonItem createLeftButtonTitle:_MENU
                                                                              Target:self
                                                                              Action:@selector(backToMenu:)];
    }
}

#pragma mark - Sorting delegate function
- (void)sortingTypeDidChange:(EmailSortingType)sortingType
{
    [self dismissSortingByPopUp];
    self.sortingType = sortingType;
    [self buildView:fectchEmail];
}

#pragma mark - Load email details screen
- (void) loadMoreEmailsAction:(id)sender
{
    UIButton *btnLoadmore = (UIButton *)sender;
    btnLoadmore.enabled = NO;
    [self loadMoreEmails];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        btnLoadmore.enabled = YES;
    });
}
- (void)loadMoreEmails
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        NSMutableArray *queryHeaders = [[EmailFacade share] getEmailHeadersWithOrderBy:YES
                                                                              inFolder:folderIndex
                                                                                 limit:10
                                                                             oldestUID:oldestUID
                                                                              isGetOld:YES];

        if (queryHeaders.count == 0 )// at inbox and get no email in DB
        {
            if (folderIndex == 1)
                [[EmailFacade share] getMoreEmailHeaders];
        }
        else
        {
            [fectchEmail addObjectsFromArray:queryHeaders];
            [self buildView:fectchEmail];
        }
    });
}

- (void) buildView:(NSMutableArray*)arrayEmailHeaders
{
    NSNumber *unreadMessageNumber = nil;
    NSDictionary *emailDict = [[EmailFacade share] getEmailsOfUser:[[EmailFacade share] getEmailAddress]
                                                            folder:folderIndex
                                                      groupingType:[[EmailFacade share] groupingTypeBySortingType:self.sortingType]
                                               unreadMessageNumber:&unreadMessageNumber
                                                        fetchEmail:arrayEmailHeaders];
    emailsDict = [[EmailFacade share] emailsDictionayWithSortedContentFromDictionary:emailDict sortingType:self.sortingType];
    
    sectionKeys = [[EmailFacade share] sortedSectionKeysFromKeys:[emailsDict allKeys]
                                                     sortingType:self.sortingType];
    
    // We also need to build emails array for searching
    NSMutableArray *allEmails = [NSMutableArray new];
    
    for (NSArray *sectionEmails in [emailsDict allValues])
    {
        [allEmails addObjectsFromArray:sectionEmails];
    }
    
    arrayEmail = [allEmails mutableCopy];
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        //Arpana have added this to resolve bug 9126
        if (arrayEmail.count == 0)
        {
            lblMailBoxEmpty.hidden = NO;
            lblHintDescription.hidden = NO;
        }
        else
        {
            lblMailBoxEmpty.hidden = YES;
            lblHintDescription.hidden = YES;
        }
        
        [[CWindow share] hideLoading];
        MailHeader *lastEmailHeader = [fectchEmail lastObject];
        oldestUID = lastEmailHeader.uid;
        tblInbox.userInteractionEnabled = YES;
        [tblInbox reloadData];
        needReload = YES;
        tblInbox.scrollEnabled = YES;
    });
}

-(void) loadMoreEmailDetailSuccess:(NSString*)emailUID
{
    MailHeader *emailHeaderDetail = [[EmailFacade share] getMailHeaderFromUid:emailUID];
    int i;
    BOOL isEmailHeaderExist;
    for (i = 0; i < fectchEmail.count; i++) {
        MailHeader *emailHeaderCheck = [fectchEmail objectAtIndex:i];
        if ([emailHeaderCheck.uid isEqualToString:emailUID])
        {
            isEmailHeaderExist = YES;
            break;
        }
    }
    if (isEmailHeaderExist && i < fectchEmail.count)
    {
        //fectchEmail = [fectchEmail mutableCopy];
        [fectchEmail replaceObjectAtIndex:i withObject:emailHeaderDetail];
        
        //reload table view here
        if (block)
            return;
        
        block = YES;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            block = NO;
            [self buildView:fectchEmail];
            NSLog(@"reload table data");
        });
    }
}

-(void) loadMoreEmailsSuccess{
    //for get new emails
    [refreshControl endRefreshing];
    self.tblInbox.scrollEnabled = YES;
    [spinner stopAnimating];
    
    [self getEmailHeaders];
}

-(void) loadNewEmailsSuccess
{
    if (fectchEmail.count == 0)
    {
        newestUID = 0;
    }
    else
    {
        MailHeader *newestEmailHeader = [fectchEmail firstObject];
        newestUID = newestEmailHeader.uid;
    }
    NSMutableArray *queryHeaders = [[EmailFacade share] getEmailHeadersWithOrderBy:NO
                                                                          inFolder:folderIndex
                                                                             limit:100
                                                                         oldestUID:newestUID
                                                                          isGetOld:NO];
    for (MailHeader *queryHeader in queryHeaders) {
        [fectchEmail insertObject:queryHeader atIndex:0];
    }
    [self buildView:fectchEmail];
}
-(void) loadMoreEmailFailed
{
    needReload = YES;
    [refreshControl endRefreshing];
    [[CAlertView new] showError:ERROR_SERVER_GOT_PROBLEM];
}

-(void) removeEmailHeader:(NSString *)emailHeaderRemoveUID
{
    int i;
    BOOL isEmailHeaderExist;
    for (i = 0; i < fectchEmail.count; i++) {
        MailHeader *emailHeaderCheck = [fectchEmail objectAtIndex:i];
        if ([emailHeaderCheck.uid isEqualToString:emailHeaderRemoveUID])
        {
            isEmailHeaderExist = YES;
            break;
        }
    }
    if (isEmailHeaderExist)
    {
        [fectchEmail removeObjectAtIndex:i];
        [self buildView:fectchEmail];
    }
}

-(void) showLoadingView{
    if (self.navigationController.viewControllers.count > 0 &&
        [self.navigationController.viewControllers[self.navigationController.viewControllers.count -1] isKindOfClass:[EmailInbox class]] )
        [[CWindow share] showLoading:kLOADING_LOADING];
}

-(void) changedEmailPassword{
    [refreshControl endRefreshing];
    
    [[CAlertView new] showWarning:NSLocalizedString(ERROR_EMAIL_PASSWORD_CHANGED,nil)
                           TARGET:self
                           ACTION:@selector(changePassword)];
    //Turn off sync schedule
    [[BackgroundTask share] stopBackgroundTask];
}

-(void) disabledLessSecureApp{
     [refreshControl endRefreshing];
    
    [[CAlertView new] showError:NSLocalizedString(mError_WeAreUnableToSetupYourEmail, nil)];
    //Turn off sync schedule
    [[BackgroundTask share] stopBackgroundTask];
}

#pragma mark - navigate to email detail
- (void)navigateToEmailDetailView:(MailHeader*)email
{
    EmailDetailView *emailDetailView = [[EmailDetailView alloc] init];
    emailDetailView.mailHeader = email;
    emailDetailView.arrayEmails = arrayEmail;
    [self.navigationController pushViewController:emailDetailView animated:YES];
}

#pragma mark - navigate to compose email
- (void) navigateToEmailComposeView:(MailHeader*)emailHeader
{
    EmailComposeView *composeView = [[EmailComposeView alloc] initWithNibName:@"EmailComposeView" bundle:nil];
    composeView.composeAction = (ComposeEmailAction *)kCOMPOSE_EMAIL_ACTION_REOPEN_COMPOSE;
    [[EmailFacade share] buildReopenComposeWithHeader:emailHeader];

    [self.navigationController pushViewController:composeView animated:YES];
}
@end
