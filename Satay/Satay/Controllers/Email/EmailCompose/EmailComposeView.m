//
//  EmailComposeView.m
//  Satay
//
//  Created by Nghia (William) T. VO on 4/21/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import "EmailComposeView.h"
#import "AttachmentCell.h"
#import "TPKeyboardAvoidingScrollView.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "EmailInbox.h"
#import "FindEmailContact.h"

@interface EmailComposeView ()
{
    UIBarButtonItem *btnSend;
    BOOL isEncrypted;
    NSMutableArray *arrayAttachment;
    MailAccount *mailAccount;
    NSString *strEmailContent;
    BOOL block;
    NSString *draftEmailUID;
}
@end

@implementation EmailComposeView
@synthesize arrayReceipient, textViewBody;

#define kEMAIL_SEPARATE @", "
#define kEMAIL_CONTENT_SEPARATE @"##html##"
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [EmailFacade share].emailComposeDelegate = self;
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = TITLE_COMPOSE;
    
    self.navigationItem.leftBarButtonItem=[UIBarButtonItem createLeftButtonTitle:_CANCEL
                                                                          Target:self
                                                                          Action:@selector(cancelCompose)];
    btnSend = [UIBarButtonItem createRightButtonTitle:_SEND
                                               Target:self
                                               Action:@selector(sendEmailAction)];
    self.navigationItem.rightBarButtonItem= btnSend;
    
    [_btnAttachment setTitle:_ATTACHMENT forState:UIControlStateNormal];
    [_btnSaveEmail setTitle:_SAVE_EMAIL forState:UIControlStateNormal];
    
    _lblTo.text = LABEL_TO;
    _lblCC.text = LABEL_CC;
    _lblBCC.text = LABEL_BBC;
    _lblSubject.text = LABEL_SUBJECT;
    _lblEncryptMess.text = LABEL_ENCRYPTED_MESSAGE;
    _lblEncryptMess.textColor = COLOR_128128128;
    
    _attachmentView.delegate=self;
    _attachmentView.dataSource=self;
    UINib *nib = [UINib nibWithNibName:@"AttachmentCell" bundle: nil];
    [_attachmentView registerNib:nib forCellWithReuseIdentifier:@"AttachmentCell"];
    
    _webEmailContent.delegate = self;
    _webEmailContent.scalesPageToFit = YES;
    
    _textFieldTo.delegate = self;
    _textFieldCC.delegate = self;
    _textFieldBCC.delegate = self;
    _textFieldSubject.delegate = self;
    textViewBody.delegate = self;
    
    mailAccount = [[EmailFacade share] getMailAccount:[[EmailFacade share] getEmailAddress]];
    
    if (mailAccount.signature.length > 0)
        textViewBody.text = [NSString stringWithFormat:@"\n\n%@",mailAccount.signature];
    else
        textViewBody.text = @"";
    
    _btnAddTo.hidden = YES;
    _btnAddCC.hidden = YES;
    _btnAddBCC.hidden = YES;
    
    _btnEncrypt.layer.cornerRadius = _btnEncrypt.frame.size.height/2;
    _btnEncrypt.layer.borderWidth  = 1.0;
    _btnEncrypt.layer.borderColor  = [UIColor lightGrayColor].CGColor;
    
    isEncrypted = YES;
    
    if (mailAccount.useEncrypted)
    {
        isEncrypted = YES;
        [_btnEncrypt setImage:[UIImage imageNamed:IMG_CHECKMARK] forState:UIControlStateNormal];
    }
    else
    {
        isEncrypted = NO;
        [_btnEncrypt setImage:nil forState:UIControlStateNormal];
    }
    
    if (_arrayAttachment == nil)
    {
        _arrayAttachment = [NSMutableArray new];
    }
    [NotificationFacade share].emailComposeDelegate = self;
    
    switch ((ComposeEmailAction)_composeAction)
    {
        case kCOMPOSE_EMAIL_ACTION_COMPOSE:
        {
            [self buildComposeView];
        }
            break;
        case kCOMPOSE_EMAIL_ACTION_REOPEN_COMPOSE:
        {
            [self buildReopenComposeView];
        }
            break;
        case kCOMPOSE_EMAIL_ACTION_REPLY:
        {
            [self buildReplyView];
        }
            break;
        case kCOMPOSE_EMAIL_ACTION_REPLY_ALL:
        {
            [self buildReplyAllView];
        }
            break;
        case kCOMPOSE_EMAIL_ACTION_FOWARD:
        {
            [self buildFowardView];
        }
        default:
            break;
    }
    if (_textFieldTo.text.length > 0)
        btnSend.enabled = YES;
    else
        btnSend.enabled = NO;
    [self fixLayout];
}

