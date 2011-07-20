/*
 * CCVideoPlayer Tests
 *
 * cocos2d-extensions
 * https://github.com/cocos2d/cocos2d-iphone-extensions
 *
 * Copyright (c) 2010-2011 Stepan Generalov
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


// Import the interfaces
#import "CCVideoTestLayer.h"
#import "CCVideoPlayer.h"
#import "ExtensionTest.h"

#ifdef __MAC_OS_X_VERSION_MAX_ALLOWED
#import "cocos2d_extensions_macAppDelegate.h"
#endif

SYNTHESIZE_EXTENSION_TEST(CCVideoTestLayer)

// HelloWorldLayer implementation
@implementation CCVideoTestLayer

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init])) {
		
		// Add button
		CCLabelTTF *label = [CCLabelTTF labelWithString:@"Play video" fontName:@"Marker Felt" fontSize:64];
		CCMenuItemLabel *labelItem = [CCMenuItemLabel itemWithLabel:label 
															 target: self 
														   selector: @selector(testCCVideoPlayer)];
		
		// Add button 2 - playback without skip.
		CCLabelTTF *labelNoSkip = [CCLabelTTF labelWithString:@"Play video(No skip)" fontName:@"Marker Felt" fontSize:64];
		CCMenuItemLabel *labelItemNoSkip = [CCMenuItemLabel itemWithLabel:labelNoSkip 
															 target: self 
														   selector: @selector(testCCVideoPlayerNoSkip)];
		
		CCMenu *menu = [CCMenu menuWithItems: labelItem, labelItemNoSkip, nil];
		[menu alignItemsVertically];
		[self addChild: menu];
	
		
		// Init Video Player
		[CCVideoPlayer setDelegate: self];
		
		// Listen for toggleFullscreen notifications on Mac.
#ifdef __MAC_OS_X_VERSION_MAX_ALLOWED
		[[NSNotificationCenter defaultCenter] addObserverForName: appDelegateToggleFullscreenNotification 
														  object: nil 
														   queue: nil 
													  usingBlock: ^(NSNotification *notification)
		 {
			 [CCVideoPlayer reAttachView];
		 }
		 ];
#endif
	}
	return self;
}

- (void) testCCVideoPlayer
{
	[CCVideoPlayer setNoSkip: NO];
	[CCVideoPlayer playMovieWithFile: @"bait.m4v"];
}

- (void) testCCVideoPlayerNoSkip
{
	[CCVideoPlayer setNoSkip: YES];
	[CCVideoPlayer playMovieWithFile: @"bait.m4v"];
}

- (void) moviePlaybackFinished
{
	[[CCDirector sharedDirector] startAnimation];
}

- (void) movieStartsPlaying
{
	[[CCDirector sharedDirector] stopAnimation];
}

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
// Updates orientation of CCVideoPlayer. Called from SharedSources/RootViewController.m
- (void) updateOrientationWithOrientation: (UIDeviceOrientation) newOrientation
{
	[CCVideoPlayer updateOrientationWithOrientation:newOrientation ];
}
#endif

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[super dealloc];
}
@end
