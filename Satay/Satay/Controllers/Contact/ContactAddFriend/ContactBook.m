//
//  ContactListViewController.m
//  JuzChatV2
//
//  Created by Kerjin on 30/10/12.
//  Copyright (c) 2012 mTouche. All rights reserved.
//

#import "ContactBook.h"

@interface ContactBook ()
{
    
    NSMutableDictionary *allContactsPhoneBook;//for displaying
    NSMutableArray *normalContactsPhoneBook;
    NSMutableArray *symbolicContactsPhoneBook;
    NSMutableArray *contactKryptoMember;
    
    NSMutableArray *addFriendsKryptoMember;//For adding
    NSMutableArray *addFriendsPhoneBook;
    NSMutableDictionary *addFriendsPhoneBookDetail; //For request item updating
    
    NSMutableArray *normalContactsPhoneBookStore;//For searching
    NSMutableArray *symbolicContactsPhoneBookStore;
    NSMutableArray *contactKryptoMemberStore;
    
    NSMutableArray *contactKryptoMemberSentSuccess;
    int requestSentCounter;
    
    NSMutableArray *toDelete;
    
    BOOL selectAll;
    BOOL isComposeTextViewPresent;
    int Addcounter;
    int sendFriendRequestCounter;
    UIActivityIndicatorView * loadingview;
}

@end

@implementation ContactBook;

@synthesize tblPhoneBook,tblMemberPhoneBook,headerTBLContact, addFriendCounter, headerContactView, addFriendview;
@synthesize lblNoUserFound,lblNoContacts;


-(void)viewDidLoad
{
    
    [super viewDidLoad];
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
    
    normalContactsPhoneBook = [[NSMutableArray alloc] init];
    contactKryptoMember = [[NSMutableArray alloc] init];
    symbolicContactsPhoneBook =[[NSMutableArray alloc] init];
    
    normalContactsPhoneBookStore = [[NSMutableArray alloc] init];
    contactKryptoMemberStore = [[NSMutableArray alloc] init];
    symbolicContactsPhoneBookStore =[[NSMutableArray alloc] init];
    
    addFriendsPhoneBook = [[NSMutableArray alloc] init];
    addFriendsKryptoMember = [[NSMutableArray alloc] init];
    
    addFriendsPhoneBookDetail = [[NSMutableDictionary alloc] init];
    
    contactKryptoMemberSentSuccess = [[NSMutableArray alloc] init];
    
    [self.view addSubview:addFriendCounter];
    addFriendCounter.hidden = YES;
    
    [addFriendCounter changeXAxis:0 YAxis:(addFriendCounter.superview.height - addFriendCounter.height)];
    addFriendCounter.tag = 2;
    [self.view bringSubviewToFront:addFriendCounter];
    [addFriendCounter.btnAddRequest addTarget:self action:@selector(sendAddFriendRequest) forControlEvents:UIControlEventTouchUpInside];
    
    tblMemberPhoneBook.tableHeaderView = addFriendview;
    tblPhoneBook.scrollEnabled = tblMemberPhoneBook.scrollEnabled = NO;

    Addcounter = 0;
    
    //Hide no contacts lable
    lblNoContacts.hidden = YES;
    [headerTBLContact.searchBar setBackgroundImage:[UIImage imageFromColor:COLOR_230230230]];
    
    [ContactFacade share].contactBookDelegate = self;
    [SIPFacade share].contactBookDelegate = self;
    
    //Re sync contact
    if (self.navigationController.viewControllers.count > 0 &&
        [self.navigationController.viewControllers[self.navigationController.viewControllers.count -2] isKindOfClass:[ContactList class]] )
        [[ContactFacade share] syncContactsWithServer];
    

}

