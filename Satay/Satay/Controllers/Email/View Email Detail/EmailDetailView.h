//
//  EmailDetailView.h
//  Satay
//
//  Created by Arpana Sakpal on 3/18/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EmailDetailView : UIViewController<UIActionSheetDelegate, UIWebViewDelegate, UIScrollViewDelegate>
{
    BOOL isReply;
    UIActionSheet *standardUIAS;
    CAlertView *alertView;
    
}
#define padding 5

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (strong, nonatomic) MailHeader *mailHeader;
@property (strong, nonatomic) NSMutableArray *arrayEmails;

@property (weak, nonatomic) IBOutlet UILabel *lblEmailFrom;
@property (weak, nonatomic) IBOutlet UITextView *txtEmailTo;
@property (weak, nonatomic) IBOutlet UITextView *txtEmailTitleDetail;
@property (weak, nonatomic) IBOutlet UILabel *lblTimeStamp;
@property (weak, nonatomic) IBOutlet UIWebView *webViewEmailContent;
@property (strong, nonatomic) IBOutlet UIImageView *imgProfileImage;

@property (weak, nonatomic) IBOutlet UILabel *lblline1;
@property (weak, nonatomic) IBOutlet UILabel *lblline2;
@property (strong, nonatomic) IBOutlet UIButton *btnOperateTO;
@property (strong, nonatomic) IBOutlet UIButton *btnOperateCC;
@property (strong, nonatomic) IBOutlet UIButton *btnNext;
@property (strong, nonatomic) IBOutlet UIButton *btnPrev;


@property (strong, nonatomic) IBOutlet UIButton *btnForward;
@property (strong, nonatomic) IBOutlet UIButton *btnMore;
@property (strong, nonatomic) IBOutlet UIButton *btnDelete;
@property (weak, nonatomic) IBOutlet UIButton *btnReply;

- (IBAction)replyEmail:(id)sender;
- (IBAction)moreAction:(id)sender;

/**
 *  Action click on button foward email
 *
 *  @param sender button foward
 *  @author Arpana
 *  date 19-Mar-2015
 */
- (IBAction)clickedBtnForward:(id)sender;

/**
 *  Action click on button expand/collasapse field to
 *
 *  @param sender button expand/collasapse at to
 *  @author Arpana
 *  date 19-Mar-2015
 */
- (IBAction)clickedBtnOperateTO:(UIButton *)sender;

/**
 *  Action click on button expand/collasapse field CC
 *
 *  @param sender button expand/collasapse at CC
 *  @author Arpana
 *  date 19-Mar-2015
 */
- (IBAction)clickedBtnOperateCC:(UIButton *)sender;

/**
 *  Action click on button delete email
 *
 *  @param sender button delete
 *  @author Arpana
 *  date 19-Mar-2015
 */
- (IBAction)clickedBtnDelete:(id)sender;
@property (strong, nonatomic) IBOutlet UIView *viewBtnNextPrev;
@property (strong, nonatomic) IBOutlet UIView *viewBottom;
@property (strong, nonatomic) IBOutlet UIButton *btnBack;
@property (strong, nonatomic) IBOutlet UILabel *lblTitle;
@property (strong, nonatomic) IBOutlet UIView *viewTitle;

@end
