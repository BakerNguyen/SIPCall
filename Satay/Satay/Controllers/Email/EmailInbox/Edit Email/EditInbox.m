//
//  EditInbox.m
//  Satay
//
//  Created by Arpana Sakpal on 3/17/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import "EditInbox.h"
#import "EmailEditCell.h"
#import "InboxNavigationView.h"
#import "EmailFolderView.h"

@interface EditInbox ()
{
    
    NSMutableArray *arrayEmailSearchCheck;
    
    InboxNavigationView *navTitleView;
    
    NSMutableSet *checkedSectionKeys;
    NSMutableSet *checkedIndexPaths;
    
    NSInteger numberOfEmailSelected;
    
    MailFolder *mailFolder;
    
    // Contains all classified emails to be shown
    NSDictionary *emailsDict;
    // Sorted section key list of the emails to be shown
    NSArray *sectionKeys;
    // Number of unread messages
    NSUInteger unreadMessageCount;
}

@end

@implementation EditInbox
@synthesize tblEditInbox;
@synthesize folderIndex;
@synthesize sortingType;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    checkedSectionKeys = [NSMutableSet new];
    checkedIndexPaths = [NSMutableSet new];
    
    // Navigation bar
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem createRightButtonTitle:_CLOSE Target:self Action:@selector(closeClick:)];
    self.navigationItem.hidesBackButton = YES;
    
    // Hardcode a button without title to make title view back to center of navigation bar
    UIButton *btnMenu = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 65, 30)];
    [btnMenu setTitle:@"" forState:UIControlStateNormal];
    [btnMenu.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [btnMenu.titleLabel setTextColor:[UIColor clearColor]];
     UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:btnMenu];
    self.navigationItem.leftBarButtonItem = backButton;
    
    navTitleView = [InboxNavigationView newView];
    navTitleView.lblEmailAddress.text = [[EmailFacade share] getEmailAddress];
    mailFolder = [[EmailFacade share] getMailFolderFromIndex:folderIndex];
    navTitleView.lblFolderName.text = mailFolder.folderName;
    self.navigationItem.titleView = navTitleView;
    
    numberOfEmailSelected = 0;
   
    // Register cell for edit table
    [self.tblEditInbox registerNib:[UINib nibWithNibName:@"EmailEditCell"
                                                  bundle:[NSBundle mainBundle]]
            forCellReuseIdentifier:@"EmailEditCell"];
    self.tblEditInbox.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    [self setupView];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
}

-(void) getEmailHeaders{
    
    NSNumber *unreadMessageNumber = nil;
    
    // Get all emails in the folder inbox and clasify them into section keys
    NSDictionary *emailDict = [[EmailFacade share] getEmailsOfUser:[[EmailFacade share] getEmailAddress]
                                                            folder:folderIndex
                                                      groupingType:[[EmailFacade share] groupingTypeBySortingType:self.sortingType]
                                                unreadMessageNumber:&unreadMessageNumber
                                                        fetchEmail:_fectchEmail];
    
    unreadMessageCount = [[EmailFacade share] countTotalUnreadEmailInFolderIndex:folderIndex];
    
    emailsDict = [[EmailFacade share] emailsDictionayWithSortedContentFromDictionary:emailDict sortingType:self.sortingType];
    
    sectionKeys = [[EmailFacade share] sortedSectionKeysFromKeys:[emailsDict allKeys]
                                                          sortingType:self.sortingType];
    
}



- (IBAction)closeClick:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSLog(@"sectionKeys Count: %lu", (unsigned long)sectionKeys.count);
    return (sectionKeys.count > 0) ? (sectionKeys.count) : 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    NSString *sectionKey = [sectionKeys objectAtIndex:section];
    NSUInteger rowNumber = [(NSArray*)[emailsDict objectForKey:sectionKey] count];

    return rowNumber;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EmailEditCell *cell = (EmailEditCell *)[tableView dequeueReusableCellWithIdentifier:@"EmailEditCell"];
    
    cell.btnCheck.layer.cornerRadius = 10;
    cell.btnCheck.layer.borderWidth  = 1.0;
    cell.btnCheck.layer.borderColor  = [UIColor lightGrayColor].CGColor;

    [self configureEmailCell:cell atIndexPath:indexPath];
    
    [cell.btnCheck addTarget:self action:@selector(selectEmail:) forControlEvents:UIControlEventTouchUpInside];
    
    
    return cell;
}

