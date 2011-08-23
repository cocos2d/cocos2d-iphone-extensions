/*
 * CCLayerPanZoom Tests
 *
 * cocos2d-extensions
 * https://github.com/cocos2d/cocos2d-iphone-extensions
 *
 * Copyright (c) 2011 Alexey Lang
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
#import "CCLayerPanZoomTest.h"
#import "ExtensionTest.h"

SYNTHESIZE_EXTENSION_TEST(CCLayerPanZoomTest)

@implementation CCLayerPanZoomTest

+ (CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	CCLayerPanZoomTest *layer = [CCLayerPanZoomTest node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

- (id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if((self = [super init])) 
    {
        // our bounding rect
        CGRect boundingRect = CGRectMake(0, 0, 964, 700);
		[self setContentSize: boundingRect.size];
        
        // background
        CCSprite *background = [CCSprite spriteWithFile: @"background.png"];
        background.anchorPoint = ccp(0,0);
        [self addChild: background];
		
		// create and initialize a Label
		CCLabelTTF *label = [CCLabelTTF labelWithString: @"Try panning and zooming using drag and pinch" 
                                               fontName: @"Marker Felt" 
                                               fontSize: 32];
		
		
		// position the label on the center of the bounds
		label.position =  ccp(boundingRect.size.width * 0.5f, boundingRect.size.height * 0.5f);
        label.color = ccWHITE;
		
		// add the label as a child to this Layer
		[self addChild: label];
	}	
	return self;
}

- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	// don't forget to call "super dealloc"
	[super dealloc];
}
@end
