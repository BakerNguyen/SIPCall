//
//  CActionSheet.m
//  Satay
//
//  Created by MTouche on 5/13/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import "CActionSheet.h"

@implementation UIActionSheet(Customize)

+(instancetype) alloc{
    id actionsheet = [super alloc];
    [[NSNotificationCenter defaultCenter] addObserver:actionsheet
                                             selector:@selector(appDidEnterBackground)
                                                 name:UIApplicationDidEnterBackgroundNotification object:nil];
    return actionsheet;
}

-(void) dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidEnterBackgroundNotification
                                                  object:nil];
}

-(void) appDidEnterBackground{
    [self dismissWithClickedButtonIndex:self.cancelButtonIndex animated:NO];
}

@end
