//
//  ContactList.m
//  Satay
//
//  Created by TrungVN on 1/15/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import "ContactList.h"
#import "CWindow.h"
#import "ContactEdit.h"

@interface ContactList ()

@end

@implementation ContactList

@synthesize tblContact;
@synthesize notification;
@synthesize header;
@synthesize arrContact;
@synthesize canDelete;
@synthesize arrDeleteContacts;
@synthesize lblNoContacts;
@synthesize lbNoUserFound;

+(ContactList *)share{
    static dispatch_once_t once;
    static ContactList * share;
    dispatch_once(&once, ^{
        share = [self new];
    });
    return share;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    tblContact.tableHeaderView = header;
    self.title = TITLE_CONTACTS;
    arrContact = [NSMutableArray new];
    arrDeleteContacts = [NSMutableArray new];
    
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem createRightButtonTitle:_ADD Target:self Action:@selector(addFriend)];
    [ContactFacade share].contactListDelegate = self;
    [ContactFacade share].contactEditDelegate = self;
    [SIPFacade share].contactListDelegate = self;
    [self.view addSubview:notification];
    self.btnTapToAdd.layer.cornerRadius = 3.0;
    self.btnTapToAdd.layer.borderWidth = 1.0;
    self.btnTapToAdd.layer.borderColor = [UIColor blackColor].CGColor;
    
    [self.btnTapToAdd setBackgroundImage:[UIImage imageFromColor:[UIColor blackColor]] forState:UIControlStateHighlighted];
    
    [self checkDisplayWhenNoContacts];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.lblNoContacts changeXAxis:self.lblNoContacts.x
                              YAxis:self.btnTapToAdd.y - lblNoContacts.height - 5];
    
    [[ContactFacade share] loadContactRequest];
    [[ContactFacade share] loadFriendArray];
    canDelete = NO;//This one to handle allow edit row. Only accept in ContactEdit
    [self checkDisplayWhenNoContacts];
    [[LogFacade share] trackingScreen:Contact_Category];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [header.searchBar setText:@""];
}

-(void) addFriend{
    if (![[ContactFacade share] getSyncContactFlag])
        [self.navigationController pushViewController:[ContactNotSync share] animated:YES];
    else {
        if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusDenied){
            [self.navigationController pushViewController:[ContactNotSync share] animated:YES];
        }
        else{
            [self.navigationController pushViewController:[ContactBook share] animated:YES];
        }
    }
}

-(void) reloadContactList:(NSArray *)contactArray{
    if ([ContactEdit share].navigationController)
        return;
    
    if (![arrContact isEqual:contactArray]) {
        arrContact = [contactArray mutableCopy];
        [tblContact reloadData];
        [self checkDisplayWhenNoContacts];
    }
}
- (IBAction)tapToAdd:(id)sender {
    [self addFriend];
}

-(void) reloadSearchContactList:(NSArray*) contactArray{
    if (![arrContact isEqualToArray:contactArray]) {
        arrContact = [contactArray mutableCopy];
        [tblContact reloadData];
    }
}

-(void)checkDisplayWhenNoContacts{
    // return if Edit contact page is showing
    if([ContactEdit share].navigationController)
        return;
    
    // return if is searching contact
    if([ContactList share].navigationController.navigationBarHidden)
        return;
    
    self.lbNoUserFound.hidden = YES;
    if (arrContact.count > 0) {
        self.btnTapToAdd.hidden = self.lblNoContacts.hidden = YES;
        [self.header showSearchBar];
    }else{
        self.btnTapToAdd.hidden = self.lblNoContacts.hidden = NO;
        [self.view bringSubviewToFront:self.btnTapToAdd];
        [self.header hideSearchBar];
    }
}

-(void)callChangeState
{
    [header fixView];
}

