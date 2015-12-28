//
//  ViewController.m
//  SIPDemo
//
//  Created by Daniel Nguyen on 4/13/15.
//  Copyright (c) 2015 mTouche. All rights reserved.
//

#import "ViewController.h"
#import "SIPFacade.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [SIPFacade share].SIPDelegate = self;
    //[[SIPFacade share] addProxyConfig:@"dallas1" password:@"Baker@123" domain:@"sip.linphone.org" port:5060 stunServer:@""];
    [[SIPAdapter share] addProxyConfig:@"satayuser2" password:@"0000" domain:@"ssdevsip.mtouche-mobile.com;transport=tls" port:5061 stunServer:@""];
}

- (void) viewWillAppear:(BOOL)animated {
    [[SIPFacade share] linphoneCallStateNotification];
    [[SIPFacade share] registrationUpdateNotification];
}

- (void) viewWillDisappear:(BOOL)animated {
    [[SIPFacade share] removeLinphoneCallStateNotification];
    [[SIPFacade share] removeRegistrationUpdateNotification];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnCall:(id)sender {
    [[SIPFacade share] makeAudioPhoneCall:@"sip:dallas2@sip.linphone.org"];
}

- (IBAction)btnAnswer:(id)sender {
    [[SIPFacade share] acceptCall];
}

- (IBAction)btnEndCall:(id)sender {
    [[SIPFacade share] endCall];
}

- (void) linphoneRegistrationState:(NSString *)registrationState {
    NSLog(@"State: %@", registrationState);
}

- (void) linphoneCallState:(NSString *)callState message:(NSString *)message {
    NSLog(@"State : %@ - Message: %@", callState, message);
}


@end
