//
//  CreateNewGroup.m
//  KryptoChat
//
//  Created by TrungVN on 5/14/14.
//  Copyright (c) 2014 mTouche. All rights reserved.
//

#import "NewGroupCreate.h"
#import "ChatComposeCell.h"
#import <AssetsLibrary/AssetsLibrary.h>

#define numberOfRoomLimit 10

@interface NewGroupCreate (){
    NSString* groupNameCopy;
    NSString *groupNameLenghBackup;
    BOOL hasSelectedAvatar;
}

@end

@implementation NewGroupCreate

@synthesize arrGroupFriend, btnAvatar, groupAvatar, groupAvatarBackup;
@synthesize photoAS, photoASandProfile;
//@synthesize pickerAvatar;
@synthesize arrContact,tblContact;
@synthesize txtGroupName, lblTextCounter;
@synthesize loadingview;
@synthesize imagePicker;
@synthesize popoverController;

- (void)viewDidLoad
{
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem createRightButtonTitle:_CREATE Target:self Action:@selector(createGroup)];
    self.title = TITLE_NEW_GROUP;
    
    hasSelectedAvatar = NO;
    
    btnAvatar.layer.cornerRadius = btnAvatar.frame.size.width/2;
    btnAvatar.imageView.contentMode = UIViewContentModeScaleAspectFill;
    
    //pickerAvatar = [UIImagePickerController new];
    //pickerAvatar.delegate = self;
    
    photoAS = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:_CANCEL destructiveButtonTitle:nil otherButtonTitles:ALERT_BUTTON_CHOOSE_FROM_LIBRARY, ALERT_BUTTON_TAKE_PHOTO, nil];
    
    photoASandProfile = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:_CANCEL destructiveButtonTitle:nil otherButtonTitles:ALERT_BUTTON_VIEW_PROFILE_PHOTO,ALERT_BUTTON_CHOOSE_FROM_LIBRARY, ALERT_BUTTON_TAKE_PHOTO, nil];
    lblTextCounter.text = [NSString stringWithFormat:@"%d", MAX_LENGHT_TEXT_GROUP_NAME];
    [super viewDidLoad];
    
    [ChatFacade share].groupCreateDelegate = self;
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [tblContact reloadData];
    
    groupAvatar = NULL;
    // Bug 2633:[iOS] [Chat- Group][ip 4s] Cant add photo while creating new group
    if (!groupAvatarBackup) {
        txtGroupName.text = groupNameCopy;
        lblTextCounter.text = [NSString stringWithFormat:@"%u", MAX_LENGHT_TEXT_GROUP_NAME - txtGroupName.text.length];
        [self updateAvatarButton: groupAvatar];
    }
    groupNameCopy = @"";
    groupNameLenghBackup = [NSString stringWithFormat:@"%d", MAX_LENGHT_TEXT_GROUP_NAME];
    
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem createLeftButtonTitle:_BACK Target:self.navigationController Action:@selector(popViewControllerAnimated:)];
    self.navigationItem.rightBarButtonItem.enabled = ([txtGroupName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length > 0);
    
    if([UIApplication sharedApplication].statusBarHidden){
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
    }
}

-(void) viewDidAppear:(BOOL)animated{
    [txtGroupName becomeFirstResponder];
}

