//
//  ServerAdapter.m
//  ChatDomain
//
//  Created by MTouche on 1/12/15.
//  Copyright (c) 2015 mTouche. All rights reserved.
//

#import "NotificationServerAdapter.h"

#import "AFNetworking.h"
#import "JSONHelper.h"
#import "CocoaLumberjack.h"

@implementation NotificationServerAdapter

#define SERVER_CENTRAL @"SERVER_CENTRAL"
#define API_ENCRYPTION_CENTRAL @"API_ENCRYPTION_CENTRAL"
#define API_PROTOCOL_CENTRAL @"API_PROTOCOL_CENTRAL"
#define API_PORT_CENTRAL @"API_PORT_CENTRAL"

#define SERVER_TENANT @"SERVER_TENANT"

#define API_VERSION @"API_VERSION"

#define API @"API"

//Define respone from server
#define RESPONSE_STATUS_MSG @"STATUS_MSG"
#define RESPONSE_STATUS_CODE @"STATUS_CODE"
#define RESPONSE_SUCCESS @"SUCCESS"

#define RESPONSE_STATUS_CODE_0 0
#define API_SUCCESS_STATUS @"1"

#define CENTRAL_HOST @"sataydevcapi.mtouche-mobile.com"
#define CENTRAL_PORT @"80"
#define CENTRAL_ENCRYPTION @"0"

//Logging
#ifdef DEBUG
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelOff;
#endif

+(NotificationServerAdapter *)share{
    static dispatch_once_t once;
    static NotificationServerAdapter * share;
    dispatch_once(&once, ^{
        share = [self new];
    });
    return share;
}

-(void) configServerCentral{
    NSMutableDictionary* serverConfig = [NSMutableDictionary new];
    [serverConfig setValue:CENTRAL_ENCRYPTION forKey:API_ENCRYPTION_CENTRAL];
    [serverConfig setValue:CENTRAL_HOST forKey:API_PROTOCOL_CENTRAL];
    [serverConfig setValue:CENTRAL_PORT forKey:API_PORT_CENTRAL];
    [[NSUserDefaults standardUserDefaults] setObject:serverConfig forKey:SERVER_CENTRAL];
    [[NSUserDefaults standardUserDefaults] synchronize];
    DDLogInfo(@"%s: %@", __PRETTY_FUNCTION__, serverConfig);
}

-(void) configServerTenant:(NSDictionary*) serverConfig{
    if(!serverConfig){
        NSLog(@"%s: serverConfig cannot be NULL", __PRETTY_FUNCTION__);
        return;
    }
    
    if(![serverConfig objectForKey:kAPI_ENCRYPTION_TENANT] ||
       [[serverConfig objectForKey:kAPI_ENCRYPTION_TENANT] isEqualToString:@""]){
        NSLog(@"%s: serverConfig do not have valid API_ENCRYPTION_TENANT value",__PRETTY_FUNCTION__);
        return;
    }
    if(![serverConfig objectForKey:kAPI_PROTOCOL_TENANT] ||
       [[serverConfig objectForKey:kAPI_PROTOCOL_TENANT] isEqualToString:@""] ){
        NSLog(@"%s: serverConfig do not have contain API_PROTOCOL_TENANT value",__PRETTY_FUNCTION__);
        return;
    }
    if(![serverConfig objectForKey:kAPI_PORT_TENANT] ||
       [[serverConfig objectForKey:kAPI_PORT_TENANT] isEqualToString:@""] ){
        NSLog(@"%s: serverConfig do not have contain API_PORT_TENANT value",__PRETTY_FUNCTION__);
        return;
    }
    [[NSUserDefaults standardUserDefaults] setObject:serverConfig forKey:SERVER_TENANT];
     [[NSUserDefaults standardUserDefaults] synchronize];
    DDLogInfo(@"%s: %@", __PRETTY_FUNCTION__, [[NSUserDefaults standardUserDefaults] objectForKey:SERVER_TENANT]);
}

