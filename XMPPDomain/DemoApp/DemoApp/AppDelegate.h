//
//  AppDelegate.h
//  DemoApp
//
//  Created by Daniel Nguyen on 12/30/14.
//  Copyright (c) 2014 mTouche. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XMPPDomain/XMPPDomain.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, XMPPDomainDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) XMPPAdapter *xmppAdapter;

@end

