//
//  ChatAdapter.m
//  ChatDomain
//
//  Created by MTouche on 2/2/15.
//  Copyright (c) 2015 mTouche. All rights reserved.
//

#import "ChatAdapter.h"
#import "ChatDomainDefine.h"
#import "ChatServerAdapter.h"
#import "AFNetworkingHelper.h"
#import "DDLog.h"

#define API_UPLOAD_FILE_CENTRAL @"AruQSjiqvZ"
#define API_UPLOAD_FILE_CENTRAL_VERSION @"v1"

#define API_UPLOAD_FILE_TENANT @"TTxgRheptu"
#define API_UPLOAD_FILE_TENANT_VERSION @"v1"

//Logging
#ifdef DEBUG
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelError;
#endif

@implementation ChatAdapter

+(NSString*) convertDateToString:(NSNumber*)dateTimestamp
                          format:(NSString*)formatDate{
    if (!dateTimestamp){
        DDLogError(@"%s:dateTimestamp is NULL", __PRETTY_FUNCTION__);
        return nil;
    }
    
    if (formatDate.length == 0){
        DDLogError(@"%s:formatDate is NULL", __PRETTY_FUNCTION__);
        return nil;
    }
    
    NSDate* convertDate = [NSDate dateWithTimeIntervalSince1970:[dateTimestamp doubleValue]];
    if (!convertDate) {
        DDLogError(@"%s:convertDate is NULL", __PRETTY_FUNCTION__);
        return nil;
    }
    
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setLocale:[NSLocale currentLocale]];
    [dateFormatter setDateFormat:formatDate];
    NSString* strDate = [dateFormatter stringFromDate:convertDate];
    
    return strDate;
}

+(NSNumber*) convertDate:(NSString*)date
                  format:(NSString*)formatDate{
    if(date.length == 0 || formatDate.length == 0){
        DDLogError(@"%s: date or formatDate is NULL", __PRETTY_FUNCTION__);
        return nil;
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[NSLocale currentLocale]];
    [dateFormatter setDateFormat:formatDate];
    NSDate *converDate = [dateFormatter dateFromString:date];
    if (converDate)
        return [NSNumber numberWithDouble:[converDate timeIntervalSince1970]];
    else
        return nil;
}

