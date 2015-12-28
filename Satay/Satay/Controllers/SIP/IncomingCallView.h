//
//  IncomingCallView.h
//  KryptoChat
//
//  Created by Ba (Baker) V. NGUYEN on 7/30/14.
//  Copyright (c) 2014 mTouche. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IncomingCallView : UIViewController <SIPDelegate>

@property (weak, nonatomic) IBOutlet UILabel *lblFriendName;
@property (weak, nonatomic) IBOutlet UILabel *lblIncomingCall;
@property (weak, nonatomic) IBOutlet UIImageView *imgAvatar;
@property (weak, nonatomic) IBOutlet UIButton *btnDecline;
@property (weak, nonatomic) IBOutlet UIButton *btnAnswer;

@property (nonatomic, retain) NSString* userJid;

- (IBAction)action_Decline:(id)sender;
- (IBAction)action_Answer:(id)sender;

+(IncomingCallView *)share;
@end
