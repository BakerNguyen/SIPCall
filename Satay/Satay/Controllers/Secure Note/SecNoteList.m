//
//  SecureNotesView.m
//  Satay
//
//  Created by Arpana Sakpal on 2/9/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import "SecNoteList.h"


@interface SecNoteList ()

@end

@implementation SecNoteList
@synthesize lblEmptyNote;
@synthesize tblSecureNote,headerView;
@synthesize actionSheetEncrypt;
@synthesize arrSecureNotes;

+(SecNoteList *)share
{
    static dispatch_once_t once;
    static SecNoteList *share;
    dispatch_once(&once, ^{
        share = [self new];
    });
    return share;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [SecureNoteFacade share].secNoteListDelegate = self;

    self.title = TITLE_SECURE_NOTES;
    arrSecureNotes = [NSMutableArray new];
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem createRightButtonTitle:_MORE Target:self Action:@selector(showMore)];
    [tblSecureNote setTableHeaderView:headerView];
    
    UITapGestureRecognizer *tapHeader = [[UITapGestureRecognizer alloc]initWithTarget:self
                                                                               action:@selector(createNewNote)];
    [headerView addGestureRecognizer:tapHeader];
    tblSecureNote.hidden = NO;
}

-(void) viewWillAppear:(BOOL)animated{
    [[SecureNoteFacade share] showNoteList];
    [[LogFacade share] trackingScreen:SecureNote_Category];
}

-(void) reloadNoteList:(NSArray*) arrNote{
    arrSecureNotes = [arrNote mutableCopy];
    [tblSecureNote reloadData];
    [self setRightNavigationButton];
    lblEmptyNote.hidden = self.navigationItem.rightBarButtonItem.enabled = ([arrSecureNotes count] != 0);
}

-(void)setRightNavigationButton
{
    SEL selector = NULL;
    if (arrSecureNotes.count > 0)
        selector = @selector(showMore);
    
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem createRightButtonTitle:_MORE
                                                                              Target:self
                                                                              Action:selector];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [[SecureNoteFacade share] setDisplayMode:![[SecureNoteFacade share] displayMode]];
        [tblSecureNote reloadData];
    }
}

-(void) createNewNote{
    [CreateNewNote share].fileName = @"";
    [[CWindow share] showPopup:[CreateNewNote share]];
    [[LogFacade share] createEventWithCategory:SecureNote_Category
                                           action:createEditNote_Action
                                            label:labelAction];
    NSDictionary *logDic = @{
                             LOG_CLASS : NSStringFromClass(self.class),
                             LOG_CATEGORY: @"CATEGORY_SECURENOTE",
                             LOG_MESSAGE: @"BEGIN CREATE NOTE",
                             LOG_EXTRA1: @"",
                             LOG_EXTRA2: @""
                             };
    [[LogFacade share] logInfoWithDic:logDic];
}

-(void)showMore{
    NSString* buttonTitle = @"";
    if ([[SecureNoteFacade share] displayMode])
        buttonTitle = _DECRYPT_NOTES;
    else
        buttonTitle = _ENCRYPT_NOTES;
    actionSheetEncrypt = [[UIActionSheet alloc]initWithTitle:nil
                                                    delegate:self
                                           cancelButtonTitle:_CANCEL
                                      destructiveButtonTitle:nil
                                           otherButtonTitles:buttonTitle, nil];
    [actionSheetEncrypt showInView:self.view];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark UITableView delegate
////////////////////////////////////////////////////////////////////////////////////////////////////
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [arrSecureNotes count];
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    SecureNote* secureNote = [arrSecureNotes objectAtIndex:indexPath.row];
    if (secureNote) {
        [CreateNewNote share].fileName = secureNote.fileName;
        [[CWindow share] showPopup:[CreateNewNote share]];
        [[LogFacade share] createEventWithCategory:SecureNote_Category
                                               action:encryptNote_Action
                                             label:labelAction];
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellId = @"SecNoteListCell";
    SecNoteListCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    
    if(!cell){
        NSArray *nib=[[NSBundle mainBundle]loadNibNamed:cellId owner:self options:nil];
        cell = (SecNoteListCell *)[nib objectAtIndex:0];
    }
    
    SecureNote* secNote = [arrSecureNotes objectAtIndex:indexPath.row];
    if (secNote) {
        if ([[SecureNoteFacade share] displayMode])
            cell.lblName.text = secNote.descContentEnc;
        else
            cell.lblName.text = secNote.descContentNormal;
        
        NSString *updateTSDate = [ChatAdapter convertDateToString: secNote.updateTS format:FORMAT_DATE];
        NSString *today = [ChatAdapter convertDateToString:[[NSNumber alloc] initWithInteger:[NSDate date].timeIntervalSince1970] format:FORMAT_DATE];
        
        if([updateTSDate isEqual:today]){
            cell.lblTimeStamp.text = [ChatAdapter convertDateToString:secNote.updateTS
                                                               format:FORMAT_FULL_TIME];
        }
        else{
            cell.lblTimeStamp.text = [ChatAdapter convertDateToString:secNote.updateTS
                                                               format:FORMAT_FULL_DATE];
        }
        
        cell.secNoteId = secNote.fileName;
    }
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        SecNoteListCell* cell = (SecNoteListCell*)[tableView cellForRowAtIndexPath:indexPath];
        if (cell) {
            [[SecureNoteFacade share] deleteNote:cell.secNoteId];
        }
    }
}
@end
