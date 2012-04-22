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


#import "CCScrollLayer.h"
#import "CCGL.h"

enum 
{
	kCCScrollLayerStateIdle,
	kCCScrollLayerStateSliding,
};

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
@interface CCTouchDispatcher (targetedHandlersGetter)

- (id<NSFastEnumeration>) targetedHandlers;

@end

@implementation CCTouchDispatcher (targetedHandlersGetter)

- (id<NSFastEnumeration>) targetedHandlers
{
	return targetedHandlers;
}

@end
#endif

@interface CCScrollLayer ()

- (int) pageNumberForPosition: (CGPoint) position;

@end

@implementation CCScrollLayer

@synthesize delegate = delegate_;
@synthesize minimumTouchLengthToSlide = minimumTouchLengthToSlide_;
@synthesize minimumTouchLengthToChangePage = minimumTouchLengthToChangePage_;
@synthesize marginOffset = marginOffset_;
@synthesize currentScreen = currentScreen_;
@synthesize showPagesIndicator = showPagesIndicator_;
@synthesize pagesIndicatorPosition = pagesIndicatorPosition_;
@synthesize pagesIndicatorNormalColor = pagesIndicatorNormalColor_;
@synthesize pagesIndicatorSelectedColor = pagesIndicatorSelectedColor_;
@synthesize pagesWidthOffset = pagesWidthOffset_;
@synthesize pages = layers_;
@synthesize stealTouches = stealTouches_;

@dynamic totalScreens;
- (int) totalScreens
{
	return [layers_ count];
}

+(id) nodeWithLayers:(NSArray *)layers widthOffset: (int) widthOffset
{
	return [[[self alloc] initWithLayers: layers widthOffset:widthOffset] autorelease];
}

-(id) initWithLayers:(NSArray *)layers widthOffset: (int) widthOffset
{
	if ( (self = [super init]) )
	{
		NSAssert([layers count], @"CCScrollLayer#initWithLayers:widthOffset: you must provide at least one layer!");
		
		// Enable Touches/Mouse.
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
		self.isTouchEnabled = YES;
#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
        self.isMouseEnabled = YES;
#endif
		
		self.stealTouches = YES;
		
		// Set default minimum touch length to scroll.
		self.minimumTouchLengthToSlide = 30.0f;
		self.minimumTouchLengthToChangePage = 100.0f;
		
		self.marginOffset = [[CCDirector sharedDirector] winSize].width;
		
		// Show indicator by default.
		self.showPagesIndicator = YES;
		self.pagesIndicatorPosition = ccp(0.5f * self.contentSize.width, ceilf ( self.contentSize.height / 8.0f ));
		self.pagesIndicatorNormalColor = ccc4(0x96,0x96,0x96,0xFF);
        self.pagesIndicatorSelectedColor = ccc4(0xFF,0xFF,0xFF,0xFF);

		// Set up the starting variables
		currentScreen_ = 0;	
		
		// Save offset.
		self.pagesWidthOffset = widthOffset;			
		
		// Save array of layers.
		layers_ = [[NSMutableArray alloc] initWithArray:layers copyItems:NO];
        
		[self updatePages];			
		
	}
	return self;
}

- (void) dealloc
{
	self.delegate = nil;
	
	[layers_ release];
	layers_ = nil;
	
	[super dealloc];
}

- (void) updatePages
{
	// Loop through the array and add the screens if needed.
	int i = 0;
	for (CCLayer *l in layers_)
	{
		l.anchorPoint = ccp(0,0);
		l.contentSize = [CCDirector sharedDirector].winSize;
		l.position = ccp(  (i * (self.contentSize.width - self.pagesWidthOffset)), 0  );
		if (!l.parent)
			[self addChild:l];
		i++;
	}
}

#pragma mark CCLayer Methods ReImpl

