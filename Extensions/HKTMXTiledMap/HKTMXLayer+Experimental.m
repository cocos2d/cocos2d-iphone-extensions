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


#import "HKTMXLayer+Experimental.h"
#import "CCSprite.h"
#import "Support/CGPointExtension.h"
#import "CCTMXXMLParser.h"
#import "ccMacros.h"

@implementation HKTMXLayer (Experimental)

// JEB - Generates a sprite based on the tile at given coords
-(CCSprite*) tileAt:(CGPoint)pos
{
	NSAssert( pos.x < layerSize_.width && pos.y < layerSize_.height && pos.x >=0 && pos.y >=0, @"TMXLayer: invalid position");
	//NSAssert( tiles_ && atlasIndexArray_, @"TMXLayer: the tiles map has been released");
	
	CCSprite *tile = nil;
	uint32_t gid = [self tileGIDAt:pos];
    uint32_t flipbits = [self tileFlipBitsAt:pos];
	
	// if GID == 0, then no tile is present
	if( gid ) 
    {
        
        CGRect rect = [tileset_ rectForGID:gid];
        if (CC_CONTENT_SCALE_FACTOR() == 2)
        {
            // Retina Support
            rect.origin.x = (rect.origin.x * 0.5);
            rect.origin.y = (rect.origin.y * 0.5);
            rect.size.width = (rect.size.width * 0.5);
            rect.size.height = (rect.size.height * 0.5);
        }
        tile = [CCSprite spriteWithTexture:texture_ rect:rect];
		[tile setPosition: [self positionAt:pos]];
        tile.anchorPoint = CGPointZero;
        [tile setOpacity:opacity_];
        
        // Test for 90 rotation
        if((flipbits & kTileRotated90) == kTileRotated90)
        {
            tile.rotation = 90;
        }
        // Test for 270 rotation
        else if ((flipbits & kTileRotated270) == kTileRotated270)
        {
            tile.rotation = 270;
        }
        else
        {
            // Normal flipping
            if(flipbits & kFlippedHorizontallyFlag)
                tile.flipX = YES;
            
            if(flipbits & kFlippedVerticallyFlag)
                tile.flipY = YES;
        }       
	}
	return tile;
}



// JEB - Replaces a tilemap tile with a sprite tile
-(void) setTile:(CCSprite *)tile at:(CGPoint) pos
{
    NSAssert( pos.x < layerSize_.width && pos.y < layerSize_.height && pos.x >=0 && pos.y >=0, @"TMXLayer: invalid position");
    NSAssert( ((tile.contentSize.width == mapTileSize_.width) &&
               (tile.contentSize.height == mapTileSize_.height)), @"TMXLayer: invalid tile");
    
    // Remove current tile from location
    [self removeTileAt:pos];
    
    // Set anchor point at center to allow rotaion.
    tile.anchorPoint = ccp(0.5f,0.5f);
    pos.x += 0.5f;
    pos.y -= 0.5f;
    
    // Position in pixels for retina support
    tile.position = ccp((pos.x * mapTileSize_.width), (((layerSize_.height -1) * mapTileSize_.height) - pos.y * mapTileSize_.height));
    
    // Add sprite to layer via CCNode's addChild method
    [super addChild:tile z:_zOrder tag:0];
}



// JEB - The following is to aid performance if using "sprite" tiles
-(void) visit
{
    
    // Have any "Sprite" tiles been added to the layer
    if(_children)
    {
		ccArray *arrayData = _children->data;
		
		
		CGAffineTransform trans = [self worldToNodeTransform];
        CGPoint baseTile = CGPointMake(floor(trans.tx / mapTileSize_.width),
                                       floor(trans.ty / mapTileSize_.height)); 
        CGPoint maxTile = CGPointMake((baseTile.x + screenGridSize_.width) , 
                                      (baseTile.y + screenGridSize_.height));
        
        NSUInteger i = 0;
		
        // Process each child tile
        for( ; i < arrayData->num; i++ ) 
        {
			CCNode *child = arrayData->arr[i];
            
            // sprite position always positive so can cast intead of calling floor
            CGPoint tileCoord = CGPointMake((int)(child.position.x / mapTileSize_.width),
                                            (int)(child.position.y / mapTileSize_.height));
            
            // Should the tile be actually drawn.
            if ((tileCoord.x >= baseTile.x) && (tileCoord.y >= baseTile.y) &&
                (tileCoord.x <  maxTile.x ) && (tileCoord.y <  maxTile.y ))
            {
                child.visible = YES;
            }
            else
            {
                child.visible = NO;
            }
		}
	}	
    
    // Ensure CCNode visit is called
    [super visit];
}


@end
