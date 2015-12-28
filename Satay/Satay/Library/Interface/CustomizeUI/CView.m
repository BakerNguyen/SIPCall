//
//  CView.m
//  Satay
//
//  Created by TrungVN on 1/19/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import "CView.h"

@implementation UIView (Customize)

-(void) changeXAxis:(CGFloat)xAxis
              YAxis:(CGFloat)yAxis{
    CGRect frame = self.frame;
    frame.origin.x = xAxis;
    frame.origin.y = yAxis;
    self.frame = frame;
}

-(void) changeWidth:(CGFloat) width
             Height:(CGFloat)height{
    CGRect frame = self.frame;
    frame.size.width = width;
    frame.size.height = height;
    self.frame = frame;
}

-(void) animateXAxis:(CGFloat)xAxis
               YAxis:(CGFloat)yAxis{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.25];
    CGRect frame = self.frame;
    frame.origin.x = xAxis;
    frame.origin.y = yAxis;
    self.frame = frame;
    [UIView commitAnimations];
}

-(void) animateWidth:(CGFloat) width
              Height:(CGFloat)height {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.25];
    CGRect frame = self.frame;
    frame.size.width = width;
    frame.size.height = height;
    self.frame = frame;
    [UIView commitAnimations];
}

- (CGFloat) rightEdge{
    return (self.frame.origin.x + self.frame.size.width);
}
- (CGFloat) bottomEdge{
    return (self.frame.origin.y + self.frame.size.height);
}

- (CGFloat) height{
    return self.frame.size.height;
}

- (CGFloat) width{
    return self.frame.size.width;
}

- (CGFloat) x{
    return self.frame.origin.x;
}

- (CGFloat) y{
    return self.frame.origin.y;
}

-(BOOL)isPoint:(CGPoint) point inView:(UIView *)view
{
    CGRect relativeFrame = view.frame;
    return CGRectContainsPoint (relativeFrame, point);
}

@end
