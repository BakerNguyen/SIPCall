//
//  LogInFirstScreen.h
//  Satay
//
//  Created by Parker on 2/2/15.
//  Copyright (c) 2014 mTouche. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CWindow.h"
@interface LogInFirstScreen : UIViewController<UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *btnGetStarted;
@property (weak, nonatomic) IBOutlet UIButton *btnLogIn;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

- (IBAction)getStarted;

- (IBAction)login:(id)sender;

+(LogInFirstScreen *)share;

@end
