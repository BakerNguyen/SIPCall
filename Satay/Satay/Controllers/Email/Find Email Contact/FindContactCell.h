//
//  FindContactCell.h
//  Satay
//
//  Created by Arpana Sakpal on 3/17/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FindContactCell : UITableViewCell


@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UILabel *lblMessage;
@property (weak, nonatomic) IBOutlet UIImageView *contactAvatar;
@property (weak, nonatomic) IBOutlet UIButton *contactCheck;

/**
 *  Action click on button choose contact
 *
 *  @param sender button check
 *  @author Arpana
 *  date 19-Mar-2015
 */
- (IBAction)clickedBtnCheck:(id)sender;

/**
 *  Display table view cell info
 *
 *  @param contactInfo contact infomation at that cell
 *  @author Danil Nguyen
 *  Date 6-Apr-2015
 */
- (void)displayCell:(Contact *)contactInfo;


@end
