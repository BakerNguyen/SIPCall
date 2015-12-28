//
//  AttachmentCell.m
//  Satay
//
//  Created by Nghia (William) T. VO on 4/21/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import "AttachmentCell.h"

@interface AttachmentCell ()

@end

@implementation AttachmentCell
@synthesize imageAttach, btnDeleteAttachment;
- (void)prepareForReuse
{
    self.imageAttach.image = nil;
}

@end
