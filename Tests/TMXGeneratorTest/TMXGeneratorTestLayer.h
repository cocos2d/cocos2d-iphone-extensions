/*
 * TMXGenerator_WorldMap.h
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

#import <Foundation/Foundation.h>
#import "cocos2d.h"

#import "TMXGenerator.h"

@interface TMXGeneratorTestLayer : CCLayer <TMXGeneratorDelegate> {
	
	// tile map creation
	NSMutableDictionary* _objectListByGroupName;
	CCTMXTiledMap* _map;

	// player
	CCSprite* _playerSprite;
}

// returns a CCScene that contains the TMXGenerator_WorldMap as the only child
+(CCScene *) scene;


@end


// tile map creation delegate #defines
#define kOutdoorTileSetName				@"OutdoorTileset"
#define kMetaLayerTileSetName			@"MetaTileset"
#define kMetaTileSetAtlasName			@"metaTiles.png"
#define kOutdoorTileSetAtlasName		@"testTiles.png"

#define kBackgroundLayerName			@"Background"
#define kObjectsLayerName				@"objectLayer"

#define kNumTilesPerChunk				32
#define kNumPixelsPerTileSquare			256
#define kNumPixelsBetweenTiles			2

#define kObjectSpawnPointKey			@"SpawnPoint"
#define kObjectSpawnPointTileCoordX     20
#define kObjectSpawnPointTileCoordY     20
#define kTileSetTypeKey					@"type"
#define kTileSetTypeNameKey				@"typeName"

#define kGeneratedMapName				@"generatedTMXMap.tmx"


// Tile types (if used as types) all need to be unique across all enums or things can get confused.
typedef enum {
	kOutdoorTileGrass = 0,
	kOutdoorTileDirt,
	kOutdoorTileRock,
	kOutdoorTileWater,
	kOutdoorTileEnd
} outdoorTileNames;

typedef enum {
	kMetaTileWater = kOutdoorTileEnd,
	kMetaTileRock,
	kMetaTileEnd
} metaTileNames;

typedef enum
{
	tileBase_NoCollision = kMetaTileEnd,
	tileBaseRock,
	tileBaseWater,
	tileBaseEnd
} BaseTileTypes;


