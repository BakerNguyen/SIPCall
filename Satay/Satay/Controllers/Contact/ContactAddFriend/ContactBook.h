//
//  ContactListViewController.h
//  JuzChatV2
//
//  Created by Kerjin on 30/10/12.
//  Copyright (c) 2012 mTouche. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <AddressBookUI/AddressBookUI.h>
#import "ContactSearchMID.h"
#import "ContactBookCell.h"
#import "AddFriendHeader.h"
#import "AddFriendCounterButton.h"
#import "CView.h"
#import "ContactList.h"
#import "CWindow.h"

@class AddFriendHeader;

@interface ContactBook : UIViewController

<UITableViewDelegate,UITableViewDataSource,UINavigationBarDelegate,UITableViewDelegate,
ABPeoplePickerNavigationControllerDelegate, UIGestureRecognizerDelegate
, MFMessageComposeViewControllerDelegate, ContactBookDelegate>


@property (nonatomic, retain) IBOutlet UITableView* tblPhoneBook;
@property (retain, nonatomic) IBOutlet UIScrollView *scrollview;
@property (retain, nonatomic) IBOutlet UITableView *tblMemberPhoneBook;
@property (nonatomic, strong) IBOutlet AddFriendHeader *headerTBLContact;
@property (strong, nonatomic) IBOutlet AddFriendCounterButton *addFriendCounter;
@property (strong, nonatomic) IBOutlet UILabel *lblNoUserFound;
@property (strong, nonatomic) IBOutlet UILabel *lblNoContacts;

@property (strong, nonatomic) IBOutlet UIView *headerContactView;

@property (strong, nonatomic) IBOutlet UIView *addFriendview;

-(void)getDataForDisplaying;

-(void) selectAll;
-(void) displayLabelNoContact;
-(void) fixTableDisplay;
-(void) moveToSearchMaskingID;
-(void) reloadSearchContactPhoneBook:(NSMutableDictionary*) arrResultContactPhoneBook;
-(void) reloadSearchMemberContact:(NSArray*) arrResultMemberContact;
-(void) updateLabelCounter;

-(void) fixsearchScrollView;
-(void) fixnormalScrollView;
-(void) fixTableWhenSearch;

+(ContactBook *)share;

@end