-(void) requestService:(NSDictionary*) paramDic tenantServer:(BOOL)isTenantServer callback:(requestCompletionBlock)callback{

    void (^requestCompletionCallBack)(BOOL success, NSString *message ,NSDictionary *response, NSError *error);
    
    requestCompletionCallBack = callback;
    
    if(!paramDic){
        DDLogError(@"%s: paramDic is NULL",__PRETTY_FUNCTION__);
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
    
    NSString* serverURL = [self getServerURL:isTenantServer];
    
    if(!serverURL || [serverURL isEqualToString:@""]){
        DDLogError(@"Server URL can not be NULL or empty.");
        return;
    }
    
    serverURL = [serverURL stringByAppendingString:@"/"];
    serverURL = [serverURL stringByAppendingString:[paramDic objectForKey:API_VERSION]];
    serverURL = [serverURL stringByAppendingString:@"/"];
    serverURL = [serverURL stringByAppendingString:[paramDic objectForKey:API]];
    
    DDLogInfo(@"%s: serverURL %@",__PRETTY_FUNCTION__, serverURL);
    
//#warning all newly created API (v2) will use PUT method and param in header (@Daniel)
    if(![paramDic objectForKey:kAPI_REQUEST_METHOD] ||
       (![[paramDic objectForKey:kAPI_REQUEST_METHOD] isKindOfClass:[NSString class]] &&
        (![[paramDic objectForKey:kAPI_REQUEST_METHOD] isEqualToString:@"POST"] || ![[paramDic objectForKey:kAPI_REQUEST_METHOD] isEqualToString:@"GET"] || ![[paramDic objectForKey:kAPI_REQUEST_METHOD] isEqualToString:@"PUT"]))){
           
           DDLogError(@"%s: Invalid API_REQUEST_METHOD value. Accept 'POST','PUT','GET' Only.",__PRETTY_FUNCTION__);
           return;
       }
    
    // Check request kind. Upload or Download or Normal is acceptable.
    if(![paramDic objectForKey:kAPI_REQUEST_KIND] ||
       (![[paramDic objectForKey:kAPI_REQUEST_KIND] isKindOfClass:[NSString class]] &&
        (![[paramDic objectForKey:kAPI_REQUEST_KIND] isEqualToString:@"Upload"] || ![[paramDic objectForKey:kAPI_REQUEST_METHOD] isEqualToString:@"Download"] || ![[paramDic objectForKey:kAPI_REQUEST_METHOD] isEqualToString:@"Normal"]))){
           
           DDLogError(@"%s:Invalid API_REQUEST_KIND value. Accept 'Upload','Download','Normal'.",__PRETTY_FUNCTION__);
           return;
       }
    
    if([[paramDic objectForKey:kAPI_REQUEST_KIND] isEqualToString:@"Upload"]){
        if(![paramDic objectForKey:kAPI_UPLOAD_FILEDATA] ||
           ![[paramDic objectForKey:kAPI_UPLOAD_FILEDATA] isKindOfClass:[NSData class]]){
            DDLogError(@"%s: Invalid kAPI_UPLOAD_FILEDATA value. It should be 'NSData kind.",__PRETTY_FUNCTION__);
            return;
        }
        if(![paramDic objectForKey:kAPI_UPLOAD_FILENAME] ||
           ![[paramDic objectForKey:kAPI_UPLOAD_FILENAME] isKindOfClass:[NSString class]]){
            DDLogError(@"%s: Invalid kAPI_UPLOAD_FILENAME value. It should be 'NSString kind.",__PRETTY_FUNCTION__);
            return;
        }
        if(![paramDic objectForKey:kAPI_UPLOAD_FILETYPE] ||
           ![[paramDic objectForKey:kAPI_UPLOAD_FILETYPE] isKindOfClass:[NSString class]]){
            DDLogError(@"%s: Invalid kAPI_UPLOAD_FILETYPE value. It should be 'NSString kind.",__PRETTY_FUNCTION__);
            return;
        }
        if(![paramDic objectForKey:kAPI_UPLOAD_NAMEUPLOAD] ||
           ![[paramDic objectForKey:kAPI_UPLOAD_NAMEUPLOAD] isKindOfClass:[NSString class]]){
            DDLogError(@"%s: Invalid kAPI_UPLOAD_NAMEUPLOAD value. It should be 'NSString kind.",__PRETTY_FUNCTION__);
            return;
        }
        
    }
    
    id successBlock = ^(AFHTTPRequestOperation *operation, id responseObject) {
      
        NSDictionary* responseDictionary = (NSDictionary*)[JSONHelper decodeJSONToObject:[operation responseString]];
        
        if(responseDictionary != nil)
        {
            
            NSString *statusCode = [[NSString alloc] initWithFormat:@"%@",[responseDictionary objectForKey:RESPONSE_STATUS_CODE]];
            
            if([statusCode isEqualToString:[NSString stringWithFormat:@"%d", RESPONSE_STATUS_CODE_0]])
            {
                requestCompletionCallBack(YES,@"API response success.",responseDictionary, nil);
            }
            else
            {
                DDLogError(@"API response failed status code-message: %@-%@", statusCode, [responseDictionary objectForKey:RESPONSE_STATUS_MSG]);
                requestCompletionCallBack(NO,@"API respone failed.",responseDictionary, nil);
            }
            
        }else{
            DDLogError(@"%s: API response NULL.", __PRETTY_FUNCTION__);
            requestCompletionCallBack(NO,@"API response NULL.",nil, nil);
        }
    };
    
    id failBlock = ^(AFHTTPRequestOperation *operation, NSError *error) {
        DDLogError(@"%s: Error AFHTTPRequest: %@",__PRETTY_FUNCTION__, error.localizedDescription);
        requestCompletionCallBack(NO,@"Failed to call server",nil, error);
    };
    
    id uploadBlock = ^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:[paramDic objectForKey:kAPI_UPLOAD_FILEDATA] name:[paramDic objectForKey:kAPI_UPLOAD_NAMEUPLOAD] fileName:[paramDic objectForKey:kAPI_UPLOAD_FILENAME] mimeType:[paramDic objectForKey:kAPI_UPLOAD_FILETYPE]];
    };

    id completeRequestKindDownloadBlock  = ^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        NSDictionary* responseDictionary = (NSDictionary*)[JSONHelper decodeJSONToObject:[response suggestedFilename]];
        requestCompletionCallBack(YES,@"Success upload file",responseDictionary, error);
    };
    
        if ([[paramDic objectForKey:kAPI_REQUEST_KIND] isEqualToString:@"Upload"])
        {
            
            NSMutableDictionary *parametersURL = [paramDic mutableCopy];
            [parametersURL removeObjectsForKeys:[NSArray arrayWithObjects:API, kAPI_REQUEST_KIND,kAPI_REQUEST_METHOD, API_VERSION, kAPI_UPLOAD_FILEDATA, kAPI_UPLOAD_NAMEUPLOAD, kAPI_UPLOAD_FILENAME,  kAPI_UPLOAD_FILETYPE, nil]];
            
            DDLogWarn(@"Parameters for request API upload: %@", parametersURL);
            
            AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:serverURL]];
            
            manager.responseSerializer = [AFJSONResponseSerializer serializer];
            //manager.responseSerializer.acceptableContentTypes = [[NSSet alloc] initWithObjects:@"image/tiff", @"image/jpeg", @"image/gif", @"image/png", @"image/ico", @"image/x-icon", @"image/bmp", @"image/png", @"image/x-bmp", @"image/x-xbitmap", @"image/x-win-bitmap",@"application/octet-stream",@"audio/mp4",@"audio/mp3",@"audio/mov",@"audio/m4v",@"video/mp4",@"video/mov",@"video/m4v",@"audio/mpeg",@"video/mpeg", nil];
            manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
            
            AFHTTPRequestOperation *op = [manager POST:serverURL parameters:parametersURL constructingBodyWithBlock:uploadBlock success:successBlock failure:failBlock];
            
            [op start];
        
        }
        else if ([[paramDic objectForKey:kAPI_REQUEST_KIND] isEqualToString:@"Download"])
        {
            
            NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
            AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
            
            NSURL *URL = [NSURL URLWithString:serverURL];
            NSURLRequest *request = [NSURLRequest requestWithURL:URL];
            
            NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:nil destination:nil completionHandler: completeRequestKindDownloadBlock];
            [downloadTask resume];
        
        }
        else
        {
            NSMutableDictionary *parametersURL = [paramDic mutableCopy];
            
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            
            manager.responseSerializer = [AFJSONResponseSerializer serializer];
            manager.responseSerializer.acceptableContentTypes = [[NSSet alloc] initWithObjects:@"text/html", nil];
            
            [parametersURL removeObjectsForKeys:[NSArray arrayWithObjects:API, kAPI_REQUEST_KIND ,kAPI_REQUEST_METHOD, API_VERSION, nil]];
            DDLogWarn(@"Parameters for request API: %@", parametersURL);
            
            if ([[paramDic objectForKey:kAPI_REQUEST_METHOD] isEqualToString:@"POST"])
            {
                [manager POST:serverURL parameters:parametersURL success:successBlock failure:failBlock];
            } else if ([[paramDic objectForKey:kAPI_REQUEST_METHOD] isEqualToString:@"GET"]) {
                [manager GET:serverURL parameters:parametersURL success:successBlock failure:failBlock];
            } else {
                
                for (NSString *key in parametersURL) {
                    id value = [parametersURL objectForKey:key];
                    [manager.requestSerializer setValue:value forHTTPHeaderField:key];
                }
                DDLogWarn(@"%s:Parameters (in Header): %@",__PRETTY_FUNCTION__, manager.requestSerializer.HTTPRequestHeaders);
                [parametersURL removeAllObjects];
                
                [manager PUT:serverURL parameters:parametersURL success:successBlock failure:failBlock];
            }
        }
  
}

