//
//  MaskingIDCell.h
//  KryptoChat
//
//  Created by TrungVN on 5/29/14.
//  Copyright (c) 2014 mTouche. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "UIButton+AppStore.h"

@interface ContactSearchMIDCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *btnAdd;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (retain, nonatomic) NSString *bob_maskingId;
@property (retain, nonatomic) NSString *bob_jid;
@property (weak, nonatomic) IBOutlet UIImageView *profile_image;


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *btnAddWidth;

@end