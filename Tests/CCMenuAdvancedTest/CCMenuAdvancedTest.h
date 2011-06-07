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
@interface DemoMenu : CCLayer
{
	// weak refs of node childs
	CCLayerColor *_backgroundLayer;	
	
	CCSprite *_cornerSil;
	CCSprite *_nameLogo;
	
	DemoMenuWidget *_widget;
	DemoMenuWidget *_widget2;
}

- (void) updateForScreenReshape;

@end


// Holds CCMenuAdvanced on first screen of CCMenuAdvancedTest
// Tests CCMenuAdvanced's contentSize & horizontal align
// So it can be scaled for any winSize to fit.
@interface DemoMenuWidget : CCNode
{
}

+ (id) menuWidgetWithReversedOrder: (BOOL) rightToLeft;
- (id) initWithReversedOrder: (BOOL) rightToLeft;

@end


// Abstract Menu Screen
// Inlcudes back button, which is binded to escapeDelegate (press escape to active this button on Mac).
@interface GenericDemoMenu : CCNode 
{
	// weak refs to self children
	CCSprite *_caption;
	CCLayerColor *_background;
	CCMenuItem *_backMenuItem;
}
- (NSString *) captionSpriteFrameName;
- (void) updateForScreenReshape;

@end

// Demo Menu with list, like TimeTrial menu in iTraceur
// Tests vertical align and boundaryRect for scrolling menu.
@interface DemoMenu2 : GenericDemoMenu 
{
	CCSprite *_sil;
	CCNode *_widget;
	CCSprite *_topBorder, *_bottomBorder;
}

@end

