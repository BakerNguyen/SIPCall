//
//  InAppPurchase.m
//  Satay
//
//  Created by enclave on 1/27/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import "InAppPurchase.h"
#import "InAppPurchaseCell.h"


@interface InAppPurchase ()
{
    UIRefreshControl *refreshControl;
    NSNumberFormatter * _priceFormatter;
    BOOL isCallSuccess;
}
@end

@implementation InAppPurchase
@synthesize  InAppPurchaseList,InAppPurchase_PriceList,tbl_InAppPurchase;

- (void)viewDidLoad
{
    isCallSuccess = NO;
    [super viewDidLoad];
    [self.navigationItem setHidesBackButton:YES];
    
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem createRightButtonTitle:_CLOSE Target:self Action:@selector(closeView)];
    
    self.navigationItem.title = TITLE_IN_APP_PURCHASE;
    
    self.tbl_InAppPurchase.dataSource = self;
    self.tbl_InAppPurchase.delegate = self;
    //InAppPurchaseList = [[NSMutableArray alloc] initWithArray:@[@"3 Months",@"6 Months",@"12 Months",@"Life Time"]];
    InAppPurchase_PriceList = [[NSMutableArray alloc] initWithArray:@[@"RM30",@"RM55",@"RM100",@"RM500"]];
    
    //Call retrieveProduct
    
    _priceFormatter = [[NSNumberFormatter alloc] init];
    [_priceFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [_priceFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    

    
}

- (void)reloadIAPTable {

    InAppPurchaseList = nil;
    [tbl_InAppPurchase reloadData];
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];

}

- (void)productPurchased_refresh:(NSNotification *)notification {
   // NSString * productIdentifier = notification.object;

    
}

-(void)closeView
{
   [self.navigationController popViewControllerAnimated:YES];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
	return 1;
}

-(void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([indexPath row] == ([InAppPurchaseList count]-1)){
        //end of loading

    }
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [InAppPurchaseList count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellID =  @"InAppPurchaseCell";
	InAppPurchaseCell *cell = [tbl_InAppPurchase dequeueReusableCellWithIdentifier:cellID];
    if(!tbl_InAppPurchase)
        return cell;
    
    if(!cell){
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"InAppPurchaseCell" owner:nil options:nil];
    	cell = (InAppPurchaseCell*)[nib objectAtIndex:0];
    }
    
    
    return cell;
}
//-(void)InAppPurchaseButtonAction:(SKProduct*)product
//{
//    
//}


- (IBAction)restoreIAP:(id)sender {
    //[[IAPManager share] restoreCompletedTransactions];
    
    //NSURL *receiptURL = [[NSBundle mainBundle] appStoreReceiptURL];
    //NSData *receipt = [NSData dataWithContentsOfURL:receiptURL];
}

#pragma mark SKRequestDelegate methods

//- (void)requestDidFinish:(SKRequest *)request {
//    
//}
//
//- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
//
//    
//}




+(InAppPurchase *)share{
    static dispatch_once_t once;
    static InAppPurchase * share;
    dispatch_once(&once, ^{
        share = [self new];
    });
    return share;
}

@end
