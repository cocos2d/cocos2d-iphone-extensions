/*
 * CCSendMessages Tests
 *
 * cocos2d-extensions
 * https://github.com/cocos2d/cocos2d-iphone-extensions
 *
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
#import "CCSendMessagesTestLayer.h"
#import "CCSendMessages.h"
#import "ExtensionTest.h"

SYNTHESIZE_EXTENSION_TEST(CCSendMessagesTestLayer)

enum nodeTags
{
	kLabelTag,
	kMenu,
};

@implementation CCSendMessagesTestLayer

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init])) {
		
		// Add label
		CCLabelTTF *label = [CCLabelTTF labelWithString:@"Press \"Go\"!" fontName:@"Marker Felt" fontSize:32];
		[self addChild: label z: 0 tag: kLabelTag];
		
		// Add button.
		CCLabelTTF *labelGo = [CCLabelTTF labelWithString:@"GO!" fontName:@"Marker Felt" fontSize:64];
		CCMenuItemLabel *menuItem = [CCMenuItemLabel itemWithLabel:labelGo target:self selector:@selector(goPressed:)];
		CCMenu *menu = [CCMenu menuWithItems: menuItem, nil];
		[self addChild:menu z:0 tag:kMenu];
		
		[self updateForScreenReshape];
	
	}
	return self;
}

- (void) goPressed: (CCNode *) sender
{
	// Avoid conflicts with running actions.
	[self stopAllActions];
	
	// Prepare 'Reset' action for Label
	CCSendMessages *action = [CCSendMessages actionWithTarget:[self getChildByTag: kLabelTag]];
	[[action addMessage] stopAllActions];
	[[action addMessage] setRotation: 0.0f];
	
	// Sequence of actions, that will change label's string.
	CCSendMessages *action2 = [CCSendMessages actionWithTarget:[self getChildByTag: kLabelTag]];
	[[action2 addMessage] setString:@"One"];	
	
	CCSendMessages *action3 = [CCSendMessages actionWithTarget:[self getChildByTag: kLabelTag]];
	[[action3 addMessage] setString:@"Two"];	
	
	CCSendMessages *action4 = [CCSendMessages actionWithTarget:[self getChildByTag: kLabelTag]];
	[[action4 addMessage] setString:@"Three"];
	
	CCSendMessages *action5 = [CCSendMessages actionWithTarget:[self getChildByTag: kLabelTag]];
	[[action5 addMessage] setString:@"AH!"];
	
	// Last action for Label - start infinite rotation.
	id actionForLabel = [CCRepeatForever actionWithAction:[CCRotateBy actionWithDuration:3.0f angle:360.0f]];
	CCSendMessages *action6 = [CCSendMessages actionWithTarget:[self getChildByTag: kLabelTag]];
	[[action6 addMessage] runAction: actionForLabel];
	
	// CCSendMessage Action with target = nil.
	CCSendMessages *badAction = [CCSendMessages actionWithTarget: nil];
	[[badAction addMessage] setString:@"THIS WILL NOT WORK!"];
	
	// Prepare sequence on all this CCSendMessages actions with delays between them.
	id actionSequenceForSelf = [CCSequence actions: action, [CCDelayTime actionWithDuration:0.3f], 
								action2, [CCDelayTime actionWithDuration:0.5f], 
								action3, [CCDelayTime actionWithDuration:0.5f], 
								action4, [CCDelayTime actionWithDuration:0.5f], 
								action5, [CCDelayTime actionWithDuration:0.5f],
								action6, badAction, nil];
	
	// Run action on self (CCSendMessagesTestLayer), that will send messages to CCLabel via CCSendMessages
	[self runAction: actionSequenceForSelf ];
}

- (void) updateForScreenReshape
{
	CGSize s = [CCDirector sharedDirector].winSize;
	
	CCNode *label = [self getChildByTag: kLabelTag];
	label.anchorPoint = ccp(0.5f, 0.5f );
	
	CCMenu *menu = (CCMenu *)[self getChildByTag: kMenu];
	menu.contentSize = s;
	[menu alignItemsVertically];
	
	label.position = ccp(s.width/2.0f, 0.75f * s.height);
}

@end


