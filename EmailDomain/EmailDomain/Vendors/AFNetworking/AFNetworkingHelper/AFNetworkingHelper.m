//
//  PLISTHelper.m
//  DallasAFNetworkingHelper
//
//  Created by ENCLAVEIT on 7/23/14.
//  Copyright (c) 2014 ENCLAVEIT. All rights reserved.
//

#import "AFNetworkingHelper.h"
#import "UIImageView+AFNetworking.h"

@implementation AFNetworkingHelper

#pragma mark - HTTP Request Operation Manager

static void AFGetAlertViewTitleAndMessageFromError(NSError *error, NSString *__autoreleasing *title, NSString *__autoreleasing *message)
{
    if (error.localizedDescription && (error.localizedRecoverySuggestion || error.localizedFailureReason))
    {
        *title = error.localizedDescription;

        if (error.localizedRecoverySuggestion)
        {
            *message = error.localizedRecoverySuggestion;
        }
        else
        {
            *message = error.localizedFailureReason;
        }
    }
    else if (error.localizedDescription)
    {
        *title = NSLocalizedStringFromTable(@"Error", @"AFNetworking", @"Fallback Error Description");
        *message = error.localizedDescription;
    }
    else
    {
        *title = NSLocalizedStringFromTable(@"Error", @"AFNetworking", @"Fallback Error Description");
        *message = [NSString stringWithFormat:NSLocalizedStringFromTable(@"%@ Error: %ld", @"AFNetworking", @"Fallback Error Failure Reason Format"), error.domain, (long)error.code];
    }
}

+ (void)requestPListAFHTTPRequestOperation:(NSURL *)fileURL
                                   success:(id)successBlock
                                      fail:(id)failBlock
{
    
    NSURLRequest *req = [NSURLRequest requestWithURL:fileURL
                                         cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                     timeoutInterval:60.0];

    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:req];
    op.responseSerializer = [AFPropertyListResponseSerializer serializer];
    op.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [op setCompletionBlockWithSuccess:successBlock failure:failBlock];

    [op start];
}


+ (void)requestJSONAFHTTPRequestKindOperation:(NSString *)urlString
                                   parameters:(NSDictionary *)parameters
                                       isPOST:(BOOL)isPOST
                                      success:(id)successBlock
                                         fail:(id)failBlock
{
  
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];

    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    if (isPOST)
    {
        [manager POST:urlString parameters:parameters success:successBlock failure:failBlock];
    }
    else
    {
        [manager GET:urlString parameters:parameters success:successBlock failure:failBlock];
    }

}

+ (void)requestJSONAFHTTPRequestOperation:(NSURL *)fileURL
                                  success:(id)successBlock
                                     fail:(id)failBlock
                                timeoutInterval:(NSTimeInterval)timeoutInterval

{
    NSURLRequest *req = [NSURLRequest requestWithURL:fileURL
                                         cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                     timeoutInterval:timeoutInterval];

    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:req];
    op.responseSerializer = [AFJSONResponseSerializer serializer];
    op.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [op setCompletionBlockWithSuccess:successBlock failure:failBlock];
    
    [op start];
}

+ (void)requestJSONAFHTTPRequestOperationForDownLoad:(NSURL *)fileURL
                                  success:(id)successBlock
                                     fail:(id)failBlock
                                            download:(id)downloadBlock
                          timeoutInterval:(NSTimeInterval)timeoutInterval

