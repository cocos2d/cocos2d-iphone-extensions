/*
 * CCMenuAdvanced
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

#import "cocos2d.h"

@interface NSString (UnicharExtensions)

+ (NSString *) stringWithUnichar: (unichar) anUnichar;
- (unichar) unicharFromFirstCharacter: (NSString *) aString;

@end


/** @class CCMenuAdvanced CCMenu with some aditional features.
 *
 *		1) Selecting and activating CCMenuItems with Keyboard 
 * (by default next/prev bindings aren't set - set them manually or use one of align methods to bind arrows for this).
 *		2) One of CCMenuItems can be set as escapeDelegate - so it will be activated by pressing escape
 *		3) align left->right, right->left, bottom->top, top->bottom with autosetting self contentSize
 *		4) externalBoundsRect - if it is set then menu items will be scrollable inside these bounds
 *		5) priority property - must be set before onEnter to make it register with that priority
 * @todo [v0.2] add columns and rows alignment methods
*/
@interface CCMenuAdvanced : CCMenu  
{
	NSInteger priority_;
	int selectedItemNumber_;
	
	CGRect boundaryRect_; //< external boundaries in which menu can slide
	CGFloat minimumTouchLengthToSlide_; //< how long user must slide finger to start scrolling menu
	CGFloat curTouchLength_;
	
	BOOL isDisabled_;

#ifdef __MAC_OS_X_VERSION_MAX_ALLOWED
	// menu item that can be fast activated byt pressing Esc
	CCMenuItem *escapeDelegate_;
	// button bindings for next/prev item select
	unichar prevItemButtonBind_;
	unichar nextItemButtonBind_;	
#endif
	
#ifdef DEBUG
	BOOL debugDraw_;
#endif
	
}

/** Rectangle in parent's coordinate system, which menu must fill with it's boundingBox.
 *
 * Note: boundaryRect must have greater size then menu's boundingBox to make scrolling possible.
 * Think about boundaryRect like about hole in paper sheet under which you would like to put CCMenuAdvanced
 * and scroll it, but you never want to see the table - hole must be covered with paper. 
 */
@property(readwrite, assign) CGRect boundaryRect;

/** Minimum length of touch, that will disable selected menu item & start scrolling. */
@property(readwrite, assign) CGFloat minimumTouchLengthToSlide;

/** Priority property for touch, mouse & keyboard for menu.
 * Must be set before onEnter called.
 */
@property(readwrite, assign) NSInteger priority;

/** If YES - all touches & keyboard events will be ignored.
 * If NO - all events will work, except for disabled items.
 * Default is NO.
 */
@property(readwrite, assign) BOOL isDisabled;

#ifdef DEBUG
/** If YES - draw rectangle around CCMenuAdvanced. */
@property(readwrite, assign) BOOL debugDraw;
#endif

#ifdef __MAC_OS_X_VERSION_MAX_ALLOWED
@property(readwrite, retain) CCMenuItem *escapeDelegate;
@property(readwrite, assign) unichar prevItemButtonBind;
@property(readwrite, assign) unichar nextItemButtonBind;
#endif

#pragma mark Advanced Menu - Align
/** AlignH items horizontal from left to right. 
 * @param padding space between elements.
 */
-(void) alignItemsHorizontallyWithPadding:(float)padding;

/** Designated alignVerticall from bottom to top.
 * @param padding space between elements.
 */
-(void) alignItemsVerticallyWithPadding:(float)padding;

/** Designated alignHorizontal Method 
 *
 * @param padding space between elements.
 * @param leftRoRight If YES - align items from left to right, if NO - right to left.
 */
-(void) alignItemsHorizontallyWithPadding:(float)padding leftToRight: (BOOL) leftToRight;

/** Designated alignVerticall Method
 *
 * @param padding space between elements.
 * @param bottomToTop If YES - align items from bottom to top, if NO - top to bottom.
 */
-(void) alignItemsVerticallyWithPadding:(float)padding bottomToTop: (BOOL) bottomToTop;

#pragma mark Advanced Menu - Scrolling

/** Changes menu position to stay inside of boundaryRect if it is non-null. */
- (void) fixPosition;

#pragma mark Advanced Menu - Selecting Items
- (void) selectNextMenuItem;
- (void) selectPrevMenuItem;

#pragma mark Advanced Menu - Activating/Cancelling Selected Items.
- (void) activateSelectedItem;
- (void) cancelSelectedItem;

@end
