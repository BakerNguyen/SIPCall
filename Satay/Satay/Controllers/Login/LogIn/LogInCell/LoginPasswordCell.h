//
//  LoginPasswordCell.h
//  Satay
//
//  Created by enclave on 1/27/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol LogInPasswordCellDelegate;

@interface LoginPasswordCell : UITableViewCell<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *txtLogin;

@property(retain,nonatomic) NSString *cellNaming_PlaceHolder;

@property (nonatomic, retain) id <LogInPasswordCellDelegate> delegate;


@end


@protocol LogInPasswordCellDelegate <NSObject>
@required



- (void)LogInPasswordCellAction:(NSString*)name count:(int)text_count;

@end

