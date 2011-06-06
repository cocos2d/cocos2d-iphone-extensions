//
//  MyMovieView.m
//  ViewController
//
//  Created by Stepan Generalov on 06.01.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#ifdef __MAC_OS_X_VERSION_MAX_ALLOWED

#import "MyMovieView.h"
#import "VideoPlayer.h"


@implementation MyMovieView

- (void)rightMouseDown:(NSEvent *)theEvent
{
	[VideoPlayer cancelPlaying];
}

- (void)otherMouseDown:(NSEvent *)theEvent
{
	[VideoPlayer cancelPlaying];
}

- (void)scrollWheel:(NSEvent *)theEvent
{
}

- (void) mouseDown:(NSEvent *)theEvent
{
	[VideoPlayer cancelPlaying];
}

- (void) keyDown:(NSEvent *)theEvent
{
	if ( ![theEvent isARepeat] )
		[VideoPlayer cancelPlaying];
}

-(BOOL) ccKeyDown:(NSEvent*)event
{
	if ( ![event isARepeat] )
		[VideoPlayer cancelPlaying];
	
	return NO;
}

- (void)viewDidMoveToWindow
{	
	NSWindow *window = [self window];
	if ( window )
	{
		[[self window] makeFirstResponder: self];
	}
}

-(BOOL) becomeFirstResponder
{
	return YES;
}

-(BOOL) acceptsFirstResponder
{
	return YES;
}

-(BOOL) resignFirstResponder
{
	return YES;
}

@end

#endif
