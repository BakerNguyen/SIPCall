//
//  SelfTimer.h
//  KryptoChat
//
//  Created by TrungVN on 5/30/14.
//  Copyright (c) 2014 mTouche. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SelfTimerCell.h"

@interface SelfTimer : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, retain) IBOutlet UITableView* tblTimer;

@property (nonatomic, retain) IBOutlet UIView* footerView;
@property (nonatomic, retain) IBOutlet UIImageView* footerTick;

@property int tempTimer;
@property int destroyTimer;
@property BOOL tempDestroyAllMessage;
@property BOOL destroyAllMessage;
@property (nonatomic, retain) NSMutableArray* arrTimer;

-(void) closeView;
-(void) doneSetTimer;

-(void) drawFooter;
-(void) applyToAll;

+ (SelfTimer *)share;

@end
