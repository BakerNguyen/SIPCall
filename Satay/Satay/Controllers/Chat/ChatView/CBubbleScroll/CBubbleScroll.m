//
//  CBubbleScroll.m
//  JuzChatV2
//
//  Created by TrungVN on 8/5/13.
//  Copyright (c) 2013 mTouche. All rights reserved.
//
#import "CBubbleScroll.h"
#import "ChatView.h"
@implementation CBubbleScroll

@synthesize bottomDisplay, btnLoadMore, willScrollDown, popupisShowing;

-(void) willMoveToSuperview:(UIView *)newSuperview{
    self.delegate = self;
    [self addGestureRecognizer:
        [[UITapGestureRecognizer alloc] initWithTarget:self
                                                action:@selector(handleTap:)]];
}

-(void) scrollToBottom{
    [UIView animateWithDuration:0.1
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{ [self scrollRectToVisible:CGRectMake(1, self.contentSize.height-1, 1, 1) animated:NO]; }
                     completion:nil];
}

-(void) scrollToTop{
    [self scrollRectToVisible:CGRectMake(1, 1, 1, 1) animated:TRUE];
}

-(void) addCell:(CBubbleCell *)cell{
    cell.frame = CGRectMake(cell.x, bottomDisplay, cell.width, cell.height);
    bottomDisplay = bottomDisplay + cell.height;
    self.contentSize = CGSizeMake(self.width, bottomDisplay);
    
    [self addSubview:cell];
    if (self.willScrollDown) {
        [self scrollToBottom];
    }
}

-(CBubbleCell *) cellWithID:(NSString *) cellID{
    NSArray *subviews = [self subviews];
    for (id subview in subviews)
    {
        if([subview isKindOfClass:[CBubbleCell class]])
        {
            CBubbleCell *cell = (CBubbleCell *)subview;
            if([cell.cellID isEqualToString:cellID]){
                return cell;
            }
        }
    }
    return nil;
}

-(void) hidePopup{
    for(UIView* view in [self subviews]){
        if(view.tag == POPUP_TAG){
            [view removeFromSuperview];
            popupisShowing = FALSE;
            break;
        }
    }
}

-(void)handleTap:(id)sender{
    UITapGestureRecognizer* gesture = (UITapGestureRecognizer*)sender;
    CGPoint point = [gesture locationInView:self];
    
    for(UIView* view in self.subviews){
        if (![view isKindOfClass:[CBubbleCell class]])
            continue;
        
        // Find buble cell recieve tap
        if([view isPoint:point inView:view]){
            [((CBubbleCell *)view) handleTap:gesture];
            return;
        }
    }
    
    // No buble cell tap, hide keyboard
    [[ChatView share].chatfield hideKeyboard];
}

@end
