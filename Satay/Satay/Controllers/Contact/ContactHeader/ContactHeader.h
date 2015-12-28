//
//  HeaderView.h
//  KryptoChat
//
//  Created by TrungVN on 4/16/14.
//  Copyright (c) 2014 mTouche. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContactHeader : UIView <UISearchBarDelegate, ContactHeaderDelegate>

@property (nonatomic, retain) IBOutlet UIButton* btnEdit;
@property (nonatomic, retain) IBOutlet UISearchBar* searchBar;
@property (nonatomic, retain) UIView* dimView;

@property (nonatomic, retain) IBOutlet UIView* requestView;
@property (nonatomic, retain) IBOutlet UILabel* lblNumberRequest;

@property (nonatomic, retain) IBOutlet UIView* pendingView;
@property (nonatomic, retain) IBOutlet UILabel* lblNumberPending;

@property (nonatomic, retain) IBOutlet UIView* dividerHeader;
@property (nonatomic) BOOL isSearching;

-(IBAction) editContacts;
-(void) startSearch;
-(void) endFriendSearch;

-(void) tapViewRequest;
-(void) tapViewPending;

-(void) showNewRequest:(NSArray*) arrRequest;
-(void) hideNewRequest;
-(void) showPending:(NSArray*)arrPending;
-(void) hidePending;
-(void) showSearchBar;
-(void) hideSearchBar;

-(void) checkDevider;
-(void) fixView;

@end
