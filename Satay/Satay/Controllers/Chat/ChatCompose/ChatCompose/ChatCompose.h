//
//  ComposeView.h
//  KryptoChat
//
//  Created by TrungVN on 4/22/14.
//  Copyright (c) 2014 mTouche. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ComposeHeader.h"

@interface ChatCompose : UIViewController <UITableViewDelegate, UITableViewDataSource>

+(ChatCompose *)share;

@property (nonatomic, retain) NSMutableArray* arrContact;
@property (nonatomic, retain) NSMutableArray* arrContactStore;
@property (nonatomic, retain) IBOutlet ComposeHeader* headerCompose;
@property (nonatomic, retain) IBOutlet UITableView* tblContact;

@property BOOL isCreatingGroup;

-(void) closeView;
-(void) searchBuddyName;
- (void)reloadComposeList:(NSArray *)contactArray;
- (void)reloadComposeSearchList:(NSArray *)contactArray;
@end
