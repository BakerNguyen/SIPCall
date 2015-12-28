//
//  HeaderView.h
//  KryptoChat
//
//  Created by ENCLAVEIT on 4/18/14.
//  Copyright (c) 2014 mTouche. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HeaderView : UIView

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *loadingAvatarImage;
@property (strong, nonatomic) IBOutlet UIButton *btnProfileImage;
@property (strong, nonatomic) IBOutlet UILabel *lblKryptoMaskingId;
@property (strong, nonatomic) IBOutlet UILabel *kryptoMaskingId;
@end