{
    NSURLRequest *req = [NSURLRequest requestWithURL:fileURL
                                         cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                     timeoutInterval:timeoutInterval];
    
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:req];
    op.responseSerializer = [AFJSONResponseSerializer serializer];
    op.responseSerializer.acceptableContentTypes = [[NSSet alloc] initWithObjects:@"image/tiff", @"image/jpeg", @"image/gif", @"image/png", @"image/ico", @"image/x-icon", @"image/bmp", @"image/png", @"image/x-bmp", @"image/x-xbitmap", @"image/x-win-bitmap",@"application/octet-stream",@"audio/mp4",@"audio/mp3",@"audio/mov",@"audio/m4v",@"video/mp4",@"video/mov",@"video/m4v",@"audio/mpeg",@"video/mpeg", nil];
    
    AFSecurityPolicy *securityPolicy = [[AFSecurityPolicy alloc] init];
    [securityPolicy setAllowInvalidCertificates:YES];
    op.securityPolicy = securityPolicy;
    
    [op setCompletionBlockWithSuccess:successBlock failure:failBlock];
    
    [op setDownloadProgressBlock:downloadBlock];
    
    [op start];
}

+ (void)requestDownLoadFile:(NSURL *)fileURL
success:(id)successBlock
fail:(id)failBlock
timeoutInterval:(NSTimeInterval)timeoutInterval
outputStreamToFileAtPath:FilePath
{
    NSURLRequest *req = [NSURLRequest requestWithURL:fileURL
                                         cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                     timeoutInterval:timeoutInterval];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:req];
    operation.outputStream = [NSOutputStream outputStreamToFileAtPath:FilePath append:NO];
    [operation setCompletionBlockWithSuccess:successBlock failure:failBlock];
    
    [operation start];
}

- (void)requestJSONAFHTTPRequestOperationForDownLoad:(NSURL *)fileURL
                                             success:(id)successBlock
                                                fail:(id)failBlock
                                     timeoutInterval:(NSTimeInterval)timeoutInterval
                                          acceptType:(NSString*)type

{
    NSURLRequest *req = [NSURLRequest requestWithURL:fileURL
                                         cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                     timeoutInterval:timeoutInterval];
    
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:req];
    op.responseSerializer = [AFJSONResponseSerializer serializer];
    op.responseSerializer.acceptableContentTypes = [NSSet setWithObject:type];
    [op setCompletionBlockWithSuccess:successBlock failure:failBlock];
    
    [op start];
}


+ (void)requestXMLAFHTTPRequestOperation:(NSURL *)fileURL
                                 success:(id)successBlock
                                    fail:(id)failBlock
{
    NSURLRequest *req = [NSURLRequest requestWithURL:fileURL
                                         cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                     timeoutInterval:60.0];


    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:req];
    op.responseSerializer = [AFXMLParserResponseSerializer serializer];
    [op setCompletionBlockWithSuccess:successBlock failure:failBlock];

    [op start];
}

+ (void)cancelAllHTTPOperations:(NSString *)URLStringToMatched
                     operations:(NSArray *)operations
                 OperationQueue:(NSOperationQueue *)operationQueue
                         method:(NSString *)method
{
    for (NSOperation *operation in [operationQueue operations])
    {
        if (![operation isKindOfClass:[AFHTTPRequestOperation class]])
        {
            continue;
        }

        BOOL hasMatchingMethod = !method || [method isEqualToString:[[(AFHTTPRequestOperation *)operation request] HTTPMethod]];
        BOOL hasMatchingURL = [[[[(AFHTTPRequestOperation *)operation request] URL] absoluteString] isEqualToString:URLStringToMatched];

        if (hasMatchingMethod && hasMatchingURL)
        {
            [operation cancel];
        }
    }
}

+ (void)multiPartHTTPRequest:(NSString *)fileURL filePath:(NSURL *)filePath
                  parameters:(NSDictionary *)parameters
                     success:(id)successBlock
                        fail:(id)failBlock
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    id constructingBody = ^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileURL:filePath name:@"image" error:nil];
    };

    [manager POST:fileURL
                       parameters:parameters
        constructingBodyWithBlock:constructingBody
                          success:successBlock
                          failure:failBlock];
}

+ (void)postgetAFHTTPOperation:(NSURL *)fileURL
                      fileName:(NSString*)fileName
                    parameters:(NSDictionary *)parameters
                        isPOST:(BOOL *)isPOST
                       success:(id)successBlock
                          fail:(id)failBlock
{
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:fileURL];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    if (isPOST)
    {
        [manager POST:fileName parameters:parameters success:successBlock failure:failBlock];
    }
    else
    {
        [manager GET:fileName parameters:parameters success:successBlock failure:failBlock ];
    }
}

