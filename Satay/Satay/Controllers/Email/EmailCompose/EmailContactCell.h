//
//  EmailContactCell.h
//  Satay
//
//  Created by Arpana Sakpal on 3/11/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EmailContactCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *lblName;
@property (strong, nonatomic) IBOutlet UILabel *lblMessage;
@property (strong, nonatomic) IBOutlet UIImageView *imgContact;
@property (strong, nonatomic) IBOutlet UIButton *btnCheck;

/**
 *  Action click on button choose email
 *
 *  @param sender button check
 *  @author Arpana
 *  date 19-Mar-2015
 */
- (IBAction)clickedBtnCheck:(id)sender;

@end
