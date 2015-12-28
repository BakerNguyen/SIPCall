/*
 Copyright (c) 2010, Stig Brautaset.
 All rights reserved.
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are
 met:
   Redistributions of source code must retain the above copyright
   notice, this list of conditions and the following disclaimer.
   Redistributions in binary form must reproduce the above copyright
   notice, this list of conditions and the following disclaimer in the
   documentation and/or other materials provided with the distribution.
   Neither the name of the the author nor the names of its contributors
   may be used to endorse or promote products derived from this software
   without specific prior written permission.
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
 IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
 TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
 PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
#if !__has_feature(objc_arc)
#error "This source file must be compiled with ARC enabled!"
#endif
#import "SBJsonStreamParserState_XMPP.h"
#define SINGLETON \
+(id)share { \
    static id state = nil; \
    if (!state) { \
        @synchronized(self) { \
            if (!state) state = [[self alloc] init]; \
        } \
    } \
    return state; \
}
@implementation SBJsonStreamParserState_XMPP
+(id)share { return nil; }
-(BOOL)parser:(SBJsonStreamParser_XMPP*)parser shouldAcceptToken:(sbjson_token_t)token {
	return NO;
}
-(SBJsonStreamParserStatus)parserShouldReturn:(SBJsonStreamParser_XMPP*)parser {
	return SBJsonStreamParserWaitingForData;
}
-(void)parser:(SBJsonStreamParser_XMPP*)parser shouldTransitionTo:(sbjson_token_t)tok {}
-(BOOL)needKey {
	return NO;
}
-(NSString*)name {
	return @"<aaiie!>";
}
-(BOOL)isError {
    return NO;
}
@end
#pragma mark -
@implementation SBJsonStreamParserStateStart_XMPP
SINGLETON
-(BOOL)parser:(SBJsonStreamParser_XMPP*)parser shouldAcceptToken:(sbjson_token_t)token {
	return token == sbjson_token_array_start || token == sbjson_token_object_start;
}
-(void)parser:(SBJsonStreamParser_XMPP*)parser shouldTransitionTo:(sbjson_token_t)tok {
	SBJsonStreamParserState_XMPP *state = nil;
	switch (tok) {
		case sbjson_token_array_start:
			state = [SBJsonStreamParserStateArrayStart_XMPP share];
			break;
		case sbjson_token_object_start:
			state = [SBJsonStreamParserStateObjectStart_XMPP share];
			break;
		case sbjson_token_array_end:
		case sbjson_token_object_end:
			if (parser.supportMultipleDocuments)
				state = parser.state;
			else
				state = [SBJsonStreamParserStateComplete_XMPP share];
			break;
		case sbjson_token_eof:
			return;
		default:
			state = [SBJsonStreamParserStateError_XMPP share];
			break;
	}

	parser.state = state;
}
-(NSString*)name { return @"before outer-most array or object"; }
@end
#pragma mark -
@implementation SBJsonStreamParserStateComplete_XMPP
SINGLETON
-(NSString*)name { return @"after outer-most array or object"; }
-(SBJsonStreamParserStatus)parserShouldReturn:(SBJsonStreamParser_XMPP*)parser {
	return SBJsonStreamParserComplete;
}
@end
#pragma mark -
@implementation SBJsonStreamParserStateError_XMPP
SINGLETON
-(NSString*)name { return @"in error"; }
-(SBJsonStreamParserStatus)parserShouldReturn:(SBJsonStreamParser_XMPP*)parser {
	return SBJsonStreamParserError;
}
-(BOOL)isError {
    return YES;
}
@end
#pragma mark -
@implementation SBJsonStreamParserStateObjectStart_XMPP
SINGLETON
-(NSString*)name { return @"at beginning of object"; }
-(BOOL)parser:(SBJsonStreamParser_XMPP*)parser shouldAcceptToken:(sbjson_token_t)token {
	switch (token) {
		case sbjson_token_object_end:
		case sbjson_token_string:
			return YES;
			break;
		default:
			return NO;
			break;
	}
}
-(void)parser:(SBJsonStreamParser_XMPP*)parser shouldTransitionTo:(sbjson_token_t)tok {
	parser.state = [SBJsonStreamParserStateObjectGotKey_XMPP share];
}
-(BOOL)needKey {
	return YES;
}
@end
#pragma mark -
@implementation SBJsonStreamParserStateObjectGotKey_XMPP
SINGLETON
-(NSString*)name { return @"after object key"; }
-(BOOL)parser:(SBJsonStreamParser_XMPP*)parser shouldAcceptToken:(sbjson_token_t)token {
	return token == sbjson_token_keyval_separator;
}
-(void)parser:(SBJsonStreamParser_XMPP*)parser shouldTransitionTo:(sbjson_token_t)tok {
	parser.state = [SBJsonStreamParserStateObjectSeparator_XMPP share];
}
@end
#pragma mark -
@implementation SBJsonStreamParserStateObjectSeparator_XMPP
SINGLETON
-(NSString*)name { return @"as object value"; }
-(BOOL)parser:(SBJsonStreamParser_XMPP*)parser shouldAcceptToken:(sbjson_token_t)token {
	switch (token) {
		case sbjson_token_object_start:
		case sbjson_token_array_start:
		case sbjson_token_true:
		case sbjson_token_false:
		case sbjson_token_null:
		case sbjson_token_number:
		case sbjson_token_string:
			return YES;
			break;
		default:
			return NO;
			break;
	}
}
-(void)parser:(SBJsonStreamParser_XMPP*)parser shouldTransitionTo:(sbjson_token_t)tok {
	parser.state = [SBJsonStreamParserStateObjectGotValue_XMPP share];
}
@end
#pragma mark -
@implementation SBJsonStreamParserStateObjectGotValue_XMPP
SINGLETON
-(NSString*)name { return @"after object value"; }
-(BOOL)parser:(SBJsonStreamParser_XMPP*)parser shouldAcceptToken:(sbjson_token_t)token {
	switch (token) {
		case sbjson_token_object_end:
		case sbjson_token_separator:
			return YES;
			break;
		default:
			return NO;
			break;
	}
}
-(void)parser:(SBJsonStreamParser_XMPP*)parser shouldTransitionTo:(sbjson_token_t)tok {
	parser.state = [SBJsonStreamParserStateObjectNeedKey_XMPP share];
}

@end
#pragma mark -
@implementation SBJsonStreamParserStateObjectNeedKey_XMPP
SINGLETON
-(NSString*)name { return @"in place of object key"; }
-(BOOL)parser:(SBJsonStreamParser_XMPP*)parser shouldAcceptToken:(sbjson_token_t)token {
    return sbjson_token_string == token;
}
-(void)parser:(SBJsonStreamParser_XMPP*)parser shouldTransitionTo:(sbjson_token_t)tok {
	parser.state = [SBJsonStreamParserStateObjectGotKey_XMPP share];
}
-(BOOL)needKey {
	return YES;
}
@end
#pragma mark -
@implementation SBJsonStreamParserStateArrayStart_XMPP
SINGLETON
-(NSString*)name { return @"at array start"; }
-(BOOL)parser:(SBJsonStreamParser_XMPP*)parser shouldAcceptToken:(sbjson_token_t)token {
	switch (token) {
		case sbjson_token_object_end:
		case sbjson_token_keyval_separator:
		case sbjson_token_separator:
			return NO;
			break;
		default:
			return YES;
			break;
	}
}
-(void)parser:(SBJsonStreamParser_XMPP*)parser shouldTransitionTo:(sbjson_token_t)tok {
	parser.state = [SBJsonStreamParserStateArrayGotValue_XMPP share];
}
@end
#pragma mark -
@implementation SBJsonStreamParserStateArrayGotValue_XMPP
SINGLETON
-(NSString*)name { return @"after array value"; }

-(BOOL)parser:(SBJsonStreamParser_XMPP*)parser shouldAcceptToken:(sbjson_token_t)token {
	return token == sbjson_token_array_end || token == sbjson_token_separator;
}
-(void)parser:(SBJsonStreamParser_XMPP*)parser shouldTransitionTo:(sbjson_token_t)tok {
	if (tok == sbjson_token_separator)
		parser.state = [SBJsonStreamParserStateArrayNeedValue_XMPP share];
}
@end
#pragma mark -
@implementation SBJsonStreamParserStateArrayNeedValue_XMPP
SINGLETON
-(NSString*)name { return @"as array value"; }

-(BOOL)parser:(SBJsonStreamParser_XMPP*)parser shouldAcceptToken:(sbjson_token_t)token {
	switch (token) {
		case sbjson_token_array_end:
		case sbjson_token_keyval_separator:
		case sbjson_token_object_end:
		case sbjson_token_separator:
			return NO;
			break;
		default:
			return YES;
			break;
	}
}
-(void)parser:(SBJsonStreamParser_XMPP*)parser shouldTransitionTo:(sbjson_token_t)tok {
	parser.state = [SBJsonStreamParserStateArrayGotValue_XMPP share];
}
@end