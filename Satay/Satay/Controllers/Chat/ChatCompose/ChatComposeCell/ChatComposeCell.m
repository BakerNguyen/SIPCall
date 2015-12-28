//
//  ComposeViewCell.m
//  KryptoChat
//
//  Created by TrungVN on 4/22/14.
//  Copyright (c) 2014 mTouche. All rights reserved.
//

#import "ChatComposeCell.h"
#import "NewGroup.h"


@implementation ChatComposeCell

@synthesize lblName, lblStatus, separateView, imgAvatar;
@synthesize containerView;
@synthesize checkBox;

-(void) willMoveToSuperview:(UIView *)newSuperview{
    checkBox.layer.cornerRadius = checkBox.width/2;
    imgAvatar.layer.cornerRadius = imgAvatar.width/2;
}

-(void) displayCell:(Contact*) contactInfo{
    lblName.text = [[ContactFacade share] getContactName:contactInfo.jid];
    
    if([[NewGroup share].arrGroupFriend containsObject:contactInfo]){
        checkBox.image = [UIImage imageNamed:IMG_C_B_TICK];
        checkBox.layer.borderWidth = 1;
    }
    else{
        checkBox.image = NULL;
        checkBox.layer.borderColor = COLOR_128128128.CGColor;
        checkBox.layer.borderWidth = 0;
    }
    
    NSString* contactState = @"";
    switch ([contactInfo.contactState integerValue]) {
        case kCONTACT_STATE_ONLINE: contactState = _ONLINE; break;
        case kCONTACT_STATE_OFFLINE: contactState = _OFFLINE; break;
        case kCONTACT_STATE_BLOCKED: contactState = _BLOCKED; break;
    }
    
    lblStatus.text = contactInfo.statusMsg.length > 0 && ![contactState isEqual:_BLOCKED] ? contactInfo.statusMsg : DEFAULT_STATUS_AVAILABLE;
    
    lblStatus.text = contactInfo.statusMsg.length > 0 ? contactInfo.statusMsg : DEFAULT_STATUS_AVAILABLE;
    lblStatus.text = [contactState isEqualToString:_BLOCKED] ? _BLOCKED: lblStatus.text;
    
    imgAvatar.image = [[ContactFacade share] updateContactAvatar:contactInfo.avatarURL];
}

@end
