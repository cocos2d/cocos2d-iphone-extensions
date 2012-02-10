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

#import "HKTMXLayer.h"
#import "CCTMXTiledMap.h"
#import "CCTMXXMLParser.h"
#import "CCTextureCache.h"
#import "CCDirector.h"
#import "CGPointExtension.h"
#import "ccMacros.h"
#import "CCSprite.h"

#pragma mark -
#pragma mark HKTMXLayer

@interface HKTMXLayer (Private)
-(CGPoint) positionForOrthoAt:(CGPoint)pos;

-(CGPoint) calculateLayerOffset:(CGPoint)offset;

/* The layer recognizes some special properties, like cc_vertez */
-(void) parseInternalProperties;

@end

@implementation HKTMXLayer
@synthesize layerSize = layerSize_, layerName = layerName_, tiles=tiles_;
@synthesize tileset=tileset_;
@synthesize layerOrientation=layerOrientation_;
@synthesize mapTileSize=mapTileSize_;
@synthesize properties=properties_;
@synthesize opacity=opacity_;
@synthesize color=color_;
@synthesize blendFunc = blendFunc_;

#pragma mark CCTMXLayer - init & alloc & dealloc

+(id) layerWithTilesetInfo:(CCTMXTilesetInfo*)tilesetInfo layerInfo:(CCTMXLayerInfo*)layerInfo mapInfo:(CCTMXMapInfo*)mapInfo
{
	return [[[self alloc] initWithTilesetInfo:tilesetInfo layerInfo:layerInfo mapInfo:mapInfo] autorelease];
}

