//
//  NewFolderEmail.m
//  Satay
//
//  Created by Arpana Sakpal on 3/19/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import "NewFolderEmail.h"
#define MAX_LENGHT_TEXT     15
@interface NewFolderEmail ()
{
    MailAccount *mailAccountObj;
    NSString *userName;
    BOOL isUpdated;
    BOOL isDescending;
    MailFolder *mailFolderObj;
    
}
@end

@implementation NewFolderEmail

@synthesize txtFieldNewFolder;
@synthesize folderName;
@synthesize txtViewNewFolder;
@synthesize lblNumberRest;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self)
    {

    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title=TITLE_ADD_NEW_FOLDER;
    self.navigationItem.rightBarButtonItem=[UIBarButtonItem createRightButtonTitle:_SAVE Target:self Action:@selector(saveNewFolder)];
    self.navigationItem.leftBarButtonItem=[UIBarButtonItem createLeftButtonTitle:_CANCEL Target:self Action:@selector(cancelAddNewFolder)];

    
    
    self.navigationItem.rightBarButtonItem.enabled = NO;
    txtFieldNewFolder.hidden = YES;
    txtFieldNewFolder.delegate = self;
    txtViewNewFolder.delegate = self;
    
    if (folderName.length > 0)
    {
        txtViewNewFolder.text = folderName;
    }
    
    int numberRest = MAX_LENGHT_TEXT - txtViewNewFolder.text.length;
    lblNumberRest.text = [NSString stringWithFormat:@"%d", numberRest];
    lblNumberRest.textColor = COLOR_170170170;
    lblNumberRest.font = [UIFont systemFontOfSize:FONT_TEXT_SIZE_14];
    [self changeLanguage];
    mailFolderObj =[MailFolder new];
    //NSArray *mailFolders = [[EmailFacade share] getAllEmailFolders];
    [EmailFacade share].createEmailFolderDelegate = self;
}

- (void)changeLanguage
{
    self.navigationItem.title=NSLocalizedString(TITLE_ADD_NEW_FOLDER, nil);

    self.navigationItem.rightBarButtonItem.title=NSLocalizedString(_SAVE, nil);
    self.navigationItem.leftBarButtonItem.title=NSLocalizedString(_CANCEL, nil);
    
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [txtViewNewFolder becomeFirstResponder];
}

- (void)cancelAddNewFolder
{
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (void)saveNewFolder
{
    [self.view endEditing:YES];
    [[EmailFacade share] saveEmailFolderName:txtViewNewFolder.text oldName:folderName];
}

- (void) createFolderSucceded
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) showAlertDuplicateName
{
    [[CAlertView new] showError:mError_Folder_Exist];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    return YES;
}


- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    /*
     * Parker update old flow again. related to bug 2270
     */
    NSUInteger newLength = [textView.text length] + [text length] - range.length;
    
    if ([text isEqualToString:@"\n"])
    {
        [txtViewNewFolder resignFirstResponder];
    }
    
    if (newLength > 0)
    {
        if (newLength > MAX_LENGHT_TEXT && newLength < UINT32_MAX)
        {
            [txtViewNewFolder resignFirstResponder];
            return NO;
        }
        else
        {
            // Enable Save button
            self.navigationItem.rightBarButtonItem.enabled = YES;
            int numberRest = MAX_LENGHT_TEXT - newLength;
            lblNumberRest.text = [NSString stringWithFormat:@"%d", numberRest];
        }
    }
    else
    {
        lblNumberRest.text = [NSString stringWithFormat:@"%d", MAX_LENGHT_TEXT];
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
    
    return YES;
}


@end
