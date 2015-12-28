//
//  MoreKeyboard.m
//  JuzChatV2
//
//  Created by TrungVN on 12/4/13.
//  Copyright (c) 2013 mTouche. All rights reserved.
//
#import "MoreKeyboard.h"
#import "ChatView.h"
#import "ImagePreview.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "VoiceCallView.h"
#import <AssetsLibrary/AssetsLibrary.h>

@implementation MoreKeyboard{
    ChatView* chatView;
}

@synthesize scrMore;
@synthesize btnChoosePhoto, btnChooseVideo, btnLocation, btnTakePhoto, btnTakeVideo, btnFreeCall;
@synthesize CameraType;
@synthesize mediaPicker;

-(void) willMoveToSuperview:(UIView *)newSuperview{
    chatView = [ChatView share];
    
    [btnChoosePhoto alignCenter];
    [btnChooseVideo alignCenter];
    [btnFreeCall alignCenter];
    [btnLocation alignCenter];
    [btnTakePhoto alignCenter];
    [btnTakeVideo alignCenter];
    
    
   
}

-(void) didMoveToSuperview{
    [self hide];
}

-(IBAction) freeCall
{
    [[LogFacade share] createEventWithCategory:Contact_Category action:freeCall_Action label:labelAction];
    if ([[ContactFacade share] isAccountRemoved]) {
        [[CAlertView new] showError:ERROR_ACCOUNT_REMOVED];
        return;
    }
    
    if (!IS_OS_8_OR_LATER) {
        [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
            if (granted) {
                NSLog(@"Permission microphone granted");
            }
            else {
                NSLog(@"Permission microphone denied");
                [[CAlertView new] showError:_ALERT_SATAY_DOES_NOT_HAVE_ACCESS_TO_YOUR_MICROPHONE];
                return;
            }
        }];
    }
    
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    if(authStatus == AVAuthorizationStatusDenied){
        [[CAlertView new] showInfo:_ALERT_SATAY_DOES_NOT_HAVE_ACCESS_TO_YOUR_MICROPHONE];
        return;
    }

    
    if (![[NotificationFacade share] isInternetConnected]){
        [[CAlertView new] showError:NO_INTERNET_CONNECTION_TRY_LATER];
        return;
    }
    if ([SIPFacade share].isCalling) {
        [[CAlertView new] showInfo:SIP_ERROR_CANNOT_CALL_WHILE_IN_ANOTHER_CALL];
        return;
    }
    [chatView.chatfield hideKeyboard];
    
    //SIP Call
    [[SIPFacade share] setStatusOfCall:YES];
    [SIPFacade share].isWhoMakeCall = YES;
    [VoiceCallView share].userJid = chatView.chatBoxID;
    [[ChatFacade share] stopCurrentAudioPlaying:nil];
    [[CWindow share] showVoiceCallView];
}

-(IBAction) choosePhoto{
    if ([[ContactFacade share] isAccountRemoved]) {
        [[CAlertView new] showError:ERROR_ACCOUNT_REMOVED];
        return;
    }
    
    ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
    switch (status) {
        case ALAuthorizationStatusDenied:
            [[CAlertView new] showInfo:_ERROR_DONT_HAVE_ACCESS_PHOTOS_LIBRARY];
            break;
        case ALAuthorizationStatusAuthorized:
            CameraType = 4;
            [self getMediaFromSource:UIImagePickerControllerSourceTypePhotoLibrary];
            break;
        case ALAuthorizationStatusNotDetermined:{
            ALAssetsLibrary *lib = [[ALAssetsLibrary alloc] init];
            [lib enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                if(group){
                    CameraType = 4;
                    [self getMediaFromSource:UIImagePickerControllerSourceTypePhotoLibrary];
                }
            } failureBlock:^(NSError *error) {
            }];
        }
        default:
            break;
    }
}

-(IBAction)chooseVideo{
    if ([[ContactFacade share] isAccountRemoved]) {
        [[CAlertView new] showError:ERROR_ACCOUNT_REMOVED];
        return;
    }
    
    ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
    switch (status) {
        case ALAuthorizationStatusDenied:
            [[CAlertView new] showInfo:_ERROR_DONT_HAVE_ACCESS_PHOTOS_LIBRARY];
            break;
        case ALAuthorizationStatusAuthorized:
            CameraType = 3;
            [self getMediaFromSource:UIImagePickerControllerSourceTypePhotoLibrary];
            break;
        case ALAuthorizationStatusNotDetermined:{
            ALAssetsLibrary *lib = [[ALAssetsLibrary alloc] init];
            [lib enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                if(group){
                    CameraType = 3;
                    [self getMediaFromSource:UIImagePickerControllerSourceTypePhotoLibrary];
                }
            } failureBlock:^(NSError *error) {
            }];
        }
        default:
            break;
    }
}

