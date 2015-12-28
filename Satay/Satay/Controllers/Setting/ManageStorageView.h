//
//  ManageStorageView.h
//  Satay
//
//  Created by Nghia (William) T. VO on 5/18/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ManageStorageCell.h"
#import "AddFriendCounterButton.h"

@interface ManageStorageView : UIViewController<UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tblStorage;
@property (strong, nonatomic) IBOutlet UILabel *lblStorageClear;
@property (strong, nonatomic) IBOutlet AddFriendCounterButton *btnDelete;
@end
