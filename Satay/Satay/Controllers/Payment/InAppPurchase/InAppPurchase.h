//
//  InAppPurchase.h
//  Satay
//
//  Created by enclave on 1/27/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InAppPurchaseCell.h"

@interface InAppPurchase : UIViewController<UITableViewDataSource,UITableViewDelegate,InAppPurchaseButtonActionDelegate>

@property (nonatomic, retain) IBOutlet UITableView *tbl_InAppPurchase;

@property (nonatomic, retain) NSMutableArray *InAppPurchaseList;

@property (nonatomic, retain) NSMutableArray *InAppPurchase_PriceList;

@property BOOL IAPSelected;

- (IBAction)restoreIAP:(id)sender;


+(InAppPurchase *)share;
    
    
@end
