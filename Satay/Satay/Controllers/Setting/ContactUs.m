//
//  ContactUs.m
//  Satay
//
//  Created by Juriaan on 7/20/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import "ContactUs.h"
#import <QuartzCore/QuartzCore.h>
static NSString* _CALLNO1  = @"1111";
static NSString* _CALLNO2  = @"1300 111 000";
static NSString* _CALLNO3  = @"603 36308888";
@interface ContactUs ()

@end

@implementation ContactUs
@synthesize lbContent,lbContentNo2,lbContentNo3,lbcontentNo4,btnCallNo1,btnCallNo2,btnCallNo3,btnWriteUs,scrollContactUs;
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = LABEL_CONTACT_US;
    self.navigationItem.leftBarButtonItem=[UIBarButtonItem createLeftButtonTitle:_BACK
                                                                          Target:self
                                                                          Action:@selector(backToAccount)];
    screenWidth  = [UIScreen mainScreen].bounds.size.width;
    screenHeight = [UIScreen mainScreen].bounds.size.height;
    // Do any additional setup after loading the view from its nib.
    [btnCallNo1 setTitle:[_CALL stringByAppendingString:_CALLNO1] forState:UIControlStateNormal];
    [btnCallNo2 setTitle:[_CALL stringByAppendingString:_CALLNO2] forState:UIControlStateNormal];
    [btnCallNo3 setTitle:[_CALL stringByAppendingString:_CALLNO3] forState:UIControlStateNormal];
    [btnWriteUs setTitle:_WRITEUS forState:UIControlStateNormal];
   
    lbContent.text     = CONTEXT_NO1;
    lbContentNo2.text  = CONTEXT_NO2;
    lbContentNo3.text  = CONTEXT_NO3;
    lbcontentNo4.text  = CONTEXT_NO4;
    self.view.backgroundColor = COLOR_247247247;
    btnCallNo1.layer.borderColor = btnCallNo2.layer.borderColor = btnCallNo3.layer.borderColor= [COLOR_48147213 CGColor];
    scrollContactUs.contentSize = CGSizeMake(screenWidth, screenHeight);
}

-(void)viewWillAppear:(BOOL)animated{
    btnCallNo1.layer.borderColor = [UIColor blackColor].CGColor;
    btnCallNo2.layer.borderColor = [UIColor blackColor].CGColor;
    btnCallNo3.layer.borderColor = [UIColor blackColor].CGColor;
    btnWriteUs.layer.borderColor = COLOR_24317741.CGColor;
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)backToAccount{
    [self.navigationController popViewControllerAnimated:YES];
}

+(ContactUs *)share
{
    static dispatch_once_t once;
    static ContactUs * share;
    dispatch_once(&once, ^{
        share = [[self alloc] init];
    });
    return share;
}
- (IBAction)btnCallNo1_click:(id)sender {
    NSMutableArray *buttonsName  = [NSMutableArray arrayWithObjects:_CANCEL,_OK, nil];
    
    CAlertView* alertView = [CAlertView new];
    [alertView showInfo_2btn:btnCallNo1.titleLabel.text ButtonsName:buttonsName];
    [alertView setOnButtonTouchUpInside:^(CAlertView *alertView, int buttonIndex)
     {
         if(buttonIndex ==1){
             [self callPhone:_CALLNO1];
         }
     }];
}

- (IBAction)btnCallNo2_click:(id)sender {
    NSMutableArray *buttonsName  = [NSMutableArray arrayWithObjects:_CANCEL,_OK, nil];
    
    CAlertView* alertView = [CAlertView new];
    [alertView showInfo_2btn:btnCallNo2.titleLabel.text ButtonsName:buttonsName];
    [alertView setOnButtonTouchUpInside:^(CAlertView *alertView, int buttonIndex)
     {
         if(buttonIndex ==1){
             [self callPhone:_CALLNO2];
         }
     }];
}

- (IBAction)btnCallNo3_click:(id)sender {
    NSMutableArray *buttonsName  = [NSMutableArray arrayWithObjects:_CANCEL,_OK, nil];
    
    CAlertView* alertView = [CAlertView new];
    [alertView showInfo_2btn:btnCallNo3.titleLabel.text ButtonsName:buttonsName];
    [alertView setOnButtonTouchUpInside:^(CAlertView *alertView, int buttonIndex)
     {
         if(buttonIndex ==1){
             [self callPhone:_CALLNO3];
         }
     }];
}

- (IBAction)btnWriteUs:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:LINK_WRITEUS]];
}

- (void)callPhone:(NSString*)phNo{
    phNo = [phNo stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSURL *phoneUrl = [NSURL URLWithString:[NSString  stringWithFormat:@"tel://%@",phNo]];
    
    if ([[UIApplication sharedApplication] canOpenURL:phoneUrl]) {
        [[UIApplication sharedApplication] openURL:phoneUrl];
    } else
    {
        [[CAlertView new] showError:ERROR_CANNOT_CALL];
    }
}
@end
