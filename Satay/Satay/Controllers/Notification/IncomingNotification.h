//
//  IncomingNotification.h
//  Satay
//
//  Created by Arpana Sakpal on 1/20/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    IN_Type_Chat,
    IN_Type_Email,
    IN_Type_DELETE_REQUEST,
    IN_Type_NEW_REQUEST
} INType;

@interface IncomingNotification : UIView
{
    INType IncomingNotificationType;
}
@property (nonatomic,strong) IBOutlet UIButton *bannerButton;
@property (nonatomic,strong) IBOutlet UIButton *cancelButton;
@property (nonatomic,strong) IBOutlet UILabel *titleLabel;
@property (nonatomic,strong) IBOutlet UILabel *messageLabel;
@property (nonatomic,strong) IBOutlet UIImageView *chatBoxImage;

@property Message* currentMessage;
@property Request* currentRequest;

-(IBAction) cancelButtonPress:(id)sender;
-(IBAction) bannerButtonPress:(id)sender;
-(void) hideBannerNotification;
-(void) showNotifyMessage:(id) message groupName:(id)groupName;
-(void) showNotifyRequest:(id) request;
-(void) showNotifyRemovedContact:(NSString *) fullJID;
-(void) showNotifyNewEmail:(int) numberNewEmail;

+(IncomingNotification *)share;

@end
