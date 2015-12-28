//
//  EmailSortBy.h
//  Satay
//
//  Created by Arpana Sakpal on 3/18/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SortByDelegate;

@interface EmailSortBy : UIViewController<UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UITableView *tblSortByEmail;
@property (weak, nonatomic) id<SortByDelegate> delegate;

@property (assign, nonatomic) EmailSortingType sortingType;

@end

@protocol SortByDelegate <NSObject>

@optional
/**
 *  Action change email sorting type in folder
 *
 *  @param sortingType selected sorting type
 *  @author Parker
 *  date 6-Apr-2015
 */
- (void)sortingTypeDidChange:(EmailSortingType)sortingType;

@end