- (void) visit
{
	[super visit];//< Will draw after glPopScene. 
	
	if (self.showPagesIndicator)
	{
		int totalScreens = [layers_ count];
		
		// Prepare Points Array
		CGFloat n = (CGFloat)totalScreens; //< Total points count in CGFloat.
		CGFloat pY = self.pagesIndicatorPosition.y; //< Points y-coord in parent coord sys.
		CGFloat d = 16.0f; //< Distance between points.
		CGPoint points[totalScreens];	
		for (int i=0; i < totalScreens; ++i)
		{
			CGFloat pX = self.pagesIndicatorPosition.x + d * ( (CGFloat)i - 0.5f*(n-1.0f) );
			points[i] = ccp (pX, pY);
		}
		
		// Set GL Values
#if COCOS2D_VERSION >= 0x00020000
        ccGLEnable(CC_GL_BLEND);
        ccPointSize( 6.0 * CC_CONTENT_SCALE_FACTOR() );
#define DRAW_4B_FUNC ccDrawColor4B
        
#else
        glEnable(GL_POINT_SMOOTH);
        GLboolean blendWasEnabled = glIsEnabled( GL_BLEND );
        glEnable(GL_BLEND);
        
        // save the old blending functions
        int blend_src = 0;
        int blend_dst = 0;
        glGetIntegerv( GL_BLEND_SRC, &blend_src );
        glGetIntegerv( GL_BLEND_DST, &blend_dst );
        glPointSize( 6.0 * CC_CONTENT_SCALE_FACTOR() );
        
#define DRAW_4B_FUNC glColor4ub        

#endif
        glBlendFunc( GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA );
 		
 		// Draw Gray Points
        DRAW_4B_FUNC(pagesIndicatorNormalColor_.r,
                     pagesIndicatorNormalColor_.g,
                     pagesIndicatorNormalColor_.b,
                     pagesIndicatorNormalColor_.a);
        
        ccDrawPoints( points, totalScreens );
                           
        // Draw White Point for Selected Page	
        DRAW_4B_FUNC(pagesIndicatorSelectedColor_.r,
                     pagesIndicatorSelectedColor_.g,
                     pagesIndicatorSelectedColor_.b,
                     pagesIndicatorSelectedColor_.a);
        ccDrawPoint(points[currentScreen_]);
                                               
        // Restore GL Values
#if COCOS2D_VERSION >= 0x00020000
        ccPointSize(1.0f);
#else
        glPointSize(1.0f);
        glDisable(GL_POINT_SMOOTH);
        if (! blendWasEnabled)
            glDisable(GL_BLEND);
        
        // always restore the blending functions too
        glBlendFunc( blend_src, blend_dst );
#endif		
	}
}

#pragma mark Moving To / Selecting Pages

- (void) moveToPageEnded
{
    if (prevScreen_ != currentScreen_)
    {
        if ([self.delegate respondsToSelector:@selector(scrollLayer:scrolledToPageNumber:)])
            [self.delegate scrollLayer: self scrolledToPageNumber: currentScreen_];
    }
    
    prevScreen_ = currentScreen_ = [self pageNumberForPosition:self.position];
}

- (int) pageNumberForPosition: (CGPoint) position
{
	CGFloat pageFloat = - self.position.x / (self.contentSize.width - self.pagesWidthOffset);
	int pageNumber = ceilf(pageFloat);
	if ( (CGFloat)pageNumber - pageFloat  >= 0.5f)
		pageNumber--;
	
	
	pageNumber = MAX(0, pageNumber);
	pageNumber = MIN([layers_ count] - 1, pageNumber);
	
	return pageNumber;
}
	

- (CGPoint) positionForPageWithNumber: (int) pageNumber
{
	return ccp( - pageNumber * (self.contentSize.width - self.pagesWidthOffset), 0.0f );
}

-(void) moveToPage:(int)page
{	
    if (page < 0 || page >= [layers_ count]) {
        CCLOGERROR(@"CCScrollLayer#moveToPage: %d - wrong page number, out of bounds. ", page);
		return;
    }

	id changePage = [CCMoveTo actionWithDuration:0.3 position: [self positionForPageWithNumber: page]];
	changePage = [CCSequence actions: changePage,[CCCallFunc actionWithTarget:self selector:@selector(moveToPageEnded)], nil];
    [self runAction:changePage];
    currentScreen_ = page;

}

-(void) selectPage:(int)page
{
    if (page < 0 || page >= [layers_ count]) {
        CCLOGERROR(@"CCScrollLayer#selectPage: %d - wrong page number, out of bounds. ", page);
		return;
    }
	
    self.position = [self positionForPageWithNumber: page];
    prevScreen_ = currentScreen_;
    currentScreen_ = page;
	
}

#pragma mark Dynamic Pages Control

- (void) addPage: (CCLayer *) aPage
{
	[self addPage: aPage withNumber: [layers_ count]];
}

- (void) addPage: (CCLayer *) aPage withNumber: (int) pageNumber
{
	pageNumber = MIN(pageNumber, [layers_ count]);
	pageNumber = MAX(pageNumber, 0);
	
	[layers_ insertObject: aPage atIndex: pageNumber];
	
	[self updatePages];
	
	[self moveToPage: currentScreen_];
}

