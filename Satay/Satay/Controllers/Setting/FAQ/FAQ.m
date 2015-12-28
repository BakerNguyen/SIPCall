//
//  FAQ.m
//  KryptoChat
//
//  Created by Juriaan on 4/15/15.
//  Copyright (c) 2015 mTouche. All rights reserved.
//

#import "FAQ.h"
#define isEmptyString(string) [[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""] || !string
#define str_replace(find,replace,string) [string stringByReplacingOccurrencesOfString:find withString:replace];
#define split(string,separator) [string componentsSeparatedByString:separator]
#define URL_FAQ_LINK @"http://www.onekrypto.com/faq.html?mode=mobile"

@interface FAQ (){
    UIWebView* loadingDataWebView;
}

@end

@implementation FAQ
@synthesize faqWebView;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    loadingDataWebView = [[UIWebView alloc]init];
    
    UIButton* btnBack = [[UIButton alloc] initWithFrame:CGRectMake(10, 0, 50, 40)];
    [btnBack addTarget:self action:@selector(backclick:) forControlEvents:UIControlEventTouchUpInside];
    [btnBack setTitle:_BACK forState:UIControlStateNormal];
    [btnBack.titleLabel setFont:[UIFont systemFontOfSize:15]];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btnBack];
    loadingDataWebView.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    
    if([[NotificationFacade share] isInternetConnected]){
        self.navigationItem.title = LABEL_FAQ;
        [super viewWillAppear:animated];
        
        NSString* isHeaderLoaded = [loadingDataWebView stringByEvaluatingJavaScriptFromString:@"document.head.innerHTML"];
        if (isEmptyString(isHeaderLoaded)) {
            [[CWindow share] showLoading:kLOADING_LOADING];
        }
        
        NSURL* nsUrl = [NSURL URLWithString:URL_FAQ_LINK];
        NSURLRequest* request = [NSURLRequest requestWithURL:nsUrl
                                                 cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                             timeoutInterval:30];
        [loadingDataWebView loadRequest:request];
    }
    else{
        [[CAlertView new] showError:NO_INTERNET_CONNECTION_TRY_LATER];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    
    [[CWindow share] hideLoading];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) webViewDidFinishLoad:(UIWebView *)webView{
    // checking is content is same
    NSString *currentbody = [faqWebView stringByEvaluatingJavaScriptFromString:@"document.getElementById(\"accordion\").innerHTML"];
    NSString *loadBody = [loadingDataWebView stringByEvaluatingJavaScriptFromString:@"document.getElementById(\"accordion\").innerHTML"];
    BOOL isCurrentDisplayHTMLSame = [loadBody isEqual:currentbody];
    if (!isCurrentDisplayHTMLSame) {
        [self loadFAQwithModiftyContent];
    }

    
}
/*
 * Load FAQ content and remodify for display in native page 
 * Reload FAQ web have new content.
 */
- (void)loadFAQwithModiftyContent{
    
    NSArray * scriptLink = split([loadingDataWebView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML"], @"<!-- JavaScript -->");
    NSString *body = scriptLink[0];
    NSString *head = [@"" stringByAppendingString:@"<head>"];
    head = [head stringByAppendingString:[loadingDataWebView stringByEvaluatingJavaScriptFromString:@"document.head.innerHTML"]];
    head = [head stringByAppendingString:@"</head>"];
    
    NSString* scriptLinkString = scriptLink[1];
    scriptLinkString = str_replace(@"js/jquery-1.10.2.js", @"http://www.onekrypto.com/js/jquery-1.10.2.js", scriptLinkString);
    scriptLinkString = str_replace(@"bootstrap-3.1.1/js/bootstrap.min.js", @"http://www.onekrypto.com/bootstrap-3.1.1/js/bootstrap.min.js", scriptLinkString);
    scriptLinkString = str_replace(@"modern-business/js/modern-business.js", @"http://www.onekrypto.com/modern-business/js/modern-business.js", scriptLinkString);
    scriptLinkString = str_replace(@"js/custom.js", @"http://www.onekrypto.com/js/custom.js", scriptLinkString);
    
    head = str_replace(@"css/main.css", @"http://www.onekrypto.com/css/main.css",head);
    head = str_replace(@"css/style.css", @"http://www.onekrypto.com/css/style.css",head);
    head = str_replace(@"modern-business/css/", @"http://www.onekrypto.com/modern-business/css/",head);
    head = str_replace(@"modern-business/font-awesome", @"http://www.onekrypto.com/modern-business/font-awesome",head);
    head = str_replace(@"bootstrap-3.1.1", @"http://www.onekrypto.com/bootstrap-3.1.1",head);
    head = [head stringByAppendingString:body];
    head = [head stringByAppendingString:scriptLinkString];

    [[CWindow share] hideLoading];
    [faqWebView loadHTMLString:head baseURL:nil];
    
}

- (IBAction)backclick:(id)sender {
    [[self navigationController] popViewControllerAnimated:YES];
    
}

+(FAQ *)share{
    static dispatch_once_t once;
    static FAQ * share;
    dispatch_once(&once, ^{
        share = [self new];
    });
    return share;
}

@end
