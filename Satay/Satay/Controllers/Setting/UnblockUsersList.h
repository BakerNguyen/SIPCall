//
//  UnblockUsersList.h
//  Satay
//
//  Created by Vi (Violet) T.T. DAO on 5/14/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BlockUsersController.h"
@interface UnblockUsersList : UIViewController<UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tblUnblockUser;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;

@property (weak, nonatomic) IBOutlet UILabel *lblNoContact;

@property (nonatomic, retain) NSMutableArray* arrUnblockUser;
-(void) reloadUnblockList:(NSArray*) unblockArr;
-(void) reloadUnblockUserSearchList:(NSArray*) unblockArray;

+(UnblockUsersList*)share;

@end
