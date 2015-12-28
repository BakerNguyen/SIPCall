//
//  ChatView.h
//  JuzChatV2
//
//  Created by TrungVN on 7/29/13.
//  Copyright (c) 2013 mTouche. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

#import "ChatFieldMenu.h"
#import "CBubbleScroll.h"
#import "MoreKeyboard.h"
#import "NaviTitle.h"
#import "NotifyChatView.h"
#import "AudioRecorder.h"
#import "SelfTimer.h"
#import "ContactInfo.h"

#define MESSAGE_TAG_MOVED 88
#define MESSAGE_TAG -999
#define MESSAGE_DATE_TAG -1000

@interface ChatView : UIViewController
<UINavigationBarDelegate,
UIImagePickerControllerDelegate,
UIActionSheetDelegate,
ChatViewDelegate,
MWPhotoBrowserDelegate>

@property (nonatomic, retain) IBOutlet NaviTitle* naviTitle;
@property (nonatomic, retain) IBOutlet ChatFieldMenu* chatfield;
@property (nonatomic, retain) IBOutlet CBubbleScroll* bubbleScroll;
@property (nonatomic, retain) IBOutlet MoreKeyboard* moreKeyboard;
@property (nonatomic, retain) IBOutlet NotifyChatView* notifyChat;
@property (nonatomic, retain) IBOutlet AudioRecorder* audioRecorder;
@property (nonatomic, retain) IBOutlet UIButton* btnPlayMedia;
@property (nonatomic, strong) UIPopoverController *popoverController;
@property (nonatomic, retain) NSMutableArray* arrDate;
@property (nonatomic, strong) MWPhotoBrowser *mwPhotoBrowser;
@property (nonatomic) BOOL isGridShowing;

@property NSInteger pageHistory;
@property (nonatomic, retain) NSMutableArray* mediaArray;
@property (nonatomic, retain) NSMutableArray* arrMessage;
@property (nonatomic, retain) NSString* chatBoxID;
@property (nonatomic, retain) UINib* cellNib;
@property (nonatomic, retain) AudioCell* currentAudioPlaying;
@property (nonatomic, retain) NSString* tempVideoURL;
@property (nonatomic, retain) MPMoviePlayerViewController* mediaPlayer;

+ (ChatView *)share;
-(void) showTimer;

-(void) showChatSetting;
-(void) backView;
-(void) resetContent;
-(void) buildContent;
-(void) displayName;
-(void) displayStatus;
-(void) displaySingleStatus;
-(void) displayGroupStatus;
-(void) checkDisplayBlueAlert;
-(void) addMessage:(NSString *)messageId;
-(void) updateStatus:(NSString*) messageId;
-(void) updateState:(NSString*) messageId;
-(void) updateCell:(NSString*) messageId;
-(void) showCellLoading:(NSString*) messageId
               progress:(CGFloat) progress;
-(void) hideCellLoading:(NSString*) messageId;

-(void) showAlertBlocked;
-(void) displayPhotoBrower:(NSMutableArray*) photoArray
                photoIndex:(NSInteger) photoIndex
              showGridView:(BOOL)showGridView;

-(void) showButtonRetry:(NSString*) messageId;
-(void) hideButtonRetry:(NSString*) messageId;

-(IBAction) loadContent:(id)sender;
-(IBAction) playMedia:(id)sender;
-(void) handleSingleChatState:(NSDictionary *)userInfo;

-(void) stopAudioPlaying:(NSString*) messageID;

-(void) addKVO;
-(void) removeKVO;

@end
