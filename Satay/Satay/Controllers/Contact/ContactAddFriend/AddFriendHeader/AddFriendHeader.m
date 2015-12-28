//
//  HeaderContactFriendList.m
//  KryptoChat
//
//  Created by ENCLAVEIT on 6/21/14.
//  Copyright (c) 2014 mTouche. All rights reserved.
//

#import "AddFriendHeader.h"
#import "VoiceCallView.h"

@implementation AddFriendHeader

@synthesize searchBar;
@synthesize dimView,viewAddMaskingID, searchDelayer;

-(void) searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    [searchDelayer invalidate];
    searchDelayer=nil;
    searchDelayer = [NSTimer scheduledTimerWithTimeInterval:0.3
                                                         target:self
                                                       selector:@selector(delayedSearch:)
                                                       userInfo:searchText
                                                        repeats:NO];
}

-(void)delayedSearch:(NSTimer *)timer
{
    [[ContactFacade share] searchUserMember:searchDelayer.userInfo];
    [[ContactFacade share] searchPhoneBookFriend:searchDelayer.userInfo];
    searchDelayer = nil; // important because the timer is about to release and dealloc itself
}

-(void) searchBarTextDidBeginEditing:(UISearchBar *)searchBar1{
    [self startFriendSearch];
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar1{
     self.searchBar.text = @"";
    [[ContactFacade share] searchUserMember:self.searchBar.text];
    [[ContactFacade share] searchPhoneBookFriend:self.searchBar.text];
    [[ContactBook share] displayLabelNoContact];    
    [self endFriendSearch];
    
}
-(void) searchBarSearchButtonClicked:(UISearchBar *)searchBar1{
    [self endEditing:YES];
}

-(void)startFriendSearch{
    self.isSearching = YES;
    [ContactBook share].addFriendCounter.hidden = TRUE;
    [ContactBook share].navigationController.navigationBarHidden = YES;
    [searchBar setShowsCancelButton:YES];
    [self.viewAddMaskingID setHidden:YES];
    [self fixView];
}

-(IBAction)endFriendSearch{
    self.searchBar.text = @"";
    self.isSearching = NO;
    [searchBar resignFirstResponder];
    [[ContactBook share] updateLabelCounter];
    [[ContactBook share].scrollview changeXAxis:0 YAxis:0];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [ContactBook share].navigationController.navigationBarHidden = NO;
    [searchBar setShowsCancelButton:NO];
    [self.viewAddMaskingID setHidden:NO];
    [[ContactBook share] fixTableDisplay];
}

-(void)fixView
{
    if (!self.isSearching)
        return;
    [[ContactBook share] fixTableDisplay];
    if (![SIPFacade share].isMinimize){
        [[ContactBook share].scrollview changeXAxis:0 YAxis:0];
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
    }
    else{
        [[ContactBook share].scrollview changeXAxis:0 YAxis:20];
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
    }
}

- (IBAction)addAFriend:(id)sender {
    UIButton *btnAddFriend = (UIButton*)sender;
    btnAddFriend.enabled= NO;
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        btnAddFriend.enabled= YES;
        [self endFriendSearch];
        [[ContactBook share].navigationController pushViewController:[ContactSearchMID share] animated:TRUE];
    }];
}

-(void) hideAddMaskingID{
    [viewAddMaskingID changeWidth:viewAddMaskingID.width Height:0];
}

-(void) willMoveToSuperview:(UIView *)newSuperview{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        [self hideAddMaskingID];
        [[UIBarButtonItem appearanceWhenContainedIn:[UISearchBar class], nil] setTitleTextAttributes:
         @{NSForegroundColorAttributeName: COLOR_707070,
           NSFontAttributeName: [UIFont systemFontOfSize:15]
           } forState:UIControlStateNormal];
        if(!(NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1)){
            [[searchBar.subviews objectAtIndex:0] removeFromSuperview];
            for (UIView *searchbuttons in searchBar.subviews)
            {
                if ([searchbuttons isKindOfClass:[UIButton class]])
                {
                    UIButton *cancelButton = (UIButton*)searchbuttons;
                    cancelButton.enabled = YES;
                    [cancelButton setBackgroundImage:[UIImage new] forState:UIControlStateNormal];
                    break;
                }
            }
        }
    });
    
}


@end
