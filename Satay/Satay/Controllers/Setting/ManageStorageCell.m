//
//  ManageStorageCell.m
//  Satay
//
//  Created by Nghia (William) T. VO on 5/18/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import "ManageStorageCell.h"

@implementation ManageStorageCell

- (void)awakeFromNib {
    // Initialization code
    _btnSelectedChatRoom.layer.cornerRadius = _btnSelectedChatRoom.frame.size.height/2;
    _btnSelectedChatRoom.clipsToBounds = YES;
    [_btnSelectedChatRoom setImage:[UIImage imageNamed:IMG_C_B_UNTICK] forState:UIControlStateNormal];
    _imageChatRoomAvatar.layer.cornerRadius = _imageChatRoomAvatar.frame.size.height/2;
    _imageChatRoomAvatar.clipsToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
