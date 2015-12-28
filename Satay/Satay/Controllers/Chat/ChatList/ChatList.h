//
//  ChatList.h
//  Satay
//
//  Created by TrungVN on 1/15/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatHeader.h"
#import "ChatCompose.h"
#import "ChatView.h"
#import "CWindow.h"
#import "ChatListNotification.h"

@interface ChatList : UIViewController <UINavigationBarDelegate,UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate, ChatListDelegate>

@property (nonatomic, retain) IBOutlet ChatHeader* header;
@property (nonatomic, retain) IBOutlet UITableView *tblChatHistory;
@property (weak, nonatomic) IBOutlet UILabel *lblNoChatRoom;
@property (strong, nonatomic) IBOutlet ChatListNotification *notification;
@property (nonatomic, retain) NSMutableArray* arrChatBox;
@property (nonatomic, retain) NSMutableArray* arrDeleteChatBoxs;

-(void) composeChat;
-(void) reloadChatList:(NSArray*) chatboxArray;
-(void) reloadSearchChatList:(NSArray *)chatboxArray;
-(void) showChatView:(NSString*) chatBoxId;
+(ChatList *)share;

@end
