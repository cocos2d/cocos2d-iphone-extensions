/*
 * CCBigImage - Dynamic Tiled Node for holding Large Images
 *
 * cocos2d-extensions
 * https://github.com/cocos2d/cocos2d-iphone-extensions
 *
 * Copyright (c) 2010-2011 Stepan Generalov
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

#import <Foundation/Foundation.h>
#import "CCBigImage.h"
#import "CCTextureCache+CCBigImageExtensions.h"

/* Unloadable Sprite - holds one dynamic tile for CCBigImage
 *
 * Limitations: scale, rotation not supported
 */
@interface UnloadableSpriteNode : CCNode
{	
	// name of texture file for sprite 
	NSString *_imageName;
	
	// position and size of the tile
	CGRect _activeRect;
	
	// sprite used to render content if tile is loaded	
	CCSprite *_sprite;
}

@property(retain) CCSprite *sprite;
@property(copy) NSString *imageName;

+ (id) nodeWithImage: (NSString *) anImage forRect: (CGRect) aRect;
- (id) initWithImage: (NSString *) anImage forRect: (CGRect) aRect;

- (CGRect) boundingBox;

- (void) load;
- (void) unload;

@end

@implementation UnloadableSpriteNode

@synthesize sprite = _sprite;
@synthesize imageName = _imageName;

#pragma mark Init / Creation

+ (id) nodeWithImage: (NSString *) anImage forRect: (CGRect) aRect
{
	return [[[self alloc] initWithImage:anImage forRect: aRect] autorelease];
}

- (id) initWithImage: (NSString *) anImage forRect: (CGRect) aRect
{
	if ( (self = [super init]) )
	{
		self.imageName = anImage;
		
		_activeRect = aRect;
		
		self.anchorPoint = ccp(0,0);
		self.position = aRect.origin;
	}
	return self;
}

#pragma mark CocosNode


// small visit for only one sprite
-(void) visit
{
	// quick return if not visible
	if (!_visible)
		return;
	
	kmGLPushMatrix();
	
	[self transform];
	
	[self.sprite visit];

	kmGLPopMatrix();
}

- (CGRect) boundingBox
{
	return _activeRect;
}

- (void) dealloc
{
	self.sprite = nil;	
	self.imageName = nil;
	
	[super dealloc];
}

#pragma mark Load/Unload 

- (void) loadedTexture: (CCTexture2D *) aTex
{
	
	[aTex setAntiAliasTexParameters];
	//[aTex setMipMapTexParameters];
	
	
	//create sprite, position it and at to self
	self.sprite = [[ [CCSprite alloc] initWithTexture: aTex] autorelease];
	self.sprite.anchorPoint = ccp(0,0);
	self.sprite.position = ccp(0,0);
	
	// fill our activeRect fully with sprite (stretch if needed)
	self.sprite.scaleX = _activeRect.size.width / [self.sprite contentSize].width;
	self.sprite.scaleY = _activeRect.size.height / [self.sprite contentSize].height;
}

- (void) unload
{
	self.sprite = nil;
}


- (void) load
{
	if (self.sprite)
		return; //< already loaded
	
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA4444];
	
	
	if ([NSThread currentThread] != [[CCDirector sharedDirector] runningThread] )
	{
		// _cmd called in other thread - load safely 
		[  [CCTextureCache sharedTextureCache] addImageFromAnotherThreadWithName: _imageName 
																		  target: self 
																		selector: @selector(loadedTexture:) ];		
	}
	else 
	{
		// _cmd called in cocos thread - load now
		[self loadedTexture: [[CCTextureCache sharedTextureCache] addImage: _imageName ] ];
	}
	
}

@end

#pragma mark -

@interface CCBigImage (Private)

- (void) startTilesLoadingThread;
- (void) stopTilesLoadingThread;

// preloads tiles and retains their textures
- (void) preloadAllTiles;

// unloads all tiles and releases their textures
- (void) unloadAllTiles;

