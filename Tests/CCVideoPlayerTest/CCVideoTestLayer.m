//
//  HelloWorldLayer.m
//  CCVideoPlayer
//
//  Created by Stepan Generalov on 12.04.11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//


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
