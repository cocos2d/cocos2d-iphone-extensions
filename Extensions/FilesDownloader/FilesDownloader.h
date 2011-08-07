/*
 * FilesDownloader
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

#import <Foundation/Foundation.h>
#import "SingleFileDownloader.h"

typedef enum
{
	kDownloadStatusIdle,
    kDownloadStatusSizeCheck,
    kDownloadStatusDownload,
    kDownloadStatusCancelled,
	kDownloadStatusFinished,
} FilesArrayDownloaderStatus;


@protocol FilesDownloaderDelegate

- (void) downloadFailedWithError: (NSString *) errorDescription;
- (void) downloadFinished;

@end


/** @class FilesDownloader Simple files downloader. Uses multiple SingleFileDownloader's
 for size checking before & downloading.
 */
@interface FilesDownloader : NSObject <SingleFileDownloaderDelegate>
{    
    NSArray *_filenames;
	NSString *_sourcePath;
	
    NSMutableArray *_sizeCheckers, *_fileDownloaders;
    
    FilesArrayDownloaderStatus _status;    
    int _curFile;
    
    NSMutableArray *_fileSizes;
	
	id <FilesDownloaderDelegate> _delegate;
}

/** Path from which to download file, without filename. I.e.
 * @"http://foo.com/files/"
 */
@property (readwrite, copy) NSString *sourcePath;

/** Delegate for download status callbacks. */
@property (readwrite, retain) id <FilesDownloaderDelegate> delegate;

#pragma mark Init

/** Creates FilesDownloader with given source path & filenames.
 *
 * @param files Array of NSStrings of filenames. Each string is subPath that will 
 * be added to aSourcePath to determine full URL for single file. I.e. @"foo/bar/file.txt"
 * 
 * @param aSourcePath - path to download from (shared part for all files) I.e. @"http://foo.com/files/"
 *
 */
+ (id) downloaderWithFiles: (NSArray *) files withSourcePath: (NSString *) aSourcePath;

/** Inits FilesDownloader with given source path & filenames.
 *
 * @param files Array of NSStrings of filenames. Each string is subPath that will 
 * be added to aSourcePath to determine full URL for single file. I.e. @"foo/bar/file.txt"
 * 
 * @param aSourcePath - path to download from (shared part for all files) I.e. @"http://foo.com/files/"
 *
 */
- (id) initWithFiles: (NSArray *) files withSourcePath: (NSString *) aSourcePath;

#pragma mark Start/Stop Downloading 

/** Starts downloading. */
- (void) start;

/** Cancels downloading. */
- (void) cancel; 

#pragma mark Download Info

/** Returns destination path which aFilename should be downloaded to.
 * Doesn't check does aFilename exist in _filenames array.
 */
- (NSString *) destinationPathForFileWithName: (NSString *) aFilename;

/** Returns download progress completion in percents. */
- (float) totalPercentsDone;

/** Returns total bytes count downloaded. */
- (int) totalContentDownloaded;

/** Returns total size for all content in bytes. */
- (int) totalContentLength;

@end

