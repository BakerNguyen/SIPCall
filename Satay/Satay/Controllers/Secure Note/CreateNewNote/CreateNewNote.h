//
//  CreateNewNote.h
//  Satay
//
//  Created by Arpana Sakpal on 2/6/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CreateNewNote : UIViewController <UITextViewDelegate>
@property (nonatomic, retain) IBOutlet UITextView* txtNewNote;
@property (nonatomic, retain) NSString* fileName;

-(void) alertDeleteNote;
-(void) saveNote;
-(void) displaySecureNote:(NSString*) noteName;
-(void) closeNewNote;
-(void) displayKeyboard;

+(CreateNewNote *)share;

@end
