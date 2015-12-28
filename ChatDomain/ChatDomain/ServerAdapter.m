//
//  ServerAdapter.m
//  ChatDomain
//
//  Created by MTouche on 1/12/15.
//  Copyright (c) 2015 mTouche. All rights reserved.
//

#import "ServerAdapter.h"

#import "AFNetworking.h"
#import "JSONHelper.h"
#import "CocoaLumberjack.h"

@implementation ServerAdapter

#define SERVER @"SERVER"
#define API_ENCRYPTION @"API_ENCRYPTION"
#define API_PROTOCOL @"API_PROTOCOL"
#define API_PORT @"API_PORT"
#define API_VERSION @"API_VERSION"
#define DEFAULT_CONFIG @"DEFAULT_CONFIG"
#define API @"API"

#define API_REQUEST_METHOD @"API_REQUEST_METHOD"// POST or GET
#define API_REQUEST_KIND @"API_REQUEST_KIND"// Upload or Download or Normal
#define API_REQUEST_FILEPATH @"API_REQUEST_FILEPATH"// This for upload file

//Define respone from server
#define RESPONSE_STATUS_MSG @"STATUS_MSG"
#define RESPONSE_STATUS_CODE @"STATUS_CODE"

#define API_SUCCESS_STATUS @"1000"

//Logging
#ifdef DEBUG
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelOff;
#endif

+(ServerAdapter *)share{
    static dispatch_once_t once;
    static ServerAdapter * share;
    dispatch_once(&once, ^{
        share = [self new];
        // Configure CocoaLumberjack
        [DDLog addLogger:[DDASLLogger sharedInstance]];
        [DDLog addLogger:[DDTTYLogger sharedInstance]];
    });
    return share;
}

-(void) configServer{
    NSDictionary* config = [self getServerConfig];
    if ([[config objectForKey:DEFAULT_CONFIG] isEqualToNumber:[NSNumber numberWithBool:TRUE]]) {
        return;
    }
    
    NSMutableDictionary* serverConfig = [NSMutableDictionary new];
    [serverConfig setValue:@"0" forKey:API_ENCRYPTION];
    [serverConfig setValue:@"satay.mooo.com" forKey:API_PROTOCOL];
    [serverConfig setValue:@"80" forKey:API_PORT];
    [serverConfig setValue:[NSNumber numberWithBool:TRUE] forKey:DEFAULT_CONFIG];
    [[NSUserDefaults standardUserDefaults] setValue:serverConfig forKey:SERVER];
}

-(void) configServerManual:(NSDictionary*) serverConfig{
    if(!serverConfig){
        NSLog(@"%s: dicConfig cannot be NULL", __PRETTY_FUNCTION__);
        return;
    }
    
    if(![serverConfig objectForKey:API_ENCRYPTION] ||
       [[serverConfig objectForKey:API_ENCRYPTION] isEqualToString:@""]){
        NSLog(@"%s: dicConfig do not have valid API_ENCRYPTION value",__PRETTY_FUNCTION__);
        return;
    }
    if(![serverConfig objectForKey:API_PROTOCOL] ||
       [[serverConfig objectForKey:API_PROTOCOL] isEqualToString:@""] ){
        NSLog(@"%s: dicConfig do not have contain API_PROTOCOL value",__PRETTY_FUNCTION__);
        return;
    }
    if(![serverConfig objectForKey:API_PORT] ||
       [[serverConfig objectForKey:API_PORT] isEqualToString:@""] ){
        NSLog(@"%s: dicConfig do not have contain API_PORT value",__PRETTY_FUNCTION__);
        return;
    }
    
    [serverConfig setValue:[NSNumber numberWithBool:FALSE] forKey:DEFAULT_CONFIG];
    [[NSUserDefaults standardUserDefaults] setValue:serverConfig forKey:SERVER];
}

-(NSDictionary*) getServerConfig{
    return [[NSUserDefaults standardUserDefaults] valueForKey:SERVER];
}

