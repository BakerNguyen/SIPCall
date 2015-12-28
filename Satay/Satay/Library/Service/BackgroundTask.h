//
//  BackgroundTask.h
//  Satay
//
//  Created by enclave on 5/5/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface BackgroundTask : NSObject
{
    __block UIBackgroundTaskIdentifier bgTask;
    __block dispatch_block_t expirationHandler;
    __block NSTimer * timer;
    
    NSInteger timerInterval;
    id target;
    SEL selector;
}
- (void)startBackgroundTasks:(NSInteger)time_  target:(id)target_ selector:(SEL)selector_;
- (void)stopBackgroundTask;
+(BackgroundTask *)share;
@end
