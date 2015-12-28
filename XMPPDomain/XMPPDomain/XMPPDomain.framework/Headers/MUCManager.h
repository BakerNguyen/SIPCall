//
//  MUCManager.h
//  XMPPDomain
//
//  Created by Daniel Nguyen on 1/28/15.
//  Copyright (c) 2015 mTouche. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMPPFramework.h"

@interface MUCManager : NSObject

+ (MUCManager *)share;

- (NSDictionary *)processGroupMessage:(XMPPMessage *)message;
- (void)processIncomingRoomImageWithMessage:(NSDictionary *)dIncomingMessage Data:(NSDictionary *)objData;
- (void)processIncomingRoomVideoWithMessage:(NSDictionary *)dIncomingMessage Data:(NSDictionary *)objData;
- (void)processIncomingRoomAudioWithMessage:(NSDictionary *)dIncomingMessage Data:(NSDictionary *)objData;
@end
