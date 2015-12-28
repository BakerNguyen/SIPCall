//
//  NotificationController.h
//  Satay
//
//  Created by Arpana Sakpal on 1/20/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IncomingNotification.h"
@interface NotificationController : UIViewController<UITableViewDelegate,UITableViewDataSource, NotificationListDelegate>
@property (retain, nonatomic) IBOutlet UITableView *tblNotificationList;

@property (retain, nonatomic) UILabel* notificationView;
@property (weak, nonatomic) IBOutlet UILabel *lblNoNotification;

@property(nonatomic,retain) IncomingNotification *incomingNotification;

+(NotificationController *)share;

/**
 *  Reload Notification page
 *  Author: Violet
 */
- (void) reloadNotificationPage;

@end
