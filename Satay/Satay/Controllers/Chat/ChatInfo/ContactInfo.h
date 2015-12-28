//
//  ContactInfo.h
//  KryptoChat
//
//  Created by TrungVN on 6/4/14.
//  Copyright (c) 2014 mTouche. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

#import "HeaderContact.h"
#import "FooterInfo.h"
#import "InfoCell.h"
#import "UpdateName.h"

@interface ContactInfo : UIViewController
<UITableViewDelegate,
UITableViewDataSource,
UIActionSheetDelegate,
UINavigationControllerDelegate,
GKImagePickerDelegate,
UIActionSheetDelegate, MWPhotoBrowserDelegate>

@property BOOL isSingleInfo;

@property (nonatomic, retain) IBOutlet UITableView* tblSetting;
@property (nonatomic, strong) GKImagePicker *imagePicker;
@property (nonatomic, strong) UIPopoverController *popoverController;
@property (nonatomic, retain) IBOutlet HeaderContact* headerView;
@property (nonatomic, retain) IBOutlet FooterInfo* footerInfo;
@property (strong, nonatomic) UIActionSheet *standardUIAS;
@property (nonatomic, retain) NSMutableArray* arrGroupFriend;
@property (nonatomic, retain) NSMutableArray* arrAddingMembers;
@property (nonatomic, retain) NSMutableArray* arrMemberContacts;
@property (nonatomic, retain) NSMutableArray* arrMediaMessages;
@property (nonatomic, strong) MWPhotoBrowser *mwPhotoBrowser;
@property (nonatomic, strong) MPMoviePlayerViewController* mediaPlayer;

@property (nonatomic, retain) IBOutlet UIButton* btnPlayMedia;
@property (nonatomic, retain) NSMutableArray* mediaArray;

-(BOOL) checkInfoAvailable:(NSString*) chatBoxId;
-(void) buildView;
-(void) resetView;
-(void) backView;

-(void) changeAlertChat:(id)sender;
-(void) changeSoundChat:(id)sender;
-(void) changeEncryptChat:(id)sender;
-(IBAction) changeLogo;

@property (nonatomic, retain) ChatBox* chatBox;
@property (nonatomic, retain) Contact* contact;
@property (nonatomic, retain) GroupObj* group;

-(void) displayPhotoBrower:(NSMutableArray*) photoArray
                photoIndex:(NSInteger) photoIndex;

- (void)addParticipant;

+(ContactInfo *)share;

-(void) removeKVO;
-(void) addKVO;

@end
