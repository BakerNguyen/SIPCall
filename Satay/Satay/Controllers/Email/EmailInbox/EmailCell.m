//
//  EmailCell.m
//  Satay
//
//  Created by Arpana Sakpal on 3/10/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import "EmailCell.h"

@implementation EmailCell
@synthesize imgAttachment;
@synthesize lblDate,lblFrom,lblDescription,lblSubject;
@synthesize btnLoadMore;

- (void)prepareForReuse
{
    self.lblFrom.text = nil;
    self.lblSubject.text = nil;
    self.lblDescription.text = nil;
    self.imgAttachment.image = nil;
    self.lblDate.text = nil;
    
    self.btnLoadMore.hidden = YES;
    
    [self.btnLoadMore setTitleColor: [UIColor blackColor]
                              forState:UIControlStateNormal];
    [self.btnLoadMore setBackgroundImage:[UIImage imageFromColor:[UIColor whiteColor]]
                                   forState:UIControlStateNormal];
    
    [self.btnLoadMore setTitleColor:[UIColor whiteColor]
                              forState:UIControlStateHighlighted];
    [self.btnLoadMore setBackgroundImage:[UIImage imageFromColor:[UIColor blackColor]]
                                   forState:UIControlStateHighlighted];
    
    [self.btnLoadMore setTitleColor:[UIColor whiteColor]
                              forState:UIControlStateSelected];
    [self.btnLoadMore setBackgroundImage:[UIImage imageFromColor:[UIColor blackColor]]
                                   forState:UIControlStateSelected];
    
    
}

@end