- (void)configureEmailCell:(EmailEditCell *)cell atIndexPath:(NSIndexPath *)indexPath;
{
    NSString *sectionKey = [sectionKeys objectAtIndex:indexPath.section];
    NSArray *emailsInSection = [emailsDict objectForKey:sectionKey];
    
    MailHeader *email = [emailsInSection objectAtIndex:indexPath.row];
    
    // Tag for check button
    cell.btnCheck.tag = indexPath.row + 100;
    // The cell is checked if its is checked or its section is checked
    if ([checkedSectionKeys member:sectionKey] || [checkedIndexPaths member:indexPath]) {
        [cell.btnCheck setImage:[UIImage imageNamed:IMG_CHECKMARK] forState:UIControlStateNormal];
    }
    else {
        [cell.btnCheck setImage:nil forState:UIControlStateNormal];
    }
    
    NSString *dateFormat = FORMAT_DATE_MMMDDYYY;
    if (sectionKey == kInboxSectionKeyToday || sectionKey == kInboxSectionKeyYesterday)
        dateFormat = FORMAT_EMAIL_TIME;
    
    cell.lblDate.text = [ChatAdapter convertDateToString:email.sendDate format:dateFormat];
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
    //update title
    numberOfEmailSelected = checkedIndexPaths.count;
    if (numberOfEmailSelected > 0) {
        navTitleView.lblFolderName.text = [NSString stringWithFormat:NSLocalizedString(LABEL_COUNT_SELECTED,nil), numberOfEmailSelected];
        navTitleView.lblEmailAddress.text = @"";
    }else{
        navTitleView.lblFolderName.text = (unreadMessageCount > 0) ? [NSString stringWithFormat:@"%@ (%ld)",NSLocalizedString(([NSString stringWithFormat:@"%@", mailFolder.folderName]),nil), (long)unreadMessageCount] : NSLocalizedString(([NSString stringWithFormat:@"%@", mailFolder.folderName]),nil);
        navTitleView.lblEmailAddress.text = [[EmailFacade share] getEmailAddress];
    }

}

- (void)selectEmail:(UIButton *) sender
{

    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tblEditInbox];
    NSIndexPath *indexPath = [self.tblEditInbox indexPathForRowAtPoint:buttonPosition];
    NSUInteger section = indexPath.section;
    NSString *sectionKey = [sectionKeys objectAtIndex:section];
    
    if ([checkedIndexPaths member:indexPath]) {
        // Remove the item from the checked list
        [checkedIndexPaths removeObject:indexPath];
        // Remove its section from the checked list also
        [checkedSectionKeys removeObject:sectionKey];
    }
    else {
        
        if (indexPath != nil) {
            [checkedIndexPaths addObject:indexPath];
        }
        // If the section's items has been already checked, mark the section checked also
        NSMutableSet *sectionIndexPaths = [NSMutableSet new];
        NSArray *emailsInSection = [emailsDict objectForKey:sectionKey];
        NSUInteger emailCount = emailsInSection.count;
        for (NSUInteger row = 0; row < emailCount; row++) {
            NSIndexPath *aIndexPath = [NSIndexPath indexPathForRow:row inSection:section];
            
            if (aIndexPath != nil) {
                [sectionIndexPaths addObject:aIndexPath];
            }
        }
        
        if ([sectionIndexPaths isSubsetOfSet:checkedIndexPaths]) {
            if (sectionKey != nil) {
                [checkedSectionKeys addObject:sectionKey];
            }
        }
    }
    
    [tblEditInbox reloadData];
 

}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}

- (UIView*) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    UIView* viewHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width , 80)];
    viewHeader.backgroundColor = COLOR_230230230;
    UIButton *btnSelectAll = [[UIButton alloc] initWithFrame:CGRectMake(8, 10, 20, 20)];
    btnSelectAll.layer.cornerRadius = 10;
    btnSelectAll.layer.borderWidth  = 1.0;
    btnSelectAll.layer.borderColor  = [UIColor lightGrayColor].CGColor;
    [btnSelectAll addTarget:self action:@selector(selectAllEmail:) forControlEvents:UIControlEventTouchUpInside];
    [btnSelectAll setImage:[UIImage imageNamed:IMG_CHECKMARK] forState:UIControlStateSelected];
    btnSelectAll.tag = section;

    
    UILabel* lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(32, 12, 20, 10)];
    lblTitle.textColor = COLOR_148148148;
    lblTitle.font = [UIFont systemFontOfSize:FONT_TEXT_SIZE_14];
    UILabel* lblDate;
    
    
    lblDate = [[UILabel alloc] initWithFrame:CGRectMake(self.view.width - 100, 12, 70, 10)];
   
    lblDate.textColor = COLOR_148148148;
    lblDate.font = [UIFont systemFontOfSize:FONT_TEXT_SIZE_14];
    
    
    
    NSString *sectionKey = [sectionKeys objectAtIndex:section];
    NSArray *emailsInSection = (NSArray *)[emailsDict objectForKey:sectionKey];
    
    //Section Title
    
    lblTitle.text = [[EmailFacade share]nameStringForInboxSectionKey:sectionKey itemCount:emailsInSection.count];
    lblDate.text =[[EmailFacade share]dateStringForInboxSectionKey:sectionKey];
    
    if ([checkedSectionKeys member:sectionKey])
    {
        btnSelectAll.selected = YES;
    }
    else
    {
        btnSelectAll.selected = NO;
    }
    
    
    lblTitle.textAlignment = NSTextAlignmentLeft;
    [lblTitle sizeToFit];
    lblDate.textAlignment = NSTextAlignmentRight;
    [lblDate sizeToFit];
    
    
    [viewHeader addSubview:btnSelectAll];
    [viewHeader addSubview:lblTitle];
    [viewHeader addSubview:lblDate];
    return viewHeader;
}


