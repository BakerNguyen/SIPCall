//
//  WebMyAccount.h
//  Satay
//
//  Created by Arpana Sakpal on 2/5/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebMyAccount : UIViewController <UIWebViewDelegate,UIActionSheetDelegate>
@property (strong, nonatomic) IBOutlet UIWebView *webContentMyAccount;
@property (strong, nonatomic) IBOutlet UILabel *kryptoID;
@property (strong, nonatomic) IBOutlet UILabel *deviceName;
@property (strong, nonatomic) IBOutlet UILabel *started;
@property (strong, nonatomic) IBOutlet UILabel *end;
@property (strong, nonatomic) IBOutlet UILabel *accountStatus;
@property (strong, nonatomic) IBOutlet UIView *container;
+(WebMyAccount *)share;
@end
