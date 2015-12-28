//
//  LogIn.h
//  Satay
//
//  Created by enclave on 1/27/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LogInViewCell.h"
#import "LoginPasswordCell.h"
#import "LogInFirstScreen.h"

@interface LogIn : UIViewController<UITableViewDataSource,UITableViewDelegate,LogInViewCellDelegate,LogInPasswordCellDelegate>


@property (nonatomic, retain) NSMutableArray *LogIn2CellName;
@property (weak, nonatomic) IBOutlet UITableView *tblLogIn;
@property (nonatomic, retain) NSString* pushView;

+(LogIn *)share;

@end
