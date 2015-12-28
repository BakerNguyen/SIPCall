//
//  Tutorial.m
//  JuzChatV2
//
//  Created by TrungVN on 10/7/13.
//  Copyright (c) 2013 mTouche. All rights reserved.
//
#import "Tutorial.h"
#import "CWindow.h"

@interface Tutorial ()
@end
@implementation Tutorial

@synthesize tutScroll, pageControl, btnStart;


- (void)viewDidLoad
{
    [super viewDidLoad];
    [pageControl setNumberOfPages:3];
    [pageControl setCurrentPage:0];
     pageControl.hidden = YES;
     btnStart.hidden = NO;
    [btnStart setTitleColor:[UIColor colorWithRed:30/255.0f green:107/255.0f blue:180/255.0f alpha:1] forState:UIControlStateSelected];
    [[self navigationController] setNavigationBarHidden:YES];
    
    NSString* suffix = @"";
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        CGSize result = [[UIScreen mainScreen] bounds].size;
        if(result.height == 480)
        {
            suffix = @"_4";
        }
        if(result.height == 568)
        {
            // iPhone 5
            suffix = @"_5";
        }
        if (result.height==667)
        {
            suffix= @"_5";
        }
        if (result.height==736)
        {
            suffix= @"_5";
        }
        [tutScroll changeWidth:tutScroll.width Height:result.height];
        [tutScroll setContentSize:CGSizeMake(tutScroll.frame.size.width*4, tutScroll.frame.size.height)];
    }
    
    for(int index  = 1; index <= 4; index++){
        NSString* imgName = [NSString stringWithFormat:@"gs_0%d%@.png", index, suffix];
        
        NSLog(@"%@", imgName);
        UIImageView* imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imgName]];
        [imgView changeWidth:tutScroll.width Height:tutScroll.height];
        [tutScroll addSubview:imgView];
        [imgView changeXAxis:(index-1)*320 YAxis:0];
    }
    //Set account status is pending
    [[ContactFacade share] setAccountStatusPending];

}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[self navigationController] navigationBar].hidden = TRUE;
    [[UIApplication sharedApplication] setStatusBarHidden:TRUE];
}

-(void) viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [[self navigationController] navigationBar].hidden = FALSE;
    [[UIApplication sharedApplication] setStatusBarHidden:FALSE];
}

+(Tutorial *)share{
    static dispatch_once_t once;
    static Tutorial * share;
    dispatch_once(&once, ^{
        share = [self new];
    });
    return share;
}

-(void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    int page = scrollView.contentOffset.x /scrollView.frame.size.width;
    NSLog(@"page %d", page);
    [pageControl setCurrentPage:page];
}

-(IBAction)startJuzChat:(id)sender{
    int page = tutScroll.contentOffset.x /tutScroll.frame.size.width;
    
    if (page == 3) {
        NSLog(@"Done button clicked");
        [[ContactFacade share] getStartedAccount];
    }else{
        [tutScroll setContentOffset:CGPointMake(tutScroll.frame.size.width*(page+1), tutScroll.frame.origin.y)];
    }
    
    [pageControl setCurrentPage:page+1];
     NSLog(@"Current Page %d", page+1);
}


@end