- (void) viewWillAppear:(BOOL)animated
{
    [_scrollView addSubview:_headerButtonsView];
    [_scrollView addSubview:_headerView];
    [_scrollView addSubview:_bodyView];
    [_scrollView contentSizeToFit];
}

- (void) viewDidDisappear:(BOOL)animated
{
    [_headerButtonsView removeFromSuperview];
    [_headerView removeFromSuperview];
    [_bodyView removeFromSuperview];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionView datasource
- (NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [_arrayAttachment count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = @"AttachmentCell";
    
    static BOOL nibMyCellloaded = NO;
    
    if(!nibMyCellloaded)
    {
        UINib *nib = [UINib nibWithNibName:@"AttachmentCell" bundle: nil];
        [collectionView registerNib:nib forCellWithReuseIdentifier:identifier];
        nibMyCellloaded = YES;
    }
    AttachmentCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AttachmentCell" forIndexPath:indexPath];
    
    NSData *attachmentData = [[EmailFacade share] getAttachmentDataWithFileName:[_arrayAttachment objectAtIndex:indexPath.row]];
    if (attachmentData.length > 0)
    {
        UIImage *imageAttachment = [UIImage imageWithData:attachmentData];
        if (imageAttachment != nil)//image
        {
            if (attachmentData.length > 5120000) //image size ? 5 MB -> reduce
                attachmentData = [ChatAdapter scaleImage:imageAttachment rate:3];
            cell.imageAttach.image = [UIImage imageWithData:attachmentData];
            cell.imageAttach.image = [cell.imageAttach.image imageWithRenderingMode:UIImageRenderingModeAutomatic];
        }
        else
        {   //other type (video, doc, xls, pdf, ...)
            cell.imageAttach.image = [UIImage imageNamed:IMG_ATTACH_FILE_ICON];
            cell.imageAttach.image = [cell.imageAttach.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            [cell.imageAttach setTintColor:COLOR_48147213];
            [cell.imageAttach setContentMode:UIViewContentModeScaleToFill];
        }
    }
        
    [cell.btnDeleteAttachment addTarget:self
                                 action:@selector(removeAttachment:)
                       forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

#pragma mark - UIWebView delegate
- (void) webViewDidFinishLoad:(UIWebView *)aWebView
{
    [aWebView changeWidth:aWebView.frame.size.width Height:aWebView.scrollView.contentSize.height];
    _webEmailContent.scrollView.scrollEnabled = NO;
    aWebView.scrollView.delegate = self;
    
    [_bodyView changeWidth:aWebView.frame.size.width
                    Height:aWebView.scrollView.contentSize.height + aWebView.frame.origin.y + 5];
    [_scrollView setContentSize:CGSizeMake(_scrollView.frame.size.width, _bodyView.frame.origin.y + _bodyView.frame.size.height + 8)];
}

- (BOOL)webView:(UIWebView *)inWeb shouldStartLoadWithRequest:(NSURLRequest *)inRequest navigationType:(UIWebViewNavigationType)inType
{
    if (inType == UIWebViewNavigationTypeLinkClicked)
    {
        [[UIApplication sharedApplication] openURL:[inRequest URL]];
        return NO;
    }
    
    return YES;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    _webEmailContent.scrollView.scrollEnabled = YES;
}

#pragma mark - UITextView delegate
- (void)textViewDidChange:(UITextView *)textView
{
    if (textViewBody.contentSize.height > 100)
    {
        if (block)
            return;
        
        block = YES;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            block = NO;
            [textViewBody changeWidth:textViewBody.frame.size.width Height:textViewBody.contentSize.height];
            [self fixLayout];
        });
    }
}
#pragma mark - UITextField delegate
- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == _textFieldTo)
    {
        NSUInteger newLength = [textField.text length] + [string length] - range.length;
        if (newLength > 0)
            btnSend.enabled = YES;
        else
            btnSend.enabled = NO;
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    _btnAddTo.hidden = YES;
    _btnAddCC.hidden = YES;
    _btnAddBCC.hidden = YES;
    NSString *trimTextField = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if ([textField isEqual:_textFieldTo])
    {
        _btnAddTo.hidden = NO;
        if(!(trimTextField.length > 0))
            return;
        if (_textFieldTo.text.length > 0 && ![[trimTextField substringFromIndex:[trimTextField length] - 1] isEqualToString:@","])
            _textFieldTo.text = [NSString stringWithFormat:@"%@, ",_textFieldTo.text];
        
    }
    else if ([textField isEqual:_textFieldCC])
    {
        _btnAddCC.hidden = NO;
        if(!(trimTextField.length > 0))
            return;
        if (_textFieldCC.text.length > 0 && ![[trimTextField substringFromIndex:[trimTextField length] - 1] isEqualToString:@","])
            _textFieldCC.text = [NSString stringWithFormat:@"%@, ",_textFieldCC.text];
        
    }
    else if ([textField isEqual:_textFieldBCC])
    {
        _btnAddBCC.hidden = NO;
        if(!(trimTextField.length > 0))
            return;
        if (_textFieldBCC.text.length > 0 && ![[trimTextField substringFromIndex:[trimTextField length] - 1] isEqualToString:@","])
            _textFieldBCC.text = [NSString stringWithFormat:@"%@, ",_textFieldBCC.text];
        
    }
}

- (void) textFieldDidEndEditing:(UITextField *)textField
{
    _btnAddTo.hidden = YES;
    _btnAddCC.hidden = YES;
    _btnAddBCC.hidden = YES;
}
#pragma mark - Button Action
- (void) removeAttachment:(id)sender
{
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:_attachmentView];
    NSIndexPath *indexPath = [_attachmentView indexPathForItemAtPoint:buttonPosition];
    [_arrayAttachment removeObjectAtIndex:indexPath.row];
    if (_arrayAttachment.count == 0)
    {
        [self fixLayout];
    }
    [_attachmentView reloadData];
}

- (IBAction)addAttachment:(id)sender
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    [[UINavigationBar appearance]setTintColor:[UIColor whiteColor]];
    [self presentViewController:picker animated:YES completion:NULL];
}

