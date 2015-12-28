//
//  CBarButtonItem.h
//  Satay
//
//  Created by TrungVN on 1/20/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIBarButtonItem (Customize)

+(UIBarButtonItem*) createLeftButtonTitle:(NSString*) title
                                   Target:(id) target
                                   Action:(SEL)action;

+(UIBarButtonItem*) createRightButtonTitle:(NSString*) title
                                    Target:(id) target
                                    Action:(SEL)action;

@end
