//
//  FindEmailContactViewController.m
//  Satay
//
//  Created by Arpana Sakpal on 3/17/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import "FindEmailContact.h"
#import "FindContactCell.h"
#import "ContactInfo.h"
#import "EmailComposeView.h"

@interface FindEmailContact ()
{
    NSMutableArray *emailContact;
    NSMutableArray *array_Contact;
    NSArray *indexTitles;
    NSArray *sectionTitles;
    NSMutableDictionary *dictionary_Contact;
    NSMutableArray *arrayContactSelect;
    BOOL isSelectAll, isSearch;
    
    UIButton *backButton, *selectAllButton;
    UIButton *closeButton;
    
}
@end
@implementation FindEmailContact
{
    NSMutableArray *arrayEmail;
    NSArray *searchResults;
}
@synthesize tblView, lblNumber, btnAddContact;
@synthesize isAddParticipants, arrPaticipant;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil parent:(id) _parent
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        parent = _parent;
    }
    return self;
}

+(FindEmailContact *)share{
    static dispatch_once_t once;
    static FindEmailContact * share;
    dispatch_once(&once, ^{
        share = [self new];
    });
    return share;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UITapGestureRecognizer* tapOnView = [[UITapGestureRecognizer alloc]initWithTarget:self
                                                                               action:@selector(btnAddContact)];
    [viewAddContact addGestureRecognizer:tapOnView];
    
    [self.tblView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    self.lblNumber.clipsToBounds = YES;
    self.lblNumber.layer.cornerRadius = 20.0;
    self.lblNumber.layer.borderWidth  = 1.0;
    self.lblNumber.layer.borderColor = COLOR_230230230.CGColor;
    
    lblNoContacts.hidden=NO;
    self.searchBar.delegate = self;
    array_Contact = [NSMutableArray new];
    arrayContactSelect = [NSMutableArray new];
    [ContactFacade share].findEmailContactDelegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[ContactFacade share] loadContactRequest];
    [[ContactFacade share] loadFriendArray];
    [[ContactInfo share].arrAddingMembers removeAllObjects];
    [arrayContactSelect removeAllObjects];
    [tblView reloadData];
    lblNumber.text = LABEL_NUMBER_0;
    if (isAddParticipants)
    {
        self.navigationItem.title=TITLE_ADD_PARTICIPANTS;
        self.navigationItem.rightBarButtonItem=[UIBarButtonItem createRightButtonTitle:_CLOSE
                                                                                Target:self
                                                                                Action:@selector(closeButtonClicked)];
        self.navigationItem.leftBarButtonItem = nil;
    }
    else  // Contacts for email
    {
        self.navigationItem.title=TITLE_CONTACTS;
        self.navigationItem.leftBarButtonItem=[UIBarButtonItem createLeftButtonTitle:_BACK
                                                                              Target:self
                                                                              Action:@selector(backToCompose)];
        self.navigationItem.rightBarButtonItem=[UIBarButtonItem createRightButtonTitle:_SELECT_ALL
                                                                                Target:self
                                                                                Action:@selector(clickedBtnSelectAll:)];
    }
    self.searchBar.text = @"";
    [btnAddContact.btnAddRequest addTarget:self
                                    action:@selector(clickedBtnAddContact:)
                          forControlEvents:UIControlEventTouchUpInside];
    btnAddContact.btnAddRequest.layer.masksToBounds = YES;
    btnAddContact.btnAddRequest.layer.cornerRadius = 5.0;
    btnAddContact.btnAddRequest.titleLabel.textAlignment = NSTextAlignmentCenter;
    btnAddContact.btnAddRequest.layer.borderColor = COLOR_24317741.CGColor;
    btnAddContact.btnAddRequest.layer.borderWidth = 1;
    [self updateLabelCounter];
}

