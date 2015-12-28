//
//  UIDelegate.h
//  SIPDemo
//
//  Created by Ba (Baker) V. NGUYEN on 5/5/15.
//  Copyright (c) 2015 mTouche. All rights reserved.
//

//SIP Delegate
@protocol SIPDelegate

@optional
-(void) linphoneCallState:(NSString*) callState message:(NSString*) message;
-(void) linphoneRegistrationState:(NSString*) registrationState;
-(void) linphoneTextReceivedEvent:(NSString*) textReceived;
@end