-(void) moveToSearchMaskingID{
    [self.navigationController pushViewController:[ContactSearchMID share] animated:TRUE];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.scrollview scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
    
    // Hide 2 table while loading
    tblMemberPhoneBook.hidden = YES;
    tblPhoneBook.hidden = YES;
    
    self.navigationItem.title = TITLE_ADD_FRIENDS;
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem createLeftButtonTitle:_BACK Target:self Action:@selector(backView)];
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem createRightButtonTitle:_SELECT_ALL Target:self Action:@selector(selectAll)];
    
    [[CWindow share] showLoading:kLOADING_LOADING];
    
    NSOperationQueue *reloadContactBook = [[NSOperationQueue alloc] init];
    NSOperationQueue *mainQueue = [NSOperationQueue mainQueue];
    [reloadContactBook addOperationWithBlock:^{
        [addFriendsPhoneBook removeAllObjects];
        [addFriendsPhoneBookDetail removeAllObjects];
        [addFriendsKryptoMember removeAllObjects];
        [normalContactsPhoneBook removeAllObjects];
        [symbolicContactsPhoneBook removeAllObjects];
        [contactKryptoMemberSentSuccess removeAllObjects];
        
        [self getDataForDisplaying];
        normalContactsPhoneBookStore = normalContactsPhoneBook;
        symbolicContactsPhoneBookStore = symbolicContactsPhoneBook;
        contactKryptoMemberStore = contactKryptoMember;
        
        [mainQueue addOperationWithBlock:^{
            // Show 2 table while done loading
            tblMemberPhoneBook.hidden = NO;
            tblPhoneBook.hidden = NO;
            headerTBLContact.hidden = NO;
            
            lblNoUserFound.hidden = YES;
            
            if (normalContactsPhoneBook.count == 0 &&
                contactKryptoMember.count == 0 &&
                symbolicContactsPhoneBook.count == 0){
                lblNoContacts.hidden = NO;
            }
            
            [self selectMemberContact];
            [tblPhoneBook reloadData];
            
            [self fixTableDisplay];
            [self updateSelectAllButton];
            [[CWindow share] hideLoading];
        }];
    }];
}

-(void)getDataForDisplaying{
    contactKryptoMember =  [[[ContactFacade share] getAllKryptoMembers] mutableCopy];
    contactKryptoMember = [self sortKryptoMember:contactKryptoMember];

    normalContactsPhoneBook = [[[ContactFacade share] getContactsAddressBook] mutableCopy];
    symbolicContactsPhoneBook = [[[ContactFacade share] getSymbolicContactsAddressBook] mutableCopy];
    allContactsPhoneBook = [[[ContactFacade share] getAllContactsInAddressBook] mutableCopy];
    allContactsPhoneBook = [self sortContactPhoneBook:allContactsPhoneBook];
}

-(NSMutableArray*)sortKryptoMember:(NSMutableArray*)kryptoMembers{
    //Sort alphabet
    NSArray *tempContactKryptoMember = [kryptoMembers copy];
    if (kryptoMembers.count > 0) {
        kryptoMembers = [[tempContactKryptoMember sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2){
            Contact *contact1 = (Contact*) obj1;
            Contact *contact2 = (Contact*) obj2;
            
            NSString *contactName1 = [[ContactFacade share] getContactName:contact1.jid];
            NSString *contactName2 = [[ContactFacade share] getContactName:contact2.jid];
            
            return [contactName1 compare:contactName2];
        }] mutableCopy];
    }
    return kryptoMembers;
}

-(NSMutableDictionary*)sortContactPhoneBook:(NSMutableDictionary*)contactPhoneBooks{
    
    NSMutableDictionary *resultDic = [[NSMutableDictionary alloc] init];
    NSArray *sectionPhoneBook = [[contactPhoneBooks allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    for (int i = 0; i < sectionPhoneBook.count; i++) {
         NSArray *phoneBooksInSection = [contactPhoneBooks valueForKey:sectionPhoneBook[i]];
        phoneBooksInSection = [phoneBooksInSection sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2){
            NSDictionary  *phoneBook1 = (NSDictionary*) obj1;
            NSDictionary  *phoneBook2 = (NSDictionary*) obj2;
            
            NSString *phoneBookName1 = [phoneBook1 objectForKey:@"contactFirstLast"];
            NSString *phoneBookName2 = [phoneBook2 objectForKey:@"contactFirstLast"];
            
            return [phoneBookName1 compare:phoneBookName2];
        }];
        [resultDic setObject:phoneBooksInSection forKey:sectionPhoneBook[i]];
    }
    return resultDic;

}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [headerTBLContact.searchBar setText:@""];
}

- (void) selectMemberContact{
    [addFriendsKryptoMember removeAllObjects];
    for (Contact *contact in contactKryptoMember) {
        [addFriendsKryptoMember addObject:contact.jid];
    }
    
    [tblMemberPhoneBook reloadData];
    [self updateLabelCounter];
}