-(BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSString *actualString = [textField.text stringByReplacingCharactersInRange:range withString:string];

    self.navigationItem.rightBarButtonItem.enabled = ([actualString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length > 0);
    
    if (actualString.length > MAX_LENGHT_TEXT_GROUP_NAME && actualString.length < UINT32_MAX) {
        //[[CAlertView new] showError:@"Length of group name text is exceeded."];
        [textField resignFirstResponder];
        return NO;
    } else {
        lblTextCounter.text = [NSString stringWithFormat:@"%d", MAX_LENGHT_TEXT_GROUP_NAME - actualString.length];
        return YES;
    }
}

-(void) updateAvatarButton: (UIImage*) avatar{
    [txtGroupName resignFirstResponder];
    if(avatar){
        [btnAvatar setImage:avatar forState:UIControlStateNormal];
        [btnAvatar setImage:avatar forState:UIControlStateHighlighted];
        hasSelectedAvatar = YES;
    }
    else{
        [btnAvatar setImage:[UIImage imageNamed:IMG_C_MP_ADDPHOTO] forState:UIControlStateNormal];
        [btnAvatar setImage:[UIImage imageNamed:IMG_C_MP_ADDPHOTO_TAP] forState:UIControlStateHighlighted];
        hasSelectedAvatar = NO;
    }
}

-(void) createGroup {
    self.navigationItem.rightBarButtonItem.enabled = FALSE;
    if ([arrGroupFriend count] == 0)
        return;
    if(txtGroupName.text.length == 0){
        [[CAlertView new] showError:_ALERT_GROUP_NAME_NIL];
        return;
    }
    
    /* Daryl comment on 10-Aug-2015
    NSMutableArray *myGroups = [[ChatFacade share] getAllOwnerGroup];
     
    if (myGroups.count >= numberOfRoomLimit) {
        [[CAlertView new] showError:[NSString stringWithFormat:mERROR_EXCEEDED_ROOM_LIMIT,numberOfRoomLimit]];
        return;
    }*/
    
    NSString *memberJIDLists = @"";
    NSMutableArray* jidList = [NSMutableArray new];
    for (Contact *contact in arrGroupFriend) {
        if (contact.jid) {
            [jidList addObject:contact.jid];
        }
    }
    memberJIDLists = [jidList componentsJoinedByString:@","];
    NSLog(@"memberJIDLists %@", memberJIDLists);
    NSDictionary *createChatRoomDic = @{kIMSI: [[ContactFacade share] getIMSI],
                                        kIMEI: [[ContactFacade share] getIMEI],
                                        kTOKEN: [[ContactFacade share] getTokentTenant],
                                        kCENTRALTOKEN: [[ContactFacade share] getTokentCentral],
                                        kMASKINGID: [[ContactFacade share] getMaskingId],
                                        kROOMNAME: [Base64Security generateBase64String:txtGroupName.text],
                                        kROOM_PASSWORD: [ChatAdapter generateMessageId],
                                        kMEMBER_JID_LIST: memberJIDLists,
                                        kAPI_REQUEST_METHOD: PUT,
                                        kAPI_REQUEST_KIND: NORMAL
                                        };
    [[ChatFacade share] createChatRoomWithInfo:createChatRoomDic];
}

- (void)didSuccessCreateGroup:(NSString *)roomJid memberList:(NSString*)memberJIDLists
{
    NSLog(@"%s %@", __PRETTY_FUNCTION__, roomJid);
    ChatBox *chatBox = [[AppFacade share] getChatBox:roomJid];
    if (!chatBox) {
        [[ChatFacade share] createChatBox:roomJid isMUC:YES];
        chatBox = [[AppFacade share] getChatBox:roomJid];
    }
    
    GroupObj *grp = [[AppFacade share] getGroupObj:roomJid];
    NSString *groupPassword = @"";
    if (grp) {
        groupPassword = grp.groupPassword;
    }
    
    if ([[roomJid componentsSeparatedByString:@"@"] count] == 2) {
        NSDictionary *groupUpdateDic = @{kROOMJID:[[roomJid componentsSeparatedByString:@"@"] objectAtIndex:0],
                                         kIMEI: [[ContactFacade share] getIMEI],
                                         kIMSI: [[ContactFacade share] getIMSI],
                                         kTOKEN: [[ContactFacade share] getTokentTenant],
                                         kROOM_HOST: [[roomJid componentsSeparatedByString:@"@"] objectAtIndex:1],
                                         kMASKINGID: [[ContactFacade share] getMaskingId],
                                         kMESSAGETYPE: [kBODY_MT_NOTI_GRP_CREATE lowercaseString],
                                         kMEMBER_JID_LIST: memberJIDLists,
                                         kOCCUPANTS: [[ContactFacade share] getJid:YES],
                                         kROOMNAME: [Base64Security generateBase64String:[[ChatFacade share] getGroupName:roomJid]],
                                         kROOMLOGOURL: [[ChatFacade share] getGroupLogoUrl:roomJid],
                                         kROOM_PASSWORD: groupPassword
                                         };
        [[ChatFacade share] sendNoticeForGroupUpdate:groupUpdateDic];
        
        // sent to myself db
        NSMutableDictionary *infoDic = [[NSMutableDictionary alloc] init];
        [infoDic setObject:roomJid forKey:kROOMJID];
        [infoDic setObject:[[ContactFacade share] getJid:YES] forKey:kOCCUPANTS];
        [infoDic setObject:[NSDate date] forKey:kROOM_NOTICE_DELAY_DATE];
        [[ChatFacade share] noticeGroupCreated:infoDic];
    }
    
    if (hasSelectedAvatar) {
        NSDictionary *info = @{kMUC_ROOM_JID: roomJid,
                               kROOM_IMAGE_DATA: [ChatAdapter scaleImage:btnAvatar.imageView.image rate:3]
                               };
        [[ChatFacade share] setChatRoomLogo:info];
        hasSelectedAvatar = NO;
    }
    groupNameCopy = @"";
    [self dismissViewControllerAnimated:NO completion:^(void){
        [[CWindow share] showChatList];
        [[ChatFacade share] moveToChatView:chatBox.chatboxId];
        self.navigationItem.rightBarButtonItem.enabled = TRUE;
    }];
}

- (void)didFailCreateGroup {
    [[CWindow share] hideLoading];
    if(self.navigationController){
        [[CAlertView new] showWarning:WARNING_CREATE_GROUP_FAIL TARGET:self ACTION:@selector(createGroup)];
        self.navigationItem.rightBarButtonItem.enabled = TRUE;
    }
}

- (IBAction)textFieldDidChange:(id)sender {
    NSUInteger newLength = txtGroupName.text.length;
    int numberRest = (int)(MAX_LENGHT_TEXT_GROUP_NAME - newLength);
    
    lblTextCounter.text = [NSString stringWithFormat:@"%d",numberRest];
    if (newLength > MAX_LENGHT_TEXT_GROUP_NAME) {
        [txtGroupName deleteBackward];
        [txtGroupName resignFirstResponder];
        return;
    }
}

+(NewGroupCreate *)share{
    static dispatch_once_t once;
    static NewGroupCreate * share;
    dispatch_once(&once, ^{
        share = [self new];
    });
    return share;
}

- (IBAction)clickAddPhoto:(id)sender
{
    self.btnAvatar.enabled = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.btnAvatar.enabled = YES;
            [photoAS showInView:self.view];
    });
    [txtGroupName resignFirstResponder];
}

