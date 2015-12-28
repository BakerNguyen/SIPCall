//
//  SearchMaskingID.h
//  KryptoChat
//
//  Created by TrungVN on 5/29/14.
//  Copyright (c) 2014 mTouche. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContactSearchMID : UIViewController <UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, ContactSearchMIDDelegate>

@property (retain, nonatomic) IBOutlet UITableView *tblSearchFriend;
@property (nonatomic, retain) IBOutlet UITextField* txtSearchFriend;
@property (retain, nonatomic) IBOutlet UILabel *lblNotFound;

+(ContactSearchMID *)share;

-(void) showSearchResult:(NSDictionary*) searchResult;
-(void) refreshSearchResult;
-(void) failedSearchResult;
-(void) addFriendSuccess;
-(void) addFriendFailed;

@end