-(id) initWithTilesetInfo:(CCTMXTilesetInfo*)tilesetInfo layerInfo:(CCTMXLayerInfo*)layerInfo mapInfo:(CCTMXMapInfo*)mapInfo
{	
	if((self=[super init]))
	{
        // JEB - default blend function
		blendFunc_ = (ccBlendFunc) { CC_BLEND_SRC, CC_BLEND_DST };
        
        // JEB - default colour
        color_.r = 255;
        color_.g = 255;
        color_.b = 255;
        
        
        
		texture_ = [[CCTextureCache sharedTextureCache] addImage:tilesetInfo.sourceImage];
		tilesetInfo.imageSize = texture_.contentSizeInPixels;
		
		// layerInfo
		layerName_ = [layerInfo.name copy];
		layerSize_ = layerInfo.layerSize;
		tiles_ = layerInfo.tiles;
		minGID_ = tilesetInfo.firstGid;
		maxGID_ = minGID_
			+ (tilesetInfo.imageSize.width - tilesetInfo.margin * 2 + tilesetInfo.spacing)
			/ (tilesetInfo.tileSize.width + tilesetInfo.spacing)
			* (tilesetInfo.imageSize.height - tilesetInfo.margin * 2 + tilesetInfo.spacing)
			/ (tilesetInfo.tileSize.height + tilesetInfo.spacing)
			- 1;
		opacity_ = layerInfo.opacity;
		properties_ = [layerInfo.properties mutableCopy];
		
		// tilesetInfo
		tileset_ = [tilesetInfo retain];
		
		// mapInfo
		mapTileSize_ = mapInfo.tileSize;
		layerOrientation_ = mapInfo.orientation;
		
		// offset (after layer orientation is set);
		CGPoint offset = [self calculateLayerOffset:layerInfo.offset];
		[self setPositionInPixels:offset];
		
		[self setContentSizeInPixels: CGSizeMake( layerSize_.width * mapTileSize_.width, layerSize_.height * mapTileSize_.height )];
		
		// adjust and validate tile IDs
		NSAssert1(minGID_ <= maxGID_ + 1 && maxGID_ - minGID_ < 1000000,
			@"TMX: Bad minGID/maxGID for layer %@", layerName_);
		int tileCount = layerSize_.height * layerSize_.width;
		for(int i=0; i < tileCount; i++)
		{
#ifdef __BIG_ENDIAN__
			tiles_[i] = CFSwapInt32(tiles_[i]);
#endif
            
            // JEB flip bits masked to compare true GID
			NSAssert((tiles_[i] & kFlippedMask) == 0 || 
                     (((tiles_[i] & kFlippedMask) >= minGID_) && ((tiles_[i] & kFlippedMask) <= maxGID_)),
				@"TMX: Only one tileset per layer is supported");
		}
		
		CGSize screenSize = [CCDirector sharedDirector].winSizeInPixels;
		screenGridSize_.width = (ceil(screenSize.width / mapTileSize_.width)*2) + 1;
		screenGridSize_.height = (ceil(screenSize.height / mapTileSize_.height)*2) + 1;
		int screenTileCount = screenGridSize_.width * screenGridSize_.height;
		// create buffer objects
		glGenBuffers(3, buffers_);
		// generate a static vertex array covering the screen
		glBindBuffer(GL_ARRAY_BUFFER, buffers_[0]);
		glBufferData(GL_ARRAY_BUFFER, screenTileCount * 4 * 2 * sizeof(GLfloat), NULL, GL_STATIC_DRAW);
#if __IPHONE_OS_VERSION_MAX_ALLOWED
		GLfloat *screenGrid = glMapBufferOES(GL_ARRAY_BUFFER, GL_WRITE_ONLY_OES);
#elif __MAC_OS_X_VERSION_MAX_ALLOWED
        GLfloat *screenGrid = glMapBuffer(GL_ARRAY_BUFFER, GL_WRITE_ONLY);
#endif
		GLfloat *tilePtr = screenGrid;
		for (int y=0; y < screenGridSize_.height; y++)
		{
			GLfloat ypos_0 = mapTileSize_.height * y;
			GLfloat ypos_1 = mapTileSize_.height * (y+1);
			for (int x=0; x < screenGridSize_.width; x++, tilePtr += 4 * 2)
			{
				GLfloat xpos_0 = mapTileSize_.width * x;
				GLfloat xpos_1 = mapTileSize_.width * (x+1);
				// define the points of a quad here; we'll use the index buffer to make them triangles
				tilePtr[0] = xpos_0;
				tilePtr[1] = ypos_0;
				tilePtr[2] = xpos_1;
				tilePtr[3] = ypos_0;
				tilePtr[4] = xpos_0;
				tilePtr[5] = ypos_1;
				tilePtr[6] = xpos_1;
				tilePtr[7] = ypos_1;
			}
		}
#if __IPHONE_OS_VERSION_MAX_ALLOWED
		glUnmapBufferOES(GL_ARRAY_BUFFER);
#elif __MAC_OS_X_VERSION_MAX_ALLOWED
        glUnmapBuffer(GL_ARRAY_BUFFER);
#endif
		// allocate texcoord buffer
		glBindBuffer(GL_ARRAY_BUFFER, buffers_[1]);
		glBufferData(GL_ARRAY_BUFFER, screenTileCount * 4 * 2 * sizeof(GLfloat), NULL, GL_DYNAMIC_DRAW);
		// allocate index buffer
		glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, buffers_[2]);
		glBufferData(GL_ELEMENT_ARRAY_BUFFER, screenTileCount * 6 * sizeof(GLushort), NULL, GL_DYNAMIC_DRAW);
		
		glBindBuffer(GL_ARRAY_BUFFER, 0);
		glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
		
		// --= set up animations =--
		// XXX should belong to tileset or map to avoid redundancy
		__block int animCount = 0;
		// read relevant tile properties from the map
		animRules_ = calloc(maxGID_ - minGID_ + 1, sizeof *animRules_);
		animCache_ = calloc(maxGID_ - minGID_ + 1, sizeof *animCache_);        
#if NS_BLOCKS_AVAILABLE
        [mapInfo.tileProperties enumerateKeysAndObjectsUsingBlock:
		 ^(id key, id obj, BOOL *stop)
		 {
			 unsigned int idx = [key unsignedIntValue] - minGID_;
			 if (idx > maxGID_) return;
			 unsigned int next = [[obj objectForKey:@"Next"] intValue];
			 double delay = [[obj objectForKey:@"Delay"] doubleValue];
			 if (next && delay > 0) {
				 animRules_[idx].delay = delay;
				 animRules_[idx].next = next;
				 animCount++;
			 }
		 }];
#else
		
        for(id key in [mapInfo.tileProperties keyEnumerator])
        {
            unsigned int idx = [key unsignedIntValue] - minGID_;
            if (idx > maxGID_) continue;
            id obj = [mapInfo.tileProperties objectForKey:key];
            unsigned int next = [[obj objectForKey:@"Next"] intValue];
            double delay = [[obj objectForKey:@"Delay"] doubleValue];
            if (next && delay > 0) {
                animRules_[idx].delay = delay;
                animRules_[idx].next = next;
                animCount++;
            }
        }
#endif
		// find animation cycles and annotate
		for (int gid=minGID_; gid <= maxGID_; gid++)
		{
			struct HKTMXAnimRule *rule = animRules_ + (gid - minGID_);
			if (!rule->next)
			{
				// no animation here
				rule->last = gid;
			}
			else if (!rule->cycleTime && !rule->last)
			{
				animCount++;
				rule->cycleTime = rule->delay;
				unsigned int state = rule->next;
				while (1)
				{
					// found loop
					if (state == gid) break;
					// found endpoint
					if (!animRules_[state - minGID_].next)
					{
						rule->last = state;
						break;
					}
					// keep looking
					rule->cycleTime += animRules_[state - minGID_].delay;
					state = animRules_[state - minGID_].next;
				}
				// XXX propagate result forward through the cycle to avoid quadratic startup lag
			}
		}
		animClock_ = 0.0;
		dirtyAt_ = -INFINITY;
		if (animCount > 0)
			[self scheduleUpdate];
	}
	return self;
}

