//
//  CreateNewNote.m
//  KryptoChat
//
//  Created by TrungVN on 5/28/14.
//  Copyright (c) 2014 mTouche. All rights reserved.
//

#import "CreateNewNote.h"

@interface CreateNewNote ()

@end

@implementation CreateNewNote
@synthesize txtNewNote;
@synthesize fileName;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = TITLE_SECURE_NOTES;
    
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem createLeftButtonTitle:_CANCEL
                                                                            Target:self
                                                                            Action:@selector(closeNewNote)];
    
    txtNewNote.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:IMG_SECURE_BACKGROUND_TILE]];
    txtNewNote.delegate = self;
    txtNewNote.font = [UIFont systemFontOfSize:17.f];
    
    UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(displayKeyboard)];
    [tapGesture setCancelsTouchesInView:NO];
    [txtNewNote addGestureRecognizer:tapGesture];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showKeyboard:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideKeyboard:) name:UIKeyboardWillHideNotification object:nil];
}

-(void)viewWillAppear:(BOOL)animated
{
    [self displaySecureNote:self.fileName];
    SEL selector = NULL;
    NSString* rightButtonTitle = @"";
    if (txtNewNote.text.length > 0){
        selector = @selector(alertDeleteNote);
        rightButtonTitle = _DELETE;
    }
    else{
        selector = @selector(saveNote);
        rightButtonTitle = _SAVE;
        [txtNewNote becomeFirstResponder];
    }
    
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem createRightButtonTitle:rightButtonTitle
                                                                              Target:self
                                                                              Action:selector];
}

-(void) showKeyboard:(NSNotification*) notifi{
    CGRect _keyboardEndFrame;
    [[notifi.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue:&_keyboardEndFrame];
    CGFloat keyboardHeight = _keyboardEndFrame.size.height;
    [txtNewNote changeWidth:txtNewNote.width Height:self.view.height - keyboardHeight];
    
    [txtNewNote scrollRectToVisible:CGRectMake(1, txtNewNote.contentSize.height, 1, 1) animated:NO];
}

-(void) hideKeyboard:(NSNotification*) notifi{
    CGRect _keyboardEndFrame;
    [[notifi.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue:&_keyboardEndFrame];
    CGFloat keyboardHeight = _keyboardEndFrame.size.height;
    [txtNewNote changeWidth:txtNewNote.width Height:txtNewNote.height + keyboardHeight];
}

-(void) alertDeleteNote{
    [[CAlertView new] showWarning:WARNING_ARE_YOU_SURE_DELETE_NOTE TARGET:self ACTION:@selector(deleteNote)];
}

-(void) deleteNote{
    [[SecureNoteFacade share] deleteNote:self.fileName];
    [self closeNewNote];
}

-(void) saveNote
{
    NSString* strContent = txtNewNote.text;
    if ([strContent stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length <= 0) {
        [[CAlertView new] showError:ERROR_NOTE_BLANK];
        return;
    }
    
    [[SecureNoteFacade share] saveNote:self.fileName
                               content:strContent];
    
    [self closeNewNote];
}

-(void) displaySecureNote:(NSString*) noteName{
    SecureNote* secNote = [[SecureNoteFacade share] getSecureNote:noteName];
    if (secNote) {
        txtNewNote.text = [[SecureNoteFacade share] contentNote:noteName];
    }
    else{
        txtNewNote.text = @"";
    }
}

-(void) closeNewNote{
    [self dismissViewControllerAnimated:TRUE completion:nil];
    [[SecureNoteFacade share] showNoteList];
}

-(void) displayKeyboard{
    if ([txtNewNote isFirstResponder]){
        [txtNewNote resignFirstResponder];
    }
    else{
        [txtNewNote becomeFirstResponder];
    }
}

//DELEGATE OF TEXTVIEW
-(void) textViewDidChange:(UITextView *)textView{
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem createRightButtonTitle:_SAVE
                                                                              Target:self
                                                                              Action:@selector(saveNote)];
}

+(CreateNewNote *)share{
    static dispatch_once_t once;
    static CreateNewNote * share;
    dispatch_once(&once, ^{
        share = [self new];
    });
    return share;
}

@end
