//
//  CPopup.h
//  JuzChatV2
//
//  Created by TrungVN on 8/13/13.
//  Copyright (c) 2013 mTouche. All rights reserved.
//
#import <UIKit/UIKit.h>

@interface CPopup : UIView

@property (nonatomic, strong) IBOutlet UIImageView* arrowDown;
@property (nonatomic, strong) IBOutlet UIView* viewButton;
@property (nonatomic, strong) IBOutlet UIButton* btnCopy;
@property (nonatomic, strong) IBOutlet UIButton* btnDelete;
@property (nonatomic, strong) IBOutlet UIButton* btnForward;
@property (nonatomic, strong) Message* message;

-(IBAction) copyAction:(id)sender;
-(IBAction) deleteAction:(id)sender;
-(IBAction) forwardAction:(id)sender;
-(IBAction) saveAction:(id)sender;

-(void) showCopyButton;
-(void) showSaveButton;
-(void) hideSaveButton;
-(void) hideForwardButton;

@end
