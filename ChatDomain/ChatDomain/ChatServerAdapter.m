//
//  ServerAdapter.m
//  ChatDomain
//
//  Created by MTouche on 1/12/15.
//  Copyright (c) 2015 mTouche. All rights reserved.
//

#import "ChatServerAdapter.h"

#import "AFNetworking.h"
#import "JSONHelper.h"
#import "CocoaLumberjack.h"

@implementation ChatServerAdapter

#define SERVER_CENTRAL @"SERVER_CENTRAL"
#define API_ENCRYPTION_CENTRAL @"API_ENCRYPTION_CENTRAL"
#define API_PROTOCOL_CENTRAL @"API_PROTOCOL_CENTRAL"
#define API_PORT_CENTRAL @"API_PORT_CENTRAL"

#define SERVER_TENANT @"SERVER_TENANT"
#define API_ENCRYPTION_TENANT @"API_ENCRYPTION_TENANT"
#define API_PROTOCOL_TENANT @"API_PROTOCOL_TENANT"
#define API_PORT_TENANT @"API_PORT_TENANT"

#define API_VERSION @"API_VERSION"

#define API @"API"

#define API_REQUEST_METHOD @"API_REQUEST_METHOD"// POST or GET
#define API_REQUEST_KIND @"API_REQUEST_KIND"// Upload or Download or Normal
#define API_REQUEST_FILEPATH @"API_REQUEST_FILEPATH"// This for upload file

//Define respone from server
#define RESPONSE_STATUS_MSG @"STATUS_MSG"
#define RESPONSE_STATUS_CODE @"STATUS_CODE"
#define RESPONSE_SUCCESS @"SUCCESS"

#define METHOD_POST @"POST"
#define METHOD_GET @"GET"
#define METHOD_PUT @"PUT"

#define RESPONSE_STATUS_CODE_0 0

#define API_SUCCESS_STATUS @"1"

//Logging
#ifdef DEBUG
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelError;
#endif

+(ChatServerAdapter *)share{
    static dispatch_once_t once;
    static ChatServerAdapter * share;
    dispatch_once(&once, ^{
        share = [self new];
        [DDLog addLogger:[DDASLLogger sharedInstance]];
        [DDLog addLogger:[DDTTYLogger sharedInstance]];
        
        setenv("XcodeColors", "YES", 0);
        [[DDTTYLogger sharedInstance] setColorsEnabled:YES];
        [[DDTTYLogger sharedInstance] setForegroundColor:[UIColor greenColor] backgroundColor:nil forFlag:DDLogFlagInfo];
        [[DDTTYLogger sharedInstance] setForegroundColor:[UIColor redColor] backgroundColor:nil forFlag:DDLogFlagError];
        [[DDTTYLogger sharedInstance] setForegroundColor:[UIColor orangeColor] backgroundColor:nil forFlag:DDLogFlagWarning];
        [[DDTTYLogger sharedInstance] setForegroundColor:[UIColor grayColor] backgroundColor:nil forFlag:DDLogFlagVerbose];
    });
    return share;
}

-(void) configServerCentral{
    NSMutableDictionary* serverConfig = [NSMutableDictionary new];
    [serverConfig setValue:@"0" forKey:API_ENCRYPTION_CENTRAL];
    [serverConfig setValue:@"sataydevcapi.mtouche-mobile.com" forKey:API_PROTOCOL_CENTRAL];
    [serverConfig setValue:@"80" forKey:API_PORT_CENTRAL];
    [[NSUserDefaults standardUserDefaults] setValue:serverConfig forKey:SERVER_CENTRAL];
}