+(void) generateVideoData:(NSURL*) videoURL
                 callback:(generateVideoData)callback{
    void(^generateVideoCallBack)(BOOL success, NSData* videoData);
    generateVideoCallBack = callback;
    if (!videoURL) {
        DDLogError(@"%s videoURL is null", __PRETTY_FUNCTION__);
        generateVideoCallBack(NO, nil);
        return;
    }
    @try {
        AVURLAsset *movieAsset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
        AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:movieAsset];
        imageGenerator.appliesPreferredTrackTransform = YES;
        
        AVMutableComposition* mixComposition = [[AVMutableComposition alloc] init];
        AVMutableCompositionTrack *CompositionTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo
                                                                                  preferredTrackID:kCMPersistentTrackID_Invalid];
        NSArray* movieAssetArray =  [movieAsset tracksWithMediaType:AVMediaTypeVideo];
        if (movieAssetArray.count >0) {
            [CompositionTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, movieAsset.duration)
                                      ofTrack:[movieAssetArray objectAtIndex:0] atTime:kCMTimeZero error:nil];
        }
        
        
        AVMutableCompositionTrack *ACompositionTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio
                                                                                   preferredTrackID:kCMPersistentTrackID_Invalid];
        NSArray* audioAssetArray =[movieAsset tracksWithMediaType:AVMediaTypeAudio];
        if (audioAssetArray.count > 0) {
            [ACompositionTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, movieAsset.duration)
                                       ofTrack:[audioAssetArray objectAtIndex:0] atTime:kCMTimeZero error:nil];
        }
        
        
        // 2.1 - Create AVMutableVideoCompositionInstruction
        AVMutableVideoCompositionInstruction *mainInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
        mainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, CMTimeAdd(kCMTimeZero,movieAsset.duration));
        // 2.2 - Create an AVMutableVideoCompositionLayerInstruction for the first track
        AVMutableVideoCompositionLayerInstruction *firstlayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:CompositionTrack];
        AVAssetTrack *firstAssetTrack = [[movieAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
        
        BOOL isFirstAssetPortrait_  = NO;
        CGAffineTransform firstTransform = firstAssetTrack.preferredTransform;
        if (firstTransform.a == 0 && firstTransform.b == 1.0 && firstTransform.c == -1.0 && firstTransform.d == 0)
            isFirstAssetPortrait_ = YES;
        if (firstTransform.a == 0 && firstTransform.b == -1.0 && firstTransform.c == 1.0 && firstTransform.d == 0)
            isFirstAssetPortrait_ = YES;
        
        [firstlayerInstruction setTransform:firstAssetTrack.preferredTransform atTime:kCMTimeZero];
        [firstlayerInstruction setOpacity:0.0 atTime:movieAsset.duration];
        
        // 2.4 - Add instructions
        mainInstruction.layerInstructions = [NSArray arrayWithObjects:firstlayerInstruction,nil];
        AVMutableVideoComposition *mainCompositionInst = [AVMutableVideoComposition videoComposition];
        mainCompositionInst.instructions = [NSArray arrayWithObject:mainInstruction];
        mainCompositionInst.frameDuration = CMTimeMake(1, 30);
        
        CGSize naturalSizeFirst;
        if(isFirstAssetPortrait_)
            naturalSizeFirst = CGSizeMake(firstAssetTrack.naturalSize.height, firstAssetTrack.naturalSize.width);
        else
            naturalSizeFirst = firstAssetTrack.naturalSize;
        
        mainCompositionInst.renderSize = CGSizeMake(naturalSizeFirst.width, naturalSizeFirst.height);
        
        NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)
                            objectAtIndex:0];
        NSString* fileName = [NSString stringWithFormat:@"%@%@.%@",[self generateMessageId],[self generateMessageId], FILE_EXT_VIDEO];
        NSString *filePath = [docDir stringByAppendingPathComponent:fileName];
        NSURL* dataURL = [NSURL fileURLWithPath:filePath];
        
        AVAssetExportSession* exporter = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetMediumQuality];
        exporter.outputURL = dataURL;
        exporter.outputFileType = AVFileTypeMPEG4;
        exporter.shouldOptimizeForNetworkUse = YES;
        exporter.videoComposition = mainCompositionInst;
        //[self performSelector:@selector(updateExportProgress) withObject:exporter afterDelay:0.1f];
        
        [exporter exportAsynchronouslyWithCompletionHandler:^{
            if (exporter.status == AVAssetExportSessionStatusCompleted) {
                NSData* videoData = [NSData dataWithContentsOfFile:filePath];
                generateVideoCallBack(YES, videoData);
            }
            else{
                generateVideoCallBack(NO, nil);
            }
            
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
        }];
    }
    @catch (NSException *exception) {
        NSLog(@"generateVideoData %@:",exception.debugDescription);
    }
}

+(void) generateVideoThumbnail:(NSURL*) videoURL
                      callback:(generateThumbnailImageCompletionBlock)callback{
    void(^generateThumbnailImageCallBack)(BOOL success, NSData* thumbnailData);
    generateThumbnailImageCallBack = callback;
    if(!videoURL){
        DDLogError(@"%s videoURL is null", __PRETTY_FUNCTION__);
        generateThumbnailImageCallBack(NO, nil);
        return;
    }
    
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
    Float64 durationSeconds = CMTimeGetSeconds([asset duration]);
    AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    generator.appliesPreferredTrackTransform=TRUE;
    CMTime _thumbTime = CMTimeMakeWithSeconds(durationSeconds/2.0, 600);
    
    AVAssetImageGeneratorCompletionHandler _handler = ^(CMTime requestedTime, CGImageRef im, CMTime actualTime, AVAssetImageGeneratorResult result, NSError *error){
        if (result != AVAssetImageGeneratorSucceeded) {
            generateThumbnailImageCallBack(NO, nil);
        }
        else{
            generateThumbnailImageCallBack(YES, UIImageJPEGRepresentation([UIImage imageWithCGImage:im], 0.7));
        }
    };
    
    CGSize maxSize = CGSizeMake(320, 320);
    generator.maximumSize = maxSize;
    [generator generateCGImagesAsynchronouslyForTimes:[NSArray arrayWithObject:[NSValue valueWithCMTime:_thumbTime]] completionHandler:_handler];
}

NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
+(NSString*) generateMessageId{
    NSMutableString *randomString = [NSMutableString stringWithCapacity: 8];
    for (int i=0; i<8; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random_uniform((int)[letters length])]];
    }
    return randomString;
}

