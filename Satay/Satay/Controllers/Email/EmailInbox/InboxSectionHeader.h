//
//  SectionHeaderView.h
//  KryptoChat
//
//  Created by Alain P. Phan on 5/21/14.
//  Copyright (c) 2014 mTouche. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InboxSectionHeader : UIView

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

/**
 *  Returns a header view without any text data
 *
 *  @return header view
 *  @author Parker
 */
+ (instancetype)newHeader;

//
/**
 *  Returns a header view with text populated
 *
 *  @param sectionKey  key of that section
 *  @param number      number of item
 *  @param sortingType sorting type
 *
 *  @return header view
 *  @author Parker
 */
+ (instancetype)headerForSectionKey:(NSString *)sectionKey
                          itemCount:(NSUInteger)number
                        sortingType:(EmailSortingType)sortingType;

@end
