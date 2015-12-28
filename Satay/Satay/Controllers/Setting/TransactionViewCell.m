//
//  TransactionViewCell.m
//  Satay
//
//  Created by Juriaan on 7/14/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import "TransactionViewCell.h"

@implementation TransactionViewCell
@synthesize lbTransactionDate, lbService, lbTransactionMethod, lbAmount, lbStatus;
- (void)awakeFromNib {
    // Initialization code
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
