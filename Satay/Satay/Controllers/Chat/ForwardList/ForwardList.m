//
//  ForwardList.m
//  Satay
//
//  Created by MTouche on 4/10/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import "ForwardList.h"
#import "ContactCell.h"
#import "ChatView.h"

@interface ForwardList ()

@end

@implementation ForwardList

@synthesize forwardMessage, forwardContact;
@synthesize arrFriend, tblContact;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem createRightButtonTitle:_CLOSE
                                                                              Target:self Action:@selector(closeView)];
    self.title = TITLE_FORWARD_TO;
    _searchBar.delegate = self;
    [ContactFacade share].forwardListDelegate = self;
}

-(void) viewWillAppear:(BOOL)animated{
    [[ContactFacade share] loadFriendArray];
}

-(void) reloadForwardList:(NSArray*) arrContact{
    arrFriend = [arrContact mutableCopy];
    [tblContact reloadData];
}

-(void) forwardNow{
    //Switch to that chatbox of that user.
    ChatBox *chatBox = [[AppFacade share] getChatBox:forwardContact.jid];
    if (!chatBox){
        [[ChatFacade share] createChatBox:forwardContact.jid isMUC:NO];
        chatBox = [[AppFacade share] getChatBox:forwardContact.jid];
    }
    [ChatView share].chatBoxID = chatBox.chatboxId;
    [[ChatView share] resetContent];
    [[ChatView share] buildContent];
    [[ChatView share] checkDisplayBlueAlert];
    
    [[CWindow share] showLoading:kLOADING_SENDING];
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^(void){
        switch ([[ChatFacade share] messageType:forwardMessage.messageType]) {
            case MediaTypeText:
                if (forwardMessage.isEncrypted) {
                    NSData* data = [Base64Security decodeBase64String:forwardMessage.messageContent];
                    data = [[AppFacade share] decryptDataLocally:data];
                    if (data){
                        NSString* content = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                        [[ChatFacade share] sendText:content chatboxId:chatBox.chatboxId];
                    }
                }
                else{
                    [[ChatFacade share] sendText:forwardMessage.messageContent chatboxId:chatBox.chatboxId];
                }
                break;
            case MediaTypeAudio:{
                NSData* audioData = [[ChatFacade share] audioData:forwardMessage.messageId];
                NSString* rawAudioLink = [[ChatFacade share] createTempURL:audioData];
                [[ChatFacade share] sendAudio:rawAudioLink chatboxId:chatBox.chatboxId];
            }
                break;
            case MediaTypeImage:{
                [[ChatFacade share] sendImage:[UIImage imageWithData:[[ChatFacade share] imageData:forwardMessage.messageId]]
                                    chatboxId:chatBox.chatboxId];
            }
                break;
            case MediaTypeVideo:{
                NSData* videoData = [[ChatFacade share] videoData:forwardMessage.messageId];
                NSString* rawVideoLink = [[ChatFacade share] createTempURL:videoData];
                NSURL* videoURL = [NSURL fileURLWithPath:rawVideoLink];
                [[ChatFacade share] sendVideo:videoURL chatboxId:chatBox.chatboxId];
            }
                break;
                
            default:
                break;
        }
        
        [self closeView];
        [[CWindow share] hideLoading];
    }];
}

-(void) closeView{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex {
    return [arrFriend count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellID =  @"ContactCell";
    ContactCell *cell = [tblContact dequeueReusableCellWithIdentifier:cellID];
    
    if(!cell){
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:cellID owner:nil options:nil];
        cell = (ContactCell*)[nib objectAtIndex:0];
    }
    
    if ([arrFriend count] > indexPath.row)
    {
        Contact* contact = [arrFriend objectAtIndex:indexPath.row];
        cell.lblBuddyName.text = [[ContactFacade share] getContactName:contact.jid];
        
        NSString* contactState = @"";
        switch ([contact.contactState integerValue])
        {
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

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    forwardContact = (Contact*)[arrFriend objectAtIndex:indexPath.row];
    
    [[CAlertView new] showWarning:[NSString stringWithFormat:_WARNING_FORWARD_TO,[[ContactFacade share] getContactName:forwardContact.jid]]
                           TARGET:self
                           ACTION:@selector(forwardNow)];
}

#pragma mark - UISearchBar Delegate
- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar{
    self.searchBar.text = @"";
    [searchBar setShowsCancelButton:NO];
    [self.view endEditing:YES];
    [[ContactFacade share] searchContact:self.searchBar.text];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [searchBar setShowsCancelButton:YES];
    [[ContactFacade share] searchContact:searchText];
}

+(ForwardList *)share{
    static dispatch_once_t once;
    static ForwardList * share;
    dispatch_once(&once, ^{
        share = [self new];
    });
    return share;
}


@end
