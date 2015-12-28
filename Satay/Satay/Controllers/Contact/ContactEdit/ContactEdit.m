//
//  EditContact.m
//  KryptoChat
//
//  Created by TrungVN on 4/17/14.
//  Copyright (c) 2014 mTouche. All rights reserved.
//

#import "ContactEdit.h"

#import "ContactList.h"

@interface ContactEdit ()

@end

@implementation ContactEdit{
    ContactList* contactList;
}

+(ContactEdit *)share{
    static dispatch_once_t once;
    static ContactEdit * share;
    dispatch_once(&once, ^{
        share = [self new];
    });
    return share;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = TITLE_EDIT_CONTACTS;
    
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem createLeftButtonTitle:_CANCEL Target:self Action:@selector(cancelView)];
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem createRightButtonTitle:_DONE Target:self Action:@selector(deleteFriend)];
    
    contactList = [ContactList share];
}

-(void) viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    [contactList.arrDeleteContacts removeAllObjects];
    [contactList.tblContact changeXAxis:0 YAxis:0];
    [self.view addSubview:contactList.tblContact];
    
    [contactList.tblContact reloadData];
    contactList.tblContact.editing = TRUE;
    contactList.canDelete = YES;
    contactList.tblContact.tableHeaderView = NULL;
    [contactList.tblContact setContentOffset:CGPointMake(0, 0)];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self cancelView];
}

-(void) cancelView{
    contactList.tblContact.editing = FALSE;
    [contactList.notification movingHeight];
    [contactList.header checkDevider];
    contactList.tblContact.tableHeaderView = contactList.header;
    [contactList.view addSubview:contactList.tblContact];
    [contactList.tblContact setContentOffset:CGPointMake(0, 0)];
    [contactList.tblContact changeXAxis:0 YAxis:contactList.notification.height];
    
    [contactList.navigationController popViewControllerAnimated:YES];
}

-(void) deleteFriend
{
    //code delete here;
    for (Contact *contact in contactList.arrDeleteContacts) {
        [[ContactFacade share] deleteFriend:contact.jid];
    }
    
    //[self cancelView];
}

@end
