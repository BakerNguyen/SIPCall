//
//  ViewController.h
//  SIPDemo
//
//  Created by Daniel Nguyen on 4/13/15.
//  Copyright (c) 2015 mTouche. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIDelegate.h"

@interface ViewController : UIViewController <SIPDelegate> 

- (IBAction)btnCall:(id)sender;
- (IBAction)btnAnswer:(id)sender;
- (IBAction)btnEndCall:(id)sender;

@end

