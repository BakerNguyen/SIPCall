//
//  EditInbox.h
//  Satay
//
//  Created by Arpana Sakpal on 3/17/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditInbox : UIViewController <UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate>

@property (nonatomic, strong) CAlertView *alertView;

@property (weak, nonatomic) IBOutlet UITableView *tblEditInbox;

@property (assign, nonatomic) EmailSortingType sortingType;
@property (strong, nonatomic) NSMutableArray *fectchEmail;
@property NSInteger folderIndex;

/**
 *  Action click on button delete email
 *
 *  @param sender button delete
 *  @author Arpana
 *  date 23-Mar-2015
 */
- (IBAction)clickedBtnDelete:(id)sender;

/**
 *  Action click on button move email to other folder
 *
 *  @param sender button move
 *  @author Arpana
 *  date 23-Mar-2015
 */
- (IBAction)clickedBtnMove:(id)sender;

/**
 *  Action click on button select all emails
 *
 *  @param sender button select all
 *  @author Arpana
 *  date 23-Mar-2015
 */
- (IBAction)selectAllEmail:(id) sender;


@end
