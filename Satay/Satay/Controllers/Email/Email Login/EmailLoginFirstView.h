//
//  EmailLoginFirstView.h
//  Satay
//
//  Created by Arpana Sakpal on 3/10/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EmailLoginFirstView : UIViewController
/**
 *  Action click on gmail row
 *
 *  @param sender button gmail
 *  @author Arpana
 *  date 20-Mar-2015
 */
- (IBAction)clickedBtnloginToGmail:(id)sender;

/**
 *  Action click on Hotmail row
 *
 *  @param sender button hotmail
 *  @author Arpana
 *  date 24-Mar-2015
 */
- (IBAction)clickedBtnloginToHotmail:(id)sender;

/**
 *  Action click on Yahoo row
 *
 *  @param sender button yahoo
 *  @author Arpana
 *  date 20-Mar-2015
 */
- (IBAction)clickedBtnloginToYahoo:(id)sender;

/**
 *  Action click on Microsoft exchange row
 *
 *  @param sender button MS exchange
 *  @author Arpana
 *  date 20-Mar-2015
 */
- (IBAction)clickdBtnloginToMicrosoftExchange:(id)sender;

/**
 *  Action click on Other row
 *
 *  @param sender button other
 *  @author Arpana
 *  date 20-Mar-2015
 */
- (IBAction)clickedBtnloginToOtherMail:(id)sender;
+(EmailLoginFirstView *)share;

@end