-(void) checkDiplayContactsData{
    [tblView reloadData];
    [tblView setContentOffset:CGPointMake(0, 0)];
    
    lblNoContacts.hidden = [array_Contact count] > 0;
    viewAddContact.hidden = self.searchBar.hidden = ![array_Contact count] > 0;
}

- (void) buildEmailContactsData
{
    indexTitles = @[@"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z", @" "];
    NSMutableArray *foundLetter = [[NSMutableArray alloc] init];
    // Hardcode for testing find email contact
    NSMutableArray *tempArray = [NSMutableArray new];
    for (int i = 0; i < emailContact.count; i ++)
    {
        Contact *contact = emailContact[i];
        if (contact.email.length > 0)
        {
            [tempArray addObject:contact];
        }
//  Add this for testing
//        else
//        {
//            contact.email = [NSString stringWithFormat:@"email[%d]",i];
//            [tempArray addObject:contact];
//        }
    }
    
    [emailContact removeAllObjects];
    emailContact = [tempArray mutableCopy];
    dictionary_Contact = [NSMutableDictionary new];
    [tempArray removeAllObjects];
    for (int i = 0; i < indexTitles.count; i++)
    {
        NSString *letter = @"";
        
        for (int j = 0; j < emailContact.count; j++)
        {
            Contact *contact = emailContact[j];
            
            if (contact.customerName.length > 0)
            {
                letter = [[contact.customerName substringToIndex:1] uppercaseString];
            }
            else if (contact.phonebookName.length > 0)
            {
                letter = [[contact.phonebookName substringToIndex:1] uppercaseString];
            }
            else if (contact.serversideName.length > 0)
            {
                letter = [[contact.serversideName substringToIndex:1] uppercaseString];
            }
            else
            {
                letter = [[contact.maskingid substringToIndex:1] uppercaseString];
            }
            
            if ([letter isEqualToString:indexTitles[i]])
            {
                // add to array contact
                [tempArray addObject:contact];
                
                if (![foundLetter containsObject:letter])
                {
                    [foundLetter addObject:letter];
                }
            }
            else if ((![letter isEqualToString:@""]) && ([indexTitles[i] isEqualToString:@" "]))
            {
                // add to array contact
                if (![foundLetter containsObject:letter])
                {
                    [tempArray addObject:contact];
                }
            }
            
            if (contact.contactState.intValue == 2)
            {
                [tempArray removeObject:contact];
            }
        }
        // add array contact with key
        if (tempArray.count > 0)
        {
            [dictionary_Contact setObject:[tempArray copy] forKey:indexTitles[i]];
            [tempArray removeAllObjects];
        }
    }
    sectionTitles = [dictionary_Contact allKeys];
    
    [tblView reloadData];
    [tblView setContentOffset:CGPointMake(0, 0)];
    
    lblNoContacts.hidden = self.navigationItem.rightBarButtonItem.enabled = [emailContact count] > 0;
    viewAddContact.hidden = self.searchBar.hidden = ![emailContact count] > 0;
}

- (void)reloadEmailContactList:(NSArray *)contactArray
{
    NSMutableArray *arrTmp = [contactArray mutableCopy];
    
    NSMutableArray *discardedItems = [NSMutableArray array];

    for(Contact *item in [contactArray mutableCopy])
    {
        for (Contact *iContact in [ContactInfo share].arrMemberContacts)
        {
            if ([iContact.jid isEqualToString:item.jid])
            {
                [discardedItems addObject:item];
                break;
            }
        }
    }
    
    [arrTmp removeObjectsInArray:discardedItems];

    if (![array_Contact isEqualToArray:arrTmp])
    {
        array_Contact = [arrTmp mutableCopy];
        emailContact = [array_Contact mutableCopy];
        if (isAddParticipants)
            [self checkDiplayContactsData];
        else
            [self buildEmailContactsData];
    }
    else
    {
        NSLog(@"CONTACT LIST ALREADY UPDATED");
    }
}

