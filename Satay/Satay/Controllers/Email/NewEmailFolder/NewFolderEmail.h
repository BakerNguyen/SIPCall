//
//  NewFolderEmail.h
//  Satay
//
//  Created by Arpana Sakpal on 3/19/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewFolderEmail : UIViewController
<UINavigationControllerDelegate, UITextFieldDelegate, UITextViewDelegate>

@property (strong, nonatomic) NSString *folderName;

@property (strong, nonatomic) IBOutlet UITextField *txtFieldNewFolder;
@property (strong, nonatomic) IBOutlet UITextView *txtViewNewFolder;
@property (strong, nonatomic) IBOutlet UILabel *lblNumberRest;
@end
