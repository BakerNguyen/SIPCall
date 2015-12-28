//
//  ImageCell.h
//  JuzChatV2
//
//  Created by TrungVN on 8/9/13.
//  Copyright (c) 2013 mTouche. All rights reserved.
//
#import <UIKit/UIKit.h>

@interface ImageCell : UIButton

@property (nonatomic, strong) NSString* cellID;
-(void) initImageCell:(NSString*) messageId;
-(IBAction) clickImage:(id) sender;

@end
