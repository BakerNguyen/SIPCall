//
//  BlockUsersController.m
//  Satay
//
//  Created by Vi (Violet) T.T. DAO on 5/13/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import "BlockUsersController.h"
#import "BlockUsersCell.h"
#import "UnblockUsersList.h"

@interface BlockUsersController (){
    
}

@end

@implementation BlockUsersController

@synthesize tblBlockUsers;
@synthesize footerView;
@synthesize addNewView;
@synthesize arrBlockUser;

+(BlockUsersController*)share{
    static dispatch_once_t once;
    static BlockUsersController * share;
    dispatch_once(&once, ^{
        share = [self new];
    });
    return share;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [ContactFacade share].blockUsersDelegate = self;
    
    arrBlockUser = [NSMutableArray new];
    tblBlockUsers.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.title = TITLE_BLOCKED_USERS;
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem createRightButtonTitle:_CLOSE Target:self Action:@selector(closeView)];
    self.navigationItem.hidesBackButton = YES;
    [tblBlockUsers setTableFooterView:footerView];
    
    UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addBlock)];
    [addNewView addGestureRecognizer:tapGesture];
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) addUnblockUserToArray:(Contact*)contactItem{
    [arrBlockUser addObject:contactItem];
    [tblBlockUsers reloadData];
}
- (void) removeUnblockUserToArray:(Contact*)contactItem{
    for (Contact* item in arrBlockUser) {
        if ([item.jid isEqual:contactItem.jid]) {
            contactItem = item;
            break;
        }
    }
    [arrBlockUser removeObject:contactItem];
    [tblBlockUsers reloadData];
}

#pragma mark UITableDelegate/UITableDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return arrBlockUser.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellID = @"BlockUsersCell";
    
    BlockUsersCell *cell = (BlockUsersCell *)[tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:cellID owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    [ContactFacade share].blockUsersCellDelegate = cell;
    
    if(!arrBlockUser)
        return cell;

    Contact *contactItem = [Contact new];
    if(arrBlockUser.count > indexPath.row)
        contactItem = [arrBlockUser objectAtIndex:indexPath.row];
    
    if(!contactItem)
        return cell;
    
    cell.lblName.text = [[ContactFacade share] getContactName:contactItem.jid];
    cell.avatar.image = [[ContactFacade share] updateContactAvatar:contactItem.jid];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.fullJID = contactItem.jid;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

#pragma mark Interact UI

-(void) closeView{
    [self.navigationController popViewControllerAnimated:YES];
}

/*deprecated, we not block a list now.
- (void) updateBlockListToServer:(NSArray*)arrBlockUserList{
    NSString *blocklist = @"";
    // Update block user into server
    for (int i=0; i<[arrBlockUserList count]; i++) {
        //NSString *memberJID = [[[members objectAtIndex:i] componentsSeparatedByString:@"@"] objectAtIndex:0];
        //using full jid as param
        Contact *contact = [arrBlockUserList objectAtIndex:i];
        if ([blocklist length]>0) {
            blocklist = [blocklist stringByAppendingString:@","];
        }
        blocklist = [blocklist stringByAppendingString:contact.jid];
    }
    
    [[ContactFacade share] synchronizeBlockList:blocklist action:UPDATE];
}
 */

#pragma mark Support methods

-(void) reloadBlockList:(NSArray*) blockArr{
    if(![arrBlockUser isEqualToArray:blockArr]){
        [arrBlockUser removeAllObjects];
        arrBlockUser = [blockArr mutableCopy];
        [tblBlockUsers reloadData];
    }else{
        NSLog(@"BLOCK USERS LIST IS ALREADY UPDATED");
    }
    
}

-(void) addBlock{
    [[CWindow share] showPopup:[UnblockUsersList share]];
}

#pragma mark Synchronize block list
-(void) synchronizeBlockListSuccess{
    [[CWindow share] hideLoading];
   
    NSLog(@"SYNC BLOCK USERS TO SERVER SUCCESS");
}
-(void) synchronizeBlockListFailed{
    NSLog(@"synchronize Block List Failed");
    [[CWindow share] hideLoading];
    
    if (arrBlockUser.count > 0) {
        CAlertView *alert = [CAlertView new];
        [alert showError:ERROR_SERVER_GOT_PROBLEM];
        [alert setOnButtonTouchUpInside:^(CAlertView *alertView, int buttonIndex){
            [self.navigationController popViewControllerAnimated:YES];
        }];
    }
    else
        [self.navigationController popViewControllerAnimated:YES];
   }


@end