-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    groupNameCopy = txtGroupName.text;
    groupNameLenghBackup = lblTextCounter.text;
    [[UINavigationBar appearance]setTintColor:[UIColor whiteColor]];
    if([actionSheet numberOfButtons] == 3){
        switch (buttonIndex) {
            case 0:{
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
                break;
            case 1:{
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
                break;
            case 2:
                break;
            default:
                break;
        }
    }
    else{
        switch (buttonIndex) {
            case 0:
                break;
            case 1:{
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
                break;
            case 2:{
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
                break;
            default:
                break;
        }
    }
}

- (void)imagePicker:(GKImagePicker *)imagePicker pickedImage:(UIImage *)image{
    if(!image){
        [[CAlertView new] showError:ERROR_CANNOT_CHOOSE_IMAGE];
        return;
    }
    groupAvatar = image;
    groupAvatarBackup = groupAvatar;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [txtGroupName becomeFirstResponder];
    });
    
    [self updateAvatarButton: groupAvatarBackup];
    if (UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM() && imagePicker.imagePickerController.sourceType != UIImagePickerControllerSourceTypeCamera)
        [self.popoverController dismissPopoverAnimated:YES];
    else
        [self.imagePicker.imagePickerController dismissViewControllerAnimated:YES completion:nil];
}

- (void)showOption:(NSInteger)type {
    
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
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad && imagePicker.imagePickerController.sourceType != UIImagePickerControllerSourceTypeCamera) {
            
            self.popoverController = [[UIPopoverController alloc] initWithContentViewController:self.imagePicker.imagePickerController];
            [self.popoverController presentPopoverFromRect:btnAvatar.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        } else
            [self presentViewController:self.imagePicker.imagePickerController animated:YES completion:nil];
    }
    else{
        [[CAlertView new] showError:mERROR_MEDIA_NOT_AVAILABLE];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

#pragma UiTableView
-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [arrGroupFriend count];
}

-(void) tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    [tblContact cellForRowAtIndexPath:indexPath].backgroundColor = COLOR_247247247;
}
-(void) tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    [tblContact cellForRowAtIndexPath:indexPath].backgroundColor = [UIColor clearColor];
}

-(void) tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tblContact cellForRowAtIndexPath:indexPath].backgroundColor = [UIColor clearColor];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellID =  @"ChatComposeCell";
	ChatComposeCell *cell = [tblContact dequeueReusableCellWithIdentifier:cellID];
    if(!arrGroupFriend)
        return cell;
    
    if(!cell){
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ChatComposeCell" owner:nil options:nil];
    	cell = (ChatComposeCell*)[nib objectAtIndex:0];
    }
    if (indexPath.row == 0) {
        UILabel *lblLine = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 1)];
        lblLine.backgroundColor = [UIColor lightGrayColor];
        lblLine.alpha = 0.5;
        [cell.containerView addSubview:lblLine];
    }
    [cell displayCell:[arrGroupFriend objectAtIndex:indexPath.row]];
	return cell;
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [txtGroupName resignFirstResponder];
}

@end
