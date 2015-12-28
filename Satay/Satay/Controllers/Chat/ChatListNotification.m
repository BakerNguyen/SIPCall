//
//  ChatListNotification.m
//  Satay
//
//  Created by Vi (Violet) T.T. DAO on 5/5/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//


#import "ContactNotification.h"
#import "NotificationController.h"
#import "ContactList.h"
#import "ChatList.h"
#import "ChatEdit.h"

@implementation ChatListNotification

@synthesize internetView;
@synthesize lblInternet, connectLoading;

-(void) willMoveToSuperview:(UIView *)newSuperview{
    [XMPPFacade share].chatListNotificationDelegate = self;
    [NotificationFacade share].chatListNotificationDelegate = self;
    
    CGFloat originTableHeight = [ChatList share].tblChatHistory.height;
    [self hideInternetView:InternetViewTypeGeneral];
    [[ChatList share].tblChatHistory changeWidth:[ChatList share].tblChatHistory.width
                                          Height:originTableHeight];
}

-(void) showNoInternet:(NSString*) notifyContent{
    connectLoading.hidden = TRUE;
    lblInternet.tag = ([notifyContent isEqual:NO_INTERNET_CONNECTION_MESSAGE] ?
                       InternetViewTypeNoInternetConnection : InternetViewTypeNoServerConnection);
    lblInternet.text = notifyContent;
    internetView.backgroundColor = INTERNET_NO_CONNECT_BG;
    [internetView changeWidth:internetView.width Height:32];
    
    if([ChatList share].navigationController.navigationBarHidden)
        return;
    
    [self movingHeight];
}

-(void) showConnecting{
    connectLoading.hidden = FALSE;
    lblInternet.tag = InternetViewTypeConnectingXMPP;
    lblInternet.text = CONNECTING_MESSAGE;
    internetView.backgroundColor = INTERNET_CONNECTING_BG;
    [internetView changeWidth:internetView.width Height:32];
    
    if([ChatList share].navigationController.navigationBarHidden)
        return;
    
    [self movingHeight];
}

-(void) hideInternetView:(int) type{
    switch (type) {
        case InternetViewTypeConnectingXMPP:
            if(lblInternet.tag == InternetViewTypeConnectingXMPP)
                [self hideInternet];
            break;
            
        case InternetViewTypeNoInternetConnection:
            if(lblInternet.tag == InternetViewTypeNoInternetConnection)
                [self hideInternet];
            break;
            
        case InternetViewTypeNoServerConnection:
            if(lblInternet.tag == InternetViewTypeNoServerConnection)
                [self hideInternet];
            break;

        default:
            [self hideInternet];
            break;
    }
}

-(void) hideInternet{
    [internetView changeWidth:internetView.width Height:0.0];
    [self movingHeight];
}


-(void) movingHeight{
    // return if Edit chat page is showing
    if([ChatEdit share].navigationController)
        return;
    
    CGFloat oldHeight = self.height;
    [self animateWidth:self.width
                Height:internetView.height];
    [[ChatList share].tblChatHistory animateXAxis:0
                                            YAxis:self.height];
    CGFloat changeHeight = self.height - oldHeight;
    [[ChatList share].tblChatHistory changeWidth:[ChatList share].tblChatHistory.width
                                          Height:[ChatList share].tblChatHistory.height + (-changeHeight)];
}


@end

