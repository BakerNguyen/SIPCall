//
//  BlockUsersController.h
//  Satay
//
//  Created by Vi (Violet) T.T. DAO on 5/13/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BlockUsersController : UIViewController<UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UITableView *tblBlockUsers;
@property (strong, nonatomic) IBOutlet UIView *footerView;
@property (strong, nonatomic) IBOutlet UIView *addNewView
;
@property (strong, nonatomic) NSMutableArray* arrBlockUser;
-(void) reloadBlockList:(NSArray*) blockArr;

/*
 * Description: add contact into block list and reload
 * Author: Jurian
 */
- (void) addUnblockUserToArray:(Contact*)contactItem;

/*
 * Description: remove contact into block list  and reload
* Author: Jurian
 */
- (void) removeUnblockUserToArray:(Contact*)contactItem;
+(BlockUsersController*)share;

@end