-(void) configServerTenant:(NSDictionary*) serverConfig{
    if(!serverConfig){
        NSLog(@"%s: serverConfig cannot be NULL", __PRETTY_FUNCTION__);
        return;
    }
    
    if(![serverConfig objectForKey:API_ENCRYPTION_TENANT] ||
       [[serverConfig objectForKey:API_ENCRYPTION_TENANT] isEqualToString:@""]){
        NSLog(@"%s: serverConfig do not have valid API_ENCRYPTION_TENANT value",__PRETTY_FUNCTION__);
        return;
    }
    if(![serverConfig objectForKey:API_PROTOCOL_TENANT] ||
       [[serverConfig objectForKey:API_PROTOCOL_TENANT] isEqualToString:@""] ){
        NSLog(@"%s: serverConfig do not have contain API_PROTOCOL_TENANT value",__PRETTY_FUNCTION__);
        return;
    }
    if(![serverConfig objectForKey:API_PORT_TENANT] ||
       [[serverConfig objectForKey:API_PORT_TENANT] isEqualToString:@""] ){
        NSLog(@"%s: serverConfig do not have contain API_PORT_TENANT value",__PRETTY_FUNCTION__);
        return;
    }
    [[NSUserDefaults standardUserDefaults] setValue:serverConfig forKey:SERVER_TENANT];
}

-(NSDictionary*) getConfigurationOfCentralServer{
    return [[NSUserDefaults standardUserDefaults] valueForKey:SERVER_CENTRAL];
}

-(NSDictionary*) getConfigurationOfTenantServer{
    return [[NSUserDefaults standardUserDefaults] valueForKey:SERVER_TENANT];
}

-(NSString*) getServerURL:(BOOL)isTenantServer{
    
    NSDictionary* serverConfig;
    NSString* serverURL = @"";
    
    if (isTenantServer){//Tenant Server
        serverConfig = [self getConfigurationOfTenantServer];
        
        if(!serverConfig){
            DDLogError(@"%s: Server is not yet config, run configServerTenant 1st", __PRETTY_FUNCTION__);
            return NULL;
        }
        
        if([[serverConfig objectForKey:API_ENCRYPTION_TENANT] integerValue] != 1)
            serverURL = [serverURL stringByAppendingString:@"http://"];
        else
            serverURL = [serverURL stringByAppendingString:@"https://"];
        
        serverURL = [serverURL stringByAppendingString:[serverConfig objectForKey:API_PROTOCOL_TENANT]];
        serverURL = [serverURL stringByAppendingString:@":"];
        serverURL = [serverURL stringByAppendingString:[serverConfig objectForKey:API_PORT_TENANT]];
    }
    else{// Central Server
        serverConfig = [self getConfigurationOfCentralServer];
        
        if(!serverConfig){
            DDLogError(@"%s: Server is not yet config, run configServerCentral 1st", __PRETTY_FUNCTION__);
            return NULL;
        }
        
        if([[serverConfig objectForKey:API_ENCRYPTION_CENTRAL] integerValue] != 1)
            serverURL = [serverURL stringByAppendingString:@"http://"];
        else
            serverURL = [serverURL stringByAppendingString:@"https://"];
        
        serverURL = [serverURL stringByAppendingString:[serverConfig objectForKey:API_PROTOCOL_CENTRAL]];
        serverURL = [serverURL stringByAppendingString:@":"];
        serverURL = [serverURL stringByAppendingString:[serverConfig objectForKey:API_PORT_CENTRAL]];
    }
    
    return serverURL;
}

