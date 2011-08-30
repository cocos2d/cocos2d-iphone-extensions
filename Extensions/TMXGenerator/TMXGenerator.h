/*
 * TMXGenerator.h
 * 
 * Created by Jeremy Stone on 3/19/11.
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

#define kTMXGeneratorTilesetGIDStart			@"tileGIDStart"

#pragma mark Map Setup Info Keys

#define kTMXGeneratorHeaderInfoMapWidth			@"mapWidth"
#define kTMXGeneratorHeaderInfoMapHeight		@"mapHeight"
#define kTMXGeneratorHeaderInfoMapTileWidth		@"mapTileWidth"
#define kTMXGeneratorHeaderInfoMapTileHeight	@"mapTileHeight"
#define kTMXGeneratorHeaderInfoMapOrientation	@"mapOrientation"
#define kTMXGeneratorHeaderInfoMapPath			@"mapPath"
#define kTMXGeneratorHeaderInfoMapProperties	@"mapProperties"

#pragma mark Tileset Setup Info Keys

#define kTMXGeneratorImageAtlasTileWidth		@"imageAtlasTileWidth"
#define kTMXGeneratorImageAtlasTileHeight		@"imageAtlasTileHeight"
#define kTMXGeneratorImageAtlasTileSpacing		@"imageAtlasTileSpacing"
#define kTMXGeneratorTileProperties				@"tileProperties"
#define kTMXGeneratorTileSetName				@"tileSetName"
#define kTMXGeneratorTileSetImageAtlasFilename	@"imageAtlasFilename"

#pragma mark Layer Setup Info Keys

#define kTMXGeneratorLayerName					@"layerName"
#define kTMXGeneratorLayerWidth					@"layerWidth"
#define kTMXGeneratorLayerHeight				@"layerHeight"
#define kTMXGeneratorLayerData					@"layerData"
#define kTMXGeneratorLayerRotationData			@"rotationData"
#define kTMXGeneratorLayerIsVisible				@"visible"

#pragma mark Objects Group Setup Info Keys

#define kTMXGeneratorObjectGroupName			@"objectGroupName"
#define kTMXGeneratorObjectGroupWidth			@"objectGroupWidth"
#define kTMXGeneratorObjectGroupHeight			@"objectGroupHeight"
#define kTMXGeneratorObjectGroupProperties		@"objectGroupProperties"

#pragma mark Single Object Setup Info Keys

#define kTMXGeneratorGroupObjectName			@"groupObjectName"
#define kTMXGeneratorGroupObjectType			@"groupObjectType"
#define kTMXGeneratorGroupObjectX				@"groupObjectX"
#define kTMXGeneratorGroupObjectY				@"groupObjectY"
#define kTMXGeneratorGroupObjectWidth			@"groupObjectWidth"
#define kTMXGeneratorGroupObjectHeigth			@"groupObjectHeight"
#define kTMXGeneratorGroupObjectProperties		@"groupObjectProperties"


@protocol TMXGeneratorDelegate <NSObject>

/** Returns the map's filePath to be saved to. */
- (NSString*) mapFilePath;													
 
/** Returns map setup parameters and properties. Keys listed in the "Map Setup Info Keys" section above.  
 * Number values can be strings or NSNumbers. */
- (NSDictionary*) mapAttributeSetup;				

/** Returns tileset setup information based on the name. Keys listed in 
 * "Tileset Setup Info Keys" section above. */
- (NSDictionary*) tileSetInfoForName:(NSString*)name;	

/** Returns layer setup information based on the name passed.  Keys listed in 
 * "Layer Setup Info Keys" section above. */
- (NSDictionary*) layerInfoForName:(NSString*)name;							

/** Returns the names of all the object groups as NSStrings. 
 * It's ok to return nil if don't need objects. */
- (NSArray*) objectGroupNames;

/** Returns object group information based on the name passed.  Keys listed in 
 * "Objects Group Setup Info Keys" section above.
 */
- (NSArray*) objectsGroupInfoForName:(NSString*)name;								

