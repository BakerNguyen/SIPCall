//
//  EmailDetailView.m
//  Satay
//
//  Created by Arpana Sakpal on 3/18/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import "EmailDetailView.h"
#import "EmailComposeView.h"
#import "ViewEmailAttachment.h"
#import "EmailSortBy.h"
#import <QuartzCore/QuartzCore.h>

@interface EmailDetailView ()

@end

@implementation EmailDetailView
 {

    UIScrollView *attachFileView;
     
    UIActivityIndicatorView *spinner, *spinner1;
    
    UIView *ccView;

    UILabel *ccLabel;
    UITextView *ccTextView;
    BOOL isOperatedToView, isOperatedCCView;
     
     MailContent *mailContent;
     NSArray *mailAttachmentsList;
     NSMutableArray *arrAttachmentsName;
     
    NSDictionary *decryptedEmailContentDic;
     UIActionSheet *sheetReplyEmail, *sheetMore3Button, *sheetMore2Button;
}
@synthesize scrollView,webViewEmailContent;
@synthesize lblTimeStamp, lblEmailFrom, txtEmailTo, txtEmailTitleDetail;

@synthesize lblline1, lblline2;

@synthesize viewBtnNextPrev,btnNext,btnPrev;
@synthesize btnDelete,btnForward,btnMore,btnReply,viewBottom;

@synthesize mailHeader;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self)
    {
        // Custom initialization
    }
    
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem=[UIBarButtonItem createLeftButtonTitle:_BACK
                                                                          Target:self
                                                                          Action:@selector(backToMenuSideBar)];

    _imgProfileImage.layer.cornerRadius = _imgProfileImage.frame.size.width/2;
    _imgProfileImage.clipsToBounds = YES;
    alertView = [[CAlertView alloc] init];

    [btnNext addTarget:self
                action:@selector(nextEmail)
      forControlEvents:UIControlEventTouchUpInside];

    [btnPrev  addTarget:self
                 action:@selector(previousEmail)
       forControlEvents:UIControlEventTouchUpInside];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:viewBtnNextPrev];
    self.navigationItem.titleView = _viewTitle;
    mailContent = [[EmailFacade share] getMailContentFromMailHeaderUid:mailHeader.uid];
    if (mailContent.htmlContent == nil) //some how can't get email content -> call email server to get
    {
        [[EmailFacade share] getSingleEmailDetailForImapWithHeader:mailHeader];
    }
    [EmailFacade share].emailDetailDelegate = self;
    webViewEmailContent.scalesPageToFit = YES;
    webViewEmailContent.scrollView.scrollEnabled = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self reloadEmailDetail];
    [self setUpNextPreviousButton];
}

- (void) getEmailDetailSucceeded;
{
    mailContent = [[EmailFacade share] getMailContentFromMailHeaderUid:mailHeader.uid];
    [self reloadEmailDetail];
    [self setUpNextPreviousButton];
}
- (void) getEmailDetailFailed:(NSString *)message
{
    [[CAlertView new] showError:message];
}

-(void)displayEmailContent
{
    //Get email body
    
    if ([[EmailFacade share] isEncEmail:mailContent.htmlContent])      //If email is encrypted
    {
        decryptedEmailContentDic =  [[EmailFacade share] decrypteEmailContent:mailContent.htmlContent
                                                                  attachments:arrAttachmentsName];
        
        if (decryptedEmailContentDic)
        {
            mailContent.htmlContent = [decryptedEmailContentDic objectForKey:kEMAIL_DEC_BODY];
        }
    }
    NSString *htmlString = [self htmlEmailContent:mailContent.htmlContent];
    //display on web view
    [webViewEmailContent loadHTMLString:htmlString baseURL:nil];
    if (mailHeader.emailStatus.intValue == 0) // not seen
    {
        //Update email flag
        [[EmailFacade share] updateSeenFlagForEmail:mailHeader.uid];
    }
}

-(void)setUpNextPreviousButton
{
    NSInteger index = [_arrayEmails indexOfObject:mailHeader];
    
    if (index == _arrayEmails.count - 1) {
        btnNext.enabled = NO;
        btnPrev.enabled = YES;
    }
    else if (index == 0){
        btnNext.enabled = YES;
        btnPrev.enabled = NO;
    }
    else{
        btnNext.enabled = YES;
        btnPrev.enabled = YES;
    }
}

