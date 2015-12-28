//
//  Advanced.h
//  Satay
//
//  Created by Arpana Sakpal on 3/12/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Advanced: UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    id parent;
    int numberOfRow;
    int isUseSSL;
    
}
@property (strong, nonatomic) IBOutlet UILabel *topLine;

@property (strong, nonatomic) IBOutlet UITableView *tblViewAdvanced;

@property (strong, nonatomic) NSString *strEmailDeletion;
@property (strong, nonatomic) NSString *strSyncSchedule;
@property (strong, nonatomic) NSString *strAuthentication;
/**
 *  Action click switch use ssl or not
 *
 *  @param sender switch SSL
 *  @author Arpana
 */
- (IBAction)clickedSwitchUseSSL:(id)sender;
@property BOOL isImapEmail;
@end
