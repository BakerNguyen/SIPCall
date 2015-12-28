//

#import "CAlertView.h"
#import <QuartzCore/QuartzCore.h>

const static CGFloat kCustomIOS7AlertViewDefaultButtonHeight       = 50;
const static CGFloat kCustomIOS7AlertViewDefaultButtonSpacerHeight = 1;
const static CGFloat kCustomIOS7AlertViewCornerRadius              = 7;
const static CGFloat kCustomIOS7MotionEffectExtent                 = 10.0;

@implementation CAlertView

CGFloat buttonHeight = 0;
CGFloat buttonSpacerHeight = 0;

@synthesize parentView, containerView, dialogView, buttonView, onButtonTouchUpInside;
@synthesize delegate;
@synthesize buttonTitles;
@synthesize useMotionEffects;

@synthesize lblMessage, lblTitle, imgTitle, separate;

+(instancetype) alloc
{
    id alertView = [super alloc];
    [[NSNotificationCenter defaultCenter] addObserver:alertView
                                             selector:@selector(appDidEnterBackground)
                                                 name:UIApplicationDidEnterBackgroundNotification object:nil];
    return alertView;
}

-(void) appDidEnterBackground
{
    [self close];
}


- (id)initWithParentView: (UIView *)_parentView
{
    self = [self init];
    if (_parentView) {
        self.frame = _parentView.frame;
        self.parentView = _parentView;
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);

        delegate = self;
        useMotionEffects = false;
        buttonTitles = @[@"Close"];
        
        lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 50, 40)];
        lblTitle.textAlignment = NSTextAlignmentCenter;
        [lblTitle setFont:[UIFont boldSystemFontOfSize:17]];
        
        lblMessage = [[UILabel alloc] initWithFrame:CGRectMake(0, 50, 50, 40)];
        lblMessage.textAlignment = NSTextAlignmentCenter;
        [lblMessage setFont:[UIFont systemFontOfSize:13]];
        lblMessage.numberOfLines = 2;
        
        imgTitle = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 15, 15)];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    }
    return self;
}

// Create the dialog view, and animate opening the dialog
- (void)show
{
    
    dialogView = [self createContainerView];
  
    dialogView.layer.shouldRasterize = YES;
    dialogView.layer.rasterizationScale = [[UIScreen mainScreen] scale];
  
    self.layer.shouldRasterize = YES;
    self.layer.rasterizationScale = [[UIScreen mainScreen] scale];

#if (defined(__IPHONE_7_0))
    if (useMotionEffects) {
        [self applyMotionEffects];
    }
#endif

    dialogView.layer.opacity = 1;

    self.backgroundColor = [UIColor clearColor];

    [self addSubview:dialogView];

    // Can be attached to a view or to the top most window
    // Attached to a view:
    if (parentView != NULL) {
        [parentView addSubview:self];
        
    if(self.parentView)
        [self.parentView endEditing:TRUE];

    // Attached to the top most window (make sure we are using the right orientation):
    } else {
        UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
        switch (interfaceOrientation) {
            case UIInterfaceOrientationLandscapeLeft:
                self.transform = CGAffineTransformMakeRotation(M_PI * 270.0 / 180.0);
                break;
                
            case UIInterfaceOrientationLandscapeRight:
                self.transform = CGAffineTransformMakeRotation(M_PI * 90.0 / 180.0);
                break;

            case UIInterfaceOrientationPortraitUpsideDown:
                self.transform = CGAffineTransformMakeRotation(M_PI * 180.0 / 180.0);
                break;

            default:
                break;
        }

        [self setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        [[[[UIApplication sharedApplication] windows] firstObject] addSubview:self];
    }

    [UIView animateWithDuration:0.2f delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
					 animations:^{
						 self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
                         dialogView.layer.transform = CATransform3DMakeScale(1, 1, 1);
					 }
					 completion:NULL
     ];
}

// Button has been touched
- (IBAction)customIOS7dialogButtonTouchUpInside:(id)sender
{
    NSInteger index = ((UIButton*)sender).tag;
    if (delegate != NULL) {
        [delegate customIOS7dialogButtonTouchUpInside:self clickedButtonAtIndex:index];
    }

    if (onButtonTouchUpInside != NULL) {
        onButtonTouchUpInside(self, (int)index);
    }
}

// Default button behaviour
- (void)customIOS7dialogButtonTouchUpInside: (CAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self close];
}

