//
//  ImagePreviewView.m
//  JuzChatV2
//
//  Created by Low Ker Jin on 7/9/13.
//  Copyright (c) 2013 mTouche. All rights reserved.
//
#import "ImagePreview.h"

@interface ImagePreview ()

@end

@implementation ImagePreview

@synthesize cancelButton;
@synthesize SendButton;
@synthesize SelectedImageView;
@synthesize picker;
@synthesize image;
@synthesize chatBoxID;

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    SelectedImageView.image = image;
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem createLeftButtonTitle:_BACK Target:self.navigationController Action:@selector(popViewControllerAnimated:)];
}

-(void)viewDidLoad
{
    [super viewDidLoad];
     self.title = TITLE_PHOTO;
}

-(IBAction) sendButtonPressed:(id)sender{
    if (!chatBoxID){
        NSLog(@"%s: FAILED", __PRETTY_FUNCTION__);
        return;
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
    [[ChatFacade share] sendImage:image chatboxId:chatBoxID];
}

-(IBAction) cancelButtonPressed:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

+(ImagePreview *)share{
    static dispatch_once_t once;
    static ImagePreview* share;
    dispatch_once(&once, ^{
        share = [self new];
    });
    return share;
}

@end
