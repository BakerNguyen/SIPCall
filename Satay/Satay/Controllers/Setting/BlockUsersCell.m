//
//  BlockUsersCell.m
//  Satay
//
//  Created by Vi (Violet) T.T. DAO on 5/13/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import "BlockUsersCell.h"
#import "BlockUsersController.h"
@implementation BlockUsersCell

@synthesize btnUnblock, avatar, lblName, fullJID;

-(void) willMoveToSuperview:(UIView *)newSuperview{
    btnUnblock.layer.borderWidth = 1;
    btnUnblock.layer.cornerRadius = 5;
    
    avatar.layer.cornerRadius = avatar.frame.size.width/2;
    avatar.clipsToBounds = YES;
}

- (IBAction)unBlockUser:(id)sender {
    if ([[ContactFacade share] isAccountRemoved]) {
        [[CAlertView new] showError:ERROR_ACCOUNT_REMOVED];
        return;
    }
    
    if (![[NotificationFacade share] isInternetConnected]) {
        [[CAlertView new] showError:NO_INTERNET_CONNECTION_TRY_LATER];
        return;
    }
    
    [[CWindow share] showLoading:kLOADING_LOADING];
    [[ContactFacade share] synchronizeBlockList:fullJID action:kUNBLOCK_USERS];
}

#pragma mark Synchronize block list
-(void) synchronizeBlockListSuccess{
    [[CWindow share] hideLoading];
    Contact* contact = [[ContactFacade share] getContact:fullJID];
    [[BlockUsersController share] removeUnblockUserToArray:contact];
}
-(void) synchronizeBlockListFailed{
    [[CWindow share] hideLoading];
     [[CAlertView new] showError:ERROR_SERVER_GOT_PROBLEM];
}

@end
