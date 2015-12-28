//
//  PendingControllerCellTableViewCell.m
//  KryptoChat
//
//  Created by Kuan Khim Yoong on 5/9/14.
//  Copyright (c) 2014 mTouche. All rights reserved.
//

#import "ContactPendingCell.h"
#import "ContactPending.h"

@implementation ContactPendingCell

@synthesize imgAvatar, lblName;
@synthesize btnDelete;
@synthesize requestObj;

- (void)awakeFromNib
{
    [btnDelete addTarget:self action:@selector(btnDeleteClicked) forControlEvents:UIControlEventTouchUpInside];
    [self longPressOnRow];
}


- (void)btnDeleteClicked{
    // delete user in buddys list
    NSLog(@"deletePendingForApproval: %@", requestObj.requestJID);
    
    CAlertView *alert = [CAlertView new];
    [alert showWarning:[[NSString alloc] initWithFormat:NSLocalizedString(WARNING_ARE_YOU_SURE_DELETE_CONTACT, nil), [[ContactFacade share] getContactName:requestObj.requestJID]] TARGET:self ACTION:nil];
    [alert setOnButtonTouchUpInside:^(CAlertView *alertView, int buttonIndex)
     {
         if(buttonIndex == 0)
         {
             [self deletePendingForApproval:requestObj.requestJID];
         }
         
     }];
    
    //[alert showWarning:[[NSString alloc] initWithFormat:NSLocalizedString(mError_UnableDeleteFriendRequest, nil), requestObj.requestJID] TARGET:self ACTION:nil];
}

- (void)deletePendingForApproval:(NSString *)friendJID{
    [[CWindow share] showLoading:kLOADING_DELETING];
    [[ContactFacade share] friendRequestWithContactJid:friendJID requestType:CANCEL requestInfo:nil];
    
}
// Long Press on row
- (void)longPressOnRow{
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = 1.4; //seconds
    lpgr.delegate = self;
    [self addGestureRecognizer:lpgr];
}

-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        UIActionSheet * actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                  delegate:self cancelButtonTitle:NSLocalizedString(_CANCEL, nil)
                                                    destructiveButtonTitle:nil
                                                         otherButtonTitles:NSLocalizedString(_RESEND, nil), nil];
        actionSheet.delegate = self;
        [actionSheet showInView:[ContactPending share].view];
    }
}

-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (buttonIndex) {
        case 0:
            [self resendFriendRequest:requestObj.requestJID];
            break;
        default:
            break;
    }
}

- (void)resendFriendRequest:(NSString*)friendJID{
    // update code to
    Contact *contact = [[ContactFacade share] getContact:friendJID];
    
    if (contact) {
        [[ContactFacade share] friendRequestWithContactJid:contact.jid requestType:REQUEST requestInfo:nil];
    }
}

-(void) willMoveToSuperview:(UIView *)newSuperview{
    imgAvatar.layer.cornerRadius = imgAvatar.frame.size.width/2;
}




@end
