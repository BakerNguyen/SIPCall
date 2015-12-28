//
//  FindContactCell.m
//  Satay
//
//  Created by Arpana Sakpal on 3/17/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import "FindContactCell.h"

@implementation FindContactCell

@synthesize lblMessage,lblName,contactAvatar;
@synthesize contactCheck;


- (void)awakeFromNib
{
    [self configureSubviews];
}

- (id)init
{
    if (self = [super init]) {
        [self configureSubviews];
    }
    
    return self;
}

- (void)configureSubviews
{
    self.contactCheck.layer.cornerRadius = 10;
    self.contactCheck.layer.borderWidth  = 1.0;
    self.contactCheck.layer.borderColor  = [UIColor lightGrayColor].CGColor;
    self.contactCheck.selected = NO;
    [self.contactCheck setImage:[UIImage imageNamed:IMG_C_B_TICK] forState:UIControlStateSelected];
    
    
    self.contactAvatar.layer.cornerRadius = 25;
    //self.imgContact.layer.borderWidth  = 1.0;
    self.contactAvatar.clipsToBounds = YES;
    //self.imgContact.layer.borderColor  = [UIColor lightGrayColor].CGColor;
}

- (void)displayCell:(Contact *)contactInfo
{
    lblName.text = [[ContactFacade share] getContactName:contactInfo.jid];
    
    contactCheck.layer.borderColor = COLOR_128128128.CGColor;
    contactCheck.layer.borderWidth = 0;
    
    NSString* contactState = @"";
    switch ([contactInfo.contactState integerValue]) {
        case kCONTACT_STATE_ONLINE: contactState = _ONLINE; break;
        case kCONTACT_STATE_OFFLINE: contactState = _OFFLINE; break;
        case kCONTACT_STATE_BLOCKED: contactState = _BLOCKED; break;
    }
    
    lblMessage.text = contactInfo.statusMsg.length > 0 ? contactInfo.statusMsg : DEFAULT_STATUS_AVAILABLE;
    lblMessage.text = [contactState isEqualToString:_BLOCKED] ? _BLOCKED: lblMessage.text;
    
    
    contactAvatar.image = [[ContactFacade share] updateContactAvatar:contactInfo.avatarURL];
}

- (IBAction)clickedBtnCheck:(id)sender
{
    }

@end