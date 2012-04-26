/*
 * CCBigImage Tests
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


// Import the interfaces
#import "HKTMXTiledMap.h"
#import "HKTMXTiledMapTestLayer.h"
#import "ExtensionTest.h"

SYNTHESIZE_EXTENSION_TEST(HKTMXTiledMapTestLayer)

// HelloWorldLayer implementation
@implementation HKTMXTiledMapTestLayer

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init])) {
		
		// prepare scroll stuff
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
		self.isTouchEnabled = YES;
        // setting this, and running on an iPhone 4 causes a crash / assert
        //[[CCDirector sharedDirector] enableRetinaDisplay:YES];
#elif __MAC_OS_X_VERSION_MIN_REQUIRED
		self.isMouseEnabled = YES;
        [[CCDirector sharedDirector] setResizeMode:kCCDirectorResize_AutoScale];
#endif
		[[CCDirector sharedDirector] setProjection:kCCDirectorProjection2D];
        HKTMXTiledMap* node = [HKTMXTiledMap tiledMapWithTMXFile:@"testmap.tmx"];
        
		// Add node as child
		node.position = ccp(0,0);
		[self addChild: node];
	}
	return self;
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	
	// don't forget to call "super dealloc"
	[super dealloc];
}

- (void) updateForScreenReshape
{
}


#pragma mark Scrolling

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
-(void) registerWithTouchDispatcher
{
	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:kCCMenuTouchPriority swallowsTouches:YES];
}

-(BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{	
	return YES;
}

-(void) ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{	
	CGRect boundaryRect = CGRectMake(0, 0, 
									 [[CCDirector sharedDirector] winSize].width, 
									 [[CCDirector sharedDirector] winSize].height );
	
	// scrolling is allowed only with non-zero boundaryRect
	if (!CGRectIsNull(boundaryRect))
	{	
		// get touch move delta 
		CGPoint point = [touch locationInView: [touch view]];
		CGPoint prevPoint = [ touch previousLocationInView: [touch view] ];	
		point =  [ [CCDirector sharedDirector] convertToGL: point ];
		prevPoint =  [ [CCDirector sharedDirector] convertToGL: prevPoint ];
		CGPoint delta = ccpSub(point, prevPoint);
		
		CGPoint newPosition = ccpAdd(self.position, delta );	
		self.position = newPosition;
		
		// stay in externalBorders
	}
}

#elif __MAC_OS_X_VERSION_MIN_REQUIRED
-(BOOL) ccMouseDragged:(NSEvent*)event
{
	CGPoint delta = ccp( [event deltaX], - [event deltaY] );
	
	// fix scrolling speed if we are scaled
	delta = ccp(delta.x / self.scaleX, delta.y / self.scaleY);
	
	// add delta
	CGPoint newPosition = ccpAdd(self.position, delta );	
	self.position = newPosition;

	return NO;
}

- (BOOL)ccScrollWheel:(NSEvent *)theEvent
{
	CGPoint delta = ccp( [theEvent deltaX], - [theEvent deltaY] );
	
	// add delta
	CGPoint newPosition = ccpAdd(self.position, delta );	
	self.position = newPosition;
	
	// stay in externalBorders
	//[self fixPosition];
	
	return NO;
}

#endif

@end
