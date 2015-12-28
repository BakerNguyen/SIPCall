//
//  CColor.m
//  Satay
//
//  Created by MTouche on 4/1/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import "CColor.h"

@implementation UIColor (Customize)

+ (UIColor *)colorFromHexString:(NSString *)hexString {
    if(!hexString)
        return [UIColor clearColor];
    
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

+(NSString*) randomHexColor{
    NSInteger baseInt = arc4random() % 16777216;
    NSString *hex = [NSString stringWithFormat:@"%06X", baseInt];
    NSLog(@"hex %@", hex);
    return hex;
}

@end
