//
//  ChatView.m
//  JuzChatV2
//
//  Created by TrungVN on 7/29/13.
//  Copyright (c) 2013 mTouche. All rights reserved.
//
#import "ChatView.h"
#import "CWindow.h"
#import "MWGridViewController.h"

#define maxReloadTyping 1.0 //seconds
#define maxRecord 10
@implementation ChatView{
    CGFloat originHeight;
    NSTimeInterval typingTime;
    UIBarButtonItem *saveButton;
    NSOperationQueue* mainQueue;
}

@synthesize chatfield;
@synthesize naviTitle;
@synthesize bubbleScroll;
@synthesize moreKeyboard;
@synthesize notifyChat;
@synthesize audioRecorder;
@synthesize pageHistory;
@synthesize arrMessage, chatBoxID, cellNib;
@synthesize mediaArray;
@synthesize btnPlayMedia;
@synthesize arrDate;
@synthesize currentAudioPlaying;
@synthesize popoverController;
@synthesize mwPhotoBrowser;
@synthesize tempVideoURL, mediaPlayer;

-(void) viewDidLoad{
    self.navigationItem.titleView = naviTitle;
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem createRightButtonTitle:_TIMER Target:self Action:@selector(showTimer)];
    
    [self.view addSubview:moreKeyboard];
    [self.view addSubview:notifyChat];
    [self.view addSubview:audioRecorder];
    
    
    [AppFacade share].chatViewDelegate = self;
    [ContactFacade share].chatViewDelegate = self;
    [ChatFacade share].chatViewDelegate = self;
    [SIPFacade share].chatViewDelegate = self;
    [EmailFacade share].chatViewDelegate = self;
    
    arrMessage = [NSMutableArray new];
    arrDate = [NSMutableArray new];
    cellNib = [UINib nibWithNibName:@"CBubbleCell" bundle:nil];
    
    mainQueue = [NSOperationQueue mainQueue];
    
    // Create save button
    saveButton = [UIBarButtonItem createRightButtonTitle:_SAVE Target:self Action:@selector(saveMediaFileFromPhotoBrowser)];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playbackStateChanged)
                                                 name:MPMoviePlayerPlaybackStateDidChangeNotification object:nil];
}

-(void) viewWillAppear:(BOOL)animated{
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem createLeftButtonTitle:_BACK
                                                                            Target:self
                                                                            Action:@selector(backView)];
    if ((self.isMovingToParentViewController)){
        [self resetContent];
        [self buildContent];
        [chatfield.txtChatView becomeFirstResponder];
        if(![[AppFacade share] getChatBox:chatBoxID].isGroup){
            [[XMPPFacade share] sendLastActivityQueryToJID:chatBoxID];
        }
    }
    
    [self checkDisplayBlueAlert];
    [[LogFacade share] trackingScreen:Conversation_Category];
}

-(void) viewDidAppear:(BOOL)animated{
    if(chatfield.y < self.view.height - chatfield.height){
        if (moreKeyboard.y == self.view.height)
            return;
        else{
            [chatfield.txtChatView becomeFirstResponder];
        }
    }
}

-(void) viewWillDisappear:(BOOL)animated{
    [bubbleScroll hidePopup];
    [self stopAudioPlaying:nil];
}

-(void) showTimer{
    [chatfield.txtChatView resignFirstResponder];
    [[CWindow share] showPopup:[SelfTimer share]];
}

-(void) showChatSetting
{
    self.naviTitle.userInteractionEnabled = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.naviTitle.userInteractionEnabled = YES;
        if ([[ContactInfo share] checkInfoAvailable:chatBoxID])
            [[self navigationController] pushViewController:[ContactInfo share] animated:YES];
        else
            [[CAlertView new] showError:_ALERT_FAILED_GET_CHATBOX_INFO];
    });
}

