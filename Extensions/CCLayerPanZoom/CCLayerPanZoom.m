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
/* Get minimum possible scale for the layer 
 considering panBoundsRect and enablePanBounds */
- (CGFloat) getMinPossibleScale;

@end


@implementation CCLayerPanZoom

@synthesize maxScale = _maxScale, minScale = _minScale, maxTouchDistanceToClick = _maxTouchDistanceToClick, 
            delegate = _delegate, mode = _mode, touches = _touches, touchDistance = _touchDistance, speed = _speed,
            topFrameMargin = _topFrameMargin, bottomFrameMargin = _bottomFrameMargin, leftFrameMargin = _leftFrameMargin,
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
        self.mode = kCCLayerPanZoomModeScrollScale;
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
		CGPoint curPosTch1 = [[CCDirector sharedDirector] convertToGL: [touch1 locationInView: [touch1 view]]];
		CGPoint curPosTch2 = [[CCDirector sharedDirector] convertToGL: [touch2 locationInView: [touch2 view]]];
		CGPoint prevPosTch1 = [[CCDirector sharedDirector] convertToGL: [touch1 previousLocationInView: [touch1 view]]];
		CGPoint prevPosTch2 = [[CCDirector sharedDirector] convertToGL: [touch2 previousLocationInView: [touch2 view]]];
		// Calculate current and previous positions of the layer relative the anchor point
		CGPoint curPosLayer = ccpMidpoint(curPosTch1, curPosTch2);
		CGPoint prevPosLayer = ccpMidpoint(prevPosTch1, prevPosTch2);
		// If current and previous positions of the layer were fuzzy equal then they are equal
		if (ccpFuzzyEqual(prevPosLayer, curPosLayer, 2))
		{
			prevPosLayer = curPosLayer;
		}
		// Calculate new scale
		CGFloat newScale = self.scale * (ccpDistance(curPosTch1, curPosTch2) / ccpDistance(prevPosTch1, prevPosTch2));		
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
		// Get the one touch
        UITouch *touch = [self.touches objectAtIndex: 0];        
		// Get current and previous positions of the touche
		CGPoint curPosTch = [[CCDirector sharedDirector] convertToGL: [touch locationInView: [touch view]]];
		CGPoint prevPosTch = [[CCDirector sharedDirector] convertToGL: [touch previousLocationInView: [touch view]]];
		// Calculate new anchor point
		CGPoint newAnchorInPixels = [self convertToNodeSpace: prevPosTch];
		self.anchorPoint = ccp(newAnchorInPixels.x / self.contentSize.width, newAnchorInPixels.y / self.contentSize.height);
		// Set new position of the layer
		self.position = curPosTch;		
		[self fixLayerPosition];
		// Accumulate touche distance
		self.touchDistance += ccpDistance(curPosTch, prevPosTch);
	}	
}

- (void) ccTouchesEnded: (NSSet *) touches 
			  withEvent: (UIEvent *) event
{
	// Obtain click event
	if ((self.touchDistance < self.maxTouchDistanceToClick) && (self.delegate))
	{
		UITouch *touch = [self.touches objectAtIndex: 0];        
		CGPoint curPos = [[CCDirector sharedDirector] convertToGL: [touch locationInView: [touch view]]];
		[self.delegate layerPanZoom: self 
				 clickedAtPoint: [self convertToNodeSpace: curPos]];
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
			self.scale = [self getMinPossibleScale];	
	}
}

- (CGFloat) getMinPossibleScale
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

#pragma mark Dealloc

- (void) dealloc
{
	self.touches = nil;
	self.delegate = nil;
	[super dealloc];
}

@end
