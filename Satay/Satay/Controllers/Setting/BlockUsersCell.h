//
//  BlockUsersCell.h
//  Satay
//
//  Created by Vi (Violet) T.T. DAO on 5/13/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BlockUsersCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *avatar;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UIButton *btnUnblock;
@property NSString *fullJID;
- (IBAction)unBlockUser:(id)sender;

@end