// Dialog close animation then cleaning and removing the view from the parent
- (void)close
{
    CATransform3D currentTransform = dialogView.layer.transform;

    CGFloat startRotation = [[dialogView valueForKeyPath:@"layer.transform.rotation.z"] floatValue];
    CATransform3D rotation = CATransform3DMakeRotation(-startRotation + M_PI * 270.0 / 180.0, 0.0f, 0.0f, 0.0f);

    dialogView.layer.transform = CATransform3DConcat(rotation, CATransform3DMakeScale(1, 1, 1));
    dialogView.layer.opacity = 1.0f;

    [UIView animateWithDuration:0.2f delay:0.0 options:UIViewAnimationOptionTransitionNone
					 animations:^{
						 self.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.0f];
                         dialogView.layer.transform = CATransform3DConcat(currentTransform, CATransform3DMakeScale(0.6f, 0.6f, 1.0));
                         dialogView.layer.opacity = 0.0f;
					 }
					 completion:^(BOOL finished) {
                         for (UIView *v in [self subviews]) {
                             [v removeFromSuperview];
                         }
                         [self removeFromSuperview];
					 }
	 ];
}

- (void)setSubView: (UIView *)subView
{
    containerView = subView;
}

// Creates the container view here: create the dialog, then add the custom content and buttons
- (UIView *)createContainerView
{
    if (containerView == NULL) {
        lblMessage.numberOfLines = 0;
        containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 270, 72)];
    }

    CGSize screenSize = [self countScreenSize];
    [containerView addSubview:lblTitle];
    [containerView addSubview:lblMessage];
    [containerView addSubview:imgTitle];
    
    [lblTitle fitLabelWidth:lblTitle.superview.width - 30];
    [lblTitle changeWidth:lblTitle.width Height:30];
    
    CGFloat gap = (lblTitle.height - imgTitle.height)/2;
    
    [lblTitle changeXAxis:(lblTitle.superview.width - lblTitle.width)/2 YAxis:0];
    [imgTitle changeXAxis:lblTitle.x - imgTitle.width - 5
                    YAxis:lblTitle.y + gap];
    
    [lblMessage fitLabelWidth:lblMessage.superview.width - 30];
    [lblMessage changeXAxis:(lblMessage.superview.width - lblMessage.width)/2
                      YAxis:lblTitle.height];
    [lblMessage changeWidth:lblMessage.width
                     Height:lblMessage.height + 10];

    if (lblMessage.text.length > 0) {
        [containerView changeWidth:containerView.width Height:lblTitle.height + lblMessage.height];
    }

    // For the black background
    [self setFrame:CGRectMake(0, 0, screenSize.width, screenSize.height)];

    CGSize dialogSize = [self countDialogSize];
    
    // This is the dialog's container; we attach the custom content and the buttons to this one
    UIView *dialogContainer = [[UIView alloc] initWithFrame:CGRectMake((screenSize.width - dialogSize.width) / 2, (screenSize.height - dialogSize.height) / 2, dialogSize.width, dialogSize.height)];
    
    dialogContainer.backgroundColor = [UIColor whiteColor];

    // iOS7 UIAlertView style >>>
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = dialogContainer.bounds;
    gradient.colors = [NSArray arrayWithObjects:
                       (id)[[UIColor colorWithRed:218.0/255.0 green:218.0/255.0 blue:218.0/255.0 alpha:1.0f] CGColor],
                       (id)[[UIColor colorWithRed:233.0/255.0 green:233.0/255.0 blue:233.0/255.0 alpha:1.0f] CGColor],
                       (id)[[UIColor colorWithRed:218.0/255.0 green:218.0/255.0 blue:218.0/255.0 alpha:1.0f] CGColor],
                       nil];

    CGFloat cornerRadius = kCustomIOS7AlertViewCornerRadius;
    gradient.cornerRadius = cornerRadius;
    //[dialogContainer.layer insertSublayer:gradient atIndex:0];

    dialogContainer.layer.cornerRadius = cornerRadius;
    dialogContainer.layer.borderColor = COLOR_199199199.CGColor;
    dialogContainer.layer.borderWidth = 1;
    dialogContainer.layer.shadowRadius = cornerRadius + 5;
    dialogContainer.layer.shadowOpacity = 0.1f;
    dialogContainer.layer.shadowOffset = CGSizeMake(0 - (cornerRadius+5)/2, 0 - (cornerRadius+5)/2);
    dialogContainer.layer.shadowColor = [UIColor blackColor].CGColor;
    dialogContainer.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:dialogContainer.bounds cornerRadius:dialogContainer.layer.cornerRadius].CGPath;

    // There is a line above the button
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, dialogContainer.bounds.size.height - buttonHeight - buttonSpacerHeight, dialogContainer.bounds.size.width, 1)];
    lineView.backgroundColor = COLOR_199199199;
    if([self.buttonTitles  count] > 1){
        separate = [[UIView alloc] initWithFrame:CGRectMake(containerView.frame.size.width/2,lineView.frame.origin.y,1, buttonHeight)];
        separate.backgroundColor = COLOR_199199199;
        [containerView addSubview:separate];
    }
    [dialogContainer addSubview:lineView];

    // Add the custom container if there is any
    [dialogContainer addSubview:containerView];

    // Add the buttons too
    [self addButtonsToView:dialogContainer];

    return dialogContainer;
}

