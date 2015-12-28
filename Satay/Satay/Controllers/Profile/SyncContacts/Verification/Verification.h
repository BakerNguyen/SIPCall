//
//  VerificationViewController.h
//  KryptoChat
//
//  Created by ENCLAVEIT on 4/25/14.
//  Copyright (c) 2014 mTouche. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Verification : UIViewController<UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>{
}


@property (nonatomic,retain) UIView *paddingView;

@property (strong, nonatomic) UIButton *tapHere;

@property (strong, nonatomic) UITextField *txtFieldVerCode;

@property (strong, nonatomic) IBOutlet UITableView *tblViewVerification;

@property (strong, nonatomic) NSString *countryCode;
@property (strong, nonatomic) NSString *phoneNumber;


+(Verification *)share;

@end