#pragma mark - AFURLSessionManager

+ (void)createAFHTTPDownloadTask:(NSURL *)downloadURL
                        isResume:(BOOL)isResume
                        withData:(NSData *)data
                     destination:(id)destination
                         success:(id)successBlock
{
    //create download task
    if (isResume)
    {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
        NSURLRequest *request = [NSURLRequest requestWithURL:downloadURL
                                                 cachePolicy:NSURLRequestReloadIgnoringCacheData
                                             timeoutInterval:60.0];

        NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:nil destination:destination completionHandler:successBlock];

        [downloadTask resume];

        //create download task with resume data
    }
    else
    {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
        NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithResumeData:data progress:nil destination:destination completionHandler:successBlock];

        [downloadTask resume];
    }
}

+ (void)createAFHTTPUploadTask:(NSURL *)uploadURL
                      filePath:(NSURL *)filePath
                       success:(id)successBlock
{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];

    NSURLRequest *request = [NSURLRequest requestWithURL:uploadURL
                                             cachePolicy:NSURLRequestReloadIgnoringCacheData
                                         timeoutInterval:60.0];

    NSURLSessionUploadTask *uploadTask = [manager uploadTaskWithRequest:request
                                                               fromFile:filePath
                                                               progress:nil
                                                      completionHandler:successBlock];

    [uploadTask resume];
}

+ (void)createMultiAFHTTPUploadTask:(NSString *)uploadURL
                           filePath:(NSString *)filePath
                         parameters:(NSDictionary*)parameters
          constructingBodyWithBlock:(id)constructingBody
                            success:(id)successBlock
{
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:uploadURL parameters:parameters constructingBodyWithBlock:constructingBody error:nil];

    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSProgress *progress = nil;

    NSURLSessionUploadTask *uploadTask = [manager uploadTaskWithStreamedRequest:request
                                                                       progress:&progress
                                                              completionHandler:successBlock];

    [uploadTask resume];
}

+ (void)createDataAFHTTPTask:(NSURL *)uploadURL
                    filePath:(NSString *)filePath
                     success:(id)successBlock
{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];

    NSURLRequest *request = [NSURLRequest requestWithURL:uploadURL];

    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:successBlock];

    [dataTask resume];
}

#pragma mark - Request Serialization
/*
   Request serializers create requests from URL strings, encoding parameters as either a query string or HTTP body.
 */
+ (NSMutableURLRequest *)parametersEncodingwithMethod:(NSString *)method urlString:(NSString *)urlString contentType:(NSString *)contentType parameters:(NSDictionary *)parameters
{
    NSMutableURLRequest *result = [[AFHTTPRequestSerializer serializer] requestWithMethod:method URLString:urlString parameters:parameters error:nil];

    return result;
}

#pragma mark - Network Reachability Manager
/*
   AFNetworkReachabilityManager monitors the reachability of domains, and addresses for both WWAN and WiFi network interfaces.
 */


+ (void)getShareNetworkStatus:(id)success
{

    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:success];
}

+ (void)getHTTPNetworkStatus:(NSURL *)URL 
{
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:URL];
    NSOperationQueue *operationQueue = manager.operationQueue;

    [manager.reachabilityManager  startMonitoring];
    [manager.reachabilityManager
     setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
         NSLog(@"Reachability: %@", AFStringFromNetworkReachabilityStatus(status));
        switch (status)
        {
            case AFNetworkReachabilityStatusReachableViaWWAN:
            case AFNetworkReachabilityStatusReachableViaWiFi:
                [operationQueue setSuspended:NO];
                break;

            case AFNetworkReachabilityStatusNotReachable:
            default:
                [operationQueue setSuspended:YES];
                break;
        }
    }];
}

