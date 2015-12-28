//
//  XMPPvCardTemp+ContactDisplayName.m
//  XMPPDomain
//
//  Created by Daniel Nguyen on 2/9/15.
//  Copyright (c) 2015 mTouche. All rights reserved.
//

#define XMPP_VCARD_SET_FN_CHILD(Value, Name)                        \
NSXMLElement *name = [self elementForName:@"FN"];					\
if ((Value) != nil && name == nil)                                  \
{                                                                   \
name = [NSXMLElement elementWithName:@"FN"];                        \
[self addChild:name];                                               \
}																	\
\
NSXMLElement *part = [name elementForName:(Name)];					\
if ((Value) != nil && part == nil)                                  \
{								                                    \
part = [NSXMLElement elementWithName:(Name)];                       \
[name addChild:part];                                               \
}																	\
\
if (Value)                                                          \
{                                                                   \
[part setStringValue:(Value)];                                      \
}                                                                   \
else if (part != nil)                                               \
{                                                                   \
/* N is mandatory, so we leave it in. */                            \
[name removeChildAtIndex:[[self children] indexOfObject:part]];     \
}

#import "XMPPvCardTemp+ContactDisplayName.h"


@implementation XMPPvCardTemp (ContactDisplayName)

- (NSString *)getDisplayName
{
    return [[self elementForName:@"display_name"] stringValue];
}

- (NSString *)getMaskingID
{
    return [[self elementForName:@"masking_id"] stringValue];
}


- (void)setDisplayName:(NSString *)dname
{
    XMPP_VCARD_SET_STRING_CHILD(dname, @"display_name");
}

- (BOOL)hasDisplayName
{
    NSXMLElement *elem = [self elementForName:@"display_name"];
    if (elem != nil) {
        return YES;
    }
    
    return NO;
}

- (BOOL)hasMaskingID
{
    NSXMLElement *elem = [self elementForName:@"masking_id"];
    if (elem != nil) {
        return YES;
    }
    
    return NO;
}

- (BOOL)hasPhoto
{
    NSXMLElement *elem = [self elementForName:@"PHOTO"];
    if (elem != nil) {
        return YES;
    }
    
    return NO;
}

@end
