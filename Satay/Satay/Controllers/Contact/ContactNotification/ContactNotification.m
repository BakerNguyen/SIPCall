//
//  NotificationView.m
//  KryptoChat
//
//  Created by TrungVN on 4/16/14.
//  Copyright (c) 2014 mTouche. All rights reserved.
//

#import "ContactNotification.h"
#import "NotificationController.h"
#import "ContactList.h"

@implementation ContactNotification

@synthesize internetView, notifiView;
@synthesize lblInternet, lblNotif, connectLoading;

-(void) willMoveToSuperview:(UIView *)newSuperview{
    [XMPPFacade share].contactNotificationDelegate = self;
    [NotificationFacade share].contactNotificationDelegate = self;
    [ContactFacade share].contactNotificationDelegate = self;
    
    [self addTapRecognize];
    
    CGFloat originTableHeight = [ContactList share].tblContact.frame.size.height;
    [self hideInternetView:InternetViewTypeGeneral];
    [self hideNotification];
    [[ContactList share].tblContact changeWidth:[ContactList share].tblContact.width
                                         Height:originTableHeight];
}

-(void) showNoInternet:(NSString*) notifyContent{
    connectLoading.hidden = TRUE;
    lblInternet.tag = ([notifyContent isEqual:NO_INTERNET_CONNECTION_MESSAGE] ?
                       InternetViewTypeNoInternetConnection : InternetViewTypeNoServerConnection);
    lblInternet.text = notifyContent;
    internetView.backgroundColor = INTERNET_NO_CONNECT_BG;
    [internetView changeWidth:internetView.width Height:32];

    if([ContactList share].navigationController.navigationBarHidden)
        return;
    
    [self movingHeight];
}

-(void) showConnecting{
    connectLoading.hidden = FALSE;
    lblInternet.tag = InternetViewTypeConnectingXMPP;
    lblInternet.text = CONNECTING_MESSAGE;
    internetView.backgroundColor = INTERNET_CONNECTING_BG;
    [internetView changeWidth:internetView.width Height:32];
    
    if([ContactList share].navigationController.navigationBarHidden)
        return;
    
    [self movingHeight];
}


-(void) showNotifiView:(NSString*) notifSentence{
    lblNotif.text = notifSentence;

    if(lblNotif.frame.size.height < 43)
        [lblNotif changeWidth:notifiView.frame.size.width Height:43];
    else
        [lblNotif changeWidth:notifiView.frame.size.width Height:lblNotif.height];
    
    [notifiView changeWidth:notifiView.width Height:lblNotif.height];
    
    if([ContactList share].navigationController.navigationBarHidden)
        return;
    
    [self movingHeight];
}

-(void) hideInternetView:(int) type{
    switch (type) {
        case InternetViewTypeConnectingXMPP:
            if([lblInternet.text isEqual:CONNECTING_MESSAGE])
                [self hideInternet];
            break;
            
        case InternetViewTypeNoInternetConnection:
            if([lblInternet.text isEqual:NO_INTERNET_CONNECTION_MESSAGE])
                [self hideInternet];
            break;
            
        case InternetViewTypeNoServerConnection:
            if([lblInternet.text isEqual:NO_SERVER_CONNECTION_MESSAGE])
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

-(void) hideNotification{
    [notifiView changeWidth:notifiView.width Height:0.0];
    [self movingHeight];
}

-(void) movingHeight{
    // return if tlbContact is editing
    if([ContactList share].tblContact.editing == TRUE)
       return;
    
    [internetView changeXAxis:0 YAxis:0];
    [notifiView changeXAxis:0 YAxis:internetView.height];
    
    CGFloat oldHeight = self.height;
    [self animateWidth:self.width
                Height:internetView.height + notifiView.height];
    [[ContactList share].tblContact animateXAxis:0
                                           YAxis:self.height];
    CGFloat changeHeight = self.height - oldHeight;
    [[ContactList share].tblContact changeWidth:[ContactList share].tblContact.width
                                         Height:[ContactList share].tblContact.height + (-changeHeight)];
}

#pragma mark notifiView tap recognize

- (void)addTapRecognize
{
    UITapGestureRecognizer *notifyViewTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleNotifyViewTap)];
    notifyViewTapRecognizer.numberOfTouchesRequired = 1;
    notifyViewTapRecognizer.numberOfTapsRequired = 1;
    [notifiView addGestureRecognizer:notifyViewTapRecognizer];
}

- (void) handleNotifyViewTap{
    [self hideNotification];
    
    if([self.lblNotif.text isEqualToString:HAVE_NEW_NOTIFICATION_MESSAGE]){
        [[ContactList share].navigationController pushViewController:[NotificationController share] animated:YES];
    }
}



@end