- (void) dealloc
{
	glDeleteBuffers(3, buffers_);
	[layerName_ release];
	[tileset_ release];
	[properties_ release];
	
	free(tiles_);
	free(animRules_);
	free(animCache_);
	
	[super dealloc];
}

- (void) update: (ccTime) delta
{
	animClock_ += delta;
}

#pragma mark CCTMXLayer - setup Tiles

-(void) setupTiles
{
	// Parse cocos2d properties
	[self parseInternalProperties];
	
}

#pragma mark CCTMXLayer - Properties

-(id) propertyNamed:(NSString *)propertyName 
{
	return [properties_ valueForKey:propertyName];
}

-(void) parseInternalProperties
{

}

#pragma mark CCTMXLayer - obtaining tiles/gids


// JEB - Returns the texture of gid at position as a CCSprite.
-(CCSprite*) tileAt:(CGPoint)pos
{
	NSAssert( pos.x < layerSize_.width && pos.y < layerSize_.height && pos.x >=0 && pos.y >=0, @"TMXLayer: invalid position");
	//NSAssert( tiles_ && atlasIndexArray_, @"TMXLayer: the tiles map has been released");
	
	CCSprite *tile = nil;
	uint32_t gid = [self tileGIDAt:pos];
	
	// if GID == 0, then no tile is present
	if( gid ) 
    {
        
        CGRect rect = [tileset_ rectForGID:gid];
        tile = [CCSprite spriteWithTexture:texture_ rect:rect];
		[tile setPositionInPixels: [self positionAt:pos]];
        tile.anchorPoint = CGPointZero;
        [tile setOpacity:opacity_];
	}
	return tile;
}


-(uint32_t) tileGIDAt:(CGPoint)pos
{
	NSAssert( pos.x < layerSize_.width && pos.y < layerSize_.height && pos.x >=0 && pos.y >=0, @"TMXLayer: invalid position");
//	NSAssert( tiles_ && atlasIndexArray_, @"TMXLayer: the tiles map has been released");
	
	NSInteger idx = pos.x + pos.y * layerSize_.width;
	
	// JEB - Return true GID
	return (tiles_[ idx ] & kFlippedMask);
}

#pragma mark CCTMXLayer - adding / remove tiles

-(void) setTileGID:(unsigned int)gid at:(CGPoint)pos
{
	NSAssert( pos.x < layerSize_.width && pos.y < layerSize_.height && pos.x >=0 && pos.y >=0, @"TMXLayer: invalid position");
	NSAssert1(gid == 0 || (gid >= minGID_ && gid <= maxGID_), @"invalid gid (%u) for tileset", gid);
	int idx = (int)pos.y * (int)layerSize_.width + pos.x;
	tiles_[idx] = gid;
	dirtyAt_ = -INFINITY;
}

-(void) addChild: (CCNode*)node z:(NSInteger)z tag:(NSInteger)tag
{
	NSAssert(NO, @"addChild: is not supported on CCTMXLayer. Instead use setTileGID:at:/tileGIDAt:");
}

-(void) removeTileAt:(CGPoint)pos
{
	[self setTileGID:0 at:pos];
}

#pragma mark CCTMXLayer - obtaining positions, offset

