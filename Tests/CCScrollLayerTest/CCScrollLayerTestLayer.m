/*
 * CCScrollLayer Tests
 *
 * cocos2d-extensions
 * https://github.com/cocos2d/cocos2d-iphone-extensions
 *
 * Copyright (c) 2010 Giv Parvaneh
 * Copyright (c) 2011 Stepan Generalov
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
#import "CCScrollLayerTestLayer.h"
#import "CCScrollLayer.h"
#import "ExtensionTest.h"

SYNTHESIZE_EXTENSION_TEST(CCScrollLayerTestLayer)


@implementation CCScrollLayerTestLayer

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init])) {
		
		// get screen size
		CGSize screenSize = [CCDirector sharedDirector].winSize;
		
		//  Use 2D Projection to avoid issue #23
		[[CCDirector sharedDirector] setProjection: kCCDirectorProjection2D];
		
		/////////////////////////////////////////////////
		// PAGE 1
		////////////////////////////////////////////////
		// create a blank layer for page 1
		CCLayer *pageOne = [CCLayer node];
		
		// create a label for page 1
		CCLabelTTF *label = [CCLabelTTF labelWithString:@"Page 1" fontName:@"Arial Rounded MT Bold" fontSize:44];
		label.position =  ccp( screenSize.width /2 , screenSize.height/2 );
		
		// add label to page 1 layer
		[pageOne addChild:label];
		
		/////////////////////////////////////////////////
		// PAGE 2
		////////////////////////////////////////////////
		// create a blank layer for page 2
		CCLayer *pageTwo = [CCLayer node];;
		
		// create a custom font menu for page 2
		CCLabelTTF *labelTwo = [CCLabelTTF labelWithString:@"Press Me!" fontName:@"Marker Felt" fontSize:44];		
		CCMenuItemLabel *titem = [CCMenuItemLabel itemWithLabel:labelTwo target:self selector:@selector(testCallback:)];
		CCMenu *menu = [CCMenu menuWithItems: titem, nil];
		menu.position = ccp(screenSize.width/2, screenSize.height/2);
		
		// add menu to page 2
		[pageTwo addChild:menu];
		
		
		/////////////////////////////////////////////////
		// PAGE 3
		////////////////////////////////////////////////
		CCLayer *pageThree = [CCLayerColor layerWithColor:ccc4(255, 0, 0, 128)];
		
		////////////////////////////////////////////////
		
		// now create the scroller and pass-in the pages (set widthOffset to 0 for fullscreen pages)
		CCScrollLayer *scroller = [[CCScrollLayer alloc] initWithLayers:[NSMutableArray arrayWithObjects: pageOne,pageTwo,pageThree,nil] widthOffset: 230];
		
		// finally add the scroller to your scene
		[self addChild:scroller];
	
	}
	return self;
}

- (void) testCallback: (CCNode *) sender
{
	NSLog(@"test callback called!");
}

@end


