//
//  CCScrollLayer.h
//
//  Copyright 2010 DK101
//  http://dk101.net/2010/11/30/implementing-page-scrolling-in-cocos2d/
//
//  Copyright 2010 Giv Parvaneh.
//  http://www.givp.org/blog/2010/12/30/scrolling-menus-in-cocos2d/
//
//  Copyright 2011 Stepan Generalov
//  Copyright 2011 Brian Feller
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import <Foundation/Foundation.h>
#import "cocos2d.h"

#ifndef __MAC_OS_X_VERSION_MAX_ALLOWED

/* 
 It is a very clean and elegant subclass of CCLayer that lets you pass-in an array 
 of layers and it will then create a smooth scroller. 
 Complete with the "snapping" effect. You can create screens with anything that can be added to a CCLayer.
 
 Additions since Giv Parvaneh version:
	1. Added ability to swipe above targetedTouchDelegates.
    2. Added touches lengths & screens properties.
	3. Added factory class method.
	4. Code cleanup.
	5. Added current page number indicator (iOS Style Dots).
	6. moveToPage is public method.
	7. Standard pages numbering starting from zero: [0;totalScreens-1] instead of [1; totalScreens]
 
 Limitations: 
	1. Mac OS X not supported. (Note #ifndef wrappers ;) )
	2. Standard Touch Delegates will still receive touch events after layer starts sliding.
 */
@interface CCScrollLayer : CCLayer {
	
	// Holds the current width of the screen substracting offset.
	CGFloat scrollWidth_;
	
	// Holds the current page being displayed.
	int currentScreen_;
	
	// A count of the total screens available.
	int totalScreens_;
	
	// The x coord of initial point the user starts their swipe.
	CGFloat startSwipe_;
	
	// For what distance user must slide finger to start scrolling menu.
	CGFloat minimumTouchLengthToSlide_; 
	
	// For what distance user must slide finger to change the page.
	CGFloat minimumTouchLengthToChangePage_; 
	
	// Whenever show or not gray/white dots under scrolling content.
	BOOL showPagesIndicator_;
	
	// Internal state of scrollLayer (scrolling or idle).
	int state_;
	
}

// Calibration property. Minimum moving touch length that is enough
// to cancel menu items and start scrolling a layer.
@property(readwrite, assign) CGFloat minimumTouchLengthToSlide;

// Calibration property. Minimum moving touch length that is enough to change
// the page, without snapping back to the previous selected page.
@property(readwrite, assign) CGFloat minimumTouchLengthToChangePage;

// Whenever show or not white/grey dots under the scroll layer.
@property(readwrite, assign) BOOL showPagesIndicator;

// Total pages available in scrollLayer.
@property(readonly) int totalScreens;

// Current page number, that is shown. Belongs to the [0, totalScreen] interval.
@property(readonly) int currentScreen;

#pragma mark Init/Creation
+(id) nodeWithLayers:(NSArray *)layers widthOffset: (int) widthOffset; 
-(id) initWithLayers:(NSArray *)layers widthOffset: (int) widthOffset;

#pragma mark Pages Control

/* Changes page to page with given number. 
 Does nothing if number >= totalScreens or < 0.
 */
-(void) moveToPage:(int)page;

@end

#endif
