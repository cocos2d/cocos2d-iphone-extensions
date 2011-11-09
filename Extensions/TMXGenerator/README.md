TMXGenerator
==================

TMX Generator used as a delegate to create TMX maps based on data that is fed into it.

Intended for use in situations where tile maps are to be generated on the fly rather than pre-built.
This could be used for many things including top-down world maps, shooters, and platformers.


Features
----------------------------

   * Generates TMX maps with both object and tile layers.
   * TMX files have one atlas per layer.
   * Custom property support for layers, objects and tiles.
   * Custom filenames supported.
   * TMX tile rotation support (Unofficial).
   * Universal support (iPhone + iPad + Mac)
   * TMXGenerator can be used with most any cocoa project.
   * Easy to use


Limitations
----------------------------

1. The tile flipping that was introduced in Tiled 0.7 (July 2011) is not yet supported.


Usage
----------------------------

- Set up your data class to implement the TMXGeneratorDelegate protocol.
- Create a TMXGenerator object (with alloc and init).
- Set your desired data class as it's delegate.
- call the method generateAndSaveTMXMap: to allow for the map to be generated.
- release your TMXGenerator object.


delegate methods
----------------------------

TMXGenerator uses your delegate functions to feed itself data in order to write a TMX file.
A summation of the steps the generator goes through are as follows:

   * Get the overall map width and height, tile width and height and file path.
   * Generate the atlas tileset information and atlas information.
   * Generate the layer and tile rotation information (in name array order).
   * Generate the object layer information.
   * Write the new TMX file.
   * Copy the image atlas to the same location as the TMX file.

A list of the delegate methods and optional delegate methods is below.

- (NSString*) mapFilePath;												// returns the map's filePath to be saved to.
- (NSDictionary*) mapSetupInfo;											// returns map setup parameters.  Keys listed above.  Number values can be strings or NSNumbers.
- (NSDictionary*) tileSetInfoForName:(NSString*)name;					// returns tileset setup information based on the name.  Keys listed above.
- (NSDictionary*) layerInfoForName:(NSString*)name;						// returns layer setup information based on the name passed.  Keys listed above.
- (NSArray*) objectsGroupInfoForName:(NSString*)name;					// returns object group information based on the name passed.  Keys listed above.

// The order of array items returned here determine the heirarchy of objects and layers.
- (NSArray*) layerNames;												// returns all layer names as an array of NSStrings.
- (NSArray*) tileSetNames;												// returns the names of all tilesets as NSStrings.
- (NSArray*) objectGroupNames;											// returns the names of all the object groups as NSStrings. 

- (NSString*) tileIdentificationKeyForLayer:(NSString*)layerName;		// returns the key to look for in the tile properties when assigning tiles during map creation.
- (NSString*) tileSetNameForLayer:(NSString*)layerName;            		// returns the name of the tileset (only one right now) for the layer.
- (NSString*) tilePropertyForLayer:(NSString*)layerName					// returns a uniquely identifying value for the key returned in the method keyForTileIdentificationForLayer:
                tileSetName:(NSString*)tileSetName						// If the value is not found, the tile gets set to the minimum GID.
                X:(int)x
                Y:(int)y;


optional delegate methods
----------------------------

- (NSDictionary*) propertiesForTileSetNamed:(NSString*)name;			// returns the optional properties for a given tileset.
- (NSArray*) propertiesForObjectWithName: (NSString *) name				// returns the optional properties for a given object in a given group.
               inGroupWithName: (NSString *) groupName;
- (int) tileRotationForLayer:(NSString*)layerName						// returns a rotation value for the specified tile name and tile.
               X:(int)x													// (no rotation is created if this method doesn't exist) 
               Y:(int)y;

Tip:  Look at the example code provided for an easy way to attach tiles on a layer using properties.

Dependencies
----------------------------

1. LFCGzipUtility.m / .h
2. cencode.c / .h
(or appropriate substitutes as desired)

License and Attribution
----------------------------

Copyright (c) 2011 Stone Software and Jeremy Stone. All rights reserved.
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
- The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

LFCGzipUtility.m / .h Copyright (c) 2009 Clint Harris (www.clintharris.net)
http://www.clintharris.net/2009/how-to-gzip-data-in-memory-using-objective-c/

cencode.c / .h is Copyright (c) 2006-2007, Philip Busch <broesel@studcs.uni-sb.de>, All rights reserved.
Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:
 - Redistributions of source code must retain the above copyright notice,
   this list of conditions and the following disclaimer.
 - Redistributions in binary form must reproduce the above copyright
   notice, this list of conditions and the following disclaimer in the
   documentation and/or other materials provided with the distribution.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
  POSSIBILITY OF SUCH DAMAGE.
  
