//
//  SecureNoteFacade.h
//  Satay
//
//  Created by MTouche on 4/13/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SecureNoteFacade : NSObject{
    NSObject <SecNoteListDelegate> *secNoteListDelegate;
}

@property (strong , retain) NSObject* secNoteListDelegate;

/*
 *Singleton of this file
 *@Author TrungVN
 */
+(SecureNoteFacade *)share;

/*
 * Save content note into file + encrypt.
 * Save record into SecureNote* object.
 * @Author TrungVN
 */
-(void) saveNote:(NSString*) fileName
         content:(NSString*) fileContent;
/*
 *Delete content of note.
 *@Author TrungVN
 */
-(void) deleteNote:(NSString*) fileName;
/*
 * Get SecureNote object
 * @Author TrungVN
 */
-(SecureNote*) getSecureNote:(NSString*) fileName;
/*
 * Return decrypted content of note
 * @Author TrungVN
 */
-(NSString*) contentNote:(NSString*) fileName;
/*
 * Show Note List
 * @Author TrungVN
 */
-(void) showNoteList;
/*
 * get display mode config (encrypte/decrypt title);
 * @Author TrungVN
 */
-(BOOL) displayMode;
/*
 * set display mode config
 * @Author TrungVN
 */
-(void) setDisplayMode:(BOOL) displayMode;

@end