-(void) backView{
    if (self.navigationController) {
        [mainQueue cancelAllOperations];
        chatBoxID = @"";
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

-(void) resetContent{
    [mainQueue cancelAllOperations];
    pageHistory = 0;
    [arrMessage removeAllObjects];
    [arrDate removeAllObjects];
    bubbleScroll.bottomDisplay = 10;
    bubbleScroll.willScrollDown = TRUE;
    [[bubbleScroll subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    bubbleScroll.contentSize = CGSizeMake(bubbleScroll.width, bubbleScroll.bottomDisplay);
    chatfield.isTyping = FALSE;
    [chatfield resetField];
}

-(void) buildContent{
    [self displayName];
    [self displayStatus];
    
    arrMessage = [[[ChatFacade share] getHistoryMessage:chatBoxID limit:MAXFLOAT] mutableCopy];
    [bubbleScroll addSubview:bubbleScroll.btnLoadMore];
    [self loadContent:nil];
}

-(void) checkDisplayBlueAlert{
    [[[AppFacade share] getChatBox:chatBoxID].encSetting boolValue] ? [notifyChat hideBlueAlert] : [notifyChat showBlueAlert:CHAT_DECRYPTED];
}

-(void) displayName{
    naviTitle.title.text = [[AppFacade share] getChatBox:chatBoxID].isGroup ? [[ChatFacade share] getGroupName:chatBoxID] : [[ContactFacade share] getContactName:chatBoxID];
}

-(void) displayStatus{
    if(![[AppFacade share] getChatBox:chatBoxID].isGroup){
        naviTitle.subTitle.text = _TAP_HERE_FOR_CONTACT_INFO;
    }
    else if(![[ChatFacade share] isKickedByOwner:chatBoxID]){
        naviTitle.subTitle.text = _TAP_HERE_FOR_GROUP_INFO;
    }
    else{
        naviTitle.subTitle.text  = _YOU_WAS_KICKED_OUT_OF_THIS_ROOM;
        return;
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if([[AppFacade share] getChatBox:chatBoxID].isGroup)
            [self displayGroupStatus];
        else
            [self displaySingleStatus];
    });
}

-(void) displaySingleStatus{
    if ([[AppFacade share] getChatBox:chatBoxID].isGroup)
        return;
    if (!self.navigationController)
        return;
    
    Contact* contact = [[ContactFacade share] getContact:chatBoxID];
    NSString* subTitleStr = [NSString new];
    if(contact.contactState){
        switch ([contact.contactState integerValue]) {
            case kCONTACT_STATE_ONLINE: subTitleStr = _ONLINE; break;
            case kCONTACT_STATE_BLOCKED: subTitleStr = _BLOCKED; break;
            case kCONTACT_STATE_OFFLINE: subTitleStr = contact.extend2 ; break;
        }
    }
    if(subTitleStr.length > 0)
        naviTitle.subTitle.text = subTitleStr;
}

-(void) displayGroupStatus{
    if([[ChatFacade share] isKickedByOwner:chatBoxID]){
        naviTitle.subTitle.text = _YOU_WAS_KICKED_OUT_OF_THIS_ROOM;
        return;
    }
    
    NSString *memberListStr = @"";
    NSArray *memberListArr = [[ChatFacade share] getMembersList:chatBoxID];
    for(GroupMember *item in memberListArr){
        NSString *contactName = [[ContactFacade share] getContactName:item.jid];
        if(memberListStr.length > 0)
            memberListStr = [memberListStr stringByAppendingString:@", "];
        if(contactName.length > 8)
            contactName = [NSString stringWithFormat:@"%@...", [contactName substringToIndex:7]];
        memberListStr = [memberListStr stringByAppendingFormat:@"%@", contactName];
    }
    naviTitle.subTitle.text = memberListStr;
}

-(void) handleSingleChatState:(NSDictionary *)userInfo{
    if (![[userInfo objectForKey:kCHAT_STATE_FROM_JID] isEqualToString:chatBoxID])
        return;
    
    naviTitle.subTitle.text = _IS_TYPING;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(maxReloadTyping * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if(([[NSDate date] timeIntervalSince1970] - typingTime) >= maxReloadTyping){
            [self displaySingleStatus];
        }
    });
    typingTime = [[NSDate date] timeIntervalSince1970];
}

-(IBAction) loadContent:(id)sender{
    [mainQueue addOperationWithBlock:^{
    if (sender)
        bubbleScroll.willScrollDown = FALSE;
    bubbleScroll.btnLoadMore.enabled = NO;
    
    NSInteger maxIndex = [arrMessage count];
    //Return if no message to load, do nothing here.
    if (maxIndex == 0){
        bubbleScroll.btnLoadMore.hidden = YES;
         [[CWindow share] hideLoading];
        return;
    }
    
    pageHistory++;
    NSInteger subIndex = (pageHistory-1)*maxRecord;
    NSArray* subArray = nil;
    
    if(subIndex >= maxIndex){
        [[CAlertView new] showInfo:INFO_NO_MORE_CONTENT];
        bubbleScroll.willScrollDown = TRUE;
        bubbleScroll.bottomDisplay = bubbleScroll.bottomDisplay - bubbleScroll.btnLoadMore.height;
         [[CWindow share] hideLoading];
        return;
    }
    
    if (subIndex+maxRecord >= maxIndex){
        subArray = [arrMessage subarrayWithRange:NSMakeRange(subIndex, maxIndex - subIndex)];
        bubbleScroll.btnLoadMore.hidden = YES;
        bubbleScroll.bottomDisplay = 3*padding;
    }
    else{
        subArray = [arrMessage subarrayWithRange:NSMakeRange(subIndex, maxRecord)];
        bubbleScroll.btnLoadMore.hidden = NO;
        bubbleScroll.bottomDisplay = bubbleScroll.btnLoadMore.height;
    }
    subArray = [[subArray reverseObjectEnumerator] allObjects];

    arrDate = [[arrDate sortedArrayUsingComparator:
                                            ^(id obj1, id obj2) {
                                                return [obj2 compare:obj1];
                                            }] mutableCopy];
    CGFloat dateCellHeight = 0;
    if (arrDate.lastObject){
        dateCellHeight = [bubbleScroll cellWithID:arrDate.lastObject].height;
        [[bubbleScroll cellWithID:arrDate.lastObject] removeFromSuperview];
        [arrDate removeLastObject];
    }
    
    for (Message* message in subArray) {
        [self addMessage:message.messageId];
    }
    
    for (Message* message in subArray) {
        [bubbleScroll cellWithID:message.messageId].tag = MESSAGE_TAG;
    }
    
        CGFloat bottomY = bubbleScroll.bottomDisplay;
        for (CBubbleCell* cell in [bubbleScroll subviews]) {
            if ([cell isKindOfClass:[CBubbleCell class]]) {
                if (cell.tag == MESSAGE_TAG || cell.tag == MESSAGE_DATE_TAG){
                    cell.tag = MESSAGE_TAG_MOVED;
                    continue;
                }
                if (cell.tag == MESSAGE_TAG_MOVED) {
                    [cell changeXAxis:cell.x
                                YAxis:cell.y + bubbleScroll.bottomDisplay - bubbleScroll.btnLoadMore.height - dateCellHeight];
                    if(bottomY < cell.y + cell.height)
                        bottomY = cell.y + cell.height;
                    continue;
                }
            }
        }
        bubbleScroll.bottomDisplay = bottomY;
        bubbleScroll.contentSize = CGSizeMake(bubbleScroll.width, bubbleScroll.bottomDisplay);
        if (bubbleScroll.willScrollDown)
            [bubbleScroll scrollToBottom];
        else
            [bubbleScroll scrollToTop];
        bubbleScroll.willScrollDown = TRUE;
        bubbleScroll.btnLoadMore.enabled = YES;
        
        [[CWindow share] hideLoading];
    }];
}

-(void) addMessage:(NSString*) messageId{
    Message* message = [[AppFacade share] getMessage:messageId];
    ChatBox* chatBox = [[AppFacade share] getChatBox:message.chatboxId];
    if (!chatBox){
        [[ChatFacade share] createChatBox:message.chatboxId isMUC:FALSE];
        chatBox = [[AppFacade share] getChatBox:message.chatboxId];
    }
    if (!message ||
        ![message.chatboxId isEqualToString:chatBoxID] ||
        ![ChatView share].navigationController ||
        [bubbleScroll cellWithID:messageId])
        return;
    
    CBubbleCell* cell = (CBubbleCell*)[[cellNib instantiateWithOwner:self options:nil] firstObject];
    //draw cell date.
    if ([cell drawDateCell:message.sendTS]){
        [bubbleScroll addCell:cell];
        cell = (CBubbleCell*)[[cellNib instantiateWithOwner:self options:nil] firstObject];
    }
    //continue draw normal.
    cell.cellID = messageId;
    [cell drawCell];
    [bubbleScroll addCell:cell];
    cell.tag = MESSAGE_TAG_MOVED;

    [[ChatFacade share] updateMessageReadTS:message];
}

-(void) updateStatus:(NSString*) messageId{
    Message* message = [[AppFacade share] getMessage:messageId];
    if (!message ||
        [message.messageType isEqualToString:MSG_TYPE_NOT_MESSAGE_DESTROY] ||
        [message.messageType isEqualToString:MESSAGE_STATUS_CONTENT_DELETED])
        return;
    CBubbleCell* cell = [bubbleScroll cellWithID:messageId];
    if(cell){
        [cell drawStatus];
    }
    [[ChatFacade share] startDestroyMessage:messageId];
}

-(void) updateState:(NSString*) messageId{
    CBubbleCell* cell = [bubbleScroll cellWithID:messageId];
    if(cell)
        [cell drawState];
}

-(void) updateCell:(NSString *)messageId{
    CBubbleCell* cell = [bubbleScroll cellWithID:messageId];
    if(!cell)
        return;
    CGFloat oldHeight = cell.height;
    if ([[[AppFacade share] getMessage:messageId].messageType
         isEqualToString:MSG_TYPE_NOT_MESSAGE_DESTROY]) {
        for (UIView* view in [cell subviews]) {
            [view removeFromSuperview];
        }
    }
    
    [cell drawCell];
    
    CGFloat gapDraw = cell.height - oldHeight;
    for (CBubbleCell* moveCell in bubbleScroll.subviews) {
        if ([moveCell isKindOfClass:[CBubbleCell class]] &&
            cell.y < moveCell.y &&
            [cell.message.sendTS doubleValue] < [moveCell.message.sendTS doubleValue]) {
            [moveCell changeXAxis:moveCell.x YAxis:moveCell.y + gapDraw];
        }
    }
    bubbleScroll.bottomDisplay = bubbleScroll.bottomDisplay + gapDraw;
    bubbleScroll.contentSize = CGSizeMake(bubbleScroll.width, bubbleScroll.bottomDisplay);
}

-(void) showCellLoading:(NSString*) messageId
               progress:(CGFloat) progress{
    CBubbleCell* cell = [bubbleScroll cellWithID:messageId];
    if(!cell)
        return;
    [cell showLoading];
    cell.loadingDimView.progress = progress;
}

-(void) hideCellLoading:(NSString*) messageId{
    CBubbleCell* cell = [bubbleScroll cellWithID:messageId];
    if(cell)
        [cell hideLoading];
}

-(void) showAlertBlocked{
    UIActionSheet * actionSheet = [[UIActionSheet alloc] initWithTitle:_ALERT_BLOCKED
                                                              delegate:self
                                                     cancelButtonTitle:_CANCEL
                                                destructiveButtonTitle:nil
                                                     otherButtonTitles:_UNBLOCK, nil];
    [actionSheet showInView:self.view];
}

-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (buttonIndex) {
        case 0:
            if ([[ContactFacade share] isAccountRemoved]) {
                [[CAlertView new] showError:ERROR_ACCOUNT_REMOVED];
                return;
            }
            
            if (![[NotificationFacade share] isInternetConnected]) {
                [[CAlertView new] showError:NO_INTERNET_CONNECTION_TRY_LATER];
                return;
            }
            
            [[ContactFacade share] synchronizeBlockList:chatBoxID action:kUNBLOCK_USERS];
            break;
        default:
            break;
    }
}

-(void) addKVO{
    id observe = [mwPhotoBrowser observationInfo];
    if (mwPhotoBrowser.navigationItem && !observe) {
        [mwPhotoBrowser addObserver:self forKeyPath:@"navigationItem.title" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];

    }
}

-(void) removeKVO{
    @try {
        id observeInfo = [mwPhotoBrowser observationInfo];
        if (observeInfo)
            [mwPhotoBrowser removeObserver:self forKeyPath:@"navigationItem.title"];
    }
    @catch (NSException *exception) {
        NSLog(@"exception %@", exception);
        
    }
    @finally {
    }
}

-(void) displayPhotoBrower:(NSMutableArray*) photoArray
                photoIndex:(NSInteger) photoIndex
              showGridView:(BOOL)showGridView{
    if (bubbleScroll.popupisShowing)
        return;
    if(!self.navigationController)
        return;
    
    [mediaArray removeAllObjects];
    mediaArray = [photoArray mutableCopy];
    
    [self removeKVO];
    mwPhotoBrowser = [[MWPhotoBrowser alloc] initWithDelegate:self];
   
    mwPhotoBrowser.displayActionButton = NO;
    mwPhotoBrowser.displayNavArrows = YES;
    mwPhotoBrowser.displaySelectionButtons = NO;
    mwPhotoBrowser.alwaysShowControls = NO;
    mwPhotoBrowser.zoomPhotosToFill = NO;
    mwPhotoBrowser.enableGrid = YES;
    mwPhotoBrowser.startOnGrid = showGridView;
    mwPhotoBrowser.delayToHideElements = MAXFLOAT;
    mwPhotoBrowser.enableSwipeToDismiss = YES;
    
    // Optionally set the current visible photo before displaying
    [mwPhotoBrowser showNextPhotoAnimated:NO];
    [mwPhotoBrowser showPreviousPhotoAnimated:NO];
    [mwPhotoBrowser setCurrentPhotoIndex:photoIndex];
    
    [self.navigationController pushViewController:mwPhotoBrowser animated:YES];
    
}

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return [mediaArray count];
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < mediaArray.count){
        NSDictionary* contentDic = [mediaArray objectAtIndex:index];
        return [contentDic objectForKey:kMEDIA];
    }
    
    return nil;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser thumbPhotoAtIndex:(NSUInteger)index{
    if (index < mediaArray.count){
        NSDictionary* contentDic = [mediaArray objectAtIndex:index];
        return [contentDic objectForKey:kMEDIA];
    }
    return nil;
}

