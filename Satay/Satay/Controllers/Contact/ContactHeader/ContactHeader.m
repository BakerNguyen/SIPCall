//
//  HeaderView.m
//  KryptoChat
//
//  Created by TrungVN on 4/16/14.
//  Copyright (c) 2014 mTouche. All rights reserved.
//

#import "ContactHeader.h"

#import "ContactList.h"
#import "ContactEdit.h"
#import "ContactRequest.h"
#import "ContactPending.h"

@implementation ContactHeader

@synthesize lblNumberPending, lblNumberRequest;
@synthesize btnEdit, searchBar;
@synthesize pendingView, requestView, dividerHeader;
@synthesize dimView;

-(void) willMoveToSuperview:(UIView *)newSuperview{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        lblNumberRequest.layer.cornerRadius = lblNumberRequest.frame.size.width/2;
        [requestView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapViewRequest)]];
        [pendingView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapViewPending)]];
        [self hideNewRequest];
        [self hidePending];
        [searchBar setBackgroundImage:[UIImage imageFromColor:CONTACT_SEARCHBAR_BG]];
        [ContactFacade share].contactHeaderDelegate = self;
        
        [[UIBarButtonItem appearanceWhenContainedIn:[UISearchBar class], nil] setTitleTextAttributes: @{NSForegroundColorAttributeName: CONTACT_SEARCHBAR_TEXTCOLOR, NSFontAttributeName: [UIFont systemFontOfSize:15]} forState:UIControlStateNormal];
        self.isSearching = NO;
    });
}

-(void) searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    [[ContactFacade share] searchContact:searchText];
}

-(void) searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    [self startSearch];
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    self.searchBar.text = @"";
    [[ContactFacade share] searchContact:self.searchBar.text];
    [self endFriendSearch];
}
-(void) searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [self endEditing:YES];
}

-(void)startSearch{
    self.isSearching = YES;
    btnEdit.hidden = [ContactList share].notification.hidden = TRUE;
    [searchBar changeWidth:self.width Height:searchBar.height];
    [searchBar animateXAxis:0 YAxis:searchBar.frame.origin.y];
    pendingView.hidden = requestView.hidden = YES;

    [ContactList share].navigationController.navigationBarHidden = YES;
    [searchBar setShowsCancelButton:YES];
    
    [[ContactList share].tblContact changeXAxis:0 YAxis:0];
    [self changeWidth:self.width Height:searchBar.height];
    
    [[ContactList share].tblContact setTableHeaderView:self];
    dimView.hidden = [ContactList share].tblContact.scrollEnabled = FALSE;
    [self fixView];
}

-(void)endFriendSearch{
    self.searchBar.text = @"";
    self.isSearching = NO;
    [ContactList share].notification.hidden = NO;
    [[ContactList share].notification movingHeight];
    [self checkDevider];
    [searchBar changeXAxis:btnEdit.width YAxis:searchBar.y];
    [searchBar changeWidth:(self.width-btnEdit.width) Height:searchBar.height];
    pendingView.hidden = requestView.hidden = NO;
    btnEdit.hidden = [ContactList share].tblContact.tableHeaderView.hidden = NO;
    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton:FALSE];
    [[ContactList share].tblContact changeXAxis:0 YAxis:20];
    [[UIApplication sharedApplication] setStatusBarHidden:FALSE];
    
    [ContactList share].navigationController.navigationBarHidden = NO;
    [[ContactList share].tblContact changeXAxis:0 YAxis:[ContactList share].notification.height];
    [[ContactFacade share] loadContactRequest];
    [[ContactList share].tblContact reloadData];
    dimView.hidden = [ContactList share].tblContact.scrollEnabled = TRUE;
}

-(void)fixView
{
    if (!self.isSearching)
        return;    
    
    if (![SIPFacade share].isMinimize){
        [[ContactList share].tblContact changeXAxis:0 YAxis:0];
         [[UIApplication sharedApplication] setStatusBarHidden:YES];
    }
    else{
        [[ContactList share].tblContact changeXAxis:0 YAxis:20];
         [[UIApplication sharedApplication] setStatusBarHidden:NO];
    }
}

-(IBAction) editContacts{
    [[ContactList share].navigationController pushViewController:[ContactEdit share] animated:YES];
}

-(void) tapViewRequest{
    [[ContactList share].navigationController pushViewController:[ContactRequest share] animated:TRUE];
}
-(void) tapViewPending{
    [[ContactList share].navigationController pushViewController:[ContactPending share] animated:TRUE];
}

-(void) showNewRequest:(NSArray*) arrRequest{ 
    lblNumberRequest.text = [NSString stringWithFormat:@"%lu", (unsigned long)[arrRequest count]];
    [requestView changeWidth:requestView.width Height:44];
    [self reloadlblNumberRequest];
    [self checkDevider];
}
-(void) hideNewRequest{
    [requestView changeWidth:requestView.width Height:0];
    [self checkDevider];
}

-(void) showPending:(NSArray*) arrPending{
    lblNumberPending.text = [NSString stringWithFormat:@"%lu", (unsigned long)[arrPending count]];
    [pendingView changeWidth:pendingView.width Height:44];
    [self checkDevider];
}
-(void) hidePending{
    [pendingView changeWidth:pendingView.width Height:0];
    [self checkDevider];
}

-(void) showSearchBar{
    [searchBar changeWidth:searchBar.width Height:44];
    [self checkDevider];
}
-(void) hideSearchBar{
    [searchBar changeWidth:searchBar.width Height:0];
    [self checkDevider];
}

-(void) checkDevider{
    // return if is searching contact
    if([ContactList share].navigationController.navigationBarHidden)
        return;
    
    // return if Edit contact is showing
    if([ContactEdit share].navigationController)
        return;
    
    dividerHeader.hidden = !(requestView.hidden == FALSE && pendingView.hidden == FALSE);
    
    [requestView changeXAxis:0 YAxis:searchBar.height];
    [pendingView changeXAxis:0 YAxis:searchBar.height + requestView.height];
    [self animateWidth:self.width Height:searchBar.height + requestView.height + pendingView.height];
    [[ContactList share].tblContact setTableHeaderView:self];    
}

-(void) reloadlblNumberRequest{
    NSArray* arrUnreadRequestNotice = [[NotificationFacade share] getAllNoticesWithContent:kNOTICEBOARD_CONTENT_ADD_CONTACT status:kNOTICEBOARD_STATUS_NEW];
    if(arrUnreadRequestNotice.count > 0){
        lblNumberRequest.backgroundColor = COLOR_24317741;
        lblNumberRequest.textColor = [UIColor whiteColor];
    }
    else{
        lblNumberRequest.backgroundColor = [UIColor clearColor];
        lblNumberRequest.textColor = COLOR_170170170;
    }
}

@end