+(NSString*) generateJSON:(NSDictionary*) inputDictionary{
    NSData* contentData = [NSJSONSerialization dataWithJSONObject:inputDictionary options:0 error:nil];
    if(contentData)
        return [[NSString alloc] initWithData:contentData encoding:NSUTF8StringEncoding];
    return nil;
}

+(NSDictionary*) decodeJSON:(NSString*) inputJson{
    NSData* inputData = [inputJson dataUsingEncoding:NSUTF8StringEncoding];
    if(!inputData){
        DDLogError(@"%s: FAILED: inputData NULL", __PRETTY_FUNCTION__);
        return nil;
    }
    
    NSDictionary* contentDic = [NSJSONSerialization JSONObjectWithData:inputData options:kNilOptions error:nil];
    if(contentDic)
        return contentDic;
    else{
        DDLogError(@"%s: FAILED: inputJSON is not valid", __PRETTY_FUNCTION__);
        return nil;
    }
}

+ (NSData *)scaleImage:(UIImage *)image
                  rate:(NSInteger) rate
{
    if (!image || rate == 0) {
        DDLogError(@"%s: FAILED: image or rate NULL", __PRETTY_FUNCTION__);
        return nil;
    }
    
    float width = image.size.width/rate;
    float height = image.size.height/rate;

    UIGraphicsBeginImageContext(CGSizeMake(width, height));
    CGRect rect = CGRectMake(0, 0, width, height);
    
    float widthRatio = image.size.width / width;
    float heightRatio = image.size.height / height;
    float divisor = widthRatio > heightRatio ? widthRatio : heightRatio;
    
    width = image.size.width / divisor;
    height = image.size.height / divisor;
    
    rect.size.width  = width;
    rect.size.height = height;
    
    [image drawInRect:rect];
    
    UIImage *smallImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSData *imageData = UIImageJPEGRepresentation(smallImage, 0.7f);
    return imageData;
}

+(NSString*) cacheAudioData:(NSString*) fileName
                    rawData:(NSData*) rawData{
    if (fileName.length == 0 || rawData.length == 0) {
        DDLogError(@"%s: FAILED: fileName/rawData NULL", __PRETTY_FUNCTION__);
        return nil;
    }
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* folderPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:AUDIO_FOLDER];

    if (![[NSFileManager defaultManager] fileExistsAtPath:folderPath])
        [[NSFileManager defaultManager] createDirectoryAtPath:folderPath
                                  withIntermediateDirectories:NO
                                                   attributes:nil
                                                        error:nil];
    if(![[fileName pathExtension] isEqual:FILE_EXT_AUDIO])
       fileName = [[fileName stringByDeletingPathExtension] stringByAppendingPathExtension:FILE_EXT_AUDIO];
    
    NSString* filePath = [folderPath stringByAppendingPathComponent:fileName];
    BOOL result = [rawData writeToFile:filePath atomically:YES];
    if(result)
        return [AUDIO_FOLDER stringByAppendingPathComponent:fileName];
    else{
        DDLogError(@"%s: FAILED: cannot write file", __PRETTY_FUNCTION__);
        return nil;
    }
}

+(NSString*) cacheImageData:(NSString*) fileName
                    rawData:(NSData*) rawData{
    if (fileName.length == 0 || rawData.length == 0) {
        DDLogError(@"%s: FAILED: fileName/rawData NULL", __PRETTY_FUNCTION__);
        return nil;
    }
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* folderPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:IMAGE_FOLDER];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:folderPath])
        [[NSFileManager defaultManager] createDirectoryAtPath:folderPath
                                  withIntermediateDirectories:NO
                                                   attributes:nil
                                                        error:nil];
    if(![[fileName pathExtension] isEqual:FILE_EXT_IMAGE])
        fileName = [[fileName stringByDeletingPathExtension] stringByAppendingPathExtension:FILE_EXT_IMAGE];
    
    NSString* filePath = [folderPath stringByAppendingPathComponent:fileName];
    BOOL result = [rawData writeToFile:filePath atomically:YES];
    if(result)
        return [IMAGE_FOLDER stringByAppendingPathComponent:fileName];
    else{
        DDLogError(@"%s: FAILED: cannot write file", __PRETTY_FUNCTION__);
        return nil;
    }
}

