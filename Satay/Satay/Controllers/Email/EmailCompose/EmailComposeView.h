//
//  EmailComposeView.h
//  Satay
//
//  Created by Nghia (William) T. VO on 4/21/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TPKeyboardAvoidingScrollView;
@interface EmailComposeView : UIViewController<UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITextViewDelegate, UITextFieldDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIWebViewDelegate>

typedef enum {
    kCOMPOSE_EMAIL_ACTION_COMPOSE,
    kCOMPOSE_EMAIL_ACTION_REOPEN_COMPOSE,
    kCOMPOSE_EMAIL_ACTION_REPLY,
    kCOMPOSE_EMAIL_ACTION_REPLY_ALL,
    kCOMPOSE_EMAIL_ACTION_FOWARD
} ComposeEmailAction;

typedef enum {
    kActiveTextFiledTO,
    kActiveTextFiledCC,
    kActiveTextFiledBCC,
} ActiveTextField;

@property (assign, nonatomic) ComposeEmailAction *composeAction;
@property (assign, nonatomic) MailContent *emailContents;
@property (assign, nonatomic) MailHeader *emailHeader;
@property (strong, nonatomic) NSString *toEmailAddress;
@property (strong, nonatomic) NSMutableArray *arrayAttachment;
@property (assign, nonatomic) ActiveTextField *activeTextField;
@property (strong, nonatomic) NSMutableArray *arrayReceipient;

@property (strong, nonatomic) IBOutlet TPKeyboardAvoidingScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIView *headerButtonsView;
@property (strong, nonatomic) IBOutlet UIView *headerView;
@property (strong, nonatomic) IBOutlet UIView *bodyView;

@property (strong, nonatomic) IBOutlet UIButton *btnAttachment;
@property (strong, nonatomic) IBOutlet UIButton *btnSaveEmail;

@property (strong, nonatomic) IBOutlet UITextField *textFieldTo;
@property (strong, nonatomic) IBOutlet UITextField *textFieldCC;
@property (strong, nonatomic) IBOutlet UITextField *textFieldBCC;
@property (strong, nonatomic) IBOutlet UITextField *textFieldSubject;

@property (strong, nonatomic) IBOutlet UICollectionView *attachmentView;
@property (strong, nonatomic) IBOutlet UITextView *textViewBody;
@property (strong, nonatomic) IBOutlet UIButton *btnEncrypt;
@property (strong, nonatomic) IBOutlet UILabel *lblEncryptMess;
@property (strong, nonatomic) IBOutlet UIWebView *webEmailContent;

@property (strong, nonatomic) IBOutlet UILabel *lblTo;
@property (strong, nonatomic) IBOutlet UILabel *lblCC;
@property (strong, nonatomic) IBOutlet UILabel *lblBCC;
@property (strong, nonatomic) IBOutlet UILabel *lblSubject;

@property (strong, nonatomic) IBOutlet UIButton *btnAddTo;
@property (strong, nonatomic) IBOutlet UIButton *btnAddCC;
@property (strong, nonatomic) IBOutlet UIButton *btnAddBCC;

/**
 *  Action click on button add attachment in email
 *
 *  @param sender button add attachment
 *  @author William
 *  date 6-May-2015
 */
- (IBAction)addAttachment:(id)sender;

/**
 *  Action click on button save email
 *
 *  @param sender button save
 *  @author William
 *  date 6-May-2015
 */
- (IBAction)saveEmail:(id)sender;

/**
 *  Action click on button encrypted email
 *
 *  @param sender button encrypted email
 *  @author William
 *  date 6-May-2015
 */
- (IBAction)encryptEmail:(id)sender;

/**
 *  Action click on button add receipient into field
 *
 *  @param sender button add receipient
 *  @author William
 *  date 6-May-2015
 */
- (IBAction)addReceipient:(id)sender;

/**
 *  Get choosen receipients in find email contact then add active text field
 *
 *  @param arrayContactSelect array of choosen receipients
 *  @author William
 *  date 6-May-2015
 */
- (void) addReceipientIntoTextFieldWithData:(NSMutableArray *)arrayContactSelect;
+(EmailComposeView *)share;
@end
