//
//  FooterInfo.m
//  KryptoChat
//
//  Created by TrungVN on 6/9/14.
//  Copyright (c) 2014 mTouche. All rights reserved.
//

#import "FooterInfo.h"
#import "ContactInfo.h"
#import "ChatCompose.h"
#import "FindEmailContact.h"

@implementation FooterInfo

@synthesize chatBox;
@synthesize btnBlock, btnClear, tblGroup, footerView;
@synthesize addFriendView;
@synthesize selectJid;
@synthesize isAdminOfGroup;

#define MEMBER_ROLE 1
#define ADMIN_ROLE 0

-(void) willMoveToSuperview:(UIView *)newSuperview{
    /* Daryl comment this. Add view instead     
    CALayer* topBorder = [CALayer new];
    CALayer* bottomBorder = [CALayer new];
    [topBorder setFrame:CGRectMake(0, 0, btnBlock.frame.size.width, 1)];
    [bottomBorder setFrame:CGRectMake(0, btnBlock.frame.size.height-1, btnBlock.frame.size.width, 1)];
    
    topBorder.backgroundColor = bottomBorder.backgroundColor = COLOR_211211211.CGColor;
    
    [btnBlock.layer addSublayer:topBorder];
    [btnBlock.layer addSublayer:bottomBorder];
    
    [btnClear.layer addSublayer:[NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:topBorder]]];
    [btnClear.layer addSublayer:[NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:bottomBorder]]];
     */
    UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addFriendIntoGroup)];
    [tapGesture setCancelsTouchesInView:NO];
    [addFriendView addGestureRecognizer:tapGesture];
}

-(IBAction) clearConversation:(id) sender{
    NSString* displayWarning = WARNING_ALL_CONVERSATION_WILL_BE_DELETED;
    [[CAlertView new] showWarning:displayWarning TARGET:self ACTION:@selector(clearAllConversations)];
}

- (void) clearAllConversations{
    [[ChatFacade share] removeAllChatBoxMessage:chatBox.chatboxId];
}

-(IBAction) blockContact:(id) sender{
    if ([[ContactFacade share] isAccountRemoved]) {
        [[CAlertView new] showError:ERROR_ACCOUNT_REMOVED];
        return;
    }
    
    if (![[NotificationFacade share] isInternetConnected]){
        [[CAlertView new] showError:NO_INTERNET_CONNECTION_TRY_LATER];
        return;
    }
    
    if (chatBox.isGroup) {
        [[CAlertView new] showWarning:WARNING_THIS_GROUP_WILL_BE_DELETED
                               TARGET:self
                               ACTION:@selector(deleteGroup)];
        return;
    }
    Contact* contact = [[ContactFacade share] getContact:chatBox.chatboxId];
    if ([contact.contactState integerValue] != kCONTACT_STATE_BLOCKED) {
        [[CAlertView new] showWarning:WARNING_WILL_BLOCK_THIS_CONTACT
                               TARGET:self
                               ACTION:@selector(blockProcess)];
    }
    else{
        [[CWindow share] showLoading:kLOADING_UPDATING];
        [[ContactFacade share] synchronizeBlockList:contact.jid action:kUNBLOCK_USERS];
    }
}


-(void) blockProcess{
    if ([[ContactFacade share] isAccountRemoved]) {
        [[CAlertView new] showError:ERROR_ACCOUNT_REMOVED];
        return;
    }
    
    if (![[NotificationFacade share] isInternetConnected]){
        [[CAlertView new] showError:NO_INTERNET_CONNECTION_TRY_LATER];
        return;
    }
    
    Contact* contact = [[ContactFacade share] getContact:chatBox.chatboxId];
    [[CWindow share] showLoading:kLOADING_UPDATING];
    [[ContactFacade share] synchronizeBlockList:contact.jid action:kBLOCK_USERS];
}

-(void) deleteGroup{
    NSDictionary *leaveDic = @{kMUC_ROOM_JID: chatBox.chatboxId,
                               kXMPP_TO_JID: [[ContactFacade share] getJid:YES]
                               };
    [[ChatFacade share] leaveFromChatRoom:leaveDic];
}

-(void) displayBlockButton{
    btnBlock.enabled = TRUE;
    if (chatBox.isGroup) {
        [btnBlock setTitleColor:COLOR_2316558 forState:UIControlStateNormal];
        [btnBlock setTitle:_DELETE_AND_EXIT_GROUP forState:UIControlStateNormal];
    } else {
        Contact* contact = [[ContactFacade share] getContact:chatBox.chatboxId];
        switch ([contact.contactState integerValue]) {
            case kCONTACT_STATE_ONLINE:
            case kCONTACT_STATE_OFFLINE:
                [btnBlock setTitleColor:COLOR_2316558 forState:UIControlStateNormal];
                [btnBlock setTitle:_BLOCK_THIS_CONTACT forState:UIControlStateNormal];
                break;
            case kCONTACT_STATE_BLOCKED:
                [btnBlock setTitleColor:COLOR_48147213 forState:UIControlStateNormal];
                [btnBlock setTitle:_UNBLOCK forState:UIControlStateNormal];
                break;
            case kCONTACT_STATE_DELETED:
                btnBlock.enabled = FALSE;
                break;
            default:
                break;
        }
    }
}

