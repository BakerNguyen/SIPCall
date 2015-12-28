//
//  MailAttachment.m
//  DBControl
//
//  Created by enclave on 12/16/14.
//  Copyright (c) 2014 mTouche. All rights reserved.
//

#import "MailAttachment.h"

@implementation MailAttachment{
    
    NSMutableArray* notChangeColumn;
    NSMutableArray* notNullColumn;
    NSMutableArray* uniqueColumn;

}

@dynamic mailHeaderUID;
@dynamic attachmentName;
@dynamic attachmentLocalPath;
@dynamic attachmentSize;
@dynamic mineType;
@dynamic extend1;
@dynamic extend2;

-(id) init{
    if(!notChangeColumn){
        notChangeColumn = [NSMutableArray new];
        [notChangeColumn addObject:ColumnName(attachmentName)];
    }
    
    if(!notNullColumn){
        notNullColumn = [NSMutableArray new];
        //[notNullColumn addObject:ColumnName(xxx)];
        [notNullColumn addObject:ColumnName(mailHeaderUID)];
        [notNullColumn addObject:ColumnName(attachmentName)];
    }
    
    if(!uniqueColumn){
        uniqueColumn = [NSMutableArray new];
        //[uniqueColumn addObject:ColumnName(xxx)];
        [uniqueColumn addObject:ColumnName(attachmentName)];
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
    NSLog(@"INSERT MAIL ATTACHMENT %@ ...", [self class]);
    if([self violateNullColumn] || [self violateUniqueColumn])
        return FALSE;
    else
        return TRUE;
}

-(BOOL)entityWillUpdate{
    NSLog(@"UPDATE MAIL ATTACHMENT %@ ...", [self class]);
    if([self violateNotChangedColumn])
        return FALSE;
    if([self violateNullColumn] || [self violateUniqueColumn])
        return FALSE;
    else
        return TRUE;
}

-(BOOL) violateNotChangedColumn{
    MailAttachment* mailAttachment = nil;
    for (NSString* column in notChangeColumn) {
        NSString* whereState = [NSString stringWithFormat:@"%@ = '%@'", column, [self valueForKey:column]];
        mailAttachment = [[[[MailAttachment query] whereWithFormat:whereState] fetch] firstObject];
        
        NSString* oldContent = [NSString stringWithFormat:@"%@", [mailAttachment valueForKey:column]];
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
    MailAttachment* mailAttachment = nil;
    for (NSString* column in uniqueColumn) {
        NSString* whereState = [NSString stringWithFormat:@"Id != '%@' AND %@ = '%@'",self.Id, column, [self valueForKey:column]];
        mailAttachment = [[[[MailAttachment query] where:whereState] fetch] firstObject];
        if(mailAttachment){
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
    [idx addIndexForProperty:@"mailHeaderUID" propertyOrder:DBIndexSortOrderAscending];
    
    return idx;
    
}


@end
