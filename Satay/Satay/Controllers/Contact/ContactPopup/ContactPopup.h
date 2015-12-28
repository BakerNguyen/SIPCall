//
//  PopupContact.h
//  KryptoChat
//
//  Created by TrungVN on 4/18/14.
//  Copyright (c) 2014 mTouche. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContactPopupBar.h"
#import "ContactInfo.h"

@interface ContactPopup : UIViewController <ContactPopupDelegate>

@property (nonatomic, retain) IBOutlet ContactPopupBar* navPopup;
@property (nonatomic, retain) IBOutlet UIButton* btnInfo;
@property (nonatomic, retain) IBOutlet UIButton* btnChat;
@property (nonatomic, retain) IBOutlet UIButton* btnEmail;
@property (nonatomic, retain) IBOutlet UIButton* btnVoiceCall;
@property (nonatomic, retain) IBOutlet UIImageView* avatarUser;
@property (nonatomic, retain) IBOutlet UIView* dimView;
@property (nonatomic, retain) NSString* userJid;

+(ContactPopup *)share;

-(void) displayInfo;

-(IBAction) closeView;
-(IBAction) showInfo;
-(IBAction) chatContact;
-(IBAction) emailContact;
-(IBAction) voiceCall;

@end
