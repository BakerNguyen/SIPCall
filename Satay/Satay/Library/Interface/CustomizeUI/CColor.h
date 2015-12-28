//
//  CColor.h
//  Satay
//
//  Created by MTouche on 4/1/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Customize)

+ (UIColor *)colorFromHexString:(NSString *)hexString;
+ (NSString*) randomHexColor;

@end