- (IBAction)saveEmail:(id)sender
{
    if (strEmailContent.length > 0)
    {
        [[EmailFacade share] saveEmailToFolder:kINDEX_FOLDER_DRAFTS
                                           uid:draftEmailUID
                                            to:_textFieldTo.text
                                            cc:_textFieldCC.text
                                           bcc:_textFieldBCC.text
                                       subject:_textFieldSubject.text
                                          body:[NSString stringWithFormat:@"%@%@%@",textViewBody.text,kEMAIL_CONTENT_SEPARATE, strEmailContent]
                                    attachment:_arrayAttachment
                                     encrypted:isEncrypted];
    }
    else
    [[EmailFacade share] saveEmailToFolder:kINDEX_FOLDER_DRAFTS
                                       uid:draftEmailUID
                                        to:_textFieldTo.text
                                        cc:_textFieldCC.text
                                       bcc:_textFieldBCC.text
                                   subject:_textFieldSubject.text
                                      body:textViewBody.text
                                attachment:_arrayAttachment
                                 encrypted:isEncrypted];
    
    [self saveEmailSuccess];
}

- (IBAction)encryptEmail:(id)sender
{
    if (isEncrypted)
    {
        isEncrypted = NO;
        [_btnEncrypt setImage:nil forState:UIControlStateNormal];
    }
    else
    {
        isEncrypted = YES;
        [_btnEncrypt setImage:[UIImage imageNamed:IMG_CHECKMARK] forState:UIControlStateNormal];
    }
}