- (void)selectAllEmail:(UIButton *) sender
{
    
    NSUInteger section = sender.tag;
    NSString *sectionKey = [sectionKeys objectAtIndex:section];
    NSArray *emailsInSection = [emailsDict objectForKey:sectionKey];
    NSUInteger sectionRowCount = emailsInSection.count;

    if ([checkedSectionKeys member:sectionKey])
    {
        // Remove the section key from the checked list
        
        [checkedSectionKeys removeObject:sectionKey];
        // Remove all items of the section from the checked list
        
        for (NSUInteger row = 0; row < sectionRowCount; row++)
        {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
            [checkedIndexPaths removeObject:indexPath];
        }
    }
    else
    {
        // Add the section key into the checked list
        [checkedSectionKeys addObject:sectionKey];
        // Add all items of the section into the checked list

        for (NSUInteger row = 0; row < sectionRowCount; row++)
        {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
            [checkedIndexPaths addObject:indexPath];
        }
    }
    [self.tblEditInbox reloadData];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 64;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  
    NSUInteger section = indexPath.section;
    NSString *sectionKey = [sectionKeys objectAtIndex:section];
    
    if ([checkedIndexPaths member:indexPath]) {
        // Remove the item from the checked list
        [checkedIndexPaths removeObject:indexPath];
        // Remove its section from the checked list also
        [checkedSectionKeys removeObject:sectionKey];
    }
    else {
        // Add the item into the checked list
        [checkedIndexPaths addObject:indexPath];
        // If the section's items has been already checked, mark the section checked also
        NSMutableSet *sectionIndexPaths = [NSMutableSet new];
        NSArray *emailsInSection = [emailsDict objectForKey:sectionKey];
        NSUInteger emailCount = emailsInSection.count;
        
        for (NSUInteger row = 0; row < emailCount; row++) {
            NSIndexPath *aIndexPath = [NSIndexPath indexPathForRow:row inSection:section];
            [sectionIndexPaths addObject:aIndexPath];
        }
        
        if ([sectionIndexPaths isSubsetOfSet:checkedIndexPaths]) {
            [checkedSectionKeys addObject:sectionKey];
        }
    }
    
    [self.tblEditInbox reloadData];

}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)clickedBtnDelete:(id)sender {
    
    if (checkedIndexPaths.count > 0) {
        self.alertView = [[CAlertView alloc] init];
        [self.alertView showWarning:mError_EmailWillDeleted TARGET:self ACTION:@selector(deleteEmail)];
    }
    else {
        [[CAlertView new]showError:NSLocalizedString(mError_SelectEmailForDelete, nil)];

    }
}

- (void)deleteEmail
{
    MailHeader *mailHeader;
    for (NSIndexPath *indexPath in checkedIndexPaths)
    {
        NSString *sectionKey = [sectionKeys objectAtIndex:indexPath.section];
        NSArray *emailsInSection = [emailsDict objectForKey:sectionKey];
        mailHeader = [emailsInSection objectAtIndex:indexPath.row];
        for (MailHeader *emailHeader in [_fectchEmail mutableCopy]) {
            if ([emailHeader.uid isEqualToString:mailHeader.uid])
                [_fectchEmail removeObject:emailHeader];
        }
        [[EmailFacade share] deleteEmail:mailHeader.uid inFolder:[mailHeader.folderIndex doubleValue]];
        
    }
    [checkedIndexPaths removeAllObjects];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self setupView];
    });
    
}

- (void) setupView
{
    //Get Data to display
    [self getEmailHeaders];
    navTitleView.lblFolderName.text = (unreadMessageCount > 0) ? [NSString stringWithFormat:@"%@ (%ld)",NSLocalizedString(([NSString stringWithFormat:@"%@", mailFolder.folderName]),nil), (long)unreadMessageCount] : NSLocalizedString(([NSString stringWithFormat:@"%@", mailFolder.folderName]),nil);
    
    [tblEditInbox reloadData];
    tblEditInbox.scrollEnabled = YES;
}

- (IBAction)clickedBtnMove:(id)sender {
    
    if (checkedIndexPaths.count > 0) {
        
        // Get emails to be removed
        NSMutableArray *movedEmails = [NSMutableArray new];
        for (NSIndexPath *indexPath in checkedIndexPaths) {
            NSString *sectionKey = [sectionKeys objectAtIndex:indexPath.section];
            NSArray *emailsInSection = [emailsDict objectForKey:sectionKey];
            MailHeader *email = [emailsInSection objectAtIndex:indexPath.row];
            [movedEmails addObject:email];
        }
        EmailFolderView *folderVC = [[EmailFolderView alloc] initWithNibName:@"EmailFolderView" bundle:nil];
        folderVC.moveEmails = movedEmails;
        folderVC.isMoveEmail = YES;
        [self.navigationController pushViewController:folderVC animated:YES];
    }
    else {
        [[CAlertView new]showError:NSLocalizedString(mError_SelectEmailForMove, nil)];
    }
}



@end
