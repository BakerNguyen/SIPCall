//
//  ChatAdapter.h
//  ChatDomain
//
//  Created by MTouche on 2/2/15.
//  Copyright (c) 2015 mTouche. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

#define AUDIO_FOLDER @"AUDIO"
#define IMAGE_FOLDER @"IMAGE"
#define VIDEO_FOLDER @"VIDEO"
#define ENCRYPT_FOLDER @"ENCRYPT"

#define FILE_EXT_AUDIO @"m4a"
#define FILE_EXT_IMAGE @"jpg"
#define FILE_EXT_VIDEO @"mp4"
#define FILE_EXT_ENC @"enc"

@interface ChatAdapter : NSObject

/*
 * convertDate from NSNumber dateTimestamp to NSString
 * return NSString in formatDate
 * failed return nil.
 * @author Trung
 */
+(NSString*) convertDateToString:(NSNumber*)dateTimestamp
                          format:(NSString*)formatDate;

/*
 * convertDate from string
 * return NSNumber* contain timeIntervalSince1970, if failed parse will return nil;
 * @author Trung
 */
+(NSNumber*) convertDate:(NSString*)date
                  format:(NSString*)formatDate;

/*
 * generateVideoData from videoURL
 * return NSData* of that video, if failed any step will return null.
 * @author Trung
 */
typedef void (^generateVideoData)(BOOL success, NSData* videoData);
+(void) generateVideoData:(NSURL*) videoURL
                 callback:(generateVideoData)callback;

/*
 * generateVideoThumbnail from videoURL
 * return NSData* thumbnail of that video, if failed any step will return null.
 * @author Trung
 */
typedef void (^generateThumbnailImageCompletionBlock)(BOOL success, NSData* thumbnailData);
+(void) generateVideoThumbnail:(NSURL*) videoURL
                      callback:(generateThumbnailImageCompletionBlock)callback;

/*
 * generateMessageId random 8 characters for each message.
 * return NSString* messageId;
 * @author Trung/Parker
 */
+(NSString*) generateMessageId;

/*
 * generateJSON from inputDictionary using NSUTF8Encoding
 * return NSString* in json format;
 * if failed will return nil
 * @author Trung
 */
+(NSString*) generateJSON:(NSDictionary*) inputDictionary;

/*
 * decodeJSON from inputJson using NSUTF8Encoding to NSDictionary*
 * return NSDictionary*;
 * if failed will return nil
 * @author Trung
 */
+(NSDictionary*) decodeJSON:(NSString*) inputJson;

/* 
 * scaleImage from origin base on rate
 * for exaple rate = 2 is 1/2, rate = 3 is 1/3
 * @author Trung/Parker
 */
+ (NSData *)scaleImage:(UIImage *)image
                  rate:(NSInteger) rate;

/*
 * extension will be m4u;
 * Save rawData of Audio file to process.
 * return filePath if cache success or return nil
 * @author Trung
 */
+(NSString*) cacheAudioData:(NSString*) fileName
                    rawData:(NSData*) rawData;

/*
 * extension will be jpg;
 * Save rawData of Image file to process.
 * return filePath if cache success or return nil
 * @author Trung
 */
+(NSString*) cacheImageData:(NSString*) fileName
                    rawData:(NSData*) rawData;

/*
 * extension will be mp4;
 * Save rawData of Video file to process.
 * return filePath if cache success or return nil
 * @author Trung
 */
+(NSString*) cacheVideoData:(NSString*) fileName
                    rawData:(NSData*) rawData;

/*
 * extension will be jpg;
 * Save rawData of thumbnail Video file to process.
 * return filePath if cache success or return nil
 * @author Trung
 */
+(NSString*) cacheThumbData:(NSString*) fileName
                    rawData:(NSData*) rawData;

/*
 * extension will be enc;
 * Save encData of file to process.
 * return filePath if cache success or return nil
 * @author Trung
 */
+(NSString*) cacheEncryptData:(NSString*) fileName
                      encData:(NSData*) encData;

/*
 * return encryptData or nil;
 * @author Trung
 */
+(NSData*) encryptData:(NSString*) fileName;

/*
 * return audioRawData or nil;
 * @author Trung
 */
+(NSData*) audioRawData:(NSString*) fileName;

/*
 * return imageRawData or nil;
 * @author Trung
 */
+(NSData*) imageRawData:(NSString*) fileName;

/*
 * return videoRawData or nil;
 * @author Trung
 */
+(NSData*) videoRawData:(NSString*) fileName;

/*
 * return thumbRawData or nil;
 * @author Trung
 */
+(NSData*) thumbRawData:(NSString*) fileName;

/*
 * delete media data at filePath;
 * @author Trung
 */
+(BOOL) deleteRawData:(NSString*) fileName;

/*
 * delete enc media data at filePath;
 * @author Trung
 */
+(BOOL) deleteEncData:(NSString*) fileName;

/*
 * return TRUE if media file existed in any folder: AUDIO/VIDEO/IMAGE/ENCRYPTED
 * @author Trung
 */
+(BOOL) isMediaFileExisted:(NSString*)fileName;

/*
 * upload media file to central.
 * @author Trung
 * @parameter parametersDic must have value for keys: 
 FROMJID, 
 FROMHOST, 
 TOJID, 
 TOHOST, 
 TOKEN (CENTRAL),
 UPLOAD_TYPE (1 - user to user, 2 - user to MUC, - 3 update MUC logo), 
 ROOMID (only for UPLOAD_TYPE 2 and 3)
 UPLOAD_FILE (file input)
 * server will return
 STATUS_CODE, MESSAGE, SUCCESS, TO_USERS, MEDIA
 */
typedef void (^uploadBlock)(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead);
typedef void (^requestCompleteBlock)(BOOL success, NSString *message ,NSDictionary *response, NSError *error);
+ (void)uploadMediaCentral:(NSDictionary *)parametersDic
               uploadBlock:(uploadBlock) uploadBlock
                  callback:(requestCompleteBlock)callback;

/*
 * upload media file to central.
 * @author Trung
 * @parameter parametersDic must have value for keys:
 */
+ (void)uploadMediaTenant:(NSDictionary *)parametersDic
              uploadBlock:(uploadBlock) uploadBlock
                 callback:(requestCompleteBlock)callback;

/*
 * download media file to url server.
 * @author Trung
*/
typedef void (^downloadBlock)(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead);
+ (void) downloadMedia:(NSURL*) urlDownload
         downloadBlock:(downloadBlock) downloadBlock
              callback:(requestCompleteBlock)callback;

@end
