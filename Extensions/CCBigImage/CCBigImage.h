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
#import "cocos2d.h"

// How many times visit should be called to call removeUnusedTexture
#define CCBIGIMAGE_TEXTURE_UNLOAD_PERIOD 3

/** @class CCBigImage Node, that holds parts of big image as 
 * an idvididual dynamically unloadable tiles.
 * Besides dynamic tiles this node can have normal children, such as CCSprite, layer, etc...
 *
 * CCBigImage is refactored DynamicTiledLevelNode
 * New Features:
 *  1) Tile-Cutter ( https://github.com/psineur/Tile-Cutter ) instead of Gimp & xcftools
 *  2) Removed unnecessary code, more comments, etc...
 *
 * Besides Dynamic Mode, when all tiles are loaded in independent thread
 * this node also supports Static Mode (dynamicMode = NO) when all tiles are 
 * preloaded and no additional thread is used. 
 * However, even in staticMode tiles that aren't visible now in screen rect will be not
 * rendered to increase performance.
 *
 * LIMITATIONS: CCCamera may be not supported.
 */
@interface CCBigImage : CCNode
{	
	// How much more tiles we should load beyond the visible area
	CGSize _screenLoadRectExtension;
	
	// Area within all tiles must be loaded
	CGRect _loadedRect;
	
	// Array of UnloadableSprites that holds image tiles
	NSMutableArray *_dynamicChildren;
	
	// holds textures to avoid removing them from cache if DynamicMode & PreloadAllTiles are used
	NSMutableArray *_levelTextures;
	
	// Dynamic Tiles Loading Mechanism
	NSThread *_tilesLoadThread;
	BOOL _tilesLoadThreadIsSleeping; //< status of loading tiles thread to know when to unload textures
	BOOL _significantPositionChange; //< if YES - tiles load will be forced	
	
	BOOL _dynamicMode;
}

// private property
@property(retain) NSThread *tilesLoadThread; 

/** Returns size that describes in what distance beyond each side of the screen tiles should be loaded
 * to avoid holes when levels scrolls fast.
 * By default it's equal to first tile's size.
 */
@property (readwrite) CGSize screenLoadRectExtension;

/** if YES - then only needed (visible in screen rect) tiles will be loaded at the moment
 *   via independent thread
 * if NO - all tiles will be preloaded and no no additional thread will be used
 * This property can be changed at runtime in both directions.
 * On the Mac by default this property is OFF
 * On the iOS devices by default this property is ON
 */
@property (readwrite) BOOL dynamicMode;

/** Returns new CCBigImage. @see initWithTilesFile:tilesExtension:tilesZ: */
+ (id) nodeWithTilesFile: (NSString *) filename 
		  tilesExtension: (NSString *) extension 
				  tilesZ: (int) tilesZ;

/** Inits CCBigImage. Designated initializer.
 *
 * @param filename plist filename from Tile-Cutter. 
 *
 * @param extension file extension, that will be used for all tiles instead of their 
 * extensions that are in plist file. Pass nil to kep original extension from plist file.
 *
 * @param tilesZ zOrder, that will be used for all tiles. Usefull when you have 
 * other nodes added as children to CCBigImage.
 */
- (id) initWithTilesFile: (NSString *) filename 
		  tilesExtension: (NSString *) extension 
				  tilesZ: (int) tilesZ;

/** Load tiles by request in a given rect (in nodes coordinates) */
- (void) loadTilesInRect: (CGRect) loadRect;

@end
