//
//  Payment_Other.m
//  Satay
//
//  Created by enclave on 1/27/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import "Payment_Other.h"

@interface Payment_Other ()

@end

@implementation Payment_Other
@synthesize webView;



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    UIActivityIndicatorView *loadingview = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    loadingview.layer.backgroundColor = [[UIColor colorWithWhite:0.0f alpha:0.5f] CGColor];
    loadingview.hidesWhenStopped = YES;
    loadingview.frame = CGRectMake(0.0f, 0.0f,
                                   [UIScreen mainScreen].bounds.size.width,
                                   [UIScreen mainScreen].bounds.size.height);
    [self.view addSubview:loadingview];
    [loadingview startAnimating];
    
//    NSData *notesData = [[NSUserDefaults standardUserDefaults] objectForKey:ACCOUNT_DETAILS_IDENTITY_PATH_KEY];
//    AccountDO  *accountDO = [NSKeyedUnarchiver unarchiveObjectWithData:notesData];
//    
//    NSString *fullURL = accountDO.URL;
//    NSURL *url = [NSURL URLWithString:fullURL];
//    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
//    [webView loadRequest:requestObj];
    
     [loadingview stopAnimating];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

+(Payment_Other *)share{
    static dispatch_once_t once;
    static Payment_Other * share;
    dispatch_once(&once, ^{
        share = [self new];
    });
    return share;
}
@end