- (void) prepareTilesWithFile: (NSString *) plistFile extension: (NSString *) extension z: (int) tilesZ;
- (void) updateLoadRect;
- (void) updateTiles;

@end

@implementation  CCBigImage
@synthesize tilesLoadThread = _tilesLoadThread;
@synthesize screenLoadRectExtension = _screenLoadRectExtension;
@dynamic dynamicMode;

- (BOOL) dynamicMode
{
	return _dynamicMode;
}

- (void) setDynamicMode:(BOOL) dynamicMode
{
	if (_isRunning)
	{
		// turning off dynamic mode
		if ( _dynamicMode && !dynamicMode) 
		{
			[self stopTilesLoadingThread];
			[self preloadAllTiles];
		}
		
		// turning on dynamic mode
		if ( !_dynamicMode && dynamicMode )
		{
			[self unloadAllTiles];
			[self startTilesLoadingThread];
		}
	}
	
	_dynamicMode = dynamicMode;
}

@dynamic position;
- (void) setPosition:(CGPoint) newPosition
{
	CGFloat significantPositionDelta = MIN(_screenLoadRectExtension.width, 
										   _screenLoadRectExtension.height) / 2.0f;
	
	if ( ccpLength(ccpSub(newPosition, [self position])) > significantPositionDelta )
		_significantPositionChange = YES;
	
	[super setPosition: newPosition];
}

#pragma mark Init / Creation

+ (id) nodeWithTilesFile: (NSString *) filename 
		  tilesExtension: (NSString *) extension 
				  tilesZ: (int) tilesZ
{
	return [[[self alloc] initWithTilesFile: filename
							 tilesExtension: extension
									 tilesZ: tilesZ ] autorelease];
}

// designated initializer
- (id) initWithTilesFile: (NSString *) filename 
		  tilesExtension: (NSString *) extension 
				  tilesZ: (int) tilesZ
{
	if ( (self = [super init]) )
	{		
		_loadedRect = CGRectZero;		
		_screenLoadRectExtension = CGSizeZero;
		
		// Under Mac OS X we have enough memory to load all tiles
#ifdef __MAC_OS_X_VERSION_MIN_REQUIRED
		self.dynamicMode = NO;
#elif __IPHONE_OS_VERSION_MAX_ALLOWED
		self.dynamicMode = YES;
#endif
		
		NSString *path = [[CCFileUtils sharedFileUtils] fullPathFromRelativePath: filename];
		[self prepareTilesWithFile: path extension: extension z: tilesZ ];
		
		if (!self.dynamicMode)
			[self preloadAllTiles];
	}
	
	return self;
}

// loads info about all tiles,sets self.contentSize & screenLoadRectExtension
// creates & adds tiles for dynamic usage if batchNode 
- (void) prepareTilesWithFile: (NSString *) plistFile 
					extension: (NSString *) extension 
							z: (int) tilesZ
{
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    
	// load plist with image & tiles info
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile: plistFile ];    
    if ( !dict )
    {
        CCLOGERROR( @"CCBigImage#prepareTilesWithFile:extension:z: can not load dictionary from file: %@ ", plistFile);
		[pool release];
        return;
    }
	
	// load image size
	NSString *size = [[dict objectForKey:@"Source"] objectForKey:@"Size" ];
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
	self.contentSize = CGSizeFromString(size);
#elif __MAC_OS_X_VERSION_MIN_REQUIRED
	self.contentSize = NSSizeToCGSize( NSSizeFromString(size) );