-(void) fixTableDisplay{
    [headerTBLContact changeWidth:headerTBLContact.width
                           Height:headerTBLContact.searchBar.height + (headerTBLContact.viewAddMaskingID.hidden ? 0:headerTBLContact.viewAddMaskingID.height)];
    
    tblMemberPhoneBook.hidden = (contactKryptoMember.count == 0);
    if (contactKryptoMember.count > 0)
        [tblMemberPhoneBook changeXAxis:0 YAxis:headerTBLContact.height];
    
    tblPhoneBook.hidden = (allContactsPhoneBook.count == 0);
    if (allContactsPhoneBook.count > 0)
        [tblPhoneBook changeXAxis:0 YAxis:headerTBLContact.height];

    if (allContactsPhoneBook.count > 0) {
        [tblPhoneBook changeXAxis:0
                            YAxis:(contactKryptoMember.count > 0 ? tblMemberPhoneBook.contentSize.height:0) +headerTBLContact.height];
        
        [tblPhoneBook changeWidth:tblPhoneBook.width Height:tblPhoneBook.contentSize.height];
    }
    
    [tblMemberPhoneBook changeWidth:tblMemberPhoneBook.width
                             Height:contactKryptoMember.count > 0 ? tblMemberPhoneBook.contentSize.height:0];

    //4. Resize content of scrollview >> make it scrollable
    [self.scrollview setContentSize:CGSizeMake(self.scrollview.width,
                                               tblPhoneBook.height + tblMemberPhoneBook.height +addFriendCounter.height+headerTBLContact.height)];
    
    BOOL isMAContactNameEmpty = (allContactsPhoneBook.count == 0);
    BOOL isMemberContactNameEmpty = (contactKryptoMember.count==0);
    if (isMAContactNameEmpty && isMemberContactNameEmpty) {
        lblNoUserFound.hidden = NO;
        lblNoContacts.hidden = YES;
    }
    else
        lblNoUserFound.hidden = YES;
    
}

-(void) backView{
    NSArray* navigationControl = self.navigationController.viewControllers;
    //push back to contact list if user pushed from ContactList
    if (navigationControl.count == 2 && [navigationControl[0] isKindOfClass:[ContactList class]]) {
        [[self navigationController] popViewControllerAnimated:YES];
        return;
    }
    
    // Show Sidebar if user pushed from signup view
    [[CWindow share] showApplication];
    [[CWindow share].menuController showLeftPanelAnimated:YES];
}

-(void)sendAddFriendRequest
{
    [[NSOperationQueue new] addOperationWithBlock:^(){
        [self sendFriendRequestToKryptoMembers];
    }];
    
    NSLog(@"addFriendsPhoneBook: %@", addFriendsPhoneBook);
    if (addFriendsPhoneBook.count > 0) {
        [self composeMessage:addFriendsPhoneBook];
    }
}

-(void) addKryptoFriendSuccess:(NSString *)friendJID{
    if(![self.navigationController.topViewController isEqual:self])
        return;
    requestSentCounter++;
    sendFriendRequestCounter++;
    [addFriendsKryptoMember removeObject:friendJID];
    if (sendFriendRequestCounter == (addFriendsKryptoMember.count + requestSentCounter)) {
        [self getDataForDisplaying];
        contactKryptoMemberStore = contactKryptoMember;
        [tblMemberPhoneBook reloadData];
        [self fixTableDisplay];
        [self updateLabelCounter];
        [[CWindow share] hideLoading];
        [self showPopUpSendMultiRequest];
    }
}

-(void) addKryptoFriendFailed:(NSString *)friendJID{
    if(![self.navigationController.topViewController isEqual:self])
        return;    
    sendFriendRequestCounter++;
    
    if (sendFriendRequestCounter == (addFriendsKryptoMember.count + requestSentCounter)) {
        [self getDataForDisplaying];
        contactKryptoMemberStore = contactKryptoMember;
        [tblMemberPhoneBook reloadData];
        [self fixTableDisplay];
        [self updateLabelCounter];
        [[CWindow share] hideLoading];
        [self showPopUpSendMultiRequest];
    }
}

-(void) updateContactInfoSuccess{
    if ([self.navigationController.topViewController isKindOfClass:[self class]]) {
        [tblMemberPhoneBook reloadData];
    }
}

