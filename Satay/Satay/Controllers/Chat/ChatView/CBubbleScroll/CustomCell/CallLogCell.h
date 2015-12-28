//
//  CallLogCell.h
//  KryptoChat
//
//  Created by Ba (Baker) V. NGUYEN on 10/17/14.
//  Copyright (c) 2014 mTouche. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CallLogCell : UIView


@property (weak, nonatomic) IBOutlet UIImageView *imageCallLog;
@property (weak, nonatomic) IBOutlet UILabel *statusCallLog;
@property (nonatomic,strong) NSString *cellID;

- (void)initCallCell:(NSString *)messageID;
- (IBAction)callBubbleAction:(id)sender;

@end
