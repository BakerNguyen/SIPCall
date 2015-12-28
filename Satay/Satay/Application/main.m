
//
//  main.m
//  Satay
//
//  Created by enclave on 1/6/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

int main(int argc, char *argv[])
{
    
    int mainCrash = -1;
    
    @autoreleasepool {
        @try {
            NSString* appDelegate= NSStringFromClass([AppDelegate class]);
            mainCrash = UIApplicationMain(argc, argv, nil,appDelegate );
        }
        @catch (NSException *exception) {
            [[LogFacade share] crashHandler:exception];
        }
    }
    return mainCrash;
}
