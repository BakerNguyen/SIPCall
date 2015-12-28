//
//  MyProfileViewController.h
//  KryptoChat
//
//  Created by ENCLAVEIT on 4/17/14.
//  Copyright (c) 2014 mTouche. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "HeaderView.h"
#import "ProfileContentCell.h"
#import "DisplayName.h"
#import "StatusProfile.h"
#import "SyncContacts.h"
#import "ViewPhoto.h"

@interface MyProfile : UIViewController <UITableViewDelegate, UITableViewDataSource, UINavigationBarDelegate,UIActionSheetDelegate, UINavigationControllerDelegate, GKImagePickerDelegate>{

    HeaderView *headerProfile;
    UIColor *hintTextColor;
    UIColor *bgTblViewColor;
    UIColor *colorOfBorder;
    UIButton *buttonClose;
    DisplayName *displayNameViewController;
    StatusProfile *statusProfileViewController;
    SyncContacts *syncContactsViewController;
    ViewPhoto *fullPhotoViewController;
    UIImage *chosenImage;
    NSURL *imageURL;
}

@property (nonatomic,retain) UIView *containerView;

@property (strong, nonatomic) IBOutlet UITableView *tblProfileView;

@property (strong, nonatomic) IBOutlet HeaderView *headerProfile;
@property (strong, nonatomic) UIImageView *avatarImgView;

@property (strong, nonatomic) NSString *fullPhoneNumber;
@property (strong, nonatomic) NSString *emailAddress;
//@property (nonatomic, retain) UIImagePickerController* avatarPicker;
@property (nonatomic, strong) GKImagePicker *imagePicker;
@property (nonatomic, strong) UIPopoverController *popoverController;

- (IBAction)clickAddPhoto:(id)sender;

-(void) closeView;
-(id) init;

-(void) moveToSyncContact;
-(void) updateAvatarSuccess;
-(void) updateAvatarFailed;

+(MyProfile *)share;

@end
