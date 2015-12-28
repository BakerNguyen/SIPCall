//
//  InboxNavigationView.m
//
//  Created by Parker on 4/16/15.
//

#import "InboxNavigationView.h"

@implementation InboxNavigationView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

+ (instancetype)newView
{
    InboxNavigationView *view = [[[NSBundle mainBundle] loadNibNamed:@"InboxNavigationView" owner:nil options:nil] lastObject];
    
    if ([view isKindOfClass:[InboxNavigationView class]]) {
        view.lblFolderName.text = nil;
        view.lblEmailAddress.text = nil;
        return view;
    }
    
    return nil;
}

- (void)initilize
{
    
    // Add some more 
}
@end
