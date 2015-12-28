//
//  PLISTHelper.h
//  DallasAFNetworkingHelper
//
//  Created by ENCLAVEIT on 7/23/14.
//  Copyright (c) 2014 ENCLAVEIT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

@interface AFNetworkingHelper : NSObject
/** request PList AFHTTP Request Operation
   @param fileURL :The request object to be loaded asynchronously during execution of the operation.
   @param successBlock :^(AFHTTPRequestOperation *operation, id responseObject) {}
   A block object to be executed when the request operation finishes successfully. This block has no return value and takes two arguments: the created request operation and the object created from the response data of request.
   @param failBlock :^(AFHTTPRequestOperation *operation, NSError *error) {}
   A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. This block has no return value and takes two arguments:, the created request operation and the NSError object describing the network or parsing error that occurred.
   @author: Tony
 */
+ (void)requestPListAFHTTPRequestOperation:(NSURL *)uploadFileApi
                                   success:(id)successBlock
                                      fail:(id)failBlock;

/** request JSON AFHTTP Request Operation with POST or GET method
 @param urlString :The request object to be loaded asynchronously during execution of the operation.
 @param parameters :parameters of request.
 @param successBlock :^(AFHTTPRequestOperation *operation, id responseObject) {}
 A block object to be executed when the request operation finishes successfully. This block has no return value and takes two arguments: the created request operation and the object created from the response data of request.
 @param failBlock :^(AFHTTPRequestOperation *operation, NSError *error) {}
 A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. This block has no return value and takes two arguments:, the created request operation and the NSError object describing the network or parsing error that occurred.
 @author: Parker / email: vanphuc06t1@gmail.com
 */
+ (void)requestJSONAFHTTPRequestKindOperation:(NSString *)urlString
                                   parameters:(NSDictionary *)parameters
                                       isPOST:(BOOL)isPOST
                                      success:(id)successBlock
                                         fail:(id)failBlock;

/** request JSON AFHTTP Request Operation
   @param fileURL :The request object to be loaded asynchronously during execution of the operation.
   @param successBlock :^(AFHTTPRequestOperation *operation, id responseObject) {}
   A block object to be executed when the request operation finishes successfully. This block has no return value and takes two arguments: the created request operation and the object created from the response data of request.
   @param failBlock :^(AFHTTPRequestOperation *operation, NSError *error) {}
   A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. This block has no return value and takes two arguments:, the created request operation and the NSError object describing the network or parsing error that occurred.
   @author: William
 */
+ (void)requestJSONAFHTTPRequestOperation:(NSURL *)fileURL
                                  success:(id)successBlock
                                     fail:(id)failBlock
                            timeoutInterval:(NSTimeInterval)timeoutInterval;
+ (void)requestJSONAFHTTPRequestOperationForDownLoad:(NSURL *)fileURL
                                             success:(id)successBlock
                                                fail:(id)failBlock
                                            download:(id)downloadBlock
                                     timeoutInterval:(NSTimeInterval)timeoutInterval;
/*+ (void)requestJSONAFHTTPRequestOperationForDownLoad:(NSURL *)fileURL
                                             success:(id)successBlock
                                                fail:(id)failBlock
                                     timeoutInterval:(NSTimeInterval)timeoutInterval
                                          acceptType:(NSString*)type;*/
+ (void)requestDownLoadFile:(NSURL *)fileURL
                    success:(id)successBlock
                       fail:(id)failBlock
            timeoutInterval:(NSTimeInterval)timeoutInterval
   outputStreamToFileAtPath:FilePath;

/** request XML AFHTTP Request Operation
   @param fileURL :The request object to be loaded asynchronously during execution of the operation.
   @param successBlock :^(AFHTTPRequestOperation *operation, id responseObject) {}
   A block object to be executed when the request operation finishes successfully. This block has no return value and takes two arguments: the created request operation and the object created from the response data of request.
   @param failBlock :^(AFHTTPRequestOperation *operation, NSError *error) {} :
   A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. This block has no return value and takes two arguments:, the created request operation and the NSError object describing the network or parsing error that occurred.
   @author: Violet
 */
+ (void)requestXMLAFHTTPRequestOperation:(NSURL *)fileURL
                                 success:(id)successBlock
                                    fail:(id)failBlock;

