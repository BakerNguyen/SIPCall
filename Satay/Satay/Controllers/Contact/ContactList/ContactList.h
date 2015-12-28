//
//  ContactList.h
//  Satay
//
//  Created by TrungVN on 1/15/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ContactCell.h"
#import "ContactNotification.h"
#import "ContactHeader.h"
#import "ContactPopup.h"
#import "ContactNotSync.h"
#import "ContactBook.h"

@interface ContactList : UIViewController <UITableViewDataSource, UITableViewDelegate,
ContactListDelegate>

@property (nonatomic, retain) IBOutlet UITableView* tblContact;
@property (nonatomic, retain) IBOutlet ContactNotification* notification;
@property (nonatomic, retain) IBOutlet ContactHeader* header;
@property (nonatomic, retain) NSMutableArray* arrContact;
@property (weak, nonatomic) IBOutlet UILabel *lbNoUserFound;
@property (weak, nonatomic) IBOutlet UIButton *btnTapToAdd;
@property (strong, nonatomic) IBOutlet UILabel *lblNoContacts;

@property (nonatomic, assign) BOOL canDelete;
@property (nonatomic, retain) NSMutableArray* arrDeleteContacts;

-(void) addFriend;
-(void) reloadContactList:(NSArray*) contactArray;
-(void) reloadSearchContactList:(NSArray*) contactArray;
+(ContactList *)share;

@end