-(void) photoBrowser:(MWPhotoBrowser *)photoBrowser didDisplayPhotoAtIndex:(NSUInteger)index{

    [self addKVO];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        Message *message = [[AppFacade share] getMessage:[[mediaArray objectAtIndex:index]
                                                          objectForKey:kTEXT_MESSAGE_ID]];
        if (!message )
            return;
        
        if(photoBrowser.navigationItem.title == nil)
        {
            _isGridShowing = NO;
            [btnPlayMedia removeFromSuperview];
            switch ([[ChatFacade share] messageType:message.messageType]) {
                case MediaTypeAudio:
                case MediaTypeVideo:
                {
                    [btnPlayMedia setCenter:CGPointMake(mwPhotoBrowser.view.width/2, mwPhotoBrowser.view.height/2)];
                    [mwPhotoBrowser.view addSubview:btnPlayMedia];
                    btnPlayMedia.tag = index;
                }
                    break;
                default:
                    break;
            }
        }
        
        [self photoBrowser:photoBrowser reloadSaveButton:message];
    });
}

-(void)photoBrowser:(MWPhotoBrowser*) photoBrowser reloadSaveButton:(Message*) message{
    if(message ){
        photoBrowser.navigationItem.rightBarButtonItem = nil;
        
        if (_isGridShowing) {
            return;
        }
        
        switch ([[ChatFacade share] messageType:message.messageType]){
            case MediaTypeImage:
            case MediaTypeVideo:
                if([message.selfDestructDuration integerValue] <= 0){
                    photoBrowser.navigationItem.rightBarButtonItem = saveButton;
                }
                break;
                
            default:
                break;
        }
    }
}