-(CGPoint) calculateLayerOffset:(CGPoint)pos
{
	CGPoint ret = CGPointZero;
	switch( layerOrientation_ ) {
		case CCTMXOrientationOrtho:
			ret = ccp( pos.x * mapTileSize_.width, -pos.y *mapTileSize_.height);
			break;
		case CCTMXOrientationIso:
			ret = ccp( (mapTileSize_.width /2) * (pos.x - pos.y),
					  (mapTileSize_.height /2 ) * (-pos.x - pos.y) );
			break;
		case CCTMXOrientationHex:
			NSAssert(CGPointEqualToPoint(pos, CGPointZero), @"offset for hexagonal map not implemented yet");
			break;
	}
	return ret;	
}

-(CGPoint) positionAt:(CGPoint)pos
{
	CGPoint ret = CGPointZero;
	switch( layerOrientation_ ) {
		case CCTMXOrientationOrtho:
			ret = [self positionForOrthoAt:pos];
			break;
	}
	return ret;
}

-(CGPoint) positionForOrthoAt:(CGPoint)pos
{
	int x = pos.x * mapTileSize_.width + 0.49f;
	int y = (layerSize_.height - pos.y - 1) * mapTileSize_.height + 0.49f;
	return ccp(x,y);
}

#pragma mark CCTMXLayer - draw

-(void) draw
{
    // JEB Set Blend mode
    BOOL newBlend = ((blendFunc_.src != CC_BLEND_SRC) || (blendFunc_.dst != CC_BLEND_DST));
	if( newBlend )
    {
		glBlendFunc( blendFunc_.src, blendFunc_.dst );
	}
	else if( opacity_ != 255 ) 
    {
		newBlend = YES;
		glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	}

    
	glBindTexture(GL_TEXTURE_2D, texture_.name);
    // TODO: Do we EVER want a tiled map to be anti-aliased?
    ccTexParams texParams = { GL_NEAREST, GL_NEAREST, GL_CLAMP_TO_EDGE, GL_CLAMP_TO_EDGE };
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, texParams.minFilter );
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, texParams.magFilter );
	glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, texParams.wrapS );
	glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, texParams.wrapT );
    
	glBindBuffer(GL_ARRAY_BUFFER, buffers_[0]);
	glVertexPointer(2, GL_FLOAT, 0, NULL);
	glBindBuffer(GL_ARRAY_BUFFER, buffers_[1]);
	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, buffers_[2]);
	CGAffineTransform trans = [self worldToNodeTransform];
	CGPoint baseTile = CGPointMake(floor(trans.tx / mapTileSize_.width),
								   floor(trans.ty / mapTileSize_.height));
	unsigned int vertexCount = 0;
	if (dirtyAt_ > animClock_ && baseTile.x == lastBaseTile_.x && baseTile.y == lastBaseTile_.y)
	{
		vertexCount = lastVertexCount_;
		goto texdone;
	}
	dirtyAt_ = INFINITY;
	struct HKTMXAnimRule *AR = animRules_ - minGID_;
	struct HKTMXAnimCacheEntry *AC = animCache_ - minGID_;
#if __IPHONE_OS_VERSION_MAX_ALLOWED
	GLfloat *texcoords = glMapBufferOES(GL_ARRAY_BUFFER, GL_WRITE_ONLY_OES);
	GLushort *indices = glMapBufferOES(GL_ELEMENT_ARRAY_BUFFER, GL_WRITE_ONLY_OES);
#elif __MAC_OS_X_VERSION_MAX_ALLOWED
    GLfloat *texcoords = glMapBuffer(GL_ARRAY_BUFFER, GL_WRITE_ONLY);
	GLushort *indices = glMapBuffer(GL_ELEMENT_ARRAY_BUFFER, GL_WRITE_ONLY);