#endif
	
	// load tiles	
	NSArray *arr = [dict objectForKey:@"Tiles"];
	
	_dynamicChildren = [[NSMutableArray arrayWithCapacity: [arr count]] retain];
    
	// set screenLoadRectExtension = size of first tile
	if ([arr count])
	{
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
		_screenLoadRectExtension = CGRectFromString( [[arr objectAtIndex:0] valueForKey: @"Rect"] ).size;
#elif __MAC_OS_X_VERSION_MIN_REQUIRED	
		_screenLoadRectExtension = NSRectToCGRect( NSRectFromString([[arr objectAtIndex:0] valueForKey: @"Rect"]) ).size;
#endif
	}
	
	//read data and create nodes and add them
    for ( NSDictionary *tileDict in arr )
    {		
        // All properties of Dictionary
        NSString *spriteName = [ tileDict valueForKey: @"Name" ];
		
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
		CGRect tileRect = CGRectFromString( [tileDict valueForKey: @"Rect"] );
#elif __MAC_OS_X_VERSION_MIN_REQUIRED		
		CGRect tileRect = NSRectToCGRect( NSRectFromString( [tileDict valueForKey: @"Rect"] ) );
#endif
		
		// convert rect origin from top-left to bottom-left
		tileRect.origin.y = self.contentSize.height - tileRect.origin.y - tileRect.size.height; 
		
		// Use forced tile extension or original if tilesExtension isn't set
		if (extension)
		{
			// Change extension
			spriteName = [spriteName stringByDeletingPathExtension];
			spriteName = [spriteName stringByAppendingPathExtension: extension];
		}
		
		// if file doesn't exist - do not use it
		NSString *resourcesDirectoryPath = [ [NSBundle mainBundle] resourcePath ];  	
		NSString *filePath = [resourcesDirectoryPath stringByAppendingPathComponent: spriteName];
		if ( ! [[NSFileManager defaultManager] fileExistsAtPath: filePath] )
		{
			CCLOGINFO(@"CCBigImage#prepareTilesWithFile:extension:z: %@ doesn't exists - skipping tile.", filePath);
			continue;
		}
		
		// Create & Add Tile (Dynamic Sprite Mode)
		id tile = [UnloadableSpriteNode nodeWithImage: spriteName forRect: tileRect];
		[self addChild: tile z: tilesZ];	                                                               
		[_dynamicChildren addObject: tile ];	
		
    } //< for dict in arr
	
    [pool release];
} 

- (void) dealloc
{
	[_levelTextures release];
	_levelTextures = nil;
	
	[_dynamicChildren release];
	_dynamicChildren = nil;
	
	[[CCSpriteFrameCache sharedSpriteFrameCache] removeUnusedSpriteFrames];
	[[CCTextureCache sharedTextureCache] removeUnusedTextures];
	
	[super dealloc];
}


#pragma mark CCNode LifeCycle

- (void) onEnter
{
	[super onEnter];
	
	if (self.dynamicMode)
		[self startTilesLoadingThread];
}

- (void) onExit
{	
	// turn off dynamic thread
	[self stopTilesLoadingThread];
		
	[super onExit];
}

-(void) visit
{	
	[self updateLoadRect];
	
	// load tiles in cocos2d thread if dynamic mode is off
	if (!self.dynamicMode)
	{
		[self updateTiles];
	}
	
	[super visit];	
	
	// remove unused textures periodically
	if (self.dynamicMode)	
	{
		static int i = CCBIGIMAGE_TEXTURE_UNLOAD_PERIOD;
		if (--i <= 0)
		{
			i = CCBIGIMAGE_TEXTURE_UNLOAD_PERIOD;
			if (_tilesLoadThreadIsSleeping)
				[[CCTextureCache sharedTextureCache] removeUnusedTextures];
		}
	}
}

#if CC_BIGIMAGE_DEBUG_DRAW
- (void) draw
{
	[super draw];
	
	CGSize s = [self contentSize];
	CGPoint vertices[4]={
		ccp(0,0),ccp(s.width,0),
		ccp(s.width,s.height),ccp(0,s.height),
	};
	ccDrawPoly(vertices, 4, YES);
}
#endif


#pragma mark Dynamic Tiles Stuff

