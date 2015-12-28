//
//  HeaderContact.h
//  KryptoChat
//
//  Created by TrungVN on 6/4/14.
//  Copyright (c) 2014 mTouche. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HeaderContact : UIView

@property (nonatomic, retain) IBOutlet UIButton* btnAvatar;
@property (nonatomic, retain) IBOutlet UIImageView* imgAvatar;

@property (nonatomic, retain) IBOutlet UILabel* lblMasking;
@property (nonatomic, retain) IBOutlet UILabel* lblMaskingContent;
@property (nonatomic, retain) IBOutlet UILabel* lblStatus;
@property (nonatomic, retain) IBOutlet UILabel* lblStatusContent;

-(void) buildView:(ChatBox*) chatBox;

@end
