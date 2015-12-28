//
//  ContactInfo.m
//  Satay
//
//  Created by TrungVN on 6/4/14.
//  Copyright (c) 2014 mTouche. All rights reserved.
//

#import "ContactInfo.h"
#import <MediaPlayer/MediaPlayer.h>
#import "ChatView.h"
#import "ViewPhoto.h"
#import "MWGridViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>

#define ACTION_SHEET_COPY_MASKINGID_TAG 2

@interface ContactInfo (){
    BOOL isAvatar;
    UIImage* chosenImage;
    UIBarButtonItem *saveButton;
    BOOL isGridShowing;
}
@end

@implementation ContactInfo

@synthesize chatBox, contact, group;

@synthesize headerView;
@synthesize tblSetting;
@synthesize footerInfo;

@synthesize arrMediaMessages;
@synthesize arrGroupFriend, arrMemberContacts;
@synthesize arrAddingMembers;
@synthesize standardUIAS;
@synthesize imagePicker;
@synthesize popoverController;

@synthesize btnPlayMedia, mediaArray;
@synthesize mwPhotoBrowser, mediaPlayer;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [tblSetting setTableHeaderView:headerView];
    [self.view addSubview:tblSetting];
    [tblSetting setTableFooterView:footerInfo];

    
    arrGroupFriend = [NSMutableArray new];
    arrAddingMembers = [NSMutableArray new];
    arrMemberContacts = [NSMutableArray new];
    [ContactFacade share].contactInfoDelegate = self;
    [AppFacade share].contactInfoDelegate = self;
    [ChatFacade share].contactInfoDelegate = self;
    mediaArray = [NSMutableArray new];
    
    // Create save button
    saveButton = [UIBarButtonItem createRightButtonTitle:_SAVE Target:self Action:@selector(saveMediaFileFromPhotoBrowser)];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playbackStateSwitched)
                                                 name:MPMoviePlayerPlaybackStateDidChangeNotification object:nil];
}

-(void) viewWillAppear:(BOOL)animated{
    // switch to delegate in footerinfo if user open contact info
    [[ChatView share] removeKVO];
    if([self isMovingFromParentViewController])
        return;
    
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem createLeftButtonTitle:_BACK
                                                                            Target:self
                                                                            Action:@selector(backView)];
    [tblSetting setContentOffset:CGPointMake(0, 0)];
    [self buildView];
    [self enableTableMemberListInteraction:TRUE];
    if([UIApplication sharedApplication].statusBarHidden){
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
    }
    
    [arrAddingMembers removeAllObjects];
}

-(void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if([self isMovingFromParentViewController])
        return;
}

-(BOOL) checkInfoAvailable:(NSString*) chatBoxId{
    chatBox = [[AppFacade share] getChatBox:chatBoxId];
    GroupMember *groupMember;
    if (!chatBox)
        return FALSE;
    if (chatBox.isGroup) {
        group = [[AppFacade share] getGroupObj:chatBoxId];
        NSString *Jid = [[ContactFacade share] getJid:YES];
        groupMember = [[AppFacade share] getGroupMember:chatBoxId userJID:Jid];
        if(!groupMember || [groupMember.memberState intValue] != kGROUP_MEMBER_STATE_ACTIVE){
            return FALSE;
        }

    }
    else{
        contact = [[ContactFacade share] getContact:chatBoxId];
    }
    
    if (!contact && !group) {
        return FALSE;
    }
    return TRUE;
}

-(void) buildView{
    if(![self checkInfoAvailable:chatBox.chatboxId])
        return;
    if(!self.navigationController)
        return;
    self.title = chatBox.isGroup ? TITLE_GROUP_INFO: TITLE_CONTACT_INFO;
    [headerView buildView:chatBox];
    [tblSetting setTableHeaderView:headerView];
    
    [arrGroupFriend removeAllObjects];
    [arrMemberContacts removeAllObjects];
    [arrGroupFriend addObjectsFromArray:[[ChatFacade share] getMembersList:chatBox.chatboxId]];
    [arrMemberContacts addObjectsFromArray:[[ChatFacade share] getMemberContactsList:chatBox.chatboxId]];
    arrMediaMessages = [[[ChatFacade share] getMediaMessage:chatBox.chatboxId limit:MAXFLOAT] mutableCopy];
    
    [footerInfo.tblGroup reloadData];
    [footerInfo buildFooter:chatBox];
    [tblSetting setTableFooterView:footerInfo];
    [tblSetting reloadData];
}

