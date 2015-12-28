//
//  UnblockUsersList.m
//  Satay
//
//  Created by Vi (Violet) T.T. DAO on 5/14/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import "UnblockUsersList.h"
#import "UnblockUserCell.h"

@interface UnblockUsersList ()

@end

@implementation UnblockUsersList

@synthesize arrUnblockUser;
@synthesize tblUnblockUser;
@synthesize searchBar;
@synthesize lblNoContact;

+(UnblockUsersList*)share{
    static dispatch_once_t once;
    static UnblockUsersList * share;
    dispatch_once(&once, ^{
        share = [self new];
    });
    return share;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [ContactFacade share].unblockUsersDelegate = self;
    searchBar.delegate = self;
    
    self.title = TITLE_SELECT_CONTACTS;
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem createRightButtonTitle:_CLOSE Target:self Action:@selector(closeView)];
    tblUnblockUser.separatorStyle = UITableViewCellSeparatorStyleNone;
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self resetview];
    [[ContactFacade share] loadFriendArray];
}

-(void) removeBlockedUser{
    NSMutableArray* arrayOfBlockuser = [[NSMutableArray alloc]init];
    for (Contact* item in [BlockUsersController share].arrBlockUser) {
        for (Contact* unblockContact in arrUnblockUser) {
            if ([unblockContact.jid isEqual:item.jid]) {
                [arrayOfBlockuser addObject:unblockContact];
            }
        }
    }
    [arrUnblockUser removeObjectsInArray:arrayOfBlockuser];
    [tblUnblockUser reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark UITableDelegate/UITableDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return arrUnblockUser.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellID = @"UnblockUserCell";
    
    UnblockUserCell *cell = (UnblockUserCell *)[tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:cellID owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    if(!arrUnblockUser)
        return cell;
    
    Contact *contactItem = [Contact new];
    if(arrUnblockUser.count > indexPath.row)
        contactItem = [arrUnblockUser objectAtIndex:indexPath.row];
    
    if(!contactItem)
        return cell;
    
    cell.lblName.text = [[ContactFacade share] getContactName:contactItem.jid];
    cell.avatar.image = [[ContactFacade share] updateContactAvatar:contactItem.jid];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([[ContactFacade share] isAccountRemoved]) {
        [[CAlertView new] showError:ERROR_ACCOUNT_REMOVED];
        return;
    }
    
    if (![[NotificationFacade share] isInternetConnected]){
        [[CAlertView new] showError:NO_INTERNET_CONNECTION_TRY_LATER];
        return;
    }
    
    Contact *currentContact = [Contact new];
    if(arrUnblockUser.count > indexPath.row){
        currentContact = [arrUnblockUser objectAtIndex:indexPath.row];
    }
     [[CWindow share] showLoading:kLOADING_LOADING];
    if(!currentContact)
        return;
    
    [[ContactFacade share] synchronizeBlockList:currentContact.jid action:kBLOCK_USERS];
}

#pragma mark SearchBar delegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    [[ContactFacade share] searchContact:searchText];
}

-(void) searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    [self startFriendSearch];
}

-(void) searchBarTextDidEndEditing:(UISearchBar *)searchBar{
    [self endFriendSearch];
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    self.searchBar.text = @"";
    [[ContactFacade share] searchContact:self.searchBar.text];
    [self endFriendSearch];
}

-(void) searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [self.view endEditing:YES];
}

-(void)startFriendSearch{
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    self.navigationController.navigationBarHidden = YES;
    [self.searchBar setShowsCancelButton:YES];
    [self.searchBar changeXAxis:0 YAxis:searchBar.y];
    [self.tblUnblockUser changeXAxis:0 YAxis:0];
}

-(void)endFriendSearch{
    self.searchBar.text = @"";
    [self.searchBar resignFirstResponder];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    self.navigationController.navigationBarHidden = NO;
    [self.searchBar setShowsCancelButton:NO];
    [self.tblUnblockUser reloadData];
    [self.searchBar changeXAxis:0 YAxis:searchBar.y];
    
}

#pragma mark Interact UI

-(void) closeView{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark Support methods

-(void) reloadUnblockList:(NSArray*) unblockArr{
    if (![arrUnblockUser isEqualToArray:unblockArr]) {
        arrUnblockUser = [unblockArr mutableCopy];
        [tblUnblockUser reloadData];
        [self checkDisplayWhenNoContact];
    }
    else{
        NSLog(@"UNBLOCK LIST ALREADY UPDATED");
    }
    
    [self removeBlockedUser];
}

-(void) checkDisplayWhenNoContact{
    if(arrUnblockUser.count == 0){
        tblUnblockUser.tableHeaderView = nil;
        lblNoContact.hidden = NO;
    }else{
        tblUnblockUser.tableHeaderView = searchBar;
        lblNoContact.hidden = YES;
    }
}
-(void) resetview{
    searchBar.text = @"";
}

-(void) reloadUnblockUserSearchList:(NSArray*) unblockArray{
    arrUnblockUser = [unblockArray mutableCopy];
    [tblUnblockUser reloadData];
}

-(void) synchronizeBlockListSuccess{
    [[CWindow share] hideLoading];
    [self endFriendSearch];
    [self closeView];
}

-(void) synchronizeBlockListFailed{
    [[CWindow share] hideLoading];
    CAlertView *alert = [CAlertView new];
    [alert showError:ERROR_SERVER_GOT_PROBLEM];
    [alert setOnButtonTouchUpInside:^(CAlertView *alertView, int buttonIndex){
        [self endFriendSearch];
        [self closeView];
    }];
}

@end

