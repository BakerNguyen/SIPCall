//
//  TransactionHistory.h
//  Satay
//
//  Created by Juriaan on 7/14/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TransactionHistory : UIViewController <UITableViewDataSource,UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tbTransactionHistory;
@property (strong, nonatomic) NSArray* arrayOfTransactionHistory;
@property (strong, nonatomic) IBOutlet UILabel *lbNoTransactionHistory;
+(TransactionHistory *)share;
@end
