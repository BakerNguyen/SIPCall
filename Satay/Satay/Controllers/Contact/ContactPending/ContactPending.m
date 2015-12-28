//
//  PendingController.m
//  KryptoChat
//
//  Created by TrungVN on 4/17/14.
//  Copyright (c) 2014 mTouche. All rights reserved.
//

#import "ContactPending.h"


@interface ContactPending ()

@end

@implementation ContactPending
@synthesize tblPendingList, arrPending;

+(ContactPending *)share{
    static dispatch_once_t once;
    static ContactPending * share;
    dispatch_once(&once, ^{
        share = [self new];
    });
    return share;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title =TITLE_PENDING_FOR_APPROVAL;
    arrPending = [NSMutableArray new];
    [ContactFacade share].contactPendingDelegate = self;
}

-(void) viewWillAppear:(BOOL)animated{
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem createLeftButtonTitle:_BACK Target:self.navigationController Action:@selector(popViewControllerAnimated:)];
    [[ContactFacade share] displayNewPending];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
	return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [arrPending count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellID =  @"ContactPendingCell";
	ContactPendingCell *cell = [tblPendingList dequeueReusableCellWithIdentifier:cellID];
    
    if(!cell){
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:cellID owner:nil options:nil];
    	cell = (ContactPendingCell*)[nib objectAtIndex:0];
    }
    
    Request *requestObj = (Request*)[arrPending objectAtIndex:indexPath.row];
    
    cell.requestObj = requestObj;
    // update code for SMS_REQUEST - no contact name, just name from phonebook
    NSString *contactName = @"";
    if ([requestObj.requestJID rangeOfString:[[ContactFacade share] getXmppHostName]].location != NSNotFound) {
        contactName = [[ContactFacade share] getContactName:requestObj.requestJID];
    } else {
        contactName = requestObj.extend1;
    }
    cell.lblName.text = contactName;
    cell.imgAvatar.image = [[ContactFacade share] updateContactAvatar:requestObj.requestJID];
   
	return cell;
}

-(void) displayPending:(NSArray*) pendingList{
    arrPending = [pendingList mutableCopy];
    [tblPendingList reloadData];
}

-(void) backViewWhenNoPending{
    if (self.navigationController && arrPending.count == 0) {
        [[CWindow share] showContactList];
    }
}
-(void) cancelFriendRequestSuccess{
    [[CWindow share] hideLoading];
}
-(void) cancelFriendRequestFailed{
    [[CWindow share] hideLoading];
    [[CAlertView new] showError:NSLocalizedString(mError_UnableDeleteFriendRequest, nil)];
}

-(void) resendFriendFailed{
    if (![self.navigationController.topViewController isKindOfClass:[self class] ])
        return;
    
    [[CWindow share] hideLoading];
    [[CAlertView new] showError:_ALERT_FAILED_ADD];
}

-(void) resendFriendSuccess{
    [[CWindow share] hideLoading];
    if (!self.navigationController)
        return;
    
    CAlertView* alertView = [CAlertView new];
    [alertView showInfo:SUCCESS_TO_SEND_FRIEND_REQUEST];
    [alertView setOnButtonTouchUpInside:^(CAlertView *alertView, int buttonIndex)
     {
         if(buttonIndex ==0)
             [tblPendingList reloadData];
     }];
}

@end
