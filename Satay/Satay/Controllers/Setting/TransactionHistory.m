//
//  TransactionHistory.m
//  Satay
//
//  Created by Juriaan on 7/14/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import "TransactionHistory.h"
#import "TransactionViewCell.h"
@interface TransactionHistory (){
    CGFloat screenWidth;
    CGFloat screenHeight;
}

@end

@implementation TransactionHistory
@synthesize tbTransactionHistory,arrayOfTransactionHistory,lbNoTransactionHistory;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    tbTransactionHistory.delegate = self;
    tbTransactionHistory.dataSource = self;
    self.navigationItem.leftBarButtonItem=[UIBarButtonItem createLeftButtonTitle:_BACK
                                                                          Target:self
                                                                    Action:@selector(backToAccount)];
    self.title = _TRANSACTION;
    screenWidth  = [UIScreen mainScreen].bounds.size.width;
    screenHeight = [UIScreen mainScreen].bounds.size.height;
    self.tbTransactionHistory.contentSize = CGSizeMake(screenWidth, screenHeight);
    [self.tbTransactionHistory setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    tbTransactionHistory.backgroundColor = [UIColor clearColor];
    tbTransactionHistory.tableFooterView.backgroundColor =[UIColor clearColor];
    self.view.backgroundColor = COLOR_247247247;
    [tbTransactionHistory changeWidth:screenWidth Height:screenHeight - self.navigationController.navigationBar.frame.size.height];
}

- (void)viewWillAppear:(BOOL)animated{
    if (arrayOfTransactionHistory.count == 0 || arrayOfTransactionHistory == nil) {
        lbNoTransactionHistory.hidden = NO;
        tbTransactionHistory.hidden= YES;
    }
    else{
        lbNoTransactionHistory.hidden = YES;
        tbTransactionHistory.hidden= NO;
    }
}
- (void)backToAccount{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellID = @"TransactionViewCell";
    TransactionViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (!cell)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:cellID owner:self options:nil];
        cell = (TransactionViewCell*)[nib objectAtIndex:0];
    }
    NSDictionary* dictionOfSection = arrayOfTransactionHistory[indexPath.row];
    cell.lbTransactionDate.text = dictionOfSection[kTRANSACTION_DATE];
    cell.lbService.text = dictionOfSection[kSERVICE_SECTION];
    cell.lbTransactionMethod.text = dictionOfSection[kTRANSACTION_METHOD];
    cell.lbAmount.text = dictionOfSection[kAMOUNT];
    cell.lbStatus.text = dictionOfSection[KSTATUS_SECTION];
    return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 271.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return arrayOfTransactionHistory.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 70.0f;
}


+(TransactionHistory *)share{
    static dispatch_once_t once;
    static TransactionHistory * share;
    dispatch_once(&once, ^{
        share = [self new];
    });
    return share;
}
@end