-(void) resetView{
    chatBox = nil;
    contact = nil;
    group = nil;
    [arrGroupFriend removeAllObjects];
    [arrMediaMessages removeAllObjects];
    [arrAddingMembers removeAllObjects];
    [arrMemberContacts removeAllObjects];
}

-(void) backView{
    if (self.navigationController) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    [self resetView];
}

-(void) changeAlertChat:(id)sender{
    UISwitch * button = (UISwitch *)sender;
    chatBox.notificationSetting = [NSNumber numberWithDouble:button.on];
    [[DAOAdapter share] commitObject:chatBox];
}

-(void) changeSoundChat:(id)sender{
    UISwitch * button = (UISwitch *)sender;
    chatBox.soundSetting = [NSNumber numberWithDouble:button.on];
    [[DAOAdapter share] commitObject:chatBox];
}

-(void) changeEncryptChat:(id)sender{
    UISwitch * button = (UISwitch *)sender;
    chatBox.encSetting = [NSNumber numberWithDouble:button.on];
    [[DAOAdapter share] commitObject:chatBox];
}

-(void)copyMaskingID
{
    UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self
                                                    cancelButtonTitle:_CANCEL
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:_COPY_MASKINGID, nil];
    [actionSheet setTag:ACTION_SHEET_COPY_MASKINGID_TAG];
    [actionSheet showInView:self.view];
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView{
    if(chatBox.isGroup)
        return 5;
    else
        return 6;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.tblSetting deselectRowAtIndexPath:indexPath animated:YES];
    
    NSInteger section = indexPath.section;
    if(chatBox.isGroup){
        section ++;
    }
    
    switch (section) {
        case 0:
            [self copyMaskingID];
            break;
        case 1:
            [UpdateName share].chatBoxId = chatBox.chatboxId;
            [self.navigationController pushViewController:[UpdateName share] animated:YES];
            break;
        case 2:
        {
            if ([[ChatFacade share] countMediaMessageExisted:chatBox.chatboxId] > 0) {
                [[ChatFacade share] displayPhotoBrower:[arrMediaMessages objectAtIndex:0]
                                          showGridView:YES];
            }
            else{
                [[CAlertView new] showError:_ALERT_NO_MEDIA];
            }
        }
            break;
            
        default:
            break;
    }
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 2;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return (indexPath.row == 0) ? 44:35;
}



