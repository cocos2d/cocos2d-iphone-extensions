/*
 * TMXGenerator_WorldMap.m
 *
 * Created by Jeremy Stone on 8/6/11.
 * Copyright (c) 2011 Stone Software. 
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

#import "TMXGeneratorTestLayer.h"
#import "SimpleAudioEngine.h"
#import "ExtensionTest.h"

SYNTHESIZE_EXTENSION_TEST(TMXGeneratorTestLayer)


#pragma mark -
#pragma mark Retina Utils
// Use these functions for retina display compatibility.  Retina displays do many things in points (instead of pixels) and it's handy to have conversion functions.

CGPoint PixelsToPoints(CGPoint inPoint)
{
	return ccpMult( inPoint, 1/CC_CONTENT_SCALE_FACTOR() );
}

CGPoint PointsToPixels(CGPoint inPoint)
{
	return ccpMult( inPoint, CC_CONTENT_SCALE_FACTOR() );
}

CGFloat PixelsToPointsF(CGFloat inPoint)
{
	return inPoint / CC_CONTENT_SCALE_FACTOR();
}

CGFloat PointsToPixelsF(CGFloat inPoint)
{
	return inPoint * CC_CONTENT_SCALE_FACTOR();
}


#pragma mark -

@interface TMXGeneratorTestLayer ()		// these methods shouldn't be called anywhere but internally.
- (void) setupSounds;
- (void) setupMap;
- (void) setupPlayer;
- (void) updateForScreenReshape;
@end


@implementation TMXGeneratorTestLayer

enum
{
    kMap,
} nodeTags;

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	TMXGeneratorTestLayer *layer = [TMXGeneratorTestLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init]))
	{
		// init and register touches
		self.isTouchEnabled = YES;
		[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];

		// init class variables
		objectListByGroupName = [[NSMutableDictionary alloc] initWithCapacity:10];

		// set up the map and related items.
		[self setupSounds];
		[self setupMap];
		[self setupPlayer];
	}
	return self;
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	[objectListByGroupName release];

	// don't forget to call "super dealloc"
	[super dealloc];
}

- (void) setupSounds
{
	[[SimpleAudioEngine sharedEngine] preloadEffect:@"hit.wav"];
	[[SimpleAudioEngine sharedEngine] preloadEffect:@"water.wav"];
	[[SimpleAudioEngine sharedEngine] preloadEffect:@"move.wav"];
}

- (void) setupMap
{
	NSString* newMapPath = [self mapFilePath];
	NSError* error = nil;
	TMXGenerator* gen = [[TMXGenerator alloc] init];
	gen.delegate = self;
	
	if (![gen generateAndSaveTMXMap:&error])
	{
		NSLog(@"Error generating TMX Map!  Error: %@, %d", [error localizedDescription], (int)[error code]);
		map = [[[CCTMXTiledMap alloc] initWithTMXFile:@"testMap.tmx"] autorelease];
	}
	else
	{
		map = [[[CCTMXTiledMap alloc] initWithTMXFile:newMapPath] autorelease];			
	}
	[gen release], gen = nil;
	
	// add it as a child.
	[self addChild:map z: -1 tag: kMap];
	
	// calculate scale
	CGSize s = [CCDirector sharedDirector].winSize;
	
	// Scale to fit the screen.
	CGSize mapSize = map.contentSize;    
	CGFloat scaleFactorX = s.height / mapSize.height;
	CGFloat scaleFactorY = s.width / mapSize.width;    
	currentScale = MIN ( 1.0f, MIN(scaleFactorX, scaleFactorY) );

	[self updateForScreenReshape];
}

- (void) updateForScreenReshape
{
	CGSize s = [CCDirector sharedDirector].winSize;
	
    map.scale = currentScale;
    
    // Position on the center of screen.
    map.anchorPoint = ccp(0.5f, 0.5f);
    map.position = ccp(0.5f * s.width, 0.5f * s.height);
}

- (void) setupPlayer
{
	// Find SpawnPoint
	CCTMXObjectGroup* objList = [map objectGroupNamed:kObjectsLayerName];
	NSAssert(objList != nil, @"'Objects' group not found in TMX!");
	NSMutableDictionary* spawnPointDict = [objList objectNamed:kObjectSpawnPointKey];
	NSAssert(spawnPointDict != nil, @"SpawnPoint not found in objects layer of TMX!");
	
	int x = [[spawnPointDict valueForKey:@"x"] intValue];
	int y = [[spawnPointDict valueForKey:@"y"] intValue];
	
	playerSprite = [[CCSprite spriteWithFile:@"hero.png"] retain];
	playerSprite.scale = currentScale;
	playerSprite.position = ccpAdd(PixelsToPoints(ccp(x*playerSprite.scale, y*playerSprite.scale)), map.position);
	
	[self addChild:playerSprite];
}

#pragma mark -
#pragma mark movement


- (CGPoint) tileCoordForPosition:(CGPoint)inPosition
{
	// since the map isn't currently flush with the top, we need to compensate for that space.
	CGSize sz = [CCDirector sharedDirector].winSize;
	double mapHeight = (map.mapSize.height * (PixelsToPointsF(map.tileSize.height) * currentScale));
	double mapWidth = (map.mapSize.width * (PixelsToPointsF(map.tileSize.width) * currentScale));
	double heightOffset = (sz.height - mapHeight) / 2;
	double widthOffset = (sz.width - mapWidth) / 2;
	
	// need to invert Y because cocos2d is bottom-left not top-left.
	int invertedY = (map.mapSize.height * (PixelsToPointsF(map.tileSize.height) * currentScale)) - inPosition.y;
	int x = (inPosition.x + widthOffset) / (PixelsToPointsF(map.tileSize.width) * currentScale);
	int y = (invertedY + heightOffset) / (PixelsToPointsF(map.tileSize.height) * currentScale);
    return ccp(x, y);
}


- (BaseTileTypes) collisionTypeForTile:(CGPoint)inPosition forLayerNamed:(NSString*)layerName
{
	CCTMXTiledMap* curMap = (CCTMXTiledMap*)[self getChildByTag: kMap];		// there are better ways to do it than this!  This is a hack!
	CCTMXLayer* layer = [curMap layerNamed:layerName];
	
	CGPoint tileCoord = [self tileCoordForPosition:inPosition];
	int tileGid = [layer tileGIDAt:tileCoord];
	
	//	// if there's a tile here, check to see what kind it is.
	if (tileGid)
	{
		NSDictionary* dict = [curMap propertiesForGID:tileGid];
		if (dict)
		{
			NSString* val = [dict valueForKey:kTileSetTypeKey];
			if (val)
				return [val intValue];
		}
	}
	
	return tileBase_NoCollision;
}


// example of possible collision detection and movement.
-(void)movePlayerPosition:(CGPoint)inPosition
{
	// with collision
	int type = [self collisionTypeForTile:inPosition forLayerNamed:kMetaLayerTileSetName];
	if (type != tileBase_NoCollision)
	{
		if (type == tileBaseRock)
		{
			[[SimpleAudioEngine sharedEngine] playEffect:@"hit.wav"];
			return;	// we've hit something!  Don't move!
		}
		else if (type == tileBaseWater)
		{
			[[SimpleAudioEngine sharedEngine] playEffect:@"water.wav"];
			return;	// we've hit something!  Don't move!
		}
	}
	
	type = [self collisionTypeForTile:inPosition forLayerNamed:kBackgroundLayerName];
	if (type != tileBase_NoCollision)
	{
		// do some action based on a specific kind of collision here, such as a monster encounter
//		if (type == tileForegroundMonster)
//			[self encounter];
	}		
	
	
	[[SimpleAudioEngine sharedEngine] playEffect:@"move.wav"];
	
	// animate player movement.
	[playerSprite runAction:[CCMoveTo actionWithDuration:0.125 position:inPosition]];
}

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED

#pragma mark -
#pragma mark touches


-(BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
	return YES;
}

-(void) ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint touchLocation = [touch locationInView: [touch view]];		
    touchLocation = [[CCDirector sharedDirector] convertToGL: touchLocation];
    touchLocation = [self convertToNodeSpace:touchLocation];
    
    CGRect mapRect = [map boundingBox];
    if (!CGRectContainsPoint(mapRect, touchLocation))
        return;
	
	// offset our movement based on where we have the background scrolled
    CGPoint playerPos = playerSprite.position;
    CGPoint diff = ccpSub(touchLocation, playerPos);
    if (abs(diff.x) > abs(diff.y))
	{
        if (diff.x > 0)
            playerPos.x += PixelsToPointsF(map.tileSize.width) * currentScale;
        else
            playerPos.x -= PixelsToPointsF(map.tileSize.width) * currentScale; 
    }
	else
	{
        if (diff.y > 0)
            playerPos.y += PixelsToPointsF(map.tileSize.height) * currentScale;
        else
            playerPos.y -= PixelsToPointsF(map.tileSize.height) * currentScale;
    }
	
	// since the map isn't currently flush with the top, we need to compensate for that space.
	CGSize sz = [CCDirector sharedDirector].winSize;
	double mapHeight = (map.mapSize.height * (PixelsToPointsF(map.tileSize.height) * currentScale));
	double mapWidth = (map.mapSize.width * (PixelsToPointsF(map.tileSize.width) * currentScale));
	double heightOffset = (sz.height - mapHeight) / 2;
	double widthOffset = (sz.width - mapWidth) / 2;
	
	
	// map bounds check
    if (playerPos.x <= (map.mapSize.width * (PixelsToPointsF(map.tileSize.width) * currentScale)) &&
        playerPos.y <= (map.mapSize.height * (PixelsToPointsF(map.tileSize.height) * currentScale) + heightOffset) &&
        playerPos.y >= (0 + heightOffset) &&
        playerPos.x >= (0 + widthOffset) &&
		![playerSprite numberOfRunningActions])		// check the running actions to see if we are already moving a tile or not.  Keeps us from re-starting a move when we are already moving.
    {
		[self movePlayerPosition:playerPos];
//		[self setViewpointCenter:_player.position withDuration:kPlayerMoveAnimationSpeed];
    }
	
}

#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)

#error touches equivalent not yet complete for mac version.

#endif


#pragma mark -
#pragma mark map generator delegate


- (NSArray*) layerNames
{
	// warning!  The order these are in determines the layer heirarchy, leftmost is lowest, rightmost is highest!
	return [NSArray arrayWithObjects:kMetaLayerTileSetName, kBackgroundLayerName, kObjectsLayerName, nil];
}


- (NSArray*) tileSetNames
{
	return [NSArray arrayWithObjects:kOutdoorTileSetName, kMetaLayerTileSetName, nil];
}


- (NSArray*) objectGroupNames
{
	return [NSArray arrayWithObjects:kObjectsLayerName, nil];
}


- (NSDictionary*) mapAttributeSetup
{
	NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithCapacity:5];
	[dict setObject:[NSString stringWithFormat:@"%i", kNumTilesPerChunk] forKey:kTMXGeneratorHeaderInfoMapWidth];
	[dict setObject:[NSString stringWithFormat:@"%i", kNumTilesPerChunk] forKey:kTMXGeneratorHeaderInfoMapHeight];
	[dict setObject:[NSString stringWithFormat:@"%i", kNumPixelsPerTileSquare] forKey:kTMXGeneratorHeaderInfoMapTileWidth];
	[dict setObject:[NSString stringWithFormat:@"%i", kNumPixelsPerTileSquare] forKey:kTMXGeneratorHeaderInfoMapTileHeight];
	[dict setObject:[self mapFilePath] forKey:kTMXGeneratorHeaderInfoMapPath];
	[dict setObject:[NSDictionary dictionaryWithObject:@"Test property" forKey:@"property"] forKey:kTMXGeneratorHeaderInfoMapProperties];
	
	return dict;
}


- (NSDictionary*) tileSetInfoForName:(NSString*)name
{
	NSDictionary* dict = nil;
	
	if ([name isEqualToString:kOutdoorTileSetName])
	{
		// filename
		NSString* fileName = kOutdoorTileSetAtlasName;
		
		// setup other info
		dict = [TMXGenerator tileSetWithImage:fileName
										named:name 
										width:kNumPixelsPerTileSquare
									   height:kNumPixelsPerTileSquare
								  tileSpacing:kNumPixelsBetweenTiles];
	}
	else if ([name isEqualToString:kMetaLayerTileSetName])
	{
		// you would add additional tilesets here.
		NSString* fileName = kMetaTileSetAtlasName;
		
		// setup other info
		dict = [TMXGenerator tileSetWithImage:fileName
										named:name 
										width:kNumPixelsPerTileSquare
									   height:kNumPixelsPerTileSquare
								  tileSpacing:kNumPixelsBetweenTiles];
	}
	else
	{
		NSLog(@"tileSetInfoForName: called with name %@, name was not handled!", name);
	}
	
	return dict;
}


- (NSDictionary*) layerInfoForName:(NSString*)name
{	
	NSDictionary* dict = nil;
	
	// default to visible
	BOOL isVisible = YES;

	if ([name isEqualToString:kMetaLayerTileSetName])		// if you have an invisible layer you can set that up here.
		isVisible = NO;								// meta layer isn't visible.

	// data will be filled in by tilePropertyForLayer:tileSetName:X:Y:	
	dict = [TMXGenerator layerNamed:name width:kNumTilesPerChunk height:kNumTilesPerChunk data:nil visible:isVisible];
	return dict;
}


- (NSArray*) objectsGroupInfoForName:(NSString*)name
{
	NSMutableArray* objects = [NSMutableArray arrayWithCapacity:10];
	NSDictionary* dict = nil;
	
	if ([name isEqualToString:kObjectsLayerName])
	{
		// generate the spawn point.
		int x = (kNumPixelsPerTileSquare * 5) + (kNumPixelsPerTileSquare / 2);
		int y = (kNumPixelsPerTileSquare * (kNumTilesPerChunk-3)) - (kNumPixelsPerTileSquare / 2);
		
		// the properties are gathered below, not passed here.
		dict = [TMXGenerator makeObjectWithName:kObjectSpawnPointKey type:nil x:x y:y width:kNumPixelsPerTileSquare*2 height:kNumPixelsPerTileSquare*2 properties:nil];
		if (dict)
			[objects addObject:dict];
		
		// add a new array (if needed) representing our kObjectsLayerName group with the spawn point dictionary inside of that.  
		// Make it mutable so if we want to add to this elsewhere we can.
		NSMutableArray* array = [objectListByGroupName objectForKey:name];
		if (array)
			[array addObject:dict];
		else 
			[objectListByGroupName setObject:[NSMutableArray arrayWithObject:dict] forKey:name];
	}
	
	return objects;
}


- (NSDictionary*) propertiesForTileSetNamed:(NSString*)name
{
	NSMutableDictionary* retVal = [NSMutableDictionary dictionaryWithCapacity:50];
	NSMutableDictionary* dict;
	NSString* typeName;
	
	// These propertie map to the given atlas tile.
	if ([name isEqualToString:kOutdoorTileSetName])
	{
		// outdoor atlas setup
		
		// tile 0
		dict = [NSMutableDictionary dictionaryWithCapacity:10];
		[dict setObject:[NSString stringWithFormat:@"%i", kOutdoorTileGrass] forKey:kTileSetTypeNameKey];
		[retVal setObject:dict forKey:@"0"];
		
		// tile 1
		dict = [NSMutableDictionary dictionaryWithCapacity:10];
		[dict setObject:[NSString stringWithFormat:@"%i", kOutdoorTileDirt] forKey:kTileSetTypeNameKey];
		[retVal setObject:dict forKey:@"1"];
		
		// tile 2
		dict = [NSMutableDictionary dictionaryWithCapacity:10];
		[dict setObject:typeName = [NSString stringWithFormat:@"%i", kOutdoorTileRock] forKey:kTileSetTypeNameKey];
		[retVal setObject:dict forKey:@"2"];
		
		// tile 3
		dict = [NSMutableDictionary dictionaryWithCapacity:10];
		[dict setObject:[NSString stringWithFormat:@"%i", kOutdoorTileWater] forKey:kTileSetTypeNameKey];
		[retVal setObject:dict forKey:@"3"];
		
	}
	else if ([name isEqualToString:kMetaLayerTileSetName])
	{
		// meta tileset ID's
		// tile 0 in the atlas
		dict = [NSMutableDictionary dictionaryWithCapacity:10];
		[dict setObject:[NSString stringWithFormat:@"%i", tileBaseWater] forKey:kTileSetTypeKey];
		[dict setObject:[NSString stringWithFormat:@"%i", kMetaTileWater] forKey:kTileSetTypeNameKey];
		[retVal setObject:dict forKey:@"0"];
		
		// tile 1
		dict = [NSMutableDictionary dictionaryWithCapacity:10];
		[dict setObject:[NSString stringWithFormat:@"%i", tileBaseRock] forKey:kTileSetTypeKey];
		[dict setObject:[NSString stringWithFormat:@"%i", kMetaTileRock] forKey:kTileSetTypeNameKey];
		[retVal setObject:dict forKey:@"1"];
	}
	
	return retVal;
}


- (NSArray*) propertiesForObjectWithName:(NSString *) name inGroupWithName: (NSString *) groupName
{
	// no object properties currently for any objects.
	return nil;
}


- (NSString*) mapFilePath
{
	// put this in the document directory, then you can grab the TMX file from iTunes sharing if you'd like.
	NSArray *paths					= NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory	= [paths objectAtIndex:0];
	NSString *fullPath				= [documentsDirectory stringByAppendingPathComponent:kGeneratedMapName];
	return fullPath;
}


- (NSString*) tileIdentificationKeyForLayer:(NSString*)layerName
{
	// once we start using multiple tiles for multiple layers and need a different key value, change the name for those keys here.  Multiple names are optional and only useful for your own grouping purposes.
	return kTileSetTypeNameKey;
}


- (NSString*) tileSetNameForLayer:(NSString*)layerName
{
	// if you were using multiple tilesets then you'd want to determine which tileset you needed based on the layer name here.
	if ([layerName isEqualToString:kMetaLayerTileSetName])
	{
		return kMetaLayerTileSetName;
	}
	else if ([layerName isEqualToString:kBackgroundLayerName])
	{
		return kOutdoorTileSetName;
	}
	return nil;
}


- (NSString*) tilePropertyForLayer:(NSString*)layerName tileSetName:(NSString*)tileSet X:(int)x Y:(int)y
{
	// this is NOT the best way to generate your tile data, but it illustrates the concept.
	static int tileGenerationData[kNumTilesPerChunk][kNumTilesPerChunk] =
	{
		{2, 2, 2, 2, 2, 2, 2, 2, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 3, 3, 3, 3, 3, 3, 3},
		{2, 2, 2, 2, 2, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 3, 3, 3, 3, 3, 3, 3},
		{2, 2, 2, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 3, 3, 3, 3, 3, 3, 3, 0},
		{2, 2, 1, 1, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 0, 0, 0},
		{2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 3, 3, 3, 3, 3, 3, 3, 0, 0, 0, 0, 0},
		{2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 3, 3, 3, 3, 0, 0, 0, 0, 0},
		{2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
		{2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
		{2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
		{2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
		{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
		{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
		{0, 0, 0, 0, 0, 0, 0, 0, 3, 3, 3, 3, 3, 0, 0, 0, 0, 0, 0, 2, 2, 2, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0},
		{0, 0, 0, 0, 0, 0, 0, 3, 3, 3, 3, 3, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0},
		{0, 0, 0, 0, 0, 0, 0, 3, 3, 3, 3, 3, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0},
		{0, 0, 0, 0, 0, 0, 1, 1, 3, 3, 3, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0},
		{0, 0, 0, 0, 0, 0, 1, 1, 3, 3, 3, 0, 0, 0, 0, 0, 0, 0, 0, 2, 2, 0, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0},
		{0, 0, 0, 0, 0, 0, 0, 1, 1, 3, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
		{0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
		{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
		{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
		{3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0},
		{3, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 3, 3, 0, 0, 0, 0, 0, 0, 0, 2},
		{3, 3, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 2, 2, 2},
		{3, 3, 3, 3, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 2, 2, 2, 2, 2},
		{3, 3, 3, 3, 3, 3, 3, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 2, 2, 2, 2, 2, 2},
		{3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 2, 2, 2, 2, 2, 2},
		{3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 2, 2, 2, 2, 2, 2, 2},
		{3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 2, 2, 2, 2, 2, 2, 2},
		{3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 2, 2, 2, 2, 2, 2, 2, 2},
		{3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 2, 2, 2, 2, 2, 2, 2, 2},
		{3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 0, 0, 0, 0, 0, 0, 0, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2}
	};
	
	// should return the string value of the tile type here for the appropriate layer.
	if ([layerName isEqualToString:kBackgroundLayerName])
	{
		// I use numbers 0-3 for tile property names (in propertiesForTileSetNamed:) to make this code more automated.
		// also, I use y,x so that the above reflects what gets sent out to the screen.
		return [NSString stringWithFormat:@"%d", tileGenerationData[y][x]];
	}
	else if ([layerName isEqualToString:kMetaLayerTileSetName])
	{
		// check the background layer's map data.  If it's not passable then we return the meta tile type that corresponds to the background type.
		// generally I would use the same values for both the meta layer and the general layer (it's less code) but for illustration
		// purposes I've split them into two separate enumerations.  You could also create methods to convert more complex types for this as well.
		
		// Note that we use @"0" and @"1" for the names of the atlas tiles when defining the meta tile properties (in propertiesForTileSetNamed:).
		// This is so we can use an enumeration elsewhere in the code to identify tiles (which is generally more descriptive and easier)
		// and then send the value of the enumeration (0 for water, 1 for rock) back here and get the appropriate tile.
		if (tileGenerationData[y][x] == kOutdoorTileWater)
			return [NSString stringWithFormat:@"%d", kMetaTileWater];
		else if (tileGenerationData[y][x] == kOutdoorTileRock)
			return [NSString stringWithFormat:@"%d", kMetaTileRock];
	}
	
	return @"No Property";
}


// If you had implemented rotated tiles then you would return degree rotation for the passed in tile coords on the passed layer.  We are not using (meaningful) rotation in this example.
//- (int) tileRotationForLayer:(NSString*)layerName X:(int)x Y:(int)y
//{
//	return 0;	// 0-360 degree rotation value for tile at x,y
//}


@end