- (BOOL)photoBrowser:(MWPhotoBrowser *)photoBrowser isPhotoSelectedAtIndex:(NSUInteger)index
{
    return YES;
}


-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    
    if (![object isKindOfClass:[MWPhotoBrowser class]])
        return;

    NSInteger index  = ((MWPhotoBrowser*)object).currentIndex;
    Message* message = [[AppFacade share] getMessage:[[mediaArray objectAtIndex:index]
                                                      objectForKey:kTEXT_MESSAGE_ID]];
    _isGridShowing = NO;
    
    for (UIView *subView in mwPhotoBrowser.view.subviews ) {
        UIResponder* nextResponder = [subView nextResponder];
        if ([nextResponder isKindOfClass:[MWGridViewController class] ]) {
            _isGridShowing = YES;
            break;
        }
    }
    
    NSString *changeString = [change objectForKey:@"new"];
    if ([changeString isKindOfClass:[NSNull class]]) { // Title nil this case when display only 1 photo.
        _isGridShowing = NO;
    }
    
    [btnPlayMedia removeFromSuperview];
    
    if (_isGridShowing) {// When grid  showing
        
    }
    else{// When grid not showing
        if([message.messageType isEqual:MSG_TYPE_IMAGE]){
            [[ChatFacade share] startDestroyMessage:message.messageId];
        }
        
        switch ([[ChatFacade share] messageType:message.messageType]) {
            case MediaTypeImage:
                break;
            case MediaTypeAudio:
            case MediaTypeVideo:
            {
                [btnPlayMedia setCenter:CGPointMake(mwPhotoBrowser.view.width/2, mwPhotoBrowser.view.height/2)];
                [mwPhotoBrowser.view addSubview:btnPlayMedia];
                btnPlayMedia.tag = index;
            }
                break;
            default:
                break;
        }

    }
    
    [self photoBrowser:mwPhotoBrowser reloadSaveButton:message];
}

