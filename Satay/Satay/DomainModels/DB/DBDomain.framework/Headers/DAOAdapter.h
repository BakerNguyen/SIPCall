//
//  DAOAdapter.h
//  EliteTest
//
//  Created by enclave on 11/28/14.
//  Copyright (c) 2014 mTouche. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <DBAccess/DBAccess.h>

enum DBConditionCase {
    DBConditionCaseEqual = 1,
    DBConditionCaseEqualAndEqual = 2
};

@interface DAOAdapter : NSObject <DBDelegate>

/* Singleton of this object
 * @Author: Trung
 * using this so no need re-alloc the object
 */
+(DAOAdapter *)share;

/**
 * Open DB file with DBName or create it if not yet existed.
 * @author Trung
 * @param (NSString*) DatabaseName, name of Database needed to be created or opened.
 * version 1.0
 * date 15/12/2014
 */
- (void) openDB:(NSString*) DatabaseName;

/**
 * insert or update object
 * @author Parker
 *
 * @param (DBObject*)object, the object needed to be updated or inserted.
 * @return BOOL success or not.
 */
- (BOOL) commitObject:(DBObject*)object;

/**
 * Delete object in table database.
 * @author Parker
 *
 * @return BOOL success or not.
 */
- (BOOL)deleteObject:(DBObject*)object;

/**
 * Delete all object with same class.
 * @author Parker
 *
 * @return BOOL success or not.
 */
- (void)deleteAllObject:(Class)object;

//***** IMPORTANT NOTE: strCondition is string after "WHERE" in sql query. ********/
/**
 * Geting object with specific condition.
 * @author Parker
 *
 * @param (Class)objClass, class of object you want to query.
 * @param (NSString*)strCondition condition string format
 * @return (DBObject*) found or null.
 */
- (DBObject*)getObject:(Class)objClass condition:(NSString *)strCondition;

/**
 * Geting all objects from database with same class.
 * @author Parker
 * @param (Class)objClass, class of object you want to query.
 * @return (NSArray*)  array of objects  or NULL.
 */
- (NSArray *)getAllObject:(Class)object;

/**
 * Geting objects with specific condition.
 * @author Parker
 *
 * @param (Class)object the object
 * @param (NSString*)strCondition condition string format
 * @return (NSArray*) array of objects  or NULL.
 */
- (NSArray *)getObjects:(Class)objClass condition:(NSString *)strCondition;

/**
 * Geting objects with specific condition and order by base on columns name.
 * @author Parker
 *
 * @param (Class)objClass, class of object you want to query
 * @param (NSString*)strCondition condition string format
 * @param (NSString*)order a comma separated string for use to order the results, e.g. "surname, forename"
 * @return (NSArray*) array of objects  or NULL. 
 */
- (NSArray *)getObjects:(Class)objClass
              condition:(NSString *)strCondition
                orderBy:(NSString *)order
           isDescending:(BOOL) isDescending
                  limit:(int) limit;

/**
 * This function for checking object is existing or not.
 * @author Parker
 *
 * @param (DBObject*)object, object need to be checked.
 * @return BOOL TRUE or FALL.
 */
- (BOOL)isExisted:(DBObject*)object condition:(NSString *)strCondition;

/**
 * This function for condition string format for query.
 * @author Parker
 *
 * @param (enum DBConditionCase)cases case number
 * @param (NSArray*)key key condition
 * @return (NSArray*)value value of condition.
 */
- (NSString *)conditionObjectWithCase:(enum DBConditionCase)cases withKey:(NSArray *)key withValue:(NSArray *)value;

@end