#pragma mark - Network Reachability Manager

+ (void)allowInvlaidSSL
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];

    manager.securityPolicy.allowInvalidCertificates = YES; // not recommended for production
}

#pragma mark - AFHTTPRequestOperation
/*
   AFHTTPRequestOperation is a subclass of AFURLConnectionOperation for requests using the HTTP or HTTPS protocols. It encapsulates the concept of acceptable status codes and content types, which determine the success or failure of a request.
   Although AFHTTPRequestOperationManager is usually the best way to go about making requests, AFHTTPRequestOperation can be used by itself.

 */

+ (void)getAFHTTPRequestOperation:(NSURL *)url
                          success:(id)successBlock
                             fail:(id)failBlock
{
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];

    op.responseSerializer = [AFJSONResponseSerializer serializer];
    [op setCompletionBlockWithSuccess:successBlock failure:failBlock];
    [[NSOperationQueue mainQueue] addOperation:op];
}

+ (void)callBatchOfRequestOperations:(NSString *)url
                              method:(NSString *)method
                               batch:(id)batch
                          parameters:(NSDictionary*)parameters
                       filesToUpload:(NSArray *)filesToUpload
                             success:(id)successBlock
                                fail:(id)failBlock
{
    NSMutableArray *mutableOperations = [NSMutableArray array];

    for (NSURL *fileURL in filesToUpload)
    {
        NSURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:method
                                                                                           URLString:url
                                                                                          parameters:parameters
                                                                           constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            [formData appendPartWithFileURL:fileURL
                                       name:@"images[]"
                                      error:nil];
        }

                                                                                               error:nil];

        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];

        [mutableOperations addObject:operation];
    }

    NSArray *operations = [AFURLConnectionOperation batchOfRequestOperations:batch
                                                               progressBlock:^(NSUInteger numberOfFinishedOperations, NSUInteger totalNumberOfOperations) {
        NSLog(@"%lu of %lu complete", (unsigned long)numberOfFinishedOperations, (unsigned long)totalNumberOfOperations);
    }

                                                             completionBlock:^(NSArray *operations) {
        NSLog(@"All operations in batch complete");
    }];
    [[NSOperationQueue mainQueue] addOperations:operations waitUntilFinished:NO];
}

+ (void)showAlertViewForTaskWithErrorOnCompletion:(NSURLSessionTask *)task
                                         delegate:(id)delegate
                                cancelButtonTitle:(NSString *)cancelButtonTitle
                                otherButtonTitles:(NSString *)otherButtonTitles, ...NS_REQUIRES_NIL_TERMINATION
{
    __block id observer = [[NSNotificationCenter defaultCenter] addObserverForName:AFNetworkingTaskDidCompleteNotification
                                                                            object:task
                                                                             queue:[NSOperationQueue mainQueue]
                                                                        usingBlock:^(NSNotification *notification) {
        NSError *error = notification.userInfo[AFNetworkingTaskDidCompleteErrorKey];

        if (error)
        {
            NSString *title, *message;
            AFGetAlertViewTitleAndMessageFromError(error, &title, &message);

            [[[UIAlertView alloc] initWithTitle:title
                                        message:message
                                       delegate:delegate
                              cancelButtonTitle:cancelButtonTitle
                              otherButtonTitles:otherButtonTitles, nil] show];
        }

        [[NSNotificationCenter defaultCenter] removeObserver:observer
                                                        name:AFNetworkingTaskDidCompleteNotification
                                                      object:notification.object];
    }];
}

#pragma mark - AFHTTPRequestOperation
+(void)requestImageToPutIntoUIImageView:(UIImageView *)imageView
                                urlRequest:(NSURLRequest *)urlRequest
                            imageHolder:(UIImage *)imageHolder
                                success:(id)successBlock
                                failure:(id)failBlock
{
    [imageView setImageWithURLRequest:urlRequest placeholderImage:imageHolder success: successBlock failure: failBlock];
}

@end
