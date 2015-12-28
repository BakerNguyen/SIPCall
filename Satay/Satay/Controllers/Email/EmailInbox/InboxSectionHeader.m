//
//  SectionHeaderView.m
//  KryptoChat
//
//  Created by Alain P. Phan on 5/21/14.
//  Copyright (c) 2014 mTouche. All rights reserved.
//

#import "InboxSectionHeader.h"

@implementation InboxSectionHeader

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

+ (instancetype)newHeader
{
    InboxSectionHeader *sectionHeader = [[[NSBundle mainBundle] loadNibNamed:@"InboxSectionHeader" owner:nil options:nil] lastObject];
    
    if ([sectionHeader isKindOfClass:[InboxSectionHeader class]]) {
        return sectionHeader;
    }
    
    return nil;
}

+ (instancetype)headerForSectionKey:(NSString *)sectionKey
                          itemCount:(NSUInteger)number
                        sortingType:(EmailSortingType)sortingType;
{
    InboxSectionHeader *header = [InboxSectionHeader newHeader];
    if (header) {
        switch (sortingType) {
            case EmailSortingTypeDateASC:
            case EmailSortingTypeDateDESC:
                [header configureDateViewForSectionKey:sectionKey itemCount:number];
                break;
                
            default:
            {
                header.nameLabel.text = [NSString stringWithFormat:@"%@ (%d)", sectionKey, number];
                header.dateLabel.text = nil;
            }
                break;
        }
    }
    
    return header;
}


#pragma mark - Private methods
- (void)configureDateViewForSectionKey:(NSString *)sectionKey itemCount:(NSUInteger)number;
{
    self.nameLabel.text = [[EmailFacade share] nameStringForInboxSectionKey:sectionKey itemCount:number];
    self.dateLabel.text = [[EmailFacade share] dateStringForInboxSectionKey:sectionKey];
}

@end
