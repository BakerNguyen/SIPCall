//
//  TransactionViewCell.h
//  Satay
//
//  Created by Juriaan on 7/14/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TransactionViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *lbTransactionDate;
@property (strong, nonatomic) IBOutlet UILabel *lbService;
@property (strong, nonatomic) IBOutlet UILabel *lbTransactionMethod;
@property (strong, nonatomic) IBOutlet UILabel *lbAmount;
@property (strong, nonatomic) IBOutlet UILabel *lbStatus;

@end
