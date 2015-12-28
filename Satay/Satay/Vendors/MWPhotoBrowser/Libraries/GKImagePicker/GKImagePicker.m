//
//  GKImagePicker.m
//  GKImagePicker
//
//  Created by Georg Kitz on 6/1/12.
//  Copyright (c) 2012 Aurora Apps. All rights reserved.
//

#import "GKImagePicker.h"
#import "GKImageCropViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>

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
        
//        self.cropSize = CGSizeMake(320, 320);
//        self.resizeableCropArea = NO;
//        _imagePickerController = [[UIImagePickerController alloc] init];
//        _imagePickerController.delegate = self;
//        _imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    return self;
}

- (id)initWithType:(UIImagePickerControllerSourceType )type {
    
    if (self) {
        
        self.resizeableCropArea = NO;
        _imagePickerController = [[UIImagePickerController alloc] init];
        _imagePickerController.delegate = self;
        _imagePickerController.sourceType = type;
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
//    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
    NSString *lastChosenMediaType = [info valueForKey:UIImagePickerControllerMediaType];
    
    if ([lastChosenMediaType isEqual:(NSString *)kUTTypeImage]){
        GKImageCropViewController *cropController = [[GKImageCropViewController alloc] init];
        cropController.preferredContentSize = picker.preferredContentSize;
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        NSData* rawContent = nil;
        if(image.size.height*image.size.width > 2024000)
            rawContent = [ChatAdapter scaleImage:image rate:2];
        else
            rawContent = UIImageJPEGRepresentation(image, 0.7);
        image = [UIImage imageWithData:rawContent];
        
        if (self.croptEnable) {
            cropController.sourceImage = image;
            cropController.resizeableCropArea = self.resizeableCropArea;
            CGRect screenRect = picker.view.bounds;
            CGFloat minCropSize = MIN(screenRect.size.height, screenRect.size.width);
            self.cropSize = CGSizeMake(minCropSize - 30, minCropSize);
            cropController.cropSize = self.cropSize;
            cropController.delegate = self;
            [picker pushViewController:cropController animated:YES];
        }
        else{
            if ([self.delegate respondsToSelector:@selector(imagePicker:pickedImage:)]) {
                [self.delegate imagePicker:self pickedImage:image];
            }
        }
    }
    
    if ([lastChosenMediaType isEqual:(NSString *)kUTTypeMovie]){
        NSURL* videoURL = [info objectForKey:UIImagePickerControllerMediaURL];
        if ([self.delegate respondsToSelector:@selector(imagePicker:pickedVideo:)]) {
            [self.delegate imagePicker:self pickedVideo:videoURL];
        }
        
    }
}

#pragma mark -
#pragma GKImagePickerDelegate

- (void)imageCropController:(GKImageCropViewController *)imageCropController didFinishWithCroppedImage:(UIImage *)croppedImage{
//    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
    
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
//    if(_imagePickerController.sourceType == UIImagePickerControllerSourceTypeCamera)
//        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
//    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];

    
    // [Sirius] - Bug 7458:[iOS] Color's navigation bar of Photos page should be blue color.
    [navigationController.navigationBar setBackgroundImage:[UIImage imageFromColor:COLOR_878787] forBarMetrics:UIBarMetricsDefault];
    [navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName :  COLOR_24317741}];
    [navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    
    
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {        
        viewController.navigationItem.rightBarButtonItem= [UIBarButtonItem createRightButtonTitle:_CANCEL Target:self Action:@selector(cancel)];
    }
    
}

- (void)cancel {
    [self.imagePickerController dismissViewControllerAnimated:YES completion:nil];
}

@end
