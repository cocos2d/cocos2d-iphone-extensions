/*
 * CCVideoPlayer
 *
 * Cocos2D-iPhone-Extensions v0.2.1
 * https://github.com/cocos2d/cocos2d-iphone-extensions
 *
 * Copyright (c) 2010-2012 Stepan Generalov
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */

#if __MAC_OS_X_VERSION_MAX_ALLOWED

#import <Cocoa/Cocoa.h>
#import <QTKit/QTKit.h>
#import "CCVideoPlayer.h"

@class CustomVideoViewController;
@class MyMovieView;

#define VIDEO_PLAYER_IMPL_SUPER_CLASS CCVideoPlayerImplMac
@interface CCVideoPlayerImplMac : NSObject
{	
	NSViewController *videoViewController;	
	NSView *retainedView;
	
	//weak ref
	NSObject<CCVideoPlayerDelegate> *delegate;
	
	BOOL isPlaying;
	BOOL noSkip;
}
//private property
@property (readwrite, retain) NSViewController *videoViewController;
@property (readwrite, retain) NSView *retainedView;
@property (readonly) BOOL isPlaying;

- (void)playMovieAtURL:(NSURL*)theURL;
- (void)playMovieAtURL:(NSURL*)theURL attachedInView: (NSView *) aView;

- (void)setNoSkip:(BOOL)value;

- (void)userCancelPlaying;
- (void)cancelPlaying;

- (void)setDelegate: (id<CCVideoPlayerDelegate>) aDelegate;

/** reattaches MyMovieView to the Cocos Window.
 Call it after changing to/from fullscreen. */
- (void) reAttachView;

@end

#endif
