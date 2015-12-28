//
//  HeaderContact.m
//  KryptoChat
//
//  Created by TrungVN on 6/4/14.
//  Copyright (c) 2014 mTouche. All rights reserved.
//

#import "HeaderContact.h"

@implementation HeaderContact

@synthesize btnAvatar, imgAvatar;
@synthesize lblMasking, lblMaskingContent, lblStatus, lblStatusContent;

-(void) buildView:(ChatBox*) chatBox{
    btnAvatar.layer.cornerRadius = btnAvatar.frame.size.width/2;
    imgAvatar.layer.cornerRadius = imgAvatar.frame.size.width/2;   
    
    if (chatBox.isGroup) {
        GroupObj *group = [[AppFacade share] getGroupObj:chatBox.chatboxId];
        [lblStatusContent setFont:[UIFont boldSystemFontOfSize:15.0]];
        lblStatus.text=LABEL_GROUP_CREATED;
        lblStatus.textColor = lblStatusContent.textColor = COLOR_128128128;
        lblStatusContent.text = [[ChatFacade share] getFullTimeString:group.updateTS];
        imgAvatar.image = [[ChatFacade share] updateGroupLogo:chatBox.chatboxId];
    }
    else{
        Contact* contact = [[ContactFacade share] getContact:chatBox.chatboxId];
        if (!contact)
            return;
        imgAvatar.image = [[ContactFacade share] updateContactAvatar:contact.jid];
        lblStatus.text = LABEL_STATUS;
        NSString* contactState = @"";
        switch ([contact.contactState integerValue]) {
            case kCONTACT_STATE_ONLINE: contactState = _ONLINE; break;
            case kCONTACT_STATE_OFFLINE: contactState = _OFFLINE; break;
            case kCONTACT_STATE_BLOCKED: contactState = _BLOCKED; break;
        }
        
        lblStatusContent.text = contact.statusMsg.length > 0 ? contact.statusMsg : DEFAULT_STATUS_AVAILABLE;
        lblStatusContent.text = [contactState isEqualToString:_BLOCKED] ? _BLOCKED: lblStatusContent.text;
        
    }
    [lblStatusContent sizeToFit];
    [lblStatusContent changeWidth:[UIScreen mainScreen].bounds.size.width - lblStatusContent.x
                           Height:lblStatusContent.height];
    [self changeWidth:self.width Height:lblStatusContent.bottomEdge + 5];
}

@end