//Private method.
-(NSDictionary*) getConfigurationOfCentralServer{
    return [[NSUserDefaults standardUserDefaults] objectForKey:SERVER_CENTRAL];
}

-(NSDictionary*) getConfigurationOfTenantServer{
    return [[NSUserDefaults standardUserDefaults] objectForKey:SERVER_TENANT];
}

-(NSString*) getServerURL:(BOOL)isTenantServer{
    NSDictionary* serverConfig;
    NSString* serverURL = @"";
    
    if (isTenantServer){//Tenant Server
        serverConfig = [self getConfigurationOfTenantServer];
        
        if(!serverConfig){
            DDLogError(@"%s: Server Tenant is not yet config", __PRETTY_FUNCTION__);
            return NULL;
        }
        
        if([[serverConfig objectForKey:kAPI_ENCRYPTION_TENANT] integerValue] != 1){
            serverURL = [serverURL stringByAppendingString:@"http://"];
        }
        else
            serverURL = [serverURL stringByAppendingString:@"https://"];
        
        serverURL = [serverURL stringByAppendingString:[serverConfig objectForKey:kAPI_PROTOCOL_TENANT]];
        serverURL = [serverURL stringByAppendingString:@":"];
        serverURL = [serverURL stringByAppendingString:[serverConfig objectForKey:kAPI_PORT_TENANT]];
    }
    else{// Central Server
        serverConfig = [self getConfigurationOfCentralServer];
        
        if(!serverConfig){
            DDLogError(@"%s: Server Central is not yet config", __PRETTY_FUNCTION__);
            return NULL;
        }
        
        if([[serverConfig objectForKey:API_ENCRYPTION_CENTRAL] integerValue] != 1){
            serverURL = [serverURL stringByAppendingString:@"http://"];
        }
        else
            serverURL = [serverURL stringByAppendingString:@"https://"];
        
        serverURL = [serverURL stringByAppendingString:[serverConfig objectForKey:API_PROTOCOL_CENTRAL]];
        serverURL = [serverURL stringByAppendingString:@":"];
        serverURL = [serverURL stringByAppendingString:[serverConfig objectForKey:API_PORT_CENTRAL]];
    }
    
    return serverURL;
}


@end
