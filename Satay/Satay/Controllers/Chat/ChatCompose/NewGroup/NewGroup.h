//
//  NewGroup.h
//  KryptoChat
//
//  Created by TrungVN on 4/22/14.
//  Copyright (c) 2014 mTouche. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "NavNewGroup.h"
#import "NewGroupCreate.h"


@interface NewGroup : UIViewController <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>

@property (nonatomic, retain) IBOutlet UIView* navBar;
@property (nonatomic, retain) IBOutlet UILabel* lblCounter;
@property (weak, nonatomic) IBOutlet UISearchBar *searchContact;


@property (weak, nonatomic) IBOutlet UITableView *tblFriends;
@property (nonatomic, retain) NSMutableArray* arrGroupFriend;

@property (nonatomic, retain) NSMutableArray* arrContact;
@property (nonatomic, retain) NSMutableArray* arrContactStore;

+(NewGroup *)share;

-(void) updateCounter;
-(void) nextCreateStep;

@end
