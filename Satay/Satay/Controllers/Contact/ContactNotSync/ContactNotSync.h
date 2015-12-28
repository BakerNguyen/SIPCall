//
//  NotSyncView.h
//  KryptoChat
//
//  Created by TrungVN on 5/29/14.
//  Copyright (c) 2014 mTouche. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContactNotSync : UIViewController
{
    UIColor *hintTextColor;
}

-(void) tapSearch;
-(void) tapSyncPhone;

@property (nonatomic, retain) IBOutlet UIView* searchView;
@property (nonatomic, retain) IBOutlet UIView* syncView;
@property (nonatomic, retain) IBOutlet UILabel* contentCell;
@property (nonatomic, retain) IBOutlet UILabel* labelCell;
@property (nonatomic, retain) IBOutlet UILabel* labelPrivateContact;

+(ContactNotSync *)share;

@end
