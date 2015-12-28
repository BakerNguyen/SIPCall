//
//  NotificationController.m
//  Satay
//
//  Created by Arpana Sakpal on 1/20/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import "NotificationController.h"
#import "NotificationRequestViewCell.h"
#import "ContactRequest.h"
#import "ContactList.h"

@class IncomingNotification;
@interface NotificationController (){
    NSArray *arrAllNotices;
}

@end

@implementation NotificationController
@synthesize tblNotificationList;
@synthesize lblNoNotification;
@synthesize incomingNotification;

+(NotificationController *)share{
    static dispatch_once_t once;
    static NotificationController * share;
    dispatch_once(&once, ^{
        share = [self new];
    });
    return share;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [NotificationFacade share].notificationListDelegate = self;
    [ContactFacade share].notificationListDelegate = self;
    
    self.title=TITLE_NOTIFICATION;
    lblNoNotification.text = LABEL_NO_NOTIFICATION;
    lblNoNotification.textColor = COLOR_128128128;
    lblNoNotification.font = [UIFont systemFontOfSize:16];
    lblNoNotification.frame = CGRectMake(lblNoNotification.frame.origin.x, lblNoNotification.frame.origin.y, lblNoNotification.frame.size.width,([[UIScreen mainScreen] applicationFrame].size.height - 16)/2 );
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    tblNotificationList.hidden = NO;
    lblNoNotification.hidden = YES;
    [self reloadNotificationPage];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[NotificationFacade share] deleteAllRemovedContactNotices];
        [[NotificationFacade share] markAllNoticesAsRead];
        [[NotificationFacade share] setUnreadNotification:0 atMenuIndex:SideBarNotificationIndex];
        [[NotificationFacade share] setUnreadNotification:0 atMenuIndex:SideBarContactIndex];
        [[NotificationFacade share] hideNotificationView];
    });
}

#pragma mark Support methods

- (void) reloadNotificationPage{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        arrAllNotices = [[NotificationFacade share] getAllNoticesWithContent:nil status:nil];
        if (arrAllNotices.count > 0) {
            tblNotificationList.hidden = NO;
            lblNoNotification.hidden = YES;
        }
        else{
            tblNotificationList.hidden = YES;
            lblNoNotification.hidden = NO;
        }
        
        [tblNotificationList reloadData];
    }];
}

- (NSAttributedString*) generateNoticeContent:(NSString*)displayName noticeBoard:(NoticeBoard *)notice
{
    NSString* contentStr = [NSString new];
    if([notice.content isEqual:kNOTICEBOARD_CONTENT_ADD_CONTACT]){
        contentStr = mNOTICEBOARD_ADD_CONTACT;
    }else if([notice.content isEqual:kNOTICEBOARD_CONTENT_DELETE_CONTACT]){
        contentStr = mNOTICEBOARD_DELETE_CONTACT;
    }
    
    const CGFloat fontSize = 28.0f/SCALE;
    UIFont *boldFont = [UIFont boldSystemFontOfSize:fontSize];
    UIFont *regularFont = [UIFont systemFontOfSize:fontSize];
    UIColor *foregroundColor = [UIColor blackColor];
    
    NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:
                           boldFont, NSFontAttributeName,
                           foregroundColor, NSForegroundColorAttributeName, nil];
    NSDictionary *subAttrs = [NSDictionary dictionaryWithObjectsAndKeys:
                              regularFont, NSFontAttributeName, nil];
    
    
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",displayName] attributes:attrs];
    NSMutableAttributedString *contentText = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",contentStr] attributes:subAttrs];
    [attributedText appendAttributedString:contentText];
    
    return attributedText;
}


#pragma mark UITableView

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return arrAllNotices.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellId = @"NotificationRequestViewCell";
    NotificationRequestViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellId];
    
    if (!cell)
    {
        NSArray *nib= [[NSBundle mainBundle]loadNibNamed:cellId owner:self options:nil];
        cell=(NotificationRequestViewCell*)[nib objectAtIndex:0];
    }
  
    if(!arrAllNotices)
        return cell;
    
    NoticeBoard *noticeItem = [NoticeBoard new];
    if(arrAllNotices.count > indexPath.row){
        noticeItem = [arrAllNotices objectAtIndex:indexPath.row];
    }
    
    if(!noticeItem)
        return cell;
    
    if ([noticeItem.status  isEqual: kNOTICEBOARD_STATUS_NEW]) {
        [cell setBackgroundColor:COLOR_255244230];
    }
    else{
        [cell setBackgroundColor:[UIColor whiteColor]];
    }
    
    NSAttributedString *attributedText = [NSAttributedString new];
    cell.noticeBoard = noticeItem;
    cell.profileImage.image = [[ContactFacade share] updateContactAvatar:noticeItem.noticeID];
    
    attributedText = [self generateNoticeContent:[[ContactFacade share] getContactName:noticeItem.noticeID]
                                     noticeBoard:noticeItem];
    [cell.notifyContent setAttributedText:attributedText];
    
    return cell;
}



-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return HEIGHT_CELL/SCALE;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NoticeBoard *currentNotice = [NoticeBoard new];
    if(arrAllNotices.count > indexPath.row)
        currentNotice = [arrAllNotices objectAtIndex:indexPath.row];
    
    if([currentNotice.content isEqual:kNOTICEBOARD_CONTENT_ADD_CONTACT]){
        [self.navigationController pushViewController:[ContactRequest share] animated:NO];
    }
    
}




@end