-(UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellID = @"";
    if(indexPath.row == 1)
        cellID = @"InfoCell2";
    else
        cellID = @"InfoCell1";
    InfoCell *cell = (InfoCell *)[tableView dequeueReusableCellWithIdentifier:cellID];

    
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"InfoCell" owner:self options:nil];
        if (indexPath.row == 1) {
            cell = [nib objectAtIndex:1];
        }else{
            cell = [nib objectAtIndex:0];
        }
    }
    
    cell.indicator.hidden = YES;
    cell.btnSwitch.hidden = YES;
    [cell.btnSwitch removeTarget:nil
                       action:NULL
             forControlEvents:UIControlEventAllEvents];
    
    if(indexPath.row == 1){
        cell.backgroundColor = [UIColor clearColor];
    }
    else {
        NSInteger section = indexPath.section;
        if(chatBox.isGroup){
            section ++;
        }

        switch (section) {
            case 0:
                cell.lblTitle.text = LABEL_ONE_KRYPTO_ID;
                cell.lbTitleContent.text = contact.maskingid;
                cell.indicator.hidden = NO;
                break;
            case 1:
                cell.lblTitle.text = chatBox.isGroup ? LABEL_GROUP_NAME:LABEL_DISPLAY_NAME;
                cell.lbTitleContent.text = chatBox.isGroup ? [[ChatFacade share] getGroupName:chatBox.chatboxId] : [[ContactFacade share] getContactName:chatBox.chatboxId];
                cell.indicator.hidden = NO;
                break;
            case 2:{
                cell.lblTitle.text = LABEL_VIEW_ALL_MEDIA;
                NSString* titleContent = [NSString stringWithFormat:@"%d", [[ChatFacade share] countMediaMessageExisted:chatBox.chatboxId]];
                if([[ChatFacade share] countMediaMessageExisted:chatBox.chatboxId] == 0)
                    titleContent = LABEL_NONE;
                cell.lbTitleContent.text = titleContent;
                cell.indicator.hidden = NO;
            }
                break;
            case 3:
                cell.lblTitle.text = LABEL_NOTIFICATION_ALERT;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.lbTitleContent.text = @"";
                cell.btnSwitch.hidden = NO;
                cell.btnSwitch.on = [chatBox.notificationSetting boolValue];
                [cell.btnSwitch addTarget:self
                                   action:@selector(changeAlertChat:)
                         forControlEvents:UIControlEventValueChanged];

                break;
            case 4:
                cell.lblTitle.text =LABEL_NOTIFICATION_SOUND;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.lbTitleContent.text = @"";
                cell.btnSwitch.hidden = NO;
                cell.btnSwitch.on = [chatBox.soundSetting boolValue];
                [cell.btnSwitch addTarget:self
                                   action:@selector(changeSoundChat:)
                         forControlEvents:UIControlEventValueChanged];

                break;
            case 5:
                cell.lblTitle.text =LABEL_ENCRYPTED_MESSAGE;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.lbTitleContent.text = @"";
                cell.btnSwitch.hidden = NO;
                cell.btnSwitch.on = [chatBox.encSetting boolValue];
                [cell.btnSwitch addTarget:self
                                   action:@selector(changeEncryptChat:)
                         forControlEvents:UIControlEventValueChanged];
                break;
            default:
                break;
        }
    }
    
    return cell;
}

#pragma mark - IBActionSheet/UIActionSheet Delegate Method
- (IBAction)changeLogo
{
    [self.headerView.btnAvatar setHighlighted:YES];
    if (chatBox.isGroup)
    {
        NSLog(@"Upload new logo for chat room");

        if ([[[ChatFacade share] updateGroupLogo:chatBox.chatboxId] isEqual:[UIImage imageNamed:IMG_CHAT_GROUP_EMPTY]])
        {
            isAvatar = FALSE;
            standardUIAS = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:_CANCEL destructiveButtonTitle:nil otherButtonTitles:ALERT_BUTTON_CHOOSE_FROM_LIBRARY, ALERT_BUTTON_TAKE_PHOTO, nil];
        }
        else
        {
            isAvatar = TRUE;
            standardUIAS = [[UIActionSheet alloc] initWithTitle:nil delegate:self
                                              cancelButtonTitle:_CANCEL
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:ALERT_BUTTON_VIEW_PROFILE_PHOTO, ALERT_BUTTON_CHOOSE_FROM_LIBRARY, ALERT_BUTTON_TAKE_PHOTO, nil];
        }
    }
    else
    {
        if ([[[ContactFacade share] updateContactAvatar:contact.jid] isEqual:[UIImage imageNamed:IMG_C_EMPTY]])
        {
            isAvatar = FALSE;
            standardUIAS = nil;
        }
        else
        {
            isAvatar = TRUE;
            standardUIAS = [[UIActionSheet alloc] initWithTitle:nil
                                                       delegate:self
                                              cancelButtonTitle:_CANCEL
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:ALERT_BUTTON_VIEW_PROFILE_PHOTO, nil];
        }
    }
    [standardUIAS showInView:self.view];
}