- (IBAction)addReceipient:(id)sender
{
    UIButton *button = (UIButton *)sender;

    if ([button isEqual:_btnAddTo])
        _activeTextField = (ActiveTextField *)kActiveTextFiledTO;
    else if ([button isEqual:_btnAddCC])
        _activeTextField = (ActiveTextField *)kActiveTextFiledCC;
    else if ([button isEqual:_btnAddBCC])
        _activeTextField = (ActiveTextField *)kActiveTextFiledBCC;

    [FindEmailContact share].isAddParticipants = NO;
    [[CWindow share] showPopup:[FindEmailContact share]];
}

- (void) cancelCompose
{
    [self.view endEditing:YES];
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:_CANCEL
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:_DELETE_DRAFT, _SAVE_DRAFT, nil];
    [actionSheet showInView:self.view];
}

- (void)sendEmailAction
{
    [self.view endEditing:YES];
    if ([_textFieldSubject.text isEqualToString:@""])
    {
        CAlertView *alertView = [CAlertView new];
        NSMutableArray *buttonsName  = [NSMutableArray arrayWithObjects:NSLocalizedString(ALERT_BUTTON_SEND_EMAIL, nil), NSLocalizedString(ALERT_BUTTON_CANCEL, nil), nil];
        [alertView showInfo_2btn:NSLocalizedString(NO_SUBJECT, nil) ButtonsName:buttonsName];
        [alertView setOnButtonTouchUpInside:^(CAlertView *alertView, int buttonIndex)
        {
            if (buttonIndex == 0) //send
            {
                [self sendEmail];
            }
        }];
        [alertView show];
    }
    else
    {
        [self sendEmail];
    }
}

- (void)sendEmail
{
    self.navigationItem.rightBarButtonItem.enabled = NO;
    NSString *uid, *subject;
    if (_textFieldSubject.text.length > 0)
        subject = _textFieldSubject.text;
    else
        subject = kEmailNoSubject;
    
    if (strEmailContent.length > 0)
    {
        uid = [[EmailFacade share] saveEmailToFolder:kINDEX_FOLDER_OUTBOX
                                                 uid:draftEmailUID
                                                  to:_textFieldTo.text
                                                  cc:_textFieldCC.text
                                                 bcc:_textFieldBCC.text
                                             subject:subject
                                                body:[NSString stringWithFormat:@"%@\n<br/><br/><br/>%@", textViewBody.text, strEmailContent]
                                          attachment:_arrayAttachment
                                           encrypted:isEncrypted];
    }
    else
    {
        uid = [[EmailFacade share] saveEmailToFolder:kINDEX_FOLDER_OUTBOX
                                                 uid:draftEmailUID
                                                  to:_textFieldTo.text
                                                  cc:_textFieldCC.text
                                                 bcc:_textFieldBCC.text
                                             subject:subject
                                                body:textViewBody.text
                                          attachment:_arrayAttachment
                                           encrypted:isEncrypted];
    }
    
    [[EmailFacade share] sendEmail:uid attachments:_arrayAttachment encrypted:isEncrypted isResend:NO];
}

-(void) resendEmails{
    [[EmailFacade share] reSendEmails];
}

-(void) sendEmailSuccess{
    self.navigationItem.rightBarButtonItem.enabled = YES;
    [[self navigationController] popViewControllerAnimated:YES];
}
-(void) sendEmailFailed:(NSString*)errorMessage
{
    self.navigationItem.rightBarButtonItem.enabled = YES;
    [[CAlertView new] showError:errorMessage];
}

-(void) saveEmailSuccess{

    NSArray *viewControllers = [[self navigationController] viewControllers];
    
    for (int i = 0; i < [viewControllers count]; i++)
    {
        id obj = [viewControllers objectAtIndex:i];
        
        if ([obj isKindOfClass:[EmailInbox class]])
        {
            [[self navigationController] popToViewController:obj animated:YES];
            return;
        }
    }

}

#pragma mark - UIAction sheet
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex)
    {
        case 0:
        {
            // Delete
            if (_emailHeader.uid.length > 0)
                [[EmailFacade share] deleteDraftEmail:_emailHeader.uid];
            [self.navigationController popViewControllerAnimated:YES];
            NSLog(@"Click button 0");
        }
            break;
        case 1:
        {
            // Save
            NSLog(@"Click button 1");
            [self performSelector:@selector(saveEmail:) withObject:nil];
        }
            break;
        case 2:
            // Cancel
            NSLog(@"Click button 2");
            break;
        default:
            break;
    }
}

