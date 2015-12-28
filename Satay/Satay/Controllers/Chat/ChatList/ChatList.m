//
//  ChatList.m
//  Satay
//
//  Created by TrungVN on 1/15/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import "ChatList.h"
#import "ChatListCell.h"
#import "ChatEdit.h"

@interface ChatList ()
@end

@implementation ChatList

@synthesize header;
@synthesize tblChatHistory, arrChatBox, arrDeleteChatBoxs;
@synthesize notification;
@synthesize lblNoChatRoom;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:notification];
    self.title = TITLE_CHAT;
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem createRightButtonTitle:_COMPOSE
                                                                              Target:self
                                                                              Action:@selector(composeChat)];
    arrChatBox = [NSMutableArray new];
    arrDeleteChatBoxs = [NSMutableArray new];
    [ChatFacade share].chatListDelegate = self;
    [ContactFacade share].chatListDelegate = self;
    [SIPFacade share].chatListDelegate = self;
    [header.searchBar setText:@""];
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (![self.view.subviews containsObject:tblChatHistory])
         [self.view addSubview:tblChatHistory];
   
    [[ChatFacade share] reloadChatBoxList];
    [[ContactFacade share] loadFriendArray];
    [[LogFacade share] trackingScreen:Chat_Category];
}

-(void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.notification movingHeight];
}

-(void) viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    tblChatHistory.editing = FALSE;
}

-(void) checkDisplayWhenNoChat{
    // return if Edit chat page is showing
    if ([self.navigationController.topViewController isEqual:[ChatEdit share]])
        return;
    
    // return if is searching
    if(self.navigationController.navigationBarHidden)
        return;
    
    if(tblChatHistory.isEditing)
        return;
    
    if(arrChatBox.count > 0){
        tblChatHistory.tableHeaderView = header;
        lblNoChatRoom.hidden = YES;
    }
    else{
        tblChatHistory.tableHeaderView = nil;
        lblNoChatRoom.hidden = NO;
    }
    
    [tblChatHistory reloadData];
}

-(void)reloadComposeButton:(NSArray *) contactArray{
    self.navigationItem.rightBarButtonItem.enabled = (contactArray.count > 0);
}

-(void) composeChat{
    if ([[ContactFacade share] isAccountRemoved]) {
        [[CAlertView new] showError:ERROR_ACCOUNT_REMOVED];
        return;
    }
    [[CWindow share] showPopup:[ChatCompose share]];
}

-(void) reloadChatList:(NSArray*) chatboxArray{
    // if editting, we skip reload table.
    if ([self.navigationController.topViewController isEqual:[ChatEdit share]])
        return;
    
    [arrChatBox removeAllObjects];
    arrChatBox = [chatboxArray mutableCopy];
    
    [self checkDisplayWhenNoChat];
}

-(void) reloadSearchChatList:(NSMutableArray *)chatboxArray{
    if (![arrChatBox isEqualToArray:chatboxArray]) {
        arrChatBox = [chatboxArray mutableCopy];
        [tblChatHistory reloadData];
    }
}

-(void) showChatView:(NSString*) chatBoxId{
    [[CWindow share] showLoading:kLOADING_LOADING];
    [ChatView share].chatBoxID = chatBoxId;
    
    [header endSearch];
    if (![self.navigationController.topViewController isEqual:[ChatView share]]) {
        [[ChatList share].navigationController pushViewController:[ChatView share] animated:YES];
    }
    else{
        [[ChatView share] resetContent];
        [[ChatView share] buildContent];
    }
    //this is if [ChatList share].navigationController not available, the chat view won't be pushed.
    if (![ChatList share].navigationController)
        [ChatView share].chatBoxID = @"";
    
    [ChatList share].tblChatHistory.userInteractionEnabled = YES;
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [header.searchBar resignFirstResponder];
}

-(void)callChangeState
{
    [header fixView];
}

-(void)doneLeaveChatBox:(NSString *)errString
{
    if (![self.navigationController.topViewController isEqual:self])
        return;
    
    if (errString.length>0) {
        [[CAlertView new] showError:errString];
    }

}