-(NSString*) getServerURL{
    NSDictionary* serverConfig = [self getServerConfig];
    if(!serverConfig){
        NSLog(@"%s: Server is not yet config, run configServer or configServerManual 1st", __PRETTY_FUNCTION__);
        return NULL;
    }
    NSString* serverURL = @"";
    
    if([[serverConfig objectForKey:API_ENCRYPTION] integerValue] != 1){
        serverURL = [serverURL stringByAppendingString:@"http://"];
    }
    else
        serverURL = [serverURL stringByAppendingString:@"https://"];
    serverURL = [serverURL stringByAppendingString:[serverConfig objectForKey:API_PROTOCOL]];
    serverURL = [serverURL stringByAppendingString:@":"];
    serverURL = [serverURL stringByAppendingString:[serverConfig objectForKey:API_PORT]];
    return serverURL;
}

void (^requestCompletionCallBack)(BOOL success, NSString *message ,NSDictionary *response, NSError *error);

-(void) requestService:(NSDictionary*) paramDic callback:(requestCompletionBlock)callback{
    
    requestCompletionCallBack = callback;
    
    if(!paramDic){
        DDLogError(@"%s: paramDic cannot be NULL",__PRETTY_FUNCTION__);
        return;
    }
    if(![paramDic objectForKey:API] ||
       ![[paramDic objectForKey:API] isKindOfClass:[NSString class]] ||
       [[paramDic objectForKey:API] isEqualToString:@""]){
        DDLogError(@"%s: paramDic didn't have valid API value",__PRETTY_FUNCTION__);
        return;
    }
    
    if(![paramDic objectForKey:API_VERSION] ||
       ![[paramDic objectForKey:API_VERSION] isKindOfClass:[NSString class]] ||
       [[paramDic objectForKey:API_VERSION] isEqualToString:@""]){
        DDLogError(@"%s: paramDic didn't have valid API_VERSION value",__PRETTY_FUNCTION__);
        return;
    }
    
    NSString* serverURL = [self getServerURL];
    if(!serverURL){
        return;
    }
    
    serverURL = [serverURL stringByAppendingString:@"/"];
    serverURL = [serverURL stringByAppendingString:[paramDic objectForKey:API_VERSION]];
    serverURL = [serverURL stringByAppendingString:@"/"];
    serverURL = [serverURL stringByAppendingString:[paramDic objectForKey:API]];
    
    DDLogWarn(@"serverURL %@", serverURL);
    
    // Check request method. POST or GET is acceptable.
    // Check request method. POST or GET is acceptable.
    if(![paramDic objectForKey:API_REQUEST_METHOD] ||
       (![[paramDic objectForKey:API_REQUEST_METHOD] isKindOfClass:[NSString class]] &&
        (![[paramDic objectForKey:API_REQUEST_METHOD] isEqualToString:@"POST"] || ![[paramDic objectForKey:API_REQUEST_METHOD] isEqualToString:@"GET"]))){
           
           DDLogError(@"%s: paramDic didn't have valid API_REQUEST_METHOD value. It should be 'POST' or 'GET'.",__PRETTY_FUNCTION__);
           return;
           
       }
    
    // Check request kind. Upload or Download or Normal is acceptable.
    if(![paramDic objectForKey:API_REQUEST_KIND] ||
       (![[paramDic objectForKey:API_REQUEST_KIND] isKindOfClass:[NSString class]] &&
        (![[paramDic objectForKey:API_REQUEST_KIND] isEqualToString:@"Upload"] || ![[paramDic objectForKey:API_REQUEST_METHOD] isEqualToString:@"Download"] || ![[paramDic objectForKey:API_REQUEST_METHOD] isEqualToString:@"Normal"]))){
           
           DDLogError(@"%s: paramDic didn't have valid API_REQUEST_KIND value. It should be 'Upload' or 'Download' or 'Normal'.",__PRETTY_FUNCTION__);
           return;
           
       }
    
    if([[paramDic objectForKey:API_REQUEST_KIND] isEqualToString:@"Upload"] || [[paramDic objectForKey:API_REQUEST_KIND] isEqualToString:@"Download"]){
        // Check request File path.
        if(![paramDic objectForKey:API_REQUEST_FILEPATH] ||
           ![[paramDic objectForKey:API_REQUEST_FILEPATH] isKindOfClass:[NSURL class]] ||
           [[paramDic objectForKey:API_REQUEST_FILEPATH] isEqualToString:@""]){
            
            DDLogError(@"%s: paramDic didn't have valid API_REQUEST_FILEPATH value. It should be 'NSURL kind.",__PRETTY_FUNCTION__);
            return;
            
        }
    }
    
    id successBlock = ^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary* responseDictionary = (NSDictionary*)[JSONHelper decodeJSONToObject:[operation responseString]];
        
        if(responseDictionary != nil)
        {
            
            NSString *statusCode = [[NSString alloc] initWithFormat:@"%@",[responseDictionary objectForKey:RESPONSE_STATUS_CODE]];
            if([statusCode isEqualToString:API_SUCCESS_STATUS])
            {
                requestCompletionCallBack(YES,@"Response success.",responseObject, nil);
            }
            else
            {
                DDLogError(@"Response failed with status code: %@",[responseDictionary objectForKey:RESPONSE_STATUS_CODE]);
                requestCompletionCallBack(NO,@"Response failed.",responseDictionary, nil);
            }
            
        }else{
            requestCompletionCallBack(NO,@"Response NULL.",nil, nil);
        }
    };
    
    id failBlock = ^(AFHTTPRequestOperation *operation, NSError *error) {
        DDLogError(@"Error AFHTTPRequest: %@", error.localizedDescription);
        requestCompletionCallBack(NO,@"Failed to call server",nil, error);
        
    };
    
    
    id completeRequestKindUploadBlock = ^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            DDLogError(@"Error upload file: %@", error);
            requestCompletionCallBack(NO, @"Failed to upload", nil, error);
        } else {
            DDLogVerbose(@"Success block upload file: %@ %@", response, responseObject);
            NSDictionary* responseDictionary = (NSDictionary*)[JSONHelper decodeJSONToObject:responseObject];
            requestCompletionCallBack(YES,@"Success upload file",responseDictionary, error);
            
        }
        
    };
    /*
     id destinationDownloadFile  = ^NSURL *(NSURL *targetPath, NSURLResponse *response) {
     NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
     return [documentsDirectoryURL URLByAppendingPathComponent:[response suggestedFilename]];
     };*/
    
    id completeRequestKindDownloadBlock  = ^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        //NSLog(@"File downloaded to: %@", filePath);
        NSDictionary* responseDictionary = (NSDictionary*)[JSONHelper decodeJSONToObject:[response suggestedFilename]];
        requestCompletionCallBack(YES,@"Success upload file",responseDictionary, error);
    };
    
    
    if ([[paramDic objectForKey:API_REQUEST_KIND] isEqualToString:@"Upload"])
    {
        
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
        
        NSURL *URL = [NSURL URLWithString:serverURL];
        NSURLRequest *request = [NSURLRequest requestWithURL:URL];
        
        NSURL *filePath = [paramDic objectForKey:API_REQUEST_FILEPATH];
        NSURLSessionUploadTask *uploadTask = [manager uploadTaskWithRequest:request fromFile:filePath progress:nil completionHandler:completeRequestKindUploadBlock];
        [uploadTask resume];
        
        
    }else if ([[paramDic objectForKey:API_REQUEST_KIND] isEqualToString:@"Download"]){
        
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
        
        NSURL *URL = [NSURL URLWithString:serverURL];
        NSURLRequest *request = [NSURLRequest requestWithURL:URL];
        
        NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:nil destination:nil completionHandler: completeRequestKindDownloadBlock];
        [downloadTask resume];
        
    }else{
        NSMutableDictionary *parametersURL = [paramDic mutableCopy];
        [parametersURL removeObjectsForKeys:[NSArray arrayWithObjects:API, API_REQUEST_KIND ,API_REQUEST_METHOD, nil]];
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        manager.responseSerializer.acceptableContentTypes = [[NSSet alloc] initWithObjects:@"text/html", nil];
        
        if ([[paramDic objectForKey:API_REQUEST_METHOD] isEqualToString:@"POST"])
        {
            [manager POST:serverURL parameters:parametersURL success:successBlock failure:failBlock];
        }else{
            [manager GET:serverURL parameters:parametersURL success:successBlock failure:failBlock];
            
        }
    }
    
}

@end