+(NSString*) cacheVideoData:(NSString*) fileName
                    rawData:(NSData*) rawData{
    if (fileName.length == 0 || rawData.length == 0) {
        DDLogError(@"%s: FAILED: fileName/rawData NULL", __PRETTY_FUNCTION__);
        return nil;
    }
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* folderPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:VIDEO_FOLDER];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:folderPath])
        [[NSFileManager defaultManager] createDirectoryAtPath:folderPath
                                  withIntermediateDirectories:NO
                                                   attributes:nil
                                                        error:nil];
    if(![[fileName pathExtension] isEqual:FILE_EXT_VIDEO])
        fileName = [[fileName stringByDeletingPathExtension] stringByAppendingPathExtension:FILE_EXT_VIDEO];
    
    NSString* filePath = [folderPath stringByAppendingPathComponent:fileName];
    BOOL result = [rawData writeToFile:filePath atomically:YES];
    if(result)
        return [VIDEO_FOLDER stringByAppendingPathComponent:fileName];
    else{
        DDLogError(@"%s: FAILED: cannot write file", __PRETTY_FUNCTION__);
        return nil;
    }
}

+(NSString*) cacheThumbData:(NSString*) fileName
                    rawData:(NSData*) rawData{
    if (fileName.length == 0 || rawData.length == 0) {
        DDLogError(@"%s: FAILED: fileName/rawData NULL", __PRETTY_FUNCTION__);
        return nil;
    }
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* folderPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:VIDEO_FOLDER];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:folderPath])
        [[NSFileManager defaultManager] createDirectoryAtPath:folderPath
                                  withIntermediateDirectories:NO
                                                   attributes:nil
                                                        error:nil];
    if(![[fileName pathExtension] isEqual:FILE_EXT_IMAGE])
        fileName = [[fileName stringByDeletingPathExtension] stringByAppendingPathExtension:FILE_EXT_IMAGE];
    
    NSString* filePath = [folderPath stringByAppendingPathComponent:fileName];
    BOOL result = [rawData writeToFile:filePath atomically:YES];
    if(result)
        return [VIDEO_FOLDER stringByAppendingPathComponent:fileName];
    else{
        DDLogError(@"%s: FAILED: cannot write file", __PRETTY_FUNCTION__);
        return nil;
    }
}

+(NSString*) cacheEncryptData:(NSString*) fileName
                      encData:(NSData*) encData{
    if (fileName.length == 0 || encData.length == 0) {
        DDLogError(@"%s: FAILED: fileName/encData NULL", __PRETTY_FUNCTION__);
        return nil;
    }
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* folderPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:ENCRYPT_FOLDER];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:folderPath])
        [[NSFileManager defaultManager] createDirectoryAtPath:folderPath
                                  withIntermediateDirectories:NO
                                                   attributes:nil
                                                        error:nil];
    if(![[fileName pathExtension] isEqual:FILE_EXT_ENC])
        fileName = [[fileName stringByDeletingPathExtension] stringByAppendingPathExtension:FILE_EXT_ENC];
    
    NSString* filePath = [folderPath stringByAppendingPathComponent:fileName];
    BOOL result = [encData writeToFile:filePath atomically:YES];
    if(result)
        return [ENCRYPT_FOLDER stringByAppendingPathComponent:fileName];
    else{
        DDLogError(@"%s: FAILED: cannot write file", __PRETTY_FUNCTION__);
        return nil;
    }
}

+(NSData*) encryptData:(NSString*) fileName{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* folderPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:ENCRYPT_FOLDER];
    if(![[fileName pathExtension] isEqual:FILE_EXT_ENC])
        fileName = [[fileName stringByDeletingPathExtension] stringByAppendingPathExtension:FILE_EXT_ENC];
    NSString* filePath = [folderPath stringByAppendingPathComponent:fileName];
    
    return [[NSFileManager defaultManager] contentsAtPath:filePath];
}

+(NSData*) audioRawData:(NSString*) fileName{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* folderPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:AUDIO_FOLDER];
    if(![[fileName pathExtension] isEqual:FILE_EXT_AUDIO])
        fileName = [[fileName stringByDeletingPathExtension] stringByAppendingPathExtension:FILE_EXT_AUDIO];
    NSString* filePath = [folderPath stringByAppendingPathComponent:fileName];
    
    return [[NSFileManager defaultManager] contentsAtPath:filePath];
}

