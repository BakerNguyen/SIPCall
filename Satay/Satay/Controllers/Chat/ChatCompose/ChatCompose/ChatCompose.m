//
//  ComposeView.m
//  KryptoChat
//
//  Created by TrungVN on 4/22/14.
//  Copyright (c) 2014 mTouche. All rights reserved.
//

#import "ChatCompose.h"

#import "ComposeHeader.h"
#import "ChatComposeCell.h"
#import "NewGroup.h"

@interface ChatCompose ()

@end

@implementation ChatCompose

@synthesize tblContact, headerCompose;
@synthesize arrContact, isCreatingGroup,arrContactStore;

+(ChatCompose *)share{
    static dispatch_once_t once;
    static ChatCompose * share;
    dispatch_once(&once, ^{
        share = [[self alloc] init];
    });
    return share;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = TITLE_COMPOSE;
    [tblContact setTableHeaderView:headerCompose];
    
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem createRightButtonTitle:_CLOSE
                                                                              Target:self Action:@selector(closeView)];
    
    arrContact = [NSMutableArray new];
    [ContactFacade share].chatComposeDelegate = self;
    
}

-(void) viewWillAppear:(BOOL)animated{
    [[CWindow share] showLoading:kLOADING_LOADING];
    isCreatingGroup = NO;
    [super viewWillAppear:animated];
    
    [self.view addSubview:tblContact];
    [headerCompose showNewGroup];
    headerCompose.searchContact.text = @"";
    
    [[ContactFacade share] loadFriendArray];
    
    arrContactStore = [arrContact mutableCopy];
    
    [tblContact setContentOffset:CGPointMake(0, 0)];
    [SIPFacade share].chatComposeDelegate = self;
}
-(void)viewWillDisappear:(BOOL)animated
{
   // [headerCompose fixView];
    [SIPFacade share].chatComposeDelegate = nil;
    [super viewWillDisappear:animated];
}


- (void)reloadComposeList:(NSArray *)contactArray
{
    [[CWindow share] hideLoading];
    if (![arrContact isEqualToArray:contactArray]) {
        arrContact = [contactArray mutableCopy];
        arrContactStore = [arrContact mutableCopy];
        [tblContact reloadData];
    }
    else{
        NSLog(@"CONTACT LIST ALREADY UPDATED");
    }
}

-(void)reloadComposeSearchList:(NSArray *)contactArray
{
    arrContact = [contactArray mutableCopy];
    [tblContact reloadData];
}



-(void) closeView{
    [self dismissViewControllerAnimated:TRUE completion:nil];
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [arrContact count];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    scrollView.contentInset = UIEdgeInsetsMake(0,0,0,0);
}

-(void) tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    [tblContact cellForRowAtIndexPath:indexPath].backgroundColor = COLOR_247247247;
}
-(void) tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    [tblContact cellForRowAtIndexPath:indexPath].backgroundColor = [UIColor clearColor];
}

-(void) tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tblContact cellForRowAtIndexPath:indexPath].backgroundColor = [UIColor clearColor];
}

-(void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    ((ChatComposeCell*)cell).checkBox.layer.borderWidth = isCreatingGroup? 1:0;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    Contact* user = [arrContact objectAtIndex:indexPath.row];
    ChatBox* chatBox = [[AppFacade share] getChatBox:user.jid];
    if (!chatBox) {
        [[ChatFacade share] createChatBox:user.jid isMUC:FALSE];
        chatBox = [[AppFacade share] getChatBox:user.jid];
    }
    [self dismissViewControllerAnimated:NO completion:^(){
        [[CWindow share] showChatList];
        [[ChatFacade share] moveToChatView:chatBox.chatboxId];
    }];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellID =  @"ChatComposeCell";
	ChatComposeCell *cell = [tblContact dequeueReusableCellWithIdentifier:cellID];
    
    if(!cell){
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:cellID owner:nil options:nil];
        cell = (ChatComposeCell*)[nib objectAtIndex:0];
    }
    
    
    if(!arrContact)
        return cell;
    
    if ([arrContact count] > indexPath.row) {
        Contact* contact = [arrContact objectAtIndex:indexPath.row];
        cell.lblName.text = [[ContactFacade share] getContactName:contact.jid];
        
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
// search
-(void)searchBuddyName{
    [arrContact removeAllObjects];
    NSString *searchText = headerCompose.searchContact.text;
    [[ContactFacade share] searchContact:searchText];
}

-(void)callChangeState
{
    [headerCompose fixView];
}

@end
