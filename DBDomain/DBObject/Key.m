//
//  Key.m
//  DBControl
//
//  Created by enclave on 12/15/14.
//  Copyright (c) 2014 mTouche. All rights reserved.
//

#import "Key.h"

@implementation Key{

    NSMutableArray* notChangeColumn;
    NSMutableArray* notNullColumn;
    NSMutableArray* uniqueColumn;
}


@dynamic keyId;
@dynamic keyJSON;
@dynamic keyVersion;
@dynamic updateTS;
@dynamic extend1;
@dynamic extend2;

-(id) init{
    if(!notChangeColumn){
        notChangeColumn = [NSMutableArray new];
        [notChangeColumn addObject:ColumnName(keyId)];
    }
    
    if(!notNullColumn){
        notNullColumn = [NSMutableArray new];
        //[notNullColumn addObject:ColumnName(xxx)];
        [notNullColumn addObject:ColumnName(keyId)];
    }
    
    if(!uniqueColumn){
        uniqueColumn = [NSMutableArray new];
        //[uniqueColumn addObject:ColumnName(xxx)];
        //[uniqueColumn addObject:ColumnName(keyId)];
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
    NSLog(@"INSERT KEY %@ ...", [self class]);
    if([self violateNullColumn] || [self violateUniqueColumn])
        return FALSE;
    else
        return TRUE;
}

-(BOOL)entityWillUpdate{
    NSLog(@"UPDATE KEY %@ ...", [self class]);
    if([self violateNotChangedColumn])
        return FALSE;
    if([self violateNullColumn] || [self violateUniqueColumn])
        return FALSE;
    else
        return TRUE;
}

-(BOOL) violateNotChangedColumn{
    Key* key = nil;
    for (NSString* column in notChangeColumn) {
        NSString* whereState = [NSString stringWithFormat:@"%@ = '%@'", column, [self valueForKey:column]];
        key = [[[[Key query] whereWithFormat:whereState] fetch] firstObject];
        
        NSString* oldContent = [NSString stringWithFormat:@"%@", [key valueForKey:column]];
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
    Key* key = nil;
    for (NSString* column in uniqueColumn) {
        NSString* whereState = [NSString stringWithFormat:@"Id != '%@' AND %@ = '%@'",self.Id, column, [self valueForKey:column]];
        key = [[[[Key query] where:whereState] fetch] firstObject];
        if(key){
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
    [idx addIndexForProperty:@"keyId" propertyOrder:DBIndexSortOrderAscending];
    
    return idx;
    
}


@end
