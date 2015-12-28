//
//  EmailLoginOffice.h
//  Satay
//
//  Created by Arpana Sakpal on 3/3/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EmailLoginOffice : UIViewController<UIScrollViewDelegate, UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate>
{
id parent;
}
    @property (strong, nonatomic) IBOutlet UIScrollView *scrollView;

@property(strong,nonatomic)IBOutlet UITableView *tblBottom;
@property (strong, nonatomic) IBOutlet UISegmentedControl *segControlImaPop;

@property (strong, nonatomic) IBOutlet UITextField *txtFieldEmail;
@property (strong, nonatomic) IBOutlet UITextField *txtIncomeHostName;
@property (strong, nonatomic) IBOutlet UITextField *txtIncomeUserName;
@property (strong, nonatomic) IBOutlet UITextField *txtIncomePassword;
@property (strong, nonatomic) IBOutlet UITextField *txtIncomeServerPort;

@property (strong, nonatomic) IBOutlet UITextField *txtOutgoHostName;
@property (strong, nonatomic) IBOutlet UITextField *txtOutgoUserName;
@property (strong, nonatomic) IBOutlet UITextField *txtOutgoPassword;
@property (strong, nonatomic) IBOutlet UITextField *txtOutgoServerPort;

@property (strong, nonatomic) IBOutlet UILabel *lblTitleDeleteEmail;
@property (strong, nonatomic) IBOutlet UILabel *lblDeleteEmail;
@property (strong, nonatomic) IBOutlet UILabel *lblTitleSyncSchedule;
@property (strong, nonatomic) IBOutlet UILabel *lblSyncSchedule;

@property (strong, nonatomic) NSString *strEmailDeletion;
@property (strong, nonatomic) NSString *strSyncSchedule;
@property (strong, nonatomic) NSString *strEmailAddress;
@property (strong, nonatomic) NSString *strPassWord;

@property (strong, nonatomic) CAlertView *alertView;

@property (assign, readonly) BOOL isImap;;
@property (assign, readonly) int numberOfRow;

/**
 *  Initialize custom alertview
 *
 *  @param theCAlertView alertview
 *
 *  @return this view controller
 *  @author Arpana
 * date 20-Mar-2015
 */
- (id)initWithCAlertView:(CAlertView *)theCAlertView;
+(EmailLoginOffice *)share;

@end
