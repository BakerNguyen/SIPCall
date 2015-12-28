//
//  MoreKeyboard.h
//  JuzChatV2
//
//  Created by TrungVN on 12/4/13.
//  Copyright (c) 2013 mTouche. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MoreKeyboard : UIView <UIScrollViewDelegate,UINavigationControllerDelegate, GKImagePickerDelegate>
@property(nonatomic,assign) NSInteger CameraType;

-(void) show;
-(void) hide;

@property (nonatomic, strong) IBOutlet UIScrollView* scrMore;

@property (nonatomic, strong) IBOutlet UIButton* btnChoosePhoto;
@property (nonatomic, retain) IBOutlet UIButton* btnChooseVideo;
@property (nonatomic, strong) IBOutlet UIButton* btnTakePhoto;
@property (nonatomic, strong) IBOutlet UIButton* btnTakeVideo;
@property (nonatomic, strong) IBOutlet UIButton* btnLocation;
@property (nonatomic, retain) IBOutlet UIButton *btnFreeCall;

@property (nonatomic, strong) GKImagePicker* mediaPicker;

-(IBAction) freeCall;
-(IBAction) choosePhoto;
-(IBAction) chooseVideo;
-(IBAction) takePhoto;
-(IBAction) takeVideo;

@end
