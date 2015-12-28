//

#import <UIKit/UIKit.h>

@protocol CustomIOS7AlertViewDelegate

- (void)customIOS7dialogButtonTouchUpInside:(id)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;

@end

@interface CAlertView : UIView<CustomIOS7AlertViewDelegate>

@property (nonatomic, retain) UIView *parentView;    // The parent view this 'dialog' is attached to
@property (nonatomic, retain) UIView *dialogView;    // Dialog's container view
@property (nonatomic, retain) UIView *containerView; // Container within the dialog (place your ui elements here)
@property (nonatomic, retain) UIView *buttonView;    // Buttons on the bottom of the dialog

@property (nonatomic, assign) id<CustomIOS7AlertViewDelegate> delegate;
@property (nonatomic, retain) NSArray *buttonTitles;
@property (nonatomic, assign) BOOL useMotionEffects;

@property (copy) void (^onButtonTouchUpInside)(CAlertView *alertView, int buttonIndex);

@property (nonatomic, retain) UILabel* lblTitle;
@property (nonatomic, retain) UILabel* lblMessage;
@property (nonatomic, retain) UIImageView* imgTitle;
@property (nonatomic, retain) UIView* separate;

- (void) showInfo:(NSString *)infoMessage;
- (id)init;

/*!
 DEPRECATED: Use the [CustomIOS7AlertView init] method without passing a parent view.
 */
- (id)initWithParentView: (UIView *)_parentView __attribute__ ((deprecated));

- (void)show;
- (void)close;

- (IBAction)customIOS7dialogButtonTouchUpInside:(id)sender;
- (void)setOnButtonTouchUpInside:(void (^)(CAlertView *alertView, int buttonIndex))onButtonTouchUpInside;

- (void)deviceOrientationDidChange: (NSNotification *)notification;

- (void) showError:(NSString*) errorMessage;
- (void) showWarning:(NSString*) warningMessage
              TARGET:(id) controller
              ACTION:(SEL) action;
- (void) showInfoTitle:(NSString*) infoTitle
           InfoMessage:(NSString *)infoMessage;

- (void) showInfo_2btn:(NSString *)infoMessage;
- (void) showInfo_2btn:(NSString *)infoMessage ButtonsName:(NSMutableArray*) buttons;

@end
