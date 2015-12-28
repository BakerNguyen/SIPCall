//
//  NewRequest.h
//  KryptoChat
//
//  Created by TrungVN on 4/17/14.
//  Copyright (c) 2014 mTouche. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContactRequest : UIViewController<UITableViewDelegate,UITableViewDataSource, ContactRequestDelegate>

@property (nonatomic, retain) IBOutlet UITableView* tblNewRequestList;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingSpinner;
@property (nonatomic, retain) NSMutableArray* arrNewRequest;

+(ContactRequest *)share;
-(void) displayRequest:(NSArray*) arrRequest;
-(void) backViewWhenNoRequest;

@end
