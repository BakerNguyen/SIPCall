//
//  CPopup.m
//  JuzChatV2
//
//  Created by TrungVN on 8/13/13.
//  Copyright (c) 2013 mTouche. All rights reserved.
//
#import "CPopup.h"
#import "ChatView.h"
#import "ForwardList.h"
#import <AssetsLibrary/AssetsLibrary.h>

@implementation CPopup

@synthesize viewButton, btnCopy, btnDelete,btnForward, arrowDown;
@synthesize message;

-(IBAction) copyAction:(id)sender{
    NSString* txtMessage = @"";
    if (message.isEncrypted) {
        NSData* data = [Base64Security decodeBase64String:message.messageContent];
        data = [[AppFacade share] decryptDataLocally:data];
        if (data)
            txtMessage = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    else{
        txtMessage = message.messageContent;
    }
    [[ChatFacade share] copyToClipboard:txtMessage];
    [[ChatView share].bubbleScroll hidePopup];
}

-(IBAction) deleteAction:(id)sender{
    [[CAlertView new] showWarning:_WARNING_WANT_TO_DELETE_MESS_OR_NOT
                           TARGET:self
                           ACTION:@selector(deleteNow)];

    [[ChatView share].bubbleScroll hidePopup];
}
-(IBAction) forwardAction:(id)sender{
    if ([[ContactFacade share] isAccountRemoved]) {
        [[CAlertView new] showError:ERROR_ACCOUNT_REMOVED];
        return;
    }
    
    [[ChatFacade share] stopCurrentAudioPlaying:nil];
    [ForwardList share].forwardMessage = message;
    [[CWindow share] showPopup:[ForwardList share]];
    [[ChatView share].bubbleScroll hidePopup];
}

-(IBAction) saveAction:(id)sender{
    ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
    switch (status) {
        case ALAuthorizationStatusAuthorized:
            [[ChatFacade share] saveMediaToLibrary:message];
            break;
        case ALAuthorizationStatusDenied:
            [[CAlertView new] showError:_ERROR_DONT_HAVE_ACCESS_PHOTOS_LIBRARY];
            break;
        case ALAuthorizationStatusNotDetermined:
        {
            ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
            [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop){
                if(*stop){
                    [[ChatFacade share] saveMediaToLibrary:message];
                }
                *stop = TRUE;
            }failureBlock:^(NSError *error){
                [[CAlertView new] showError:_ERROR_DONT_HAVE_ACCESS_PHOTOS_LIBRARY];
            }];
        }
            break;
        case ALAuthorizationStatusRestricted:
            NSLog(@"ALAuthorizationStatusRestricted");
            break;
            
        default:
            break;
    }
    
    [[ChatView share].bubbleScroll hidePopup];
}

-(void) deleteNow{
    [NSTimer scheduledTimerWithTimeInterval:0.1
                                     target:[ChatFacade share]
                                   selector:@selector(destroyMessage:) userInfo:message.messageId
                                    repeats:NO];
}

-(void) showCopyButton{
    [btnCopy setTitle:_COPY forState:UIControlStateNormal];
    [btnCopy removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [btnCopy addTarget:self action:@selector(copyAction:) forControlEvents:UIControlEventTouchUpInside];
}

-(void) showSaveButton{
    [btnCopy setTitle:_SAVE forState:UIControlStateNormal];
    [btnCopy removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [btnCopy addTarget:self action:@selector(saveAction:) forControlEvents:UIControlEventTouchUpInside];
}

-(void) hideSaveButton{
    [btnCopy setFrame:CGRectZero];
    [btnForward changeXAxis:btnCopy.x YAxis:btnForward.y];
    [btnDelete changeXAxis:btnForward.width YAxis:btnDelete.y];
    [self changeWidth:btnDelete.width + btnForward.width Height:self.height];
}

-(void) hideForwardButton{
    [btnForward setFrame:CGRectZero];
    [btnDelete changeXAxis:btnCopy.width YAxis:btnDelete.y];
    [self changeWidth:btnDelete.width + btnCopy.width Height:self.height];
}

@end
