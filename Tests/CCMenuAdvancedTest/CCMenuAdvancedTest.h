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

/* 
	First screen of CCMenuAdvancedTest.
 Presents CCMenuAdvanced which allow you too choose
 Vertical, Horizontal or Priority Test.
 
 Demonstrates natural pisitioning of CCMenuAdvanced.
 (contentSize is set automatically based on menu's children)
 
 ADVICE: Use mac project and resize the window, too see how natural positioning
 of CCMenuAdvanced works with updateForScreenReshape.
 */
@interface CCMenuAdvancedTestLayer : CCLayer
{}

- (void) updateForScreenReshape;

@end

/*
	This test demonstrates vertical scrollable menu (boundaryRect property).
 Use mouse wheel to scroll on mac, swipe to scroll on iOS.
 
 On Mac OS X it also demosntrates escapeDelegate menuItem (press esc to go back)
 and upArrow/DownArrow automatic keybinding on alignItemsVertically.
 */
@interface CCMenuAdvancedVerticalTestLayer : CCLayer
{}

// Creates advice label (test description)
- (CCLabelTTF *) adviceLabel;

// Creates widget (can be anything you want, in Vertical Test it is a vertical menu).
- (CCNode *) widget;

// Creates reversed vertical menu.
- (CCNode *) widgetReversed;

// Updates layout of the children.
- (void) updateForScreenReshape;

// Updates position for node with tag kWidget (Used in updateForScreenReshape).
- (void) updateWidget;


@end

/*
 This test demonstrates horizontal scrollable menu (boundaryRect property).
 Use mouse wheel to scroll on mac, swipe to scroll on iOS.
 
 On Mac OS X it also demosntrates escapeDelegate menuItem (press esc to go back)
 and leftArrow/rightArrow automatic keybinding on alignItemsHorizontally.
 */
@interface CCMenuAdvancedHorizontalTestLayer : CCMenuAdvancedVerticalTestLayer
{}

@end

/*
 This test demonstrates ability to set ccMouseDelegate & ccTouchDelegate Priority
 (priority property).
 
 Note: priority must be set before CCMenuADvanced's onEnter will be called.
 */
@interface CCMenuAdvancedPriorityTestLayer : CCMenuAdvancedVerticalTestLayer
{}

@end


