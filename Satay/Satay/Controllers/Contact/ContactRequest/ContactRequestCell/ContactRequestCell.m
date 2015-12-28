//
//  NewRequestCell.m
//  KryptoChat
//
//  Created by Kuan Khim Yoong on 5/9/14.
//  Copyright (c) 2014 mTouche. All rights reserved.
//

#import "ContactRequestCell.h"

@implementation ContactRequestCell
@synthesize imgAvatar,lblBuddyName,btnApprove,btnDeny, cellJid;

-(void) willMoveToSuperview:(UIView *)newSuperview{
    imgAvatar.layer.cornerRadius = imgAvatar.frame.size.width/2;
}

-(IBAction)approveRequest:(id)sender{
    NSLog(@"cellJid %@", cellJid);
    //[[ContactFacade share] approveRequest:cellJid];
    [[ContactFacade share] responseFriendRequest:cellJid responseType:APPROVED];
}

-(IBAction)denyRequest:(id)sender{
    NSLog(@"DENIED");
    //[[ContactFacade share] denyRequest:cellJid];
    [[ContactFacade share] responseFriendRequest:cellJid responseType:DENIED];
}

@end
