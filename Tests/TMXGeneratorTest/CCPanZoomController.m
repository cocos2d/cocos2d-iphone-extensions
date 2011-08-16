/* Copyright (c) 2011 Robert Blackwood
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
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

#import "CCPanZoomController.h"

@interface CCPanZoomController (Private)
- (void) updateTime:(ccTime)dt;
- (CGPoint) boundPos:(CGPoint)pos;
- (void) recordScrollPoint:(CGPoint)pt;
- (CGPoint) getHistoricSpeed;
- (void) centerOnPoint:(CGPoint)pt damping:(float)damping;

- (void) beginScroll:(CGPoint)pos;
- (void) moveScroll:(CGPoint)pos;
- (void) endScroll:(CGPoint)pos;

- (void) beginZoom:(CGPoint)pt otherPt:(CGPoint)pt2;
- (void) moveZoom:(CGPoint)pt otherPt:(CGPoint)pt2;
- (void) endZoom:(CGPoint)pt otherPt:(CGPoint)pt2;
@end

@implementation CCPanZoomController

@synthesize centerOnPinch = _centerOnPinch;
@synthesize zoomRate = _zoomRate;
@synthesize zoomInLimit = _zoomInLimit;
@synthesize zoomOutLimit = _zoomOutLimit;
@synthesize swipeVelocityMultiplier = _swipeVelocityMultiplier;
@synthesize scrollDuration = _scrollDuration;
@synthesize scrollDamping = _scrollDamping;
@synthesize pinchDamping = _pinchDamping;

+ (id) controllerWithNode:(CCNode*)node
{
	return [[[self alloc] initWithNode:node] autorelease];
}

- (id) initWithNode:(CCNode*)node;
{
	self = [super init];
	
	_touches = [[NSMutableArray alloc] init];
	
	_node = node;
    _tr = ccp(0, 0);
    _bl = ccp(node.contentSize.width, node.contentSize.height);
    
    CGSize winSize = [[CCDirector sharedDirector] winSize];
	_winTr.x = winSize.width;
	_winTr.y = winSize.height;
    _winBl.x = 0;
    _winBl.y = 0;
    
    _centerOnPinch = YES;
    _zoomRate = 1/500.0f;
    _zoomInLimit = 1.0f;
    _zoomOutLimit = 0.5f;
    _swipeVelocityMultiplier = 0.3;
    _scrollDuration = .4;
    _scrollDamping = .4;
    _pinchDamping = .9;
	
	return self;
}

- (void) dealloc
{
	[_touches release];
	[super dealloc];
}

- (void) setBoundingRect:(CGRect)rect
{	
    _bl = rect.origin;
	_tr = ccpAdd(_bl, ccp(rect.size.width, rect.size.height));
}

-(CGRect) boundingRect
{
    CGPoint size = ccpSub(_tr, _bl);
    return CGRectMake(_bl.x, _bl.y, size.x, size.y);
}

- (void) setWindowRect:(CGRect)rect
{	
    _winBl = rect.origin;
	_winTr = ccpAdd(_winBl, ccp(rect.size.width, rect.size.height));
}

-(CGRect) windowRect
{
    CGPoint size = ccpSub(_winTr, _winBl);
    return CGRectMake(_winBl.x, _winBl.y, size.x, size.y);
}

- (CGPoint) boundPos:(CGPoint)pos
{
	float scale = _node.scale;
	
    //Correct for anchor
    CGPoint anchor = ccp(_node.contentSize.width*_node.anchorPoint.x,
                         _node.contentSize.height*_node.anchorPoint.y);
    anchor = ccpMult(anchor, (1.0f - scale));
    
    //Calculate corners
    CGPoint topRight = ccpAdd(ccpSub(ccpMult(_tr, scale), _winTr), anchor);
    CGPoint bottomLeft = ccpSub(ccpAdd(ccpMult(_bl, scale), _winBl), anchor);
    
    //bound x
	if (pos.x > bottomLeft.x)
		pos.x = bottomLeft.x;
	else if (pos.x < -topRight.x)
		pos.x = -topRight.x;
	
    //bound y
	if (pos.y > bottomLeft.y)
		pos.y = bottomLeft.y;
	else if (pos.y < -topRight.y)
		pos.y = -topRight.y;
	
	return pos;
}

- (void) updatePosition:(CGPoint)pos
{	
    //user interface to boundPos basically
	pos = [self boundPos:pos];
	[_node setPosition:pos];
}

- (void) enableWithTouchPriority:(int)priority swallowsTouches:(BOOL)swallowsTouches
{
	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self
													 priority:priority 
											  swallowsTouches:swallowsTouches];
}

-(void) disable
{
	[[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
}

- (void) updateTime:(ccTime)dt
{
    //keep the time
	_time += dt;
}

-(BOOL) ccTouchBegan:(UITouch*)touch withEvent:(UIEvent *)event
{	
	[_touches addObject:touch];
	
	BOOL multitouch = [_touches count] > 1;
	
	if (multitouch)
	{
        //reset history so auto scroll doesn't happen
        _timePointStampCounter = 0;
        
		[self endScroll:_firstTouch];
        
        UITouch *touch1 = [_touches objectAtIndex:0];
		UITouch *touch2 = [_touches objectAtIndex:1];
        
		CGPoint pt = [touch1 locationInView:[touch view]];
		CGPoint pt2 = [touch2 locationInView:[touch view]];
		
		[self beginZoom:pt otherPt:pt2];		
	}
	else 
		[self beginScroll:[_node convertTouchToNodeSpace:touch]];
	
	return YES;
}

-(void) ccTouchMoved:(UITouch*)touch withEvent:(UIEvent *)event
{
	BOOL multitouch = [_touches count] > 1;
	if (multitouch)
	{
        UITouch *touch1 = [_touches objectAtIndex:0];
		UITouch *touch2 = [_touches objectAtIndex:1];
        
		CGPoint pt = [touch1 locationInView:[touch view]];
		CGPoint pt2 = [touch2 locationInView:[touch view]];
		
		[self moveZoom:pt otherPt:pt2];
	}
	else
	{		
		CGPoint pt = [_node convertTouchToNodeSpace:touch];
		[self moveScroll:pt];
	}
}

- (void)ccTouchEnded:(UITouch*)touch withEvent:(UIEvent *)event
{
	BOOL multitouch = [_touches count] > 1;
	if (multitouch)
	{
		UITouch *touch1 = [_touches objectAtIndex:0];
		UITouch *touch2 = [_touches objectAtIndex:1];
        
        // We only care about relative to each other pts
		CGPoint pt = [touch1 locationInView:[touch view]];
		CGPoint pt2 = [touch2 locationInView:[touch view]];
		
		[self endZoom:pt otherPt:pt2];
		
		//which touch remains?
		if (touch == touch2)
			[self beginScroll:[_node convertToNodeSpace:pt]];
		else
			[self beginScroll:[_node convertToNodeSpace:pt2]];
	}
	else
	{
		CGPoint pt = [_node convertTouchToNodeSpace:touch];
		[self endScroll:pt];
	}
	
	[_touches removeObject:touch];
}

- (void)ccTouchCancelled:(UITouch*)touch withEvent:(UIEvent *)event
{
	[self ccTouchEnded:touch withEvent:event];
}

- (void) recordScrollPoint:(CGPoint)pt
{
    CCPanZoomTimePointStamp *record = &_history[_timePointStampCounter++ % kCCPanZoomControllerHistoryCount];
    record->time = _time;
    record->pt = pt;
}

- (CGPoint) getHistoricSpeed
{
    float tTime = 0, lastTime = _time;
    CGPoint tPt = ccp(0,0);
	CGPoint lastPt;
    CGPoint speed = ccp(0,0);
    int count = 0;
	
    for (int i = 0; i < kCCPanZoomControllerHistoryCount && i < _timePointStampCounter; i++)
    {
        CCPanZoomTimePointStamp *record = &_history[(_timePointStampCounter-i-1) % kCCPanZoomControllerHistoryCount];
        
        //sentinel: did they stop moving more than .25 second ago?
        if (lastTime-record->time > .25)
            break;
        
        lastPt = record->pt;
        lastTime = record->time;
        
        tPt = ccpAdd(tPt, lastPt);
        tTime += lastTime;
        
        count++;
    }
    
    if (count)
    {
        tTime = tTime/count - lastTime;
        tPt = ccpSub(ccpMult(tPt, 1.0f/count), lastPt);
        
        speed = ccpMult(tPt, 1.0f/tTime);
    }
    
    return speed;
}

- (void) beginScroll:(CGPoint)pos
{
	_time = 0;
    _timePointStampCounter = 0;
	_firstTouch = pos;
    
    //record the point for determining velocity
    [self recordScrollPoint:pos];
	
    //keep track of time passed
	[[CCScheduler sharedScheduler] scheduleSelector:@selector(updateTime:) forTarget:self interval:0 paused:NO];
}

- (void) moveScroll:(CGPoint)pos
{
    //record the point for determining velocity
    [self recordScrollPoint:pos];
    
    //dampen value
	pos = ccpSub(pos, _firstTouch);
	pos = ccpMult(pos, _scrollDamping * _node.scale);
	
	[self updatePosition:ccpAdd(_node.position, pos)];
}

- (void) endScroll:(CGPoint)pos
{
    //unschedule our time keeper
	[[CCScheduler sharedScheduler] unscheduleSelector:@selector(updateTime:) forTarget:self];
	
    //Only perform a velocity scroll if we have a good amount of history
	if (_timePointStampCounter > 3)
	{
        //calculate velocity
        CGPoint velocity = ccpMult([self getHistoricSpeed], _swipeVelocityMultiplier * _node.scale);
		
        //Make sure we have a reasonable speed
		if (ccpLengthSQ(velocity) > 5*5)
		{
            //caculate  position of swipe action
			CGPoint newPos = ccpAdd(_node.position, velocity);
			newPos = [self boundPos:newPos];
			
            //create the action
			id moveTo = [CCMoveTo actionWithDuration:_scrollDuration position:newPos];
			id ease = [CCEaseOut actionWithAction:moveTo rate:4];
			
            //unconditional stop; cocos handles this properly
			[_node stopAction:_lastScrollAction];
			[_node runAction:ease];
            
            //release our last action since we retain it below
            [_lastScrollAction release];
            _lastScrollAction = [ease retain];
		}
	}
}

- (void) beginZoom:(CGPoint)pt otherPt:(CGPoint)pt2
{
    //initialize our zoom vars
	_firstLength = ccpDistance(pt, pt2);
	_oldScale = _node.scale;
    
    //get the mid point of pinch
    _firstTouch = [_node convertToNodeSpace:ccpMidpoint(pt, pt2)];
}

- (void) moveZoom:(CGPoint)pt otherPt:(CGPoint)pt2
{
    //what's the difference in length
	float length = ccpDistance(pt, pt2);	
	float diff = (length-_firstLength) * _pinchDamping;
	
	//calculate new scale
	float factor = diff * _zoomRate;
	float newScale = _oldScale + factor;
	
    //bound scale
	if (newScale > _zoomInLimit)
		newScale = _zoomInLimit;
	else if (newScale < _zoomOutLimit)
		newScale = _zoomOutLimit;
    
    //set the new scale
	_node.scale = newScale;
    
    //center on midpoint of pinch
    if (_centerOnPinch)
        [self centerOnPoint:_firstTouch damping:_scrollDamping];
    else
        [self updatePosition:_node.position];
}

- (void) centerOnPoint:(CGPoint)pt
{
    [self centerOnPoint:pt damping:1.0f];
}

- (void) centerOnPoint:(CGPoint)pt damping:(float)damping
{
    CGPoint mid = [_node convertToNodeSpace:ccpMidpoint(_winTr, _winBl)];
    CGPoint diff = ccpMult(ccpSub(mid, pt), damping);
    
    [self updatePosition:ccpAdd(_node.position, diff)];
}

- (void) endZoom:(CGPoint)pt otherPt:(CGPoint)pt2
{
	[self moveZoom:pt otherPt:pt2];
}

@end