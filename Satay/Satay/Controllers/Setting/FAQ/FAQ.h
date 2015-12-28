//
//  FAQ.h
//  KryptoChat
//
//  Created by Juriaan on 4/15/15.
//  Copyright (c) 2015 mTouche. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FAQ : UIViewController <UIWebViewDelegate>
@property (strong, nonatomic) IBOutlet UIWebView *faqWebView;
+(FAQ *)share;
@end
