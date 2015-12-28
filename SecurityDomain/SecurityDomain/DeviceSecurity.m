//
//  DeviceSecurity.m
//  SecurityDomain
//
//  Created by Van Trung on 6/25/15.
//  Copyright (c) 2015 mTouche. All rights reserved.
//

#import "DeviceSecurity.h"
#define BLANK_WINDOW_TAG -5877

@implementation DeviceSecurity

// [iOS] - CASE 12 - Security Issue - Application continues to work on Jailbroken/Rooted device
+(BOOL)isJailbroken
{
#if !(TARGET_IPHONE_SIMULATOR)
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:@"/Applications/Cydia.app"] ||
        [[NSFileManager defaultManager] fileExistsAtPath:@"/Library/MobileSubstrate/MobileSubstrate.dylib"] ||
        [[NSFileManager defaultManager] fileExistsAtPath:@"/bin/bash"] ||
        [[NSFileManager defaultManager] fileExistsAtPath:@"/usr/sbin/sshd"] ||
        [[NSFileManager defaultManager] fileExistsAtPath:@"/etc/apt"] ||
        [[NSFileManager defaultManager] fileExistsAtPath:@"/private/var/lib/apt/"] ||
        [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"cydia://package/com.example.package"]])
    {
        return YES;
    }
    
    FILE *f = NULL ;
    if ((f = fopen("/bin/bash", "r")) ||
        (f = fopen("/Applications/Cydia.app", "r")) ||
        (f = fopen("/Library/MobileSubstrate/MobileSubstrate.dylib", "r")) ||
        (f = fopen("/usr/sbin/sshd", "r")) ||
        (f = fopen("/etc/apt", "r")))
    {
        fclose(f);
        return YES;
    }
    fclose(f);
#endif
    return NO;
}

// Bug 8843:[iOS][Security Issues] - SCD-014 (Medium risk) Cached data information leakage
+(void)removeCacheDataInsideApp {
    
    NSString *caches = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, TRUE) objectAtIndex:0];
    NSString *appID = [[NSBundle mainBundle] infoDictionary][@"CFBundleIdentifier"];
    NSString *pathCacheDBWall = [NSString stringWithFormat:@"%@/%@/Cache.db-wal", caches, appID];
    [[NSFileManager defaultManager] removeItemAtPath:pathCacheDBWall error:nil];
    NSString *pathCacheDB= [NSString stringWithFormat:@"%@/%@/Cache.db", caches, appID];
    [[NSFileManager defaultManager] removeItemAtPath:pathCacheDB error:nil];
    
    NSString *pathCacheDBShm= [NSString stringWithFormat:@"%@/%@/Cache.db-shm", caches, appID];
    [[NSFileManager defaultManager] removeItemAtPath:pathCacheDBShm error:nil];
}

/* Bug 8846:[iOS][Security Issues] - SCD-015 (Medium risk) Backgrounding snapshots may leak information*/
+ (void)addBlankViewForSnapShotPrevention:(UIWindow*)window {
    if (!window) {
        return;
    }
    // only add view if that view is not display
    if ([window viewWithTag:BLANK_WINDOW_TAG])
        return;
    
    // fill screen with our own colour
    UIView *colourView = [[UIView alloc]initWithFrame:window.frame];
    colourView.backgroundColor = [UIColor blackColor];
    colourView.tag = BLANK_WINDOW_TAG;
    colourView.alpha = 0;
    [window addSubview:colourView];
    [window bringSubviewToFront:colourView];
    
    // fade in the view
    [UIView animateWithDuration:0.3 animations:^{
        colourView.alpha = 1;
    }];
}

/*Bug 8846:[iOS][Security Issues] - SCD-015 (Medium risk) Backgrounding snapshots may leak information*/
+ (void)removeBlankViewForSnapShotPrevention:(UIWindow*)window {
    if (!window) {
        return;
    }
    
    // grab a reference to our coloured view
    UIView *colourView = [window viewWithTag:BLANK_WINDOW_TAG];
    
    // fade away colour view from main view
    [UIView animateWithDuration:0.3 animations:^{
        colourView.alpha = 0;
    } completion:^(BOOL finished) {
        // remove when finished fading
        [colourView removeFromSuperview];
    }];
}

+(void) clearDeviceCache{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError * error;
    NSArray * cacheFiles = [fileManager contentsOfDirectoryAtPath:NSTemporaryDirectory() error:&error];
    
    for(NSString * file in cacheFiles)
    {
        error=nil;
        NSString * filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:file ];
        [fileManager removeItemAtPath:filePath error:&error];
        if(error){
            NSLog(@"ERROR: %@", [error description]);
        }
    }
}

@end
