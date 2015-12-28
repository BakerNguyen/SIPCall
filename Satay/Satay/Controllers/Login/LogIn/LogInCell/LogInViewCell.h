//
//  LogInViewCell.h
//  Satay
//
//  Created by enclave on 1/27/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LogInViewCellDelegate;

@interface LogInViewCell : UITableViewCell<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *txtLogin;

@property(retain,nonatomic) NSString *cellNaming_PlaceHolder;

@property (nonatomic, retain) id <LogInViewCellDelegate> delegate;


@end


@protocol LogInViewCellDelegate <NSObject>
@required
- (void)LogInViewCellAction:(NSString*)name count:(int)text_count;

@end
