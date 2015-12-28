//
//  FooterInfo.h
//  KryptoChat
//
//  Created by TrungVN on 6/9/14.
//  Copyright (c) 2014 mTouche. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GroupInfoFriendCell.h"

@interface FooterInfo : UIView <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate>

@property (nonatomic, retain) IBOutlet UIButton* btnClear;
@property (nonatomic, retain) IBOutlet UIButton* btnBlock;

@property (nonatomic, retain) IBOutlet UITableView* tblGroup;
@property (nonatomic, retain) IBOutlet UIView* footerView;
@property (nonatomic, retain) IBOutlet UIView* addFriendView;
@property BOOL isAdminOfGroup;

@property (nonatomic, retain) NSString* selectJid;
@property (nonatomic, retain) ChatBox* chatBox;

-(void) buildFooter:(ChatBox*) chatBoxInfo;

-(IBAction) clearConversation:(id) sender;
-(IBAction) blockContact:(id) sender;

-(void) deleteGroup;
-(void) blockProcess;
-(void) displayBlockButton;
-(void) addFriendIntoGroup;

@end
