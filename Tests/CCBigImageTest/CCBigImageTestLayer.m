/*
 * CCBigImage Tests
 *
 * cocos2d-extensions
 * https://github.com/cocos2d/cocos2d-iphone-extensions
 *
 * Copyright (c) 2011-2012 Stepan Generalov
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
#import "CCBigImageTestLayer.h"
#import "CCBigImage.h"
#import "ExtensionTest.h"

SYNTHESIZE_EXTENSION_TEST(CCBigImageTestLayer)

// HelloWorldLayer implementation
@implementation CCBigImageTestLayer

enum nodeTags {
	kBigNode,
};

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init])) {
		
		// prepare scroll stuff
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
		self.isTouchEnabled = YES;
#elif __MAC_OS_X_VERSION_MIN_REQUIRED
		self.isMouseEnabled = YES;
#endif
		
		// Create DynamicTiledNode with screen bounds additional preload zone size
		CCBigImage *node = [ CCBigImage nodeWithTilesFile:@"bigImage.plist" tilesExtension: nil tilesZ: 0  ];
		
		// size of bigImage.png in points
		self.contentSize = node.contentSize;
		
		// Add node as child.
		node.scale = 0.2f;
		[self addChild: node z:0 tag: kBigNode];
		
#ifdef __MAC_OS_X_VERSION_MIN_REQUIRED
		// Run Infinite Rotate & Scale Actions for testing issue #19 on Mac.
		id action = [CCSpawn actions: 
					 [CCRotateBy actionWithDuration:6.0f angle: 360.0f],
					 [CCSequence actions:
						[CCScaleTo actionWithDuration:3.0f scale:0.05f],
						[CCScaleTo actionWithDuration:3.0f scale:0.2f],
					  nil],
					 nil];
		action = [CCRepeatForever actionWithAction: action];
		[node runAction: action];
#endif
		
		[self updateForScreenReshape];
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
	CGSize s = [[CCDirector sharedDirector] winSize];
	CCNode *node = [self getChildByTag:kBigNode];
	node.anchorPoint = ccp(0.5f, 0.5f);
	node.position = ccp(0.5f * s.width, 0.5f * s.height);
}


#pragma mark Scrolling

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED

-(void) registerWithTouchDispatcher
{
#if COCOS2D_VERSION >= 0x00020000
    CCTouchDispatcher *dispatcher = [[CCDirector sharedDirector] touchDispatcher];
#else
    CCTouchDispatcher *dispatcher = [CCTouchDispatcher sharedDispatcher];
#endif
    
	[dispatcher addTargetedDelegate:self priority:0 swallowsTouches:YES];
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
	
	return NO;
}

#endif

- (void) fixPosition
{	
	CGRect boundaryRect = CGRectMake(0, 0, 
			   [[CCDirector sharedDirector] winSize].width, 
			   [[CCDirector sharedDirector] winSize].height );
	
	if ( CGRectIsNull( boundaryRect) || CGRectIsInfinite(boundaryRect) )
		return;
	
#define CLAMP(x,y,z) MIN(MAX(x,y),z)
	
	// get right top corner coords
	CGRect rect = [self boundingBox];	
	CGPoint rightTopCorner = ccp(rect.origin.x + rect.size.width, 
								 rect.origin.y + rect.size.height);
	CGPoint originalRightTopCorner = rightTopCorner;
	CGSize s = rect.size;
	
	// reposition right top corner to stay in boundary
	CGFloat leftBoundary = boundaryRect.origin.x + boundaryRect.size.width;
	CGFloat rightBoundary = boundaryRect.origin.x + MAX(s.width, boundaryRect.size.width);
	CGFloat bottomBoundary = boundaryRect.origin.y + boundaryRect.size.height;
	CGFloat topBoundary = boundaryRect.origin.y + MAX(s.height,boundaryRect.size.height);
	
	rightTopCorner = ccp( CLAMP(rightTopCorner.x,leftBoundary,rightBoundary), 
						 CLAMP(rightTopCorner.y,bottomBoundary,topBoundary));
	
	// calculate and add position delta
	CGPoint delta = ccpSub(rightTopCorner, originalRightTopCorner);
	self.position = ccpAdd(self.position, delta);		
	
#undef CLAMP
	
}


@end
