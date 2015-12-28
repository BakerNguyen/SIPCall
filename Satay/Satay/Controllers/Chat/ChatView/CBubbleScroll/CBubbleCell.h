//
//  CBubbleCell.h
//  JuzChatV2
//
//  Created by TrungVN on 8/5/13.
//  Copyright (c) 2013 mTouche. All rights reserved.
//
#import <UIKit/UIKit.h>



#import "ImageCell.h"
#import "AudioCell.h"
#import "VideoCell.h"
#import "LocationCell.h"
#import "NotificationCell.h"
#import "CPopup.h"

#import "CallLogCell.h"

@interface CBubbleCell : UIView <UITextViewDelegate, UIActionSheetDelegate>

@property (nonatomic, strong) IBOutlet UIImageView* bgrImage;
@property (nonatomic, strong) IBOutlet UILabel* lblStatus;
@property (nonatomic, retain) IBOutlet UILabel* lblMessageType;
@property (nonatomic, strong) IBOutlet UITextView* txtMessage;
@property (nonatomic, strong) IBOutlet UILabel* lblDateCell;
@property (nonatomic, retain) IBOutlet UIButton* btnRetry;
@property (nonatomic, strong) IBOutlet UILabel* lblBuddyName;

@property (nonatomic, strong) IBOutlet VideoCell* videoCell;
@property (nonatomic, strong) IBOutlet ImageCell* imageCell;
@property (nonatomic, strong) IBOutlet AudioCell* audioCell;
@property (nonatomic, strong) IBOutlet LocationCell* locationCell;
@property (nonatomic, strong) IBOutlet NotificationCell* notificationCell;
@property (nonatomic, strong) IBOutlet DACircularProgressView* loadingDimView;
@property (nonatomic, strong) IBOutlet CPopup* popupView;
@property (nonatomic, strong) IBOutlet CallLogCell* callLogCell;

#define padding 5
#define widthPercent 260.0/320.0

@property (nonatomic, strong) NSString* cellID;
@property (nonatomic, strong) Message* message;
@property BOOL mineMessage;

-(void) drawCell;
-(void) drawStatus;
-(void) drawBubble;
-(void) drawState;
-(BOOL) drawDateCell:(NSNumber *)date;

-(void) showLoading;
-(void) hideLoading;
-(void) showPopupMenu:(id) sender;

-(IBAction) retrySendMessage;
-(void) handleTap:(UITapGestureRecognizer*)tap;
@end
