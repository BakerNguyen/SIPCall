//
//  HeaderChatList.h
//  KryptoChat
//
//  Created by TrungVN on 4/22/14.
//  Copyright (c) 2014 mTouche. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatHeader : UIView<UISearchBarDelegate>

@property (nonatomic, retain) IBOutlet UIButton* btnEdit;
@property (nonatomic, retain) IBOutlet UISearchBar* searchBar;
@property (nonatomic) BOOL isSearching;

-(IBAction) editChatList;

-(void)startSearch;
-(void)endSearch;
-(void)fixView;
@end