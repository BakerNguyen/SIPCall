//
//  CView.h
//  Satay
//
//  Created by TrungVN on 1/19/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Customize)

-(void) changeXAxis:(CGFloat)xAxis
              YAxis:(CGFloat)yAxis;
-(void) changeWidth:(CGFloat) width
             Height:(CGFloat)height;
-(void) animateXAxis:(CGFloat)xAxis
               YAxis:(CGFloat)yAxis;
-(void) animateWidth:(CGFloat) width
              Height:(CGFloat)height;

- (CGFloat) rightEdge;
- (CGFloat) bottomEdge;

- (CGFloat) height;
- (CGFloat) width;
- (CGFloat) x;
- (CGFloat) y;

-(BOOL)isPoint:(CGPoint) point inView:(UIView *)view;

@end
