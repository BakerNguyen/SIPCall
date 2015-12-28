//
//  StatusProfile.h
//  KryptoChat
//
//  Created by ENCLAVEIT on 1/16/15.
//  Copyright (c) 2014 mTouche. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StatusProfile : UIViewController<UINavigationControllerDelegate, UITextViewDelegate>{
    
    UIButton *buttonCancel;
    UIButton *buttonSave;
    CGFloat screenWidth;
    CGFloat screenHeight;
}

@property (strong, nonatomic) UIColor *hintTextColor;
@property (strong, nonatomic) IBOutlet UITextView *txtViewStatus;
@property (strong, nonatomic) IBOutlet UILabel *lblNumberRest;

-(void) cancelStatusView;
-(void) saveStatusProfile;
-(void) updateLblNumberRest: (NSString*) strToCheck;

@end
