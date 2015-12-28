//
//  ViewEmailAttachment.h
//  Satay
//
//  Created by Arpana Sakpal on 3/18/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewEmailAttachment : UIViewController <UIWebViewDelegate, UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webViewattachment;

@property (strong, nonatomic) IBOutlet UIImageView *imgViewAttach;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) NSString *fileName;

@property BOOL isEncypted;
@property (strong, nonatomic) NSData *attachmentDecryptedData;

@end