-(void)showPopUpSendMultiRequest{

    if (isComposeTextViewPresent) {
        return;
    }
    
    if(requestSentCounter == 0) // all friend requests sent failed
        [[CAlertView new] showError:[NSString stringWithFormat:FAILED_TO_SEND_FRIEND_REQUEST_COUNTER ,requestSentCounter, sendFriendRequestCounter]];
    else // At least one friend request sent successfully
    {
        CAlertView* alertView = [CAlertView new];
        [alertView showInfo:[NSString stringWithFormat:SUCCESS_TO_SEND_FRIEND_REQUEST_COUNTER, requestSentCounter, sendFriendRequestCounter]];
        [alertView setOnButtonTouchUpInside:^(CAlertView *alertView, int buttonIndex) {
            [[CWindow share] showApplication];
            [[CWindow share].menuController showLeftPanelAnimated:YES];
        }];
    }
    
}

-(void)sendFriendRequestToKryptoMembers{
    NSLog(@"addFriendsKryptoMember: %@", addFriendsKryptoMember);
    if (addFriendsPhoneBook.count == 0)
    {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^(){
             [[CWindow share] showLoading:kLOADING_ADDING];
        }];
    }    
    requestSentCounter = 0;
    sendFriendRequestCounter = 0;
    for(NSString *Jid in addFriendsKryptoMember){
        if (Jid.length > 0)
            [[ContactFacade share] friendRequestWithContactJid:Jid requestType:REQUEST requestInfo:nil];
    }
}


-(void) composeMessage:(NSMutableArray*) phoneNumbers{
    
    MFMessageComposeViewController *controller = [MFMessageComposeViewController new];
    if([MFMessageComposeViewController canSendText])
    {   isComposeTextViewPresent = YES;
        controller.body = [NSString stringWithFormat:HI_YOU_MUST_TRY_THIS_APP,[[ContactFacade share] getMaskingId]];
        controller.recipients = [NSArray arrayWithArray:phoneNumbers];
        controller.messageComposeDelegate = self;
        [self presentViewController:controller animated:YES completion:nil];
    }
    else
    {
        NSLog(@"You device counldn't send SMS.");
    }
}

-(void) syncContactsSuccess{
    
    if(self.navigationController){
        [self getDataForDisplaying];
        [self selectNewKryptoMember];
        
        normalContactsPhoneBookStore = normalContactsPhoneBook;
        symbolicContactsPhoneBookStore = symbolicContactsPhoneBook;
        contactKryptoMemberStore = contactKryptoMember;
    }    
    [self updateLabelCounter];
    [tblPhoneBook reloadData];
    [tblMemberPhoneBook reloadData];
    [self fixTableDisplay];
    [self updateSelectAllButton];
    
}

-(void) selectNewKryptoMember{
    if (contactKryptoMember.count != contactKryptoMemberStore.count) {
        NSMutableArray *arrOldKryptoJID = [NSMutableArray new];
        
        // Get old krypto member.
        for (Contact *contactStore in contactKryptoMemberStore) {
            if (contactStore.jid)
                [arrOldKryptoJID addObject:contactStore.jid];
        }
        
        // Find new member after sync add to selected member.
        for (Contact *contact in contactKryptoMember) {
            if (![arrOldKryptoJID containsObject:contact.jid])
                [addFriendsKryptoMember addObject:contact.jid];
        }
    }
}

-(void) syncContactsFailed{
    NSLog(@"Sync Contact Fail");
}

// Dismiss keyboard when scroll.
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [headerTBLContact.searchBar resignFirstResponder];
}