- (NSString *) htmlEmailContent:(NSString *)content
{
    NSString *htmlContent = @"";
    if (content.length > 0)
    {
        htmlContent = [NSString stringWithFormat:@"<span style=\"font-family: %@; font-size: %i\">%@</span>", FONT_FAMILY_GOTHAMROUNDED_BOLD, FONT_TEXT_SIZE_50, content];
    }
    return htmlContent;
}
- (void) showEmailAttachments
{
    //Get attachments list in db
    mailAttachmentsList = [[EmailFacade share] getMailAttachmentsFromUid:mailHeader.uid];
    // Check if is folder sent/outbox then don't download attachment
    if (mailHeader.attachNumber.intValue > mailAttachmentsList.count &&
        mailHeader.folderIndex.intValue != kINDEX_FOLDER_SENT &&
        mailHeader.folderIndex.intValue != kINDEX_FOLDER_OUTBOX)
    {
        [[EmailFacade share] reDownLoadAttachmentOfEmail:mailHeader];
    }

    if (mailAttachmentsList.count > 0)
    {
        arrAttachmentsName = [[NSMutableArray alloc] init];
        for (MailAttachment *mailAttachment in mailAttachmentsList)
        {
            [arrAttachmentsName addObject:mailAttachment.attachmentName];
        }
        //Display attachment
        [self displayAttachmentIconsList:arrAttachmentsName];
    }
}

-(void)loadEmailDetail{
    
    // Title
    [self initTitleNavigation];
    
    // From
    lblEmailFrom.text  = mailHeader.extend1;
    
    // Profile Image
    _imgProfileImage.image = [[EmailFacade share] getAvatarFromEmail:mailHeader.emailFrom];

    //To
    [self initToView];

    //CC
    [self initCCView];
    
    //Email Title
    [self initEmailTitleAndTimeStamp];
    
    if (mailHeader.attachNumber.intValue > 0)
    {
        //Attachment
        [self initAttachmentsView];
        [webViewEmailContent changeXAxis:webViewEmailContent.x
                                   YAxis:attachFileView.bottomEdge + 2*padding ];
    }
    else
    {
        [webViewEmailContent changeXAxis:webViewEmailContent.x
                                   YAxis:lblline2.bottomEdge + 2*padding ];
    }
}

-(void)initTitleNavigation
{
    [_lblTitle setText:mailHeader.subject];
    _lblTitle.font = [UIFont systemFontOfSize:18.0];
    _lblTitle.minimumFontSize = 14.0;
    _lblTitle.adjustsFontSizeToFitWidth = YES;
}

-(void)initToView
{
    txtEmailTo.text = mailHeader.emailTo;
    txtEmailTo.editable = NO;
    
    CGSize newSize = [txtEmailTo sizeThatFits:CGSizeMake(txtEmailTo.width, MAXFLOAT)];
    [txtEmailTo changeWidth:txtEmailTo.width Height:newSize.height];
    txtEmailTo.scrollEnabled = NO;
    [txtEmailTo setContentSize:newSize];
    if (txtEmailTo.frame.size.height > 45)
    {
        [txtEmailTo changeWidth:txtEmailTo.width Height:45];
        [self.btnOperateTO changeXAxis:txtEmailTo.frame.origin.x - 20 YAxis:txtEmailTo.frame.origin.y + 30];
        [self.btnOperateTO setBackgroundImage:[UIImage imageNamed:IMG_PLUG_SIGN] forState:UIControlStateNormal];
        self.btnOperateTO.hidden = NO;
    }
    else{
        self.btnOperateTO.hidden = YES;
    }
    txtEmailTo.scrollEnabled = YES;
}

