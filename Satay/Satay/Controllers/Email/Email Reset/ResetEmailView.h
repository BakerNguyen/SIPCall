//
//  ResetEmailView.h
//  Satay
//
//  Created by Arpana Sakpal on 3/16/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ResetEmailView : UIViewController
@property (strong, nonatomic) IBOutlet UIButton *buttonResetEmail;
@property (strong, nonatomic) NSString *emailAccount;

/**
 *  Action click on button reset email
 *
 *  @param sender button reset
 *  @author Arpana
 *  date 19-Mar-2015
 */
- (IBAction)clickedBtnEmailReset:(id)sender;

@end
