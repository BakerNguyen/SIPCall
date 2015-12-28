//
//  NotSyncView.m
//  KryptoChat
//
//  Created by TrungVN on 5/29/14.
//  Copyright (c) 2014 mTouche. All rights reserved.
//

#import "ContactNotSync.h"

#import "CWindow.h"
#import "ContactSearchMID.h"
#import "MyProfile.h"

@interface ContactNotSync ()

@end

@implementation ContactNotSync

@synthesize syncView;
@synthesize searchView;
@synthesize contentCell, labelCell, labelPrivateContact;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title =TITLE_ADD_FRIENDS;
    hintTextColor = COLOR_128128128;
    [searchView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self
                                                                             action:@selector(tapSearch)]];
    
    [syncView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self
                                                                           action:@selector(tapSyncPhone)]];
    
    [ContactFacade share].contactNotSyncDelegate = self;
}

-(void) viewWillAppear:(BOOL)animated{
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem createLeftButtonTitle:_BACK
                                                                            Target:self.navigationController
                                                                            Action:@selector(popToRootViewControllerAnimated:)];
    
    if (![[ContactFacade share] getSyncContactFlag] ) {
        labelCell.text = LABEL_OFF;
        labelPrivateContact.text = @"";
        contentCell.text = LABEL_SYNC_CONTACTS;
        if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusDenied){
            labelCell.text = LABEL_DISABLE;
            contentCell.text = LABEL_MOBILE_CONTACTS;
            labelPrivateContact.text = [NSString stringWithFormat:@"%@%@",CONSENT_CONTACT,LABEL_ENABEL_ACCESS_TO_YOUR_CONTACTS_IN_IPHONE];
        }
    }
    else
        if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusDenied){
            labelPrivateContact.text = [NSString stringWithFormat:@"%@%@",CONSENT_CONTACT,LABEL_ENABEL_ACCESS_TO_YOUR_CONTACTS_IN_IPHONE];
            labelCell.text = LABEL_DISABLE;
        }
    
    labelPrivateContact.textColor = hintTextColor;
    labelPrivateContact.font = [UIFont systemFontOfSize:FONT_TEXT_SIZE_14];
    labelCell.textColor = hintTextColor;

}

-(void) tapSearch{
    [[self navigationController] pushViewController:[ContactSearchMID share] animated:YES];
}

-(void) tapSyncPhone{
    if ([[ContactFacade share] isAccountRemoved]) {
        [[CAlertView new] showError:ERROR_ACCOUNT_REMOVED];
        return;
    }
    
    if (![[ContactFacade share] getSyncContactFlag]) {
        
        if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusDenied)
            return;
        else if(ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined){
            // Request authorization to Address Book
            ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
            ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
                if (granted) {
                    // First time access has been granted, add the contact
                    NSOperationQueue *mainQueue = [NSOperationQueue mainQueue];
                    [mainQueue addOperationWithBlock:^{
                        [[CWindow share] showPopup:[MyProfile share]];
                        [[MyProfile share] moveToSyncContact];
                        [self.navigationController popToRootViewControllerAnimated:NO];
                    }];
                }
                else
                {
                    labelPrivateContact.text = [NSString stringWithFormat:@"%@%@",CONSENT_CONTACT,LABEL_ENABEL_ACCESS_TO_YOUR_CONTACTS_IN_IPHONE];
                    labelCell.text = LABEL_DISABLE;
                    NSLog(@"User Not allow > Contacts Phonebook ");
                }
            });
        }
        else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized){
            [[CWindow share] showPopup:[MyProfile share]];
            [[MyProfile share] moveToSyncContact];
            [self.navigationController popToRootViewControllerAnimated:NO];
        }
    }
}


+(ContactNotSync *)share{
    static dispatch_once_t once;
    static ContactNotSync * share;
    dispatch_once(&once, ^{
        share = [self new];
    });
    return share;
}

@end
