/*
 * CCVideoPlayer Tests
 *
 * cocos2d-extensions
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
		
		// Add button "Play video(File)".
		CCLabelTTF *labelFile = [CCLabelTTF labelWithString:@"Play video(File)" fontName:@"Marker Felt" fontSize:52];
		CCMenuItemLabel *labelItemFile = [CCMenuItemLabel itemWithLabel:labelFile 
															 target: self 
														   selector: @selector(testCCVideoPlayerFile)];
		
		// Add button "Play video(Path)".
		CCLabelTTF *labelPath = [CCLabelTTF labelWithString:@"Play video(Path)" fontName:@"Marker Felt" fontSize:52];
		CCMenuItemLabel *labelItemPath = [CCMenuItemLabel itemWithLabel:labelPath 
															 target: self 
														   selector: @selector(testCCVideoPlayerPath)];
        
        // Add toggle "NoSkip = NO|YES".
        CCLabelTTF *labelNoSkipNo = [CCLabelTTF labelWithString:@"NoSkip:NO" fontName:@"Marker Felt" fontSize:34];
        CCLabelTTF *labelNoSkipYes = [CCLabelTTF labelWithString:@"NoSkip:YES" fontName:@"Marker Felt" fontSize:34];
		CCMenuItemToggle *labelItemSkipToggle = [CCMenuItemToggle itemWithTarget: self
                                                                       selector: @selector(toggleNoSkip:)
                                                                          items: [CCMenuItemLabel itemWithLabel:labelNoSkipNo],
                                                                                 [CCMenuItemLabel itemWithLabel:labelNoSkipYes],
                                                nil];
		
		CCMenu *menu = [CCMenu menuWithItems: labelItemFile, labelItemPath, labelItemSkipToggle, nil];
		[menu alignItemsVertically];
		[self addChild: menu];
	
		
		// Init Video Player
        [CCVideoPlayer setNoSkip: NO];
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

- (void) toggleNoSkip: (CCMenuItemToggle *) toggle
{
    switch (toggle.selectedIndex) {
        case 0:
            [CCVideoPlayer setNoSkip: NO];
            break;
        case 1:
            [CCVideoPlayer setNoSkip: YES];
            break;
            
        default:
            break;
    }    
}

- (void) testCCVideoPlayerFile
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"bait" ofType:@"m4v" ];
	[CCVideoPlayer playMovieWithPath: path];
}

- (void) testCCVideoPlayerPath
{
	[CCVideoPlayer playMovieWithFile: @"bait.m4v"];
}

- (void) moviePlaybackFinished
{
    // Avoid crashes on 2.x cocos2d-iphone Mac (workaround for Issue #104).
#if COCOS2D_VERSION >= 0x00020000 && defined (__MAC_OS_X_VERSION_MAX_ALLOWED)
    return;
#endif
    
	[[CCDirector sharedDirector] startAnimation];
}

- (void) movieStartsPlaying
{
    // Avoid crashes on 2.x cocos2d-iphone Mac (workaround for Issue #104).
#if COCOS2D_VERSION >= 0x00020000 && defined (__MAC_OS_X_VERSION_MAX_ALLOWED)
    return;
#endif
    
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
