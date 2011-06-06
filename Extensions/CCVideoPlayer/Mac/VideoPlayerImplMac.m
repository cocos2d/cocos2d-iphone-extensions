//
//  VideoPlayerImplMac.m
//  iTraceur for Mac
//
//  Created by Stepan Generalov on 05.01.11.
//  Copyright 2011 Parkour Games. All rights reserved.
//

#import "VideoPlayerImplMac.h"
#import "cocos2d.h"
#import "MyMovieView.h"
#import "CustomVideoViewController.h"

#if __MAC_OS_X_VERSION_MAX_ALLOWED

@interface VideoPlayerImplMac  (Private) <CCKeyboardEventDelegate>

-(void)movieFinishedCallback:(NSNotification*)aNotification;
-(BOOL) ccKeyDown:(NSEvent*)event;

@end



@implementation VideoPlayerImplMac

NSString *const kVideoTitle		= @"CustomVideoView";

@synthesize videoViewController;
@synthesize retainedView;


#pragma mark Interface 

- (void)playMovieAtURL:(NSURL*)theURL
{
	NSView *targetView = [[CCDirector sharedDirector] openGLView];
	[self playMovieAtURL: theURL attachedInView: targetView];
}


// start playing movie in new view, replacing and retaining targetView
- (void)playMovieAtURL:(NSURL*)theURL attachedInView: (NSView *) targetView
{		
	// Setup Movie	
	QTMovie* movie = [[QTMovie alloc] initWithURL:theURL error:nil];	
	if ( ! movie )
		return;
	
	// Prepare other systems for Playback
	[delegate movieStartsPlaying];
	
	//Setup Movie	
	[movie setAttribute:[NSNumber numberWithBool: YES] forKey:QTMovieOpenAsyncRequiredAttribute ];
	[movie setAttribute:[NSNumber numberWithBool: NO] forKey:QTMovieEditableAttribute];
	[movie setAttribute:[NSNumber numberWithBool: NO] forKey:QTMovieLoopsAttribute];
	
	//Get Movie View
	self.videoViewController =
		[[[CustomVideoViewController alloc] initWithNibName:kVideoTitle bundle:nil] autorelease];
	[(MyMovieView*)[self.videoViewController view] setMovie:movie];
	[(MyMovieView*)[self.videoViewController view] setPreservesAspectRatio:YES];
	[(MyMovieView*)[self.videoViewController view] setControllerVisible:NO];
		
	// Integrate Movie's View by Replacing the targetView from it's superview
	self.retainedView = targetView;
	NSView *windowContentView = [targetView superview];
	//[targetView removeFromSuperview];
	[windowContentView addSubview:[self.videoViewController view]];
	[[self.videoViewController view] setFrame: [windowContentView bounds]];
	
	// Start handling events on movie view
	[[CCEventDispatcher sharedDispatcher] addKeyboardDelegate: (MyMovieView *)[self.videoViewController view] 
													 priority: NSIntegerMin ];
		
	// Register for end notification
	[[NSNotificationCenter defaultCenter] addObserver: self 
											 selector:@selector(movieFinishedCallback:) 
												 name: QTMovieDidEndNotification 
											   object: movie];
	[movie play];
	[movie release];	
}

- (void) cancelPlaying
{	
	[self movieFinishedCallback: nil];
}

- (void)setDelegate: (id<VideoPlayerDelegate>) aDelegate;
{
	delegate = aDelegate;
}

#pragma mark Other Stuff

-(void)movieFinishedCallback:(NSNotification*)aNotification
{		
	// Stop receiving notifications
	QTMovie *movie = (QTMovie *)[aNotification object];	
    [[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: QTMovieDidEndNotification
                                                  object: movie ];
	
	// Stop Playing
	[movie stop];
	[(MyMovieView*)[self.videoViewController view] setMovie:nil];
    
	// switch from movie to retained view
	NSView *windowContentView = [[self.videoViewController view] superview];
	[[self.videoViewController view] removeFromSuperview];
	//[windowContentView addSubview: self.retainedView];
	[[self retainedView] setFrame:[windowContentView bounds]];
	
	// Stop handling events on movie view
	[[CCEventDispatcher sharedDispatcher] removeKeyboardDelegate: self];
	[[windowContentView window] makeFirstResponder: self.retainedView ];
	
	
	
	// release not needed views
	self.retainedView = nil;
	self.videoViewController = nil;
	
	[delegate moviePlaybackFinished];
}

@end

#endif
