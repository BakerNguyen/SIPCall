//
//  PendingController.h
//  KryptoChat
//
//  Created by TrungVN on 4/17/14.
//  Copyright (c) 2014 mTouche. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContactPendingCell.h"

@interface ContactPending : UIViewController <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, retain) IBOutlet UITableView* tblPendingList;
@property (nonatomic, retain) NSMutableArray* arrPending;

+(ContactPending *)share;

-(void) displayPending:(NSArray*) pendingList;

@end