#pragma mark - UIImagePickerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSURL *refURL = [info valueForKey:UIImagePickerControllerReferenceURL];
    ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *imageAsset)
    {
        ALAssetRepresentation *imageRep = [imageAsset defaultRepresentation];
        NSString* imageName;
        if ([imageRep filename].length > 0)
            imageName = [NSString stringWithFormat:@"%@_%@", [[EmailFacade share] randomEmailUid],[imageRep filename]];
        else
            imageName = [NSString stringWithFormat:@"%@",[[EmailFacade share] randomEmailUid]];
                
        //extracting image from the picker and saving it
        NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
        
        if ([mediaType isEqualToString:@"public.image"])
        {
            UIImage *editedImage = [info objectForKey:UIImagePickerControllerOriginalImage];
            //editedImage = [self fixrotation:editedImage];
            NSData *webData = UIImageJPEGRepresentation(editedImage, 1.0f);
            
            [[EmailFacade share] setEmailAttachment:imageName data:webData];
        }
        
        if ([mediaType isEqualToString:@"public.movie"])
        {
            NSString *moviePath = (NSString *)[[info objectForKey:UIImagePickerControllerMediaURL] path];
            NSData *webData = [NSData dataWithContentsOfFile:moviePath];
            [[EmailFacade share] setEmailAttachment:imageName data:webData];
        }
    
        if (_arrayAttachment == nil)
        {
            _arrayAttachment = [NSMutableArray new];
        }
        [_arrayAttachment addObject:imageName];
        
        [self addAttachment];
    };
    
    // get the asset library and fetch the asset based on the ref url (pass in block above)
    ALAssetsLibrary *assetslibrary = [[ALAssetsLibrary alloc] init];
    
    [assetslibrary assetForURL:refURL resultBlock:resultblock failureBlock:nil];
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - Build View
- (void) buildComposeView
{
    _textFieldTo.text = _toEmailAddress;
    [_textFieldTo becomeFirstResponder];
    [_webEmailContent loadHTMLString:@"" baseURL:nil];
}
- (void) buildReopenComposeView
{
    _textFieldTo.text = _emailHeader.emailTo;
    _textFieldCC.text = _emailHeader.emailCC;
    _textFieldBCC.text = _emailHeader.emailBCC;
    _textFieldSubject.text = _emailHeader.subject;
    if ([strEmailContent rangeOfString:kEMAIL_CONTENT_SEPARATE].location != NSNotFound)
    {
        NSArray *array = [strEmailContent componentsSeparatedByString:kEMAIL_CONTENT_SEPARATE];
        textViewBody.text = [array objectAtIndex:0];
        strEmailContent = [self htmlEmailContent:[array objectAtIndex:1]];
        [_webEmailContent loadHTMLString:strEmailContent baseURL:nil];
    }
    else
    {
        textViewBody.text = strEmailContent;
        [_webEmailContent loadHTMLString:@"" baseURL:nil];
        strEmailContent = nil;
    }
    
    [textViewBody becomeFirstResponder];
    if ([_emailHeader.isEncrypted boolValue])
    {
        isEncrypted = YES;
        [_btnEncrypt setImage:[UIImage imageNamed:IMG_CHECKMARK] forState:UIControlStateNormal];
    }
    else
    {
        isEncrypted = NO;
        [_btnEncrypt setImage:nil forState:UIControlStateNormal];
    }
    
    if (_arrayAttachment.count > 0)
    {
        [_attachmentView reloadData];
    }
}
- (void) buildReopenComposeViewData:(NSDictionary *)data
{
    _emailHeader = [data objectForKey:kEMAIL_HEADER_KEY];
    _emailContents = [data objectForKey:kEMAIL_CONTENT_KEY];
    _arrayAttachment = [[data objectForKey:kEMAIL_ATTACHMENT_KEY] mutableCopy];
    strEmailContent = _emailContents.htmlContent;
    draftEmailUID = _emailHeader.uid;
}

