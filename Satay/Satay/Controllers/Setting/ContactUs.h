//
//  ContactUs.h
//  Satay
//
//  Created by Juriaan on 7/20/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContactUs : UIViewController{
    CGFloat screenWidth;
    CGFloat screenHeight;
}

+(ContactUs *)share;
@property (strong, nonatomic) IBOutlet UILabel *lbContent;
@property (strong, nonatomic) IBOutlet UIButton *btnCallNo1;
@property (strong, nonatomic) IBOutlet UIButton *btnCallNo2;
@property (strong, nonatomic) IBOutlet UILabel *lbContentNo2;
@property (strong, nonatomic) IBOutlet UIButton *btnCallNo3;
@property (strong, nonatomic) IBOutlet UILabel *lbContentNo3;
@property (strong, nonatomic) IBOutlet UIButton *btnWriteUs;
@property (strong, nonatomic) IBOutlet UILabel *lbcontentNo4;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollContactUs;

- (IBAction)btnCallNo1_click:(id)sender;
- (IBAction)btnCallNo2_click:(id)sender;
- (IBAction)btnCallNo3_click:(id)sender;
- (IBAction)btnWriteUs:(id)sender;

@end
