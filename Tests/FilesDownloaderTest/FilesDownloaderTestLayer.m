/*
 * FilesDownloader Tests
 *
 * cocos2d-extensions
 * https://github.com/cocos2d/cocos2d-iphone-extensions
 *
 * Copyright (c) 2011-2012 Stepan Generalov
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

#import "FilesDownloaderTestLayer.h"
#import "iTraceurProgressBar.h"
#import "ExtensionTest.h"
SYNTHESIZE_EXTENSION_TEST(FilesDownloaderTestLayer);

@implementation FilesDownloaderTestLayer

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init])) {
		
		// Add download button
		CCLabelTTF *labelDownload = [CCLabelTTF labelWithString:@"Download" fontName:@"Marker Felt" fontSize:64];
		CCMenuItemLabel *downloadMenuItem = [CCMenuItemLabel itemWithLabel:labelDownload
																	target: self
																  selector: @selector(downloadPressed)]; 
		
		// Add Delete Button
		CCLabelTTF *labelDelete = [CCLabelTTF labelWithString:@"Delete Downloaded" fontName:@"Marker Felt" fontSize:36];
		CCMenuItemLabel *deleteMenuItem = [CCMenuItemLabel itemWithLabel:labelDelete
																  target: self
																selector: @selector(deletePressed)]; 
		
		// ask director the the window size
		CGSize size = [[CCDirector sharedDirector] winSize];
		
		// position the label on the center of the screen
		downloadMenuItem.position =  ccp( size.width /2 , size.height/2 );
		
		// create and add menu
		CCMenu *menu = [CCMenu menuWithItems: downloadMenuItem, deleteMenuItem, nil];
		[menu alignItemsVertically];
		[self addChild: menu z: 1];
		
		//Add downloaded files as children if images downloaded
		SpritesDownloadingLayer *downloader = [SpritesDownloadingLayer node];
		NSUInteger i = 0;
		CGPoint lastSpriteEnd = ccp(0,0);
		CGFloat direction = 0.5f;
		for (NSString *filename in [downloader files])
		{
			CCSprite *spriteForCurFilename  = (CCSprite *)[downloader getChildByTag: i];
			
			if ([downloader isFileDownloaded: filename] && !spriteForCurFilename )
			{
				spriteForCurFilename = [CCSprite spriteWithFile: [downloader downloadedFileWithFilename: filename]];
				spriteForCurFilename.anchorPoint = ccp(0,0);
				spriteForCurFilename.position = lastSpriteEnd;
				spriteForCurFilename.scale = MIN(spriteForCurFilename.scale, 0.33f * size.height / [spriteForCurFilename contentSize].height);
				spriteForCurFilename.scale = MIN(spriteForCurFilename.scale, 1.0f);
				
				
				// change direction of adding sprites at screen borders
				if ( (lastSpriteEnd.x > size.width) || (lastSpriteEnd.x < 0) )
				{
					direction *= -1.0f;
				}
				
				lastSpriteEnd = ccpAdd(lastSpriteEnd, ccp(direction * spriteForCurFilename.contentSize.width, 0));
				
				[self addChild:spriteForCurFilename z:0 tag: i];
			}
			
			++i;
		}
		
		[deleteMenuItem setIsEnabled:[downloader allFilesDownloaded]];
		
		
	}
	return self;
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	
	// don't forget to call "super dealloc"
	[super dealloc];
}

- (void) downloadPressed
{
	CCScene *scene = [CCScene node];
	SpritesDownloadingLayer *layer = [SpritesDownloadingLayer node];
	[scene addChild: layer];
	[[CCDirector sharedDirector] replaceScene: scene];	
}

- (void) deletePressed
{
	// purge texture cache
	[[CCDirector sharedDirector] purgeCachedData];
	
	// delete files
	SpritesDownloadingLayer *downloader = [SpritesDownloadingLayer node];
	for ( NSString *filename in [downloader files])
	{
		NSString *curPath = [downloader downloadedFileWithFilename: filename];
		[[NSFileManager defaultManager] removeItemAtPath:curPath error: NULL];
	}
	
	// reset current scene
	[[CCDirector sharedDirector] replaceScene: [ExtensionTest scene]];
}

@end

#pragma mark Downloading Layers

@implementation DownloadingLayer 

enum nodeTags
{
	kErrorLayer,
};

- (id) init
{
	if ( (self = [super init]) )
	{
		// Add background
		_background = [CCLayerGradient layerWithColor: ccc4(0x33, 0x33, 0x33, 255)  
											 fadingTo: ccc4(0, 0, 0, 255) 
										  alongVector: ccp(1,1) ];	
		[self addChild:_background];
		
		// Add "Downloading" text
		_label = [CCLabelTTF labelWithString:@"Downloading" fontName:@"Marker Felt" fontSize:64];
		[self addChild: _label];
		
		// add Close button		
		CCSprite *close = [CCSprite spriteWithFile:@"closeButton.png"];
		CCSprite *closeSelected = [CCSprite spriteWithFile:@"closeButton.png"];
		closeSelected.color = ccGRAY;
		
#if COCOS2D_VERSION >= 0x00020000
        _closeMenuItem = [CCMenuItemSprite itemWithNormalSprite: close 
												 selectedSprite: closeSelected 
														 target: self 
													   selector: @selector(closePressed) ];
#else
		_closeMenuItem = [CCMenuItemSprite itemFromNormalSprite: close 
												 selectedSprite: closeSelected 
														 target: self 
													   selector: @selector(closePressed) ];
#endif
		CCMenu *menu = [CCMenu menuWithItems: _closeMenuItem, nil];
		menu.anchorPoint = ccp(0,0);
		menu.position = ccp(0,0);
		[self addChild: menu ];
		
		// Add ProgressBar
		_bar = [iTraceurProgressBar progressBar];
		[self addChild: _bar ];		
				
		// Do not go into infinite loop if everything is downloaded.
		if ( [self allFilesDownloaded] )
		{
			// change text
			[_label setString: @"Idle"];
			
			// set 100% and do not start updating bar
			[_bar setPercentage: 100.0f];
		}
		else 
		{
			// Create Downloader
			_downloader = [FilesDownloader downloaderWithFiles: [self files] 
												withSourcePath: [self sourcePath] ];
			_downloader.delegate = self;
			[_downloader retain];
			
			// Run ProgressBar Updating Loop
			CCSequence *seq = [CCSequence actionOne:[CCDelayTime actionWithDuration: 0.1f] 
												two:[CCCallFunc actionWithTarget:self selector:@selector(updateProgress)]];
			[self runAction:[CCRepeatForever actionWithAction: seq]];
		}
		
		[self updateForScreenReshape];
	}
	
	return self;
}

- (void) dealloc
{
	[[CCTextureCache sharedTextureCache] removeUnusedTextures];
	
	[_downloader release];
	_downloader = nil;
	
	[super dealloc];
}

- (void) onEnter
{
	[super onEnter];
	
	[_downloader start];
}

- (void) onExit
{
	[self removeAllChildrenWithCleanup:YES];
	[super onExit];
	
	[_downloader cancel];
}

- (void) updateForScreenReshape
{
	CGSize winSize = [[CCDirector sharedDirector] winSize];
	
	// background fit on screen
	[_background setContentSize: winSize];
	_background.vector = ccp(1,1);
	
	// text - fit 3/4 of width + no sctretch pixel
	_label.scale = (winSize.width * 3.0f / 4.0f) / [_label contentSize].width;
	_label.scale = MIN(winSize.height / [_label contentSize].height, _label.scale);
	_label.scale = MIN (_label.scale, 1.0f);	
	_label.anchorPoint = ccp(0.5f,0.5f);
	_label.position = ccp(winSize.width / 2.0f,winSize.height / 2.0f);
	
	// position close button at top left corner
	_closeMenuItem.anchorPoint = ccp(0,1);
	_closeMenuItem.position = ccp(0, winSize.height);
	
	// position progress bar a little under center
	_bar.anchorPoint = ccp(0.5f, 0);
	_bar.position = ccp(winSize.width / 2.0f, winSize.height / 8.0f);
	
	// update error screen if it exists
	CCNode *errorScreen = [self getChildByTag:kErrorLayer];
	errorScreen.contentSize = winSize;
	[[errorScreen.children objectAtIndex:0] setPosition:ccp(winSize.width/2.0f, winSize.height/2.0f)];
}

- (void) closePressed
{	
	[[CCDirector sharedDirector] replaceScene:[ExtensionTest scene]];
}

- (void) updateProgress
{
	_bar.percentage = [_downloader totalPercentsDone];
}



// returns absolute path of file in Cached directory
- (NSString *) downloadedFileWithFilename: (NSString *) filename
{
	return [_downloader destinationPathForFileWithName: filename];
}

// returns YES if file is available in Cached directory
- (BOOL) isFileDownloaded: (NSString *) filename
{
	// get cache path
	NSString *filePath = [self downloadedFileWithFilename: filename];
	
	// test for cache
	if ( [[NSFileManager defaultManager] fileExistsAtPath:filePath] )
		return YES;
	
	return NO;
}

- (BOOL) allFilesDownloaded
{
	for (NSString *filename in [self files])
	{
		if ( ! [self isFileDownloaded: filename ] )
			return NO;
	}
	
	return YES;
}

#pragma mark FilesDownloaderDelegate Methods

- (void) downloadFinished
{
	[self closePressed];
}


- (void) downloadFailedWithError: (NSString *) errorDescription
{    
	// Present error screen.
	CCLayer *bgErrorLayer = [CCLayerColor layerWithColor: ccc4(0, 0, 0, 196)];
	CCLabelTTF *label = [CCLabelTTF labelWithString:@"Connection Error\n See console for description." fontName:@"Marker Felt" fontSize:32];
	[bgErrorLayer addChild:label];
	[bgErrorLayer runAction:[CCSequence actions:
							 [CCDelayTime actionWithDuration:3.0f],
							 [CCCallFunc actionWithTarget:self selector:@selector(closePressed)],
							 nil]];
	[self addChild:bgErrorLayer z:0 tag:kErrorLayer];
	
	// Cancel downloading.
	[_downloader cancel];
	
	// Position the error screen.
	[self updateForScreenReshape];
}

#pragma mark Virtual Methods

- (NSArray *) files
{
	NSAssert(NO,@"DownloadingLayer#files - this method should be reimplemented!");
	return nil;
}

- (NSString *) sourcePath
{
	NSAssert(NO,@"DownloadingLayer#sourcePath - this method should be reimplemented!");
	return nil;
}

@end



@implementation SpritesDownloadingLayer

- (NSArray *) files
{	
	NSArray *array = [NSArray arrayWithObjects: 
					    @"img/b1-hd.png",
						@"img/b1.png",
						@"img/b2.png",
						@"img/blocks-hd.png",
						@"img/btn-about-normal.png",
						@"img/btn-about-selected.png",
						@"img/btn-highscores-normal.png",
						@"img/btn-highscores-selected.png",
						@"img/btn-play-normal.png",
						@"img/btn-play-selected.png",
						@"img/grossini_dance_01.png",
						@"img/grossini_dance_02.png",
						@"img/grossini_dance_03.png",
						@"img/grossini_dance_04.png",
						@"img/grossini_dance_05.png",
						@"img/grossini_dance_06.png", 
						@"img/grossini_dance_07.png",
						@"img/grossini_dance_08.png",
						@"img/grossini_dance_09.png",
						@"img/grossini_dance_10.png",
						@"img/grossini_dance_11.png",
						@"img/grossini_dance_12.png",
						@"img/grossini_dance_13.png",
						@"img/grossini_dance_14.png",
						@"img/grossini-hd.png",
						@"img/grossini.png",
						@"img/grossinis_sister1.png",
						@"img/grossinis_sister2.png",
						@"img/test_blend.bmp",
						@"img/test_image.bmp", 
					  nil ];
	return array;	
}

- (NSString *) sourcePath
{
	return @"http://itraceur.ru/";
}

@end