- (BOOL) checkContainContact:(Contact *)user isAddParticipant:(BOOL)isAdd
{
    BOOL isExist = NO;
    if (isAdd)
    {
        for (Contact *contact in [[ContactInfo share].arrAddingMembers copy])
        {
            if ([contact.maskingid isEqualToString:user.maskingid])
            {
                isExist = YES;
                [[ContactInfo share].arrAddingMembers removeObject:contact];
            }
        }
    }
    else
    {
        for (Contact *contact in [arrayContactSelect copy])
        {
            if ([contact.maskingid isEqualToString:user.maskingid])
            {
                isExist = YES;
                [arrayContactSelect removeObject:contact];
            }
        }
    }
    
    return isExist;
}

#pragma mark - Button Action
- (void) clickBtnCheck:(id)sender
{
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:tblView];
    NSIndexPath *indexPath = [tblView indexPathForRowAtPoint:buttonPosition];
    FindContactCell *cell = (FindContactCell *)[self.tblView cellForRowAtIndexPath:indexPath];
    if (!isAddParticipants)
    {
        NSString *sectionTitle = [sectionTitles objectAtIndex:indexPath.section];
        NSArray *sectionContact = [dictionary_Contact objectForKey:sectionTitle];
        
        Contact *contact = [Contact new];
        
        if (isSearch)
        {
            contact = [searchResults objectAtIndex:indexPath.row];
        }
        else
        {
            contact = [sectionContact objectAtIndex:indexPath.row];
        }
        
        if ([arrayContactSelect containsObject:contact])
        {
            [arrayContactSelect removeObject:contact];
        }
        else
        {
            [arrayContactSelect addObject:contact];
        }
        
        if ([arrayContactSelect containsObject:contact])
        {
            [cell.contactCheck setImage:[UIImage imageNamed:IMG_C_B_TICK] forState:UIControlStateNormal];
            cell.contactCheck.layer.borderColor = COLOR_148148148.CGColor;
        }
        else
        {
            [cell.contactCheck setImage:nil forState:UIControlStateNormal];
            cell.contactCheck.layer.borderColor = COLOR_128128128.CGColor;
        }
        //add object
        self.lblNumber.text = [NSString stringWithFormat:@"%ld", (unsigned long)arrayContactSelect.count];
        return;
    }
}
- (void)backToCompose
{
    isSearch = NO;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)closeButtonClicked
{
    isSearch = NO;
    [self dismissViewControllerAnimated:YES completion:nil];
}