// Helper function: add buttons to container
- (void)addButtonsToView: (UIView *)container
{
    if (buttonTitles==NULL) { return; }

    CGFloat buttonWidth = container.bounds.size.width / [buttonTitles count];

    for (int i=0; i<[buttonTitles count]; i++) {

        UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];

        [closeButton setFrame:CGRectMake(i * buttonWidth, container.bounds.size.height - buttonHeight, buttonWidth, buttonHeight)];
        
        [closeButton addTarget:self action:@selector(customIOS7dialogButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        [closeButton setTag:i];

        [closeButton setTitle:[buttonTitles objectAtIndex:i] forState:UIControlStateNormal];
        [closeButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [closeButton.titleLabel setFont:[UIFont systemFontOfSize:17.0f]];
        [closeButton.layer setCornerRadius:kCustomIOS7AlertViewCornerRadius];

        [container addSubview:closeButton];
    }
}

// Helper function: count and return the dialog's size
- (CGSize)countDialogSize
{
    CGFloat dialogWidth = containerView.frame.size.width;
    CGFloat dialogHeight = containerView.frame.size.height + buttonHeight + buttonSpacerHeight;

    return CGSizeMake(dialogWidth, dialogHeight);
}

// Helper function: count and return the screen's size
- (CGSize)countScreenSize
{
    if (buttonTitles!=NULL && [buttonTitles count] > 0) {
        buttonHeight       = kCustomIOS7AlertViewDefaultButtonHeight;
        buttonSpacerHeight = kCustomIOS7AlertViewDefaultButtonSpacerHeight;
    } else {
        buttonHeight = 0;
        buttonSpacerHeight = 0;
    }

    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;

    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
        CGFloat tmp = screenWidth;
        screenWidth = screenHeight;
        screenHeight = tmp;
    }

    return CGSizeMake(screenWidth, screenHeight);
}

#if (defined(__IPHONE_7_0))
// Add motion effects
- (void)applyMotionEffects {

    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        return;
    }

    UIInterpolatingMotionEffect *horizontalEffect = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x"
                                                                                                    type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    horizontalEffect.minimumRelativeValue = @(-kCustomIOS7MotionEffectExtent);
    horizontalEffect.maximumRelativeValue = @( kCustomIOS7MotionEffectExtent);

    UIInterpolatingMotionEffect *verticalEffect = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y"
                                                                                                  type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    verticalEffect.minimumRelativeValue = @(-kCustomIOS7MotionEffectExtent);
    verticalEffect.maximumRelativeValue = @( kCustomIOS7MotionEffectExtent);

    UIMotionEffectGroup *motionEffectGroup = [[UIMotionEffectGroup alloc] init];
    motionEffectGroup.motionEffects = @[horizontalEffect, verticalEffect];

    [dialogView addMotionEffect:motionEffectGroup];
}
#endif

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIDeviceOrientationDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidEnterBackgroundNotification
                                                  object:nil];
}

