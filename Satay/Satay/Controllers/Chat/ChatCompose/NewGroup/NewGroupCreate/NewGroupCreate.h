//
//  CreateNewGroup.h
//  KryptoChat
//
//  Created by TrungVN on 5/14/14.
//  Copyright (c) 2014 mTouche. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewGroupCreate : UIViewController <UIActionSheetDelegate,UINavigationControllerDelegate, GKImagePickerDelegate, UITextFieldDelegate,UITableViewDelegate, UITableViewDataSource, NewGroupCreateDelegate>

@property (nonatomic, retain) NSMutableArray* arrGroupFriend;
@property (nonatomic, retain) NSMutableArray* arrContact;
@property (strong, nonatomic) IBOutlet UITableView *tblContact;

@property (nonatomic, retain) IBOutlet UIButton* btnAvatar;
@property (nonatomic, retain) UIActionSheet *photoAS;
@property (nonatomic, retain) UIActionSheet *photoASandProfile;

@property (nonatomic, retain) UIImage* groupAvatar;
@property (nonatomic, retain) UIImage* groupAvatarBackup;
//@property (nonatomic, retain) UIImagePickerController *pickerAvatar;
@property (nonatomic, strong) GKImagePicker *imagePicker;
@property (nonatomic, strong) UIPopoverController *popoverController;
@property (nonatomic, retain) IBOutlet UITextField* txtGroupName;
@property (nonatomic, retain) IBOutlet UILabel* lblTextCounter;

@property (nonatomic, retain) IBOutlet UIActivityIndicatorView* loadingview;

+(NewGroupCreate *)share;

-(void) updateAvatarButton: (UIImage *) avatar;
-(void) createGroup;

- (void)didFailCreateGroup;
- (IBAction)textFieldDidChange:(id)sender;

- (IBAction)clickAddPhoto:(id)sender;

@end
