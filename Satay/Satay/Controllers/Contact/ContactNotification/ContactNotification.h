//
//  NotificationView.h
//  KryptoChat
//
//  Created by TrungVN on 4/16/14.
//  Copyright (c) 2014 mTouche. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContactNotification : UIView<ContactNotificationDelegate>

@property (nonatomic, retain) IBOutlet UIView* internetView;
@property (nonatomic, retain) IBOutlet UILabel* lblInternet;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView* connectLoading;

@property (nonatomic, retain) IBOutlet UIView* notifiView;
@property (nonatomic, retain) IBOutlet UILabel* lblNotif;

-(void) showNoInternet:(NSString*) notifyContent;
-(void) showNotifiView:(NSString*) notifyContent;
-(void) hideInternetView:(int) type;
-(void) hideNotification;
-(void) showConnecting;
-(void) movingHeight;

@end
