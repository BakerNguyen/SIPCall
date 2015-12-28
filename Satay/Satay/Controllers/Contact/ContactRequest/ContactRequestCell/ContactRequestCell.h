//
//  NewRequestCell.h
//  KryptoChat
//
//  Created by Kuan Khim Yoong on 5/9/14.
//  Copyright (c) 2014 mTouche. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContactRequestCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UIView* separateView;
@property (nonatomic, retain) IBOutlet UIButton* btnApprove;
@property (nonatomic, retain) IBOutlet UIButton* btnDeny;
@property (nonatomic, retain) IBOutlet UIImageView* imgAvatar;
@property (nonatomic, retain) IBOutlet UILabel* lblBuddyName;
@property (nonatomic, retain) NSString* cellJid;

-(IBAction)approveRequest:(id)sender;
-(IBAction)denyRequest:(id)sender;

@end
