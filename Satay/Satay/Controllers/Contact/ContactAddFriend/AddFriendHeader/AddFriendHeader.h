//
//  HeaderContactFriendList.h
//  KryptoChat
//
//  Created by ENCLAVEIT on 6/21/14.
//  Copyright (c) 2014 mTouche. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContactBook.h"

@interface AddFriendHeader : UIView<UISearchBarDelegate>

@property (nonatomic, retain) IBOutlet UISearchBar* searchBar;
@property (nonatomic, retain) UIView* dimView;
@property (nonatomic, retain) IBOutlet UIView* viewAddMaskingID;
@property (nonatomic, retain) NSTimer *searchDelayer;
@property (nonatomic) BOOL isSearching;

-(void)startFriendSearch;
-(IBAction)endFriendSearch;
- (IBAction)addAFriend:(id)sender;
- (void)fixView;
@end