-(void) buildFooter:(ChatBox*) chatBoxInfo{
    chatBox = chatBoxInfo;
    isAdminOfGroup = [[ChatFacade share] isAdmin:chatBox.chatboxId];
    if (chatBox.isGroup){
        [tblGroup changeWidth:tblGroup.width Height:tblGroup.contentSize.height];
    } else {
        [tblGroup changeWidth:tblGroup.width Height:0];
    }
    
    //tblGroup.layer.borderWidth = 1;
    
    [self displayBlockButton];
    [footerView changeXAxis:0 YAxis:tblGroup.height];
    [self changeWidth:self.width Height:tblGroup.height + footerView.height];
}

-(NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return [NSString stringWithFormat:PARTICIPANTS, (int)[[ContactInfo share].arrGroupFriend count]];
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [[ContactInfo share].arrGroupFriend count];
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    ((GroupInfoFriendCell*)cell).underLine.hidden = NO;
    
    if (isAdminOfGroup)
        return;
    
    if(indexPath.row == [tableView numberOfRowsInSection:0] - 1){
        ((GroupInfoFriendCell*)cell).underLine.hidden = YES;
    }
}

-(UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellID = @"GroupInfoFriendCell";
    GroupInfoFriendCell *cell = (GroupInfoFriendCell *)[tblGroup dequeueReusableCellWithIdentifier:cellID];
    
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"GroupInfoFriendCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    GroupMember *gm = (GroupMember *)[[ContactInfo share].arrGroupFriend objectAtIndex:indexPath.row];
    
    if (gm) {
        Contact *contact = [[ContactFacade share] getContact:gm.jid];
        if (contact) {
            cell.imgAvatar.image = [[ContactFacade share] updateContactAvatar:contact.jid];
            cell.lblName.text = [[ContactFacade share] getContactName:contact.jid];
        }
        
        // for myself
        if ([gm.jid isEqualToString:[[ContactFacade share] getJid:YES]]) {
            if([[[ContactFacade share] getProfileAvatar] isEqual:[UIImage imageNamed:IMG_S_EMPTY]]){
                cell.imgAvatar.image = [UIImage imageNamed:IMG_C_EMPTY];
            }
            else{
                cell.imgAvatar.image = [[ContactFacade share] getProfileAvatar];
            }
            
            cell.lblName.text = _YOU;
        }
        
        cell.lblGroupAdmin.hidden = ([gm.memberRole integerValue] != ADMIN_ROLE);
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (!isAdminOfGroup)
        return;
    GroupMember* groupMember = [[ContactInfo share].arrGroupFriend objectAtIndex:indexPath.row];
    
    if (groupMember) {
        selectJid = groupMember.jid;
        if ([selectJid isEqualToString: [[ContactFacade share]getJid:YES]]) {
            return;
        }
        UIActionSheet* actionSheet1 = [[UIActionSheet alloc] init];
        actionSheet1.delegate = self;
        actionSheet1.destructiveButtonIndex = [actionSheet1 addButtonWithTitle:[NSString stringWithFormat:REMOVE, [[ContactFacade share] getContactName:selectJid]]];
        actionSheet1.cancelButtonIndex = [actionSheet1 addButtonWithTitle:_CANCEL];
        [actionSheet1 showInView:self];
    }
}

-(void) tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    GroupInfoFriendCell* cell = (GroupInfoFriendCell*)[tableView cellForRowAtIndexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 44.0;
}

-(UIView*) tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if(isAdminOfGroup)
        return addFriendView;
    else
        return [[UIView alloc] initWithFrame:CGRectZero];
}

-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        Contact *rmContact = [[ContactFacade share] getContact:selectJid];        
        if (rmContact) {
            NSDictionary *kickMemberDic = @{kMUC_ROOM_JID:chatBox.chatboxId,
                                            kFRIEND_MASKING_ID:rmContact.maskingid,
                                            kXMPP_TO_JID:selectJid
                                            };
            [[ChatFacade share] kickMember:kickMemberDic];
        }
    }
}

-(void) addFriendIntoGroup{
    if ([[ContactFacade share] isAccountRemoved]) {
        [[CAlertView new] showError:ERROR_ACCOUNT_REMOVED];
        return;
    }
    
    if (![[NotificationFacade share] isInternetConnected]){
        [[CAlertView new] showError:NO_INTERNET_CONNECTION_TRY_LATER];
        return;
    }
    [FindEmailContact share].isAddParticipants = YES;
    [[CWindow share] showPopup:[FindEmailContact share]];
}

@end
