/*
 * CCMenuItemSpriteIndependent Tests
 *
 * cocos2d-extensions
 * https://github.com/cocos2d/cocos2d-iphone-extensions
 *
 * Copyright (c) 2011-2012 Stepan Generalov
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

#import "CCMenuItemSpriteIndependentTestLayer.h"
#import "CCMenuItemSpriteIndependent.h"
#import "ExtensionTest.h"

SYNTHESIZE_EXTENSION_TEST(CCMenuItemSpriteIndependentTestLayer)

#if COCOS2D_VERSION >= 0x00020000

@interface CCMenuItemSprite (backwardCompatabilaty)

+(id) itemFromNormalSprite:(CCNode<CCRGBAProtocol>*)normalSprite selectedSprite:(CCNode<CCRGBAProtocol>*)selectedSprite target:(id)target selector:(SEL)selector;

@end

@implementation CCMenuItemSprite (backwardCompatabilaty)

+(id) itemFromNormalSprite:(CCNode<CCRGBAProtocol>*)normalSprite selectedSprite:(CCNode<CCRGBAProtocol>*)selectedSprite target:(id)target selector:(SEL)selector
{
    return [self itemWithNormalSprite: normalSprite selectedSprite: selectedSprite target: target selector: selector];
}

@end

@interface CCSpriteFrameCache (backwardCompatabilaty)

-(void) addSpriteFramesWithFile:(NSString*)plist textureFile:(NSString*)textureFileName;

@end

@implementation CCSpriteFrameCache (backwardCompatabilaty)

-(void) addSpriteFramesWithFile:(NSString*)plist textureFile:(NSString*)textureFileName;
{
    [self addSpriteFramesWithFile: plist textureFilename: textureFileName];
}

@end

#endif

// HelloWorldLayer implementation
@implementation CCMenuItemSpriteIndependentTestLayer

enum nodeTags
{
	kAboutBatchNode,
	kHighcoresNormalSprite,
	kHighcoresSelectedSprite,
	kPlayNode,
};

-(id) init
{
	if( (self=[super init])) 
	{
		// Prepare & AddChild batchNode Sprites
		[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"btn-about-spritesheet.plist" 
																 textureFile:@"btn-about-spritesheet.png"];
		CCSprite *aboutNormal = [CCSprite spriteWithSpriteFrameName:@"btn-about-normal.png"];
		CCSprite *aboutSelected = [CCSprite spriteWithSpriteFrameName:@"btn-about-selected.png"];
		CCSpriteBatchNode *bNode = [CCSpriteBatchNode batchNodeWithFile:@"btn-about-spritesheet.png"];
		[bNode addChild:aboutNormal];
		[bNode addChild:aboutSelected];
		[self addChild: bNode z: 0 tag: kAboutBatchNode];
		
		// Prepare & AddChild Independent Sprites
		CCSprite *highscoresNormal = [CCSprite spriteWithFile:@"btn-highscores-normal.png"];
		CCSprite *highscoresSelected = [CCSprite spriteWithFile:@"btn-highscores-selected.png"];
		
		[self addChild: highscoresNormal z: 0 tag:kHighcoresNormalSprite ];
		[self addChild: highscoresSelected z: 0 tag:kHighcoresSelectedSprite ];
		
		
		// Prepare & AddChild Sprites in Independent CCNode
		CCSprite *playNormal = [CCSprite spriteWithFile:@"btn-play-normal.png"];
		CCSprite *playSelected = [CCSprite spriteWithFile:@"btn-play-selected.png"];
		CCNode *node = [CCNode node];
#if COCOS2D_VERSION >= 0x00020000
        node.ignoreAnchorPointForPosition = NO;
#else
        node.isRelativeAnchorPoint = YES;
#endif
		node.contentSize = playNormal.contentSize;
		node.anchorPoint = ccp(0.5f, 0.5f);
		[node addChild: playNormal];
		[node addChild: playSelected];
		[self addChild: node z:0 tag: kPlayNode];
		
		// Rotate Independent CCNode
		[node runAction:[CCRepeatForever actionWithAction:[CCRotateBy actionWithDuration:5.0f angle:360.0f]]];
		
		// Prepare Menu Items
		CCMenuItemSpriteIndependent *item1 = 
			[CCMenuItemSpriteIndependent itemFromNormalSprite: aboutNormal
											   selectedSprite: aboutSelected
													   target: self
													 selector: @selector(aboutPressed:)];
		CCMenuItemSpriteIndependent *item2 = 
		[CCMenuItemSpriteIndependent itemFromNormalSprite: highscoresNormal
										   selectedSprite: highscoresSelected
												   target: self
												 selector: @selector(highscoresPressed:)];
		CCMenuItemSpriteIndependent *item3 = 
		[CCMenuItemSpriteIndependent itemFromNormalSprite: playNormal
										   selectedSprite: playSelected
												   target: self
												 selector: @selector(playPressed:)];
		
		// Add Menu
		CCMenu *menu = [CCMenu menuWithItems:item1, item2, item3, nil];
		[self addChild: menu];
		
		[self updateForScreenReshape];
		
	}
	return self;
}

- (void) updateForScreenReshape
{
	CGSize winSize = [CCDirector sharedDirector].winSize;
	
	CCSpriteBatchNode *bNode = (CCSpriteBatchNode *)[self getChildByTag: kAboutBatchNode];
	bNode.anchorPoint = ccp(0,0);
	bNode.position = ccp(0,0);
	for (CCNode *child in bNode.children)
	{
		child.anchorPoint = ccp(0.5f, 1);
		child.position = ccp(winSize.width/2.0f, winSize.height);
	}
	
	CCSprite *highscoresNormal = (CCSprite *)[self getChildByTag: kHighcoresNormalSprite];
	CCSprite *highscoresSelected = (CCSprite *)[self getChildByTag: kHighcoresSelectedSprite];
	highscoresNormal.anchorPoint = ccp(0.5, 0);
	highscoresSelected.anchorPoint = ccp(0.5, 0);
	highscoresNormal.position = ccp(winSize.width / 2.0f, 0);
	highscoresSelected.position = ccp(winSize.width / 2.0f, 0);
	
	CCNode *playNode = [self getChildByTag: kPlayNode];
	playNode.position = ccp(winSize.width/2.0f, winSize.height / 2.0f);
}

- (void) aboutPressed: (id) sender
{
	NSLog(@"about pressed!");
}

- (void) highscoresPressed: (id) sender
{
	NSLog(@"highscores pressed!");
}

- (void) playPressed: (id) sender
{
	NSLog(@"play pressed!");
}


@end