- (IBAction)clickedBtnSelectAll:(id)sender
{
    if (isSelectAll)
    {
        isSelectAll = NO;
        [arrayContactSelect removeAllObjects];
        self.lblNumber.text = [NSString stringWithFormat:@"%ld", (unsigned long)arrayContactSelect.count];
        self.navigationItem.rightBarButtonItem=[UIBarButtonItem createRightButtonTitle:_SELECT_ALL
                                                                                Target:self
                                                                                Action:@selector(clickedBtnSelectAll:)];
    }
    else
    {
        isSelectAll = YES;
        arrayContactSelect = [emailContact mutableCopy];
        self.lblNumber.text = [NSString stringWithFormat:@"%ld", (unsigned long)arrayContactSelect.count];
        self.navigationItem.rightBarButtonItem=[UIBarButtonItem createRightButtonTitle:_UNSELECT_ALL
                                                                                Target:self
                                                                                Action:@selector(clickedBtnSelectAll:)];
    }
    [self updateLabelCounter];
    [self.tblView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView Datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)_tableView
{
    if (self.searchBar.text.length > 0)
    {
        return 1;
    }
    else
    {
        if (isAddParticipants)
        {
            return 1;
        }
        else
        {
            return sectionTitles.count;
        }
    }
}

- (NSInteger)tableView:(UITableView *)_tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.searchBar.text.length > 0)
    {
        return [searchResults count];
    }
    else
    {
        if (isAddParticipants)
        {
            return [array_Contact count];
        }
        else
        {
            NSString *sectionTitle = [sectionTitles objectAtIndex:section];
            NSArray *sectionContact = [dictionary_Contact objectForKey:sectionTitle];
            return [sectionContact count];
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)contactTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"FindContactCell";
    FindContactCell *cell = (FindContactCell *)[contactTableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];

    if (!cell)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"FindContactCell" owner:nil options:nil];
        cell = (FindContactCell *)[nib objectAtIndex:0];
    }

    Contact *user = [Contact new];

    if (isAddParticipants)
    {
        if (self.searchBar.text.length > 0)
        {
            user = [searchResults objectAtIndex:indexPath.row];
        }
        else
        {
            user = [array_Contact objectAtIndex:indexPath.row];
        }

        [cell displayCell:user];

        if ([[ContactInfo share].arrAddingMembers containsObject:user])
        {
            [cell.contactCheck setImage:[UIImage imageNamed:IMG_C_B_TICK] forState:UIControlStateNormal];
            cell.contactCheck.layer.borderColor = COLOR_148148148.CGColor;
        }
        else
        {
            [cell.contactCheck setImage:nil forState:UIControlStateNormal];
            cell.contactCheck.layer.borderColor = COLOR_128128128.CGColor;
        }
    }
    else
    {
        if (self.searchBar.text.length > 0)
        {
            user = [searchResults objectAtIndex:indexPath.row];
        }
        else
        {
            NSString *sectionTitle = [sectionTitles objectAtIndex:indexPath.section];
            NSArray *sectionContact = [dictionary_Contact objectForKey:sectionTitle];

            user = [sectionContact objectAtIndex:indexPath.row];
        }

        [cell displayCell:user];

        if ([arrayContactSelect containsObject:user])
        {
            [cell.contactCheck setImage:[UIImage imageNamed:IMG_C_B_TICK] forState:UIControlStateNormal];
            cell.contactCheck.layer.borderColor = COLOR_148148148.CGColor;
        }
        else
        {
            [cell.contactCheck setImage:nil forState:UIControlStateNormal];
            cell.contactCheck.layer.borderColor = COLOR_128128128.CGColor;
        }

        [cell.contactCheck addTarget:self
                              action:@selector(clickBtnCheck:)
                    forControlEvents:UIControlEventTouchUpInside];
    }

    return cell;
}

#pragma mark - UITableView Delegate
- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FindContactCell *cell = (FindContactCell *)[self.tblView cellForRowAtIndexPath:indexPath];
    Contact *user = nil;
    
    if (isAddParticipants)
    {
        if (self.searchBar.text.length > 0)
            user = [searchResults objectAtIndex:indexPath.row];
        else
            user = [array_Contact objectAtIndex:indexPath.row];
        
        if ([self checkContainContact:user isAddParticipant:isAddParticipants])
        {
            [cell.contactCheck setImage:nil forState:UIControlStateNormal];
            cell.contactCheck.layer.borderColor = COLOR_128128128.CGColor;
        }
        else
        {
            [[ContactInfo share].arrAddingMembers addObject:user];
            [cell.contactCheck setImage:[UIImage imageNamed:IMG_C_B_TICK] forState:UIControlStateNormal];
            cell.contactCheck.layer.borderColor = COLOR_148148148.CGColor;
        }
        
        [self updateLabelCounter];
        return;
    }
    else
    {
        if (self.searchBar.text.length > 0)
        {
            user = [searchResults objectAtIndex:indexPath.row];
        }
        else
        {
            NSString *sectionTitle = [sectionTitles objectAtIndex:indexPath.section];
            NSArray *sectionContact = [dictionary_Contact objectForKey:sectionTitle];

            user = [sectionContact objectAtIndex:indexPath.row];
        }
        if ([self checkContainContact:user isAddParticipant:isAddParticipants])
        {
            [cell.contactCheck setImage:nil forState:UIControlStateNormal];
            cell.contactCheck.layer.borderColor = COLOR_128128128.CGColor;
        }
        else
        {
            [arrayContactSelect addObject:user];
            [cell.contactCheck setImage:[UIImage imageNamed:IMG_C_B_TICK] forState:UIControlStateNormal];
            cell.contactCheck.layer.borderColor = COLOR_148148148.CGColor;
        }
        
        //add object
        [self updateLabelCounter];
        return;
    }
}

