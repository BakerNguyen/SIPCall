//
//  EmailSetting.h
//  Satay
//
//  Created by Arpana Sakpal on 3/13/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EmailSignatureSetting.h"
#import "EmailKeeping.h"

@interface EmailSetting : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    int is_Encrypted;
    int is_Notification;
    
}
@property (strong, nonatomic) IBOutlet UITableView *tblEmailSetting;
@property (strong, nonatomic) UIPopoverController *popOver;
@property (strong, nonatomic) EmailKeeping *emailKeepingVC;
@property (strong, nonatomic) EmailSignatureSetting *emailSignature;
@property (strong, nonatomic) UIButton *closeButton;
@property (strong, nonatomic) NSString *signatureStr;
@property (strong, nonatomic) MailAccount *mailAccountObj;
@property (strong, nonatomic) IBOutlet UISwitch *switchNotification;
@property (strong, nonatomic) IBOutlet UILabel *lblGeneral;
@property (strong, nonatomic) IBOutlet UILabel *lblDot;
@property (strong, nonatomic) IBOutlet UIButton *btnEmail;

+(EmailSetting *)share;

@end
