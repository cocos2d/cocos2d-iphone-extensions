/*
 * HKTMXTiledMap
 *
 * cocos2d-extensions
 * https://github.com/cocos2d/cocos2d-iphone-extensions
 * 
 * HKASoftware
 * http://hkasoftware.com
 *
 * Copyright (c) 2011 HKASoftware
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
 * TMX Tiled Map support:
 * http://www.mapeditor.org
 *
 */
#import "CCNode.h"

@class CCTMXMapInfo;
@class CCTMXLayerInfo;
@class CCTMXTilesetInfo;

/**
 Represents a tile animation state.  When animClock == 0.0, each tile is in a state
 equal to its GID.  After entering a state, a tile will look up the AnimRule for that
 state, wait `delay` seconds, and then switch to state `next`.  If `next` is zero, it
 will stay in the state forever.
 
 As an optimization, `cycleTime` and `last` provide information about the complete
 animation starting at this state.  If `last` is zero, it is an endless loop
 with a period of `cycleTime` seconds.  If `last` is nonzero, it will reach state
 `last` and terminate in a total of `cycleTime` seconds.
 */
struct HKTMXAnimRule {
	double delay;
	double cycleTime;
	unsigned int next;
	unsigned int last;
};

struct HKTMXAnimCacheEntry {
	unsigned int state;
	double validUntil;
};

@interface HKTMXLayer : CCNode
{
	CCTMXTilesetInfo	*tileset_;
	CCTexture2D			*texture_;
	NSString			*layerName_;
	CGSize				layerSize_;
	CGSize				mapTileSize_;
	CGSize				screenGridSize_;
	unsigned int		*tiles_;
	NSMutableArray		*properties_;
	unsigned char		opacity_;
	unsigned int		minGID_;
	unsigned int		maxGID_;
	GLuint				buffers_[3];
	
	double				dirtyAt_;
	CGPoint				lastBaseTile_;
	int					lastVertexCount_;
	
	struct HKTMXAnimRule *animRules_;
	struct HKTMXAnimCacheEntry *animCache_;
	double				animClock_;
}
/** name of the layer */
@property (nonatomic,readwrite,retain) NSString *layerName;
/** size of the layer in tiles */
@property (nonatomic,readwrite) CGSize layerSize;
/** size of the map's tile (could be differnt from the tile's size) */
@property (nonatomic,readwrite) CGSize mapTileSize;
/** pointer to the map of tiles */
@property (nonatomic,readwrite) unsigned int *tiles;
/** Tileset information for the layer */
@property (nonatomic,readwrite,retain) CCTMXTilesetInfo *tileset;
/** Layer orientation, which is the same as the map orientation */
@property (nonatomic,readwrite) int layerOrientation;
/** properties from the layer. They can be added using Tiled */
@property (nonatomic,readwrite,retain) NSMutableArray *properties;

/** creates an HKTMXLayer with a tileset info, a layer info and a map info */
+(id) layerWithTilesetInfo:(CCTMXTilesetInfo*)tilesetInfo layerInfo:(CCTMXLayerInfo*)layerInfo mapInfo:(CCTMXMapInfo*)mapInfo;
/** initializes an HKTMXLayer with a tileset info, a layer info and a map info */
-(id) initWithTilesetInfo:(CCTMXTilesetInfo*)tilesetInfo layerInfo:(CCTMXLayerInfo*)layerInfo mapInfo:(CCTMXMapInfo*)mapInfo;

/** returns the tile gid at a given tile coordinate.
 if it returns 0, it means that the tile is empty.
 */
-(unsigned int) tileGIDAt:(CGPoint)tileCoordinate;

/** sets the tile gid (gid = tile global id) at a given tile coordinate.
 The Tile GID can be obtained by using the method "tileGIDAt" or by using the TMX editor -> Tileset Mgr +1.
 If a tile is already placed at that position, then it will be replaced.
 */
-(void) setTileGID:(unsigned int)gid at:(CGPoint)tileCoordinate;

/** removes a tile at given tile coordinate */
-(void) removeTileAt:(CGPoint)tileCoordinate;

/** returns the position in pixels of a given tile coordinate */
-(CGPoint) positionAt:(CGPoint)tileCoordinate;

/** return the value for the specific property name */
-(id) propertyNamed:(NSString *)propertyName;

/** Creates the tiles */
-(void) setupTiles;

@end