- (void) buildReplyView
{
    [textViewBody becomeFirstResponder];
    _textFieldTo.text = _emailHeader.emailFrom;
    _textFieldSubject.text = [NSString stringWithFormat:@"Re: %@",_emailHeader.subject];
    strEmailContent = [self htmlEmailContent:_emailContents.htmlContent];
    [_webEmailContent loadHTMLString:strEmailContent baseURL:nil];
}

- (void) buildReplyAllView
{
    [textViewBody becomeFirstResponder];
    NSArray *arrayTo = [self arrayEmailToRemovedObjectAccountEmail:
                        [NSString stringWithFormat:@"%@, %@",_emailHeader.emailFrom , _emailHeader.emailTo]];
    _textFieldTo.text = [arrayTo componentsJoinedByString:kEMAIL_SEPARATE];
    NSArray *arrayCC = [self arrayEmailToRemovedObjectAccountEmail:_emailHeader.emailCC];
    _textFieldCC.text = [arrayCC componentsJoinedByString:kEMAIL_SEPARATE];
    _textFieldSubject.text = [NSString stringWithFormat:@"Re: %@",_emailHeader.subject];
    strEmailContent = [self htmlEmailContent:_emailContents.htmlContent];
    [_webEmailContent loadHTMLString:strEmailContent baseURL:nil];
}

- (void) buildFowardView
{
    [_textFieldTo becomeFirstResponder];
    _textFieldSubject.text = [NSString stringWithFormat:@"FWD: %@",_emailHeader.subject];
    strEmailContent = [self htmlEmailContent:_emailContents.htmlContent];
    [_webEmailContent loadHTMLString:strEmailContent baseURL:nil];
    if (_arrayAttachment.count > 0)
    {
        [_attachmentView reloadData];
    }
}

#pragma mark - Other Action
- (NSArray *)arrayEmailToRemovedObjectAccountEmail:(NSString *)emailString
{
    // Get email to list, that should not include the account user.
    NSString *trimmedStrEmail = [emailString stringByTrimmingCharactersInSet:
                                 [NSCharacterSet whitespaceCharacterSet]];
    NSArray *emailArray = [trimmedStrEmail componentsSeparatedByString:kEMAIL_SEPARATE];
    NSMutableArray *mutableArray = [NSMutableArray arrayWithArray:emailArray];
    
    for (int i = 0; i < [mutableArray count]; i++)
    {
        if ([[mutableArray objectAtIndex:i] isEqualToString:[[EmailFacade share] getEmailAddress]])
        {
            [mutableArray removeObjectAtIndex:i];
        }
    }
    
    return [NSArray arrayWithArray:mutableArray];
}

- (NSString *) htmlEmailContent:(NSString *)content
{
    if (content.length > 0)
    {
        switch ((ComposeEmailAction)_composeAction)
        {
            case kCOMPOSE_EMAIL_ACTION_REPLY:
            case kCOMPOSE_EMAIL_ACTION_REPLY_ALL:
            {
                content = [NSString stringWithFormat:@"On %@, <b>%@</b> &lt;%@&gt; wrote:<br/><br/>%@", [ChatAdapter convertDateToString:_emailHeader.sendDate format:FORMAT_DATE_MMMDDYYY], _emailHeader.extend1, _emailHeader.emailFrom, content];
            }
                break;
            case kCOMPOSE_EMAIL_ACTION_FOWARD:
            {
                NSString *strForward = [NSString stringWithFormat:@"---------- Forwarded message ----------<br/>From: <b>%@</b> &lt;%@&gt;<br/>Date: %@<br/>To: %@<br/>", _emailHeader.extend1, _emailHeader.emailFrom, [ChatAdapter convertDateToString:_emailHeader.sendDate format:FORMAT_DATE_MMMDDYYY], _emailHeader.emailTo];
                
                if (_emailHeader.emailCC.length > 0)
                {
                    strForward = [NSString stringWithFormat:@"%@Cc: %@<br/>", strForward, _emailHeader.emailCC];
                }
                
                content = [NSString stringWithFormat:@"%@<br/>%@", strForward, content];
            }
                break;
            default:
                break;
        }
        return [NSString stringWithFormat:@"<span style=\"font-family: %@; font-size: %i\">%@</span>", FONT_FAMILY_GOTHAMROUNDED_BOLD, FONT_TEXT_SIZE_15, content];
    }
    else
        return @"";
}

