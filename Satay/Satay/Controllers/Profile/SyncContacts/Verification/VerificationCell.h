//
//  VerificationCell.h
//  KryptoChat
//
//  Created by ENCLAVEIT on 4/25/14.
//  Copyright (c) 2014 mTouche. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VerificationCell : UITableViewCell<UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UILabel *leftLabelForCell;
@property (strong, nonatomic) IBOutlet UILabel *rightLabelForCell;
@property (strong, nonatomic) IBOutlet UITextField *txtFieldForCell;


@end
