/*
 * FilesDownloader Tests
 *
 * cocos2d-extensions
 * https://github.com/cocos2d/cocos2d-iphone-extensions
 *
 * Copyright (c) 2011 Stepan Generalov
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

#import "cocos2d.h"
#import "FilesDownloader.h"

@class iTraceurProgressBar;

// First screen of this test: inlcudes "Download" & "Delete Downloaded" Buttons
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

#pragma mark Downloaded Info

// returns absolute path of file in Cached directory
- (NSString *) downloadedFileWithFilename: (NSString *) filename;

// returns YES if file is available in Cached directory
- (BOOL) isFileDownloaded: (NSString *) filename;

// returns YES if all files from [self files] NSArray are downloaded
- (BOOL) allFilesDownloaded;

@end

/*
 * Concrete class, that defines files and path to download by reimplementing
 * -(NSString *)sourcePath; 
 *      and
 * - (NSArray *) files; methods.
 */
@interface SpritesDownloadingLayer : DownloadingLayer
@end

