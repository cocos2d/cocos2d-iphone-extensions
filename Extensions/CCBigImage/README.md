CCBigImage 
==================

CCBigImage is Node, that allows [iTraceur](http://itunes.apple.com/us/app/itraceur-parkour-freerunning/id374163905?mt=8 "AppStore Link") to have levels large as 16000x2500 points.
In short words it just loads/unloads tiles dynamically in other thread, keeping in memory only tiles that user can see right now.

Files
-------------
* CCBigImage.h & CCBigImage.m
* CCTextureCache+CCBigImageExtensions.h & CCTextureCache+CCBigImageExtensions.m - needed to load textures from the same thread all the time 
(Has more performance than CCTextureCache's addImageAsync:target:selector: cause uses only one thread, that created only ones, instead of creating thread each texture load)
* Tile-Cutter is inlcuded as compiled commandLine tool in prepareResoures folder. Source code of Tile-Cutter is available here: https://github.com/psineur/Tile-Cutter

CCMenuAdvancedTest features
-------------
* iPad/ iPhone / Retina project
* Slide node with finger.

Using CCBigImage
--------------------------------------------------
See comments in CCBigImage.h, code in CCBigImageTestLayer for more info.
Use CC_BIGIMAGE_DEBUG_DRAW to enable drawing rect around CCBigImage content.

Performance
--------------------------------------------------
If you have some performance issues - using pvr.ccz for tiles instead of png may really help you a lot.
After compressing textures you will not need to change plist - just init it with "pvr.ccz" extension.
Like this:

     CCBigImage *node = [ CCBigImage nodeWithTilesFile:@"bigImage.plist" tilesExtension: @"pvr.ccz" tilesZ: 0  ];
     
If you have texturePacker - tilesCompress.sh will help you to compress all tiles automatically.
Just execute it in folder with png's and it will compress them all to RGBA4444 pvr.ccz format

CCMenuAdvancedTest uses pvr.ccz now. Cause with png it was too long to build.
Compressed tiles in 8e67e772174ba57536380fc7bebf19cb88194f9a
Replaced all 'png' with 'pvr.ccz' in 072fdd4d621902c22f13254e81bb850f90405450

Quality
--------------------------------------------------
As mentioned above, it is recommended to use pvr.ccz instead of png.   
However, if you use png - you may notice some quality issues, due to RGBA4444   
set as default texture format in UnloadableSpriteNode#load:

    [CCTexture2D setDefaultAlphaPixelFormat:kTexture2DPixelFormat_RGBA4444];
	
You may comment this line, but it's recommended to keep it, to save memory.   
But the best will be to use pvr.ccz (you can use RGBA4444 format with dithering -   
that will give you best quality while saving memory).