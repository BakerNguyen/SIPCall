//
//  VideoCell.h
//  JuzChatV2
//
//  Created by TrungVN on 8/9/13.
//  Copyright (c) 2013 mTouche. All rights reserved.
//
#import <UIKit/UIKit.h>

//#import "MessageDO.h"

@interface VideoCell : UIView


//@property (nonatomic, strong) MessageDO* messageContent;
@property (nonatomic, strong) IBOutlet UIButton* btnDisplay;
@property (nonatomic, strong) IBOutlet UIImageView* imgPlay;
@property (nonatomic, strong) NSString *messageID;

-(IBAction) clickVideo:(id) sender;
-(void) initVideoCell:(NSString*) messageId;

@end
