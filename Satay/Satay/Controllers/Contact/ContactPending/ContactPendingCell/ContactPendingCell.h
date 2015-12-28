//
//  PendingControllerCellTableViewCell.h
//  KryptoChat
//
//  Created by Kuan Khim Yoong on 5/9/14.
//  Copyright (c) 2014 mTouche. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContactPendingCell : UITableViewCell <UIGestureRecognizerDelegate,UIActionSheetDelegate>

@property (nonatomic, retain) IBOutlet UILabel* lblName;
@property (nonatomic, retain) IBOutlet UIImageView* imgAvatar;
@property (strong, nonatomic) IBOutlet UIButton *btnDelete;
@property (nonatomic, retain) Request *requestObj;


@end
