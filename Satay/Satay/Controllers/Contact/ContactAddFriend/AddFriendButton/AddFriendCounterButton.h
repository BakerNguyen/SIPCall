//
//  AddFriendButton.h
//  KryptoChat
//
//  Created by Kuan Khim Yoong on 5/9/14.
//  Copyright (c) 2014 mTouche. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddFriendCounterButton : UIView

@property (retain, nonatomic) IBOutlet UIButton *btnAddRequest;

@property (nonatomic, assign) BOOL isAddButton;

-(void)setButtonTitle: (NSString*) lblTitle;

@end