// Handle device orientation changes
- (void)deviceOrientationDidChange: (NSNotification *)notification
{
    // If dialog is attached to the parent view, it probably wants to handle the orientation change itself
    if (parentView != NULL) {
        return;
    }

    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];

    CGFloat startRotation = [[self valueForKeyPath:@"layer.transform.rotation.z"] floatValue];
    CGAffineTransform rotation;

    switch (interfaceOrientation) {
        case UIInterfaceOrientationLandscapeLeft:
            rotation = CGAffineTransformMakeRotation(-startRotation + M_PI * 270.0 / 180.0);
            break;

        case UIInterfaceOrientationLandscapeRight:
            rotation = CGAffineTransformMakeRotation(-startRotation + M_PI * 90.0 / 180.0);
            break;

        case UIInterfaceOrientationPortraitUpsideDown:
            rotation = CGAffineTransformMakeRotation(-startRotation + M_PI * 180.0 / 180.0);
            break;

        default:
            rotation = CGAffineTransformMakeRotation(-startRotation + 0.0);
            break;
    }

    [UIView animateWithDuration:0.2f delay:0.0 options:UIViewAnimationOptionTransitionNone
					 animations:^{
                         dialogView.transform = rotation;
					 }
					 completion:^(BOOL finished){
                         // fix errors caused by being rotated one too many times
                         dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5f * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                             UIInterfaceOrientation endInterfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
                             if (interfaceOrientation != endInterfaceOrientation) {
                                 // TODO user moved phone again before than animation ended: rotation animation can introduce errors here
                             }
                         });
                     }
	 ];

}
-(BOOL)containsString:(NSString *)StrSearchTerm on:(NSString *)StrText
{
    return  [StrText rangeOfString:StrSearchTerm options:NSCaseInsensitiveSearch].location==NSNotFound?FALSE:TRUE;
}

// Handle keyboard show/hide changes
- (void)keyboardWillShow: (NSNotification *)notification
{
    CGSize screenSize = [self countScreenSize];
    CGSize dialogSize = [self countDialogSize];
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;

    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
        CGFloat tmp = keyboardSize.height;
        keyboardSize.height = keyboardSize.width;
        keyboardSize.width = tmp;
    }

    [UIView animateWithDuration:0.2f delay:0.0 options:UIViewAnimationOptionTransitionNone
					 animations:^{
                         // prevent the change dialog size of View in Sync Contact page
                         if (![self containsString:@"Sync Contact" on:self.lblMessage.text]) {
                             dialogView.frame = CGRectMake((screenSize.width - dialogSize.width) / 2, (screenSize.height - keyboardSize.height - dialogSize.height) / 2, dialogSize.width, dialogSize.height);
                         }
                         
					 }
					 completion:nil
	 ];
}