-(void)saveMediaFileFromPhotoBrowser{
    [self enableSaveMediaButton:FALSE];
    NSInteger index  = mwPhotoBrowser.currentIndex;
    Message* message = [[AppFacade share] getMessage:[[mediaArray objectAtIndex:index]
                                                      objectForKey:kTEXT_MESSAGE_ID]];
    if(message)
        [[ChatFacade share] saveMediaToLibrary:message];
}

-(IBAction) playMedia:(id) sender{
    NSInteger index = ((UIButton*)sender).tag;
    Message* message = [[AppFacade share] getMessage:[[mediaArray objectAtIndex:index]
                                                      objectForKey:kTEXT_MESSAGE_ID]];
    if (!message)
        return;
    NSData* mediaData = nil;
    
    switch ([[ChatFacade share] messageType:message.messageType]) {
        case MediaTypeAudio:
            mediaData = [[ChatFacade share] audioData:message.messageId];
            [[ChatFacade share] startDestroyMessage:message.messageId];
            break;
        case MediaTypeVideo:
            mediaData = [[ChatFacade share] videoData:message.messageId];
            [[ChatFacade share] startDestroyMessage:message.messageId];
            break;
        default:
            break;
    }
    
    if (mediaData) {
        tempVideoURL = [[ChatFacade share] createTempURL:mediaData];
        
        mediaPlayer =  [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL fileURLWithPath:tempVideoURL]];
        [self.navigationController presentMoviePlayerViewControllerAnimated:mediaPlayer];
        [mediaPlayer.moviePlayer play];
    }
    else{
        [[CAlertView new] showError:_ALERT_NO_MEDIA];
    }
}

