//
//  SyncContacts.h
//  KryptoChat
//
//  Created by ENCLAVEIT on 4/23/14.
//  Copyright (c) 2014 mTouche. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CountryList.h"
#import "Verification.h"
#import "CWindow.h"

@interface SyncContacts : UIViewController<UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>{

}

@property (strong, nonatomic) UILabel *lblPreNumberPhone;
@property (strong, nonatomic) UITextField *txtNumPhone;
@property (strong, nonatomic) UIView *paddingView;

@property (strong, nonatomic) IBOutlet UITableView *tblSyncContact;

@property (nonatomic,retain) CountryList *countryListViewController;
@property (nonatomic,retain) Verification *verificationViewController;

@property (strong, nonatomic) NSString *countryName;
@property (strong, nonatomic) NSString *countryCode;
@property (strong, nonatomic) NSString *dialCode;
@property (strong, nonatomic) NSString *phoneNumber;

-(void) setCountryConfig;
-(void)showKeyboard;
-(void) setupPresentCountryData:(NSDictionary *) countryData;

+(SyncContacts *)share;

@end
