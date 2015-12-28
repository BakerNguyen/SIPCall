//
//  CallTimeOutView.h
//  KryptoChat
//
//  Created by Nghia (William) T. VO on 3/9/15.
//  Copyright (c) 2015 mTouche. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CallTimeOutView : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *lblFriendName;
@property (weak, nonatomic) IBOutlet UILabel *lblCallStatus;
@property (weak, nonatomic) IBOutlet UIImageView *imgAvatar;
@property (weak, nonatomic) IBOutlet UIButton *btnMessage;
@property (weak, nonatomic) IBOutlet UIButton *btnRetry;
@property (weak, nonatomic) IBOutlet UIButton *btnCancel;

@property (nonatomic, retain) NSString* userJid;

- (IBAction)action_Message:(id)sender;
- (IBAction)action_Retry:(id)sender;
- (IBAction)action_Cancel:(id)sender;


+(CallTimeOutView *)share;
@end
