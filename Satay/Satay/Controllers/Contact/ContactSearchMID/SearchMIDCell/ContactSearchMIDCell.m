//
//  MaskingIDCell.m
//  KryptoChat
//
//  Created by TrungVN on 5/29/14.
//  Copyright (c) 2014 mTouche. All rights reserved.
//

#import "ContactSearchMIDCell.h"

@implementation ContactSearchMIDCell
@synthesize  lblName,btnAdd,bob_maskingId,profile_image, bob_jid;

-(void) willMoveToSuperview:(UIView *)newSuperview{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        [btnAdd addTarget:self action:@selector(addFriend:) forControlEvents:UIControlEventTouchUpInside];
        profile_image.layer.cornerRadius = profile_image.frame.size.width/2;
    });
}

-(void)addFriend:(id)sender
{
    if ([[ContactFacade share] isAccountRemoved]) {
        [[CAlertView new] showError:ERROR_ACCOUNT_REMOVED];
        return;
    }
    
    if (![[NotificationFacade share] isInternetConnected]){
        [[CAlertView new] showError:NO_INTERNET_CONNECTION_TRY_LATER];
        return;
    }
    
    UIButton *btn = (UIButton*)sender;
    if([btn.imageView.image isEqual:[UIImage imageNamed:IMG_BUTTON_ADD]]){
        // Add
        [[CWindow share] showLoading:kLOADING_ADDING];
        [[ContactFacade share] friendRequestWithContactJid:bob_jid requestType:REQUEST requestInfo:nil];
    }
    else{
        // Approve
        [[ContactFacade share] responseFriendRequest:bob_jid responseType:APPROVED];
    }
}

@end
