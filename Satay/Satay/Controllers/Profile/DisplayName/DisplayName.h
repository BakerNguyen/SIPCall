//
//  DisplayNameV.h
//  KryptoChat
//
//  Created by ENCLAVEIT on 4/20/14.
//  Copyright (c) 2014 mTouche. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DisplayName : UIViewController<UINavigationControllerDelegate, UITextViewDelegate,DisplaynameDelegate>

@property (strong, nonatomic) IBOutlet UITextView *txtViewDisplayName;
@property (strong, nonatomic) IBOutlet UILabel *lblNumberRest;

+(DisplayName *)share;
-(void) cancelDisplayNameView;
-(void) updateDisplayNameFailed;

@end
