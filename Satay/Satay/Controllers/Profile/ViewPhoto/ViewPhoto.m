//
//  FullPhotoViewController.m
//  KryptoChat
//
//  Created by ENCLAVEIT on 4/29/14.
//  Copyright (c) 2014 mTouche. All rights reserved.
//

#import "ViewPhoto.h"
#import "MyProfile.h"


@interface ViewPhoto ()
{
    UIImage *imgProfile;
}
@end

@implementation ViewPhoto

@synthesize buttonClose;
@synthesize containerView;
@synthesize bgViewColor;
@synthesize localImages;
@synthesize imgView;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        screenWidth = [[UIScreen mainScreen] applicationFrame].size.width;
        screenHeight = [[UIScreen mainScreen] applicationFrame].size.height;
        bgViewColor = COLOR_247247247;
        
        [ChatFacade share].viewPhotoDelegate = self;
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    containerView.backgroundColor = bgViewColor;
    
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem createRightButtonTitle:_CLOSE Target:self Action:@selector(backToMyProfile)];
    

    self.navigationItem.title = TITLE_PROFILE_PHOTO;
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    UIView *subView;
//    if (IS_IPHONE5) {
//        subView = [[UIView alloc] initWithFrame:CGRectMake(0, 434, 320, 70)];
//    }else
//        subView = [[UIView alloc] initWithFrame:CGRectMake(0, 346, 320, 70)];
    
    subView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:subView];
}

- (void) showProfileImage:(UIImage *)profileImage
{
    imgProfile = profileImage;
}
- (void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:animated];
    
    if (self.navigationController.viewControllers.count > 1 &&
        [self.navigationController.viewControllers[self.navigationController.viewControllers.count-2] isKindOfClass:[MyProfile class]]){
        //Display full owner photo
        imgView.image = [[ContactFacade share] getProfileAvatar];
    }
    else
        imgView.image = imgProfile;
    
    imgView.backgroundColor = [UIColor blackColor];
    imgView.contentMode = UIViewContentModeScaleAspectFit;

}

-(void)backToMyProfile{
    
  [self.navigationController popViewControllerAnimated:YES];
    
}

@end