- (void) removePage: (CCLayer *) aPage
{
	[layers_ removeObject: aPage];
	[self removeChild: aPage cleanup: YES];
	
	[self updatePages];
	
    prevScreen_ = currentScreen_;
	currentScreen_ = MIN(currentScreen_, [layers_ count] - 1);
	[self moveToPage: currentScreen_];
}

- (void) removePageWithNumber: (int) page
{
	if (page >= 0 && page < [layers_ count])
		[self removePage:[layers_ objectAtIndex: page]];
}

#pragma mark Touches
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED

/** Register with more priority than CCMenu's but don't swallow touches. */
-(void) registerWithTouchDispatcher
{	
#if COCOS2D_VERSION >= 0x00020000
    CCTouchDispatcher *dispatcher = [[CCDirector sharedDirector] touchDispatcher];
    int priority = kCCMenuHandlerPriority - 1;
#else
    CCTouchDispatcher *dispatcher = [CCTouchDispatcher sharedDispatcher];
    int priority = kCCMenuTouchPriority - 1;
#endif
    
	[dispatcher addTargetedDelegate:self priority: priority swallowsTouches:NO];    
}

/** Hackish stuff - stole touches from other CCTouchDispatcher targeted delegates. 
 Used to claim touch without receiving ccTouchBegan. */
- (void) claimTouch: (UITouch *) aTouch
{
#if COCOS2D_VERSION >= 0x00020000
    CCTouchDispatcher *dispatcher = [[CCDirector sharedDirector] touchDispatcher];
#else
    CCTouchDispatcher *dispatcher = [CCTouchDispatcher sharedDispatcher];
#endif
    
	// Enumerate through all targeted handlers.
	for ( CCTargetedTouchHandler *handler in [dispatcher targetedHandlers] )
	{
		// Only our handler should claim the touch.
		if (handler.delegate == self)
		{
			if (![handler.claimedTouches containsObject: aTouch])
			{
				[handler.claimedTouches addObject: aTouch];
			}
		}
        else 
        {
            // Steal touch from other targeted delegates, if they claimed it.
            if ([handler.claimedTouches containsObject: aTouch])
            {
                if ([handler.delegate respondsToSelector:@selector(ccTouchCancelled:withEvent:)])
                {
                    [handler.delegate ccTouchCancelled: aTouch withEvent: nil];
                }
                [handler.claimedTouches removeObject: aTouch];
            }
        }
	}
}

-(void)ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event 
{
    if( scrollTouch_ == touch ) {
        scrollTouch_ = nil;
        [self selectPage: currentScreen_];
    }
}

-(BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
	if( scrollTouch_ == nil ) {
		scrollTouch_ = touch;
	} else {
		return NO;
	}
	
	CGPoint touchPoint = [touch locationInView:[touch view]];
	touchPoint = [[CCDirector sharedDirector] convertToGL:touchPoint];
	
	startSwipe_ = touchPoint.x;
	state_ = kCCScrollLayerStateIdle;
	return YES;
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
	if( scrollTouch_ != touch ) {
		return;
	}
	
	CGPoint touchPoint = [touch locationInView:[touch view]];
	touchPoint = [[CCDirector sharedDirector] convertToGL:touchPoint];
	
	
	// If finger is dragged for more distance then minimum - start sliding and cancel pressed buttons.
	// Of course only if we not already in sliding mode
	if ( (state_ != kCCScrollLayerStateSliding) 
		&& (fabsf(touchPoint.x-startSwipe_) >= self.minimumTouchLengthToSlide) )
	{
		state_ = kCCScrollLayerStateSliding;
		
		// Avoid jerk after state change.
		startSwipe_ = touchPoint.x;
		
		if (self.stealTouches)
        {
			[self claimTouch: touch];
        }
		
		if ([self.delegate respondsToSelector:@selector(scrollLayerScrollingStarted:)])
		{
			[self.delegate scrollLayerScrollingStarted: self];
		}
	}
	
	if (state_ == kCCScrollLayerStateSliding)
	{
		CGFloat desiredX = (- currentScreen_ * (self.contentSize.width - self.pagesWidthOffset)) + touchPoint.x - startSwipe_;
		int page = [self pageNumberForPosition:ccp(desiredX, 0)];
		CGFloat offset = desiredX - [self positionForPageWithNumber:page].x; 
		if ((page == 0 && offset > 0) || (page == [layers_ count] - 1 && offset < 0))
			offset -= marginOffset_ * offset / [[CCDirector sharedDirector] winSize].width;
		else
			offset = 0;
		self.position = ccp(desiredX - offset, 0);
	}
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
	if( scrollTouch_ != touch )
		return;
	scrollTouch_ = nil;
	
	CGPoint touchPoint = [touch locationInView:[touch view]];
	touchPoint = [[CCDirector sharedDirector] convertToGL:touchPoint];
	
	int selectedPage = currentScreen_;
	CGFloat delta = touchPoint.x - startSwipe_;
	if (fabsf(delta) >= self.minimumTouchLengthToChangePage)
	{
		selectedPage = [self pageNumberForPosition:self.position];
		if (selectedPage == currentScreen_)
		{
			if (delta < 0.f && selectedPage < [layers_ count] - 1)
				selectedPage++;
			else if (delta > 0.f && selectedPage > 0)
				selectedPage--;
		}
	}
	[self moveToPage:selectedPage];	
}

