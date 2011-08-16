//
//  TMXGenerator_WorldMap.m
//
//  Created by Jeremy Stone on 8/6/11.
//
/*
 Copyright (c) 2011 Stone Software, Jeremy Stone. All rights reserved.
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#import "TMXGenerator_WorldMap.h"

#import "ExtensionTest.h"

SYNTHESIZE_EXTENSION_TEST(TMXGenerator_WorldMap)

@implementation TMXGenerator_WorldMap

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	TMXGenerator_WorldMap *layer = [TMXGenerator_WorldMap node];
	
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
		// init variables
		objectListByGroupName = [[NSMutableDictionary alloc] initWithCapacity:10];
		
		// generate a map.
		NSString* newMapPath = [self mapFilePath];
		NSError* error = nil;
		CCTMXTiledMap* map = nil;
		TMXGenerator* gen = [[TMXGenerator alloc] init];
		gen.delegate = self;
		
		if (![gen generateTMXMap:&error])
		{
			NSLog(@"Error generating TMX Map!  Error: %@, %d", [error localizedDescription], [error code]);
			map = [[[CCTMXTiledMap alloc] initWithTMXFile:@"testMap.tmx"] autorelease];
		}
		else
		{
			map = [[[CCTMXTiledMap alloc] initWithTMXFile:newMapPath] autorelease];			
		}
		[gen release], gen = nil;
		
		// set up the zoom/scroll for the map.
		_controller = [[CCPanZoomController controllerWithNode:self] retain];
        _controller.boundingRect = CGRectMake(0, 0, map.contentSize.width, map.contentSize.height);
        [_controller enableWithTouchPriority:0 swallowsTouches:YES];

		// zoom limit, currently to 4 tiles or screen size.
		float minSize = MAX([[CCDirector sharedDirector] winSizeInPixels].width, [[CCDirector sharedDirector] winSizeInPixels].height) / 2.0;
//		minSize = MAX(minSize, map.tileSize.width * 4);
		_controller.zoomOutLimit = minSize / MAX(map.contentSize.width/2.0, map.contentSize.height/2.0);
		
		// zoom out a bit at the beginning
		[_controller centerOnPoint:CGPointMake(map.contentSize.width/2.0, map.contentSize.height/2.0)];
		
		// add it as a child.
		[self addChild:map];
	}
	return self;
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	[_controller disable];
	[_controller release];

	[objectListByGroupName release];

	// don't forget to call "super dealloc"
	[super dealloc];
}


#pragma mark -
#pragma mark map generator delegate


- (NSArray*) layerNames
{
	// warning!  The order these are in determines the layer heirarchy, leftmost is lowest, rightmost is highest!
	return [NSArray arrayWithObjects:kBackgroundLayerName, kObjectsLayerName, nil];
}


- (NSArray*) tileSetNames
{
	return [NSArray arrayWithObjects:kOutdoorTileSetName, nil];
}


- (NSArray*) objectGroupNames
{
	return [NSArray arrayWithObjects:kObjectsLayerName, nil];
}


- (NSDictionary*) mapSetupInfo
{
	NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithCapacity:5];
	[dict setObject:[NSString stringWithFormat:@"%i", kNumTilesPerChunk] forKey:kHeaderInfoMapWidth];
	[dict setObject:[NSString stringWithFormat:@"%i", kNumTilesPerChunk] forKey:kHeaderInfoMapHeight];
	[dict setObject:[NSString stringWithFormat:@"%i", kNumPixelsPerTileSquare] forKey:kHeaderInfoMapTileWidth];
	[dict setObject:[NSString stringWithFormat:@"%i", kNumPixelsPerTileSquare] forKey:kHeaderInfoMapTileHeight];
	[dict setObject:[self mapFilePath] forKey:kHeaderInfoMapPath];
	
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
//	else if ([name isEqualToString:@"another tileset"])
//	{
//		// you would add additional tilesets here.
//	}
	else
	{
		NSLog(@"tileSetInfoForName: called with name %@, name was not handled!", name);
	}
	
	return dict;
}


- (NSDictionary*) layerInfoForName:(NSString*)name
{	
	// currently all layers are created equal.  Doesn't always have to be so.
	BOOL isVisible = YES;
//	if ([name isEqualToString:kMetaLayerName])		// if you have an invisible layer you can set that up here.
//		isVisible = NO;
	
	// generate the layer info
	// data will be filled in by tilePropertyForLayer:tileSetName:X:Y:
	NSDictionary* dict = [TMXGenerator layerNamed:name width:kNumTilesPerChunk height:kNumTilesPerChunk data:nil visible:isVisible];
	return dict;
}


- (NSArray*) objectInfoForName:(NSString*)name
{
	NSMutableArray* objects = [NSMutableArray arrayWithCapacity:10];
	NSDictionary* dict = nil;
	
	if ([name isEqualToString:kObjectsLayerName])
	{
		// generate the spawn point.
		int x = (kNumPixelsPerTileSquare * 3) + (kNumPixelsPerTileSquare / 2);
		int y = (kNumPixelsPerTileSquare * (kNumTilesPerChunk-3)) - (kNumPixelsPerTileSquare / 2);
		
		// the properties are gathered below, not passed here.
		dict = [TMXGenerator makeGroupObjectWithName:kObjectSpawnPointKey type:nil x:x y:y width:kNumPixelsPerTileSquare*2 height:kNumPixelsPerTileSquare*2 properties:nil];
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
		// atlas setup
		
		// tile 0
		dict = [NSMutableDictionary dictionaryWithCapacity:10];
		typeName = [NSString stringWithFormat:@"%i", kTileGrass];
		[dict setObject:typeName forKey:kTileSetTypeKey];
		[dict setObject:typeName forKey:kTileSetTypeNameKey];
		[retVal setObject:dict forKey:@"0"];
		
		// tile 1
		dict = [NSMutableDictionary dictionaryWithCapacity:10];
		typeName = [NSString stringWithFormat:@"%i", kTileDirt];
		[dict setObject:typeName forKey:kTileSetTypeKey];
		[dict setObject:typeName forKey:kTileSetTypeNameKey];
		[retVal setObject:dict forKey:@"1"];
		
		// tile 2
		dict = [NSMutableDictionary dictionaryWithCapacity:10];
		typeName = [NSString stringWithFormat:@"%i", kTileRock];
		[dict setObject:typeName forKey:kTileSetTypeKey];
		[dict setObject:typeName forKey:kTileSetTypeNameKey];
		[retVal setObject:dict forKey:@"2"];
		
		// tile 3
		dict = [NSMutableDictionary dictionaryWithCapacity:10];
		typeName = [NSString stringWithFormat:@"%i", kTileWater];
		[dict setObject:typeName forKey:kTileSetTypeKey];
		[dict setObject:typeName forKey:kTileSetTypeNameKey];
		[retVal setObject:dict forKey:@"3"];
		
	}
//	else if ([name isEqualToString:@"other tileset here"])
//	{
//		// add other defined tilesets here
//	}
	
	return retVal;
}


- (NSArray*) propertiesForObjectGroupNamed:(NSString*)groupName objectName:(NSString*)objName
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
	// once we start using multiple tiles for multiple layers and need a different key value, change the name for those keys here.
	return kTileSetTypeNameKey;
}


- (NSString*) tileSetNameForLayer:(NSString*)layerName
{
	// if you were using multiple tilesets then you'd want to determine which tileset you needed based on the layer name here.
	return kOutdoorTileSetName;
}


- (NSString*) tilePropertyForLayer:(NSString*)layerName tileSetName:(NSString*)tileSet X:(int)x Y:(int)y
{
	// this is NOT the best way to generate your tile data, but it illustrates the concept.
	int tileGenerationData[kNumTilesPerChunk][kNumTilesPerChunk] =
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
		{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
		{3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
		{3, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2},
		{3, 3, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 2, 2},
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
		// I use numbers 0-3 for tile names to make this code more automated.
		// also, I use y,x so that the above reflects what gets sent out to the screen.
		return [NSString stringWithFormat:@"%d", tileGenerationData[y][x]];
	}
//	else if ([layerName isEqualToString:kMetaLayerName])
//	{
//		// if you had multiple layers you would return the appropriate type name here, as defined in propertiesForTileSetNamed:
//	}
	
	return @"No Property";
}


- (int) tileRotationForLayer:(NSString*)layerName X:(int)x Y:(int)y
{
	// If you had implemented rotated tiles then you would return degree rotation for the passed in tile coords on the passed layer.  We are not using (meaningful) rotation in this example.
	return 0;
}


@end