+(NSData*) imageRawData:(NSString*) fileName{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* folderPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:IMAGE_FOLDER];
    if(![[fileName pathExtension] isEqual:FILE_EXT_IMAGE])
        fileName = [[fileName stringByDeletingPathExtension] stringByAppendingPathExtension:FILE_EXT_IMAGE];
    NSString* filePath = [folderPath stringByAppendingPathComponent:fileName];
    
    return [[NSFileManager defaultManager] contentsAtPath:filePath];
}

+(NSData*) videoRawData:(NSString*) fileName{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* folderPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:VIDEO_FOLDER];
    if(![[fileName pathExtension] isEqual:FILE_EXT_VIDEO])
        fileName = [[fileName stringByDeletingPathExtension] stringByAppendingPathExtension:FILE_EXT_VIDEO];
    NSString* filePath = [folderPath stringByAppendingPathComponent:fileName];
    
    return [[NSFileManager defaultManager] contentsAtPath:filePath];
}

+(NSData*) thumbRawData:(NSString*) fileName{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* folderPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:VIDEO_FOLDER];
    if(![[fileName pathExtension] isEqual:FILE_EXT_IMAGE])
        fileName = [[fileName stringByDeletingPathExtension] stringByAppendingPathExtension:FILE_EXT_IMAGE];
    NSString* filePath = [folderPath stringByAppendingPathComponent:fileName];
    
    return [[NSFileManager defaultManager] contentsAtPath:filePath];
}

+(BOOL) deleteRawData:(NSString*)fileName{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString* folderPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:VIDEO_FOLDER];
    if(![[fileName pathExtension] isEqual:FILE_EXT_VIDEO])
        fileName = [[fileName stringByDeletingPathExtension] stringByAppendingPathExtension:FILE_EXT_VIDEO];
    NSString* filePath = [folderPath stringByAppendingPathComponent:fileName];
    
    if([[NSFileManager defaultManager] fileExistsAtPath:filePath]){
        BOOL result = [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
        return result;
    }
    
    folderPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:IMAGE_FOLDER];
    if(![[fileName pathExtension] isEqual:FILE_EXT_IMAGE])
        fileName = [[fileName stringByDeletingPathExtension] stringByAppendingPathExtension:FILE_EXT_IMAGE];
    filePath = [folderPath stringByAppendingPathComponent:fileName];
    if([[NSFileManager defaultManager] fileExistsAtPath:filePath]){
        BOOL result = [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
        return result;
    }
    
    folderPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:AUDIO_FOLDER];
    if(![[fileName pathExtension] isEqual:FILE_EXT_AUDIO])
        fileName = [[fileName stringByDeletingPathExtension] stringByAppendingPathExtension:FILE_EXT_AUDIO];
    filePath = [folderPath stringByAppendingPathComponent:fileName];
    if([[NSFileManager defaultManager] fileExistsAtPath:filePath]){
        BOOL result = [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
        return result;
    }
    
    return FALSE;
}

+(BOOL) deleteEncData:(NSString*) fileName{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* folderPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:ENCRYPT_FOLDER];
    folderPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:ENCRYPT_FOLDER];
    if(![[fileName pathExtension] isEqual:FILE_EXT_ENC])
        fileName = [[fileName stringByDeletingPathExtension] stringByAppendingPathExtension:FILE_EXT_ENC];
    NSString* filePath = [folderPath stringByAppendingPathComponent:fileName];
    if([[NSFileManager defaultManager] fileExistsAtPath:filePath]){
        BOOL result = [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
        return result;
    }
    
    return FALSE;
}

+(BOOL) isMediaFileExisted:(NSString*)fileName{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSArray* arrayFolder = [[NSArray alloc] initWithObjects:ENCRYPT_FOLDER, AUDIO_FOLDER, IMAGE_FOLDER, VIDEO_FOLDER,nil];
    NSArray* arrayExtend = [[NSArray alloc] initWithObjects:FILE_EXT_ENC, FILE_EXT_AUDIO, FILE_EXT_IMAGE, FILE_EXT_VIDEO,nil];
    
    for (int index = 0; index < arrayFolder.count; index++) {
        NSString* folderPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:[arrayFolder objectAtIndex:index]];
        if(![[fileName pathExtension] isEqual:[arrayExtend objectAtIndex:index]])
            fileName = [[fileName stringByDeletingPathExtension] stringByAppendingPathExtension:[arrayExtend objectAtIndex:index]];
        NSString* filePath = [folderPath stringByAppendingPathComponent:fileName];
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath])
            return TRUE;
    }
    
    return FALSE;
}

