//
//  EmailFolder.h
//  Satay
//
//  Created by Arpana Sakpal on 3/19/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EmailFolderView : UIViewController<UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UITableView *tblEmailFolder;

@property BOOL isMoveEmail;
@property (copy, nonatomic) NSArray *moveEmails;

@end
