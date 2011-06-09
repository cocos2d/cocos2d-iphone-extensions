//
//  DownloadingLayer.h
//  FilesDownloader
//
//  Created by Stepan Generalov on 05.03.11.
//  Copyright 2011 Parkour Games. All rights reserved.
//

#import "cocos2d.h"
#import "FilesDownloader.h"

@class iTraceurProgressBar;

@interface FilesDownloaderTestLayer : CCLayer
{
}

@end


#pragma mark Downloading Layers

/* 
 * Abstract super class for downloading screens.
 */
@interface DownloadingLayer : CCNode <FilesDownloaderDelegate>
{
	// weak refs to children
	CCLayerGradient *_background;
	CCLabelTTF *_label;
	CCMenuItemSprite *_closeMenuItem;
	iTraceurProgressBar *_bar;
	
	// retained refs
	FilesDownloader *_downloader;
	UIAlertView *_alertView;
}

#pragma mark Node Look
// Updates Children position/scale for curWinSize
- (void) updateForScreenReshape;

#pragma mark Virtual Methods
// returns source path from which files will be downloaded
// Must be reimplemented in Subclasses
- (NSString *) sourcePath;

// returns array of NSStrings, containing filenames to download from source path
// (i.e. { @"foo.png", @"bar.png"}
// Must be reimplemented in Subclasses
- (NSArray *) files;

#pragma mark Downloaded Checks
// returns absolute path of file in Cached directory
- (NSString *) downloadedFileWithFilename: (NSString *) filename;

// returns YES if file is available in Cached directory
- (BOOL) isFileDownloaded: (NSString *) filename;

// returns YES if all files from [self files] NSArray are downloaded
- (BOOL) allFilesDownloaded;

@end


@interface SpritesDownloadingLayer : DownloadingLayer
@end

