//
//  FullPhotoViewController.h
//  KryptoChat
//
//  Created by ENCLAVEIT on 4/29/14.
//  Copyright (c) 2014 mTouche. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewPhoto : UIViewController{

    CGFloat screenWidth;
    CGFloat screenHeight;
    UIButton *buttonClose;
    NSArray *localImages;
}
@property (strong, nonatomic) IBOutlet UIImageView *imgView;

@property (retain, nonatomic) UIButton *buttonClose;
@property (nonatomic,retain) UIView *containerView;
@property (strong, nonatomic) UIColor *bgViewColor;
@property (strong, nonatomic) NSArray *localImages;

@end
