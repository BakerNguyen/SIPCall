//
//  MyProfileViewController.m
//  KryptoChat
//
//  Created by ENCLAVEIT on 4/17/14.
//  Copyright (c) 2014 mTouche. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>
#import "MyProfile.h"
#import "AppDelegate.h"
#import "ProfileContentCell.h"

#define SPACE_HEIGHT 20
#define ACTION_SHEET_UPLOAD_AVATAR_TAG 1
#define ACTION_SHEET_COPY_MASKINGID_TAG 2

@interface MyProfile ()

@property (assign) BOOL isAvatar;

@end

@implementation MyProfile

@synthesize containerView;
@synthesize headerProfile;
@synthesize tblProfileView;
@synthesize fullPhoneNumber;
@synthesize isAvatar;
@synthesize emailAddress;
//@synthesize avatarPicker;
@synthesize imagePicker;
@synthesize popoverController;

-(id)init{

    if (self = [super init]) {
        bgTblViewColor = COLOR_247247247;
        hintTextColor = COLOR_128128128;
        colorOfBorder = COLOR_211211211;
    }
    return self;
}


-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
//    avatarPicker = [UIImagePickerController new];
//    avatarPicker.delegate = self;
//    avatarPicker.allowsEditing = NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    tblProfileView.frame = CGRectMake(-2, 0, tblProfileView.frame.size.width +2 , tblProfileView.frame.size.height);
    // Do any additional setup after loading the view from its nib.
    
    [headerProfile setBackgroundColor:bgTblViewColor];
    headerProfile.loadingAvatarImage.hidden = YES;
    
    [tblProfileView setTableHeaderView:headerProfile];
 
    //style for Profile image
    headerProfile.btnProfileImage.layer.cornerRadius = headerProfile.btnProfileImage.width/2;
    headerProfile.btnProfileImage.imageView.contentMode = UIViewContentModeScaleAspectFill;
    
    [tblProfileView setBackgroundColor:bgTblViewColor];
    
    headerProfile.kryptoMaskingId.text = [[ContactFacade share] getMaskingId];
    self.navigationItem.title = TITLE_MY_PROFILE;
    
    [ContactFacade share].myProfileDelegate = self;
    fullPhoneNumber = [[ContactFacade share] getMSISDN];
}

-(void)viewWillAppear:(BOOL)animated{
    [self updateAvatarSuccess];
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem createRightButtonTitle:_CLOSE Target:self Action:@selector(closeView)];
    
    if([UIApplication sharedApplication].statusBarHidden){
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[self tblProfileView] reloadData];
    });
    [[LogFacade share] trackingScreen:Profile_Category];
}

-(void) closeView{
   __block bool backToPreviousView = NO;
    [self dismissViewControllerAnimated:YES completion:^{
        backToPreviousView = YES;
    }];
}

- (IBAction)clickAddPhoto:(id)sender {
    UIActionSheet* actionSheet = nil;
    if ([[[ContactFacade share] getProfileAvatar] isEqual:[UIImage imageNamed:IMG_S_EMPTY]]) {
        isAvatar = FALSE;
        actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:_CANCEL destructiveButtonTitle:nil otherButtonTitles:ALERT_BUTTON_CHOOSE_FROM_LIBRARY, ALERT_BUTTON_TAKE_PHOTO, nil];
    }
    else{
        isAvatar = TRUE;
        actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:_CANCEL destructiveButtonTitle:nil otherButtonTitles:ALERT_BUTTON_VIEW_PROFILE_PHOTO,ALERT_BUTTON_CHOOSE_FROM_LIBRARY, ALERT_BUTTON_TAKE_PHOTO, nil];
    }
    actionSheet.tag = ACTION_SHEET_UPLOAD_AVATAR_TAG;
    [actionSheet showInView:self.view];
}

