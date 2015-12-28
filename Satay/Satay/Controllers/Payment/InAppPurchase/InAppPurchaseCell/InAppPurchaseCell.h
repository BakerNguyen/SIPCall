//
//  InAppPurchaseCell.h
//  Satay
//
//  Created by enclave on 1/27/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol InAppPurchaseButtonActionDelegate;


@interface InAppPurchaseCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lbl_period;
@property (strong, nonatomic)  UIButton *btn_pricetag;
@property (strong, nonatomic)  NSString *pricetag;
//@property (strong, nonatomic)  SKProduct *product;

@property (nonatomic, retain) id <InAppPurchaseButtonActionDelegate> delegate;


@end

@protocol InAppPurchaseButtonActionDelegate <NSObject>
@required
//- (void)InAppPurchaseButtonAction:(SKProduct*)product;

@end