-(void)initCCView
{
    
    ccView = [[UIView alloc] init];
    if (![mailHeader.emailCC isEqualToString:@""]) {
        ccLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 2, 30, 30)];
        ccLabel.text = @"Cc: ";
        ccLabel.font = [UIFont systemFontOfSize:15];
        [ccView addSubview:ccLabel];
        
        ccTextView = [[UITextView alloc] initWithFrame:CGRectMake(20, 0, txtEmailTo.width, 10)];
        ccTextView.text = mailHeader.emailCC;
        ccTextView.font = [UIFont systemFontOfSize:15];
        ccTextView.editable = NO;
        CGSize newSize = [ccTextView sizeThatFits:CGSizeMake(ccTextView.width, MAXFLOAT)];
        [ccTextView changeWidth:ccTextView.width Height:newSize.height];
        ccTextView.backgroundColor = [UIColor clearColor];
        
        if (ccTextView.frame.size.height > 45)
        {
            [ccTextView changeWidth:ccTextView.frame.size.width  Height:45];
            [self.btnOperateCC changeXAxis:ccTextView.x - 20 YAxis:ccTextView.frame.origin.y + 30];
            [self.btnOperateCC setBackgroundImage:[UIImage imageNamed:IMG_PLUG_SIGN]
                                         forState:UIControlStateNormal];
            self.btnOperateCC.hidden = NO;
        }
        else{
            self.btnOperateCC.hidden = YES;
        }
        
        [ccView addSubview:ccTextView];
        [ccView addSubview:self.btnOperateCC];
        ccView.frame = CGRectMake(20, txtEmailTo.frame.origin.y + txtEmailTo.frame.size.height , txtEmailTo.width, ccTextView.frame.size.height + 2);
        
        [scrollView addSubview:ccView];
        [lblline1 changeXAxis:lblline1.frame.origin.x
                        YAxis:ccView.frame.origin.y + ccView.height +5];
    }else{
        [ccView removeFromSuperview];
        [lblline1 changeXAxis:lblline1.frame.origin.x
                        YAxis:txtEmailTo.frame.origin.y + txtEmailTo.frame.size.height +5];
    }
}

-(void)initEmailTitleAndTimeStamp
{
    [txtEmailTitleDetail changeXAxis:txtEmailTitleDetail.frame.origin.x YAxis:lblline1.frame.origin.y + 5];
    txtEmailTitleDetail.text = mailHeader.subject;
    txtEmailTitleDetail.editable = NO;
    txtEmailTitleDetail.scrollEnabled = NO;
    
    CGSize newSize = [txtEmailTitleDetail sizeThatFits:CGSizeMake(txtEmailTitleDetail.width, MAXFLOAT)];
    [txtEmailTitleDetail changeWidth:txtEmailTitleDetail.width Height:newSize.height];
    
    lblTimeStamp.text = [ChatAdapter convertDateToString:mailHeader.sendDate format:FORMAT_DATE_MMMDDYYY];
    [lblTimeStamp changeXAxis:lblTimeStamp.frame.origin.x
                        YAxis:txtEmailTitleDetail.frame.origin.y + txtEmailTitleDetail.frame.size.height];
    
    [lblline2 changeXAxis:lblline2.frame.origin.x
                    YAxis:lblTimeStamp.frame.origin.y + lblTimeStamp.frame.size.height + 5];
}

-(void)initAttachmentsView
{
    attachFileView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, lblline2.frame.origin.y + 5, lblline2.width, 90)];
    attachFileView.scrollEnabled = YES;
    [self showEmailAttachments];
}