// the delegate method to receive notifications is exactly the same as the one for UIActionSheet
-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == ACTION_SHEET_COPY_MASKINGID_TAG) //copy masking id
    {
        if (buttonIndex == 0)
        {
            [[ChatFacade share] copyToClipboard:contact.maskingid];
        }
    }
    else
    if (!isAvatar)
    {
        if (buttonIndex == 0)
        {
            ALAuthorizationStatus authStatus = [ALAssetsLibrary authorizationStatus];
            switch (authStatus) {
                case ALAuthorizationStatusDenied:
                    [[CAlertView new] showInfo:_ERROR_DONT_HAVE_ACCESS_PHOTOS_LIBRARY];
                    break;
                case ALAuthorizationStatusAuthorized:
                    [self showOption:typePhotoLibrary];
                    break;
                case ALAuthorizationStatusNotDetermined:{
                    ALAssetsLibrary *lib = [[ALAssetsLibrary alloc] init];
                    [lib enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                        if(group){
                            [self showOption:typePhotoLibrary];
                        }
                    } failureBlock:^(NSError *error) {
                    }];
                }
                default:
                    break;
            }
        }

        if (buttonIndex == 1)
        {
            AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
            switch (authStatus) {
                case AVAuthorizationStatusDenied:
                    [[CAlertView new] showInfo:_ALERT_SATAY_DOES_NOT_HAVE_ACCESS_TO_YOUR_CAMERA];
                    break;
                case AVAuthorizationStatusAuthorized:
                    [self showOption:typeCaptureImage];
                    break;
                case AVAuthorizationStatusNotDetermined:{
                    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                        if(granted){
                            NSLog(@"Permission camera granted");
                            [self showOption:typeCaptureImage];
                        } else {
                            NSLog(@"Permission camera denied");
                        }
                    }];
                }
                    break;
                    
                default:
                    break;
            }
        }

        if (buttonIndex == 2)
        {
            [headerView.btnAvatar setSelected:NO];
        }
    }
    else     // isAvatar = TRUE
    {
        if (chatBox.isGroup)
        {
            switch (buttonIndex) {
                case 0:
                    [self showChatboxAvatar];
                    break;
                case 1:
                    if ([self checkInfoAvailable:chatBox.chatboxId]) {
                        [self showOption:typePhotoLibrary];
                    } else {
                        [[CAlertView new] showError:_ALERT_NOT_GROUP_MEMBER];
                    }
                    break;
                case 2:
                    if ([self checkInfoAvailable:chatBox.chatboxId]) {
                        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
                        switch (authStatus) {
                            case AVAuthorizationStatusDenied:
                                [[CAlertView new] showInfo:_ALERT_SATAY_DOES_NOT_HAVE_ACCESS_TO_YOUR_CAMERA];
                                break;
                            case AVAuthorizationStatusAuthorized:
                                [self showOption:typeCaptureImage];
                                break;
                            case AVAuthorizationStatusNotDetermined:{
                                [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                                    if(granted){
                                        NSLog(@"Permission camera granted");
                                        [self showOption:typeCaptureImage];
                                    } else {
                                        NSLog(@"Permission camera denied");
                                    }
                                }];
                            }
                                break;
                                
                            default:
                                break;
                        }
                    } else {
                        [[CAlertView new] showError:_ALERT_NOT_GROUP_MEMBER];
                    }
                    break;
                case 3:
                    [headerView.btnAvatar setSelected:NO];
                    break;
                    
                default:
                    break;
            }
        }
        else
        {
            if (buttonIndex == 0)
            {
                [self showChatboxAvatar];
            }
            if (buttonIndex == 1)
            {
                [headerView.btnAvatar setSelected:NO];
            }
        }
    }
}

- (void) showChatboxAvatar
{
    ViewPhoto *viewPhoto = [[ViewPhoto alloc] initWithNibName:@"ViewPhoto" bundle:nil];
    viewPhoto.navigationItem.hidesBackButton = YES;
    [[ChatFacade share] showProfileImageInChatbox:chatBox];
    [self.navigationController pushViewController:viewPhoto animated:YES];
}

