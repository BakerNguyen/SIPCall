//
//  ComposeHeader.m
//  KryptoChat
//
//  Created by TrungVN on 4/22/14.
//  Copyright (c) 2014 mTouche. All rights reserved.
//

#import "ComposeHeader.h"
#import "ChatCompose.h"
#import "NewGroup.h"
#import "CWindow.h"

@implementation ComposeHeader

@synthesize searchContact, viewNewGroup;

-(void) willMoveToSuperview:(UIView *)newSuperview{
    [viewNewGroup addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(newGroup)]];
    
    [[UIBarButtonItem appearanceWhenContainedIn:[UISearchBar class], nil] setTitleTextAttributes: @{NSForegroundColorAttributeName: CONTACT_SEARCHBAR_TEXTCOLOR, NSFontAttributeName: [UIFont systemFontOfSize:15]} forState:UIControlStateNormal];
}

-(void)hideNewGroup{
    [self animateWidth:self.width Height:searchContact.height];
    [ChatCompose share].tblContact.tableHeaderView = self;
}

-(void)showNewGroup{
    [self animateWidth:self.width Height:searchContact.height + viewNewGroup.height];
    [ChatCompose share].tblContact.tableHeaderView = self;
}

-(void) newGroup{
    /*
     if ([[DaoHandler share] getTotalChatUsersWithJID:[[DaoHandler share] getUDValueByKey:JID] Role:CHATUSER_ROLE_ADMIN] >= CREATE_ROOM_LIMIT){
        [[CAlertView new] showError:@"Exceeded room limit. You are not allowed to create more than 10 rooms."];
        return;
    }
     */

    [NewGroup share].arrContact = [[ChatCompose share].arrContact mutableCopy];
    [NewGroup share].arrContactStore = [[ChatCompose share].arrContact mutableCopy];
    [[[ChatCompose share] navigationController] pushViewController:[NewGroup share] animated:TRUE];

}

-(void) searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    [[ChatCompose share] searchBuddyName];
}

-(void) searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    [self startFriendSearch];
}

/*Daryl comment this. we only end search when user cancel. Not end search when end editing
-(void) searchBarTextDidEndEditing:(UISearchBar *)searchBar{
    [self endFriendSearch];
} */
-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    self.searchContact.text = @"";
    [[ChatCompose share] searchBuddyName];
    [self endFriendSearch];
}
-(void) searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [self endEditing:YES];
}

-(void)startFriendSearch{
    [ChatCompose share].navigationController.navigationBarHidden = YES;
    [searchContact setShowsCancelButton:YES];
    [searchContact changeXAxis:0 YAxis:searchContact.y];
    [[ChatCompose share].tblContact changeXAxis:0 YAxis:0];
    [self changeWidth:searchContact.width Height:searchContact.height];
    
    [self hideNewGroup];
    [self fixView];
}

-(void)endFriendSearch{
    self.searchContact.text = @"";
    [searchContact resignFirstResponder];
    [[ChatCompose share].tblContact changeXAxis:0 YAxis:0];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [ChatCompose share].navigationController.navigationBarHidden = NO;
    [searchContact setShowsCancelButton:NO];
    [[ChatCompose share].tblContact reloadData];
    [searchContact changeXAxis:0 YAxis:searchContact.y];

    [self showNewGroup];

}

-(void)fixView
{
    if (![SIPFacade share].isMinimize){
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
         [[ChatCompose share].tblContact changeXAxis:0 YAxis:0];
    }
    else{
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
        [[ChatCompose share].tblContact changeXAxis:0 YAxis:20];
    }

}

@end