/** Cancel All HTTP Operations
   Cancels all operations in the HTTP client's operation queue whose URLs match the specified HTTP method and path.

   @param method The HTTP method to match for the cancelled requests, such as `GET`, `POST`, `PUT`, or `DELETE`. If `nil`, all request operations with URLs matching the path will be cancelled.
   @param URLStringToMatched The URL string to match for the operation. If `nil`, no path will be appended to the base URL.
   @param The operation queue which manages operations enqueued by the HTTP client
   @author: William
 */
+ (void)cancelAllHTTPOperations:(NSString *)URLStringToMatched
                     operations:(NSArray *)operations
                 OperationQueue:(NSOperationQueue *)operationQueue
                         method:(NSString *)method;


/** POST MULTI-PART REQUEST
   @param fileURL :The request object to be loaded asynchronously during execution of the operation.
   @param successBlock :A block object to be executed when the request operation finishes successfully. This block has no return value and takes two arguments: the created request operation and the object created from the response data of request.
   @param failBlock :A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. This block has no return value and takes two arguments:, the created request operation and the NSError object describing the network or parsing error that occurred.
   @author: Tony
 */
+ (void)multiPartHTTPRequest:(NSString *)fileURL filePath:(NSURL *)filePath
                  parameters:(NSDictionary *)parameters
                     success:(id)successBlock
                        fail:(id)failBlock;


/** POST-GET REQUEST
   @param fileURL :The request object to be loaded asynchronously during execution of the operation.
   @param type : if type == "POST": POST URL-FORM-ENCODED REQUEST
   type : if type == "GET ": GET REQUEST
   @param successBlock :A block object to be executed when the request operation finishes successfully. This block has no return value and takes two arguments: the created request operation and the object created from the response data of request.
   @param failBlock :A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. This block has no return value and takes two arguments:, the created request operation and the NSError object describing the network or parsing error that occurred.
   @author: Violet
 */

+ (void)postgetAFHTTPOperation:(NSURL *)fileURL
                      fileName:(NSString*)fileName
                    parameters:(NSDictionary *)parameters
                        isPOST:(BOOL *)isPOST
                       success:(id)successBlock
                          fail:(id)failBlock;


/** CREATING A DOWNLOAD TASK
   @param completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {}
   @param destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {}
   destination A block object to be executed in order to determine the destination of the downloaded file. This block takes two arguments, the target path & the server response, and returns the desired file URL of the resulting download. The temporary file used during the download will be automatically deleted after being moved to the returned URL.
   @param progress:(NSProgress *__autoreleasing *)
   progress A progress object monitoring the current download progress.
   @param successBlock:
   completionHandler A block to be executed when a task finishes. This block has no return value and takes three arguments: the server response, the path of the downloaded file, and the error describing the network or parsing error that occurred, if any.

   @param isResume: if isResume == Yes call run download task, else run create download task with resume data
   @warning If using a background `NSURLSessionConfiguration` on iOS, these blocks will be lost when the app is terminated. Background sessions may prefer to use `-setDownloadTaskDidFinishDownloadingBlock:` to specify the URL for saving the downloaded file, rather than the destination block of this method.
   @author: Tony
 */
+ (void)createAFHTTPDownloadTask:(NSURL *)downloadURL isResume:(BOOL)isResume withData:(NSData *)data destination:(id)destination success:(id)successBlock;


/** CREATING AN UPLOAD TASK with the specified request for a local file

   @param uploadURL A URL to the local file to be uploaded.
   @param successBlock : ^(NSURLResponse *response, id responseObject, NSError *error) {}
   A block object to be executed when the task finishes. This block has no return value and takes three arguments: the server response, the response object created by that serializer, and the error that occurred, if any.
   @param progress :(NSProgress *__autoreleasing *)
   progress A progress object monitoring the current upload progress.
   @author: Violet
 */

/** CREATING AN UPLOAD TASK FOR A MULTI-PART REQUEST, WITH PROGRESS
   @param successBlock : ^(NSURLResponse *response, id responseObject, NSError *error) {}
   A block object to be executed when the task finishes. This block has no return value and takes three arguments: the server response, the response object created by that serializer, and the error that occurred, if any.
   @param progress :(NSProgress *__autoreleasing *)
   A progress object monitoring the current upload progress.

   @author: William
 */
+ (void)createAFHTTPUploadTask:(NSURL *)uploadURL filePath:(NSURL *)filePath success:(id)successBlock;

/** create Multi AFHTTP UploadTask
 @param fileURL :The request object to be loaded asynchronously during execution of the operation.
 @param successBlock :A block object to be executed when the request operation finishes successfully. This block has no return value and takes two arguments: the created request operation and the object created from the response data of request.
 @param failBlock :A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. This block has no return value and takes two arguments:, the created request operation and the NSError object describing the network or parsing error that occurred.
 @author: Tony
 */
