/*
 * CCScrollLayer Tests
 *
 * cocos2d-extensions
 * https://github.com/cocos2d/cocos2d-iphone-extensions
 *
 * Copyright (c) 2010 Giv Parvaneh
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


// Import the interfaces
#import "CCScrollLayerTestLayer.h"
#import "CCScrollLayer.h"
#import "ExtensionTest.h"

SYNTHESIZE_EXTENSION_TEST(CCScrollLayerTestLayer)

@interface CCMenu (UnselectSelectedItem)
- (void) unselectSelectedItem;
@end

@implementation CCMenu (UnselectSelectedItem)

- (void) unselectSelectedItem
{
	if(state_ == kCCMenuStateTrackingTouch)
	{
		[selectedItem_ unselected];		
		state_ = kCCMenuStateWaiting;
		selectedItem_ = nil;
	}
}

@end

#pragma mark -

@interface CCScrollLayerTestLayer (ScrollLayerCreation)

- (NSArray *) scrollLayerPages;
- (CCScrollLayer *) scrollLayer;
- (void) updateFastPageChangeMenu;

@end


@implementation CCScrollLayerTestLayer

enum nodeTags
{
	kScrollLayer = 256,
	kAdviceLabel = 257,
	kFastPageChangeMenu = 258,
};

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init])) {
		
		// Add fast page change menu.
		[self updateFastPageChangeMenu];
		
		// Add advice about how to use the test
		CCLabelTTF *adviceLabel = [CCLabelTTF labelWithString:@"Press numbers at the bottom, or swipe to change screen." fontName:@"Marker Felt" fontSize:20];
		[self addChild: adviceLabel z: 0 tag: kAdviceLabel];
		
		// Do initial positioning & create scrollLayer.
		[self updateForScreenReshape];
	}
	return self;
}

// Removes old "0 1 2" menu and creates new for actual pages count.
- (void) updateFastPageChangeMenu
{
	// Remove fast page change menu if it exists.
	[self removeChildByTag:kFastPageChangeMenu cleanup:YES];
	
	// Get total current pages count.
	int pagesCount = [[self scrollLayerPages]count];
	CCScrollLayer *scroller = (CCScrollLayer *)[self getChildByTag:kScrollLayer];
	if (scroller)
	{
		pagesCount = [[scroller pages] count];
	}
	
	// Create & add fast-page-change menu.
	CCMenu *fastPageChangeMenu = [CCMenu menuWithItems: nil];
	for (int i = 0; i < pagesCount ; ++i)
	{
		NSString *numberString = [NSString stringWithFormat:@"%d", i];
		CCLabelTTF *labelWithNumber = [CCLabelTTF labelWithString:numberString fontName:@"Marker Felt" fontSize:22];		
		CCMenuItemLabel *item = [CCMenuItemLabel itemWithLabel:labelWithNumber target:self selector:@selector(fastMenuItemPressed:)];
		[fastPageChangeMenu addChild: item z: 0 tag: i];
	}
	[fastPageChangeMenu alignItemsHorizontally];
	[self addChild: fastPageChangeMenu z: 0 tag: kFastPageChangeMenu];
	
	// Position fast page change menu without calling updateForScreenReshape.
	CGSize screenSize = [CCDirector sharedDirector].winSize;
	fastPageChangeMenu.position = ccp( 0.5f * screenSize.width, 15.0f);
}

// Positions children of CCScrollLayerTestLayer.
// ScrollLayer is updated via deleting old and creating new one. 
// (Cause it's created with pages - normal CCLayer, which contentSize = winSize)
- (void) updateForScreenReshape
{
	CGSize screenSize = [CCDirector sharedDirector].winSize;
	
	CCNode *fastPageChangeMenu = [self getChildByTag:kFastPageChangeMenu];
	CCNode *adviceLabel = [self getChildByTag:kAdviceLabel];
	
	fastPageChangeMenu.position = ccp( 0.5f * screenSize.width, 15.0f); 
	adviceLabel.anchorPoint = ccp(0.5f, 1.0f);
	adviceLabel.position = ccp(0.5f * screenSize.width, screenSize.height);
	
	// ReCreate Scroll Layer for each Screen Reshape (slow, but easy).
	CCScrollLayer *scrollLayer = (CCScrollLayer *)[self getChildByTag:kScrollLayer];
	if (scrollLayer)
	{
		[self removeChild:scrollLayer cleanup:YES];
	}
	
	scrollLayer = [self scrollLayer];
	[self addChild: scrollLayer z: 0 tag: kScrollLayer];
	[scrollLayer selectPage: 1];
	scrollLayer.delegate = self;
}

#pragma mark ScrollLayer Creation

// Returns array of CCLayers - pages for ScrollLayer.
- (NSArray *) scrollLayerPages
{
	CGSize screenSize = [CCDirector sharedDirector].winSize;
	
	// PAGE 1 - Simple Label in the center.
	CCLayer *pageOne = [CCLayer node];
	CCLabelTTF *label = [CCLabelTTF labelWithString:@"Page 1" fontName:@"Arial Rounded MT Bold" fontSize:44];
	label.position =  ccp( screenSize.width /2 , screenSize.height/2 );
	[pageOne addChild:label];
	
	// PAGE 2 - Custom Font Menu in the center.
	CCLayer *pageTwo = [CCLayer node];
	CCLabelTTF *labelTwo = [CCLabelTTF labelWithString:@"Add Page!" fontName:@"Marker Felt" fontSize:44];		
	CCMenuItemLabel *titem = [CCMenuItemLabel itemWithLabel:labelTwo target:self selector:@selector(addPagePressed:)];
	CCLabelTTF *labelTwo2 = [CCLabelTTF labelWithString:@"Remove Page!" fontName:@"Marker Felt" fontSize:44];		
	CCMenuItemLabel *titem2 = [CCMenuItemLabel itemWithLabel:labelTwo2 target:self selector:@selector(removePagePressed:)];
    CCLabelTTF *labelTwo3 = [CCLabelTTF labelWithString:@"Change dots color!" fontName:@"Marker Felt" fontSize:40];		
	CCMenuItemLabel *titem3 = [CCMenuItemLabel itemWithLabel:labelTwo3 target:self selector:@selector(changeColorPressed:)];
	CCMenu *menu = [CCMenu menuWithItems: titem, titem2, titem3, nil];
	[menu alignItemsVertically];
	menu.position = ccp(screenSize.width/2, screenSize.height/2);
	[pageTwo addChild:menu];	
	
	return [NSArray arrayWithObjects: pageOne,pageTwo,nil];
}

// Creates new Scroll Layer with pages returned from scrollLayerPages.
- (CCScrollLayer *) scrollLayer
{
	CGSize screenSize = [CCDirector sharedDirector].winSize;
	
	// Create the scroller and pass-in the pages (set widthOffset to 0 for fullscreen pages).
	CCScrollLayer *scroller = [CCScrollLayer nodeWithLayers: [self scrollLayerPages] widthOffset: 0.48f * screenSize.width ];
	scroller.pagesIndicatorPosition = ccp(screenSize.width * 0.5f, screenSize.height - 30.0f);
    
    // New feature: margin offset - to slowdown scrollLayer when scrolling out of it contents.
    // Comment this line or change marginOffset to screenSize.width to disable this effect.
    scroller.marginOffset = 0.5f * screenSize.width;
	
	return scroller;
}

#pragma mark Callbacks

- (void) changeColorPressed: (CCNode *) sender
{
    CCScrollLayer *scroller = (CCScrollLayer *)[self getChildByTag:kScrollLayer];
    
    GLubyte opacity = arc4random() % 127 + 128;
    GLubyte red = arc4random() % 255;
    GLubyte green = arc4random() % 255;
    GLubyte blue = arc4random() % 255;
    
    GLubyte opacitySelected = arc4random() % 127 + 128;
    GLubyte redSelected = arc4random() % 255;
    GLubyte greenSelected = arc4random() % 255;
    GLubyte blueSelected = arc4random() % 255;
    
    scroller.pagesIndicatorNormalColor = ccc4(red, green, blue, opacity);
    scroller.pagesIndicatorSelectedColor = ccc4(redSelected, greenSelected, blueSelected, opacitySelected);
    
}

// "Add Page" Button Callback - adds new page & updates fast page change menu.
- (void) addPagePressed: (CCNode *) sender
{
	NSLog(@"CCScrollLayerTestLayer#addPagePressed: called!");
	
	// Add page with label with number.
	CGSize screenSize = [CCDirector sharedDirector].winSize;
	
	CCScrollLayer *scroller = (CCScrollLayer *)[self getChildByTag:kScrollLayer];
	
	int x = [scroller.pages count] + 1;
	CCLayer *pageX = [CCLayer node];
	CCLabelTTF *label = [CCLabelTTF labelWithString: [NSString stringWithFormat:@"Page %d", x] 
										   fontName: @"Arial Rounded MT Bold" 
										   fontSize:44];
	label.position =  ccp( screenSize.width /2 , screenSize.height/2 );
	[pageX addChild:label];
	
	[scroller addPage: pageX];
	
	//Update fast page change menu.
	[self updateFastPageChangeMenu];
}

// "Remove page" menu callback - removes pages through running new action with delay.
- (void) removePagePressed: (CCNode *) sender
{
	// Run action with page removal on cocos2d thread.
	[self runAction:[CCSequence actions:
					 [CCDelayTime actionWithDuration:0.2f],
					 [CCCallFunc actionWithTarget:self selector:@selector(removePage)],
					 nil]
	 ];
}

- (void) removePage
{
	// Actually remove page.
	CCScrollLayer *scroller = (CCScrollLayer *)[self getChildByTag:kScrollLayer];
	[scroller removePageWithNumber: [scroller.pages count] - 1];
	
	// Update fast page change menu.
	[self updateFastPageChangeMenu];
}

// "0 1 2" menu callback - used for fast page change.
- (void) fastMenuItemPressed: (CCNode *) sender
{
	CCScrollLayer *scroller = (CCScrollLayer *)[self getChildByTag:kScrollLayer];
	
	[scroller moveToPage: sender.tag];
}

#pragma mark Scroll Layer Callbacks

- (void) scrollLayerScrollingStarted:(CCScrollLayer *) sender
{
	NSLog(@"CCScrollLayerTestLayer#scrollLayerScrollingStarted: %@", sender);
}

- (void) scrollLayer: (CCScrollLayer *) sender scrolledToPageNumber: (int) page
{
	NSLog(@"CCScrollLayerTestLayer#scrollLayer:scrolledToPageNumber: %@ %d", sender, page);
}

@end


