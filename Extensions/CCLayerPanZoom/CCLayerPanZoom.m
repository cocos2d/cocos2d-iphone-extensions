/*
 * CCLayerPanZoom Tests
 *
 * cocos2d-extensions
 * https://github.com/cocos2d/cocos2d-iphone-extensions
 *
 * Copyright (c) 2011 Alexey Lang
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


#import "CCLayerPanZoom.h"


#ifdef DEBUG

@implementation CCLayerPanZoomDebugGrid

@synthesize topFrameMargin = _topFrameMargin, bottomFrameMargin = _bottomFrameMargin, 
            leftFrameMargin = _leftFrameMargin, rightFrameMargin = _rightFrameMargin;

- (void) draw
{
    glColor4f(1.0f, 0.0f, 0.0f, 1.0);
    glLineWidth(2.0f);    
    ccDrawLine(ccp(self.leftFrameMargin, 0.0f), 
               ccp(self.leftFrameMargin, self.contentSize.height));
    ccDrawLine(ccp(self.contentSize.width - self.rightFrameMargin, 0.0f), 
               ccp(self.contentSize.width - self.rightFrameMargin, self.contentSize.height));
    ccDrawLine(ccp(0.0f, self.bottomFrameMargin), 
               ccp(self.contentSize.width, self.bottomFrameMargin));
    ccDrawLine(ccp(0.0f, self.contentSize.height - self.topFrameMargin), 
               ccp(self.contentSize.width, self.contentSize.height - self.topFrameMargin));
}

@end

#endif


typedef enum
{
    kCCLayerPanZoomFrameEdgeNone,
    kCCLayerPanZoomFrameEdgeTop,
    kCCLayerPanZoomFrameEdgeBottom,
    kCCLayerPanZoomFrameEdgeLeft,
    kCCLayerPanZoomFrameEdgeRight,
    kCCLayerPanZoomFrameEdgeTopLeft,
    kCCLayerPanZoomFrameEdgeBottomLeft,
    kCCLayerPanZoomFrameEdgeTopRight,
    kCCLayerPanZoomFrameEdgeBottomRight
} CCLayerPanZoomFrameEdge;


@interface CCLayerPanZoom ()

@property (readwrite, retain) NSMutableArray *touches;
@property (readwrite, assign) CGFloat touchDistance;
@property (readwrite, retain) CCScheduler *scheduler;
// Fix position for the layer considering panBoundsRect and enablePanBounds
- (void) fixLayerPosition;
// Fix scale for the layer considering panBoundsRect and enablePanBounds
- (void) fixLayerScale;
// Return minimum possible scale for the layer considering panBoundsRect and enablePanBounds
- (CGFloat) minPossibleScale;
// Return edge in which current point located
- (CCLayerPanZoomFrameEdge) frameEdgeWithPoint: (CGPoint) point;
// Return horizontal speed in order with current position
- (CGFloat) horSpeedWithPosition: (CGPoint) pos;
// Return vertical speed in order with current position
- (CGFloat) vertSpeedWithPosition: (CGPoint) pos;

@end


@implementation CCLayerPanZoom

@synthesize maxScale = _maxScale, minScale = _minScale, maxTouchDistanceToClick = _maxTouchDistanceToClick, 
            delegate = _delegate, mode = _mode, touches = _touches, touchDistance = _touchDistance, 
            minSpeed = _minSpeed, maxSpeed = _maxSpeed, topFrameMargin = _topFrameMargin, 
            bottomFrameMargin = _bottomFrameMargin, leftFrameMargin = _leftFrameMargin,
            rightFrameMargin = _rightFrameMargin, scheduler = _scheduler;

#pragma mark Init

- (id) init
{
	if ((self = [super init])) 
	{
		self.isRelativeAnchorPoint = YES;
		self.isTouchEnabled = YES;
		
		self.maxScale = 2.0f;
		self.minScale = 0.1f;
		self.touches = [NSMutableArray arrayWithCapacity: 10];
		self.panBoundsRect = CGRectNull;
		self.touchDistance = 0.0F;
		self.maxTouchDistanceToClick = 15.0f;
        self.mode = kCCLayerPanZoomModeFrame;
        self.minSpeed = 100.0f;
        self.maxSpeed = 1000.0f;
        self.topFrameMargin = 100.0f;
        self.bottomFrameMargin = 100.0f;
        self.leftFrameMargin = 100.0f;
        self.rightFrameMargin = 100.0f;
	}	
	return self;
}

#pragma mark CCStandardTouchDelegate Touch events

- (void) ccTouchesBegan: (NSSet *) touches 
			  withEvent: (UIEvent *) event
{	
	for (UITouch *touch in [touches allObjects]) 
	{
		// Add new touche to the array with current touches
		[self.touches addObject: touch];
	}
}

- (void) ccTouchesMoved: (NSSet *) touches 
			  withEvent: (UIEvent *) event
{
	BOOL multitouch = [self.touches count] > 1;
	if (multitouch)
	{
		// Get the two first touches
        UITouch *touch1 = [self.touches objectAtIndex: 0];
		UITouch *touch2 = [self.touches objectAtIndex: 1];
		// Get current and previous positions of the touches
		CGPoint curPosTouch1 = [[CCDirector sharedDirector] convertToGL: [touch1 locationInView: [touch1 view]]];
		CGPoint curPosTouch2 = [[CCDirector sharedDirector] convertToGL: [touch2 locationInView: [touch2 view]]];
		CGPoint prevPosTouch1 = [[CCDirector sharedDirector] convertToGL: [touch1 previousLocationInView: [touch1 view]]];
		CGPoint prevPosTouch2 = [[CCDirector sharedDirector] convertToGL: [touch2 previousLocationInView: [touch2 view]]];
		// Calculate current and previous positions of the layer relative the anchor point
		CGPoint curPosLayer = ccpMidpoint(curPosTouch1, curPosTouch2);
		CGPoint prevPosLayer = ccpMidpoint(prevPosTouch1, prevPosTouch2);
		// If current and previous positions of the layer were fuzzy equal then they are equal
		if (ccpFuzzyEqual(prevPosLayer, curPosLayer, 2))
		{
			prevPosLayer = curPosLayer;
		}
		// Calculate new scale
		CGFloat newScale = self.scale * (ccpDistance(curPosTouch1, curPosTouch2) / ccpDistance(prevPosTouch1, prevPosTouch2));		
		self.scale = MIN(MAX(newScale, self.minScale), self.maxScale);
		[self fixLayerScale];
		// Calculate new anchor point
		CGPoint newAnchorInPixels = [self convertToNodeSpace: prevPosLayer];
		self.anchorPoint = ccp(newAnchorInPixels.x / self.contentSize.width, newAnchorInPixels.y / self.contentSize.height);
		// Set new position of the layer
		self.position = curPosLayer;
		[self fixLayerPosition];
		// Don't click with multitouch
		self.touchDistance = INFINITY;
	}
	else
	{	        
        // in order with current mode
        if (self.mode == kCCLayerPanZoomModeSheet)
        {
            // Get the one touch
            UITouch *touch = [self.touches objectAtIndex: 0];        
            // Get current positions of the touch
            CGPoint curPosTouch = [[CCDirector sharedDirector] convertToGL: [touch locationInView: [touch view]]];
            // Get previous positions of the touch
            CGPoint prevPosTch = [[CCDirector sharedDirector] convertToGL: [touch previousLocationInView: [touch view]]];
            // Calculate new anchor point
            CGPoint newAnchorInPixels = [self convertToNodeSpace: prevPosTch];
            self.anchorPoint = ccp(newAnchorInPixels.x / self.contentSize.width, newAnchorInPixels.y / self.contentSize.height);
            // Set new position of the layer
            self.position = curPosTouch;		
            [self fixLayerPosition];
            // Accumulate touche distance
            self.touchDistance += ccpDistance(curPosTouch, prevPosTch);
        }
    }	
}

- (void) ccTouchesEnded: (NSSet *) touches 
			  withEvent: (UIEvent *) event
{
	if (self.mode == kCCLayerPanZoomModeSheet)
    {
        // Obtain click event
        if ((self.touchDistance < self.maxTouchDistanceToClick) && (self.delegate))
        {
            UITouch *touch = [self.touches objectAtIndex: 0];        
            CGPoint curPos = [[CCDirector sharedDirector] convertToGL: [touch locationInView: [touch view]]];
            [self.delegate layerPanZoom: self 
                         clickedAtPoint: [self convertToNodeSpace: curPos]];
        }
    }
	for (UITouch *touch in [touches allObjects]) 
	{
		// Remove touche from the array with current touches
		[self.touches removeObject: touch];
	}
	if ([self.touches count] == 0)
	{
		self.touchDistance = 0.0f;
	}
}

- (void) ccTouchesCancelled: (NSSet *) touches 
				  withEvent: (UIEvent *) event
{
	for (UITouch *touch in [touches allObjects]) 
	{
		// Remove touche from the array with current touches
		[self.touches removeObject: touch];
	}
	if ([self.touches count] == 0)
	{
		self.touchDistance = 0.0f;
	}
}

#pragma mark Update

- (void) update: (ccTime) dt
{
    // for single touch and frame mode
	if ([self.touches count] == 1 && self.mode == kCCLayerPanZoomModeFrame)
    {
        // Get the one touch
        UITouch *touch = [self.touches objectAtIndex: 0];        
        // Get current positions of the touche
        CGPoint curPos = [[CCDirector sharedDirector] convertToGL: [touch locationInView: [touch view]]];
        
        if ([self frameEdgeWithPoint: curPos] != kCCLayerPanZoomFrameEdgeNone)
        {
            self.position = ccp(self.position.x + dt * [self horSpeedWithPosition: curPos], 
                                self.position.y + dt * [self vertSpeedWithPosition: curPos]);
            [self fixLayerPosition];
        }
        
        CGPoint touchPositionInLayer = [self convertToNodeSpace: curPos];
        if (!CGPointEqualToPoint(_prevSingleTouchPositionInLayer, touchPositionInLayer))
        {
            _prevSingleTouchPositionInLayer = touchPositionInLayer;
            [self.delegate layerPanZoom: self 
                   touchPositionUpdated: touchPositionInLayer];
        }
    }
}

- (void) onEnter
{
    [super onEnter];
    [[CCScheduler sharedScheduler] scheduleUpdateForTarget: self 
                                                  priority: 0 
                                                    paused: NO];
#ifdef DEBUG
    CCLayerPanZoomDebugGrid *grid = [CCLayerPanZoomDebugGrid node];
    [grid setContentSize: [CCDirector sharedDirector].winSize];
    grid.topFrameMargin = self.topFrameMargin;
    grid.bottomFrameMargin = self.bottomFrameMargin;
    grid.leftFrameMargin = self.leftFrameMargin;
    grid.rightFrameMargin = self.rightFrameMargin;
    [[CCDirector sharedDirector].runningScene addChild: grid 
                                                     z: NSIntegerMax];
#endif
}

- (void) onExit
{
    [[CCScheduler sharedScheduler] unscheduleAllSelectorsForTarget: self];
    [super onExit];
}

#pragma mark Scale and Position related

@dynamic panBoundsRect;

- (void) setPanBoundsRect: (CGRect) rect
{
	_panBoundsRect = rect;
	[self fixLayerScale];
	[self fixLayerPosition];
}

- (CGRect) panBoundsRect
{
	return _panBoundsRect;
}

- (void) fixLayerPosition
{
	if (!CGRectIsNull(self.panBoundsRect))
	{
		// Check the pan bounds and fix (if it's need) position
		CGRect boundBox = [self boundingBox];
		if (self.position.x - boundBox.size.width * self.anchorPoint.x > self.panBoundsRect.origin.x)
		{
			[self setPosition: ccp(boundBox.size.width * self.anchorPoint.x + self.panBoundsRect.origin.x, 
								   self.position.y)];
		}	
		if (self.position.y - boundBox.size.height * self.anchorPoint.y > self.panBoundsRect.origin.y)
		{
			[self setPosition: ccp(self.position.x, boundBox.size.height * self.anchorPoint.y + 
								   self.panBoundsRect.origin.y)];
		}
		if (self.position.x + boundBox.size.width * (1 - self.anchorPoint.x) < self.panBoundsRect.size.width +
			self.panBoundsRect.origin.x)
		{
			[self setPosition: ccp(self.panBoundsRect.size.width + self.panBoundsRect.origin.x - 
								   boundBox.size.width * (1 - self.anchorPoint.x), self.position.y)];
		}
		if (self.position.y + boundBox.size.height * (1 - self.anchorPoint.y) < self.panBoundsRect.size.height + 
			self.panBoundsRect.origin.y)
		{
			[self setPosition: ccp(self.position.x, self.panBoundsRect.size.height + self.panBoundsRect.origin.y - 
								   boundBox.size.height * (1 - self.anchorPoint.y))];
		}	
	}
}

- (void) fixLayerScale
{
	if (!CGRectIsNull(self.panBoundsRect))
	{
		// Check the pan bounds and fix (if it's need) scale
		CGRect boundBox = [self boundingBox];
		if ((boundBox.size.width < self.panBoundsRect.size.width) || (boundBox.size.height < self.panBoundsRect.size.height))
			self.scale = [self minPossibleScale];	
	}
}

- (CGFloat) minPossibleScale
{
	if (!CGRectIsNull(self.panBoundsRect))
	{
		return MAX(self.panBoundsRect.size.width / self.contentSize.width,
				   self.panBoundsRect.size.height / self.contentSize.height);
	}
	else 
	{
		return self.minScale;
	}
}

- (CCLayerPanZoomFrameEdge) frameEdgeWithPoint: (CGPoint) point
{
    BOOL isLeft = point.x <= self.panBoundsRect.origin.x + self.leftFrameMargin;
    BOOL isRight = point.x >= self.panBoundsRect.origin.x + self.panBoundsRect.size.width - self.rightFrameMargin;
    BOOL isBottom = point.y <= self.panBoundsRect.origin.y + self.bottomFrameMargin;
    BOOL isTop = point.y >= self.panBoundsRect.origin.y + self.panBoundsRect.size.height - self.topFrameMargin;
    
    if (isLeft && isBottom)
    {
        return kCCLayerPanZoomFrameEdgeBottomLeft;
    }
    if (isLeft && isTop)
    {
        return kCCLayerPanZoomFrameEdgeTopLeft;
    }
    if (isRight && isBottom)
    {
        return kCCLayerPanZoomFrameEdgeBottomRight;
    }
    if (isRight && isTop)
    {
        return kCCLayerPanZoomFrameEdgeTopRight;
    }
    
    if (isLeft)
    {
        return kCCLayerPanZoomFrameEdgeLeft;
    }
    if (isTop)
    {
        return kCCLayerPanZoomFrameEdgeTop;
    }
    if (isRight)
    {
        return kCCLayerPanZoomFrameEdgeRight;
    }
    if (isBottom)
    {
        return kCCLayerPanZoomFrameEdgeBottom;
    }
    
    return kCCLayerPanZoomFrameEdgeNone;
}

- (CGFloat) horSpeedWithPosition: (CGPoint) pos
{
    CCLayerPanZoomFrameEdge edge = [self frameEdgeWithPoint: pos];
    CGFloat speed = 0.0f;
    if (edge == kCCLayerPanZoomFrameEdgeLeft)
    {
        speed = self.minSpeed + (self.maxSpeed - self.minSpeed) * 
        (self.panBoundsRect.origin.x + self.leftFrameMargin - pos.x) / self.leftFrameMargin;
    }
    if (edge == kCCLayerPanZoomFrameEdgeBottomLeft || edge == kCCLayerPanZoomFrameEdgeTopLeft)
    {
        speed = self.minSpeed + (self.maxSpeed - self.minSpeed) * 
        (self.panBoundsRect.origin.x + self.leftFrameMargin - pos.x) / (self.leftFrameMargin * sqrt(2.0f));
    }
    if (edge == kCCLayerPanZoomFrameEdgeRight)
    {
        speed = - (self.minSpeed + (self.maxSpeed - self.minSpeed) * 
            (pos.x - self.panBoundsRect.origin.x - self.panBoundsRect.size.width + 
             self.rightFrameMargin) / self.rightFrameMargin);
    }
    if (edge == kCCLayerPanZoomFrameEdgeBottomRight || edge == kCCLayerPanZoomFrameEdgeTopRight)
    {
        speed = - (self.minSpeed + (self.maxSpeed - self.minSpeed) * 
            (pos.x - self.panBoundsRect.origin.x - self.panBoundsRect.size.width + 
             self.rightFrameMargin) / (self.rightFrameMargin * sqrt(2.0f)));
    }
    CCLOG(@"horizontal speed = %f", speed);
    return speed;
}

- (CGFloat) vertSpeedWithPosition: (CGPoint) pos
{
    CCLayerPanZoomFrameEdge edge = [self frameEdgeWithPoint: pos];
    CGFloat speed = 0.0f;
    if (edge == kCCLayerPanZoomFrameEdgeBottom)
    {
        speed = self.minSpeed + (self.maxSpeed - self.minSpeed) * 
            (self.panBoundsRect.origin.y + self.bottomFrameMargin - pos.y) / self.bottomFrameMargin;
    }
    if (edge == kCCLayerPanZoomFrameEdgeBottomLeft || edge == kCCLayerPanZoomFrameEdgeBottomRight)
    {
        speed = self.minSpeed + (self.maxSpeed - self.minSpeed) * 
            (self.panBoundsRect.origin.y + self.bottomFrameMargin - pos.y) / (self.bottomFrameMargin * sqrt(2.0f));
    }
    if (edge == kCCLayerPanZoomFrameEdgeTop)
    {
        speed = - (self.minSpeed + (self.maxSpeed - self.minSpeed) * 
            (pos.y - self.panBoundsRect.origin.y - self.panBoundsRect.size.height + 
             self.topFrameMargin) / self.topFrameMargin);
    }
    if (edge == kCCLayerPanZoomFrameEdgeTopLeft || edge == kCCLayerPanZoomFrameEdgeTopRight)
    {
        speed = - (self.minSpeed + (self.maxSpeed - self.minSpeed) * 
            (pos.y - self.panBoundsRect.origin.y - self.panBoundsRect.size.height + 
             self.topFrameMargin) / (self.topFrameMargin * sqrt(2.0f)));
    }
    CCLOG(@"vertical speed = %f", speed);
    return speed;
}

#pragma mark Dealloc

- (void) dealloc
{
	self.touches = nil;
	self.delegate = nil;
	[super dealloc];
}

@end
