/*
 * CCMenuAdvanced Tests
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

#import "CCMenuAdvanced.h"
#import "CCMenuAdvancedTest.h"
#import "ExtensionTest.h"

SYNTHESIZE_EXTENSION_TEST(CCMenuAdvancedTestLayer)

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

#endif

@implementation CCMenuAdvancedTestLayer

enum nodeTags
{
	// Tags to distinguish what button was pressed.
	kItemVerticalTest,
	kItemHorizontalTest,
	kItemPriorityTest,
	
	// Tag to get children in updateForScreenReshape
	kMenu,
	kAdvice,
	
	// Vertical Test Node Additional Tags
	kBackButtonMenu,
	kWidget,
    kWidgetReversed,
	
	// Priority Test Node Additional Tags
	kMenu2,
};

- (id) init
{
	if ( (self=[super init]) )
	{
		// Create advice label.		
		CCLabelTTF *label = [CCLabelTTF labelWithString:@"Choose the test." fontName:@"Marker Felt" fontSize:24];
		CCLabelTTF *label2 = [CCLabelTTF labelWithString:@"Menu should be at the screen center." fontName:@"Marker Felt" fontSize:24];
		label2.anchorPoint = ccp(0.5f, 1);
		label2.position = ccp(0.5f * label.contentSize.width, 0);
#ifdef __MAC_OS_X_VERSION_MAX_ALLOWED
		CCLabelTTF *label3 = [CCLabelTTF labelWithString:@"(Resize the window)" fontName:@"Marker Felt" fontSize:24];
		label3.anchorPoint = ccp(0.5f, 1);
		label3.position = ccp(0.5f * label2.contentSize.width, 0);
		[label2 addChild: label3];
#endif
		[label addChild: label2];
		[self addChild: label z:1 tag: kAdvice];
		
		
		// Prepare Menu Items.
		CCMenuItemSprite *verticalTestItem = 
			[CCMenuItemSprite itemFromNormalSprite: [CCSprite spriteWithFile: @"verticalTestButton.png"]
									selectedSprite: [CCSprite spriteWithFile: @"verticalTestButton.png"]
											target: self
										  selector: @selector(itemPressed:)];
		
		CCMenuItemSprite *horizontalTestItem = 
		[CCMenuItemSprite itemFromNormalSprite: [CCSprite spriteWithFile: @"horizontalTestButton.png"]
								selectedSprite: [CCSprite spriteWithFile: @"horizontalTestButton.png"]
										target: self
									  selector: @selector(itemPressed:)];
		
		CCMenuItemSprite *priorityTestItem = 
		[CCMenuItemSprite itemFromNormalSprite: [CCSprite spriteWithFile: @"priorityTestButton.png"]
								selectedSprite: [CCSprite spriteWithFile: @"priorityTestButton.png"]
										target: self
									  selector: @selector(itemPressed:)];
		
		// Distinguish Normal/Selected State of Menu Items.
		[verticalTestItem.selectedImage setColor:ccGRAY];
		[horizontalTestItem.selectedImage setColor:ccGRAY];
		[priorityTestItem.selectedImage setColor:ccGRAY];
			
		// Set Menu Items Tags.
		verticalTestItem.tag = kItemVerticalTest;
		horizontalTestItem.tag = kItemHorizontalTest;
		priorityTestItem.tag = kItemPriorityTest;
		
		// Create & Add Menu.
		CCMenuAdvanced *menu = [CCMenuAdvanced menuWithItems:verticalTestItem, horizontalTestItem, priorityTestItem, nil];
		[menu alignItemsHorizontallyWithPadding: 0.33 * verticalTestItem.contentSize.width ];
		[self addChild: menu z:0 tag: kMenu];
		
		// Enable Debug Draw (available only when DEBUG is defined )
#ifdef DEBUG
		menu.debugDraw = YES;
#endif
		
		// Do initial layout.
		[self updateForScreenReshape];
	}
	
	return self;
}

- (void) updateForScreenReshape
{
	CGSize s = [CCDirector sharedDirector].winSize;
	
	// Position label at top.
	CCLabelTTF *label = (CCLabelTTF *)[self getChildByTag: kAdvice];
	label.anchorPoint = ccp(0.5f,1);
	label.position = ccp( 0.5f * s.width, 0.9f * s.height);
	
	// Position Menu at Center.
	CCMenuAdvanced *menu = (CCMenuAdvanced *)[self getChildByTag: kMenu];
	menu.anchorPoint = ccp(0.5f,0.5f);
	menu.position = ccp( 0.5f * s.width, 0.5f * s.height);
}

- (void) changeSceneWithLayer: (CCLayer *) layer
{														
	CCScene *scene = [CCScene node];							
	[scene addChild: layer];						
	[[CCDirector sharedDirector] replaceScene: scene];										
}

- (void) itemPressed: (CCNode *) item
{
	switch (item.tag) {
		case kItemVerticalTest:
			[self changeSceneWithLayer:[CCMenuAdvancedVerticalTestLayer node]];
			break;
		case kItemHorizontalTest:
			[self changeSceneWithLayer:[CCMenuAdvancedHorizontalTestLayer node]];
			break;
		case kItemPriorityTest:
			[self changeSceneWithLayer:[CCMenuAdvancedPriorityTestLayer node]];
			break;
		default:
			break;
	}
}

@end

@implementation CCMenuAdvancedVerticalTestLayer

- (id) init
{
	if ( (self = [super init]) )
	{		
		// Create advice label.		
		CCLabelTTF  *label = [self adviceLabel];
		[self addChild: label z:1 tag: kAdvice];
		
		// Create back button menu item.
		CCMenuItemSprite *backMenuItem = 
				[CCMenuItemSprite itemFromNormalSprite: [CCSprite spriteWithFile:@"b1.png"]
										selectedSprite: [CCSprite spriteWithFile:@"b1.png"]
												target: self
											  selector: @selector(backPressed)
						 ];
		[backMenuItem.selectedImage setColor: ccGRAY];
		CCMenuAdvanced *menu = [CCMenuAdvanced menuWithItems:backMenuItem, nil];
#if COCOS2D_VERSION >= 0x00020000
        menu.priority = kCCMenuHandlerPriority - 1;
#else
        menu.priority = kCCMenuTouchPriority - 1;
#endif
		[self addChild:menu z:0 tag: kBackButtonMenu];
		
		// Enable Debug Draw (available only when DEBUG is defined )
#ifdef DEBUG
		menu.debugDraw = YES;
#endif
		
		// Bind keyboard for mac.
#ifdef __MAC_OS_X_VERSION_MAX_ALLOWED
		menu.escapeDelegate = backMenuItem;
#endif
		
		// Create vertical scroll widget.
		CCNode *widget = [self widget];
		[self addChild: widget z: 0 tag: kWidget];
		
        // Create vertical reversed scroll widget.
		CCNode *widgetReversed = [self widgetReversed];
        if (widgetReversed)
            [self addChild: widgetReversed z: 0 tag: kWidgetReversed];
		
		// Do initial layout.
		[self updateForScreenReshape];	
	}
	
	return self;
}


- (void) updateForScreenReshape
{
	CGSize s = [[CCDirector sharedDirector] winSize];
	
	// Position label at top.
	CCLabelTTF *label = (CCLabelTTF *)[self getChildByTag: kAdvice];
	label.anchorPoint = ccp(0.5f,1);
	label.position = ccp( 0.5f * s.width, 0.9f * s.height);
	
	// Position back button at the top-left corner.
	CCMenuAdvanced *menu = (CCMenuAdvanced *)[self getChildByTag: kBackButtonMenu];
	menu.anchorPoint = ccp(0, 1);
	menu.position = ccp(0, s.height);
	
	[self updateWidget];
}

// Go back to the default ExtensionTest Layer.
- (void) backPressed
{	
	[[CCDirector sharedDirector] replaceScene: [ExtensionTest scene]];
}

#pragma mark Vertical Scroll Widget

- (NSArray *) menuItemsArray
{	
	NSArray *array = [NSArray arrayWithObjects:
					  [CCMenuItemLabel itemWithLabel:[CCLabelBMFont labelWithString: @"Level #1" fntFile:@"crackedGradient42.fnt"]
											  target: self 
											selector: @selector(itemPressed:)],
					  
					  [CCMenuItemLabel itemWithLabel: [CCLabelBMFont labelWithString:@"Level #2" fntFile:@"crackedGradient42.fnt"]
											  target: self 
											selector: @selector(itemPressed:)],
					  
					  [CCMenuItemLabel itemWithLabel:[CCLabelBMFont labelWithString: @"Level #3" fntFile:@"crackedGradient42.fnt"]
											  target: self 
											selector: @selector(itemPressed:)],
					  
					  [CCMenuItemLabel itemWithLabel:[CCLabelBMFont labelWithString: @"Level +10050" fntFile:@"crackedGradient42.fnt"]
											  target: self 
											selector: @selector(itemPressed:)],
					  
					  [CCMenuItemLabel itemWithLabel: [CCLabelBMFont labelWithString:@"Level #nil" fntFile:@"crackedGradient42.fnt"]
											  target: self 
											selector: @selector(itemPressed:)],
					  
					  [CCMenuItemLabel itemWithLabel: [CCLabelBMFont labelWithString:@"Level Kill" fntFile:@"crackedGradient42.fnt"]
											  target: self 
											selector: @selector(itemPressed:)],
					  
					  [CCMenuItemLabel itemWithLabel: [CCLabelBMFont labelWithString:@"Level Kill Bill" fntFile:@"crackedGradient42.fnt"]
											  target: self 
											selector: @selector(itemPressed:)],
					  
					  [CCMenuItemLabel itemWithLabel: [CCLabelBMFont labelWithString:@"Whatever..." fntFile:@"crackedGradient42.fnt"]
											  target: self 
											selector: @selector(itemPressed:)],
					  
					  [CCMenuItemLabel itemWithLabel: [CCLabelBMFont labelWithString:@"Oh, commoooooOON!!!" fntFile:@"crackedGradient42.fnt"]
											  target: self 
											selector: @selector(itemPressed:)],
					  
					  [CCMenuItemLabel itemWithLabel: [CCLabelBMFont labelWithString:@"Fork you!" fntFile:@"crackedGradient42.fnt"]
											  target: self 
											selector: @selector(itemPressed:)],
					  
					  [CCMenuItemLabel itemWithLabel: [CCLabelBMFont labelWithString:@"FORK YOU!!!" fntFile:@"crackedGradient42.fnt"]
											  target: self 
											selector: @selector(itemPressed:)],
					  
					  [CCMenuItemLabel itemWithLabel: [CCLabelBMFont labelWithString:@"..." fntFile:@"crackedGradient42.fnt"]
											  target: self 
											selector: @selector(itemPressed:)],
					  
					  [CCMenuItemLabel itemWithLabel: [CCLabelBMFont labelWithString:@"...." fntFile:@"crackedGradient42.fnt"]
											  target: self 
											selector: @selector(itemPressed:)],
					  
					  [CCMenuItemLabel itemWithLabel: [CCLabelBMFont labelWithString:@"..." fntFile:@"crackedGradient42.fnt"]
											  target: self 
											selector: @selector(itemPressed:)],
					  
					  [CCMenuItemLabel itemWithLabel: [CCLabelBMFont labelWithString:@"WAAAZAAAAAAAA!!! =)" fntFile:@"crackedGradient42.fnt"]
											  target: self 
											selector: @selector(itemPressed:)],
					  
					  [CCMenuItemLabel itemWithLabel: [CCLabelBMFont labelWithString:@"..." fntFile:@"crackedGradient42.fnt"]
											  target: self 
											selector: @selector(itemPressed:)],
					  
					  [CCMenuItemLabel itemWithLabel: [CCLabelBMFont labelWithString:@"..." fntFile:@"crackedGradient42.fnt"]
											  target: self 
											selector: @selector(itemPressed:)],
					  
					  [CCMenuItemLabel itemWithLabel: [CCLabelBMFont labelWithString:@"..." fntFile:@"crackedGradient42.fnt"]
											  target: self 
											selector: @selector(itemPressed:)],
					  
					  [CCMenuItemLabel itemWithLabel: [CCLabelBMFont labelWithString:@"..." fntFile:@"crackedGradient42.fnt"]
											  target: self 
											selector: @selector(itemPressed:)],
					  
					  [CCMenuItemLabel itemWithLabel: [CCLabelBMFont labelWithString:@"..." fntFile:@"crackedGradient42.fnt"]
											  target: self 
											selector: @selector(itemPressed:)],
					  
					  [CCMenuItemLabel itemWithLabel: [CCLabelBMFont labelWithString:@"Last Menu Item" fntFile:@"crackedGradient42.fnt"]
											  target: self 
											selector: @selector(itemPressed:)],
					  nil  ];
	
	return array;
}

- (CCLabelTTF *) adviceLabel
{
	CCLabelTTF *label = [CCLabelTTF labelWithString:@"Vertical Test." fontName:@"Marker Felt" fontSize:24];
	CCLabelTTF *label2 = [CCLabelTTF labelWithString:@"Scrollable menu should be at left & right." fontName:@"Marker Felt" fontSize:24];
	label2.anchorPoint = ccp(0.5f, 1);
	label2.position = ccp(0.5f * label.contentSize.width, 0);
	[label addChild: label2];
	
#ifdef __MAC_OS_X_VERSION_MAX_ALLOWED
	CCLabelTTF *label3 = [CCLabelTTF labelWithString:@"(Controls: up, down, enter, esc)" fontName:@"Marker Felt" fontSize:24];
	label3.anchorPoint = ccp(0.5f, 1);
	label3.position = ccp(0.5f * label2.contentSize.width, 0);
	[label2 addChild: label3];
#endif
	
	return label;
}

- (CCNode *) widget
{
	// Get Menu Items
	NSArray *menuItems = [self menuItemsArray];
	
	// Prepare Menu
	CCMenuAdvanced *menu = [CCMenuAdvanced menuWithItems: nil];	
	for (CCMenuItem *item in menuItems)
		[menu addChild: item];	
	
	// Enable Debug Draw (available only when DEBUG is defined )
#ifdef DEBUG
	menu.debugDraw = YES;
#endif
	
	// Setup Menu Alignment
	[menu alignItemsVerticallyWithPadding: 5 bottomToTop: NO]; //< also sets contentSize and keyBindings on Mac
#if COCOS2D_VERSION >= 0x00020000
    menu.ignoreAnchorPointForPosition = NO;
#else
    menu.isRelativeAnchorPoint = YES;
#endif	
	
	return menu;
}

- (CCNode *) widgetReversed
{
	// Get Menu Items
	NSArray *menuItems = [self menuItemsArray];
	
	// Prepare Menu
	CCMenuAdvanced *menu = [CCMenuAdvanced menuWithItems: nil];	
	for (CCMenuItem *item in menuItems)
		[menu addChild: item];	
	
	// Enable Debug Draw (available only when DEBUG is defined )
#ifdef DEBUG
	menu.debugDraw = YES;
#endif
	
	// Setup Menu Alignment
	[menu alignItemsVerticallyWithPadding: 5 bottomToTop: YES]; //< also sets contentSize and keyBindings on Mac
#if COCOS2D_VERSION >= 0x00020000
    menu.ignoreAnchorPointForPosition = NO;
#else
    menu.isRelativeAnchorPoint = YES;
#endif	
	
	return menu;
}

- (void) updateWidget
{
	CGSize winSize = [[CCDirector sharedDirector] winSize];
	
    // Menu at the Left.
    {
        CCMenuAdvanced *menu = (CCMenuAdvanced *) [self getChildByTag:kWidget]; 
        
        //widget	
        menu.anchorPoint = ccp(0.5f, 1);
        menu.position = ccp(winSize.width / 4, winSize.height);
        
        menu.scale = MIN ((winSize.width / 2.0f) / menu.contentSize.width, 0.75f );
        
        menu.boundaryRect = CGRectMake(MAX(0, winSize.width / 4.0f - [menu boundingBox].size.width / 2.0f), 
                                       25.0f, 
                                       [menu boundingBox].size.width, 
                                       winSize.height - 50.0f );
        
        [menu fixPosition];	
    }
    
    // Reversed Menu at the Rigth.
    {
        CCMenuAdvanced *menu2 = (CCMenuAdvanced *) [self getChildByTag:kWidgetReversed]; 
        
        //widget	
        menu2.anchorPoint = ccp(0.5f, 1);
        menu2.position = ccp( 0.75f * winSize.width / 4, winSize.height);
        
        menu2.scale = MIN ((winSize.width / 2.0f) / menu2.contentSize.width, 0.75f );
        
        menu2.boundaryRect = CGRectMake(MIN(winSize.width, 0.75 * winSize.width - [menu2 boundingBox].size.width / 2.0f), 
                                       25.0f, 
                                       [menu2 boundingBox].size.width, 
                                       winSize.height - 50.0f );
        
        [menu2 fixPosition];	
    }
}

- (void) itemPressed: (CCNode *) sender
{
	NSLog(@"CCMenuAdvancedVerticalTestLayer#itemPressed: %@", sender);
}

@end

@implementation CCMenuAdvancedHorizontalTestLayer


- (CCLabelTTF *) adviceLabel
{
	CCLabelTTF *label = [CCLabelTTF labelWithString:@"Horizontal Test." fontName:@"Marker Felt" fontSize:24];
	CCLabelTTF *label2 = [CCLabelTTF labelWithString:@"Scrollable menu should be at the center." fontName:@"Marker Felt" fontSize:24];
	label2.anchorPoint = ccp(0.5f, 1);
	label2.position = ccp(0.5f * label.contentSize.width, 0);
	[label addChild: label2];
	
#ifdef __MAC_OS_X_VERSION_MAX_ALLOWED
	CCLabelTTF *label3 = [CCLabelTTF labelWithString:@"(Controls: left, right, enter, esc)" fontName:@"Marker Felt" fontSize:24];
	label3.anchorPoint = ccp(0.5f, 1);
	label3.position = ccp(0.5f * label2.contentSize.width, 0);
	[label2 addChild: label3];
#endif
	
	return label;
}

- (CCNode *) widget
{	
	// Prepare Menu.
	CCMenuAdvanced *menu = [CCMenuAdvanced menuWithItems: nil];	
	
	// Prepare menu items.
	for (int i = 0; i <= 31; ++i)
	{
		// Create menu item.
		CCMenuItemSprite *item = 
		[CCMenuItemSprite itemFromNormalSprite: [CCSprite spriteWithFile: @"blankTestButton.png"]
								selectedSprite: [CCSprite spriteWithFile: @"blankTestButton.png"]
										target: self
									  selector: @selector(itemPressed:)];
		
		// Add order number.
		CCLabelTTF *label = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d", i] fontName:@"Marker Felt" fontSize:24];
		label.anchorPoint = ccp(0.5f, 0.5f);
		label.position =  ccp(0.5f * item.contentSize.width, 0.5f* item.contentSize.height);
		[item addChild: label z: 1];
		
		// Distinguish normal/selected state of menu items.
		[item.selectedImage setColor:ccGRAY];
		
		// Add it.
		[menu addChild: item];
	}
	
	// Enable Debug Draw (available only when DEBUG is defined )
#ifdef DEBUG
	menu.debugDraw = YES;
#endif
	
	// Setup Menu Alignment.
	[menu alignItemsHorizontally]; //< also sets contentSize and keyBindings on Mac		
	
	return menu;
}

- (CCNode *) widgetReversed
{
    return nil;
}

- (void) updateWidget
{
	CGSize winSize = [[CCDirector sharedDirector] winSize];
	
	CCMenuAdvanced *menu = (CCMenuAdvanced *) [self getChildByTag:kWidget]; 
	
	// Initial position.	
	menu.anchorPoint = ccp(0.5f, 0.5f);
	menu.position = ccp(0.5f * winSize.width, 0.5f * winSize.height);
	
	menu.scale = MIN ((winSize.height / 2.0f) / menu.contentSize.height, 0.75f );
	
	menu.boundaryRect = CGRectMake( 25.0f, 
								   0.5f * winSize.height - 0.5f * [menu boundingBox].size.height ,
								   winSize.width - 50.0f,
								   [menu boundingBox].size.height );
	
	// Show first menuItem (scroll max to the left).
	menu.position = ccp(menu.contentSize.width / 2.0f, 0.5f * winSize.height);
	
	[menu fixPosition];	
}

@end

@implementation CCMenuAdvancedPriorityTestLayer

- (CCLabelTTF *) adviceLabel
{
	CCLabelTTF *label = [CCLabelTTF labelWithString:@"Priority Test." fontName:@"Marker Felt" fontSize:24];
	CCLabelTTF *label2 = [CCLabelTTF labelWithString:@"Items 1&3 have more priority than 3&4." fontName:@"Marker Felt" fontSize:24];
	label2.anchorPoint = ccp(0.5f, 1);
	label2.position = ccp(0.5f * label.contentSize.width, 0);
	[label addChild: label2];
	
#ifdef __MAC_OS_X_VERSION_MAX_ALLOWED
	CCLabelTTF *label3 = [CCLabelTTF labelWithString:@"(Controls: left, right, enter, esc)" fontName:@"Marker Felt" fontSize:24];
	label3.anchorPoint = ccp(0.5f, 1);
	label3.position = ccp(0.5f * label2.contentSize.width, 0);
	[label2 addChild: label3];
	CCLabelTTF *label4 = [CCLabelTTF labelWithString:@"(Only items 1&3 should be controlled by keyboard)" fontName:@"Marker Felt" fontSize:24];
	label4.anchorPoint = ccp(0.5f, 1);
	label4.position = ccp(0.5f * label3.contentSize.width, 0);
	[label3 addChild: label4];
#endif
	
	return label;
}

- (CCNode *) widget
{
	CCNode *widget = [CCNode node];
#if COCOS2D_VERSION >= 0x00020000
    widget.ignoreAnchorPointForPosition = NO;
#else
    widget.isRelativeAnchorPoint = YES;
#endif
	
	// Prepare menuItems
	CCMenuItemSprite *itemOne = 
	[CCMenuItemSprite itemFromNormalSprite: [CCSprite spriteWithFile: @"priorityOne.png"]
							selectedSprite: [CCSprite spriteWithFile: @"priorityOne.png"]
									target: self
								  selector: @selector(itemPressed:)];
	CCMenuItemSprite *itemTwo = 
	[CCMenuItemSprite itemFromNormalSprite: [CCSprite spriteWithFile: @"priorityTwo.png"]
							selectedSprite: [CCSprite spriteWithFile: @"priorityTwo.png"]
									target: self
								  selector: @selector(itemPressed:)];
	CCMenuItemSprite *itemThree = 
	[CCMenuItemSprite itemFromNormalSprite: [CCSprite spriteWithFile: @"priorityThree.png"]
							selectedSprite: [CCSprite spriteWithFile: @"priorityThree.png"]
									target: self
								  selector: @selector(itemPressed:)];
	CCMenuItemSprite *itemFour = 
	[CCMenuItemSprite itemFromNormalSprite: [CCSprite spriteWithFile: @"priorityFour.png"]
							selectedSprite: [CCSprite spriteWithFile: @"priorityFour.png"]
									target: self
								  selector: @selector(itemPressed:)];
	
	// Distinguish Normal/Selected State of Menu Items.
	[itemOne.selectedImage setColor: ccGRAY];
	[itemTwo.selectedImage setColor: ccGRAY];
	[itemThree.selectedImage setColor: ccGRAY];
	[itemFour.selectedImage setColor: ccGRAY];
	
	// Create & add menu for Items 1 & 3.
	CCMenuAdvanced *menu = [CCMenuAdvanced menuWithItems: itemOne, itemThree, nil];
	[menu alignItemsHorizontallyWithPadding:20.0f];
	menu.anchorPoint = ccp(0.5f, 0.2f);
	[widget addChild: menu z: 1];
	
	// Create & add menu for Items 2 & 4
	CCMenuAdvanced *menu2 = [CCMenuAdvanced menuWithItems: itemTwo, itemFour, nil];
	[menu2 alignItemsHorizontallyWithPadding: 120.0f];
	menu2.anchorPoint = ccp(0.5f, 0.5f);
	[widget addChild: menu2 z: 0];	
	
	// Set widget size.
	widget.contentSize = menu.contentSize;
	
	// Position menus
	menu2.position =
	menu.position = ccp(0.5f * widget.contentSize.width, 0.5f * widget.contentSize.height);
	
	// Set menus priority.
	menu.priority = 0;
	menu2.priority = 1;
	
	return widget;
}

- (CCNode *) widgetReversed
{
    return nil;
}

- (void) updateWidget
{
	CGSize winSize = [[CCDirector sharedDirector] winSize];
	
	// Get widget. 
	CCNode *widget = (CCMenuAdvanced *) [self getChildByTag:kWidget]; 
	
	// Position menu at center.	
	widget.anchorPoint = ccp(0.5f, 0);
	widget.position = ccp(0.5f * winSize.width, 0);

}

@end