#endif

#pragma mark Mouse
#ifdef __MAC_OS_X_VERSION_MAX_ALLOWED

- (NSInteger) mouseDelegatePriority
{
#if COCOS2D_VERSION >= 0x00020000
    return kCCMenuHandlerPriority - 1;
#else
	return kCCMenuMousePriority - 1;
#endif
}

-(BOOL) ccMouseDown:(NSEvent*)event
{
	CGPoint touchPoint = [[CCDirector sharedDirector] convertEventToGL: event];
	
	startSwipe_ = touchPoint.x;
	state_ = kCCScrollLayerStateIdle;
	
	return NO;
}

-(BOOL) ccMouseDragged:(NSEvent*)event
{
	CGPoint touchPoint = [[CCDirector sharedDirector] convertEventToGL:event];
	
	// If mouse is dragged for more distance then minimum - start sliding.
	if ( (state_ != kCCScrollLayerStateSliding) 
		&& (fabsf(touchPoint.x-startSwipe_) >= self.minimumTouchLengthToSlide) )
	{
		state_ = kCCScrollLayerStateSliding;
		
		// Avoid jerk after state change.
		startSwipe_ = touchPoint.x;
		
		if ([self.delegate respondsToSelector:@selector(scrollLayerScrollingStarted:)])
		{
			[self.delegate scrollLayerScrollingStarted: self];
		}
	}
	
	if (state_ == kCCScrollLayerStateSliding)
    {
        CGFloat desiredX = (- currentScreen_ * (self.contentSize.width - self.pagesWidthOffset)) + touchPoint.x - startSwipe_;
        int page = [self pageNumberForPosition:ccp(desiredX, 0)]; 		
        CGFloat offset = desiredX - [self positionForPageWithNumber:page].x;  		
        if ((page == 0 && offset > 0) || (page == [layers_ count] - 1 && offset < 0))        	
            offset -= marginOffset_ * offset / [[CCDirector sharedDirector] winSize].width;
        else        
            offset = 0;
 		
        self.position = ccp(desiredX - offset, 0);
    }
	
	return NO;
}

- (BOOL)ccMouseUp:(NSEvent *)event
{
	CGPoint touchPoint = [[CCDirector sharedDirector] convertEventToGL:event];
	
	int selectedPage = currentScreen_;
	CGFloat delta = touchPoint.x - startSwipe_;
	if (fabsf(delta) >= self.minimumTouchLengthToChangePage)
	{
		selectedPage = [self pageNumberForPosition:self.position];
		if (selectedPage == currentScreen_)
		{
			if (delta < 0.f && selectedPage < [layers_ count] - 1)
				selectedPage++;
			else if (delta > 0.f && selectedPage > 0)
				selectedPage--;
		}
	}
	[self moveToPage:selectedPage];		
	
	return NO;
}

- (BOOL)ccScrollWheel:(NSEvent *)theEvent
{
	CGFloat deltaX = [theEvent deltaX];
	
	CGPoint newPos = ccpAdd( self.position, ccp(deltaX, 0.0f) );
	newPos.x = MIN(newPos.x, [self positionForPageWithNumber: 0].x);
	newPos.x = MAX(newPos.x, [self positionForPageWithNumber: [layers_ count] - 1].x);
	
	self.position = newPos;
    prevScreen_ = currentScreen_;
	currentScreen_ = [self pageNumberForPosition:self.position];
    
    // Inform delegate about new currentScreen.
    if (prevScreen_ != currentScreen_)
    {
        if ([self.delegate respondsToSelector:@selector(scrollLayer:scrolledToPageNumber:)])
            [self.delegate scrollLayer: self scrolledToPageNumber: currentScreen_];
    }
    
    prevScreen_ = currentScreen_;
	
	return NO;
	
}

#endif

@end

