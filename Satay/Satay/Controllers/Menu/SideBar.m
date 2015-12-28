//
//  SideBar.m
//  KryptoChat
//
//  Created by TrungVN on 4/3/14.
//  Copyright (c) 2014 mTouche. All rights reserved.
//

#import "SideBar.h"
#import "CWindow.h"
#import "SideBarCell.h"

@interface SideBar ()
{
    NSInteger numberChatUnreadMessage, numberEmailUnreadMessage;
}
@end

@implementation SideBar

@synthesize tblMenu, menuHeader, arrMenu, bgImage, selectedIndex;

+(SideBar *)share{
    static dispatch_once_t once;
    static SideBar * share;
    dispatch_once(&once, ^{
        share = [self new];
        [ChatFacade share].sideBarDelegate = share;
        [EmailFacade share].sideBarDelegate = share;
        [SIPFacade share].sideBarDelegate = share;
        [NotificationFacade share].sideBarDelegate = share;
    });
    return share;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [bgImage setImage:SIDEMENU_BG];
    [tblMenu setTableHeaderView:menuHeader];
    arrMenu = [[NSMutableArray alloc] initWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"Menu" ofType:@"plist"]];
    
    UISwipeGestureRecognizer* swipeGesture = [[UISwipeGestureRecognizer alloc]
                                              initWithTarget:[CWindow share].menuController action:@selector(showCenterPanel:)];
    swipeGesture.direction = UISwipeGestureRecognizerDirectionLeft;
    [tblMenu addGestureRecognizer:swipeGesture];
    numberChatUnreadMessage = [[ChatFacade share] getNumberAllChatBoxUnreadMessage];
    numberEmailUnreadMessage = [[EmailFacade share] countTotalUnreadEmailInFolderIndex:kINDEX_FOLDER_INBOX];
}

-(void) viewWillAppear:(BOOL)animated{
    NSString* displayName = [[ContactFacade share] getDisplayName];
    if (displayName.length > 0)
        menuHeader.lblName.text = displayName;
    else
        menuHeader.lblName.text = [[ContactFacade share] getMaskingId];
    menuHeader.lblStatus.text = [[ContactFacade share] getProfileStatus].length > 0 ? [[ContactFacade share] getProfileStatus] : DEFAULT_STATUS_AVAILABLE;
    menuHeader.imgProfile.image = [[ContactFacade share] getProfileAvatar];
}

#pragma mark TableView

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"SideBarCell";
    SideBarCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if(!cell){
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:cellID owner:self options:nil];
        cell = (SideBarCell*)[nib objectAtIndex:0];
    }
    
    cell.lblCell.text = [[arrMenu objectAtIndex:indexPath.row] objectForKey:@"NAME"];
    NSString* iconName = [[arrMenu objectAtIndex:indexPath.row] objectForKey:@"ICON"];
    cell.imgCell.image = [UIImage imageNamed:iconName];
    cell.imgCell.highlightedImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@_t", iconName]];
    cell.tag = [[[arrMenu objectAtIndex:indexPath.row] objectForKey:@"ID"] intValue];
    cell = [self showNotificationCount:cell forRow:indexPath.row];
    
    return cell;
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    [cell setSelected:indexPath.row == selectedIndex];
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [arrMenu count];
}

-(void) tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    [[tableView cellForRowAtIndexPath:indexPath] setHighlighted:TRUE];
}
-(void) tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    [[tableView cellForRowAtIndexPath:indexPath] setHighlighted:FALSE];
}

-(void) tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    [[tableView cellForRowAtIndexPath:indexPath] setSelected:FALSE];
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [[tableView cellForRowAtIndexPath:indexPath] setSelected:TRUE];
    
    switch (indexPath.row) {
        case 0:
            [[CWindow share] showContactList];
            break;
        case 1:
            [[CWindow share] showChatList];
            break;
        case 2:{
            if ([[[EmailFacade share] getLoginEmailFlag] isEqualToString:IS_NO]) {
                [[CWindow share] showEmailLogin];
            }else
                [[CWindow share] showMailBox];
        }
            break;
        case 3:
            [[CWindow share] showSecureNote];
            break;
        case 4:
            [[CWindow share] showNotification];
            break;
        case 5:
            [[CWindow share] showSetting];
            break;
            
        default:
            break;
    }
}

