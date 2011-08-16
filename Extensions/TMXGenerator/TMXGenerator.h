//
//  TMXGenerator.h
//  AutoGenTest
//
//  Created by Jeremy on 3/19/11.
//
/*
 Copyright (c) 2011 Stone Software, Jeremy Stone. All rights reserved.
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#import <Foundation/Foundation.h>

#define kTilesetGIDStart			@"tileGIDStart"

// map setup
#define kHeaderInfoMapWidth			@"mapWidth"
#define kHeaderInfoMapHeight		@"mapHeight"
#define kHeaderInfoMapTileWidth		@"mapTileWidth"
#define kHeaderInfoMapTileHeight	@"mapTileHeight"
#define kHeaderInfoMapOrientation	@"mapOrientation"
#define kHeaderInfoMapPath			@"mapPath"

// tileset information
#define kImageAtlasTileWidth		@"imageAtlasTileWidth"
#define kImageAtlasTileHeight		@"imageAtlasTileHeight"
#define kImageAtlasTileSpacing		@"imageAtlasTileSpacing"

#define kTileProperties				@"tileProperties"
#define kTileSetName				@"tileSetName"
#define kTileSetImageAtlasFilename	@"imageAtlasFilename"

#define kLayerName					@"layerName"
#define kLayerWidth					@"layerWidth"
#define kLayerHeight				@"layerHeight"
#define kLayerData					@"layerData"
#define kLayerRotationData			@"rotationData"
#define kLayerIsVisible				@"visible"

#define kObjectGroupName			@"objectGroupName"
#define kObjectGroupWidth			@"objectGroupWidth"
#define kObjectGroupHeight			@"objectGroupHeight"
#define kObjectGroupProperties		@"objectGroupProperties"

#define kGroupObjectName			@"groupObjectName"
#define kGroupObjectType			@"groupObjectType"
#define kGroupObjectX				@"groupObjectX"
#define kGroupObjectY				@"groupObjectY"
#define kGroupObjectWidth			@"groupObjectWidth"
#define kGroupObjectHeigth			@"groupObjectHeight"
#define kGroupObjectProperties		@"groupObjectProperties"


@protocol TMXGeneratorDelegate <NSObject>

- (NSString*) mapFilePath;													// returns the map's filePath to be saved to.

- (NSDictionary*) mapSetupInfo;												// returns map setup parameters.  Keys listed above.  Number values can be strings or NSNumbers.
- (NSDictionary*) tileSetInfoForName:(NSString*)name;						// returns tileset setup information based on the name.  Keys listed above.
- (NSDictionary*) layerInfoForName:(NSString*)name;							// returns layer setup information based on the name passed.  Keys listed above.
- (NSArray*) objectInfoForName:(NSString*)name;								// returns object group information based on the name passed.  Keys listed above.

// Order of array items returned here determine the heirarchy.
- (NSArray*) layerNames;													// returns all layer names as an array of NSStrings.
- (NSArray*) tileSetNames;													// returns the names of all tilesets as NSStrings.
- (NSArray*) objectGroupNames;												// returns the names of all the object groups as NSStrings.  return nil 


- (NSString*) tileIdentificationKeyForLayer:(NSString*)layerName;			// returns the key to look for in the tile properties when assigning tiles during map creation.
- (NSString*) tileSetNameForLayer:(NSString*)layerName;						// returns the name of the tileset (only one right now) for the layer.
- (NSString*) tilePropertyForLayer:(NSString*)layerName						// returns a uniquely identifying value for the key returned in the method keyForTileIdentificationForLayer:
					   tileSetName:(NSString*)tileSetName					// If the value is not found, the tile gets set to the minimum GID.
								 X:(int)x
								 Y:(int)y;

@optional
- (NSDictionary*) propertiesForTileSetNamed:(NSString*)name;				// returns the optional properties for a given tileset.
- (NSArray*) propertiesForObjectGroupNamed:(NSString*)name objectName:(NSString*)objName; // returns the optional properties for a given object in a given group.

- (int) tileRotationForLayer:(NSString*)layerName							// returns a rotation value (no rotation if this method doesn't exist) for the specified tile name and tile.
						   X:(int)x
						   Y:(int)y;

@end


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


- (void) saveSampleMapWithPath:(NSString*)inPath;


// helper methods
+ (NSDictionary*) tileSetWithImage:(NSString*)imgName named:(NSString*)name width:(int)width height:(int)height tileSpacing:(int)spacing;
+ (NSDictionary*) layerNamed:(NSString*)layerName width:(int)width height:(int)height data:(NSData*)binaryLayerData visible:(BOOL)isVisible;
+ (NSDictionary*) makeGroupObjectWithName:(NSString*)name type:(NSString*)type x:(int)x y:(int)y width:(int)width height:(int)height properties:(NSDictionary*)properties;

// call this to generate your maps.
- (BOOL) generateTMXMap:(NSError**)error;						// returns NO and an error if the map isn't generated, otherwise returns YES.

@end