+ (void)createMultiAFHTTPUploadTask:(NSString *)uploadURL
                           filePath:(NSString *)filePath
                         parameters:(NSDictionary*)parameters
          constructingBodyWithBlock:(id)constructingBody
                            success:(id)successBlock;


/** CREATING A DATA TASK
   @param successBlock : ^(NSURLResponse *response, id responseObject, NSError *error) {}
   completionHandler A block object to be executed when the task finishes. This block has no return value and takes three arguments: the server response, the response object created by that serializer, and the error that occurred, if any.
   @param progress :(NSProgress *__autoreleasing *)
   @author: Tony
 */
+ (void)createDataAFHTTPTask:(NSURL *)uploadURL
                    filePath:(NSString *)filePath
                     success:(id)successBlock;

/**
   @author: Tony
 */
+ (NSMutableURLRequest *)parametersEncodingwithMethod:(NSString *)method
                                            urlString:(NSString *)urlString
                                          contentType:(NSString *)contentType
                                           parameters:(NSDictionary *)parameters;

/** get SHARED NETWORK REACHABILITY
   @author: William
 */
+ (void)getShareNetworkStatus:(id)success;

/** get HTTP Network REACHABILITY
 The solution to queue HTTP requests using AFNetworking when the device is offline, so when it goes back online the requests gets done.
   @author: Violet
 */
+ (void)getHTTPNetworkStatus:(NSURL *)URL;


/** GET WITH AFHTTPREQUESTOPERATION
   @author: William
 */
+ (void)getAFHTTPRequestOperation:(NSURL *)url
                          success:(id)successBlock
                             fail:(id)failBlock;

/** BATCH OF OPERATIONS
   @author: Tony
 */
+ (void)callBatchOfRequestOperations:(NSString *)url
                              method:(NSString *)method
                               batch:(id)batch
                          parameters:(NSDictionary*)parameters
                       filesToUpload:(NSArray *)filesToUpload
                             success:(id)successBlock
                                fail:(id)failBlock;
/**
   Shows an alert view with the error of the specified session task, if any, with a custom cancel button title and other button titles.

   @param task The session task.
   @param delegate The alert view delegate.
   @param cancelButtonTitle The title of the cancel button or nil if there is no cancel button. Using this argument is equivalent to setting the cancel button index to the value returned by invoking addButtonWithTitle: specifying this title.
   @param otherButtonTitles The title of another button. Using this argument is equivalent to invoking addButtonWithTitle: with this title to add more buttons. Too many buttons can cause the alert view to scroll. For guidelines on the best ways to use an alert in an app, see "Temporary Views". Titles of additional buttons to add to the receiver, terminated with `nil`.
   @author: William
 */
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 70000
+ (void)showAlertViewForTaskWithErrorOnCompletion:(NSURLSessionTask *)task
                                         delegate:(id)delegate
                                cancelButtonTitle:(NSString *)cancelButtonTitle
                                otherButtonTitles:(NSString *)otherButtonTitles, ...NS_REQUIRES_NIL_TERMINATION;
#endif

/**
 Asynchronously downloads an image from the specified URL request, and sets it once the request is finished. Any previous image request for the receiver will be cancelled.
 
 If the image is cached locally, the image is set immediately, otherwise the specified placeholder image will be set immediately, and then the remote image will be set once the request is finished.
 
 If a success block is specified, it is the responsibility of the block to set the image of the image view before returning. If no success block is specified, the default behavior of setting the image with `self.image = image` is applied.
 
 @param urlRequest The URL request used for the image request.
 @param placeholderImage The image to be set initially, until the image request finishes. If `nil`, the image view will not change its image until the image request finishes.
 @param success A block to be executed when the image request operation finishes successfully. This block has no return value and takes three arguments: the request sent from the client, the response received from the server, and the image created from the response data of request. If the image was returned from cache, the request and response parameters will be `nil`.
 @param failure A block object to be executed when the image request operation finishes unsuccessfully, or that finishes successfully. This block has no return value and takes three arguments: the request sent from the client, the response received from the server, and the error object describing the network or parsing error that occurred.
 */
+(void)requestImageToPutIntoUIImageView:(UIImageView *)imageView
                                urlRequest:(NSURLRequest *)urlRequest
                            imageHolder:(UIImage *)imageHolder
                                success:(id)successBlock
                                failure:(id)failBlock;
@end
