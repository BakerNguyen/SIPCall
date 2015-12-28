//
//  ForwardList.h
//  Satay
//
//  Created by MTouche on 4/10/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ForwardList : UIViewController <UINavigationBarDelegate, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

@property (nonatomic, retain) Message* forwardMessage;
@property (nonatomic, retain) Contact* forwardContact;
@property (nonatomic, retain) NSMutableArray* arrFriend;
@property (nonatomic, retain) IBOutlet UITableView* tblContact;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;

-(void) reloadForwardList:(NSArray*) arrFriend;
-(void) forwardNow;

+ (ForwardList *)share;

@end