-(IBAction) takePhoto{
    if ([[ContactFacade share] isAccountRemoved]) {
        [[CAlertView new] showError:ERROR_ACCOUNT_REMOVED];
        return;
    }
    
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    switch (authStatus) {
        case AVAuthorizationStatusDenied:
            [[CAlertView new] showInfo:_ALERT_SATAY_DOES_NOT_HAVE_ACCESS_TO_YOUR_CAMERA];
            break;
        case AVAuthorizationStatusAuthorized:
            CameraType = 2;
            [self getMediaFromSource:UIImagePickerControllerSourceTypeCamera];
            break;
        case AVAuthorizationStatusNotDetermined:{
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if(granted){
                    NSLog(@"Permission camera granted");
                    CameraType = 2;
                    [self getMediaFromSource:UIImagePickerControllerSourceTypeCamera];
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
-(IBAction) takeVideo{
    if ([[ContactFacade share] isAccountRemoved]) {
        [[CAlertView new] showError:ERROR_ACCOUNT_REMOVED];
        return;
    }
    
    
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if ([SIPFacade share].isCalling || [SIPFacade share].isOnCall) {
        [[CAlertView new] showError:mERROR_CANNOT_SEND_VIDEO_OR_RECORD_AUDIO];
        return;
    }    
    switch (authStatus) {
        case AVAuthorizationStatusDenied:
            [[CAlertView new] showInfo:_ALERT_SATAY_DOES_NOT_HAVE_ACCESS_TO_YOUR_CAMERA];
            break;
        case AVAuthorizationStatusAuthorized:
            CameraType = 1;
            [self getMediaFromSource:UIImagePickerControllerSourceTypeCamera];
            break;
        case AVAuthorizationStatusNotDetermined:{
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if(granted){
                    NSLog(@"Permission camera granted");
                    CameraType = 1;
                    [self getMediaFromSource:UIImagePickerControllerSourceTypeCamera];
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
/*
-(IBAction) shareLocation{
    MapView* mapView = [[MapView alloc] initWithNibName:@"MapView" bundle:nil];
    mapView.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    mapView.showPlainMap = NO;
    [[[ChatView share] navigationController] pushViewController:mapView animated:YES];
}
 */

-(void) hide{
    [self changeXAxis:0 YAxis:self.superview.height];
}

-(void) show{
    if (self.y < chatView.view.height)
        return;
    [chatView.chatfield hideKeyboard];
    
    [chatView.notifyChat redrawNotify];
    [self changeXAxis:0 YAxis:chatView.view.height - self.height];
    [chatView.chatfield animateXAxis:0 YAxis:chatView.view.height - chatView.chatfield.height - self.height];
    [chatView.bubbleScroll changeWidth:chatView.bubbleScroll.width Height:chatView.chatfield.y - chatView.notifyChat.height];
    [chatView.bubbleScroll scrollToBottom];
    //hide call button if chatview is group chat.
    btnFreeCall.hidden = (([[AppFacade share] getChatBox:chatView.chatBoxID].isGroup) ? YES : NO);
}

-(void) getMediaFromSource:(UIImagePickerControllerSourceType)sourceType{
	NSArray *mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:sourceType];
    
	if ([UIImagePickerController isSourceTypeAvailable:sourceType] && [mediaTypes count] > 0)
    {
        mediaPicker = [[GKImagePicker alloc] initWithType:sourceType];       
        mediaPicker.imagePickerController.mediaTypes = mediaTypes;
        mediaPicker.delegate = self;
        mediaPicker.croptEnable = NO;
        mediaPicker.imagePickerController.allowsEditing = NO;
        
        [mediaPicker.imagePickerController.navigationBar setBackgroundImage:[UIImage imageFromColor:COLOR_707070] forBarMetrics:UIBarMetricsDefault];
        [mediaPicker.imagePickerController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName,nil]];
        
        
        switch (CameraType) {
            case 1:
                mediaPicker.imagePickerController.cameraCaptureMode = UIImagePickerControllerCameraCaptureModeVideo;
                break;
            case 2:
                mediaPicker.imagePickerController.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
                break;
            case 3:
                mediaPicker.imagePickerController.mediaTypes = [NSArray arrayWithObjects:@"public.movie", nil];
                mediaPicker.imagePickerController.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
                break;
            case 4:
                mediaPicker.imagePickerController.mediaTypes =  [[NSArray alloc] initWithObjects: @"public.image", nil];
                mediaPicker.imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                break;
                
            default:
                break;
        }
        
        mediaPicker.imagePickerController.videoQuality = UIImagePickerControllerQualityTypeMedium;
        mediaPicker.imagePickerController.videoMaximumDuration = 90.0f;
        [[UINavigationBar appearance]setTintColor:[UIColor whiteColor]];
        
        [chatView presentViewController:mediaPicker.imagePickerController animated:YES completion:nil];
      
	}
	else
    {
        NSLog(@"NO SUPPORT");
        //alert(@"Error accessing media", @"Device doesn’t support that media source.", @"Ok");
	}
}

-(void) imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

-(void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    [chatView.chatfield hideKeyboard];
    NSString *lastChosenMediaType = [info valueForKey:UIImagePickerControllerMediaType];
    
    if ([lastChosenMediaType isEqual:(NSString *)kUTTypeImage]){
        UIImage* image = [info objectForKey:UIImagePickerControllerOriginalImage];
        
        NSData* rawContent = nil;
        if(image.size.height*image.size.width > 2048000)
            rawContent = [ChatAdapter scaleImage:image rate:2];
        else
            rawContent = UIImageJPEGRepresentation(image, 0.7);
        
        image = [UIImage imageWithData:rawContent];
        
        switch (picker.sourceType) {
            case UIImagePickerControllerSourceTypeCamera:
                [[ChatFacade share] sendImage:image chatboxId:chatView.chatBoxID];
                [picker dismissViewControllerAnimated:YES completion:nil];
                break;
            case UIImagePickerControllerSourceTypePhotoLibrary:
            case UIImagePickerControllerSourceTypeSavedPhotosAlbum:
                [ImagePreview share].image = image;
                [ImagePreview share].picker = picker;
                [ImagePreview share].chatBoxID = chatView.chatBoxID;
                [picker pushViewController:[ImagePreview share] animated:YES];
                break;
            default:
                break;
        }
        return;
    }
    
    if ([lastChosenMediaType isEqual:(NSString *)kUTTypeMovie]){
        if ([SIPFacade share].isCalling || [SIPFacade share].isOnCall) {
            [[CAlertView new] showError:mERROR_CANNOT_SEND_VIDEO_OR_RECORD_AUDIO];
            return;
        }
        
        NSURL* videoURL = [info objectForKey:UIImagePickerControllerMediaURL];
        [[ChatFacade share] sendVideo:videoURL chatboxId:chatView.chatBoxID];
        [picker dismissViewControllerAnimated:YES completion:nil];
        
    }
}

- (void)imagePicker:(GKImagePicker *)imagePicker pickedImage:(UIImage *)image{
            
        NSData* rawContent = nil;
        if(image.size.height*image.size.width > 2048000)
            rawContent = [ChatAdapter scaleImage:image rate:2];
        else
            rawContent = UIImageJPEGRepresentation(image, 0.7);
        
        image = [UIImage imageWithData:rawContent];
        
        switch (imagePicker.imagePickerController.sourceType) {
            case UIImagePickerControllerSourceTypeCamera:
            {
                [[ChatFacade share] sendImage:image chatboxId:chatView.chatBoxID];
                [imagePicker.imagePickerController dismissViewControllerAnimated:YES completion:^(){
                    [chatView.chatfield hideKeyboard];
                }];
            }
                break;
            case UIImagePickerControllerSourceTypePhotoLibrary:
            case UIImagePickerControllerSourceTypeSavedPhotosAlbum:
                [ImagePreview share].image = image;
                [ImagePreview share].picker = imagePicker.imagePickerController;
                [ImagePreview share].chatBoxID = chatView.chatBoxID;
                [imagePicker.imagePickerController pushViewController:[ImagePreview share] animated:YES];
                [chatView.chatfield hideKeyboard];
                break;
            default:
                break;
        }
}

- (void)imagePicker:(GKImagePicker *)imagePicker pickedVideo:(NSURL *)videoURL
{
    [imagePicker.imagePickerController dismissViewControllerAnimated:NO completion:^(){
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [chatView.chatfield hideKeyboard];
            [[ChatFacade share] sendVideo:videoURL chatboxId:chatView.chatBoxID];
        });
    }];
}

//- (void) navigationController: (UINavigationController *) navigationController  willShowViewController: (UIViewController *) viewController animated: (BOOL) animated {
//    if(mediaPicker.sourceType == UIImagePickerControllerSourceTypeSavedPhotosAlbum){
//        if ([[mediaPicker.mediaTypes firstObject] isEqual:@"public.image"] ) {
//            viewController.navigationItem.leftBarButtonItem = [UIBarButtonItem createLeftButtonTitle:@"Photos" Target:self Action:@selector(showLibrary:)] ;
//        }
//    }
//}
//
//- (void) showLibrary: (id) sender {
//    mediaPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
//}

@end
