//
//  NoteAdapter.m
//  NoteDomain
//
//  Created by MTouche on 4/13/15.
//  Copyright (c) 2015 mTouche. All rights reserved.
//

#import "NoteAdapter.h"

@implementation NoteAdapter

#define ENCRYPT_MODE @"ENCRYPT_MODE"
#define NOTE_FOLDER @"NOTE"
#define FILE_EXT_NOTE @"note"

+(BOOL) saveNoteFile:(NSString*) fileName
             content:(NSString*) fileContent{
    if (fileName.length == 0 || fileContent.length == 0) {
        NSLog(@"%s fileName or fileContent is NULL", __PRETTY_FUNCTION__);
        return FALSE;
    }
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *folderPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:NOTE_FOLDER];
    if (![[NSFileManager defaultManager] fileExistsAtPath:folderPath])
        [[NSFileManager defaultManager] createDirectoryAtPath:folderPath
                                  withIntermediateDirectories:NO
                                                   attributes:nil
                                                        error:nil];
    
    NSError *error;
    if(![[fileName pathExtension] isEqual:FILE_EXT_NOTE])
        fileName = [[fileName stringByDeletingPathExtension] stringByAppendingPathExtension:FILE_EXT_NOTE];
    BOOL succeed = [fileContent writeToFile:[folderPath stringByAppendingPathComponent:fileName]
                              atomically:YES encoding:NSUTF8StringEncoding error:&error];
    return succeed;
}

+(BOOL) deleteNoteFile:(NSString*) fileName{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString* folderPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:NOTE_FOLDER];
    if(![[fileName pathExtension] isEqual:FILE_EXT_NOTE])
        fileName = [[fileName stringByDeletingPathExtension] stringByAppendingPathExtension:FILE_EXT_NOTE];
    NSString* filePath = [folderPath stringByAppendingPathComponent:fileName];
    if([[NSFileManager defaultManager] isDeletableFileAtPath:filePath]){
        BOOL result = [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
        return result;
    }
    
    return FALSE;
}

NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
+(NSString*) generateFileName{
    NSMutableString *randomString = [NSMutableString stringWithCapacity:15];
    for (int i=0; i<15; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random_uniform((int)[letters length])]];
    }
    return randomString;
}

+(NSString*) contentOfFile:(NSString*) fileName{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* folderPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:NOTE_FOLDER];
    if(![[fileName pathExtension] isEqual:FILE_EXT_NOTE])
        fileName = [[fileName stringByDeletingPathExtension] stringByAppendingPathExtension:FILE_EXT_NOTE];
    NSString* filePath = [folderPath stringByAppendingPathComponent:fileName];
    
    NSString* strContent = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    return strContent;
}

+(void) configMode{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (![defaults objectForKey:ENCRYPT_MODE])
        [defaults setObject:[NSNumber numberWithBool:FALSE] forKey:ENCRYPT_MODE];
}

+(void) setModeNote:(BOOL) willEncrypted{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithBool:willEncrypted] forKey:ENCRYPT_MODE];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(BOOL) getModeNote{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [[defaults objectForKey:ENCRYPT_MODE] boolValue];
}

@end