/** Returns all layer names as an array of NSStrings.
 * Order of array items returned here determine the heirarchy.
 */
- (NSArray*) layerNames;											

/** Returns the names of all tilesets as NSStrings. */
- (NSArray*) tileSetNames;	

/** Returns the name of the tileset (only one right now) for the layer. */
- (NSString*) tileSetNameForLayer:(NSString*)layerName;													 


/** Returns a uniquely identifying value for the key returned in the method 
 * keyForTileIdentificationForLayer: 
 * If the value is not found, the tile gets set to the minimum GID. */
- (NSString*) tilePropertyForLayer:(NSString*)layerName						
					   tileSetName:(NSString*)tileSetName					
								 X:(int)x
								 Y:(int)y;

/* Returns the key to look for in the tile properties (like SQL primary key) 
 * when assigning tiles during map creation.
 */
- (NSString*) tileIdentificationKeyForLayer:(NSString*)layerName;			

/** Returns the properties for a given tileset. */
- (NSDictionary*) propertiesForTileSetNamed:(NSString*)name;

@optional

/* Return YES here to copy the map atlas files to the map save location.  If a map
 * is not being written, this does nothing.
 * returning NO here skips copying tile atlases.  If you skip this you need to
 * make sure your atlas name is a partial path for the map to find the atlas!
 * default is YES if this is not defined.
 */
- (BOOL) copyAtlasFileForName:(NSString*)tilesetName;

/** Returns the optional properties for a given object in a given group. Keys are listed in 
 * "Single Object Setup Info Keys" section above.
 */
- (NSArray*) propertiesForObjectWithName: (NSString *) name inGroupWithName: (NSString *) groupName;

/** Returns a rotation value (no rotation if this method doesn't exist) 
 * for the specified tile name and tile. */
- (int) tileRotationForLayer:(NSString*)layerName
						   X:(int)x
						   Y:(int)y;

@end

/** @class TMXGenerator Class that generates a single TMX map with multiple layers.
 * Keep in mind this won't build a world for you, it will just create a TMX file based on data it's fed.
 */
@interface TMXGenerator : NSObject
{
	int highestGID;
	
	NSMutableDictionary* tileSets;
	NSMutableDictionary* mapAttributes;		// map setup attributes
	NSMutableArray* objectGroups;
	NSMutableArray* layers;
	NSString* path;
	NSMutableSet* copiedAtlasNames;		// store copied filenames
	
	id<TMXGeneratorDelegate> delegate_;
}

@property (nonatomic, retain) id<TMXGeneratorDelegate> delegate;

/** Call this to generate your map & save it to filepath, provided by delegate. 
 * Returns NO and an error if the map isn't generated, otherwise returns YES.
 *
 * @param error Pass NULL if you don't want error description. 
 */
- (BOOL) generateAndSaveTMXMap:(NSError**)error;

/* Alternatively, you can create the TMXMap as an XML string.
 */
- (NSString*) generateMapXML:(NSError**)error;


#pragma mark Delegate Helper Methods

/** Prepares tileset setup info with image filename, tileset name, size of tiles & spacing between them. 
 * (See TMXGeneratorTestLayer for how-to.)
 */
+ (NSDictionary*) tileSetWithImage:(NSString*)imgName 
                             named:(NSString*)name 
                             width:(int)width 
                            height:(int)height 
                       tileSpacing:(int)spacing;

/** Prepare layer setup info with given size in tiles, some additional data and visibilaty. 
 * (See TMXGeneratorTestLayer for how-to.
 */
+ (NSDictionary*) layerNamed:(NSString*)layerName width:(int)width height:(int)height data:(NSData*)binaryLayerData visible:(BOOL)isVisible;

/** Prepare single object with given name, type, position, size & properties dictionary.
 * (See TMXGeneratorTestLayer for how-to.
 */
+ (NSDictionary*) makeObjectWithName:(NSString*)name type:(NSString*)type x:(int)x y:(int)y width:(int)width height:(int)height properties:(NSDictionary*)properties;


@end


