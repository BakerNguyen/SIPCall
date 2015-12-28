//
//  NtificationRequestViewCell.h
//  Satay
//
//  Created by Arpana Sakpal on 1/20/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import <UIKit/UIKit.h>

#define SCALE 2.0f
#define HEIGHT_CELL 149.0f

@interface NotificationRequestViewCell : UITableViewCell


@property (retain, nonatomic) IBOutlet UILabel *notifyContent;
@property (retain, nonatomic) IBOutlet UIImageView *profileImage;

@property (retain, nonatomic) NoticeBoard *noticeBoard;

@end