-(void) updateTextFieldWithData:(NSMutableArray*)arrayContactSelect
{
    for (int i = 0; i < arrayContactSelect.count; i++)
    {
        Contact *contact = arrayContactSelect[i];
        switch ((ActiveTextField)_activeTextField)
        {
            case kActiveTextFiledTO:
            {
                NSString *trimTextField = [_textFieldTo.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                if (trimTextField.length == 0)
                    _textFieldTo.text = [NSString stringWithFormat:@"%@",contact.email];
                else if ([[trimTextField substringFromIndex:[trimTextField length] - 1] isEqualToString:@","])
                    _textFieldTo.text = [NSString stringWithFormat:@"%@%@",_textFieldTo.text, contact.email];
                else
                    _textFieldTo.text = [NSString stringWithFormat:@"%@, %@",_textFieldTo.text, contact.email];
                btnSend.enabled = YES;
            }
                break;
            case kActiveTextFiledCC:
            {
                NSString *trimTextField = [_textFieldCC.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                if (trimTextField.length == 0)
                    _textFieldCC.text = [NSString stringWithFormat:@"%@",contact.email];
                else if ([[trimTextField substringFromIndex:[trimTextField length] - 1] isEqualToString:@","])
                    _textFieldCC.text = [NSString stringWithFormat:@"%@%@",_textFieldCC.text, contact.email];
                else
                    _textFieldCC.text = [NSString stringWithFormat:@"%@, %@",_textFieldCC.text, contact.email];
            }
                break;
            case kActiveTextFiledBCC:
            {
                NSString *trimTextField = [_textFieldBCC.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                if (trimTextField.length == 0)
                    _textFieldBCC.text = [NSString stringWithFormat:@"%@",contact.email];
                else if ([[trimTextField substringFromIndex:[trimTextField length] - 1] isEqualToString:@","])
                    _textFieldBCC.text = [NSString stringWithFormat:@"%@%@",_textFieldBCC.text, contact.email];
                else
                    _textFieldBCC.text = [NSString stringWithFormat:@"%@, %@",_textFieldBCC.text, contact.email];
            }
            default:
                break;
        }
    }
}

- (void) addAttachment
{
    if (_arrayAttachment.count == 1)
    {
        [self fixLayout];
    }
    [_attachmentView reloadData];
}

- (void) fixLayout
{
    if (_arrayAttachment.count > 0)
    {
        // Attachment View
        _attachmentView.hidden = NO;
        [_attachmentView changeWidth:_attachmentView.frame.size.width Height:100];
        [_attachmentView changeXAxis:_attachmentView.frame.origin.x
                               YAxis:8];
        // Text view body
        [textViewBody changeXAxis:textViewBody.frame.origin.x
                             YAxis:_attachmentView.frame.origin.y + _attachmentView.frame.size.height + 8];
    }
    else
    {
        // Text view body
        _attachmentView.hidden = YES;
        [_attachmentView changeWidth:_attachmentView.frame.size.width Height:0];
        [textViewBody changeXAxis:textViewBody.frame.origin.x
                             YAxis:_attachmentView.frame.origin.y + 8];
    }
    // Button and Label encrypted
    [_btnEncrypt changeXAxis:_btnEncrypt.frame.origin.x
                       YAxis:textViewBody.frame.origin.y + textViewBody.frame.size.height + 6];
    [_lblEncryptMess changeXAxis:_lblEncryptMess.frame.origin.x
                       YAxis:textViewBody.frame.origin.y + textViewBody.frame.size.height + 8];
    // Webview
    [_webEmailContent changeXAxis:_webEmailContent.frame.origin.x
                            YAxis:_lblEncryptMess.frame.origin.y + _lblEncryptMess.frame.size.height + 8];
    // Body view
    [_bodyView changeWidth:_bodyView.frame.size.width
                      Height:_webEmailContent.frame.size.height + _webEmailContent.frame.origin.y + 8];
    // ScrollView
    [_scrollView contentSizeToFit];
}

+(EmailComposeView *)share{
    static dispatch_once_t once;
    static EmailComposeView * share;
    dispatch_once(&once, ^{
        share = [self new];
    });
    return share;
}

@end
