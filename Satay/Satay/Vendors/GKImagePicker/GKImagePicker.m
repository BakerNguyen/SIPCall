//
//  GKImagePicker.m
//  GKImagePicker
//
//  Created by Georg Kitz on 6/1/12.
//  Copyright (c) 2012 Aurora Apps. All rights reserved.
//

#import "GKImagePicker.h"
#import "GKImageCropViewController.h"

@interface GKImagePicker ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate, GKImageCropControllerDelegate>
@property (nonatomic, strong, readwrite) UIImagePickerController *imagePickerController;
- (void)_hideController;
@end

@implementation GKImagePicker

#pragma mark -
#pragma mark Getter/Setter

@synthesize cropSize, delegate, resizeableCropArea;
@synthesize imagePickerController = _imagePickerController;


#pragma mark -
#pragma mark Init Methods

- (id)init{
    if (self = [super init]) {
        
        self.cropSize = CGSizeMake(320, 320);
        self.resizeableCropArea = NO;
        _imagePickerController = [[UIImagePickerController alloc] init];
        _imagePickerController.delegate = self;
        _imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    return self;
}

- (id)initWithType:(NSInteger)type {
    
    if (self) {
        self.cropSize = CGSizeMake(320, 320);
        self.resizeableCropArea = NO;
        _imagePickerController = [[UIImagePickerController alloc] init];
        _imagePickerController.delegate = self;
        
        if (type == typePhotoLibrary)
            _imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        else
            _imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    
    return self;
}
# pragma mark -
# pragma mark Private Methods

- (void)_hideController{
    
    if (![_imagePickerController.presentedViewController isKindOfClass:[UIPopoverController class]]){
        
        [self.imagePickerController dismissViewControllerAnimated:YES completion:nil];
        
    } 
    
}

#pragma mark -
#pragma mark UIImagePickerDelegate Methods

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    
    if ([self.delegate respondsToSelector:@selector(imagePickerDidCancel:)]) {
      
        [self.delegate imagePickerDidCancel:self];
        
    } else {
        
        [self _hideController];
    
    }
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{

    GKImageCropViewController *cropController = [[GKImageCropViewController alloc] init];
    cropController.contentSizeForViewInPopover = picker.contentSizeForViewInPopover;
    cropController.sourceImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    cropController.resizeableCropArea = self.resizeableCropArea;
    cropController.cropSize = self.cropSize;
    cropController.delegate = self;
    [picker pushViewController:cropController animated:YES];
    
}

#pragma mark -
#pragma GKImagePickerDelegate

- (void)imageCropController:(GKImageCropViewController *)imageCropController didFinishWithCroppedImage:(UIImage *)croppedImage{
    
    if ([self.delegate respondsToSelector:@selector(imagePicker:pickedImage:)]) {
        [self.delegate imagePicker:self pickedImage:croppedImage];   
    }
}

/**
 * This method to custome navigation bar when use select  "Choose From library"
 * @author Sirius
 */
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
    // [Sirius] - Bug 7646:[iOS] Device's bar and battery life are disappeared when user take photo in Group's info or when creating a new group
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    // [Sirius] - Bug 7458:[iOS] Color's navigation bar of Photos page should be blue color.
    [navigationController.navigationBar setBackgroundImage:[UIImage imageFromColor:COLOR_48147213] forBarMetrics:UIBarMetricsDefault];
    [navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    [navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    
    [[UIBarItem appearance] setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIFont fontWithName:@"" size:15.0], UITextAttributeFont,[UIColor whiteColor],
      nil]forState:UIControlStateNormal];
    
    UIButton* cancel = [[UIButton alloc] initWithFrame:CGRectMake(10, 0, 50, 40)];
    [cancel addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
    [cancel setTitle:_CANCEL forState:UIControlStateNormal];
    [cancel.titleLabel setFont:[UIFont systemFontOfSize:15]];
    UIBarButtonItem  *btn_cancel = [[UIBarButtonItem alloc] initWithCustomView:cancel];
    
    viewController.navigationItem.rightBarButtonItem= btn_cancel;
    
    [viewController.navigationItem.rightBarButtonItem setTitlePositionAdjustment:UIOffsetMake(0.0, 0) forBarMetrics:UIBarMetricsDefault];
    
}

- (void)cancel {
    [self.imagePickerController dismissViewControllerAnimated:YES completion:nil];
}

@end
