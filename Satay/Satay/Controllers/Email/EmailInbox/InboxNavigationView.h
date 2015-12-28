//
//  InboxNavigationView.m
//
//  Created by Parker on 4/16/15.
//

#import <UIKit/UIKit.h>

@interface InboxNavigationView : UIView

@property (weak, nonatomic) IBOutlet UILabel *lblFolderName;
@property (weak, nonatomic) IBOutlet UILabel *lblEmailAddress;

/**
 *  Returns a navigation banner
 *
 *  @return navigation view
 *  @author Arpana
 */
+ (instancetype)newView;

@end
