//
//  MailAccount.m
//  DBControl
//
//  Created by enclave on 12/16/14.
//  Copyright (c) 2014 mTouche. All rights reserved.
//

#import "MailAccount.h"

@implementation MailAccount{
    NSMutableArray* notChangeColumn;
    NSMutableArray* notNullColumn;
    NSMutableArray* uniqueColumn;
}

@dynamic fullEmail;
@dynamic password;
@dynamic accountType;
@dynamic displayName;
@dynamic signature;
@dynamic emailKeeping;
@dynamic useEncrypted;
@dynamic syncSchedule;
@dynamic periodSyncSchedule;
@dynamic useSyncEmail;
@dynamic retrivalSize;
@dynamic useNotify;
@dynamic autoDownloadWifi;
@dynamic incomingUserName;
@dynamic incomingPassword;
@dynamic incomingHost;
@dynamic incomingPort;
@dynamic incomingUseSSL;
@dynamic incomingSecurityType;
@dynamic outgoingUserName;
@dynamic outgoingPassword;
@dynamic outgoingHost;
@dynamic outgoingPort;
@dynamic outgoingSecurityType;
@dynamic outgoingRequireAuth;
@dynamic storeProtocol;
@dynamic pop3Deleteable;
@dynamic imapPathPrefix;
@dynamic extend1;
@dynamic extend2;

-(id) init{
    if(!notChangeColumn){
        notChangeColumn = [NSMutableArray new];
        [notChangeColumn addObject:ColumnName(fullEmail)];
    }
    
    if(!notNullColumn){
        notNullColumn = [NSMutableArray new];
        //[notNullColumn addObject:ColumnName(xxx)];
        [notNullColumn addObject:ColumnName(fullEmail)];
    }
    
    if(!uniqueColumn){
        uniqueColumn = [NSMutableArray new];
        //[uniqueColumn addObject:ColumnName(xxx)];
        [uniqueColumn addObject:ColumnName(fullEmail)];
    }
    
    return [super init];
}

-(BOOL) commit{
    NSArray* stack = [NSThread callStackSymbols];
    if (stack.count > 2){
        NSString* caller = [stack objectAtIndex:1];
        if ([caller rangeOfString:Adapter].location != NSNotFound) {
            //NSLog(@"CALL RIGHT");
        }
        else{
            NSLog(@"Please use [DAOAdapter commitObject:()]");
            return FALSE;
        }
    }
    return [super commit];
}

-(BOOL)entityWillInsert{
    NSLog(@"INSERT MAIL ACCOUNT %@ ...", [self class]);
    if([self violateNullColumn] || [self violateUniqueColumn])
        return FALSE;
    else
        return TRUE;
}

-(BOOL)entityWillUpdate{
    NSLog(@"UPDATE MAIL ACCOUNT %@ ...", [self class]);
    if([self violateNotChangedColumn])
        return FALSE;
    if([self violateNullColumn] || [self violateUniqueColumn])
        return FALSE;
    else
        return TRUE;
}

-(BOOL) violateNotChangedColumn{
    MailAccount* mailAccount = nil;
    for (NSString* column in notChangeColumn) {
        NSString* whereState = [NSString stringWithFormat:@"%@ = '%@'", column, [self valueForKey:column]];
        mailAccount = [[[[MailAccount query] whereWithFormat:whereState] fetch] firstObject];
        
        NSString* oldContent = [NSString stringWithFormat:@"%@", [mailAccount valueForKey:column]];
        NSString* newContent = [NSString stringWithFormat:@"%@", [self valueForKey:column]];
        
        if(![oldContent isEqualToString:newContent]){
            NSLog(@"%@ cannot be update in %@", column, [self class]);
            return TRUE;
        }
    }
    return FALSE;
}

-(BOOL) violateNullColumn{
    for (NSString* column in notNullColumn) {
        id data  = [self valueForKey:column];
        if (!data || ([data isKindOfClass:[NSString class]] && [data isEqualToString:@""])){
            NSLog(@"%@ must not be null in %@", column, [self class]);
            return TRUE;
        }
    }
    return FALSE;
}

-(BOOL) violateUniqueColumn{
    MailAccount* mailAccount = nil;
    for (NSString* column in uniqueColumn) {
        NSString* whereState = [NSString stringWithFormat:@"Id != '%@' AND %@ = '%@'",self.Id, column, [self valueForKey:column]];
        mailAccount = [[[[MailAccount query] where:whereState] fetch] firstObject];
        if(mailAccount){
            NSLog(@"%@ must unique in %@", column, [self class]);
            return TRUE;
        }
    }
    return FALSE;
}

+ (DBIndexDefinition *)indexDefinitionForEntity {
    
    /* create an index definition object */
    DBIndexDefinition* idx = [DBIndexDefinition new];
    
    /* now specify which properties are going to be indexed */
    [idx addIndexForProperty:@"fullEmail" propertyOrder:DBIndexSortOrderAscending];
    
    return idx;
    
}


@end
