//
//  XMPPvCardTemp+ContactDisplayName.h
//  XMPPDomain
//
//  Created by Daniel Nguyen on 2/9/15.
//  Copyright (c) 2015 mTouche. All rights reserved.
//

#import "XMPPvCardTemp.h"

@interface XMPPvCardTemp (ContactDisplayName)

- (NSString *)getDisplayName;
- (NSString *)getMaskingID;
- (void)setDisplayName:(NSString *)dname;
- (BOOL)hasDisplayName;
- (BOOL)hasMaskingID;
- (BOOL)hasPhoto;

@end
