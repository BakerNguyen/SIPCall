//
//  NewRequest.m
//  KryptoChat
//
//  Created by TrungVN on 4/17/14.
//  Copyright (c) 2014 mTouche. All rights reserved.
//

#import "ContactRequest.h"
#import "ContactRequestCell.h"
#import "ContactList.h"


@interface ContactRequest ()

@end

@implementation ContactRequest
@synthesize tblNewRequestList;
@synthesize loadingSpinner;
@synthesize arrNewRequest;

+(ContactRequest *)share{
    static dispatch_once_t once;
    static ContactRequest * share;
    dispatch_once(&once, ^{
        share = [self new];
    });
    return share;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = TITLE_NEW_REQUESTS;
    loadingSpinner.hidden = YES;
    arrNewRequest = [NSMutableArray new];
    [ContactFacade share].contactRequestDelegate = self;
}

-(void) viewWillAppear:(BOOL)animated{
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem createLeftButtonTitle:_BACK Target:self.navigationController Action:@selector(popViewControllerAnimated:)];
    [[ContactFacade share] displayNewRequest];
}

-(void) viewWillDisappear:(BOOL)animated{
    [[NotificationFacade share] markAllFriendRequestNoticesAsRead];
    [[NotificationFacade share] setUnreadNotification:[[NotificationFacade share] getNumberUnreadNotices] atMenuIndex:SideBarNotificationIndex];
    [[NotificationFacade share] setUnreadNotification:0 atMenuIndex:SideBarContactIndex];
    [[NotificationFacade share] hideNotificationView];
}

#pragma mark ContactRequestDelegate

-(void) displayRequest:(NSArray*) arrRequest{
    arrNewRequest = [arrRequest mutableCopy];
    [tblNewRequestList reloadData];
}

-(void) backViewWhenNoRequest{
    if(self.navigationController && arrNewRequest.count == 0){
        [[CWindow share] showContactList];
    }
}


#pragma mark UITableview Datasource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
	return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [arrNewRequest count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellID =  @"ContactRequestCell";
	ContactRequestCell *cell = [tblNewRequestList dequeueReusableCellWithIdentifier:cellID];
    
    if(!cell){
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:cellID owner:nil options:nil];
    	cell = (ContactRequestCell*)[nib objectAtIndex:0];
    }
    
    cell.cellJid = ((Request*)[arrNewRequest objectAtIndex:indexPath.row]).requestJID;
    
    Contact* contact = [[ContactFacade share] getContact:((Request*)[arrNewRequest objectAtIndex:indexPath.row]).requestJID];
    if(contact.jid){
        cell.cellJid = ((Request*)[arrNewRequest objectAtIndex:indexPath.row]).requestJID;
        cell.lblBuddyName.text = [[ContactFacade share] getContactName:contact.jid];
        cell.imgAvatar.image = [[ContactFacade share] updateContactAvatar:contact.avatarURL];
    }
    
    NoticeBoard* noticeBoard = [[NotificationFacade share] getNewNoticeWithID:cell.cellJid content:kNOTICEBOARD_CONTENT_ADD_CONTACT];
    cell.backgroundColor = (noticeBoard ? COLOR_255244230 : [UIColor whiteColor]);
    
    return cell;
}

@end


