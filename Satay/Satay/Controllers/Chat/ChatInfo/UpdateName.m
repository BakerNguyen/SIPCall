//
//  UpdateName.m
//  Satay
//
//  Created by TrungVN on 3/9/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import "UpdateName.h"
#import "CWindow.h"

//#define MAX_LENGHT_UPDATE 20

@interface UpdateName ()
{
    int maxLength;
}
@end

@implementation UpdateName

@synthesize chatBoxId;
@synthesize lblCounter, txtUpdateName;

- (void)viewDidLoad {
    [super viewDidLoad];
    txtUpdateName.delegate = self;
    txtUpdateName.font = [UIFont systemFontOfSize:FONT_TEXT_SIZE_15];
    lblCounter.textColor = [[UIColor alloc] initWithRed:170/255.0f green:170/255.0f blue:170/255.0f alpha:1];
    lblCounter.font = [UIFont systemFontOfSize:FONT_TEXT_SIZE_14];
}

-(void) viewWillAppear:(BOOL)animated{
    self.navigationItem.title = TITLE_UPDATE_NAME;
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem createRightButtonTitle:_SAVE Target:self
                                                                              Action:@selector(updateName)];
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem createLeftButtonTitle:_CANCEL Target:self
                                                                            Action:@selector(cancelDisplayNameView)];

    if ([[AppFacade share] getChatBox:chatBoxId].isGroup) {
        txtUpdateName.text = [[AppFacade share] getGroupObj:chatBoxId].groupName;
        maxLength = MAX_LENGHT_TEXT_GROUP_NAME;
        self.navigationItem.rightBarButtonItem.enabled = ([txtUpdateName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length > 0);
    }
    else{
        txtUpdateName.text = [[ContactFacade share] getContactName:chatBoxId];
        maxLength = MAX_LENGHT_TEXT_NAME;
        self.navigationItem.rightBarButtonItem.enabled = TRUE; 
    }
    lblCounter.text = [NSString stringWithFormat:@"%d",maxLength - (int)txtUpdateName.text.length];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];

}

-(void) cancelDisplayNameView{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void) updateNameFailed{
    [[CAlertView new] showError:_ALERT_FAILED_HERE];
}

-(void) updateName{
    self.navigationItem.rightBarButtonItem.enabled = FALSE;
    [[CWindow share] showLoading:kLOADING_UPDATING];
    ChatBox* chatBox = [[AppFacade share] getChatBox:chatBoxId];
    if(chatBox.isGroup){
        //Need to upload to server.
        GroupObj *group = [[AppFacade share] getGroupObj:chatBox.chatboxId];
        if (group) {
            group.groupName = txtUpdateName.text;
            NSDictionary *renameDic = @{kROOMJID: chatBox.chatboxId,
                                        kROOMNAME: [Base64Security generateBase64String:txtUpdateName.text]
                                        };
            [[ChatFacade share] setChatRoomName:renameDic callback:^(BOOL success, NSString *message, NSDictionary *response, NSError *error) {
                [[CWindow share] hideLoading];
                self.navigationItem.rightBarButtonItem.enabled = TRUE;
                if (success) {
                    [[DAOAdapter share] commitObject:group];
                    txtUpdateName.text = [[ChatFacade share] getGroupName:chatBox.chatboxId];
                    [[ContactFacade share] callContactUpdateDelegate];
                    [[self navigationController] popViewControllerAnimated:YES];
                }
                else{
                    [[CAlertView new] showError:ERROR_UPDATE_GROUP_NAME];
                }
            }];
        }
    }
    else{
        Contact* contact = [[ContactFacade share] getContact:chatBox.chatboxId];
        if (contact) {
            contact.customerName = [txtUpdateName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            [[DAOAdapter share] commitObject:contact];
            [[ContactFacade share] callContactUpdateDelegate];
            txtUpdateName.text = [[ContactFacade share] getContactName:chatBoxId];
            [[CWindow share] hideLoading];
            [[self navigationController] popViewControllerAnimated:YES];
            self.navigationItem.rightBarButtonItem.enabled = FALSE;
        }
    }
}

- (void)textViewDidChange:(UITextView *)textView
{
    NSUInteger newLength = textView.text.length;
    int numberRest = maxLength - (int)textView.text.length;
    lblCounter.text = [NSString stringWithFormat:@"%d",numberRest];
    if (newLength > maxLength)
        [textView deleteBackward];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    NSString *actualString  = [textView.text stringByReplacingCharactersInRange:range withString:text];

    if([text isEqualToString:@"\n"]){
        [txtUpdateName resignFirstResponder];
    }
    if (actualString.length > 0) {
        if(actualString.length > maxLength && actualString.length < UINT32_MAX)
            return NO;
        else
        {
            long numberRest = maxLength - actualString.length;
            lblCounter.text = [NSString stringWithFormat:@"%ld",numberRest];
        }
    }
    else {
        lblCounter.text = [NSString stringWithFormat:@"%d",maxLength];
    }
    
    if ([[AppFacade share] getChatBox:chatBoxId].isGroup) {
        self.navigationItem.rightBarButtonItem.enabled = ([actualString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length > 0);
    }
    
    return YES;
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary *keyboardInfo = [notification userInfo];
    CGRect keyboardEndFrame;
    [[keyboardInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardEndFrame];
    [lblCounter changeXAxis:self.view.width - 25 YAxis:self.view.height - keyboardEndFrame.size.height -25];
    
    keyboardInfo = nil;
}

+(UpdateName *)share{
    static dispatch_once_t once;
    static UpdateName * share;
    dispatch_once(&once, ^{
        share = [self new];
    });
    return share;
}

@end
