//
//  EditChatList.h
//  KryptoChat
//
//  Created by TrungVN on 4/24/14.
//  Copyright (c) 2014 mTouche. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatEdit : UIViewController

@property (nonatomic, strong) NSArray *arrChatBoxStore;

+(ChatEdit *)share;

-(void) cancelView;
-(void) doneView;

@end