#pragma mark Set number unread notification
- (void) updateEmailRowUnreadNumber:(NSInteger)numberNewEmail
{
    NSIndexPath *pathOfItem = [NSIndexPath indexPathForRow:SideBarEmailIndex inSection:0];
    SideBarCell *cell = (SideBarCell *)[tblMenu cellForRowAtIndexPath:pathOfItem];
    
    if (numberNewEmail == kNUMBER_DELETE_EMAIL)
        numberEmailUnreadMessage = 0;
    else
        numberEmailUnreadMessage += numberNewEmail;
    
    if (numberEmailUnreadMessage > 0)
    {
        cell.lblNumberNotification.hidden = NO;
        cell.lblNumberNotification.text = [[NotificationFacade share] stringNumberNotification:numberEmailUnreadMessage];
    }
    else
    {
        cell.lblNumberNotification.hidden = YES;
    }
}

- (void) updateChatRowUnreadNumber
{
    [[NSOperationQueue new] addOperationWithBlock:^(){
        numberChatUnreadMessage = [[ChatFacade share] getNumberAllChatBoxUnreadMessage];
        [[NSOperationQueue mainQueue] addOperationWithBlock:^(){
            NSIndexPath *pathOfItem = [NSIndexPath indexPathForRow:SideBarChatIndex inSection:0];
            SideBarCell *cell = (SideBarCell *)[tblMenu cellForRowAtIndexPath:pathOfItem];
            if (numberChatUnreadMessage > 0)
            {
                cell.lblNumberNotification.hidden = NO;
                cell.lblNumberNotification.text = [[NotificationFacade share] stringNumberNotification:numberChatUnreadMessage];
            }
            else
            {
                cell.lblNumberNotification.hidden = YES;
            }
        }];
    }];
}

-(void) reloadNotificationCount:(NSInteger)count MenuID:(NSInteger)menuID{
    NSIndexPath *pathOfItem = [NSIndexPath indexPathForRow:menuID inSection:0];
    SideBarCell *cell = (SideBarCell *)[tblMenu cellForRowAtIndexPath:pathOfItem];
    
    if (menuID == SideBarChatIndex)
        numberChatUnreadMessage = count;
    
    if (menuID == SideBarEmailIndex)
        numberEmailUnreadMessage = count;
    
    if ([cell.lblNumberNotification.text isEqual:@"9+"]) {
        if (count >10) {
            return;
        }
    }
    
    NSArray * cells = [tblMenu visibleCells];
    if (cells)
    {
        NSLog(@"cell.tag %ld",(long)cell.tag);
        if (count > 0)
        {
            cell.lblNumberNotification.hidden = NO;
            cell.lblNumberNotification.text = [[NotificationFacade share] stringNumberNotification:count];
        }
        else
        {
            cell.lblNumberNotification.hidden = YES;
        }
    }
}

- (SideBarCell *)showNotificationCount:(SideBarCell *)cell forRow:(NSInteger)row{
    NSInteger unreadNumber = 0;
    cell.lblNumberNotification.hidden = YES;
    switch (row) {
        case SideBarContactIndex:{
            NSArray* arrUnreadRequestNotice = [[NotificationFacade share] getAllNoticesWithContent:kNOTICEBOARD_CONTENT_ADD_CONTACT status:kNOTICEBOARD_STATUS_NEW];
            unreadNumber = arrUnreadRequestNotice.count;
            if(unreadNumber > 0){
                cell.lblNumberNotification.text = [[NotificationFacade share] stringNumberNotification:unreadNumber];
            }
        }
            break;
            
        case SideBarChatIndex:
        {
            unreadNumber = numberChatUnreadMessage;
            if(unreadNumber > 0)
            {
                cell.lblNumberNotification.text = [[NotificationFacade share] stringNumberNotification:unreadNumber];
            }
        }
            break;
            
        case SideBarEmailIndex:
        {
            unreadNumber = numberEmailUnreadMessage;
            if(unreadNumber > 0)
            {
                cell.lblNumberNotification.text = [[NotificationFacade share] stringNumberNotification:unreadNumber];
            }
        }
            break;
            
        case SideBarSecureNoteIndex:
            break;
            
        case SideBarNotificationIndex:{
            unreadNumber = [[NotificationFacade share] getNumberUnreadNotices];
            if(unreadNumber > 0)
            {
                cell.lblNumberNotification.text = [[NotificationFacade share] stringNumberNotification:unreadNumber];
            }
            break;
        }
            
        case SideBarSettingIndex:
            break;
            
        default:
            cell.lblNumberNotification.hidden = YES;
            break;
    }
    
    if (unreadNumber > 0)
    {
        cell.lblNumberNotification.hidden = NO;
    }
    
    return cell;
}
@end
