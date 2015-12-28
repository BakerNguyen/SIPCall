//
//  SecureNoteFacade.m
//  Satay
//
//  Created by MTouche on 4/13/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import "SecureNoteFacade.h"

@implementation SecureNoteFacade
@synthesize secNoteListDelegate;

+(SecureNoteFacade *)share{
    static dispatch_once_t once;
    static SecureNoteFacade * share;
    dispatch_once(&once, ^{
        share = [self new];
    });
    return share;
}

-(void) saveNote:(NSString*) fileName
         content:(NSString*) fileContent{
    SecureNote* secNote = [[SecureNoteFacade share] getSecureNote:fileName];
    NSDictionary *logDic;
    if (!secNote) {
        secNote = [SecureNote new];
        secNote.fileName = [NoteAdapter generateFileName];
        fileName = secNote.fileName;
    }
    
    NSString* strDesc = fileContent.length > 50?
    [fileContent substringToIndex:50] :
    [fileContent substringToIndex:fileContent.length];
    secNote.descContentNormal = strDesc;
    secNote.updateTS = [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]];
    
    NSData* fileData = [fileContent dataUsingEncoding:NSUTF8StringEncoding];
    fileData = [[AppFacade share] encryptDataLocally:fileData];
    NSString* base64Content = [Base64Security generateBase64String:fileData];
    if (base64Content.length > 0) {
        logDic = @{
                   LOG_CLASS : NSStringFromClass(self.class),
                   LOG_CATEGORY: CATEGORY_NOTES_ENCRYPTED,
                   LOG_MESSAGE: @"ENCRYPT SUCCESS",
                   LOG_EXTRA1: @"",
                   LOG_EXTRA2: @""
                   };
        [[LogFacade share] logInfoWithDic:logDic];
    }else{
        logDic = @{
                   LOG_CLASS : NSStringFromClass(self.class),
                   LOG_CATEGORY: CATEGORY_NOTES_ENCRYPTED,
                   LOG_MESSAGE: @"ENCRYPT FAILED",
                   LOG_EXTRA1: @"",
                   LOG_EXTRA2: @""
                   };
        [[LogFacade share] logErrorWithDic:logDic];
    }
    
    NSString* encDesc = base64Content.length > 50 ?
    [base64Content substringToIndex:50] :
    [base64Content substringToIndex:base64Content.length];
    secNote.descContentEnc = encDesc;
    [[DAOAdapter share] commitObject:secNote];
    
    if ([NoteAdapter saveNoteFile:fileName content:base64Content]) {
        logDic = @{
                   LOG_CLASS : NSStringFromClass(self.class),
                   LOG_CATEGORY: CATEGORY_NOTES_CREATE_SAVED_SUCCESS,
                   LOG_MESSAGE: @"SAVE NOTE WITH CONTENT",
                   LOG_EXTRA1: @"",
                   LOG_EXTRA2: @""
                   };
        [[LogFacade share] logInfoWithDic:logDic];
    }else
    {
        logDic = @{
                   LOG_CLASS : NSStringFromClass(self.class),
                   LOG_CATEGORY: CATEGORY_NOTES_CREATE_CANCEL,
                   LOG_MESSAGE: @"CAN NOT SAVE NOTE",
                   LOG_EXTRA1: @"",
                   LOG_EXTRA2: @""
                   };
        [[LogFacade share] logErrorWithDic:logDic];
    }
}

-(NSString*) contentNote:(NSString*) fileName{
    NSString* content = [NoteAdapter contentOfFile:fileName];
    NSData* fileData = [Base64Security decodeBase64String:content];
    NSData* decData = [[AppFacade share] decryptDataLocally:fileData];
    content = [[NSString alloc] initWithData:decData encoding:NSUTF8StringEncoding];
    NSDictionary *logDic;
    if (content.length > 0) {
        logDic = @{
                   LOG_CLASS : NSStringFromClass(self.class),
                   LOG_CATEGORY: CATEGORY_NOTES_DECRYPTED,
                   LOG_MESSAGE: @"DECRYPT SUCCESS",
                   LOG_EXTRA1: @"",
                   LOG_EXTRA2: @""
                   };
        [[LogFacade share] logInfoWithDic:logDic];
    }
    else{
        logDic = @{
                   LOG_CLASS : NSStringFromClass(self.class),
                   LOG_CATEGORY: CATEGORY_NOTES_DECRYPTED,
                   LOG_MESSAGE: @"DECRYPT FAILED",
                   LOG_EXTRA1: @"",
                   LOG_EXTRA2: @""
                   };
        [[LogFacade share] logErrorWithDic:logDic];
    }
    return content;
}

-(void) deleteNote:(NSString*) fileName{
    SecureNote* secNote = [self getSecureNote:fileName];
    if (secNote) {
        [[DAOAdapter share] deleteObject:secNote];
        [NoteAdapter deleteNoteFile:fileName];
        [self showNoteList];
    }
}

-(SecureNote*) getSecureNote:(NSString*) fileName{
    NSString* query = [NSString stringWithFormat:@"fileName = '%@'", fileName];
    SecureNote* secNote = (SecureNote*)[[DAOAdapter share] getObject:[SecureNote class]
                                                           condition:query];
    return secNote;
}

-(void) showNoteList{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        NSString* queryList = [NSString stringWithFormat:@"fileName IS NOT NULL"];
        NSArray* arrSecNote = [[DAOAdapter share] getObjects:[SecureNote class] condition:queryList orderBy:@"updateTS" isDescending:YES limit:MAXFLOAT];
        [secNoteListDelegate reloadNoteList:arrSecNote];
    }];
}

-(BOOL) displayMode{
    [NoteAdapter configMode];
    return [NoteAdapter getModeNote];
}

-(void) setDisplayMode:(BOOL) displayMode{
    [NoteAdapter setModeNote:displayMode];
}

@end
