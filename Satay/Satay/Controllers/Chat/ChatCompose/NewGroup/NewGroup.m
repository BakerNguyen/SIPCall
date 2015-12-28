//
//  NewGroup.m
//  KryptoChat
//
//  Created by TrungVN on 4/22/14.
//  Copyright (c) 2014 mTouche. All rights reserved.
//

#import "NewGroup.h"
#import "ChatCompose.h"
#import "Interface.h"
#import "NewGroupCell/NewGroupCell.h"

#define _MAX_USER_IN_GROUP 20

@interface NewGroup ()

@end

@implementation NewGroup

@synthesize navBar, lblCounter;
@synthesize arrGroupFriend;

+(NewGroup *)share{
    static dispatch_once_t once;
    static NewGroup * share;
    dispatch_once(&once, ^{
        share = [[self alloc] init];
    });
    return share;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.titleView = navBar;
    
    [_tblFriends reloadData];

    arrGroupFriend = [NSMutableArray new];
    [ContactFacade share].NewGroupViewDelegate = self;
}

-(void) viewWillAppear:(BOOL)animated{
    UIView *clearView = [[UIView alloc] initWithFrame:CGRectZero];
    [_tblFriends setTableFooterView:clearView];
    [_tblFriends reloadData];
    [self updateCounter];
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem createRightButtonTitle:_NEXT Target:self Action:@selector(nextCreateStep)];
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem createLeftButtonTitle:_BACK Target:self.navigationController Action:@selector(popViewControllerAnimated:)];
    self.searchContact.delegate = self;
    [self checkNextButton];
    [self.searchContact setText:@""];
   
}

-(void) viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [arrGroupFriend removeAllObjects];    
}

-(void) updateCounter{
    lblCounter.text = [NSString stringWithFormat:@"%d/%d",(int)[arrGroupFriend count] +1, _MAX_USER_IN_GROUP];
}

-(void) nextCreateStep{
    if ((arrGroupFriend.count + 1) > _MAX_USER_IN_GROUP) {
        [[CAlertView new] showError:_ALERT_CANT_CREATE_GROUP_CHAT_WITH_MORE_THAT_20_PARTICIAPANTS];
        return;
    }
    [NewGroupCreate share].groupAvatarBackup = NULL;
    NSMutableArray *arrGroupMember = [NSMutableArray new];
    for (NSString *jid in arrGroupFriend) {
        Contact *contact = [[ContactFacade share] getContact:jid];
        if (contact)
            [arrGroupMember addObject:contact];
    }
    [NewGroupCreate share].arrGroupFriend = [arrGroupMember mutableCopy];
    [[self navigationController] pushViewController:[NewGroupCreate share] animated:YES];
}

-(void)checkNextButton{
    if (arrGroupFriend.count>0) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }else{
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
}


- (void)reloadContactSearchList:(NSArray *)contactArray
{
    _arrContact = [contactArray mutableCopy];
    [_tblFriends reloadData];
}

#pragma mark UITableViewDataSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_arrContact count];
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellID =  @"NewGroupCell";
    NewGroupCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    if(!cell){
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:cellID owner:nil options:nil];
        cell = (NewGroupCell*)[nib objectAtIndex:0];
    }
    
    Contact* contact = [_arrContact objectAtIndex:indexPath.row];
    cell.lbName.text = [[ContactFacade share] getContactName:contact.jid];
    
    NSString* contactState = @"";
    switch ([contact.contactState integerValue]) {
        case kCONTACT_STATE_ONLINE: contactState = _ONLINE; break;
        case kCONTACT_STATE_OFFLINE: contactState = _OFFLINE; break;
        case kCONTACT_STATE_BLOCKED: contactState = _BLOCKED; break;
    }
    cell.lbStatus.text = contact.statusMsg.length > 0 ? contact.statusMsg : DEFAULT_STATUS_AVAILABLE;
    cell.lbStatus.text = [contactState isEqualToString:_BLOCKED] ? _BLOCKED: cell.lbStatus.text;
    
    cell.imgAvatar.image = [[ContactFacade share] updateContactAvatar:contact.avatarURL];
    
    if (![arrGroupFriend containsObject:contact.jid]) {
        cell.imgCheckBox.image = NULL;
        cell.imgCheckBox.layer.borderColor = COLOR_128128128.CGColor;
    } else {
        cell.imgCheckBox.image = [UIImage imageNamed:IMG_C_B_TICK];
        cell.imgCheckBox.layer.borderColor = COLOR_148148148.CGColor;
    }
    
    return cell;
}

#pragma mark UITableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NewGroupCell *cell = (NewGroupCell*)[tableView cellForRowAtIndexPath:indexPath];
    Contact* user = [_arrContact objectAtIndex:indexPath.row];
    
    if ([arrGroupFriend containsObject:user.jid]) {
        [arrGroupFriend removeObject:user.jid];
        cell.imgCheckBox.image = NULL;
        cell.imgCheckBox.layer.borderColor = COLOR_128128128.CGColor;
    } else {
        [arrGroupFriend addObject:user.jid];
        cell.imgCheckBox.image = [UIImage imageNamed:IMG_C_B_TICK];
        cell.imgCheckBox.layer.borderColor = COLOR_148148148.CGColor;
    }
    [self updateCounter];
    [self checkNextButton];
    return;
}

#pragma mark Search Bar
-(void) searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    [self searchBuddyName];
}

-(void) searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    [self startFriendSearch];
}
-(void) searchBarTextDidEndEditing:(UISearchBar *)searchBar{
    [self endFriendSearch];
}
-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    self.searchContact.text = @"";
    [self searchBuddyName];
    [self endFriendSearch];
}
-(void) searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [self.view endEditing:YES];
}

-(void)startFriendSearch{
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    self.navigationController.navigationBarHidden = YES;
    [_searchContact setShowsCancelButton:YES];
}

-(void)endFriendSearch{
    self.searchContact.text = @"";
    [_searchContact resignFirstResponder];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    self.navigationController.navigationBarHidden = NO;
    [_searchContact setShowsCancelButton:NO];
    [self.tblFriends reloadData];
}

// search
-(void)searchBuddyName{
    NSString *searchText = self.searchContact.text;
    [[ContactFacade share] searchContact:searchText];
}



@end
