//
//  CViewController.m
//  Satay
//
//  Created by TrungVN on 1/15/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import "CViewController.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"

@implementation UIViewController (Customize)

-(void) viewDidLoad{
    if([self respondsToSelector:@selector(edgesForExtendedLayout)]){
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    //self.view.backgroundColor = [UIColor grayColor];
}

#pragma clang diagnostic pop

@end
