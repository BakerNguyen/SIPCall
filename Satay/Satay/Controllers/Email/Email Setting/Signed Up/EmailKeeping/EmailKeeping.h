//
//  EmailKeeping.h
//  Satay
//
//  Created by Arpana Sakpal on 3/13/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EmailKeeping : UIViewController<UITableViewDelegate, UITableViewDataSource>{
    id parent;
}
@property (strong, nonatomic) IBOutlet UITableView *tblEmailKeeping;
@property (nonatomic,retain) NSIndexPath *checkedIndexPath;
@property (nonatomic, retain) NSMutableArray* allValues;
@property (strong, nonatomic) NSString *emailKeepingStr;

/**
 *  The designated initializer.  Override if you create the controller programmatically 
 *  and want to perform customization that is not appropriate for viewDidLoad.
 *
 *  @param nibNameOrNil   nib name
 *  @param nibBundleOrNil bundle
 *  @param _parent        parent view
 *
 *  @return view controller
 *  @author Arpana
 */
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil parent:(id)_parent;

@end