+ (void)uploadMediaCentral:(NSDictionary *)parametersDic
               uploadBlock:(uploadBlock) uploadBlock
                  callback:(requestCompleteBlock)callback
{
    if (!parametersDic) {
        DDLogError(@"%s: FAILED parametersDic NULL", __PRETTY_FUNCTION__);
        return;
    }
    
    void (^uploadFileCallBack)(BOOL success, NSString *message ,NSDictionary *response, NSError *error);
    uploadFileCallBack = callback;
    NSMutableDictionary *parameters = [parametersDic mutableCopy];
    [parameters setObject:API_UPLOAD_FILE_CENTRAL forKey:kAPI];
    [parameters setObject:API_UPLOAD_FILE_CENTRAL_VERSION forKey:kAPI_VERSION];
    
    [[ChatServerAdapter share] requestService:parameters
                                 tenantServer:NO
                               uploadProgress:(uploadProgress) uploadBlock
                                     callback:^(BOOL success, NSString *message, NSDictionary *response, NSError *error) {
        if (success){
            DDLogInfo(@"%s: SUCCESS", __PRETTY_FUNCTION__);
            uploadFileCallBack(YES, @"Upload file successfully.", response, nil);
        }
        else{
            DDLogError(@"%s: FAILED", __PRETTY_FUNCTION__);
            uploadFileCallBack(NO, @"Upload file failed.", response, error);
        }
    }];
}

+ (void)uploadMediaTenant:(NSDictionary *)parametersDic
              uploadBlock:(uploadBlock) uploadBlock
                 callback:(requestCompleteBlock)callback{
    if (!parametersDic) {
        DDLogError(@"%s: FAILED parametersDic NULL", __PRETTY_FUNCTION__);
        return;
    }
    
    void (^uploadFileCallBack)(BOOL success, NSString *message ,NSDictionary *response, NSError *error);
    uploadFileCallBack = callback;
    NSMutableDictionary *parameters = [parametersDic mutableCopy];

    [parameters setObject:API_UPLOAD_FILE_TENANT forKey:kAPI];
    [parameters setObject:API_UPLOAD_FILE_TENANT_VERSION forKey:kAPI_VERSION];
    
    [[ChatServerAdapter share] requestService:parameters
                                 tenantServer:YES
                               uploadProgress:(uploadProgress) uploadBlock
                                     callback:^(BOOL success, NSString *message, NSDictionary *response, NSError *error) {
                                         if (success){
                                             DDLogInfo(@"%s: SUCCESS", __PRETTY_FUNCTION__);
                                             uploadFileCallBack(YES, @"Upload file successfully.", response, nil);
                                         }
                                         else{
                                             DDLogError(@"%s: FAILED", __PRETTY_FUNCTION__);
                                             uploadFileCallBack(NO, @"Upload file failed.", response, error);
                                         }
                                     }];
}

+ (void) downloadMedia:(NSURL*) urlDownload
         downloadBlock:(downloadBlock) downloadBlock
              callback:(requestCompleteBlock)callback{
    
    if(!urlDownload){
        DDLogError(@"%s: FAILED urlDownload NULL", __PRETTY_FUNCTION__);
        return;
    }
    
    void (^downloadFileCallback)(BOOL success, NSString *message ,NSDictionary *response, NSError *error);
    downloadFileCallback = callback;
    NSMutableDictionary* response = [NSMutableDictionary new];
    id failBlock = ^(AFHTTPRequestOperation *operation, NSError *error){
        DDLogError(@"%s: FAILED", __PRETTY_FUNCTION__);
        downloadFileCallback(NO, @"Download file failed.", response, nil);
    };
    id successBlock = ^(AFHTTPRequestOperation *operation, id responseObject){
        [response setObject:[operation responseData] forKey:@"DATA"];
        DDLogInfo(@"%s: SUCCESS", __PRETTY_FUNCTION__);
        downloadFileCallback(YES, @"Download file success.", response, nil);
    };
    
    [AFNetworkingHelper requestJSONAFHTTPRequestOperationForDownLoad:urlDownload
                                                             success:successBlock
                                                                fail:failBlock
                                                            download:downloadBlock
                                                     timeoutInterval:300.0];
    
}

@end