#endif
    

    
    
	CGSize texSize = tileset_.imageSize;
	for (int y=0; y < screenGridSize_.height; y++)
	{
		if (baseTile.y + y < 0 || baseTile.y + y >= layerSize_.height)
			continue;
		for (int x=0; x < screenGridSize_.width; x++)
		{
			if (baseTile.x + x < 0 || baseTile.x + x >= layerSize_.width)
				continue;
			int tileidx = (layerSize_.height - (baseTile.y + y) - 1) * layerSize_.width
				+ baseTile.x + x;
			unsigned int tile = tiles_[tileidx];
			if (!tile) continue;
			unsigned int showtile;
            
            // *** JEB index does not included flip bits *** 
            unsigned int tile_noflags = (tile & kFlippedMask);
			if (AC[tile_noflags].validUntil <= animClock_)
			{
				if (AR[tile_noflags].last && animClock_ >= AR[tile_noflags].cycleTime)
				{
					showtile = AR[tile_noflags].last;
					AC[tile_noflags].state = showtile;
					AC[tile_noflags].validUntil = INFINITY;
				}
				else
				{
					double phase = AR[tile_noflags].last ? animClock_ : fmod(animClock_, AR[tile_noflags].cycleTime);
					showtile = tile_noflags;
					while (phase > AR[showtile].delay)
					{
						phase -= AR[showtile].delay;
						showtile = AR[showtile].next;
					}
					AC[tile_noflags].state = showtile;
					AC[tile_noflags].validUntil = animClock_ + AR[showtile].delay - phase;
				}
			}
			else
				showtile = AC[tile_noflags].state;
            
			dirtyAt_ = MIN(dirtyAt_, AC[tile_noflags].validUntil);
			int screenidx = y * screenGridSize_.width + x;
			CGRect tileTexture = [tileset_ rectForGID:(showtile & kFlippedMask)];
			tileTexture.origin.x /= texSize.width;
			tileTexture.origin.y /= texSize.height;
			tileTexture.size.width /= texSize.width;
			tileTexture.size.height /= texSize.height;
			GLfloat *texbase = texcoords + screenidx * 4 * 2;
			GLushort *idxbase = indices + vertexCount;
			int vertexbase = screenidx * 4;
			
            // ****************************************
            // * JEB Handle flipped and rotated tiles *
            // ****************************************
            float left, right, top, bottom;
            left   = tileTexture.origin.x;
            right  = left + tileTexture.size.width;
            bottom = tileTexture.origin.y;
            top    = bottom + tileTexture.size.height;
            
            
            if (tile & kFlippedVerticallyFlag)
                CC_SWAP(top,bottom);
            
            if (tile & kFlippedHorizontallyFlag)
                CC_SWAP(left,right);

            
            if (tile & kFlippedDiagonallyFlag)
            {
                texbase[0] = left;
                texbase[1] = top;
                texbase[2] = left;
                texbase[3] = bottom;
                texbase[4] = right;
                texbase[5] = top;
                texbase[6] = right;
                texbase[7] = bottom; 
            }
            else
            {
                texbase[0] = left;
                texbase[1] = top;
                texbase[2] = right;
                texbase[3] = top;
                texbase[4] = left;
                texbase[5] = bottom;
                texbase[6] = right;
                texbase[7] = bottom; 
            }
            // *****************************
			
			idxbase[0] = vertexbase;
			idxbase[1] = vertexbase + 1;
			idxbase[2] = vertexbase + 2;
			idxbase[3] = vertexbase + 3;
			idxbase[4] = vertexbase + 2;
			idxbase[5] = vertexbase + 1;
			vertexCount += 6;
		}
	}
#if __IPHONE_OS_VERSION_MAX_ALLOWED
	glUnmapBufferOES(GL_ARRAY_BUFFER);
	glUnmapBufferOES(GL_ELEMENT_ARRAY_BUFFER);
#elif __MAC_OS_X_VERSION_MAX_ALLOWED
    glUnmapBuffer(GL_ARRAY_BUFFER);
	glUnmapBuffer(GL_ELEMENT_ARRAY_BUFFER);
#endif
	lastBaseTile_ = baseTile;
	lastVertexCount_ = vertexCount;
	
texdone:

	glPushMatrix();
	glTranslatef(baseTile.x * mapTileSize_.width, baseTile.y * mapTileSize_.height, 0);
	glDisableClientState(GL_COLOR_ARRAY);
    
	// JEB set layer tint and opacity
    glColor4f(color_.r/255.0f, color_.g/255.0f, color_.b/255.0f, opacity_/255.0f);
    
	glTexCoordPointer(2, GL_FLOAT, 0, NULL);
	glDrawElements(GL_TRIANGLES, vertexCount, GL_UNSIGNED_SHORT, NULL);
	glEnableClientState(GL_COLOR_ARRAY);
	glPopMatrix();
	
	glBindBuffer(GL_ARRAY_BUFFER, 0);
	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
    
    // JEB - Restore default blend
    if( newBlend )
		glBlendFunc(CC_BLEND_SRC, CC_BLEND_DST);

   
    
}


@end