-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    switch (actionSheet.tag) {
        case ACTION_SHEET_COPY_MASKINGID_TAG:
            if (buttonIndex == 0) {
                [[ChatFacade share] copyToClipboard:[[ContactFacade share] getMaskingId]];
            }
            break;
            
        case ACTION_SHEET_UPLOAD_AVATAR_TAG:
            switch (buttonIndex) {
                case 0:
                    if (!isAvatar) {
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
                    else{
                        fullPhotoViewController = [[ViewPhoto alloc] initWithNibName:@"ViewPhoto" bundle:nil];
                        fullPhotoViewController.navigationItem.hidesBackButton = YES;
                        fullPhotoViewController.localImages = [[NSArray alloc] initWithObjects:imageURL,nil];
                        [self.navigationController pushViewController:fullPhotoViewController animated:YES];
                    }
                    break;
                case 1:
                    if (!isAvatar) {
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
                    else{
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
                case 2:
                    if (!isAvatar) {
                        [self.headerProfile.btnProfileImage setSelected:NO];
                    }
                    else{
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
                case 3:
                    [self.headerProfile.btnProfileImage setSelected:NO];
                    break;
                    
                default:
                    break;
            }
            break;
            
        default:
            break;
    }
}

- (void)imagePicker:(GKImagePicker *)imagePicker pickedImage:(UIImage *)image{
    [[ContactFacade share] uploadAvatar:image];
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
        self.imagePicker.croptEnable = YES;
        self.imagePicker.delegate = self;
        self.imagePicker.resizeableCropArea = YES;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad && imagePicker.imagePickerController.sourceType != UIImagePickerControllerSourceTypeCamera) {
            
            self.popoverController = [[UIPopoverController alloc] initWithContentViewController:self.imagePicker.imagePickerController];
            
            [self.popoverController presentPopoverFromRect:headerProfile.btnProfileImage.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        } else
            [self presentViewController:self.imagePicker.imagePickerController animated:YES completion:nil];
    }
    else{
        [[CAlertView new] showError:mERROR_MEDIA_NOT_AVAILABLE];
    }
}

-(void) updateAvatarSuccess{
    if ([[[ContactFacade share] getProfileAvatar] isEqual:[UIImage imageNamed:IMG_S_EMPTY]])
        return;
    [headerProfile.btnProfileImage setImage:[[ContactFacade share] getProfileAvatar] forState:UIControlStateNormal];
    [headerProfile.btnProfileImage setImage:[[ContactFacade share] getProfileAvatar] forState:UIControlStateHighlighted];
    [[LogFacade share] createEventWithCategory:Profile_Category action:addProfilePhoto_Action label:labelAction];
}
-(void) updateAvatarFailed{
    [[CWindow share] hideLoading];
    [[CAlertView new] showError:_ALERT_FAILED_UPLOAD];
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
    [[UINavigationBar appearance]setTintColor:[UIColor whiteColor]];
    navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
    
    [[UIBarItem appearance] setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIFont fontWithName:@"" size:15.0], NSFontAttributeName,
      nil]forState:UIControlStateNormal];
    
    UIButton* cancel = [[UIButton alloc] initWithFrame:CGRectMake(10, 0, 50, 40)];
    [cancel addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
    [cancel setTitle:_CANCEL forState:UIControlStateNormal];
    [cancel.titleLabel setFont:[UIFont systemFontOfSize:15]];
    UIBarButtonItem  *btn_cancel = [[UIBarButtonItem alloc] initWithCustomView:cancel];
    
    viewController.navigationItem.rightBarButtonItem= btn_cancel;
    
    [viewController.navigationItem.rightBarButtonItem setTitlePositionAdjustment:UIOffsetMake(0.0, 0) forBarMetrics:UIBarMetricsDefault];
    
}
- (void) cancel: (id) picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}


+(MyProfile *)share{
    static dispatch_once_t once;
    static MyProfile * share;
    dispatch_once(&once, ^{
        share = [[self alloc] init];
    });
    return share;
}

////////////////////////////////////////////////////////////////////////////////////
#pragma mark UITableView
////////////////////////////////////////////////////////////////////////////////////

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
	return 5;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.section) {
        case 0:
            if (indexPath.row == 1)
                return 72;
            else  if (indexPath.row == 2)
                return SPACE_HEIGHT;
            else
                return 44;
            break;
        case 1:
            if (indexPath.row == 1) {
                return 17;
            }else
                return 44;
            break;
        case 2:
            if (indexPath.row == 0)
                return 21;
            else if (indexPath.row == 1)
                return 5;
            else if (indexPath.row == 3)
                return SPACE_HEIGHT;
            else
                return 44;
            break;
        case 3:
            if(indexPath.row==1)
                return 100;
            else
                return 44;
            break;
        default:
            return 44;
            break;
    }
}

