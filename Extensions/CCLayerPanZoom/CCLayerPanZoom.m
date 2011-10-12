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

/** @class CCLayerPanZoomDebugLines Class that represents lines over the CCLayerPanZoom 
 * for debug frame mode */
@interface CCLayerPanZoomDebugLines: CCNode
{
    CGFloat _topFrameMargin;
    CGFloat _bottomFrameMargin;
    CGFloat _leftFrameMargin;
    CGFloat _rightFrameMargin;
}
/** Distance from top edge of contenSize */
@property (readwrite, assign) CGFloat topFrameMargin;
/** Distance from bottom edge of contenSize */
@property (readwrite, assign) CGFloat bottomFrameMargin;
/** Distance from left edge of contenSize */
@property (readwrite, assign) CGFloat leftFrameMargin;
/** Distance from right edge of contenSize */
@property (readwrite, assign) CGFloat rightFrameMargin;

@end

enum nodeTags
{
	kDebugLinesTag,
};

@implementation CCLayerPanZoomDebugLines

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
// Return C array with distances to edges of screen
- (CGFloat *) distancesToEdges;

- (void) autoscrollPosition;

@end


@implementation CCLayerPanZoom

@synthesize maxScale = _maxScale, minScale = _minScale, maxTouchDistanceToClick = _maxTouchDistanceToClick, 
            delegate = _delegate, touches = _touches, touchDistance = _touchDistance, 
            minSpeed = _minSpeed, maxSpeed = _maxSpeed, topFrameMargin = _topFrameMargin, 
            bottomFrameMargin = _bottomFrameMargin, leftFrameMargin = _leftFrameMargin,
            rightFrameMargin = _rightFrameMargin, scheduler = _scheduler, autoscrollSpeed = _autoscrollSpeed;

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
        self.mode = kCCLayerPanZoomModeSheet;
        self.minSpeed = 100.0f;
        self.maxSpeed = 1000.0f;
        self.topFrameMargin = 100.0f;
        self.bottomFrameMargin = 100.0f;
        self.leftFrameMargin = 100.0f;
        self.rightFrameMargin = 100.0f;
        self.autoscrollSpeed = 10.0f;
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
    
    if ([self.touches count] == 1)
    {
        _touchMoveBegan = NO;
        _singleTouchTimestamp = [NSDate timeIntervalSinceReferenceDate];
    }
    else
        _singleTouchTimestamp = INFINITY;
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
        // Get the single touch and it's previous & current position.
        UITouch *touch = [self.touches objectAtIndex: 0];
        CGPoint curPosition = [[CCDirector sharedDirector] convertToGL: [touch locationInView: [touch view]]];
        CGPoint prevPosition = [[CCDirector sharedDirector] convertToGL: [touch previousLocationInView: [touch view]]];
        
        // Always scroll in sheet mode.
        if (self.mode == kCCLayerPanZoomModeSheet)
        {
            // Calculate new anchor point.
            CGPoint newAnchorInPixels = [self convertToNodeSpace: prevPosition];
            self.anchorPoint = ccp(newAnchorInPixels.x / self.contentSize.width, newAnchorInPixels.y / self.contentSize.height);
            // Set new position of the layer.
            self.position = curPosition;		
            [self fixLayerPosition];
        }
        
        // Accumulate touch distance for all modes.
        self.touchDistance += ccpDistance(curPosition, prevPosition);
        
        // Inform delegate about starting updating touch position, if click isn't possible.
        if (self.mode == kCCLayerPanZoomModeFrame)
        {
            if (self.touchDistance > self.maxTouchDistanceToClick && !_touchMoveBegan)
            {
                [self.delegate layerPanZoom: self touchMoveBeganAtPosition: [self convertToNodeSpace: prevPosition]];
                _touchMoveBegan = YES;
            }
        }
    }	
}

