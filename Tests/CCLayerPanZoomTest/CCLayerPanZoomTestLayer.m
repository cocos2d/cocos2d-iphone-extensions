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
#import "CCLayerPanZoomTestLayer.h"
#import "ExtensionTest.h"

SYNTHESIZE_EXTENSION_TEST(CCLayerPanZoomTestLayer)


enum nodeTags
{
	kBackgroundTag,
	kLabelTag,
};

@implementation CCLayerPanZoomTestLayer

+ (CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	CCLayerPanZoomTestLayer *layer = [CCLayerPanZoomTestLayer node];
	
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
		self.delegate = self; //< TODO: very bad, i know, but it's just for testing click.
		
        // background
        CCSprite *background = [CCSprite spriteWithFile: @"background.png"];
        background.anchorPoint = ccp(0,0);
		background.scale = CC_CONTENT_SCALE_FACTOR();
        [self addChild: background z:0 tag: kBackgroundTag];
		
		
		// create and initialize a Label
		CCLabelTTF *label = [CCLabelTTF labelWithString: @"Try panning and zooming using drag and pinch" 
                                               fontName: @"Marker Felt" 
                                               fontSize: 32];
		label.scale = 0.7f; //< to be visible on iPod Touch screen.
		label.color = ccWHITE;
		
		
        
		
		// add the label as a child to this Layer
		[self addChild: label z: 1 tag: kLabelTag];
		
		[self updateForScreenReshape];
	}	
	return self;
}

- (void) updateForScreenReshape
{
	CGSize winSize = [[CCDirector sharedDirector] winSize];
	
	
	CCNode *background = [self getChildByTag: kBackgroundTag];
	// our bounding rect
	CGRect boundingRect = CGRectMake(0, 0, 0, 0);
	boundingRect.size = [background boundingBox].size;
	[self setContentSize: boundingRect.size];
	
	self.panBoundsRect = CGRectMake(0, 0, winSize.width, winSize.height);
	
	self.anchorPoint = ccp(0.5f, 0.5f);
	self.position = ccp(0.5f * winSize.width, 0.5f * winSize.height);
	
	// position the label on the center of the bounds
	CCNode *label = [self getChildByTag: kLabelTag];
	label.position =  ccp(boundingRect.size.width * 0.5f, boundingRect.size.height * 0.5f);
}

- (void) onExit
{
	[[self retain] autorelease]; //< Absolutely hackish and stupid =)))
	self.delegate = nil;
	
	[super onExit];
}

- (void) layerPanZoom: (CCLayerPanZoom *) sender 
	   clickedAtPoint: (CGPoint) point
{
	NSLog(@"CCLayerPanZoomTestLayer#layerPanZoom: %@ clickedAtPoint: { %f, %f }", sender, point.x, point.y);
}
- (void) layerPanZoom: (CCLayerPanZoom *) sender 
 touchPositionUpdated: (CGPoint) newPos
{
    NSLog(@"CCLayerPanZoomTestLayer#layerPanZoom: %@ touchPositionUpdated: { %f, %f }", sender, newPos.x, newPos.y);
}

@end
