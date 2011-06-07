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
		
		CCMenu *menu = [CCMenu menuWithItems: labelItem, nil];
		[menu alignItemsHorizontally];
		[self addChild: menu];
	
		
		// Init Video Player
		[CCVideoPlayer setDelegate: self];
	}
	return self;
}

- (void) testCCVideoPlayer
{
	[CCVideoPlayer playMovieWithFile: @"bait.mp4"];
}

- (void) moviePlaybackFinished
{
	[[CCDirector sharedDirector] startAnimation];
}

- (void) movieStartsPlaying
{
	[[CCDirector sharedDirector] stopAnimation];
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	
	// don't forget to call "super dealloc"
	[super dealloc];
}
@end
