/*
 * CCScrollLayer
 *
 * Cocos2D-iPhone-Extensions v0.2.1
 * https://github.com/cocos2d/cocos2d-iphone-extensions
 *
 * Copyright 2010 DK101
 * http://dk101.net/2010/11/30/implementing-page-scrolling-in-cocos2d/
 *
 * Copyright 2010 Giv Parvaneh.
 * http://www.givp.org/blog/2010/12/30/scrolling-menus-in-cocos2d/
 *
 * Copyright 2011-2012 Stepan Generalov
 * Copyright 2011 Brian Feller
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

@class CCScrollLayer;
@protocol CCScrollLayerDelegate

@optional

/** Called when scroll layer begins scrolling.
 * Usefull to cancel CCTouchDispatcher standardDelegates.
 */
- (void) scrollLayerScrollingStarted:(CCScrollLayer *) sender;

/** Called at the end of moveToPage:
 * Doesn't get called in selectPage:
 */
- (void) scrollLayer: (CCScrollLayer *) sender scrolledToPageNumber: (int) page;

@end

/** Scrolling layer for Menus, like iOS Springboard Screen.
 *
 * It is a very clean and elegant subclass of CCLayer that lets you pass-in an array 
 * of layers and it will then create a smooth scroller. 
 * Complete with the "snapping" effect. You can create screens with anything that can be added to a CCLayer.
 *
 * @version 0.2.1
 */
@interface CCScrollLayer : CCLayer 
{	
	NSObject <CCScrollLayerDelegate> *delegate_;
	
	// Holds the current page being displayed.
	int currentScreen_;
    
    // Number of previous page being displayed.
    int prevScreen_;
	
	// The x coord of initial point the user starts their swipe.
	CGFloat startSwipe_;
	
	// For what distance user must slide finger to start scrolling menu.
	CGFloat minimumTouchLengthToSlide_; 
	
	// For what distance user must slide finger to change the page.
	CGFloat minimumTouchLengthToChangePage_; 
	
	// Whenever show or not gray/white dots under scrolling content.
	BOOL showPagesIndicator_;
	CGPoint pagesIndicatorPosition_;
    ccColor4B pagesIndicatorSelectedColor_;
    ccColor4B pagesIndicatorNormalColor_;
	
	// Internal state of scrollLayer (scrolling or idle).
	int state_;
	
	BOOL stealTouches_;
	
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
	// Holds the touch that started the scroll
	UITouch *scrollTouch_;
#endif
	
	// Holds pages.
	NSMutableArray *layers_;
	
	// Holds current pages width offset.
	CGFloat pagesWidthOffset_;
    
	// Holds current margin offset
	CGFloat marginOffset_;
}

@property (readwrite, assign) NSObject <CCScrollLayerDelegate> *delegate;

#pragma mark Scroll Config Properties

/** Calibration property. Minimum moving touch length that is enough
 * to cancel menu items and start scrolling a layer. 
 */
@property(readwrite, assign) CGFloat minimumTouchLengthToSlide;

/** Calibration property. Minimum moving touch length that is enough to change
 * the page, without snapping back to the previous selected page.
 */
@property(readwrite, assign) CGFloat minimumTouchLengthToChangePage;

/** Offset that can be used to let user see empty space over first or last page. */
@property(readwrite, assign) CGFloat  marginOffset;

/** If YES - when starting scrolling CCScrollLayer will claim touches, that are 
 * already claimed by others targetedTouchDelegates by calling CCTouchDispatcher#touchesCancelled
 * Usefull to have ability to scroll with touch above menus in pages.
 * If NO - scrolling will start, but no touches will be cancelled.
 * Default is YES.
 */
@property(readwrite) BOOL stealTouches;

#pragma mark Pages Indicator Properties

/** Whenever show or not white/grey dots under the scroll layer.
 * If yes - dots will be rendered in parents transform (rendered after scroller visit).
 */
@property(readwrite, assign) BOOL showPagesIndicator;

/** Position of dots center in parent coordinates. 
 * (Default value is screenWidth/2, screenHeight/4)
 */
@property(readwrite, assign) CGPoint pagesIndicatorPosition;

/** Color of dot, that represents current selected page(only one dot). */
@property(readwrite, assign) ccColor4B pagesIndicatorSelectedColor;

/** Color of dots, that represents other pages. */
@property(readwrite, assign) ccColor4B pagesIndicatorNormalColor;


#pragma mark Pages Control Properties

/** Total pages available in scrollLayer. */
@property(readonly) int totalScreens;

/** Current page number, that is shown. Belongs to the [0, totalScreen] interval. */
@property(readonly) int currentScreen;

/** Offset, that can be used to let user see next/previous page. */
@property(readwrite) CGFloat pagesWidthOffset;

/** Returns array of pages CCLayer's  */
@property(readonly) NSArray *pages;

#pragma mark Init/Creation

/** Creates new scrollLayer with given pages & width offset.
 * @param layers NSArray of CCLayers, that will be used as pages.
 * @param widthOffset Length in X-coord, that describes length of possible pages
 * intersection. */
+(id) nodeWithLayers:(NSArray *)layers widthOffset: (int) widthOffset; 
/** Inits scrollLayer with given pages & width offset.
 * @param layers NSArray of CCLayers, that will be used as pages.
 * @param widthOffset Length in X-coord, that describes length of possible pages
 * intersection. */
-(id) initWithLayers:(NSArray *)layers widthOffset: (int) widthOffset;

#pragma mark Updates 
/** Updates all pages positions & adds them as children if needed.
 * Can be used to update position of pages after screen reshape, or 
 * for update after dynamic page add/remove. 
 */
- (void) updatePages;

#pragma mark Adding/Removing Pages

/** Adds new page and reorders pages trying to set given number for newly added page.
 * If number > pages count - adds new page to the right end of the scroll layer.
 * If number <= 0 - adds new page to the left end of the scroll layer. 
 * @attention Designated addPage method. 
 */
- (void) addPage: (CCLayer *) aPage withNumber: (int) pageNumber;

/** Adds new page to the right end of the scroll layer. */
- (void) addPage: (CCLayer *) aPage;

/** Removes page if it's one of scroll layers pages (not children)
 * Does nothing if page not found.
 */
- (void) removePage: (CCLayer *) aPage;

/** Removes page with given number. Doesn nothing if there's no page for such number. */
- (void) removePageWithNumber: (int) page;

#pragma mark Moving/Selecting Pages

/* Moves scrollLayer to page with given number & invokes delegate
 * method scrollLayer:scrolledToPageNumber: at the end of CCMoveTo action. 
 * Does nothing if number >= totalScreens or < 0.
 */
-(void) moveToPage:(int)page;

/* Immedeatly moves scrollLayer to page with given number without running CCMoveTo. 
 * Does nothing if number >= totalScreens or < 0.
 */
-(void) selectPage:(int)page;

@end

