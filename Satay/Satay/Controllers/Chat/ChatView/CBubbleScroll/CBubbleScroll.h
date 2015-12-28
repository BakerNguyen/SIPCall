//
//  CBubbleScroll.h
//  JuzChatV2
//
//  Created by TrungVN on 8/5/13.
//  Copyright (c) 2013 mTouche. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "CBubbleCell.h"
#define POPUP_TAG 9999

@interface CBubbleScroll : UIScrollView <UIScrollViewDelegate>

-(void) addCell: (CBubbleCell*) cell;
-(void) scrollToBottom;
-(void) scrollToTop;
-(void) hidePopup;
-(CBubbleCell *) cellWithID:(NSString *) cellID;

@property (nonatomic, strong) IBOutlet UIButton* btnLoadMore;
@property BOOL popupisShowing;
@property BOOL willScrollDown;
@property CGFloat bottomDisplay;

@end
