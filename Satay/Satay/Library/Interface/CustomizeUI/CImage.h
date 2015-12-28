//
//  CImage.h
//  Satay
//
//  Created by TrungVN on 1/15/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Color)

+ (UIImage *)imageFromColor:(UIColor *)color;
+ (UIImage *)imageFromColor:(UIColor *)color Size:(CGRect) rect;

@end