- (void)resetFrame
{
    /* Daryl Comment this.
    CGRect frame = txtEmailTo.frame;
    
    frame.origin.x = 39;
    frame.origin.y = 41;
    frame.size.width = 198;
    frame.size.height = 38;
    txtEmailTo.frame = frame;
    
    ccView.hidden = YES;
    
    frame = lblline1.frame;
    frame.origin.x = 20;
    frame.origin.y = 84;
    frame.size.width = 300;
    frame.size.height = 1;
    lblline1.frame = frame;
    
    frame = txtEmailTitleDetail.frame;
    frame.origin.x = 14;
    frame.origin.y = 154;
    frame.size.width = 290;
    frame.size.height = 29;
    txtEmailTitleDetail.frame = frame;
    
    frame = lblTimeStamp.frame;
    frame.origin.x = 20;
    frame.origin.y = 180;
    frame.size.width = 223;
    frame.size.height = 21;
    lblTimeStamp.frame = frame;
    
    frame = lblline2.frame;
    frame.origin.x = 0;
    frame.origin.y = 209;
    frame.size.width = 320;
    frame.size.height = 1;
    lblline2.frame = frame;
    
    frame = webViewEmailContent.frame;
    frame.origin.x = 12;
    frame.origin.y = 230;
    frame.size.width = 296;
    frame.size.height = 265;
    webViewEmailContent.frame = frame;*/
    [scrollView setContentSize:CGSizeMake(self.scrollView.frame.size.width, 1)];
    [attachFileView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [attachFileView removeFromSuperview];
}
- (void)displayAttachmentIconsList:(NSMutableArray *)arrayAttachment
{
    [attachFileView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    NSInteger x = 20;
    
    for (NSInteger i = 1; i <= arrayAttachment.count; i++)
    {
        //each attach is a button
        UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [button addTarget:self action:@selector(viewAttachmentFile:)
                forControlEvents:UIControlEventTouchUpInside];
        button.frame = CGRectMake(x, 0, 70, 70);
        UIImage *thumbImage = [UIImage imageNamed:IMG_ATTACH_FILE_ICON];
        [button setImage:thumbImage forState:UIControlStateNormal];
        [button setTag:i];
        [attachFileView addSubview:button];
        
        //Add file name
        UILabel *fileName = [[UILabel alloc] initWithFrame:CGRectMake(x, 70, 70, 15)];
        [fileName setText:[NSString stringWithFormat:@"%@", [arrayAttachment objectAtIndex:i - 1]]];
        //fileName.text = str_replace(@"_enc", @"", fileName.text);
        fileName.font = [UIFont systemFontOfSize:13];
        fileName.textAlignment = NSTextAlignmentCenter;
        [attachFileView addSubview:fileName];
        
        x += 100;
        
        /*
        if (i == arrayAttachment.count - 1) {
            btnNext.enabled = YES;
            btnPrev.enabled = YES;
            btnMore.enabled = YES;
        }*/
    }
    
    //add UIScrollView
    [attachFileView setContentSize:CGSizeMake(x, attachFileView.frame.size.height)];
    [scrollView addSubview:attachFileView];
}

- (void)viewAttachmentFile:(UIButton *)sender
{
    if (sender.tag > arrAttachmentsName.count || sender.tag == 0) {
        return;
    }
    ViewEmailAttachment *attachmentVC = [[ViewEmailAttachment alloc] initWithNibName:@"ViewEmailAttachment" bundle:nil];
    attachmentVC.fileName = arrAttachmentsName[sender.tag - 1];

    [self.navigationController pushViewController:attachmentVC animated:YES];
}

// webView sources
- (void)webViewDidFinishLoad:(UIWebView *)aWebView
{
    [aWebView changeWidth:aWebView.frame.size.width Height:aWebView.scrollView.contentSize.height];
    webViewEmailContent.scrollView.scrollEnabled = NO;
    aWebView.scrollView.delegate = self;
    
    [scrollView setContentSize:CGSizeMake(self.scrollView.width, aWebView.y + aWebView.scrollView.contentSize.height + 5)];
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
    webViewEmailContent.scrollView.scrollEnabled = YES;
}

#pragma mark - Action button

- (void)nextEmail
{
    [spinner stopAnimating];
    NSInteger index = [_arrayEmails indexOfObject:mailHeader];
    if (index != NSNotFound && index < _arrayEmails.count - 1){
        index++;
        mailHeader = [_arrayEmails objectAtIndex:index];
        mailContent = [[EmailFacade share] getMailContentFromMailHeaderUid:mailHeader.uid];
        if (mailContent.htmlContent == nil) //some how can't get email content
        {
            [[EmailFacade share] getSingleEmailDetailForImapWithHeader:mailHeader];
        }
        [self reloadEmailDetail];
    }
    [self setUpNextPreviousButton];
}

- (void)previousEmail
{
    [spinner stopAnimating];
    NSInteger index = [_arrayEmails indexOfObject:mailHeader];
    if (index != NSNotFound && index > 0){
        index--;
        mailHeader = [_arrayEmails objectAtIndex:index];
        mailContent = [[EmailFacade share] getMailContentFromMailHeaderUid:mailHeader.uid];
        if (mailContent.htmlContent == nil) //some how can't get email content
        {
            [[EmailFacade share] getSingleEmailDetailForImapWithHeader:mailHeader];
        }
        [self reloadEmailDetail];
    }
    [self setUpNextPreviousButton];
}

-(void)reloadEmailDetail
{
    [ccView removeFromSuperview];
    [ccLabel removeFromSuperview];
    [ccTextView removeFromSuperview];
    [self.btnOperateCC removeFromSuperview];
    [attachFileView removeFromSuperview];
    [self resetFrame];
    [self loadEmailDetail];
    [self displayEmailContent];
}

- (void)backToMenuSideBar
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)clickedBtnDelete:(id)sender;

{
    [alertView showWarning:mWarning_EmailWillBeDeleted TARGET:self ACTION:@selector(deleteEmail)];
}

-(void)deleteEmail
{
    [[EmailFacade share] deleteEmail:mailHeader.uid inFolder:[mailHeader.folderIndex doubleValue]];
}
//Delete email delegate
-(void) deleteEmailSuccess
{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void) deleteEmailFailed
{

}

- (IBAction)replyEmail:(id)sender
{
    sheetReplyEmail = [[UIActionSheet alloc] initWithTitle:nil
                                                                 delegate:self
                                                        cancelButtonTitle:_CANCEL
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:_REPLY, _REPLY_ALL, nil];
    [sheetReplyEmail showInView:self.view];
}

- (IBAction)moreAction:(id)sender
{
    if (mailHeader.folderIndex.intValue == kINDEX_FOLDER_JUNK)
    {
        // No need show move to junk when already in Junk
        sheetMore2Button = [[UIActionSheet alloc] initWithTitle:nil
                                                      delegate:self
                                             cancelButtonTitle:_CANCEL
                                        destructiveButtonTitle:nil
                                             otherButtonTitles:_SAVE_THIS_EMAIL, nil];
        [sheetMore2Button showInView:self.view];
    }
    else
    {
        sheetMore3Button = [[UIActionSheet alloc] initWithTitle:nil
                                                      delegate:self
                                             cancelButtonTitle:_CANCEL
                                        destructiveButtonTitle:nil
                                             otherButtonTitles:_MOVE_TO_JUNK, _SAVE_THIS_EMAIL, nil];
        [sheetMore3Button showInView:self.view];
    }
}

- (IBAction)clickedBtnForward:(id)sender
{
    EmailComposeView *composeView = [EmailComposeView new];
    composeView.emailContents = mailContent;
    composeView.emailHeader = mailHeader;
    composeView.composeAction = (ComposeEmailAction *)kCOMPOSE_EMAIL_ACTION_FOWARD;
    composeView.arrayAttachment = arrAttachmentsName;
    [self.navigationController pushViewController:composeView animated:YES];
}

- (IBAction)clickedBtnOperateTO:(UIButton *)sender
{
    if (!isOperatedToView) {
        
        isOperatedToView = YES;
        CGSize newSize = [txtEmailTo sizeThatFits:CGSizeMake(txtEmailTo.width, MAXFLOAT)];
        [txtEmailTo changeWidth:txtEmailTo.width Height:newSize.height];
        [self.btnOperateTO setBackgroundImage:[UIImage imageNamed:IMG_MINUS_SIGN]
                                     forState:UIControlStateNormal];
        
    }else{
        //To
        
        isOperatedToView = NO;
        [self.btnOperateTO setBackgroundImage:[UIImage imageNamed:IMG_PLUG_SIGN] forState:UIControlStateNormal];
        
        [txtEmailTo changeWidth:txtEmailTo.width Height:45];
        [self.btnOperateTO changeXAxis:txtEmailTo.frame.origin.x - 20
                                 YAxis:txtEmailTo.frame.origin.y + 30];
    }
    
    if (ccView.height > 0) {
        [ccView changeXAxis:ccView.x YAxis:txtEmailTo.y +txtEmailTo.height];
        [lblline1 changeXAxis:lblline1.x
                        YAxis:ccView.y + ccView.height + 5];
    }
    else{
        [lblline1 changeXAxis:lblline1.frame.origin.x YAxis:txtEmailTo.frame.origin.y + txtEmailTo.frame.size.height + 7];
    }
    
    [self fixLocationOnDetailView];
    [scrollView setContentSize:CGSizeMake(self.scrollView.frame.size.width, webViewEmailContent.frame.origin.y + webViewEmailContent.scrollView.contentSize.height + 5)];
    
}
- (IBAction)clickedBtnOperateCC:(UIButton *)sender
{
    if (!isOperatedCCView) {
        
        isOperatedCCView = YES;
        CGSize newSize = [ccTextView sizeThatFits:CGSizeMake(ccTextView.width, MAXFLOAT)];
        [ccTextView changeWidth:ccTextView.width Height:newSize.height];
        [ccView changeWidth:ccTextView.width Height:ccTextView.height];
        [self.btnOperateCC setBackgroundImage:[UIImage imageNamed:IMG_MINUS_SIGN] forState:UIControlStateNormal];
        
    }else{
        isOperatedCCView = NO;
        
        [self.btnOperateCC setBackgroundImage:[UIImage imageNamed:IMG_PLUG_SIGN]
                                     forState:UIControlStateNormal];
        
        [ccTextView changeWidth:ccTextView.frame.size.width  Height:45];
        [ccView changeWidth:ccTextView.width Height:ccTextView.height];
        [self.btnOperateCC changeXAxis:ccTextView.x - 20
                                 YAxis:ccTextView.frame.origin.y + 30];
    }
    
    [lblline1 changeXAxis:lblline1.frame.origin.x
                    YAxis:ccView.frame.origin.y + ccView.frame.size.height + 5];
    [self fixLocationOnDetailView];
    [scrollView setContentSize:CGSizeMake(self.scrollView.frame.size.width, webViewEmailContent.frame.origin.y + webViewEmailContent.scrollView.contentSize.height + 5)];
}

-(void)fixLocationOnDetailView
{
    [txtEmailTitleDetail changeXAxis:txtEmailTitleDetail.frame.origin.x
                               YAxis:lblline1.bottomEdge + padding];
    [lblTimeStamp changeXAxis:lblTimeStamp.x
                        YAxis:txtEmailTitleDetail.bottomEdge];
    [lblline2 changeXAxis:lblline2.x
                    YAxis:lblTimeStamp.bottomEdge + padding];
    
    if (mailHeader.attachNumber.intValue > 0)
    {
        [attachFileView changeXAxis:attachFileView.x
                              YAxis:lblline2.bottomEdge + padding];
        [webViewEmailContent changeXAxis:webViewEmailContent.x
                                   YAxis:attachFileView.bottomEdge + 2*padding ];
    }
    else
    {
        [webViewEmailContent changeXAxis:webViewEmailContent.x
                                   YAxis:lblline2.bottomEdge + 2*padding ];
    }
}

#pragma mark -  UIActionSheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet == sheetReplyEmail)
    {
        switch (buttonIndex)
        {
            case 0:
            {
                // Reply
                EmailComposeView *composeView = [EmailComposeView new];
                composeView.emailContents = mailContent;
                composeView.emailHeader = mailHeader;
                composeView.composeAction = (ComposeEmailAction *)kCOMPOSE_EMAIL_ACTION_REPLY;
                [self.navigationController pushViewController:composeView animated:YES];
            }
            break;

            case 1:
            {
                // Reply all
                EmailComposeView *composeView = [EmailComposeView new];
                composeView.emailContents = mailContent;
                composeView.emailHeader = mailHeader;
                composeView.composeAction = (ComposeEmailAction *)kCOMPOSE_EMAIL_ACTION_REPLY_ALL;
                [self.navigationController pushViewController:composeView animated:YES];
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
    else if (actionSheet == sheetMore3Button)
    {// more action sheet
        switch (buttonIndex)
        {
            case 0:
            {
                // move to junk
                [[EmailFacade share] moveEmail:mailHeader.uid toFolder:kINDEX_FOLDER_JUNK];
                [self nextEmail];
            }
            break;

            case 1:
            {
                // save
                [[EmailFacade share] moveEmail:mailHeader.uid toFolder:kINDEX_FOLDER_SAVED_EMAILS];
                [self nextEmail];
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
    else
    {
        switch (buttonIndex)
        {
            case 0:
            {
                // save
                [[EmailFacade share] moveEmail:mailHeader.uid toFolder:kINDEX_FOLDER_SAVED_EMAILS];
                [self nextEmail];
            } break;

            case 1:
            {
                // Cancel
                NSLog(@"Click button 1");
                break;
            }
            default:
                break;
        }
    }
}

@end
