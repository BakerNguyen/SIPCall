//
//  SecureNotesView.h
//  Satay
//
//  Created by Arpana Sakpal on 2/9/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CreateNewNote.h"
#import "SecNoteListCell.h"

@interface SecNoteList : UIViewController<UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate>

@property (strong, nonatomic) IBOutlet UILabel *lblEmptyNote;
@property (strong, nonatomic) IBOutlet UITableView *tblSecureNote;
@property (strong, nonatomic) IBOutlet UIView *headerView;

@property (strong, nonatomic) UIActionSheet * actionSheetEncrypt;
@property (strong, nonatomic) NSMutableArray *arrSecureNotes;

+(SecNoteList *)share;

-(void) createNewNote;
-(void) reloadNoteList:(NSArray*) arrNote;
-(void) showMore;

@end
