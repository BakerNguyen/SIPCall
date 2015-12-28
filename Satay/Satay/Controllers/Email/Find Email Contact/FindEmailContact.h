//
//  FindEmailContactViewController.h
//  Satay
//
//  Created by Arpana Sakpal on 3/17/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddFriendCounterButton.h"

@interface FindEmailContact : UIViewController <UISearchBarDelegate, UITableViewDelegate, ContactListDelegate> {
    id parent;
    IBOutlet UIView *viewAddContact;
    IBOutlet UILabel *lblNoContacts;
}

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tblView;
@property (weak, nonatomic) IBOutlet UILabel *lblNumber;

@property (weak, nonatomic) IBOutlet UIButton *btnSelectAll;
@property (weak, nonatomic) IBOutlet AddFriendCounterButton *btnAddContact;

@property (nonatomic, assign) BOOL isAddParticipants;
@property (nonatomic, retain) NSMutableArray* arrPaticipant;

/**
 *  Action click on button select all contacts
 *
 *  @param sender button select all
 *  @author Arpana
 *  date 19-Mar-2015
 */
- (IBAction)clickedBtnSelectAll:(id)sender;

/**
 *  Action click on button add selected contacts
 *
 *  @param sender button add
 *  @author Arpana
 *  date 19-Mar-2015
 */
- (IBAction)clickedBtnAddContact:(id)sender;

/**
 *  The designated initializer.  Override if you create the controller programmatically
 *  and want to perform customization that is not appropriate for viewDidLoad.
 *
 *  @param nibNameOrNil   nib name
 *  @param nibBundleOrNil bundle
 *  @param _parent        parent view
 *
 *  @return view controller
 *  @author Arpana
 */
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil parent:(id) _parent;

+(FindEmailContact *)share;

/**
 *  Get contacts data in database
 *
 *  @param contactArray array of contacts
 *  @author Trung VN
 *  date 9-Apr-2015
 */
- (void)reloadEmailContactList:(NSArray *)contactArray;

/**
 *  Get search result then display in UI
 *
 *  @param searchResult array contacts have name match search input
 *  @author William
 *  date 11-May-2015
 */
- (void) searchResult:(NSArray *)searchResult;

/**
 *  Create data from array contacts to display in UI
 *  @author William
 *  date 11-May-2015
 */
- (void) buildEmailContactsData;
@end
