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


@interface CCLayerPanZoom (Private)

/* Fix position for the layer considering _panBoundsRect and _enablePanBounds */
- (void) fixLayerPosition;

/* Fix position for the layer considering _panBoundsRect and _enablePanBounds */
- (void) fixLayerScale;

/* Get minimum possible scale for the layer 
 considering _panBoundsRect and _enablePanBounds */
- (CGFloat) GetMinPossibleScale;

@end


@implementation CCLayerPanZoom

@synthesize maxScale = _maxScale;
@synthesize minScale = _minScale;
@synthesize enablePanBounds = _enablePanBounds;
@synthesize panBoundsRect = _panBoundsRect;

#pragma mark Init

- (id) init
{
	if ((self = [super init])) 
	{
		self.isRelativeAnchorPoint = YES;
		isTouchEnabled_ = YES;
		
		_maxScale = 2.0f;
		_minScale = 0.1f;
		_touches = [[NSMutableArray arrayWithCapacity: 10] retain];
		_enablePanBounds = NO;
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
		[_touches addObject: touch];
	}
}

- (void) ccTouchesMoved: (NSSet *) touches 
			  withEvent: (UIEvent *) event
{
	BOOL multitouch = [_touches count] > 1;
	if (multitouch)
	{
		// Get the two first touches
        UITouch *touch1 = [_touches objectAtIndex: 0];
		UITouch *touch2 = [_touches objectAtIndex: 1];
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
		self.scale = MIN(MAX(newScale, _minScale), _maxScale);
		[self fixLayerScale];
		// Calculate new anchor point
		CGPoint newAnchorInPixels = [self convertToNodeSpace: prevPosLayer];
		self.anchorPoint = ccp(newAnchorInPixels.x / self.contentSize.width, newAnchorInPixels.y / self.contentSize.height);
		// Set new position of the layer
		self.position = curPosLayer;
		[self fixLayerPosition];
	}
	else
	{	
		// Get the one touch
        UITouch *touch = [_touches objectAtIndex: 0];        
		// Get current and previous positions of the touche
		CGPoint curPosTch = [[CCDirector sharedDirector] convertToGL: [touch locationInView: [touch view]]];
		CGPoint prevPosTch = [[CCDirector sharedDirector] convertToGL: [touch previousLocationInView: [touch view]]];
		// Calculate new anchor point
		CGPoint newAnchorInPixels = [self convertToNodeSpace: prevPosTch];
		self.anchorPoint = ccp(newAnchorInPixels.x / self.contentSize.width, newAnchorInPixels.y / self.contentSize.height);
		// Set new position of the layer
		self.position = curPosTch;		
		[self fixLayerPosition];
	}	
}

- (void) ccTouchesEnded: (NSSet *) touches 
			  withEvent: (UIEvent *) event
{
	for (UITouch *touch in [touches allObjects]) 
	{
		// Remove touche from the array with current touches
		[_touches removeObject: touch];
	}
}

- (void) ccTouchesCancelled: (NSSet *) touches 
				  withEvent: (UIEvent *) event
{
	for (UITouch *touch in [touches allObjects]) 
	{
		// Remove touche from the array with current touches
		[_touches removeObject: touch];
	}
}

#pragma mark Scale and Position related

- (void) setEnablePanBounds: (BOOL) enable
{
	_enablePanBounds = enable;
	[self fixLayerScale];
	[self fixLayerPosition];
}

- (void) setPanBoundsRect: (CGRect) rect
{
	_panBoundsRect = rect;
	[self fixLayerScale];
	[self fixLayerPosition];
}

- (void) fixLayerPosition
{
	if (_enablePanBounds)
	{
		// Check the pan bounds and fix (if it's need) position
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

- (void) fixLayerScale
{
	if (_enablePanBounds)
	{
		// Check the pan bounds and fix (if it's need) scale
		CGRect boundBox = [self boundingBox];
		if ((boundBox.size.width < _panBoundsRect.size.width) || (boundBox.size.height < _panBoundsRect.size.height))
			self.scale = [self GetMinPossibleScale];	
	}
}

- (CGFloat) GetMinPossibleScale
{
	if (_enablePanBounds)
	{
		return MAX(_panBoundsRect.size.width / self.contentSize.width,
				   _panBoundsRect.size.height / self.contentSize.height);
	}
	else 
	{
		return _minScale;
	}
}

#pragma mark Dealloc

- (void) dealloc
{
	[_touches release];
	[super dealloc];
}

@end
