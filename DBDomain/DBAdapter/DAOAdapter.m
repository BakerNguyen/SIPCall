//
//  DAOAdapter.m
//  EliteTest
//
//  Created by enclave on 11/28/14.
//  Copyright (c) 2014 mTouche. All rights reserved.
//

#import "DAOAdapter.h"

@implementation DAOAdapter

+(DAOAdapter *)share{
    static dispatch_once_t once;
    static DAOAdapter * share;
    dispatch_once(&once, ^{
        share = [self new];
        [DBAccess setDelegate:share];
    });
    return share;
}

-(void) openDB:(NSString *)DatabaseName{
    if(!DatabaseName || ![DatabaseName isKindOfClass:[NSString class]] || [DatabaseName isEqual:@""]){
        NSLog(@"DatabaseName: %@ is not correct", DatabaseName);
        return;
    }
    [DBAccess openDatabaseNamed:DatabaseName];
}

- (BOOL)commitObject:(DBObject*)object{
    if([object isKindOfClass:[DBObject class]])
        return [object commit];
    else{
        NSLog(@"%s Error: object is not DBObject subclass.", __PRETTY_FUNCTION__);
        return FALSE;
    }
}


- (BOOL)deleteObject:(DBObject*)object{
    if([object isKindOfClass:[DBObject class]])
        return [object remove];
    else{
        NSLog(@"%s object is not DBObject subclass", __PRETTY_FUNCTION__);
        return NO;
    }
}

- (void)deleteAllObject:(Class)object{
    if([object isSubclassOfClass:[DBObject class]])
        [[[object query] fetch] removeAll];
    else{
        NSLog(@"%s object is not DBObject subclass", __PRETTY_FUNCTION__);
    }
}

- (BOOL)isExisted:(DBObject*)object condition:(NSString *)strCondition{
    id value = [self getObject:[object class] condition:strCondition];
    if(value)
        return YES;
    else
        return NO;
}

- (DBObject*)getObject:(Class)objClass condition:(NSString *)strCondition{
    if (!strCondition || [strCondition isEqualToString:@""]) {
         NSLog(@"%s Error: condition string is empty or incorrect.", __PRETTY_FUNCTION__);
        return NULL;
    }
    if([objClass isSubclassOfClass:[DBObject class]]){
        DBObject* object = [[[[objClass query]
                  whereWithFormat:strCondition]
                 limit:1]
                fetch].firstObject;
        return object;
    }
    else{
        NSLog(@"%s Error: object is not DBObject subclass.", __PRETTY_FUNCTION__);
        return NULL;
    }
}

- (NSArray *)getAllObject:(Class)object{
    if([object isSubclassOfClass:[DBObject class]])
        return [[object query] fetch];
    else{
        NSLog(@"%s error, object is not DBObject subclass", __PRETTY_FUNCTION__);
        return NULL;
    }
}

- (NSArray *)getObjects:(Class)objClass condition:(NSString *)strCondition{
    if (!strCondition || [strCondition isEqualToString:@""]) {
         NSLog(@"%s error: condition string is empty or incorrect.", __PRETTY_FUNCTION__);
        return NULL;
    }
    
    if([objClass isSubclassOfClass:[DBObject class]])
        return [[[objClass query]
                 whereWithFormat:strCondition]
                fetch];
    else{
        NSLog(@"%s error: object is not DBObject subclass", __PRETTY_FUNCTION__);
        return NULL;
    }
}

- (NSArray *)getObjects:(Class)object
              condition:(NSString *)strCondition
                orderBy:(NSString *)order
           isDescending:(BOOL) isDescending
                  limit:(int) limit{
    if (!strCondition || [strCondition isEqualToString:@""]) {
         NSLog(@"Warning: Condition string is empty");
    }
    
    if([object isSubclassOfClass:[DBObject class]]){
        DBQuery* query = [[object query] whereWithFormat:strCondition];
        query = [query limit:limit];
        if (isDescending)
            query = [query orderByDescending:order];
        else
            query = [query orderBy:order];
        return [query fetch];
    }
    else{
        NSLog(@"Facade layer, object is not DBObject subclass");
        return NULL;
    }
    
}

-(NSString *)conditionObjectWithCase:(enum DBConditionCase)cases withKey:(NSArray *)key withValue:(NSArray *)value{
    NSString *stringConditionFormat = @"";
    switch (cases) {
        case DBConditionCaseEqual:{
            if (key.count >1 || value.count >1)
                NSLog(@"Number of parameters of condition key  or condition value is incorrect");
            else
                stringConditionFormat = [NSString stringWithFormat:@"%@ = %@", key[0], value[0]];
            break;
        }
        case DBConditionCaseEqualAndEqual:{
            if (key.count >2 || value.count >2 || key.count < 2 || value.count < 2)
                NSLog(@"Number of parameters of condition key  or condition value is incorrect");
            else
                stringConditionFormat = [NSString stringWithFormat:@"%@ = %@ AND %@ = %@", key[0], value[0], key[1], value[1]];
            break;
        }
        default:{
            stringConditionFormat = @"";
            break;
        }
    }
    return stringConditionFormat;
}

@end