- (void)keyboardWillHide: (NSNotification *)notification
{
    CGSize screenSize = [self countScreenSize];
    CGSize dialogSize = [self countDialogSize];

    [UIView animateWithDuration:0.2f delay:0.0 options:UIViewAnimationOptionTransitionNone
					 animations:^{
                         // prevent the change dialog size of View in Sync Contact page
                         if (![self containsString:@"Sync Contact" on:self.lblMessage.text]) {
                             dialogView.frame = CGRectMake((screenSize.width - dialogSize.width) / 2, (screenSize.height - dialogSize.height) / 2, dialogSize.width, dialogSize.height);
                         }
					 }
					 completion:nil
	 ];
}
- (void) showInfo:(NSString *)infoMessage;{
    [self setUseMotionEffects:FALSE];
    [self setButtonTitles:[NSMutableArray arrayWithObjects:@"OK", nil]];
    lblTitle.text = LABEL_INFORMATION;
    lblMessage.text = infoMessage;
    imgTitle.image = [UIImage imageNamed:IMG_POPUP_INFORMATION];
    [self show];
    if([self superview])
        [[self superview] endEditing:TRUE];
}
- (void) showInfo_2btn:(NSString *)infoMessage ButtonsName:(NSMutableArray*) buttons{
    [self setUseMotionEffects:FALSE];
    [self setButtonTitles:buttons];
    lblTitle.text = LABEL_INFORMATION;
    lblMessage.text = infoMessage;
    imgTitle.image = [UIImage imageNamed:IMG_POPUP_INFORMATION];
    [self show];
}

- (void) showInfo_2btn:(NSString *)infoMessage{
    [self setUseMotionEffects:FALSE];
    [self setButtonTitles:[NSMutableArray arrayWithObjects:[_YES capitalizedString], [_NO capitalizedString], nil]];
    lblTitle.text = LABEL_INFORMATION;
    lblMessage.text = infoMessage;
    imgTitle.image = [UIImage imageNamed:IMG_POPUP_INFORMATION];
    [self show];
}

- (void) showInfoTitle:(NSString*) infoTitle
           InfoMessage:(NSString *)infoMessage{
    [self setUseMotionEffects:FALSE];
    [self setButtonTitles:[NSMutableArray arrayWithObjects:_OK, nil]];
    if(infoTitle)
        lblTitle.text = infoTitle;
    else
        lblTitle.text = LABEL_INFORMATION;
    lblMessage.text = infoMessage;
    imgTitle.image = [UIImage imageNamed:IMG_POPUP_INFORMATION];
    [self show];
    if([self superview])
        [[self superview] endEditing:TRUE];
}

- (void) showError:(NSString*) errorMessage{
    [self setUseMotionEffects:FALSE];
    [self setButtonTitles:[NSMutableArray arrayWithObjects:_OK, nil]];
    lblTitle.text = LABEL_ERROR;
    lblMessage.text = errorMessage;
    imgTitle.image = [UIImage imageNamed:IMG_POPUP_ERROR];
    [self show];
    if([self superview])
        [[self superview] endEditing:TRUE];
}

- (void) showWarning:(NSString*) warningMessage
              TARGET:(id) controller
              ACTION:(SEL) action{
    
    [self setUseMotionEffects:FALSE];
    [self setButtonTitles:[NSMutableArray arrayWithObjects:_OK,_CANCEL, nil]];
    lblTitle.text = LABEL_WARNING;
    lblMessage.text = warningMessage;
    imgTitle.image = [UIImage imageNamed:IMG_POPUP_WARNING];
    
    [self show];
    if([self superview])
        [[self superview] endEditing:TRUE];
    
    if(action != NULL){
        for(UIButton* button in [self.dialogView subviews]){
            if([button isKindOfClass:[UIButton class]] && button.tag == 0){
                [button addTarget:controller action:action forControlEvents:UIControlEventTouchUpInside];
            }
        }
    }
}

@end
