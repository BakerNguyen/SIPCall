//
//  EmailInbox.h
//  Satay
//
//  Created by Arpana Sakpal on 3/10/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EmailInbox : UIViewController<UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tblInbox;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UILabel *lblMailBoxEmpty;
@property (strong, nonatomic) IBOutlet UILabel *lblHintDescription;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topSpacing;


/**
 *  Action click on button compose email
 *
 *  @param sender button compose
 *  @author Arpana
 *  date 13-Mar-2015
 */
- (IBAction)clickedBtnCompose:(id)sender;

/**
 *  Action click on button sort email
 *
 *  @param sender button sort
 *  @author Arpana
 *  date 13-Mar-2015
 */
- (IBAction)clickedBtnSortBy:(id)sender;

/**
 *  Action click on button view all folder
 *
 *  @param sender button all folder
 *  @author Arpana
 *  date 13-Mar-2015
 */
- (IBAction)clickedBtnAllFolder:(id)sender;
@property (strong, nonatomic) IBOutlet UIView *viewHeader;
@property (strong, nonatomic) IBOutlet UILabel *lblTitle;
@property (strong, nonatomic) IBOutlet UILabel *lblDate;

@property NSInteger folderIndex;

+ (EmailInbox *)share;

@end