////////////////////////////////////////////////////////////////////////////////////
#pragma mark UITableView
////////////////////////////////////////////////////////////////////////////////////
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex{
    return [arrContact count];
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    [[tableView cellForRowAtIndexPath:indexPath] setSelected:TRUE];
    tableView.userInteractionEnabled = NO;
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        tableView.userInteractionEnabled = YES;
        if ([arrContact count] > indexPath.row){//defense crash
            [ContactPopup share].userJid = ((Contact*)[arrContact objectAtIndex:indexPath.row]).jid;
            [[CWindow share] showPopup:[ContactPopup share]];
        }
    }];
}

-(void) tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    [[tableView cellForRowAtIndexPath:indexPath] setSelected:FALSE];
}
-(void) tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    [[tableView cellForRowAtIndexPath:indexPath] setHighlighted:TRUE];
}
-(void) tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    [[tableView cellForRowAtIndexPath:indexPath] setHighlighted:FALSE];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellID =  @"ContactCell";
    ContactCell *cell = [tblContact dequeueReusableCellWithIdentifier:cellID];
    
    if(!cell){
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:cellID owner:nil options:nil];
        cell = (ContactCell*)[nib objectAtIndex:0];
    }
    
    if ([arrContact count] > indexPath.row) {
        Contact* contact = [arrContact objectAtIndex:indexPath.row];
        cell.lblBuddyName.text = [[ContactFacade share] getContactName:contact.jid];
        
        NSString* contactState = @"";
        switch ([contact.contactState integerValue]) {
            case kCONTACT_STATE_ONLINE: contactState = _ONLINE; break;
            case kCONTACT_STATE_OFFLINE: contactState = _OFFLINE; break;
            case kCONTACT_STATE_BLOCKED: contactState = _BLOCKED; break;
        }
        cell.lblStatus.text = contact.statusMsg.length > 0 ? contact.statusMsg : DEFAULT_STATUS_AVAILABLE;
        cell.lblStatus.text = [contactState isEqualToString:_BLOCKED] ? _BLOCKED: cell.lblStatus.text;
        cell.imgAvatar.image = [[ContactFacade share] updateContactAvatar:contact.avatarURL];
    }
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if(canDelete) //if edit mode then can delete, else can't swipe to delete
        return YES;
    else
        return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        if ([[ContactFacade share] isAccountRemoved]) {
            [[CAlertView new] showError:ERROR_ACCOUNT_REMOVED];
            return;
        }
        
        if (![[NotificationFacade share] isInternetConnected]){
            [[CAlertView new] showError:NO_INTERNET_CONNECTION_TRY_LATER];
            return;
        }
        
        // delete user in buddys list
        CAlertView *alert = [CAlertView new];
        Contact* contact = [arrContact objectAtIndex:indexPath.row];
        
        [alert showWarning:[[NSString alloc] initWithFormat:NSLocalizedString(WARNING_ARE_YOU_SURE_DELETE_CONTACT,nil), [[ContactFacade share] getContactName:contact.jid]] TARGET:self ACTION:NULL];
        
        [alert setOnButtonTouchUpInside:^(CAlertView *alertView, int buttonIndex)
         {
             if(buttonIndex == 0)
             {
                 [arrDeleteContacts addObject:contact];
                 
                 // if user is in edit contact page, then do nothing, only remove in UI
                 // because user can press Cancel.
                 if (tblContact.tableHeaderView != NULL)
                     [[ContactEdit share] deleteFriend];
                 
                 [self deleteChatBoxRow:tableView forIndex:indexPath];
             }
         }];
    }
}

- (void)deleteChatBoxRow:(UITableView *)tableView forIndex:(NSIndexPath *)indexPath
{
    
    [arrContact removeObjectAtIndex:indexPath.row];
    
    [tableView beginUpdates];
    [tableView deleteRowsAtIndexPaths:@[indexPath]
                     withRowAnimation:UITableViewRowAnimationFade];
    [tableView endUpdates];
}

-(void) deleteFriendSuccess{

    [[ContactEdit share] cancelView];
    
    [tblContact reloadData];
    [self checkDisplayWhenNoContacts];
}
-(void) deleteFriendFailed{
    
    [[ContactEdit share] cancelView];
    
    [tblContact reloadData];
    [self checkDisplayWhenNoContacts];
}

@end