- (void) ccTouchesEnded: (NSSet *) touches 
			  withEvent: (UIEvent *) event
{
    _singleTouchTimestamp = INFINITY;
    
    // Process click event in single touch.
    if (  (self.touchDistance < self.maxTouchDistanceToClick) && (self.delegate) 
        && ([self.touches count] == 1))
    {
        UITouch *touch = [self.touches objectAtIndex: 0];        
        CGPoint curPos = [[CCDirector sharedDirector] convertToGL: [touch locationInView: [touch view]]];
        [self.delegate layerPanZoom: self
                     clickedAtPoint: [self convertToNodeSpace: curPos]
                           tapCount: [touch tapCount]];
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

// Updates position in frame mode.
- (void) update: (ccTime) dt
{
    // Only for frame mode with one touch.
	if ( self.mode == kCCLayerPanZoomModeFrame && [self.touches count] == 1 )
    {
        // Do not update position if click is still possible.
        if (self.touchDistance <= self.maxTouchDistanceToClick )
            return;
        
        // Do not update position if pinch is still possible.
        if ( [NSDate timeIntervalSinceReferenceDate] - _singleTouchTimestamp < kCCLayerPanZoomMultitouchGesturesDetectionDelay )
            return;
        
        // Otherwise - update touch position. Get current position of touch.
        UITouch *touch = [self.touches objectAtIndex: 0];
        CGPoint curPos = [[CCDirector sharedDirector] convertToGL: [touch locationInView: [touch view]]];
        
        // Scroll if finger in the scroll area near edge.
        if ([self frameEdgeWithPoint: curPos] != kCCLayerPanZoomFrameEdgeNone)
        {
            self.position = ccp(self.position.x + dt * [self horSpeedWithPosition: curPos], 
                                self.position.y + dt * [self vertSpeedWithPosition: curPos]);
            [self fixLayerPosition];
        }
        
        // Inform delegate if touch position in layer was changed due to finger or layer movement.
        CGPoint touchPositionInLayer = [self convertToNodeSpace: curPos];
        if (!CGPointEqualToPoint(_prevSingleTouchPositionInLayer, touchPositionInLayer))
        {
            _prevSingleTouchPositionInLayer = touchPositionInLayer;
            [self.delegate layerPanZoom: self 
                   touchPositionUpdated: touchPositionInLayer];
        }

    }
    if (![self.touches count] && self.autoscrollSpeed)
    {
        [self autoscrollPosition];
    }
}

- (void) onEnter
{
    [super onEnter];
    [[CCScheduler sharedScheduler] scheduleUpdateForTarget: self 
                                                  priority: 0 
                                                    paused: NO];
}

- (void) onExit
{
    [[CCScheduler sharedScheduler] unscheduleAllSelectorsForTarget: self];
    [super onExit];
}

@dynamic mode;

- (void) setMode: (CCLayerPanZoomMode) mode
{
#ifdef DEBUG
    if (mode == kCCLayerPanZoomModeFrame)
    {
        CCLayerPanZoomDebugLines *lines = [CCLayerPanZoomDebugLines node];
        [lines setContentSize: [CCDirector sharedDirector].winSize];
        lines.topFrameMargin = self.topFrameMargin;
        lines.bottomFrameMargin = self.bottomFrameMargin;
        lines.leftFrameMargin = self.leftFrameMargin;
        lines.rightFrameMargin = self.rightFrameMargin;
        [[CCDirector sharedDirector].runningScene addChild: lines 
                                                         z: NSIntegerMax 
                                                       tag: kDebugLinesTag];
    }
    if (_mode == kCCLayerPanZoomModeFrame)
    {
        [[CCDirector sharedDirector].runningScene removeChildByTag: kDebugLinesTag 
                                                           cleanup: YES];
    }
#endif
    _mode = mode;
}

- (CCLayerPanZoomMode) mode
{
    return _mode;
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
    if (!CGRectIsNull(_panBoundsRect))
    {
        if ( !(self.autoscrollSpeed && self.mode == kCCLayerPanZoomModeSheet) )
        {
            CGRect boundBox = [self boundingBox];
            if (self.position.x - boundBox.size.width * self.anchorPoint.x > _panBoundsRect.origin.x)
            {
                [self setPosition: ccp(boundBox.size.width * self.anchorPoint.x + _panBoundsRect.origin.x, 
                                       self.position.y)];
            }	
            if (self.position.y - boundBox.size.height * self.anchorPoint.y > _panBoundsRect.origin.y)
            {
                [self setPosition: ccp(self.position.x, boundBox.size.height * self.anchorPoint.y + 
                                       _panBoundsRect.origin.y)];
            }
            if (self.position.x + boundBox.size.width * (1 - self.anchorPoint.x) < _panBoundsRect.size.width +
                _panBoundsRect.origin.x)
            {
                [self setPosition: ccp(_panBoundsRect.size.width + _panBoundsRect.origin.x - 
                                       boundBox.size.width * (1 - self.anchorPoint.x), self.position.y)];
            }
            if (self.position.y + boundBox.size.height * (1 - self.anchorPoint.y) < _panBoundsRect.size.height + 
                _panBoundsRect.origin.y)
            {
                [self setPosition: ccp(self.position.x, _panBoundsRect.size.height + _panBoundsRect.origin.y - 
                                       boundBox.size.height * (1 - self.anchorPoint.y))];
            }	
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

- (void) autoscrollPosition
{
    if (!CGRectIsNull(self.panBoundsRect))
	{
        CGFloat *distances = [self distancesToEdges];
        CGFloat dx = 0.0f;
        CGFloat dy = 0.0f;        
        int mask = (distances[0] ? 1 : 0) | (distances[1] ? 2 : 0) | (distances[2] ? 4 : 0) | (distances[3] ? 8 : 0);
        switch (mask)
        {
            case 0: // none
                return;
                
            case 1:  // only top 
            case 4:  // only bottom
            {
                dy = (mask == 1) ? self.autoscrollSpeed : - self.autoscrollSpeed;
            }
                break;
            case 2:  // only left
            case 8:  // only right
            {
                dx = (mask == 2) ? - self.autoscrollSpeed : self.autoscrollSpeed;
            }
                break;
                
            case 3: // top and left 
            {
                CGFloat distanceTopLeft = ccpLength(ccp(distances[1], distances[0]));
                double angle = acos(distances[1] / distanceTopLeft);
                dx = - self.autoscrollSpeed * cos(angle);
                dy = self.autoscrollSpeed * sin(angle);
            }
                break;
            case 9: // top and right 
            {
                CGFloat distanceTopRight = ccpLength(ccp(distances[3], distances[0]));
                double angle = acos(distances[3] / distanceTopRight);
                dx = self.autoscrollSpeed * cos(angle);
                dy = self.autoscrollSpeed * sin(angle);
            }
                break;
            case 6: // bottom and left 
            {
                CGFloat distanceBottomLeft = ccpLength(ccp(distances[1], distances[2]));
                double angle = acos(distances[1] / distanceBottomLeft);
                dx = - self.autoscrollSpeed * cos(angle);
                dy = - self.autoscrollSpeed * sin(angle);
            }
                break;
            case 12: // bottom and right 
            {
                CGFloat distanceBottomRight = ccpLength(ccp(distances[3], distances[2]));
                double angle = acos(distances[3] / distanceBottomRight);
                dx = self.autoscrollSpeed * cos(angle);
                dy = - self.autoscrollSpeed * sin(angle);
            }
                break;
        }
        
        self.position = ccp(self.position.x + dx, self.position.y + dy);
        free(distances);          
        
       
        CGRect boundBox = [self boundingBox];
        distances = [self distancesToEdges];
        
        // top distance
        if (distances[0] && distances[0] <= self.autoscrollSpeed)
        {
            [self setPosition: ccp(self.position.x, _panBoundsRect.size.height + _panBoundsRect.origin.y - 
                                   boundBox.size.height * (1 - self.anchorPoint.y))];
        }	
        // left distance
        if (distances[1] && distances[1] <= self.autoscrollSpeed)
        {
            [self setPosition: ccp(boundBox.size.width * self.anchorPoint.x + _panBoundsRect.origin.x, 
                                   self.position.y)];
        }	            
        // bottom distance
        if (distances[2] && distances[2] <= self.autoscrollSpeed)
        {
            [self setPosition: ccp(self.position.x, boundBox.size.height * self.anchorPoint.y + 
                                   _panBoundsRect.origin.y)];
        }
        // right distance
        if (distances[3] && distances[3] <= self.autoscrollSpeed)
        {
            [self setPosition: ccp(_panBoundsRect.size.width + _panBoundsRect.origin.x - 
                                   boundBox.size.width * (1 - self.anchorPoint.x), self.position.y)];
        }
        free(distances);
	}
}

#pragma mark Helpers

- (CGFloat *) distancesToEdges
{
    CGFloat *distances = malloc(sizeof(CGFloat) * 4);
    CGRect boundBox = [self boundingBox];
    // top edge
    distances[0] = MAX(self.panBoundsRect.size.height + self.panBoundsRect.origin.y - self.position.y - 
                       boundBox.size.height * (1 - self.anchorPoint.y), 0);        
    // left edge
    distances[1] = MAX(self.position.x - boundBox.size.width * self.anchorPoint.x - self.panBoundsRect.origin.x, 0);
    // bottom edge
    distances[2] = MAX(self.position.y - boundBox.size.height * self.anchorPoint.y - self.panBoundsRect.origin.y, 0);
    // right edge
    distances[3] = MAX(self.panBoundsRect.size.width + self.panBoundsRect.origin.x - self.position.x - 
                       boundBox.size.width * (1 - self.anchorPoint.x), 0);

    return distances;
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
    //CCLOG(@"horizontal speed = %f", speed);
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
    //CCLOG(@"vertical speed = %f", speed);
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
