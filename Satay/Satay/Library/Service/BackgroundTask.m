//
//  BackgroundTask.m
//  Satay
//
//  Created by enclave on 5/5/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import "BackgroundTask.h"

@implementation BackgroundTask{

    NSOperationQueue *operationQueueTask;
    NSOperationQueue *operationMainQueueTask;
}

-(id) init
{
    self = [super init];
    if(self)
    {
        bgTask = UIBackgroundTaskInvalid;
        expirationHandler = nil;
        timer = nil;
        operationMainQueueTask = [NSOperationQueue mainQueue];

    }
    return  self;
    
}

+(BackgroundTask *)share{
    static dispatch_once_t once;
    static BackgroundTask * share;
    dispatch_once(&once, ^{
        share = [[self alloc]init];
    });
    return share;
}

- (void)startBackgroundTasks:(NSInteger)time_  target:(id)target_ selector:(SEL)selector_
{
    timerInterval = time_;
    target = target_;
    selector = selector_;
    
    [self initBackgroudTask];
    
}
- (void)initBackgroudTask
{
    operationQueueTask = [[NSOperationQueue alloc] init];
    
    [operationQueueTask addOperationWithBlock:^{
        if([self running])
            [self stopTasks];
        while([self running])
        {
            [NSThread sleepForTimeInterval:5]; //wait for finish
        }
        [self playTasks];
    }];
    
}

- (void)playTasks
{
    
    UIApplication * app = [UIApplication sharedApplication];
    
    if (bgTask != UIBackgroundTaskInvalid) {
        [self stopTasks];
    }
    
    bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
        
        [operationMainQueueTask addOperationWithBlock:^{
            if (bgTask != UIBackgroundTaskInvalid)
            {
                [self stopTasks];
            }
        }];

    }];
    
    [operationMainQueueTask addOperationWithBlock:^{
        timer = [NSTimer scheduledTimerWithTimeInterval:timerInterval target:target selector:selector userInfo:nil repeats:YES];
        NSRunLoop *runner = [NSRunLoop currentRunLoop];
        [runner addTimer:timer forMode: NSDefaultRunLoopMode];
    }];
    
}

- (void)stopTasks
{
    if (timer != nil) {
        [timer invalidate];
        timer = nil;
    }
    [[UIApplication sharedApplication] endBackgroundTask:bgTask];
    bgTask = UIBackgroundTaskInvalid;
}

- (BOOL)running
{
    if(bgTask == UIBackgroundTaskInvalid)
        return FALSE;
    return TRUE;
}

- (void)stopBackgroundTask
{
    if ([self running])
        [self stopTasks];
}

@end
