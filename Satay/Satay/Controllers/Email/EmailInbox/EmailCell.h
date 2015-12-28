//
//  EmailCell.h
//  Satay
//
//  Created by Arpana Sakpal on 3/10/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EmailCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *lblFrom;
@property (strong, nonatomic) IBOutlet UILabel *lblSubject;
@property (strong, nonatomic) IBOutlet UILabel *lblDescription;
@property (strong, nonatomic) IBOutlet UIImageView *imgAttachment;
@property (strong, nonatomic) IBOutlet UILabel *lblDate;

@property (strong, nonatomic) IBOutlet UIButton *btnLoadMore;
@end