-(void)callChangeState
{
    [headerTBLContact fixView];
}
#pragma mark MFMessageComposeViewControllerDelegate
////////////////////////////////////////////////////////////////////////////////////
-(void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result{
    
    switch (result) {
        case MessageComposeResultCancelled:{
            NSLog(@"Cancelled Compose Send Friend Request");
            /* BEGIN TESTING WITH FAKE PHONE NUMBER */
            /*
            NSString *recipients = @"";
            if ([controller.recipients count]>0)
                recipients = [controller.recipients componentsJoinedByString:@","];
             
            if ([recipients length] > 0)
                [[ContactFacade share] friendRequestWithContactJid:recipients requestType:SMS_REQUEST requestInfo:addFriendsPhoneBookDetail];
             */
            /* END TESTING WITH FAKE PHONE NUMBER */
        }
            break;
        case MessageComposeResultFailed:{  // - 2
            CAlertView* alertView = [CAlertView new];
            [alertView showError:SEND_SMS_FAILED];
            [alertView setOnButtonTouchUpInside:^(CAlertView *alertView, int buttonIndex) {
               
            }];

        }
            break;
        case MessageComposeResultSent: // - 1
        {
            CAlertView* alertView = [CAlertView new];
            [alertView showInfo:SEND_SMS_SUCCESS];
            NSString *recipients = @"";
            if ([controller.recipients count]>0) {
                recipients = [controller.recipients componentsJoinedByString:@","];
            }
            if ([recipients length] > 0) {
                    [[ContactFacade share] friendRequestWithContactJid:recipients requestType:SMS_REQUEST requestInfo:addFriendsPhoneBookDetail];
            }
        }
            break;
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:^(){
        isComposeTextViewPresent = NO;
    }];
}

-(void) selectAll{
    contactKryptoMember =  [[[ContactFacade share] getAllKryptoMembers] mutableCopy];
    [addFriendsKryptoMember removeAllObjects];
    [addFriendsPhoneBook removeAllObjects];
    if (selectAll == NO) { // Select all krypto and member phonebook.
        self.navigationItem.rightBarButtonItem = [UIBarButtonItem createRightButtonTitle:_UNSELECT_ALL
                                                                                  Target:self
                                                                                  Action:@selector(selectAll)];
        selectAll = YES;
        
        for (Contact  *kryptoMember in contactKryptoMember) {
            [addFriendsKryptoMember addObject:kryptoMember.jid];
        }
        
        for(NSDictionary *contactInfo in normalContactsPhoneBook)
        {
            NSString *mobile = [contactInfo objectForKey:@"mobile"];
            if (mobile)
            {
                if(![addFriendsPhoneBook containsObject:mobile])
                {
                    [addFriendsPhoneBook addObject:mobile];
                    [addFriendsPhoneBookDetail setObject:[contactInfo objectForKey:@"contactFirstLast"] forKey:mobile];
                }
            }
        }
        
        for(NSDictionary *contactInfo in symbolicContactsPhoneBook){
            NSString *mobile = [contactInfo objectForKey:@"mobile"];
            if(mobile){
                if(![addFriendsPhoneBook containsObject:mobile]){
                    [addFriendsPhoneBook addObject:mobile];
                    [addFriendsPhoneBookDetail setObject:[contactInfo objectForKey:@"contactFirstLast"] forKey:mobile];
                }
            }
        }

    }
    else{
        selectAll = NO;
        self.navigationItem.rightBarButtonItem = [UIBarButtonItem createRightButtonTitle:_SELECT_ALL
                                                                                  Target:self
                                                                                  Action:@selector(selectAll)];
    }
    
    [tblMemberPhoneBook reloadData];
    [tblPhoneBook reloadData];
    [self updateLabelCounter];
}

////////////////////////////////////////////////////////////////////////////////////
#pragma mark UITableView
////////////////////////////////////////////////////////////////////////////////////
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if([tableView isEqual:tblPhoneBook])
        return [[allContactsPhoneBook allKeys] count];
    else
        return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    if([tableView isEqual:tblMemberPhoneBook])
        return [contactKryptoMember count];
    
    else if([tableView isEqual:tblPhoneBook]){
        if(normalContactsPhoneBook.count > 0 || symbolicContactsPhoneBook.count > 0)
        {
            
            NSString* key = [[[allContactsPhoneBook allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] objectAtIndex:sectionIndex];
            NSArray* alphabetArray = [allContactsPhoneBook objectForKey:key];
            return [alphabetArray count];
        }
        else
            return 0;
    }
    else
        return 0;
   
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if ([tableView isEqual:tblMemberPhoneBook]) {
        return 0;
    }
    else
        return 20;
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *sectionTitle = [self tableView:tableView titleForHeaderInSection:section];
    if (sectionTitle == nil) {
        return nil;
    }
    
    
    // Create label with section title
    UILabel *label = [[UILabel alloc] init];
    label.frame = CGRectMake(9, 4, 300, 15);
    label.backgroundColor = [UIColor clearColor];
    //label.textColor = COLOR_148148148;
    label.shadowColor = [UIColor whiteColor];
    label.shadowOffset = CGSizeMake(0.0, 1.0);
    label.font = [UIFont boldSystemFontOfSize:14];
    label.text = sectionTitle;
    
    // Create header view and add label as a subview
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 20)];
    [view addSubview:label];
    //view.backgroundColor = COLOR_247247247;
     
    
    return view;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"ContactBookCell";
    
    ContactBookCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if(!cell){
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ContactBookCell" owner:self options:nil];
        cell = (ContactBookCell*)[nib objectAtIndex:0];
    }
    
    if([tableView isEqual:tblMemberPhoneBook]) // Krypto Member table
    {
        Contact  *contactInfo;
        if (contactKryptoMember.count > indexPath.row){
            contactInfo= [contactKryptoMember objectAtIndex:indexPath.row];
        }
        cell.lblName.text = [[ContactFacade share] getContactName:contactInfo.jid];
        
        cell.lblStatus.text = contactInfo.serverMSISDN;
        
        cell.imgAvatar.image = [[ContactFacade share] updateContactAvatar:contactInfo.avatarURL];
        
        if ([addFriendsKryptoMember containsObject:contactInfo.jid]) {
            cell.checkBox.image = [UIImage imageNamed:IMG_C_B_TICK];
        }
        else{
            cell.checkBox.image = [UIImage imageNamed:IMG_C_B_UNTICK];
        }
        
        cell.iconKrypto.hidden = NO;
        
    }
    else // PhoneBook table
    {
        
        cell.iconKrypto.hidden = YES;
        
        if(normalContactsPhoneBook.count>0 || symbolicContactsPhoneBook.count > 0){
            NSArray *phoneBooksInSection = [allContactsPhoneBook valueForKey:[[[allContactsPhoneBook allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] objectAtIndex:indexPath.section]];
             NSDictionary  *contactInfo= [phoneBooksInSection objectAtIndex:indexPath.row];
            NSString *member_mobile = [[contactInfo objectForKey:@"mobile"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

            cell.lblName.text = [contactInfo objectForKey:@"contactFirstLast"];
            cell.lblStatus.text = [contactInfo objectForKey:@"mobileDisplay"];
            
            if ([addFriendsPhoneBook containsObject:member_mobile]) {
                cell.checkBox.image = [UIImage imageNamed:IMG_C_B_TICK];
            }
            else{
                cell.checkBox.image = [UIImage imageNamed:IMG_C_B_UNTICK];
            }
            cell.imgAvatar.image = NULL;

        }
        else
        {
            cell.lblName.text = nil;
            cell.lblStatus.text = nil;
            cell.checkBox.image = nil;
            cell.imgAvatar.image = NULL;
        }
    }
    
    BOOL isLastRowInSection = (indexPath.row == [tableView numberOfRowsInSection:indexPath.section] -1);
    cell.separateView.hidden = isLastRowInSection;
    
    return cell;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    if([tableView isEqual:tblPhoneBook])
        if(normalContactsPhoneBook.count>0 || symbolicContactsPhoneBook.count > 0)
        {
            return [[[allContactsPhoneBook allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] objectAtIndex:section];
        }
        else
            return  nil;
    else
        return  nil;
}


- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    
    if([tableView isEqual:tblPhoneBook])
        if(normalContactsPhoneBook.count>0 || symbolicContactsPhoneBook.count > 0)
            return [[UILocalizedIndexedCollation currentCollation] sectionForSectionIndexTitleAtIndex:index];
        else
            return 0;
        else
            return  0;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ContactBookCell *cell = (ContactBookCell*)[tableView cellForRowAtIndexPath:indexPath];
    
    if ([tableView isEqual:tblMemberPhoneBook]) {
        Contact  *contactInfo = [contactKryptoMember objectAtIndex:indexPath.row];
        if ([addFriendsKryptoMember containsObject:contactInfo.jid]) { // unselect krypto member case
            [addFriendsKryptoMember removeObject:contactInfo.jid];
            cell.checkBox.image = [UIImage imageNamed:IMG_C_B_UNTICK];
        }
        else{ // select krypto member case
            [addFriendsKryptoMember addObject:contactInfo.jid];
            cell.checkBox.image = [UIImage imageNamed:IMG_C_B_TICK];
        }
    }
    else{
        NSDictionary  *contactInfo= [[allContactsPhoneBook valueForKey:[[[allContactsPhoneBook allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
        
        NSString *member_mobile = [[contactInfo objectForKey:@"mobile"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if ([addFriendsPhoneBook containsObject:member_mobile]) {// unselect phonebook contact case
            [addFriendsPhoneBook removeObject:member_mobile];
            [addFriendsPhoneBookDetail removeObjectForKey:member_mobile];
            cell.checkBox.image = [UIImage imageNamed:IMG_C_B_UNTICK];
        }
        else { //select phonebook contact case
            [addFriendsPhoneBook addObject:member_mobile];
            [addFriendsPhoneBookDetail setObject:[contactInfo objectForKey:@"contactFirstLast"] forKey:member_mobile];
            cell.checkBox.image = [UIImage imageNamed:IMG_C_B_TICK];
        }
    }
    int totalCount = (int)normalContactsPhoneBook.count + (int)contactKryptoMember.count + (int)symbolicContactsPhoneBook.count;
    int totalSelected = (int)addFriendsKryptoMember.count + (int)addFriendsPhoneBook.count;
    
    if (totalSelected == totalCount){
        selectAll = YES;
        self.navigationItem.rightBarButtonItem = [UIBarButtonItem createRightButtonTitle:_UNSELECT_ALL Target:self Action:@selector(selectAll)];
    }
    else{
        selectAll = NO;
        self.navigationItem.rightBarButtonItem = [UIBarButtonItem createRightButtonTitle:_SELECT_ALL Target:self Action:@selector(selectAll)];
    }
    
    [self updateLabelCounter];
}

-(void)updateLabelCounter
{
    if(headerTBLContact.isSearching)
        return;
    
    Addcounter = (int)[addFriendsKryptoMember count] + (int)[addFriendsPhoneBook count];
    
    [addFriendCounter setButtonTitle:[NSString stringWithFormat:_ADD_SELECTED, Addcounter]];
    
    addFriendCounter.hidden = !(Addcounter > 0);
    addFriendCounter.isAddButton = (Addcounter > 0);
}

-(void)updateSelectAllButton
{
    int totalCount = (int)normalContactsPhoneBook.count + (int)contactKryptoMember.count + (int)symbolicContactsPhoneBook.count;
    self.navigationItem.rightBarButtonItem.enabled = (totalCount > 0);
}


+(ContactBook *)share{
    static dispatch_once_t once;
    static ContactBook * share;
    dispatch_once(&once, ^{
        share = [self new];
    });
    return share;
}

-(void) reloadSearchContactPhoneBook:(NSMutableDictionary*) arrResultContactPhoneBook{
    if (![allContactsPhoneBook isEqualToDictionary:arrResultContactPhoneBook]) {
        allContactsPhoneBook = [arrResultContactPhoneBook mutableCopy];
        [tblPhoneBook reloadData];
        [[ContactBook share] fixTableWhenSearch];
        [[ContactBook share] fixTableDisplay];
    }
}

-(void) reloadSearchMemberContact:(NSArray*) arrResultMemberContact{
    if (![contactKryptoMember isEqualToArray:arrResultMemberContact]) {
        contactKryptoMember = [arrResultMemberContact mutableCopy];
        [tblMemberPhoneBook reloadData];
        [[ContactBook share] fixTableWhenSearch];
        [[ContactBook share] fixTableDisplay];
    }
}

-(void) fixTableWhenSearch{
    //2.CHANGE TABLE SIZE
    [tblPhoneBook changeWidth:tblPhoneBook.width Height:tblPhoneBook.contentSize.height+100];
    [tblMemberPhoneBook changeWidth:tblMemberPhoneBook.width Height:tblMemberPhoneBook.contentSize.height];
    
    //4. Resize content of scrollview >> make it scrollable
    [tblPhoneBook changeXAxis:tblPhoneBook.x YAxis:tblMemberPhoneBook.height];
    [self.scrollview setContentSize:CGSizeMake(self.scrollview.width, tblPhoneBook.height + tblMemberPhoneBook.height+ (addFriendCounter.height*4))];
}
-(void)displayLabelNoContact{
    if (contactKryptoMember.count == 0 && normalContactsPhoneBook.count == 0 && symbolicContactsPhoneBook.count == 0 ) {
        lblNoContacts.hidden = NO;
    }
}
-(void) fixsearchScrollView
{
    [self.scrollview setContentSize:CGSizeMake(self.scrollview.width, tblPhoneBook.height + tblMemberPhoneBook.height +(addFriendCounter.height*2))];
}

-(void) fixnormalScrollView
{
    [self.scrollview setContentSize:CGSizeMake(self.scrollview.width, tblPhoneBook.height + tblMemberPhoneBook.height)];
}

- (void) moveToNotSyncView
{
    [self.navigationController pushViewController:[ContactNotSync share] animated:YES];
}
@end
