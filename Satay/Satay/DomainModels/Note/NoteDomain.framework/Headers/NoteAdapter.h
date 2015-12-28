//
//  NoteAdapter.h
//  NoteDomain
//
//  Created by MTouche on 4/13/15.
//  Copyright (c) 2015 mTouche. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NoteAdapter : NSObject

/*
 * Save file note of user into app local storage
 * @Author:TrungVN
 */
+(BOOL) saveNoteFile:(NSString*) fileName
             content:(NSString*) fileContent;
/*
 * Delete file note in app local storage
 * @Author:TrungVN
 */
+(BOOL) deleteNoteFile:(NSString*) fileName;
/*
 * Generate file name of Note
 * length 15 chars
 * @Author:TrungVN
 */
+(NSString*) generateFileName;

/*
 * Return content of note file in encrypted form.
 * @Author:TrungVN
 */
+(NSString*) contentOfFile:(NSString*) fileName;

/*
 * configMode default
 * @Author:TrungVN
 */
+(void) configMode;

/*
 * set Displaying mode for note title.
 * @Author:TrungVN
 */
+(void) setModeNote:(BOOL) willEncrypted;

/*
 * get Displaying mode for note title.
 * @Author:TrungVN
 */
+(BOOL) getModeNote;

@end
