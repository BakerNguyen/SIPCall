//
//  EmailSettingNotSignUp.h
//  Satay
//
//  Created by Arpana Sakpal on 3/13/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EmailSettingNotSignUp : UIViewController<UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) IBOutlet UITableView *tblView;
@property (strong, nonatomic) IBOutlet UILabel *lblSetUpEmail;
@property (strong, nonatomic) IBOutlet UILabel *lblEmailKeeping;

+(EmailSettingNotSignUp *)share;

@end

