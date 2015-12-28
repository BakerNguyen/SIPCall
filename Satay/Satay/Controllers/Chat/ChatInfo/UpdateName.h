//
//  UpdateName.h
//  Satay
//
//  Created by TrungVN on 3/9/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UpdateName : UIViewController <UITextViewDelegate>

@property (nonatomic, retain) NSString* chatBoxId;
@property (strong, nonatomic) IBOutlet UITextView *txtUpdateName;
@property (strong, nonatomic) IBOutlet UILabel *lblCounter;

+(UpdateName *)share;

@end
