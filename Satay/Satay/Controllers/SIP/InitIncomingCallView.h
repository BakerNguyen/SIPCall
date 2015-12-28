//
//  InitIncomingCallView.h
//  KryptoChat
//
//  Created by Ba (Baker) V. NGUYEN on 11/4/14.
//  Copyright (c) 2014 mTouche. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InitIncomingCallView : UIViewController <SIPDelegate, InitIncomingCallViewDelegate>

@property (nonatomic, retain) NSString* userJid;

+(InitIncomingCallView *)share;

@end