-(void) requestService:(NSDictionary*) paramDic
          tenantServer:(BOOL)isTenantServer
        uploadProgress:(uploadProgress) uploadProgress
              callback:(requestCompletionBlock)callback{
    
    void (^requestCompletionCallBack)(BOOL success, NSString *message ,NSDictionary *response, NSError *error);
    
    requestCompletionCallBack = callback;
    
    if(!paramDic){
        DDLogError(@"%s: FAILED:paramDic NULL",__PRETTY_FUNCTION__);
        return;
    }
    
    NSString* paramAPI = [paramDic objectForKey:API];
    if(![paramAPI isKindOfClass:[NSString class]] || paramAPI.length == 0){
        DDLogError(@"%s: FAILED:paramDic didn't have valid API value",__PRETTY_FUNCTION__);
        return;
    }
    
    NSString* paramVersion = [paramDic objectForKey:API_VERSION];
    if(![paramVersion isKindOfClass:[NSString class]] || paramVersion.length == 0){
        DDLogError(@"%s: FAILED:paramDic didn't have valid API_VERSION value",__PRETTY_FUNCTION__);
        return;
    }
    
    NSString* serverURL = [self getServerURL:isTenantServer];
    if(serverURL.length == 0){
        DDLogError(@"%s: FAILED: serverURL NULL.", __PRETTY_FUNCTION__);
        return;
    }
    
    serverURL = [serverURL stringByAppendingString:@"/"];
    serverURL = [serverURL stringByAppendingString:[paramDic objectForKey:API_VERSION]];
    serverURL = [serverURL stringByAppendingString:@"/"];
    serverURL = [serverURL stringByAppendingString:[paramDic objectForKey:API]];
    
    DDLogInfo(@"%s serverURL %@", __PRETTY_FUNCTION__, serverURL);
    
    // Check request method. POST, PUT or GET is acceptable.
//#warning all newly created API (v2) will use PUT method and param in header (@Daniel)
    NSString* requestMethod = [[paramDic objectForKey:kAPI_REQUEST_METHOD] uppercaseString];
    if(![requestMethod isEqualToString:METHOD_POST] &&
         ![requestMethod isEqualToString:METHOD_GET] &&
         ![requestMethod isEqualToString:METHOD_PUT]){
           DDLogError(@"%s: paramDic didn't have valid API_REQUEST_METHOD value. It should be 'POST', 'PUT' or 'GET'.",__PRETTY_FUNCTION__);
           return;
       }

    // Check request kind. Upload, Download or Normal only.
    NSString* requestKind = [paramDic objectForKey:kAPI_REQUEST_KIND];
    if(![requestKind isEqualToString:@"Upload"] &&
         ![requestKind isEqualToString:@"Download"] &&
         ![requestKind isEqualToString:@"Normal"]){
           
           DDLogError(@"%s: paramDic didn't have valid API_REQUEST_KIND value. It should be 'Upload' or 'Download' or 'Normal'.",__PRETTY_FUNCTION__);
           return;
       }
    
    if([[paramDic objectForKey:kAPI_REQUEST_KIND] isEqualToString:@"Upload"]){
        if(![paramDic objectForKey:kAPI_UPLOAD_FILEDATA] ||
           ![[paramDic objectForKey:kAPI_UPLOAD_FILEDATA] isKindOfClass:[NSData class]]){
            DDLogError(@"%s: paramDic didn't have valid kAPI_UPLOAD_FILEDATA value. It should be 'NSData kind.",__PRETTY_FUNCTION__);
            return;
        }
        if(![paramDic objectForKey:kAPI_UPLOAD_FILENAME] ||
           ![[paramDic objectForKey:kAPI_UPLOAD_FILENAME] isKindOfClass:[NSString class]]){
            DDLogError(@"%s: paramDic didn't have valid kAPI_UPLOAD_FILENAME value. It should be 'NSString kind.",__PRETTY_FUNCTION__);
            return;
        }
        if(![paramDic objectForKey:kAPI_UPLOAD_FILETYPE] ||
           ![[paramDic objectForKey:kAPI_UPLOAD_FILETYPE] isKindOfClass:[NSString class]]){
            DDLogError(@"%s: paramDic didn't have valid kAPI_UPLOAD_FILETYPE value. It should be 'NSString kind.",__PRETTY_FUNCTION__);
            return;
        }
        if(![paramDic objectForKey:kAPI_UPLOAD_NAMEUPLOAD] ||
           ![[paramDic objectForKey:kAPI_UPLOAD_NAMEUPLOAD] isKindOfClass:[NSString class]]){
            DDLogError(@"%s: paramDic didn't have valid kAPI_UPLOAD_NAMEUPLOAD value. It should be 'NSString kind.",__PRETTY_FUNCTION__);
            return;
        }
    }
    
    id successBlock = ^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary* responseDictionary = (NSDictionary*)[JSONHelper decodeJSONToObject:[operation responseString]];
        
        if(responseDictionary != nil)
        {
            NSString *statusCode = [[NSString alloc] initWithFormat:@"%@",[responseDictionary objectForKey:RESPONSE_STATUS_CODE]];
            
            if([statusCode isEqualToString:[NSString stringWithFormat:@"%d", RESPONSE_STATUS_CODE_0]]){
                requestCompletionCallBack(YES,@"API response success.",responseDictionary, nil);
            }
            else{
                DDLogError(@"%s: FAILED %@-%@",__PRETTY_FUNCTION__, statusCode, [responseDictionary objectForKey:RESPONSE_STATUS_MSG]);
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
        //NSLog(@"File downloaded to: %@", filePath);
        NSDictionary* responseDictionary = (NSDictionary*)[JSONHelper decodeJSONToObject:[response suggestedFilename]];
        requestCompletionCallBack(YES,@"Success upload file",responseDictionary, error);
    };
    
    
    if ([[paramDic objectForKey:kAPI_REQUEST_KIND] isEqualToString:@"Upload"])
    {
        NSMutableDictionary *parametersURL = [paramDic mutableCopy];
        [parametersURL removeObjectsForKeys:[NSArray arrayWithObjects:API, kAPI_REQUEST_KIND,kAPI_REQUEST_METHOD, API_VERSION, kAPI_UPLOAD_FILEDATA, kAPI_UPLOAD_NAMEUPLOAD, kAPI_UPLOAD_FILENAME,  kAPI_UPLOAD_FILETYPE, nil]];
        
        DDLogWarn(@"%s parametersURL %@", __PRETTY_FUNCTION__, parametersURL);
        
        AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:serverURL]];
        
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        //manager.responseSerializer.acceptableContentTypes = [[NSSet alloc] initWithObjects:@"image/tiff", @"image/jpeg", @"image/gif", @"image/png", @"image/ico", @"image/x-icon", @"image/bmp", @"image/png", @"image/x-bmp", @"image/x-xbitmap", @"image/x-win-bitmap",@"application/octet-stream",@"audio/mp4",@"audio/mp3",@"audio/mov",@"audio/m4v",@"video/mp4",@"video/mov",@"video/m4v",@"audio/mpeg",@"video/mpeg", nil];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
        
        AFHTTPRequestOperation *op = [manager POST:serverURL parameters:parametersURL constructingBodyWithBlock:uploadBlock success:successBlock failure:failBlock];
        if (uploadProgress) {
            [op setUploadProgressBlock:uploadProgress];
        }
        
        [op start];
        
    }else if ([[paramDic objectForKey:kAPI_REQUEST_KIND] isEqualToString:@"Download"]){
        
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
        
        NSURL *URL = [NSURL URLWithString:serverURL];
        NSURLRequest *request = [NSURLRequest requestWithURL:URL];
        
        NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:nil destination:nil completionHandler: completeRequestKindDownloadBlock];
        [downloadTask resume];
        
    }else{
        NSMutableDictionary *parametersURL = [paramDic mutableCopy];
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        manager.responseSerializer.acceptableContentTypes = [[NSSet alloc] initWithObjects:@"text/html", nil];
        
        [parametersURL removeObjectsForKeys:[NSArray arrayWithObjects:API, kAPI_REQUEST_KIND ,kAPI_REQUEST_METHOD, API_VERSION, nil]];
        DDLogWarn(@"%s parametersURL %@", __PRETTY_FUNCTION__, parametersURL);
        
        NSString* method = [[paramDic objectForKey:kAPI_REQUEST_METHOD] uppercaseString];
        
        if ([method isEqualToString:METHOD_POST]) {
            [manager POST:serverURL parameters:parametersURL success:successBlock failure:failBlock];
        } else if([method isEqualToString:METHOD_GET]) {
            [manager GET:serverURL parameters:parametersURL success:successBlock failure:failBlock];
        } else {
            for (NSString *key in parametersURL) {
                id value = [parametersURL objectForKey:key];
                [manager.requestSerializer setValue:value forHTTPHeaderField:key];
            }
            [manager PUT:serverURL parameters:parametersURL success:successBlock failure:failBlock];
        }
    }
}

@end
