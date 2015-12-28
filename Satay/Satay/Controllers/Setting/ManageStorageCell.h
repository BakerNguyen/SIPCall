//
//  ManageStorageCell.h
//  Satay
//
//  Created by Nghia (William) T. VO on 5/18/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ManageStorageCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIButton *btnSelectedChatRoom;
@property (strong, nonatomic) IBOutlet UIImageView *imageChatRoomAvatar;
@property (strong, nonatomic) IBOutlet UILabel *lblChatRoomSize;
@property (strong, nonatomic) IBOutlet UILabel *lblChatRoomName;
@property (assign, nonatomic) unsigned long long totalBypeSize;
@end
