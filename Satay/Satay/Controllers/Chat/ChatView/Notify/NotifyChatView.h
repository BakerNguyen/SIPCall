//
//  NotifyChatView.h
//  KryptoChat
//
//  Created by TrungVN on 6/20/14.
//  Copyright (c) 2014 mTouche. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NotifyChatView : UIView

@property (nonatomic, retain) IBOutlet UIView* redAlert;
@property (nonatomic, retain) IBOutlet UILabel* lblRed;
@property (nonatomic, retain) IBOutlet UIView* blueAlert;
@property (nonatomic, retain) IBOutlet UILabel* lblBlue;
@property CGFloat originScrollHeight;

-(void) showRedAlert:(NSString*) alertMessage;
-(void) showBlueAlert:(NSString*) alertMessage;
-(void) hideRedAlert;
-(void) hideBlueAlert;

-(void) redrawNotify;

@end
