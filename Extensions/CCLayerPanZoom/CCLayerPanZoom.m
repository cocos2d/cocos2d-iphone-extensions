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

/*
@interface CCPanZoomController (Private)

- (CGPoint) boundPos: (CGPoint) pos;

@end
*/

@implementation CCLayerPanZoom

@synthesize maxScale = _maxScale;
@synthesize minScale = _minScale;

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
	}	
	return self;
}

#pragma mark CCStandardTouchDelegate Touch events

- (void) ccTouchesBegan: (NSSet *) touches 
			  withEvent: (UIEvent *) event
{	
	for (UITouch *touch in [touches allObjects]) 
	{
		[_touches addObject: touch];
		
	}
}

- (void) ccTouchesMoved: (NSSet *) touches 
			  withEvent: (UIEvent *) event
{
	BOOL multitouch = [_touches count] > 1;
	if (multitouch)
	{
        UITouch *touch1 = [_touches objectAtIndex: 0];
		UITouch *touch2 = [_touches objectAtIndex: 1];
		
		CGPoint curPoint1 = [[CCDirector sharedDirector] convertToGL: [touch1 locationInView: [touch1 view]]];
		CGPoint curPoint2 = [[CCDirector sharedDirector] convertToGL: [touch2 locationInView: [touch2 view]]];
		CGPoint lastPoint1 = [[CCDirector sharedDirector] convertToGL: [touch1 previousLocationInView: [touch1 view]]];
		CGPoint lastPoint2 = [[CCDirector sharedDirector] convertToGL: [touch2 previousLocationInView: [touch2 view]]];
		CGFloat newScale = self.scale * (ccpDistance(curPoint1, curPoint2) / ccpDistance(lastPoint1, lastPoint2));
		
		
		CGPoint curPosition = ccpMidpoint(curPoint1, curPoint2);
		CGPoint lastPosition = ccpMidpoint(lastPoint1, lastPoint2); 
		if (ccpFuzzyEqual(curPosition, lastPosition, 2))
		{
			lastPosition = curPosition;
		}
		CGPoint newAnchorInPixels = [self convertToNodeSpace: lastPosition];
		CGPoint newAnchor = ccp(newAnchorInPixels.x / self.contentSize.width, newAnchorInPixels.y / self.contentSize.height);
		
		self.anchorPoint = newAnchor;
		self.position = curPosition;		
		self.scale = MIN(MAX(newScale, _minScale), _maxScale);		
	}
	else
	{		
        UITouch *touch = [_touches objectAtIndex: 0];        
		CGPoint curPoint = [[CCDirector sharedDirector] convertToGL: [touch locationInView: [touch view]]];
		CGPoint lastPoint = [[CCDirector sharedDirector] convertToGL: [touch previousLocationInView: [touch view]]];

		CGPoint newAnchorInPixels = [self convertToNodeSpace: lastPoint];
		CGPoint newAnchor = ccp(newAnchorInPixels.x / self.contentSize.width, newAnchorInPixels.y / self.contentSize.height);
		
		self.anchorPoint = newAnchor;
		self.position = curPoint;		
	}
	
	/*
	CGSize winSixe = [[CCDirector sharedDirector] winSize];
	if (self.position.x > 0 || self.postion.y > 0 || 
		(self.position.x + self.contentSize.width) < winSize.width || 
		ccp
	*/
}

- (void) ccTouchesEnded: (NSSet *) touches 
			  withEvent: (UIEvent *) event
{
	for (UITouch *touch in [touches allObjects]) 
	{
		[_touches removeObject: touch];
		
	}
}

- (void) ccTouchesCancelled: (NSSet *) touches 
				  withEvent: (UIEvent *) event
{
	for (UITouch *touch in [touches allObjects]) 
	{
		[_touches removeObject: touch];
		
	}
}

- (void) dealloc
{
	[_touches release];

	[super dealloc];
}

@end