- (void)imagePicker:(GKImagePicker *)imagePicker pickedImage:(UIImage *)image{
    NSData *imgData = [ChatAdapter scaleImage:image rate:3];
    NSDictionary *infoUpload = @{kMUC_ROOM_JID: chatBox.chatboxId,
                                 kROOM_IMAGE_DATA: imgData
                                 };
    [[ChatFacade share] setChatRoomLogo:infoUpload];
    if (UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM() && imagePicker.imagePickerController.sourceType != UIImagePickerControllerSourceTypeCamera)
        [self.popoverController dismissPopoverAnimated:YES];
    else
        [self.imagePicker.imagePickerController dismissViewControllerAnimated:YES completion:nil];
    
    
}

- (void)showOption:(NSInteger)type {
    if ([[ContactFacade share] isAccountRemoved]) {
        [[CAlertView new] showError:ERROR_ACCOUNT_REMOVED];
        return;
    }
    
    if(![[NotificationFacade share] isInternetConnected]){
        [[CAlertView new] showError:NO_INTERNET_CONNECTION_TRY_LATER];
        return;
    }
    
    UIImagePickerControllerSourceType pickerType;
    switch (type) {
        case typeCaptureImage:
            pickerType = UIImagePickerControllerSourceTypeCamera;
            break;
        case typePhotoLibrary:
            pickerType = UIImagePickerControllerSourceTypePhotoLibrary;
            break;
        default:
            break;
    }
    
    NSArray *mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:pickerType];
    
    if ([UIImagePickerController isSourceTypeAvailable:pickerType] && [mediaTypes count] > 0)
    {
        self.imagePicker = [[GKImagePicker alloc] initWithType:pickerType];        
        self.imagePicker.delegate = self;
        self.imagePicker.croptEnable = YES;
        self.imagePicker.resizeableCropArea = YES;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad && self.imagePicker.imagePickerController.sourceType != UIImagePickerControllerSourceTypeCamera) {
            
            self.popoverController = [[UIPopoverController alloc] initWithContentViewController:self.imagePicker.imagePickerController];
            [self.popoverController presentPopoverFromRect:headerView.btnAvatar.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        } else
            [self presentViewController:self.imagePicker.imagePickerController animated:YES completion:nil];
    }
    else{
        [[CAlertView new] showError:mERROR_MEDIA_NOT_AVAILABLE];
    }

}

-(void) addKVO{
    id observe = [mwPhotoBrowser observationInfo];
    if(mwPhotoBrowser.navigationItem && !observe){
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
        //mwPhotoBrowser = nil;
    }
}

-(void) displayPhotoBrower:(NSMutableArray*) photoArray
                photoIndex:(NSInteger) photoIndex{
    
    //return because chatview.navigationController will handle this.
    if ([self.navigationController isEqual:[ChatView share].navigationController])
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
    mwPhotoBrowser.startOnGrid = YES;
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
    id observe = [photoBrowser observationInfo];
    if (!observe) {
        [self addKVO];
    }
    
   /* Daryl comment this.
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        Message* message = [[AppFacade share] getMessage:[[mediaArray objectAtIndex:index]
                                                          objectForKey:kTEXT_MESSAGE_ID]];
        if (!message)
            return;

        [btnPlayMedia removeFromSuperview];
        
        // If grid is showing we don't slow play button
        if (isGridShowing)
            return;
    });
    */
}

