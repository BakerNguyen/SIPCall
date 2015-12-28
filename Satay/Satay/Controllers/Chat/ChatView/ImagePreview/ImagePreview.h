//
//  ImagePreviewView.h
//  JuzChatV2
//
//  Created by Low Ker Jin on 7/9/13.
//  Copyright (c) 2013 mTouche. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface ImagePreview : UIViewController

@property (nonatomic,strong) NSString* chatBoxID;
@property (nonatomic,strong) IBOutlet UIBarButtonItem *cancelButton;
@property (nonatomic,strong) IBOutlet UIBarButtonItem *SendButton;
@property (nonatomic,strong) IBOutlet UIImageView *SelectedImageView;
@property (nonatomic,strong) UIImage *image;
@property (nonatomic,strong) UIImagePickerController *picker;

-(IBAction) sendButtonPressed:(id)sender;
-(IBAction) cancelButtonPressed:(id)sender;

+ (ImagePreview *)share;

@end