-(void) tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    ((ProfileContentCell*) [tableView cellForRowAtIndexPath:indexPath]).labelCell.textColor = hintTextColor;
    ((ProfileContentCell*) [tableView cellForRowAtIndexPath:indexPath]).labelCell.font = [UIFont boldSystemFontOfSize:FONT_TEXT_SIZE_15];
}
-(void) tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    ((ProfileContentCell*) [tableView cellForRowAtIndexPath:indexPath]).labelCell.textColor = hintTextColor;
    ((ProfileContentCell*) [tableView cellForRowAtIndexPath:indexPath]).labelCell.font = [UIFont fontWithName:@"System" size:FONT_TEXT_SIZE_15];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.tblProfileView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.section) {
        case 0:
        {
            switch (indexPath.row) {
                case 0:
                {
                    UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:_CANCEL destructiveButtonTitle:nil otherButtonTitles:_COPY_MASKINGID, nil];
                    [actionSheet setTag:ACTION_SHEET_COPY_MASKINGID_TAG];
                    [actionSheet showInView:self.view];
                }
                    break;
                default:
                    break;
            }
            
        }break;
        case 1:
            if (indexPath.row == 0) {
                if ([[ContactFacade share] isAccountRemoved]) {
                    [[CAlertView new] showError:ERROR_ACCOUNT_REMOVED];
                    return;
                }
                displayNameViewController = [[DisplayName alloc] init];
                displayNameViewController.navigationItem.hidesBackButton = YES;
                [self.navigationController pushViewController:displayNameViewController animated:YES];
            }
            break;
        case 2:
            if (indexPath.row == 2) {
                if ([[ContactFacade share] isAccountRemoved]) {
                    [[CAlertView new] showError:ERROR_ACCOUNT_REMOVED];
                    return;
                }
                
                statusProfileViewController = [[StatusProfile alloc] init];
                statusProfileViewController.navigationItem.hidesBackButton = YES;
                [self.navigationController pushViewController:statusProfileViewController animated:YES];
            }
            break;
        case 3:
        {
            switch (indexPath.row) {
                case 0:
                {
                    if ([[ContactFacade share] isAccountRemoved]) {
                        [[CAlertView new] showError:ERROR_ACCOUNT_REMOVED];
                        return;
                    }
                    
                    [KeyChainSecurity storeString:IS_NO Key:kIS_RE_LOGIN_ACCOUNT];
                    
                    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized){
                        //NSLog(@"Authorized");
                        if (!([[ContactFacade share] getSyncContactFlag])) {
                            [self moveToSyncContact];
                        }
                    } else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
                        // Request authorization to Address Book
                        ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
                        ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
                            if (granted) {
                                // First time access has been granted, add the contact
                                [self performSelectorOnMainThread:@selector(moveToSyncContact) withObject:nil waitUntilDone:YES];
                            }
                            else
                            {
                                [tblProfileView reloadData];
                                NSLog(@"User Not allow > Contacts Phonebook ");
                            }
                        });
                    }
                    
                }break;
                default:
                    break;
            }
            
        }break;
        default:
            break;
    }
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex{
    
    switch (sectionIndex) {
        case 0:
            return 3;
            break;
        case 1:
            return 2;
            break;
        case 2:
            return 4;
            break;
        case 3:
              if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusDenied)
                  return 2;
            else
                return 1;
            break;
        default:
            return 0;
            break;
    }

    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    static NSString *cellID = @"ProfileContentCell";
    
    ProfileContentCell *cell = (ProfileContentCell *)[tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ProfileContentCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    cell.labelCell.hidden = NO;
    
    switch (indexPath.section) {
        case 0:
        {
            switch (indexPath.row) {
                case 0:
                {
                    cell.contentCell.text = LABEL_ONE_KRYPTO_ID;
                    cell.contentCell.font = [UIFont systemFontOfSize:FONT_TEXT_SIZE_15];
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
                    [cell.labelCell setTextAlignment:NSTextAlignmentRight];
                    cell.labelCell.textColor = hintTextColor;
                    cell.layer.borderWidth = 1;
                    cell.layer.borderColor  = colorOfBorder.CGColor;
                    
                    cell.labelCell.text = [[ContactFacade share] getMaskingId];;
                    
                    /*
                    UILabel* version = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width-30, cell.frame.size.height)];
                    version.textAlignment = NSTextAlignmentRight;
                    version.font = [UIFont systemFontOfSize:14];
                    version.textColor = COLOR_128128128;
                    
                   // version.text = [NSString stringWithFormat:@"%@",[[DaoHandler share] getUDValueByKey:MASKING_ID]];
                    [cell addSubview:version];
                     */
                    
                    
                }break;
                case 1:
                {
                    cell.contentCell.lineBreakMode = NSLineBreakByWordWrapping;
                    cell.contentCell.numberOfLines = 4;
                    
                    //cell.contentCell.frame = CGRectMake(15, 1, 270, 72);
                    cell.contentCell.text = LABEL_MASKING_ID_UNIQUE_KEY_YOU_AND_YOUR_FRIEND; //Hint for display name
                    [cell.contentCell sizeToFit];
                    cell.contentCell.textColor = hintTextColor;
                    cell.contentCell.font = [UIFont systemFontOfSize:FONT_TEXT_SIZE_14];
                    cell.labelCell.hidden = YES;
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    cell.backgroundColor = bgTblViewColor;
                    
                }break;
                case 2:
                {
                    //cell.contentCell.frame = CGRectMake(15, 5, 270, SPACE_HEIGHT);
                    cell.contentCell.text = @""; //Hint for display name
                    cell.contentCell.textColor = hintTextColor;
                    cell.contentCell.font = [UIFont systemFontOfSize:FONT_TEXT_SIZE_14];
                    cell.labelCell.hidden = YES;
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    cell.backgroundColor = bgTblViewColor;
                    
                }break;
                default:
                    break;
            }
        }break;
            
        case 1:
        {
            switch (indexPath.row) {
                case 0:
                {
                    
                    cell.contentCell.text = LABEL_DISPLAY_NAME;
                    cell.contentCell.font = [UIFont systemFontOfSize:FONT_TEXT_SIZE_15];
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
                    [cell.labelCell setTextAlignment:NSTextAlignmentRight];
                    cell.labelCell.textColor = hintTextColor;
                    cell.layer.borderWidth = 1;
                    cell.layer.borderColor  = colorOfBorder.CGColor;
                    
                    NSString *displayName = [[ContactFacade share] getDisplayName];
                   
                    if (displayName.length > 0) {
                        cell.labelCell.text = displayName;
                    }
                    else{
                        cell.labelCell.text = [NSString stringWithFormat:LABEL_OPTIONAL];
                    }
                    
                }break;
                case 1:
                {
                    //cell.contentCell.frame = CGRectMake(15, 5, 270, 17);
                    cell.contentCell.text = @""; //Hint for display name
                    cell.contentCell.textColor = hintTextColor;
                    cell.contentCell.font = [UIFont systemFontOfSize:FONT_TEXT_SIZE_14];
                    cell.labelCell.hidden = YES;
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    cell.backgroundColor = bgTblViewColor;
                    
                }break;
                default:
                    break;
            }
        }break;
        case 2:
        {
            switch (indexPath.row) {
                case 0:
                {
                    //cell.contentCell.frame = CGRectMake(15, 6, 270, 15);
                    cell.contentCell.text = LABEL_WHATS_UP;
                    cell.contentCell.textColor = hintTextColor;
                    cell.contentCell.font = [UIFont systemFontOfSize:FONT_TEXT_SIZE_15];
                    cell.labelCell.hidden = YES;
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    cell.backgroundColor = bgTblViewColor;
                }break;
                    
                case 1:
                {
                    //cell.contentCell.frame = CGRectMake(15, 6, 270, 5);
                    cell.contentCell.text = @"";
                    cell.contentCell.textColor = hintTextColor;
                    cell.contentCell.font = [UIFont systemFontOfSize:FONT_TEXT_SIZE_15];
                    cell.labelCell.hidden = YES;
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    cell.backgroundColor = bgTblViewColor;
                }break;
                    
                case 2:
                {
                    
                    cell.contentCell.text = [[ProfileAdapter share] getProfileStatus].length > 0 ? [[ProfileAdapter share] getProfileStatus] : DEFAULT_STATUS_AVAILABLE;
                    cell.contentCell.font = [UIFont systemFontOfSize:FONT_TEXT_SIZE_15];
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
                    cell.labelCell.hidden = YES;
                    //[cell.labelCell setTextAlignment:NSTextAlignmentRight];
                    //cell.labelCell.textColor = hintTextColor;
                    cell.layer.borderWidth = 1;
                    cell.layer.borderColor  = colorOfBorder.CGColor;
                    
                }break;
                case 3:
                {
                    //cell.contentCell.frame = CGRectMake(15, 6, 270, SPACE_HEIGHT);
                    cell.contentCell.text = @"";
                    cell.contentCell.textColor = hintTextColor;
                    cell.contentCell.font = [UIFont systemFontOfSize:FONT_TEXT_SIZE_15];
                    cell.labelCell.hidden = YES;
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    cell.backgroundColor = bgTblViewColor;
                }break;
            }
            
        }break;
        case 3:
        {
            switch (indexPath.row) {
                case 0:
                {
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    cell.layer.borderWidth = 1;
                    cell.layer.borderColor  = colorOfBorder.CGColor;
                    
                    cell.contentCell.text = LABEL_MOBILE_CONTACTS;
                    cell.contentCell.font = [UIFont systemFontOfSize:FONT_TEXT_SIZE_15];
                    [cell.labelCell setTextAlignment:NSTextAlignmentRight];
                    
                    /*
                    UILabel* mobile_contact = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width-30, cell.frame.size.height)];
                    mobile_contact.textAlignment = NSTextAlignmentRight;
                    mobile_contact.font = [UIFont systemFontOfSize:14];
                    mobile_contact.textColor = COLOR_128128128;
                    mobile_contact.text = LABEL_DISABLE;
                    */
                    /*
                     kABAuthorizationStatusNotDetermined > 0
                     kABAuthorizationStatusRestricted > 1
                     kABAuthorizationStatusDenied > 2
                     kABAuthorizationStatusAuthorized > 3
                     */
                    
                    //not yet sync contact
                    if (![[ContactFacade share] getSyncContactFlag]) {
                        //user did not choose
                        cell.labelCell.text = LABEL_OFF;
                        if(ABAddressBookGetAuthorizationStatus()== kABAuthorizationStatusNotDetermined)
                        {
                            cell.contentCell.text =LABEL_SYNC_CONTACTS;
                        }//user not allow >Setting >Privacy > Contacts >Disable
                        else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusDenied){
                            cell.labelCell.text = LABEL_DISABLE;
                            cell.contentCell.text = LABEL_MOBILE_CONTACTS;
        
                        } else {
                            //user allow >Setting >Privacy > Contacts
                            cell.contentCell.text = LABEL_SYNC_CONTACTS;
                        }
                    }
                    else{//user had sync contacts
                        if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusDenied){
                            cell.labelCell.text = LABEL_DISABLE;
                            cell.accessoryType = UITableViewCellAccessoryNone;
                        } else {
                            //Sync contact & allow  > Display Phone no
                            if([[ContactFacade share] getSyncContactFlag])
                            cell.labelCell.text = [[ContactFacade share] getMSISDN];
                            cell.accessoryType = UITableViewCellAccessoryNone;
                            cell.selectionStyle = UITableViewCellSelectionStyleNone;
                        }
                    }
                    
                    
                    cell.labelCell.textColor = hintTextColor;
                    [cell.labelCell setTextAlignment:NSTextAlignmentRight];
                    //[cell addSubview:mobile_contact];
                    
                }break;
                    
                     case 1:{
                      if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusDenied){
                         cell.contentCell.lineBreakMode = NSLineBreakByWordWrapping;
                         cell.contentCell.numberOfLines = 3;
                         
                         //cell.contentCell.frame = CGRectMake(15, 1, 270, 100);
                         cell.contentCell.text =LABEL_ENABEL_ACCESS_TO_YOUR_CONTACTS_IN_IPHONE; //Hint for display name
                         [cell.contentCell sizeToFit];
                         cell.contentCell.textColor = hintTextColor;
                         cell.contentCell.font = [UIFont systemFontOfSize:FONT_TEXT_SIZE_14];
                          cell.labelCell.hidden = YES;
                         cell.accessoryType = UITableViewCellAccessoryNone;
                         cell.selectionStyle = UITableViewCellSelectionStyleNone;
                         cell.backgroundColor = bgTblViewColor;
                      }
                     
                     }break;
                    
                default:
                    break;
            }
            
        }break;
        default:
            break;
    }
    

	return cell;
}

-(void) moveToSyncContact{
    syncContactsViewController = [SyncContacts share];
    syncContactsViewController.navigationItem.hidesBackButton = YES;
    [self.navigationController pushViewController:syncContactsViewController animated:YES];
}

- (void) reloadTableData
{
    [tblProfileView reloadData];
}
@end
