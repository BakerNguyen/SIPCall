//
//  SettingsViewController.h
//  Satay
//
//  Created by Arpana Sakpal on 2/4/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebMyAccount.h"

@interface SettingsViewController : UIViewController<UITableViewDataSource,UITableViewDelegate, AppSettingDelegate>
@property (strong, nonatomic) IBOutlet UILabel *lblnetworkStatus;

@property (strong, nonatomic) IBOutlet UITableView *tblSettingMenu;

@property (strong, nonatomic) NSString* isXMPPConnected;

- (IBAction)notificationSoundChange:(id)sender;
- (IBAction)attachCrashLogFileChange:(id)sender;
- (IBAction)notificationChange:(id)sender;
- (IBAction)passwordLockChange:(id)sender;

-(void) updateJuzChatVersion;
-(void) updateNetworkStatus:(BOOL) isXMPPConnected;
-(void) reloadSettingsTable;

+(SettingsViewController *)share;
@end