-(void) tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.tblView cellForRowAtIndexPath:indexPath].backgroundColor = COLOR_247247247;
}
-(void) tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.tblView cellForRowAtIndexPath:indexPath].backgroundColor = [UIColor clearColor];
}

-(void) tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.tblView cellForRowAtIndexPath:indexPath].backgroundColor = [UIColor clearColor];
}


#pragma mark - UISearchBarDelegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self.view endEditing:YES];
}
- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar{
    isSearch = NO;
    self.searchBar.text = @"";
    [searchBar setShowsCancelButton:NO];
    [self.view endEditing:YES];
    [[ContactFacade share] searchEmailFriendName:self.searchBar.text
                                     friendArray:emailContact
                                isAddParticipant:isAddParticipants];
    [self.tblView reloadData];
    [self updateLabelCounter];
}


- (NSString *)tableView:(UITableView *)_tableView titleForHeaderInSection:(NSInteger)section
{
    if (self.searchBar.text.length > 0)
    {
        return SELECT_CONTACT;
    }
    else if(isAddParticipants){
        return @"";
    }else{
        if (sectionTitles.count > section)
            return [sectionTitles objectAtIndex:section];
        else
            return @"";
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 69;
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    isSearch = YES;
    [searchBar setShowsCancelButton:YES];
    self.btnAddContact.hidden = YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    // emailContact is for find email contact, if you work with search contact please user array_contact
    [[ContactFacade share] searchEmailFriendName:searchText
                                     friendArray:emailContact
                                isAddParticipant:isAddParticipants];
}

- (void) searchResult:(NSArray *)searchResult
{
    searchResults = [searchResult mutableCopy];
    [tblView reloadData];
}
// search
-(void)searchBuddyName{
    //[array_Contact removeAllObjects];
    NSString *searchText = self.searchBar.text;
    BOOL isEmptyText = [searchText isEqualToString:@""] || [searchText length] == 0 ;
    if(isEmptyText)
    {
        isSearch = NO;
        //array_Contact = [AllContact mutableCopy];
        if (!isAddParticipants)
        {
            [self buildEmailContactsData];
        }
        [tblView reloadData];
    }
    else
    {
        isSearch = YES;
        if ([self searchNameKeyword:searchText])
        {
            [tblView reloadData];
        }
    }
}

//check search text
- (BOOL)searchNameKeyword:(NSString*)searchText
{
    /* maskingid, serversideName, customerName */
    NSArray *search = [emailContact filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"serversideName contains [c] %@ || customerName contains [c] %@ || phonebookName contains [c] %@ || maskingid contains [c] %@ ", searchText,searchText,searchText,searchText]];
    searchResults = [search mutableCopy];
    
    if(search.count > 0)
        return YES;
    else
        return NO;
}

- (IBAction)clickedBtnAddContact:(id)sender
{
    if (isAddParticipants)
    {
        [[ContactInfo share] addParticipant];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else
    {
        [[EmailFacade share] addReceipientIntoTextFieldWithData:arrayContactSelect];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

-(void)updateLabelCounter
{
    if(isSearch)
        return;
    
    NSInteger Addcounter;
    if (isAddParticipants)
        Addcounter = [ContactInfo share].arrAddingMembers.count;
    else
       Addcounter = arrayContactSelect.count;
    [btnAddContact setButtonTitle:[NSString stringWithFormat:_ADD_SELECTED, Addcounter]];
    btnAddContact.hidden = !(Addcounter > 0);
    
}


@end
