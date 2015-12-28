//
//  ViewEmailAttachment.m
//  Satay
//
//  Created by Arpana Sakpal on 3/18/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import "ViewEmailAttachment.h"

@interface ViewEmailAttachment ()
{
    NSString *filePath;
}
@end

@implementation ViewEmailAttachment
@synthesize webViewattachment;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem=[UIBarButtonItem createLeftButtonTitle:_BACK Target:self Action:@selector(backToViewEmailDetail)];
    self.navigationItem.title = self.fileName;
    
    webViewattachment.delegate = self;
    
    NSData *attachmentData ;
    attachmentData = [[EmailFacade share] getAttachmentDataWithFileName:self.fileName];
    
    self.imgViewAttach.contentMode = UIViewContentModeScaleAspectFit;
 
    if (attachmentData.length >= MAX_FILE_SIZE_ATTACHMENT)
    {
        CAlertView *alertView = [CAlertView new];
        NSMutableArray *buttonsName  = [NSMutableArray arrayWithObjects:[_YES capitalizedString] , [_NO capitalizedString], nil];
        [alertView showInfo_2btn:mWarning_OutOfMemoryCanNotOpenThisMedia ButtonsName:buttonsName];
        [alertView setOnButtonTouchUpInside:^(CAlertView *alertView, int buttonIndex) {
            if(buttonIndex == 0) //yes
            {
                //Save
                UIImage *saveImage = [[UIImage alloc] initWithData:attachmentData];
                UIImageWriteToSavedPhotosAlbum(saveImage, nil, nil, nil);
                [self.navigationController popViewControllerAnimated:YES];
            }
            else
            {
                //Back to ViewEmailDetail
                [self.navigationController popViewControllerAnimated:YES];
            }
            
        }];
    }
    else
    {
        if (!attachmentData)
            [[CAlertView new] showInfo:NSLocalizedString(mError_CanNotDecrypt, nil)];
        else
        {
            //Display attachment
            UIImage *imageAttach = [[UIImage alloc] initWithData:attachmentData];
            if (imageAttach != nil)
            {
                self.imgViewAttach.image = imageAttach;
                self.imgViewAttach.hidden = NO;
                self.webViewattachment.hidden = YES;
                self.scrollView.contentSize = self.webViewattachment.bounds.size;
                self.scrollView.delegate = self;
                self.scrollView.maximumZoomScale = 100.0;
            }
            else
            {
                self.imgViewAttach.hidden = YES;
                self.webViewattachment.hidden = NO;

                NSArray *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString *docDirectory = [documentPath objectAtIndex:0];
                filePath = [docDirectory stringByAppendingPathComponent:self.fileName];
                NSURL *url = [NSURL fileURLWithPath:filePath];
                [attachmentData writeToFile:filePath atomically:YES];
                NSURLRequest *request = [NSURLRequest requestWithURL:url];
                [webViewattachment loadRequest:request];
            }
        }
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    CGPoint centerPoint = CGPointMake(CGRectGetMidX(self.scrollView.bounds),
                                      CGRectGetMidY(self.scrollView.bounds));
    [self view:self.imgViewAttach setCenter:centerPoint];
}

- (void)viewDidDisappear:(BOOL)animated
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:filePath error:nil];
}

- (void)backToViewEmailDetail
{
    self.attachmentDecryptedData = nil;
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    CGSize contentSize = self.webViewattachment.scrollView.contentSize;
    CGSize viewSize = self.view.bounds.size;
    float sfactor = viewSize.width / contentSize.width;
    
    self.webViewattachment.scrollView.minimumZoomScale = sfactor;
    self.webViewattachment.scrollView.maximumZoomScale = sfactor;
    self.webViewattachment.scrollView.zoomScale = sfactor;
    self.webViewattachment.scrollView.contentOffset = CGPointMake(0, 0);
    self.webViewattachment.scrollView.scrollEnabled = NO;
    self.webViewattachment.scalesPageToFit = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)view:(UIView*)view setCenter:(CGPoint)centerPoint
{
    CGRect vf = view.frame;
    CGPoint co = self.scrollView.contentOffset;
    
    CGFloat x = centerPoint.x - vf.size.width / 2.0;
    CGFloat y = centerPoint.y - vf.size.height / 2.0;
    
    if(x < 0)
    {
        co.x = -x;
        vf.origin.x = 0.0;
    }
    else
    {
        vf.origin.x = x;
    }
    if(y < 0)
    {
        co.y = -y;
        vf.origin.y = 0.0;
    }
    else
    {
        vf.origin.y = y;
    }
    
    view.frame = vf;
    self.scrollView.contentOffset = co;
}

// MARK: - UIScrollViewDelegate
- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return  self.imgViewAttach;
}

- (void)scrollViewDidZoom:(UIScrollView *)sv
{
    UIView* zoomView = [sv.delegate viewForZoomingInScrollView:sv];
    CGRect zvf = zoomView.frame;
    if(zvf.size.width < sv.bounds.size.width)
    {
        zvf.origin.x = (sv.bounds.size.width - zvf.size.width) / 2.0;
    }
    else
    {
        zvf.origin.x = 0.0;
    }
    if(zvf.size.height < sv.bounds.size.height)
    {
        zvf.origin.y = (sv.bounds.size.height - zvf.size.height) / 2.0;
    }
    else
    {
        zvf.origin.y = 0.0;
    }
    zoomView.frame = zvf;
}


@end
