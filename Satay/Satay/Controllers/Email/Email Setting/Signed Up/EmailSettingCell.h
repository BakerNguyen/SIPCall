//
//  EmailSettingCell.h
//  Satay
//
//  Created by Nghia (William) T. VO on 7/30/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EmailSettingCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *lblTitle;
@property (strong, nonatomic) IBOutlet UILabel *lblValue;
@property (strong, nonatomic) IBOutlet UISwitch *btnSwitch;

@end
