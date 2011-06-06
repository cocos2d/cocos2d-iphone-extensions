//
//  VideoPlayerImplMac.h
//  iTraceur for Mac
//
//  Created by Stepan Generalov on 05.01.11.
//  Copyright 2011 Parkour Games. All rights reserved.
//

#if __MAC_OS_X_VERSION_MAX_ALLOWED

#import <Cocoa/Cocoa.h>
#import <QTKit/QTKit.h>
#import "VideoPlayer.h"

@class CustomVideoViewController;
@class MyMovieView;

#define VIDEO_PLAYER_IMPL_SUPER_CLASS VideoPlayerImplMac
@interface VideoPlayerImplMac : NSObject
{	
	NSViewController *videoViewController;	
	NSView *retainedView;
	
	//weak ref
	id<VideoPlayerDelegate> delegate;
}
//private property
@property (readwrite, retain) NSViewController *videoViewController;
@property (readwrite, retain) NSView *retainedView;

- (void)playMovieAtURL:(NSURL*)theURL;
- (void)playMovieAtURL:(NSURL*)theURL attachedInView: (NSView *) aView;
- (void)cancelPlaying;

- (void)setDelegate: (id<VideoPlayerDelegate>) aDelegate;

@end

#endif
