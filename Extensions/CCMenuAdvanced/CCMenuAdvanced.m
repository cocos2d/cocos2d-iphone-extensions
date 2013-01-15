/*
 * CCMenuAdvanced
 *
 * cocos2d-extensions
 * https://github.com/cocos2d/cocos2d-iphone-extensions
 *
 * Copyright (c) 2011 Stepan Generalov
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

#import "CCMenuAdvanced.h"


@implementation NSString (UnicharExtensions)

+ (NSString *) stringWithUnichar: (unichar) anUnichar
{
	return [[[NSString alloc] initWithCharacters:&anUnichar length:1] autorelease];
}

- (unichar) unicharFromFirstCharacter: (NSString *) aString
{
	if ([aString length])
		return [aString characterAtIndex:0];
	return 0;
}

@end


@interface CCMenu (Private) 

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
-(CCMenuItem *) itemForTouch: (UITouch *) touch;
#elif __MAC_OS_X_VERSION_MAX_ALLOWED
-(CCMenuItem *) itemForMouseEvent: (NSEvent *) event;
#endif

@end




@implementation CCMenuAdvanced
@synthesize boundaryRect = boundaryRect_;
@synthesize minimumTouchLengthToSlide = minimumTouchLengthToSlide_;
@synthesize priority = priority_;
@synthesize isDisabled = isDisabled_;

#ifdef DEBUG
@synthesize debugDraw = debugDraw_;
#endif

#pragma mark Init/DeInit

-(id) initWithArray:(NSArray *)arrayOfItems
{
	if ( (self = [super initWithArray:arrayOfItems]) )
	{
		self.ignoreAnchorPointForPosition = NO;
		selectedItemNumber_ = -1;
		self.boundaryRect = CGRectNull;
		self.minimumTouchLengthToSlide = 30.0f;
#ifdef __MAC_OS_X_VERSION_MAX_ALLOWED
		[self setKeyboardEnabled:YES];
#endif
		
		[self alignItemsVertically];
	}
	return self;
}

- (void) dealloc
{
#ifdef __MAC_OS_X_VERSION_MAX_ALLOWED
	self.escapeDelegate = nil;
#endif
	[super dealloc];
}

#pragma mark Advanced Menu - Priority
-(NSInteger) mouseDelegatePriority
{
	return priority_;
}

-(NSInteger) keyboardDelegatePriority
{
	return priority_;
}

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
-(void) registerWithTouchDispatcher
{
	CCTouchDispatcher *dispatcher = [[CCDirector sharedDirector] touchDispatcher];
	[dispatcher addTargetedDelegate: self 
						   priority:[self mouseDelegatePriority] 
					swallowsTouches: YES ];
}
#endif

#pragma mark Advanced Menu - Draw

#ifdef DEBUG
- (void) draw
{
	[super draw];
	
	if (self.debugDraw)
	{
		CGSize s = [self contentSize];
		CGPoint vertices[4]={
			ccp(0,0),ccp(s.width,0),
			ccp(s.width,s.height),ccp(0,s.height),
		};
		ccDrawPoly(vertices, 4, YES);
	}
}
#endif

#pragma mark Advanced Menu - Selecting/Activating Items

- (void) selectNextMenuItem
{
	CCArray *children = [self children];
	if ([children count] < 2)
		return;
	
	selectedItemNumber_++;
	
	// borders
	if (selectedItemNumber_ >= (int)[children count])
		selectedItemNumber_ = 0;
	if (selectedItemNumber_ < 0)
		selectedItemNumber_ = [children count] - 1;
	
	// select selected
	int i = 0;
	for (CCMenuItem *item in children)
	{
		[item unselected];
		if ( i == selectedItemNumber_ )
			[item selected];
		++i;
	}
}

- (void) selectPrevMenuItem
{
	CCArray *children = [self children];

	if ([children count] < 2)
		return;
	
	selectedItemNumber_--;
	
	// borders
	if (selectedItemNumber_ >= (int)[children count])
		selectedItemNumber_ = 0;
	if (selectedItemNumber_ < 0)
		selectedItemNumber_ = [children count] - 1;
	
	// select selected
	int i = 0;
	for (CCMenuItem *item in children)
	{
		if ( i == selectedItemNumber_ )
			[item selected];
		else 
			[item unselected];
		
		++i;
	}
}

- (void) activateSelectedItem
{
	if (selectedItemNumber_ < 0)
		return;
	
	// Unselect selected menu item.
	CCMenuItem *item = [self.children objectAtIndex: selectedItemNumber_];
	[item unselected];
	selectedItemNumber_ = -1;
	
	[item activate];
	
}

- (void) cancelSelectedItem
{
	if( _selectedItem ) {
		[_selectedItem unselected];
		_selectedItem = nil;
	}
	
	selectedItemNumber_ = -1;

	_state = kCCMenuStateWaiting;
}

#pragma mark Advanced Menu - Alignment
// differences from std impl:
//		* 1 auto setContentSize 
//		* 2 each item.x = width / 2
//		* 3 item starts from top, not from center on y
//		* [MAC] binds keyboard keys for verticall taking care about direction
-(void) alignItemsVerticallyWithPadding:(float)padding bottomToTop: (BOOL) bottomToTop
{
	float height = -padding;
	float width = 0;
	
	// calculate and set contentSize,
	CCMenuItem *item = nil;
	CCARRAY_FOREACH(_children, item)
	{
        if (item)
        {
            height += item.contentSize.height * item.scaleY + padding;
            width = MAX(item.contentSize.width * item.scaleX, width);
        }
	}
	[self setContentSize: CGSizeMake(width, height)];
	
	// allign items
	float y = 0;
	if (! bottomToTop)
		y = height;
	
	CCARRAY_FOREACH(_children, item) 
    {
        if (item)
        {
            CGSize itemSize = item.contentSize;
            // need to start y higher, otherwise the first element will be hidden from view
            if (bottomToTop)
                y += itemSize.height * item.scaleY;
            [item setPosition:ccp(width / 2.0f, y - itemSize.height * item.scaleY / 2.0f)];
            
            if (bottomToTop)
                y += padding;
            else 
                y -= itemSize.height * item.scaleY + padding;
        }
	}
	
	// Fix position of menuItem if it's the only one.
	if ([_children count] == 1)
		[[_children objectAtIndex: 0] setPosition: ccp(width / 2.0f, height / 2.0f ) ];
	
#ifdef __MAC_OS_X_VERSION_MAX_ALLOWED
	if (bottomToTop)
	{
		self.nextItemButtonBind = NSUpArrowFunctionKey;
		self.prevItemButtonBind = NSDownArrowFunctionKey;
	}
	else 
	{
		self.nextItemButtonBind = NSDownArrowFunctionKey;
		self.prevItemButtonBind = NSUpArrowFunctionKey;
	}
#endif
}

// differences from std impl:
//		* 1 auto setContentSize 
//		* 2 each item.y = height / 2
//		* items start from zero - i dunno why
//		* supports both directions
//		* [MAC] binds keyboard keys for horizontal taking care about direction
-(void) alignItemsHorizontallyWithPadding:(float)padding leftToRight: (BOOL) leftToRight
{
	float width = -padding;
	float height = 0;
	
	// calculate and set content size
	CCMenuItem *item;
	CCARRAY_FOREACH(_children, item)
	{
        if (item)
        {
            width += item.contentSize.width * item.scaleX + padding;
            height = MAX(item.contentSize.height * item.scaleY, height);
        }
	}
	[self setContentSize: CGSizeMake(width, height)];
	
	float x = 0;
	if ( !leftToRight )
		x = width;
	
	// align items
	CCARRAY_FOREACH(_children, item)
	{
        if (item)
        {
            CGSize itemSize = item.contentSize;
            
            CGPoint curPos = ccp(x + itemSize.width * item.scaleX / 2.0f, height / 2.0f);
            if (!leftToRight) {
                curPos.x = x - itemSize.width * item.scaleX / 2.0f;
            }
            
            [item setPosition:curPos];
            
            if (leftToRight)
                x += itemSize.width * item.scaleX + padding;
            else
                x -= itemSize.width * item.scaleX + padding;
        }
	}
	
#ifdef __MAC_OS_X_VERSION_MAX_ALLOWED
	if (leftToRight)
	{
		self.nextItemButtonBind = NSRightArrowFunctionKey;
		self.prevItemButtonBind = NSLeftArrowFunctionKey;
	}
	else 
	{
		self.nextItemButtonBind = NSLeftArrowFunctionKey;
		self.prevItemButtonBind = NSRightArrowFunctionKey;
	}
#endif
}

-(void) alignItemsHorizontallyWithPadding:(float)padding
{
	[self alignItemsHorizontallyWithPadding: padding leftToRight: YES];
}

-(void) alignItemsVerticallyWithPadding:(float)padding
{
	[self alignItemsVerticallyWithPadding: padding bottomToTop: YES];
}

#pragma mark Advanced Menu - Mouse Controls

#if defined(__MAC_OS_X_VERSION_MAX_ALLOWED)

-(BOOL) ccMouseUp:(NSEvent *)event
{
    if (self.isDisabled)
        return NO;
    
    return [super ccMouseUp: event];
}

-(BOOL) ccMouseDragged:(NSEvent *)event
{
	if (self.isDisabled)
		return NO;
	
	return [super ccMouseDragged: event];
}
 
-(BOOL) ccMouseDown:(NSEvent *)event
{
	if( ! _visible || self.isDisabled)
		return NO;
	
	_selectedItem = [self itemForMouseEvent:event];
	
	// Unselect previous selected by keyboard item.
	if (_children.count > selectedItemNumber_ && selectedItemNumber_ >= 0)
	{
		CCMenuItem *item = [_children objectAtIndex: selectedItemNumber_];
		
		if (_selectedItem != item)
		{
			[item unselected];
			selectedItemNumber_ = -1;
		}
	}
	
	[_selectedItem selected];
	
	if( _selectedItem ) {
		_state = kCCMenuStateTrackingTouch;
		return YES;
	}
	
	return NO;	
}

#endif //< Advanced Menu - Mouse Controls

#pragma mark Advanced Menu - Keyboard Controls

#ifdef __MAC_OS_X_VERSION_MAX_ALLOWED
- (BOOL) ccKeyDown:(NSEvent *)event
{
	unichar enterKeyBinding = 13;
	unichar escapeKeyBinding = 0x1b;
	unichar upKeyBinding = [self prevItemButtonBind];
	unichar downKeyBinding = [self nextItemButtonBind];
	
	if (! self.visible || self.isDisabled)
		return NO;
	
	NSString *keyCharacters = [event charactersIgnoringModifiers];
	
	// ESCAPE
	if ( [keyCharacters rangeOfString:[NSString stringWithUnichar: escapeKeyBinding]].location != NSNotFound)
	{
		// do not process holding esc key
		if ([event isARepeat])
			return NO;
		
		if (self.escapeDelegate)
		{
			[self.escapeDelegate unselected];
			[self.escapeDelegate activate];
			
			return YES;
		}
		else 
			return NO;
	}
	
	// NEXT
	if ( [keyCharacters rangeOfString:[NSString stringWithUnichar: downKeyBinding]].location != NSNotFound )
	{
		if ([_children count] < 2)
			return NO;
		
		[self selectNextMenuItem];
		return YES;
	}
	
	// PREV
	if ( [keyCharacters rangeOfString:[NSString stringWithUnichar: upKeyBinding]].location != NSNotFound)
	{
		if ([_children count] < 2)
			return NO;
		
		[self selectPrevMenuItem];
		return YES;
	}
	
	// ENTER
	if ( [keyCharacters rangeOfString:[NSString stringWithUnichar: enterKeyBinding]].location != NSNotFound)
	{
		if (selectedItemNumber_ < 0)
			return NO;
		
		[self activateSelectedItem];
		return YES;
	}	
	
	return NO;
}

@synthesize escapeDelegate = escapeDelegate_;
@synthesize prevItemButtonBind = prevItemButtonBind_;
@synthesize nextItemButtonBind = nextItemButtonBind_;

#endif

#pragma mark Advanced Menu - Scrolling

- (void) fixPosition
{	
	if ( CGRectIsNull( boundaryRect_) || CGRectIsInfinite(boundaryRect_) )
		return;
	
#define CLAMP(x,y,z) MIN(MAX(x,y),z)
	
	// get right top corner coords
	CGRect rect = [self boundingBox];	
	CGPoint rightTopCorner = ccp(rect.origin.x + rect.size.width, 
								 rect.origin.y + rect.size.height);
	CGPoint originalRightTopCorner = rightTopCorner;
	CGSize s = rect.size;
	
	// reposition right top corner to stay in boundary
	CGFloat leftBoundary = boundaryRect_.origin.x + boundaryRect_.size.width;
	CGFloat rightBoundary = boundaryRect_.origin.x + MAX(s.width, boundaryRect_.size.width);
	CGFloat bottomBoundary = boundaryRect_.origin.y + boundaryRect_.size.height;
	CGFloat topBoundary = boundaryRect_.origin.y + MAX(s.height,boundaryRect_.size.height);

	rightTopCorner = ccp( CLAMP(rightTopCorner.x,leftBoundary,rightBoundary), 
						 CLAMP(rightTopCorner.y,bottomBoundary,topBoundary));
	
	// calculate and add position delta
	CGPoint delta = ccpSub(rightTopCorner, originalRightTopCorner);
	self.position = ccpAdd(self.position, delta);		
	
#undef CLAMP
	
}


#if __IPHONE_OS_VERSION_MAX_ALLOWED

// returns YES if touch is inside our boundingBox
-(BOOL) isTouchForMe:(UITouch *) touch
{
	CGPoint point = [self convertToNodeSpace:[[CCDirector sharedDirector] convertToGL:[touch locationInView: [touch view]]]];
	CGPoint prevPoint = [self convertToNodeSpace:[[CCDirector sharedDirector] convertToGL:[touch previousLocationInView: [touch view]]]];
	
	CGRect rect = CGRectMake(0, 0, self.contentSize.width, self.contentSize.height);
	
    if ( CGRectContainsPoint(rect, point) || CGRectContainsPoint(rect, prevPoint) )
		return YES;
	
	return NO;
}

-(BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{	
	if( _state != kCCMenuStateWaiting || !_visible || self.isDisabled )
		return NO;
	
	curTouchLength_ = 0; //< every new touch should reset previous touch length
	
	_selectedItem = [self itemForTouch:touch];
	[_selectedItem selected];
	
	if( _selectedItem ) {
		_state = kCCMenuStateTrackingTouch;
		return YES;
	}
	
	// start slide even if touch began outside of menuitems, but inside menu rect
	if ( !CGRectIsNull(boundaryRect_) && [self isTouchForMe: touch] ){
		_state = kCCMenuStateTrackingTouch;
		return YES;
	}
	
	return NO;
}

-(void) ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
	NSAssert(_state == kCCMenuStateTrackingTouch, @"[Menu ccTouchEnded] -- invalid state");
	
	[_selectedItem unselected];
	[_selectedItem activate];
	
	_state = kCCMenuStateWaiting;
}

-(void) ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event
{
	NSAssert(_state == kCCMenuStateTrackingTouch, @"[Menu ccTouchCancelled] -- invalid state");
	
	[_selectedItem unselected];
	
	_state = kCCMenuStateWaiting;
}

-(void) ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
	NSAssert(_state == kCCMenuStateTrackingTouch, @"[Menu ccTouchMoved] -- invalid state");
	
	CCMenuItem *currentItem = [self itemForTouch:touch];
	
	if (currentItem != _selectedItem) {
		[_selectedItem unselected];
		_selectedItem = currentItem;
		[_selectedItem selected];
	}
	
	// scrolling is allowed only with non-zero boundaryRect
	if (!CGRectIsNull(boundaryRect_))
	{	
		// get touch move delta 
		CGPoint point = [touch locationInView: [touch view]];
		CGPoint prevPoint = [ touch previousLocationInView: [touch view] ];	
		point =  [ [CCDirector sharedDirector] convertToGL: point ];
		prevPoint =  [ [CCDirector sharedDirector] convertToGL: prevPoint ];
		CGPoint delta = ccpSub(point, prevPoint);
		
		curTouchLength_ += ccpLength( delta ); 
		
		if (curTouchLength_ >= self.minimumTouchLengthToSlide)
		{
			[_selectedItem unselected];
			_selectedItem = nil;
			
			// add delta
			CGPoint newPosition = ccpAdd(self.position, delta );	
			self.position = newPosition;
			
			// stay in externalBorders
			[self fixPosition];
		}
	}
}


#elif __MAC_OS_X_VERSION_MAX_ALLOWED

- (BOOL)ccScrollWheel:(NSEvent *)theEvent
{
	// scrolling is allowed only with non-zero boundaryRect
	if (!CGRectIsNull(boundaryRect_))
	{	
		CGPoint delta = ccp( [theEvent deltaX], - [theEvent deltaY] );
		
		// fix scrolling speed if we are scaled
		delta = ccp(delta.x / self.scaleX, delta.y / self.scaleY);
		
		// add delta
		CGPoint newPosition = ccpAdd(self.position, delta );	
		self.position = newPosition;
		
		// stay in externalBorders
		[self fixPosition];
	}
	
	return NO;
}

#endif

@end

