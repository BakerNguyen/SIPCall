//
//  SearchMaskingID.m
//  KryptoChat
//
//  Created by TrungVN on 5/29/14.
//  Copyright (c) 2014 mTouche. All rights reserved.
//

#import "ContactSearchMID.h"
#import "ContactSearchMIDCell.h"


@interface ContactSearchMID (){

    NSDictionary *friendObject;
    
}
@end

@implementation ContactSearchMID

@synthesize txtSearchFriend,tblSearchFriend,lblNotFound;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = TITLE_ADD_FRIENDS;
    
    txtSearchFriend.layer.sublayerTransform = CATransform3DMakeTranslation(10, 0, 0);
    
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:[self view]
                                                                            action:@selector(endEditing:)]];
    [ContactFacade share].contactSearchMIDDelegate = self;
}

-(void) viewWillAppear:(BOOL)animated{
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem createLeftButtonTitle:_BACK Target:self.navigationController Action:@selector(popViewControllerAnimated:)];
    txtSearchFriend.text = @"";
    tblSearchFriend.hidden = YES;
    lblNotFound.hidden = YES;
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

-(UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellID =  @"ContactSearchMIDCell";
    ContactSearchMIDCell* cell = [tblSearchFriend dequeueReusableCellWithIdentifier:cellID];
    
    if(!cell){
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:cellID owner:self options:nil];
    	cell = (ContactSearchMIDCell*)[nib objectAtIndex:0];
    }
    
    NSString* fullJID = @"";
    if (friendObject) {
        fullJID = [fullJID stringByAppendingString:[friendObject objectForKey:kJID]];
        fullJID = [fullJID stringByAppendingString:@"@"];
        fullJID = [fullJID stringByAppendingString:[friendObject objectForKey:kHOST]];
    }
    
    Contact* contact = [[ContactFacade share] getContact:fullJID];
    //Display friend info
    if (contact) {
        cell.lblName.text = [[ContactFacade share] getContactName:fullJID];
        cell.bob_maskingId = contact.maskingid;
        cell.bob_jid = fullJID;
        cell.profile_image.image = [[ContactFacade share] updateContactAvatar:fullJID];
        cell.btnAdd.enabled = FALSE;
        [cell.btnAdd setImage:[UIImage imageNamed:IMG_BUTTON_ADD] forState:UIControlStateNormal];
        [cell.btnAddWidth setConstant:65];
        
        switch ([contact.contactType integerValue]) {
            case kCONTACT_TYPE_FRIEND:
                break;
                
            case kCONTACT_TYPE_NOT_FRIEND:{
                NSString* queryRequest = [NSString stringWithFormat:@"requestJID = '%@'", fullJID];
                Request* request = (Request*)[[DAOAdapter share] getObject:[Request class] condition:queryRequest];
                if([request.requestType intValue] == kREQUEST_TYPE_RECEIVE && [request.status intValue] == kREQUEST_STATUS_PENDING){
                    cell.btnAdd.enabled = TRUE;
                    [cell.btnAdd setImage:[UIImage imageNamed:IMG_BUTTON_APPROVE] forState:UIControlStateNormal];
                    [cell.btnAddWidth setConstant:95];
                }
            }
                break;
                
            case kCONTACT_TYPE_KRYPTO_USER:
                cell.btnAdd.enabled = TRUE;
                break;
                
            default:
                break;
        }
    }
    
    return cell;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSString * txtContent = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if(txtContent.length == 8){
        txtSearchFriend.text = txtContent;
        if ([[ContactFacade share] isAccountRemoved]) {
            [[CAlertView new] showError:ERROR_ACCOUNT_REMOVED];
            return YES;
        }
        
        if (![[NotificationFacade share] isInternetConnected]){
            [[CAlertView new] showError:NO_INTERNET_CONNECTION_TRY_LATER];
            return YES;
        }
        
        if([[txtContent uppercaseString] isEqualToString:[[ContactFacade share] getMaskingId]])
        {
            [[CAlertView new] showError:mERROR_CANNOT_ADD_SELF_KRYPTO_ID];
        }
        else{
            [[CWindow share] showLoading:kLOADING_SEARCHING];
            
            [[ContactFacade share] searchFriendByMaskingId:txtContent];
            lblNotFound.hidden = TRUE;
        }
    }
    else{
        [self failedSearchResult];
    }
    if(txtContent.length == 0){
        lblNotFound.hidden = TRUE;
        tblSearchFriend.hidden = TRUE;
    }
    
    return YES;
}

-(void) showSearchResult:(NSDictionary*) searchResult{
    if(txtSearchFriend.text.length > 0){
        tblSearchFriend.hidden = FALSE;
        lblNotFound.hidden = TRUE;
        friendObject = searchResult;
        [tblSearchFriend reloadData];
    }
}

-(void)refreshSearchResult
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [tblSearchFriend reloadData];
    });
}

-(void) failedSearchResult{
    tblSearchFriend.hidden = TRUE;
    lblNotFound.hidden = FALSE;
}

-(void) addFriendSuccess{
    [[CWindow share] hideLoading];
    if (!self.navigationController)
        return;
    
    txtSearchFriend.text = @"";
    [friendObject setValue:[NSNumber numberWithInt:kCONTACT_TYPE_NOT_FRIEND] forKey:kCONTACT_TYPE];
    [tblSearchFriend reloadData];
    
    NSMutableArray *buttonsName  = [NSMutableArray arrayWithObjects:_ADD_MORE,_OK, nil];
    
    CAlertView* alertView = [CAlertView new];
    [alertView showInfo_2btn:SUCCESS_TO_SEND_FRIEND_REQUEST ButtonsName:buttonsName];
    [alertView setOnButtonTouchUpInside:^(CAlertView *alertView, int buttonIndex)
     {
         if(buttonIndex ==0)
             tblSearchFriend.hidden = TRUE;
         else
             [[CWindow share] showContactList];
     }];
}

-(void) addFriendFailed{
    if (![self.navigationController.topViewController isKindOfClass:[self class] ])
        return;
    
    
    [[CWindow share] hideLoading];
    [[CAlertView new] showError:_ALERT_FAILED_ADD];
}

-(void) approveFriendSuccess{
    if(self.navigationController){
        [[CWindow share] showContactList];
    }
}

-(void) approveFriendFailed{
    [[CAlertView new] showError:NSLocalizedString(@"Approve failed",nil)];
}

+(ContactSearchMID *)share{
    static dispatch_once_t once;
    static ContactSearchMID * share;
    dispatch_once(&once, ^{
        share = [self new];
    });
    return share;
}
@end
