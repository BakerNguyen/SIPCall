//
//  SecureNoteTableCell.h
//  Satay
//
//  Created by Arpana Sakpal on 2/10/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SecNoteListCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *lblName;
@property (strong, nonatomic) IBOutlet UILabel *lblTimeStamp;
@property (strong, nonatomic) NSString* secNoteId;

@end