#pragma mark UITableView Delegate
-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    tableView.userInteractionEnabled = NO;
    [self showChatView:((ChatBox*)[arrChatBox objectAtIndex:indexPath.row]).chatboxId];
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

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row >= arrChatBox.count){
        return;
    }
    ChatBox* chatBox = [arrChatBox objectAtIndex:indexPath.row];
    if (chatBox){
        if ([ChatEdit share].navigationController)
        {
            [arrDeleteChatBoxs addObject:chatBox];
            // if user is in edit Chat page, then do nothing, only remove in UI
            // because user can press Cancel.
            [self deleteChatBoxRow:tableView forIndex:indexPath];
        }
        else{
            tblChatHistory.editing = FALSE;
            NSDictionary *leaveDic = @{kMUC_ROOM_JID: chatBox.chatboxId,
                                       kXMPP_TO_JID: [[ContactFacade share] getJid:YES]
                                       };
            [[ChatFacade share] leaveFromChatRoom:leaveDic];
        }
    }
}

- (void)tableView:(UITableView*)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [[ChatFacade share] reloadChatBoxList];
    }];
}

#pragma mark UITableView Datasource
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellID =  @"ChatListCell";
    ChatListCell *cell = [tblChatHistory dequeueReusableCellWithIdentifier:cellID];
    if(!cell){
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:cellID owner:nil options:nil];
        cell = (ChatListCell*)[nib objectAtIndex:0];
    }
    
    [cell.widthCallIConConstrant setConstant:0];
    [cell.horizontalSpaceStatusAndImgCall setConstant:0];
    
    if(arrChatBox.count <= indexPath.row)
        return cell;
    
    NSInvocationOperation* operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(buildCell:) object:cell];
    [operation setQueuePriority:NSOperationQueuePriorityVeryHigh];
    [[NSOperationQueue mainQueue] addOperation:operation];
    
    return cell;
}

-(void) buildCell:(ChatListCell*) cell{
    NSInteger index = [tblChatHistory indexPathForCell:cell].row;
    if (arrChatBox.count <= index)
        return;
    ChatBox* chatBox = [arrChatBox objectAtIndex:index];
    cell.lblUnreadMessage.text = [[ChatFacade share] getChatBoxUnreadCount:chatBox.chatboxId];
    cell.lblUnreadMessage.hidden = !cell.lblUnreadMessage.text;
    cell.lblStatus.text = [[ChatFacade share] getChatBoxLastMessage:chatBox.chatboxId];
    cell.lblTime.text = [[ChatFacade share] getChatBoxTimeStamp:chatBox.updateTS];
    
    if (chatBox.isGroup) {
        GroupObj *groupObj = [[AppFacade share] getGroupObj:chatBox.chatboxId];
        cell.lblName.text = [[ChatFacade share] getGroupName:chatBox.chatboxId];
        cell.imgAvatar.image = [[ChatFacade share] updateGroupLogo:groupObj.groupId];
    }
    else{
        Contact* contact = [[ContactFacade share] getContact:chatBox.chatboxId];
        cell.lblName.text = [[ContactFacade share] getContactName:chatBox.chatboxId];
        cell.imgAvatar.image = [[ContactFacade share] updateContactAvatar:contact.avatarURL];
        
        Message* message = [[[ChatFacade share] getHistoryMessage:chatBox.chatboxId limit:1] firstObject];
        if ([[ChatFacade share] messageType:message.messageType] == MediaTypeSIP) {
            [UIView animateWithDuration:0.3 animations:^(){
                [cell.widthCallIConConstrant setConstant:15];
                [cell.horizontalSpaceStatusAndImgCall setConstant:5];
            }];
           
        }
    }
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [arrChatBox count];
}

- (void)deleteChatBoxRow:(UITableView *)tableView forIndex:(NSIndexPath *)indexPath
{
    [arrChatBox removeObjectAtIndex:indexPath.row];
    
    [tableView beginUpdates];
    [tableView deleteRowsAtIndexPaths:@[indexPath]
                     withRowAnimation:UITableViewRowAnimationFade];
    [tableView endUpdates];
}


+(ChatList *)share{
    static dispatch_once_t once;
    static ChatList * share;
    dispatch_once(&once, ^{
        share = [self new];
    });
    return share;
}

@end
