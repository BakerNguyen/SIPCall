//
//  ChatListNotification.h
//  Satay
//
//  Created by Vi (Violet) T.T. DAO on 5/5/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatListNotification : UIView<ContactNotificationDelegate>

@property (nonatomic, retain) IBOutlet UIView* internetView;
@property (nonatomic, retain) IBOutlet UILabel* lblInternet;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView* connectLoading;


-(void) showNoInternet:(NSString*) notifyContent;
-(void) hideInternetView:(int) type;
-(void) showConnecting;
-(void) movingHeight;

@end
