//
//  SelfTimer.m
//  KryptoChat
//
//  Created by TrungVN on 5/30/14.
//  Copyright (c) 2014 mTouche. All rights reserved.
//

#import "SelfTimer.h"
#import "ChatView.h"

@interface SelfTimer (){
    ChatView* chatView;
}


@end

@implementation SelfTimer

@synthesize tblTimer, footerView, footerTick;
@synthesize tempTimer, tempDestroyAllMessage, destroyTimer, destroyAllMessage, arrTimer;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = TITLE_SELF_DESTRUCT_TIME;
    
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem createLeftButtonTitle:_CLOSE Target:self Action:@selector(closeView)];
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem createRightButtonTitle:_DONE Target:self Action:@selector(doneSetTimer)];
    
    arrTimer = [NSMutableArray new];
    [arrTimer addObject:@"0"];
    [arrTimer addObject:@"30"];
    [arrTimer addObject:@"60"];
    [arrTimer addObject:@"180"];
    [arrTimer addObject:@"300"];
    [arrTimer addObject:@"600"];
    
    destroyTimer = 0;
    destroyAllMessage = FALSE;
    [tblTimer setTableFooterView:footerView];
    
    UITapGestureRecognizer* tapApply  = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(applyToAll)];
    [tapApply setCancelsTouchesInView:NO];
    [footerView addGestureRecognizer:tapApply];
    footerTick.layer.cornerRadius = footerTick.frame.size.width/2;
    chatView = [ChatView share];
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    ChatBox* chatBox = [[AppFacade share] getChatBox:chatView.chatBoxID];
    if (chatBox) {
        tempTimer = (int)[chatBox.destructTime integerValue];
        tempDestroyAllMessage = chatBox.isAlwaysDestruct;
    }
    
    [self drawFooter];
    [tblTimer reloadData];
}

-(void) closeView{
    [self dismissViewControllerAnimated:TRUE completion:nil];
}

-(void) doneSetTimer{
    destroyTimer = tempTimer;
    destroyAllMessage = tempDestroyAllMessage;
    [[ChatFacade share] updateChatBoxDestroyTime:chatView.chatBoxID
                               isAlwaysDestruct:destroyAllMessage
                                         second:destroyTimer];
    [self closeView];
}

-(void) applyToAll{
    [[LogFacade share] createEventWithCategory:Conversation_Category
                                           action:selfDestructTimer
                                            label:enterConversation_Action];
    tempDestroyAllMessage = !tempDestroyAllMessage;
    [self drawFooter];
}

-(void) drawFooter{
    if(tempDestroyAllMessage){
        footerTick.image = [UIImage imageNamed:IMG_C_B_TICK];
        footerTick.layer.borderWidth = 0;
    }
    else{
        footerTick.image = NULL;
        footerTick.layer.borderWidth = 2;
        footerTick.layer.borderColor = COLOR_128128128.CGColor;
    }
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [arrTimer count];
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    tempTimer = [[arrTimer objectAtIndex:indexPath.row] intValue];
    
    switch (tempTimer) {
        case 30:{
            
            [[LogFacade share] createEventWithCategory:Conversation_Category
                                                action:selfDestructTimer
                                                 label:selectTimer_Label];
            break;
        }case 60:{
            [[LogFacade share] createEventWithCategory:Conversation_Category
                                                action:selfDestructTimer
                                                 label:selectTimer_Label];
            break;
        }case 180:{
            
            [[LogFacade share] createEventWithCategory:Conversation_Category
                                                action:selfDestructTimer
                                                 label:selectTimer_Label];
            break;
        }case 300:{
            
            [[LogFacade share] createEventWithCategory:Conversation_Category
                                                action:selfDestructTimer
                                                 label:selectTimer_Label];
            break;
        }case 600:{
            [[LogFacade share] createEventWithCategory:Conversation_Category
                                                action:selfDestructTimer
                                                 label:selectTimer_Label];
            break;
        }default:
            break;
    }
    
    [tblTimer reloadData];
}

-(UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellID = @"SelfTimerCell";
    SelfTimerCell* cell = [tblTimer dequeueReusableCellWithIdentifier:cellID];
    
	if (!cell){
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:cellID owner:self options:nil];
    	cell = (SelfTimerCell*)[nib objectAtIndex:0];
	}
    
    int time = [[arrTimer objectAtIndex:indexPath.row] intValue];
    cell.tickImage.hidden = TRUE;
    if(tempTimer == time)
        cell.tickImage.hidden = FALSE;
    
    switch (time) {
        case 0:
            cell.lblTitle.text = LABEL_NONE;
            break;
        case 30:
            cell.lblTitle.text = [NSString stringWithFormat:LABEL_SECONDS, time];
            break;
        case 60:
            cell.lblTitle.text = [NSString stringWithFormat:LABEL_MINUTE, (int) (time/60)];
            break;
        default:
            cell.lblTitle.text =[NSString stringWithFormat:LABEL_MINUTES, (int)(time/60)];
            break;
    }
	return cell;
}

+(SelfTimer *)share{
    static dispatch_once_t once;
    static SelfTimer * share;
    dispatch_once(&once, ^{
        share = [self new];
    });
    return share;
}

@end
