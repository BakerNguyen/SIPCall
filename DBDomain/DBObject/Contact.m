//
//  Contact.m
//  DBASample
//
//  Created by MTouche on 12/3/14.
//  Copyright (c) 2014 mTouche inc. All rights reserved.
//

#import "Contact.h"

@implementation Contact{
    NSMutableArray* notChangeColumn;
    NSMutableArray* notNullColumn;
    NSMutableArray* uniqueColumn;
}

@dynamic jid;
@dynamic maskingid;
@dynamic phonebookName;
@dynamic serversideName;
@dynamic customerName;
@dynamic statusMsg;
@dynamic phoneModel;
@dynamic platform;
@dynamic phonebookMSISDN;
@dynamic serverMSISDN;
@dynamic email;
@dynamic avatarURL;
@dynamic contactType;
@dynamic contactState;
@dynamic syncTS;
@dynamic extend1;
@dynamic extend2;

-(id) init{
    if(!notChangeColumn){
        notChangeColumn = [NSMutableArray new];
        [notChangeColumn addObject:ColumnName(jid)];
        [notChangeColumn addObject:ColumnName(maskingid)];
    }
    
    if(!notNullColumn){
        notNullColumn = [NSMutableArray new];
        [notNullColumn addObject:ColumnName(jid)];
        [notNullColumn addObject:ColumnName(maskingid)];
    }
    
    if(!uniqueColumn){
        uniqueColumn = [NSMutableArray new];
        [uniqueColumn addObject:ColumnName(jid)];
        [uniqueColumn addObject:ColumnName(maskingid)];
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
    NSLog(@"INSERT %@ ...", [self class]);
    if([self violateNullColumn] || [self violateUniqueColumn])
        return FALSE;
    else
        return TRUE;
}

-(BOOL)entityWillUpdate{
    NSLog(@"UPDATE %@ ...", [self class]);
    if([self violateNotChangedColumn])
        return FALSE;
    if([self violateNullColumn] || [self violateUniqueColumn])
        return FALSE;
    else
        return TRUE;
}

-(BOOL) violateNotChangedColumn{
    Contact* contact = nil;
    for (NSString* column in notChangeColumn) {
        NSString* whereState = [NSString stringWithFormat:@"%@ = '%@'", column, [self valueForKey:column]];
        contact = [[[[Contact query] whereWithFormat:whereState] fetch] firstObject];
        
        NSString* oldContent = [NSString stringWithFormat:@"%@", [contact valueForKey:column]];
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
    Contact* contact = nil;
    for (NSString* column in uniqueColumn) {
        NSString* whereState = [NSString stringWithFormat:@"Id != '%@' AND %@ = '%@'",self.Id, column, [self valueForKey:column]];
        contact = [[[[Contact query] where:whereState] fetch] firstObject];
        if(contact){
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
    [idx addIndexForProperty:@"cusomterName" propertyOrder:DBIndexSortOrderAscending secondaryProperty:@"serversideName" secondaryOrder:DBIndexSortOrderAscending];
    
    return idx;
    
}


@end
