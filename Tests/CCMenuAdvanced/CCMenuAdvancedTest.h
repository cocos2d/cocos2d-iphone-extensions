/*
 * CCMenuAdvanced Tests
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

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@class DemoMenuWidget;

// Main Demo Menu Node - demonstration of how universal menu screen can be created 
// as subclass of CCNode
@interface DemoMenu : CCLayer
{
	// weak refs of node childs
	CCLayerColor *_backgroundLayer;	
	
	CCSprite *_cornerSil;
	CCSprite *_nameLogo;
	
	DemoMenuWidget *_widget;	
}

- (void) updateForScreenReshape;

@end


// The Menu itself of Demo Screen
@interface DemoMenuWidget : CCNode
{
}

@end

#define DEMO_MENU_Z_BACKGROUND			1
#define DEMO_MENU_Z_CONTENT				2
#define DEMO_MENU_Z_BORDERS				3
#define DEMO_MENU_Z_COVER				4
#define DEMO_MENU_Z_CAPTION				5
#define DEMO_MENU_Z_BACK_BUTTON			6
#define DEMO_MENU_Z_OVER_BACK_BUTTON	7

// Abstract Menu Screen, that was used in iTraceur 
// as a subclass for Choose Leve, Time Trial & Game Progress Menus
@interface GenericDemoMenu : CCNode 
{
	// weak refs to self children
	CCSprite *_caption;
	CCLayerColor *_background;
	CCMenuItem *_backMenuItem;
}

// must be reimplemented in subclasses, 
// should return sprite frame name for caption sprite at the top
- (NSString *) captionSpriteFrameName;

// must be called from subclasses implementation of method
- (void) updateForScreenReshape;

@end

// Demo Menu with list, like TimeTrial menu in iTraceur
// demonstrates how menu ca be build as a subclass of GenericDemoMenu
@interface DemoMenu2 : GenericDemoMenu 
{
	//Right Silhouette
	CCSprite *_sil;
	
	// Left List of something (videos, levels, etc)
	CCNode * _widget;
	
	// Faders on top and bottom - to fade the list
	CCSprite *_topBorder, *_bottomBorder;
}

@end

