//
//  CBubbleCell.m
//  JuzChatV2
//
//  Created by TrungVN on 8/5/13.
//  Copyright (c) 2013 mTouche. All rights reserved.
//
#import "CBubbleCell.h"
#import "ChatView.h"

@implementation CBubbleCell
@synthesize audioCell, imageCell, videoCell, notificationCell, callLogCell;

@synthesize txtMessage;
@synthesize bgrImage;
@synthesize lblStatus, lblDateCell;
@synthesize lblBuddyName, lblMessageType, loadingDimView, popupView;
@synthesize btnRetry;
@synthesize cellID, mineMessage, message;

-(void) willMoveToSuperview:(UIView *)newSuperview{
    if (self.tag == MESSAGE_DATE_TAG)
        return;
    
    UILongPressGestureRecognizer* longTap = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(showPopupMenu:)];
    [longTap setCancelsTouchesInView:NO];
    [self addGestureRecognizer:longTap];
    txtMessage.delegate = self;
    loadingDimView.trackTintColor = COLOR_255244230;
    loadingDimView.progressTintColor = COLOR_24317741;
}

-(void) drawCell{
    [self changeWidth:[UIScreen mainScreen].bounds.size.width Height:self.height];
    message = (Message*)[[AppFacade share] getMessage:cellID];
    if(!message)
        return;
    
    mineMessage = [[ChatFacade share] isMineMessage:message];
    switch ([[ChatFacade share] messageType:message.messageType]) {
        case MediaTypeText:
            if (message.isEncrypted) {
                NSData* data = [Base64Security decodeBase64String:message.messageContent];
                data = [[AppFacade share] decryptDataLocally:data];
                if (data)
                    txtMessage.text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            }
            else{
                txtMessage.text = message.messageContent;
            }
            
            txtMessage.font = [UIFont systemFontOfSize:15];
            txtMessage.linkTextAttributes =  @{ NSForegroundColorAttributeName: [UIColor blueColor],};
            if([[ChatFacade share] isMineMessage:message])
                txtMessage.textAlignment = NSTextAlignmentLeft;
            
            self.txtMessage.textContainer.lineFragmentPadding = 0.0;
            self.txtMessage.textContainerInset = UIEdgeInsetsMake(0, 0, 0, 0);
            CGFloat fixedWidth = 220;
            CGSize newSize = [txtMessage sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
            [txtMessage changeWidth:newSize.width >= fixedWidth - padding?fixedWidth:newSize.width
                             Height:newSize.height + padding*1.5];
            [bgrImage changeWidth:txtMessage.width + padding*4
                           Height:txtMessage.height + padding*1.5];
            if (![[AppFacade share] isStringContainWebLink:txtMessage.text] &&
                ![[AppFacade share] isStringContainPhoneNumber:txtMessage.text]){
                [txtMessage setUserInteractionEnabled:NO];
            }
            
            [self addSubview:txtMessage];
            if ([message.selfDestructDuration integerValue] > 0)
                [[ChatFacade share] startDestroyMessage:cellID];
            break;
        case MediaTypeImage:
            [imageCell initImageCell:message.messageId];
            [bgrImage changeWidth:imageCell.width + padding*4 Height:imageCell.height + padding*3];
            [self addSubview:imageCell];
            [imageCell addSubview:loadingDimView];
            break;
        case MediaTypeVideo:
            [videoCell initVideoCell:message.messageId];
            [bgrImage changeWidth:videoCell.width + padding*4 Height:videoCell.height + padding*3];
            [self addSubview:videoCell];
            [videoCell addSubview:loadingDimView];
            break;
        case MediaTypeAudio:
            [audioCell initAudioCell:message.messageId];
            [bgrImage changeWidth:audioCell.width + padding*4 Height:audioCell.height + padding*3];
            [self addSubview:audioCell];
            [audioCell addSubview:loadingDimView];
            break;
        case MediaTypeSIP:
            [callLogCell initCallCell:message.messageId];
            callLogCell.cellID = [[ChatView share] chatBoxID];
            [bgrImage changeWidth:callLogCell.width+padding*4 Height:callLogCell.height+padding*3];
            [self addSubview:callLogCell];
            break;
        case MediaTypeNotification:
            [self changeXAxis:0 YAxis:self.y];
            [notificationCell changeWidth:self.width Height:notificationCell.height];
            notificationCell.lblNotification.text = message.messageContent;
            [notificationCell.lblNotification fitLabelWidth:260];
            [notificationCell.lblNotification changeXAxis:(notificationCell.width - notificationCell.lblNotification.width)/2 YAxis:padding];
            [notificationCell.imgBackground changeWidth:notificationCell.lblNotification.width + padding*2
                                                Height:notificationCell.lblNotification.height+padding*2];
            [notificationCell.imgBackground changeXAxis:notificationCell.lblNotification.x - padding
                                                  YAxis:notificationCell.imgBackground.y];
            [self changeWidth:self.width Height:notificationCell.imgBackground.height + padding];
            notificationCell.imgBackground.image = [notificationCell.imgBackground.image stretchableImageWithLeftCapWidth:4 topCapHeight:4];
            [self addSubview:notificationCell];
            
            [[ChatFacade share] updateMessageReadTS:message];
            
            //Important, for mediatype notification, we don't process drawBubble or drawStatus so we return here;
            return;
            break;
            
        default:
            break;
    }
    
    [self drawBubble]; // >>> drawState inside here.
    [self changeWidth:self.width Height:bgrImage.height];
    [self drawStatus];
    
    if([message.selfDestructTS boolValue] > 0){
        [[ChatFacade share] startDestroyMessage:message.messageId];
    }
}

-(void) drawStatus{
    message = [[AppFacade share] getMessage:message.messageId];
    NSString* statusContent = message.sendTS ? [self convertTime:message.sendTS] :
    [self convertTime:message.readTS];
    
    /* no need status text in call log cell, just time of this. @Daniel June 5, 2015 */
    
    if(mineMessage) {
        NSString *messageStatus = ([[ChatFacade share] messageType:message.messageType]==MediaTypeSIP) ? @"" : [message.messageStatus capitalizedString];
        statusContent = [NSString stringWithFormat:@"%@\n%@", messageStatus, statusContent];
    }
    
    lblStatus.text = statusContent;
    [lblStatus fitLabelWidth:200];
    
    if (mineMessage){
        [lblStatus changeXAxis:bgrImage.x - lblStatus.width - padding/2
                         YAxis:bgrImage.height - lblStatus.height - padding];
        lblStatus.textAlignment = NSTextAlignmentRight;
    }
    else{
        [lblStatus changeXAxis:bgrImage.width + padding
                         YAxis:bgrImage.height - lblStatus.height - padding];
        lblStatus.textAlignment = NSTextAlignmentLeft;
    }
    [self addSubview:lblStatus];
}

-(void) drawBubble{
    GroupMember* groupMember = [[AppFacade share] getGroupMember:message.chatboxId userJID:message.senderJID];
    
    if (groupMember && !mineMessage) {
        if(!(groupMember.memberColor.length > 0)){
            groupMember.memberColor = [UIColor randomHexColor];
            [[DAOAdapter share] commitObject:groupMember];
        }
        
        lblBuddyName.text = [[ContactFacade share] getContactName:groupMember.jid];
        lblBuddyName.textColor = [UIColor colorFromHexString:groupMember.memberColor];
        [lblBuddyName fitLabelWidth:widthPercent *[CWindow share].width];
        [lblBuddyName changeXAxis:padding*2.5 YAxis:padding];
        [self addSubview:lblBuddyName];
        
        [bgrImage changeWidth:(bgrImage.width < lblBuddyName.width + 4*padding) ? lblBuddyName.width + 4*padding:bgrImage.width
                       Height:bgrImage.height + lblBuddyName.height];
    }
    
    UIImage* imageBackground = NULL;
    if([message.selfDestructDuration intValue] > 0)
        imageBackground = [UIImage imageNamed:mineMessage ?IMG_CHAT_C3:IMG_CHAT_C4];
    else if(!message.isEncrypted)
        imageBackground = [UIImage imageNamed:mineMessage ?IMG_CHAT_C5:IMG_CHAT_C6];
    else
        imageBackground = [UIImage imageNamed:mineMessage ?IMG_CHAT_C2:IMG_CHAT_C1];
    
    [self drawState];
    [bgrImage setImage:[imageBackground stretchableImageWithLeftCapWidth:15  topCapHeight:15]];
    if(mineMessage){
        [bgrImage changeXAxis:bgrImage.superview.width - bgrImage.width YAxis:bgrImage.y];
        for(UIView* view in self.subviews){
            if([view isEqual:bgrImage])
                continue;
            if([view isEqual:lblMessageType]){
                [view changeXAxis:bgrImage.rightEdge - lblMessageType.width - padding*3
                            YAxis:bgrImage.height - lblMessageType.height - padding*2];
                continue;
            }
            [view changeXAxis:bgrImage.rightEdge - view.width - padding*3 YAxis:padding];
        }
    }
    else{
        for(UIView* view in self.subviews){
            if([view isEqual:bgrImage])
                continue;
            if([view isEqual:lblBuddyName]){
                continue;
            }
            if([view isEqual:lblMessageType]){
                [view changeXAxis:padding*2.5 YAxis:bgrImage.height - lblMessageType.height - padding*2];
                continue;
            }
            if(lblBuddyName.superview == self)
                [view changeXAxis:padding*2.5 YAxis:lblBuddyName.bottomEdge ];
            else
                [view changeXAxis:padding*2.5 YAxis:padding];
        }
    }
    [self addSubview:btnRetry];
    if (mineMessage)
        [btnRetry changeXAxis:bgrImage.x - btnRetry.width YAxis:(bgrImage.height - btnRetry.height)/2 - padding];
    else
        [btnRetry changeXAxis:bgrImage.x + bgrImage.width YAxis:(bgrImage.height - btnRetry.height)/2];
    
    btnRetry.hidden = ![message.messageStatus isEqualToString:MESSAGE_STATUS_UPLOADED_FAILED];
    if (txtMessage.x > lblMessageType.x) {
        if (!lblMessageType.hidden && lblMessageType.x > 0) {
            [txtMessage changeXAxis:lblMessageType.x YAxis:txtMessage.y];
        }
    }
}

-(void) drawState{
    Message* cellMessage = [[AppFacade share] getMessage:message.messageId];
    
    if([cellMessage.selfDestructDuration intValue] > 0){
        if(cellMessage.selfDestructTS > 0)
            lblMessageType.text = [NSString stringWithFormat:SELF_DESTRUCT_AT, [self convertTime:cellMessage.selfDestructTS]];
        else
            lblMessageType.text = [NSString stringWithFormat:SELF_DESTRUCT];
    }
    else if(!cellMessage.isEncrypted){
        lblMessageType.text = DECRYPTED;
    }
    else{
        return;
    }
    
    if (lblMessageType.superview) {
        CGFloat oldBGR = bgrImage.width;
        CGFloat oldMT= lblMessageType.width;
        [lblMessageType fitLabelWidth:200];
        [lblMessageType changeWidth:lblMessageType.width Height:20];
        [bgrImage changeWidth:bgrImage.width<lblMessageType.width+padding*4? lblMessageType.width+padding*4:bgrImage.width
                       Height:bgrImage.height == self.height ? bgrImage.height : bgrImage.height + lblMessageType.height + padding];
        CGFloat movedBGR = bgrImage.width - oldBGR;
        CGFloat movedMT = lblMessageType.width - oldMT;
        if(mineMessage){
            if (movedBGR > 0){
                [self changeXAxis:self.x - movedBGR YAxis:self.y];
                if (movedMT > movedBGR) {
                    [lblMessageType changeXAxis:lblMessageType.x - movedMT +movedBGR YAxis:lblMessageType.y];
                }
            }
            else
                [lblMessageType changeXAxis:lblMessageType.x - movedMT YAxis:lblMessageType.y];
        }
    }
    else{
        [self addSubview:lblMessageType];
        [lblMessageType fitLabelWidth:200];
        [lblMessageType changeWidth:lblMessageType.width Height:20];
        
        [bgrImage changeWidth:bgrImage.width<lblMessageType.width+padding*4? lblMessageType.width+padding*4:bgrImage.width
                       Height:bgrImage.height + lblMessageType.height + padding];
    }
    
    [[[lblMessageType.layer sublayers] objectAtIndex:0] removeFromSuperlayer];
    CALayer *topBorder = [CALayer layer];
    topBorder.backgroundColor = [UIColor whiteColor].CGColor;
    topBorder.frame = CGRectMake(0, 0, bgrImage.width-4*padding, 1);
    if(mineMessage){
        topBorder.frame = CGRectMake(-(bgrImage.width - lblMessageType.width) + 4*padding,
                                     0, bgrImage.width-4*padding, 1);
    }
    [lblMessageType.layer addSublayer:topBorder];
}

-(NSString *) convertTime:(NSNumber *)timeTS{
    return [ChatAdapter convertDateToString:timeTS format:FORMAT_FULL_TIME];
}

-(BOOL) drawDateCell:(NSNumber *)date{
    NSString* strDate = [ChatAdapter convertDateToString:date
                                               format:FORMAT_DATE];
    for (NSString* strDateDisplayed in [ChatView share].arrDate){
        if ([strDate isEqual:strDateDisplayed])
            return NO;
    }
    
    [[ChatView share].arrDate addObject:strDate];
    
    lblDateCell.text = strDate;
    lblDateCell.font = [UIFont systemFontOfSize:12];
    [lblDateCell fitLabelWidth:260];
    [self changeWidth:lblDateCell.width + 2*padding
               Height:lblDateCell.height + 4*padding];
    [lblDateCell changeXAxis:(self.width - lblDateCell.width)/2
                       YAxis:padding];
    [bgrImage changeWidth:self.width Height:lblDateCell.height + 2*padding];
    self.bgrImage.image = [[UIImage imageNamed:IMG_CHAT_DATE] stretchableImageWithLeftCapWidth:4 topCapHeight:4];
    [self addSubview:lblDateCell];
    self.tag = MESSAGE_DATE_TAG;
    self.cellID = strDate;
    
    [self changeXAxis:([ChatView share].bubbleScroll.width - self.width)/2
                YAxis:self.y];
    
    return YES;
}


-(void) showLoading{
    if(loadingDimView.hidden){
        self.userInteractionEnabled = FALSE;
        loadingDimView.hidden = FALSE;
        [loadingDimView changeXAxis:(loadingDimView.superview.width - loadingDimView.width)/2
                              YAxis:(loadingDimView.superview.height - loadingDimView.height)/2];
        [self bringSubviewToFront:loadingDimView];
    }
}

-(void) hideLoading{
    self.userInteractionEnabled = TRUE;
    loadingDimView.hidden = TRUE;
}

-(void) handleTap:(UITapGestureRecognizer*)tap;{   
   
    CGPoint point = [tap locationInView:self];
    message = (Message*)[[AppFacade share] getMessage:cellID];
    if(!message)
        return;
    
    if([[ChatFacade share] messageType:message.messageType] == MediaTypeNotification)
    {
        [[ChatView share].chatfield hideKeyboard] ;
        return;
    }
    
    if (![self isPoint:point inView:self.bgrImage]){
        [[ChatView share].chatfield hideKeyboard] ;
        txtMessage.selectedTextRange = nil;
    }
    [[UIMenuController sharedMenuController] setMenuVisible:YES animated:YES];
}

-(void) showPopupMenu:(id) sender{
    if ([sender isKindOfClass:[UIGestureRecognizer class]]) {
        UILongPressGestureRecognizer* gesture = (UILongPressGestureRecognizer*)sender;
        if (gesture.state == UIGestureRecognizerStateEnded || gesture.state == UIGestureRecognizerStateChanged)
            return;
        
        CGPoint point = [gesture locationInView:self];
        
        if (![self isPoint:point inView:self.bgrImage])
            return;
    }
     
    [[ChatView share].bubbleScroll hidePopup];
    popupView.message = message;
    
    switch ([[ChatFacade share] messageType:message.messageType]) {
        case MediaTypeText:
            [popupView showCopyButton];
            break;
        case MediaTypeAudio:
            [popupView hideSaveButton];
            if(![[ChatFacade share] isMediaFileExisted:message.messageId]){
                [popupView hideForwardButton];
            }
            break;
        case MediaTypeImage:
            if([[ChatFacade share] isMediaFileExisted:message.messageId]){
                [popupView showSaveButton];
            }else{
                [popupView hideForwardButton];
                [popupView hideSaveButton];
            }
            break;
        case MediaTypeVideo:
            if([[ChatFacade share] isMediaFileExisted:message.messageId]){
                [popupView showSaveButton];
            }else{
                [popupView hideForwardButton];
                [popupView hideSaveButton];
            }
            break;
        case MediaTypeNotification:
            return;
            break;
        case MediaTypeSIP:
            [popupView hideForwardButton];
            [popupView hideSaveButton];
            break;
        default:
            break;
    }
    
    //self destroy message not support forward and save.
    if([message.selfDestructDuration integerValue] > 0){
        [popupView hideForwardButton];
        [popupView hideSaveButton];
    }
    
    if([message.messageStatus isEqual:MESSAGE_STATUS_CONTENT_DELETED]){
        [popupView hideForwardButton];
        [popupView hideSaveButton];
    }
    
    popupView.alpha = 0.0;
    popupView.viewButton.layer.cornerRadius = 5;
    popupView.viewButton.layer.borderWidth = 1;
    popupView.viewButton.layer.masksToBounds = YES;
    popupView.tag = POPUP_TAG;
    
    [[ChatView share].bubbleScroll addSubview:popupView];
    if (mineMessage) {
        [popupView changeXAxis:self.width - popupView.width - padding
                         YAxis:self.y + self.height/2 - popupView.height];
        [popupView.arrowDown changeXAxis:popupView.width - padding - popupView.arrowDown.width
                                   YAxis:popupView.arrowDown.y];
    }
    else{
        [popupView changeXAxis:padding
                         YAxis:self.y + self.height/2 - popupView.height];
    }
    
    if (popupView.y < [ChatView share].bubbleScroll.contentOffset.y)
        [[ChatView share].bubbleScroll scrollRectToVisible:CGRectMake(1, popupView.y - popupView.height, 1, 1) animated:YES];
    
    [UIView animateWithDuration:0.4 animations:^{
        [popupView setAlpha:1.0];
        [ChatView share].bubbleScroll.popupisShowing = TRUE;
    } completion:^(BOOL finished) {}];
}

-(IBAction)retrySendMessage{
    [[ChatView share].bubbleScroll hidePopup];
    
    UIActionSheet * actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                              delegate:self
                                                     cancelButtonTitle:_CANCEL
                                                destructiveButtonTitle:nil
                                                     otherButtonTitles:_SEND_AGAIN, _DELETE, nil];
    actionSheet.destructiveButtonIndex = 1;
    actionSheet.delegate = self;
    [actionSheet showInView:[ChatView share].view];
}

-(void) deleteNow{
    [NSTimer scheduledTimerWithTimeInterval:0.1
                                     target:[ChatFacade share]
                                   selector:@selector(destroyMessage:) userInfo:message.messageId
                                    repeats:NO];
}

-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (buttonIndex) {
        case 0:
            [[ChatFacade share] reUploadProcess:message];
            break;
        case 1:
            [[CAlertView new] showWarning:_WARNING_WANT_TO_DELETE_MESS_OR_NOT
                                   TARGET:self
                                   ACTION:@selector(deleteNow)];
            break;
        default:
            break;
    }
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange{
    return YES;
}

- (void)textViewDidChangeSelection:(UITextView *)textView
{
    if(NSEqualRanges(textView.selectedRange, NSMakeRange(0, 0)) == NO) {
        textView.selectedRange = NSMakeRange(0, 0);
        if (![ChatView share].bubbleScroll.popupisShowing)
            [self showPopupMenu:textView];
    }
}


@end
