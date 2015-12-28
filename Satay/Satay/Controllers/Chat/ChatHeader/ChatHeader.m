//
//  HeaderChatList.m
//  KryptoChat
//
//  Created by TrungVN on 4/22/14.
//  Copyright (c) 2014 mTouche. All rights reserved.
//

#import "ChatHeader.h"
#import "ChatEdit.h"
#import "ChatList.h"



@implementation ChatHeader

@synthesize btnEdit, searchBar;

-(void) willMoveToSuperview:(UIView *)newSuperview{
    [searchBar setBackgroundImage:[UIImage imageFromColor:CONTACT_SEARCHBAR_BG]];
    [[UIBarButtonItem appearanceWhenContainedIn:[UISearchBar class], nil] setTitleTextAttributes: @{NSForegroundColorAttributeName: CONTACT_SEARCHBAR_TEXTCOLOR, NSFontAttributeName: [UIFont systemFontOfSize:15]} forState:UIControlStateNormal];
    self.isSearching = NO;
}

-(IBAction)editChatList{
    [ChatEdit share].arrChatBoxStore = [[ChatList share].arrChatBox copy];
    [[ChatList share].navigationController pushViewController:[ChatEdit share] animated:YES];
}

-(void)searchBar:(UISearchBar *)theSearchBar textDidChange:(NSString *)searchText {
    [[ChatFacade share] searchChatRoom:searchText];
}

-(void)searchBarTextDidBeginEditing:(UISearchBar *)theSearchBar {
    [self startSearch];
}
-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    self.searchBar.text = @"";
    [[ChatFacade share] searchChatRoom:self.searchBar.text];
    [self endSearch];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self endEditing:YES];
}

-(void)startSearch {
    self.isSearching = YES;
    [ChatList share].notification.hidden = YES;
    [ChatList share].navigationController.navigationBarHidden = YES;
    [searchBar setShowsCancelButton:TRUE animated:TRUE];
    
    btnEdit.hidden = TRUE;
    [searchBar changeWidth:searchBar.superview.width Height:searchBar.height];
    [searchBar changeXAxis:0 YAxis:0];
    [self fixView];
}

-(void)endSearch {
    self.searchBar.text = @"";
    self.isSearching = NO;
    [ChatList share].notification.hidden = NO;
    [searchBar resignFirstResponder];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [ChatList share].navigationController.navigationBarHidden = NO;
    [[ChatList share].tblChatHistory changeXAxis:0 YAxis:0];
    [searchBar setShowsCancelButton:FALSE animated:TRUE];
    
    btnEdit.hidden = FALSE;
    [searchBar changeWidth:searchBar.superview.width - btnEdit.width Height:searchBar.height];
    [searchBar changeXAxis:btnEdit.width YAxis:0];
    [[ChatList share].tblChatHistory changeXAxis:0 YAxis:[ChatList share].notification.height];
}

-(void)fixView
{
    if (!self.isSearching)
        return;
    
    if (![SIPFacade share].isMinimize){
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
        [[ChatList share].tblChatHistory changeXAxis:0 YAxis:0];
    }
    else{
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
        [[ChatList share].tblChatHistory changeXAxis:0 YAxis:20];
    }

}

@end