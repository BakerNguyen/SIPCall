//
//  SideBar.h
//  KryptoChat
//
//  Created by TrungVN on 4/3/14.
//  Copyright (c) 2014 mTouche. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MenuHeader.h"

@interface SideBar : UIViewController <UITableViewDelegate, UITableViewDataSource, SideBarDelegate>

@property (strong, nonatomic) IBOutlet UIImageView *bgImage;
@property (nonatomic, retain) IBOutlet UITableView* tblMenu;
@property (nonatomic, retain) IBOutlet MenuHeader* menuHeader;
@property (nonatomic, retain) NSMutableArray* arrMenu;
@property NSInteger selectedIndex;

-(void) reloadNotificationCount:(NSInteger)count MenuID:(NSInteger)menuID;

+(SideBar *)share;

@end