-(void)photoBrowser:(MWPhotoBrowser*) photoBrowser reloadSaveButton:(Message*) message{
    if(message){
        photoBrowser.navigationItem.rightBarButtonItem = nil;
        
        if (isGridShowing) {
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

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if (![object isKindOfClass:[MWPhotoBrowser class]])
        return;
    
    NSInteger index  = ((MWPhotoBrowser*)object).currentIndex;
    Message* message = [[AppFacade share] getMessage:[[mediaArray objectAtIndex:index]
                                                      objectForKey:kTEXT_MESSAGE_ID]];
    isGridShowing = NO;
    
    for (UIView *subView in mwPhotoBrowser.view.subviews ) {
        UIResponder* nextResponder = [subView nextResponder];
        if ([nextResponder isKindOfClass:[MWGridViewController class] ]) {
            isGridShowing = YES;
        }
    }
    
    NSString *changeString = [change objectForKey:@"new"];
    if ([changeString isKindOfClass:[NSNull class]]) { // Title nil this case when display only 1 photo.
        isGridShowing = NO;
    }
    [btnPlayMedia removeFromSuperview];
    
    if (isGridShowing) {// When grid  showing
        
    }
    else{// When grid not showing
        if([message.messageType isEqual:MSG_TYPE_IMAGE]){
            [[ChatFacade share] startDestroyMessage:message.messageId];
        }
        switch ([[ChatFacade share] messageType:message.messageType]) {
            case MediaTypeAudio:
            case MediaTypeVideo:{
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
        NSString* tempURL = [[ChatFacade share] createTempURL:mediaData];
        
        mediaPlayer =  [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL fileURLWithPath:tempURL]];
        [self.navigationController presentMoviePlayerViewControllerAnimated:mediaPlayer];
        [mediaPlayer.moviePlayer play];
    }
    else{
        [[CAlertView new] showError:ERROR_RAWDATA_NOT_READY_ALERT_FAILED];
    }
}

- (void) playbackStateSwitched {
    NSLog(@"%s",__PRETTY_FUNCTION__);
    switch (mediaPlayer.moviePlayer.playbackState) {
        case MPMoviePlaybackStatePlaying:
            break;
        default:
            [[ChatFacade share] removeTempURLFile];
            break;
    }
}

- (void)addParticipant
{
    NSLog(@"%s, %@",__PRETTY_FUNCTION__, arrAddingMembers);
    if ([arrAddingMembers count] > 0) {
        // add member to chat room
        NSString *memberMaskingIDs = @"";
        NSString *memberJIDs = @"";
        for (Contact *member in arrAddingMembers) {
            if ([memberMaskingIDs length] > 0) {
                memberMaskingIDs = [memberMaskingIDs stringByAppendingString:[NSString stringWithFormat:@",%@", member.maskingid]];
            } else {
                memberMaskingIDs = [memberMaskingIDs stringByAppendingString:member.maskingid];
            }
            if ([memberJIDs length] > 0) {
                memberJIDs = [memberJIDs stringByAppendingString:[NSString stringWithFormat:@",%@", member.jid]];
            } else {
                memberJIDs = [memberJIDs stringByAppendingString:member.jid];
            }
        }
        NSDictionary *addDic = @{kMUC_ROOM_JID: chatBox.chatboxId,
                                 kMEMBER_MASKINGID: memberMaskingIDs,
                                 kMEMBER_JID_LIST: memberJIDs,
                                 kROOMNAME: [[ChatFacade share] getGroupName:chatBox.chatboxId],
                                 kROOM_PASSWORD: [[ChatFacade share] getGroupPassword:chatBox.chatboxId]
                                 };
        [[CWindow share] showLoading:kLOADING_ADDING];
        [self enableTableMemberListInteraction:FALSE];
        [[ChatFacade share] addMember:addDic];
    }
}

-(void) synchronizeBlockListSuccess{
    [[CWindow share] hideLoading];
    Contact* contactItem = [[ContactFacade share] getContact:chatBox.chatboxId];
    if ([contactItem.contactState integerValue] != kCONTACT_STATE_BLOCKED) {
            [footerInfo displayBlockButton];
    }
}
-(void) synchronizeBlockListFailed{
    [[CWindow share] hideLoading];
}


-(void) enableSaveMediaButton:(BOOL)isEnable{
    mwPhotoBrowser.navigationItem.rightBarButtonItem.enabled = isEnable;
}

-(void) updateRoomLogoFailed{
    if(self.navigationController)
        [[CAlertView new] showError:_ALERT_FAILED_UPLOAD];
}

-(void) enableTableMemberListInteraction:(BOOL) isEnable{
    self.footerInfo.tblGroup.userInteractionEnabled = isEnable;
}

+(ContactInfo *)share{
    static dispatch_once_t once;
    static ContactInfo * share;
    dispatch_once(&once, ^{
        share = [self new];
    });
    return share;
}

@end