- (void) playbackStateChanged {
    switch (mediaPlayer.moviePlayer.playbackState) {
        case MPMoviePlaybackStatePlaying:
            break;
            
        default:
            [[NSFileManager defaultManager] removeItemAtPath:tempVideoURL error:nil];
            break;
    }
}

-(void) showButtonRetry:(NSString*) messageId{
    CBubbleCell* cell = [bubbleScroll cellWithID:messageId];
    if (cell) {
        cell.btnRetry.hidden = FALSE;
    }
}

-(void) hideButtonRetry:(NSString*) messageId{
    CBubbleCell* cell = [bubbleScroll cellWithID:messageId];
    if (cell) {
        cell.btnRetry.hidden = TRUE;
    }
}

-(void) stopAudioPlaying:(NSString*) messageID{
    if(!currentAudioPlaying)
        return;
    // If messageID = nil then stop any audio is playing.
    if(!messageID){
        [currentAudioPlaying stopAudio];
        currentAudioPlaying = nil;
        return;
    }
    
    // If currentAudioPlaying has same cellID then stop that one, this case is destroyed audio message.
    if([currentAudioPlaying.cellID isEqualToString:messageID]){
        [currentAudioPlaying stopAudio];
        currentAudioPlaying = nil;
    }
}

-(void) enableSaveMediaButton:(BOOL)isEnable{
    mwPhotoBrowser.navigationItem.rightBarButtonItem.enabled = isEnable;
}

-(void) sendBigMediaFileFailed:(NSInteger) limit{
    [[CAlertView new] showError:[NSString stringWithFormat:mERROR_CANNOT_SENT_BIG_MEDIA_FILE, limit]];
}

-(void) handleAudioRecordWhileResetEmail{
    if(audioRecorder.iRecordStage == RecordStageRecording || audioRecorder.iRecordStage == RecordStagePausing)
        [audioRecorder handleTouchEndedEvent];
}

+(ChatView *)share{
    static dispatch_once_t once;
    static ChatView * share;
    dispatch_once(&once, ^{
        share = [self new];
    });
    return share;
}

@end
