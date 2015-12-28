//
//  ComposeHeader.h
//  KryptoChat
//
//  Created by TrungVN on 4/22/14.
//  Copyright (c) 2014 mTouche. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ComposeHeader : UIView<UISearchBarDelegate>

@property (nonatomic, retain) IBOutlet UISearchBar* searchContact;
@property (nonatomic, retain) IBOutlet UIView* viewNewGroup;

-(void) newGroup;
-(void) hideNewGroup;
-(void) showNewGroup;

-(void)startFriendSearch;
-(void)endFriendSearch;
-(void)fixView;

@end
