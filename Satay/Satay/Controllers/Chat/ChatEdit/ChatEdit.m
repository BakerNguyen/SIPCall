//
//  EditChatList.m
//  KryptoChat
//
//  Created by TrungVN on 4/24/14.
//  Copyright (c) 2014 mTouche. All rights reserved.
//

#import "ChatEdit.h"
#import "ChatList.h"


@interface ChatEdit (){
    int counter;
    CAlertView *alertView;
}

@end

@implementation ChatEdit

+(ChatEdit *)share{
    static dispatch_once_t once;
    static ChatEdit * share;
    dispatch_once(&once, ^{
        share = [[self alloc] init];
    });
    return share;
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [ChatFacade share].chatListEditDelegate = self;
   [[NSOperationQueue mainQueue] addOperationWithBlock:^{
       [self.view addSubview:[ChatList share].tblChatHistory];
       [[ChatList share].tblChatHistory changeXAxis:0 YAxis:0];
       [ChatList share].tblChatHistory.editing = TRUE;
       [ChatList share].tblChatHistory.tableHeaderView = NULL;
       [[ChatList share].tblChatHistory reloadData];
       [[ChatList share].tblChatHistory setContentOffset:CGPointMake(0, 0)];
       [[ChatList share].arrDeleteChatBoxs removeAllObjects];
   }];
    alertView = [CAlertView new];
}

-(void) viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [ChatFacade share].chatListEditDelegate = nil;
    [ChatList share].tblChatHistory.editing = FALSE;
    [[ChatList share].arrDeleteChatBoxs removeAllObjects];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = TITLE_EDIT_CHAT;
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem createLeftButtonTitle:_CANCEL
                                                                            Target:self Action:@selector(cancelView)];
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem createRightButtonTitle:_DONE
                                                                              Target:self Action:@selector(doneView)];
}

-(void) cancelView{
    [ChatList share].arrChatBox = [self.arrChatBoxStore mutableCopy];
    [self popToChatList];
}
-(void)popToChatList
{
    [[ChatList share].tblChatHistory changeXAxis:0
                                           YAxis:[ChatList share].notification.height];
    [ChatList share].tblChatHistory.tableHeaderView = [ChatList share].header;
    [[ChatList share].tblChatHistory reloadData];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(void) doneView{
    counter = 0;
    if([ChatList share].arrDeleteChatBoxs.count == 0){
        [self cancelView];
        return;
    }
    
    for (ChatBox *chatBox in [ChatList share].arrDeleteChatBoxs) {
        if ([chatBox isKindOfClass:[chatBox class]]) {
            NSDictionary *leaveDic = @{kMUC_ROOM_JID: chatBox.chatboxId,
                                       kXMPP_TO_JID: [[ContactFacade share] getJid:YES]
                                       };
            [[ChatFacade share] leaveFromChatRoom:leaveDic];
        }
    }
}

-(void) doneLeaveChatBox:(NSString*)errString
{    
    [[CWindow share] showLoading:kLOADING_LEAVING];
    counter ++;
    
    if (errString.length > 0)
        [alertView showError:errString];
    
    if (counter == [ChatList share].arrDeleteChatBoxs.count) {        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [[CWindow share] hideLoading];
            [self popToChatList];
        }];
    }
}


@end
