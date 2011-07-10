//
//  CCScrollLayer.m
//
//  Copyright 2010 DK101
//  http://dk101.net/2010/11/30/implementing-page-scrolling-in-cocos2d/
//
//  Copyright 2010 Giv Parvaneh.
//  http://www.givp.org/blog/2010/12/30/scrolling-menus-in-cocos2d/
//
//  Copyright 2011 Stepan Generalov
//  Copyright 2011 Jeff Keeme
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


#import "CCScrollLayer.h"
#import "CCGL.h"

enum 
{
	kCCScrollLayerStateIdle,
	kCCScrollLayerStateSliding,
};

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
@interface CCTouchDispatcher (targetedHandlersGetter)

- (NSMutableArray *) targetedHandlers;

@end

@implementation CCTouchDispatcher (targetedHandlersGetter)

- (NSMutableArray *) targetedHandlers
{
	return targetedHandlers;
}

@end
#endif


@implementation CCScrollLayer

@synthesize minimumTouchLengthToSlide = minimumTouchLengthToSlide_;
@synthesize minimumTouchLengthToChangePage = minimumTouchLengthToChangePage_;
@synthesize totalScreens = totalScreens_;
@synthesize currentScreen = currentScreen_;
@synthesize showPagesIndicator = showPagesIndicator_;
@synthesize pagesIndicatorPosition = pagesIndicatorPosition_;

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
		
		// Set default minimum touch length to scroll.
		self.minimumTouchLengthToSlide = 30.0f;
		self.minimumTouchLengthToChangePage = 100.0f;
		
		// Show indicator by default.
		self.showPagesIndicator = YES;
		self.pagesIndicatorPosition = ccp(0.5f * self.contentSize.width, ceilf ( self.contentSize.height / 8.0f ));
		//<TODO: update this value in updateForScreenReshape for Mac Support ( #22 )
		
		// Set up the starting variables
		currentScreen_ = 0;
		
		// offset added to show preview of next/previous screens
		scrollWidth_ = [[CCDirector sharedDirector] winSize].width - widthOffset;
		
		// Loop through the array and add the screens
		int i = 0;
		for (CCLayer *l in layers)
		{
			l.anchorPoint = ccp(0,0);
			l.position = ccp((i*scrollWidth_),0);
			[self addChild:l];
			i++;
		}
		
		// Setup a count of the available screens
		totalScreens_ = [layers count];
		
	}
	return self;
}

#pragma mark CCLayer Methods ReImpl

- (void) visit
{
	[super visit];//< Will draw after glPopScene. 
	
	if (self.showPagesIndicator)
	{
		// Prepare Points Array
		CGFloat n = (CGFloat)totalScreens_; //< Total points count in CGFloat.
		CGFloat pY = self.pagesIndicatorPosition.y; //< Points y-coord in parent coord sys.
		CGFloat d = 16.0f; //< Distance between points.
		CGPoint points[totalScreens_];	
		for (int i=0; i < totalScreens_; ++i)
		{
			CGFloat pX = self.pagesIndicatorPosition.x + d * ( (CGFloat)i - 0.5f*(n-1.0f) );
			points[i] = ccp (pX, pY);
		}
		
		// Set GL Values
		glEnable(GL_POINT_SMOOTH);
		GLboolean blendWasEnabled = glIsEnabled( GL_BLEND );
		glEnable(GL_BLEND);
		glBlendFunc( GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA );
		glPointSize( 6.0 * CC_CONTENT_SCALE_FACTOR() );
		
		// Draw Gray Points
		glColor4ub(0x96,0x96,0x96,0xFF);
		ccDrawPoints( points, totalScreens_ );
		
		// Draw White Point for Selected Page
		glColor4ub(0xFF,0xFF,0xFF,0xFF);
		ccDrawPoint(points[currentScreen_]);
		
		// Restore GL Values
		glPointSize(1.0f);
		glDisable(GL_POINT_SMOOTH);
		if (! blendWasEnabled)
			glDisable(GL_BLEND);
	}
}

#pragma mark Pages Control 

-(void) moveToPage:(int)page
{
    if (page < 0 || page >= totalScreens_) {
        CCLOGERROR(@"CCScrollLayer#moveToPage: %d - wrong page number, out of bounds. ", page);
		return;
    }

	id changePage = [CCMoveTo actionWithDuration:0.3 position:ccp( - page * scrollWidth_, 0.0f )];
    [self runAction:changePage];
    currentScreen_ = page;

}

-(void) selectPage:(int)page
{
    if (page < 0 || page >= totalScreens_) {
        CCLOGERROR(@"CCScrollLayer#moveToPage: %d - wrong page number, out of bounds. ", page);
		return;
    }
	
    self.position = ccp( - page * scrollWidth_, 0.0f );
    currentScreen_ = page;
	
}

#pragma mark Touches
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED

/** Register with more priority than CCMenu's but don't swallow touches. */
-(void) registerWithTouchDispatcher
{	
	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:kCCMenuTouchPriority - 1 swallowsTouches:NO];
}

/** Hackish stuff - stole touches from other CCTouchDispatcher targeted delegates. 
 Used to claim touch without receiving ccTouchBegan. */
- (void) claimTouch: (UITouch *) aTouch
{
	// Enumerate through all targeted handlers.
	for ( CCTargetedTouchHandler *handler in [[CCTouchDispatcher sharedDispatcher] targetedHandlers] )
	{
		// Only our handler should claim the touch.
		if (handler.delegate == self)
		{
			if (![handler.claimedTouches containsObject: aTouch])
			{
				[handler.claimedTouches addObject: aTouch];
			}
			else 
			{
				CCLOGERROR(@"CCScrollLayer#claimTouch: %@ is already claimed!", aTouch);
			}
			return;
		}
	}
}

- (void) cancelAndStoleTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
	// Throw Cancel message for everybody in TouchDispatcher.
	[[CCTouchDispatcher sharedDispatcher] touchesCancelled: [NSSet setWithObject: touch] withEvent:event];
	
	//< after doing this touch is already removed from all targeted handlers
	
	// Squirrel away the touch
	[self claimTouch: touch];
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
		
		[self cancelAndStoleTouch: touch withEvent: event];		
	}
	
	if (state_ == kCCScrollLayerStateSliding)
		self.position = ccp( (- currentScreen_ * scrollWidth_) + (touchPoint.x-startSwipe_),0);	
	
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
	if( scrollTouch_ == touch ) {
		scrollTouch_ = nil;
	}
	
	CGPoint touchPoint = [touch locationInView:[touch view]];
	touchPoint = [[CCDirector sharedDirector] convertToGL:touchPoint];
	
	int newX = touchPoint.x;	
	
	if ( (newX - startSwipe_) < -self.minimumTouchLengthToChangePage && (currentScreen_+1) < totalScreens_ )
	{		
		[self moveToPage: currentScreen_+1];		
	}
	else if ( (newX - startSwipe_) > self.minimumTouchLengthToChangePage && currentScreen_ > 0 )
	{		
		[self moveToPage: currentScreen_-1];		
	}
	else
	{		
		[self moveToPage:currentScreen_];		
	}	
}

#endif

@end