- (void) preloadAllTiles
{
	if (_levelTextures)
		return;
	
	_levelTextures = [[NSMutableArray arrayWithCapacity: [_dynamicChildren count]] retain];
	for (UnloadableSpriteNode *child in _dynamicChildren)
	{
		[child load];
		CCSprite *sprite = [child sprite];
		CCTexture2D *tex = sprite.texture;
		if (tex)
			[_levelTextures addObject: tex];
	}
}

- (void) unloadAllTiles
{
	for (UnloadableSpriteNode *child in _dynamicChildren)
	{
		[child unload];
	}
	
	[_levelTextures release];
	_levelTextures = nil;
	
	[[CCTextureCache sharedTextureCache] removeUnusedTextures];
}

- (void) startTilesLoadingThread
{
	// do nothing if thread exist
	if (self.tilesLoadThread)
		return;
	
	// create new thread if it doesn't exist
	self.tilesLoadThread = [[[NSThread alloc] initWithTarget: self
												   selector: @selector(updateTiles:)
													 object: nil] autorelease];

	_tilesLoadThreadIsSleeping = NO;
	[self.tilesLoadThread start];
}

- (void) stopTilesLoadingThread
{
	[self.tilesLoadThread cancel];
	self.tilesLoadThread = nil;
}

- (void) updateLoadRect
{	
	// get screen rect
	CGRect screenRect = CGRectZero;;
	screenRect.size = [[CCDirector sharedDirector] winSize];
	
	screenRect.size.width *= CC_CONTENT_SCALE_FACTOR();
	screenRect.size.height *= CC_CONTENT_SCALE_FACTOR();
	screenRect = CGRectApplyAffineTransform(screenRect, [self worldToNodeTransform] );
	screenRect.origin = ccpMult(screenRect.origin, 1/CC_CONTENT_SCALE_FACTOR() );
	screenRect.size.width /= CC_CONTENT_SCALE_FACTOR();
	screenRect.size.height /= CC_CONTENT_SCALE_FACTOR();
	 
	// get level's must-be-loaded-part rect
	_loadedRect = CGRectMake(screenRect.origin.x - _screenLoadRectExtension.width,
							 screenRect.origin.y - _screenLoadRectExtension.height,
							 screenRect.size.width + 2.0f * _screenLoadRectExtension.width,
							 screenRect.size.height + 2.0f * _screenLoadRectExtension.height);
	
	// avoid tiles blinking
	if (_significantPositionChange)
	{
		[self updateTiles];
		_significantPositionChange = NO;
	}
}


// new update tiles for threaded use
- (void) updateTiles: (NSObject *) notUsed
{		
	while( ![[NSThread currentThread] isCancelled] ) 
	{
		NSAutoreleasePool *pool = [NSAutoreleasePool new];
		
		// flag for removeUnusedTextures only when sleeping - to disable deadLocks
		_tilesLoadThreadIsSleeping = NO;
		
		for (UnloadableSpriteNode *child in _dynamicChildren)
			if (  0 == ( CGRectIntersection([child boundingBox], _loadedRect).size.width )  )
				[child unload];
			else 
				[child load];
		//< 0 == size.width must be faster than CGRectIsEmpty
		
		// flag removeUnusedTextures only when sleeping - to disable deadLocks
		_tilesLoadThreadIsSleeping = YES; 
		
		// 60 FPS run, update at 30 fps should be ok
		[NSThread sleepForTimeInterval: 0.03  ];  
		
		[pool release];
	}
}

- (void) updateTiles
{	
	//load loadedRect tiles and unload tiles that are not in loadedRect
	for (UnloadableSpriteNode *child in _dynamicChildren)
		if (  0 == ( CGRectIntersection([child boundingBox], _loadedRect).size.width )  )
			[child unload];
		else 
			[child load];
	//< 0 == size.width must be faster than CGRectIsEmpty	
}

-(void) loadTilesInRect: (CGRect) loadRect
{
	for (UnloadableSpriteNode *child in _dynamicChildren)
		if (  0 != ( CGRectIntersection([child boundingBox], loadRect).size.width )  )
			[child load];
}

@end
