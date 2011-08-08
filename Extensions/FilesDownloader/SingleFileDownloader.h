/*
 * FilesDownloader
 *
 * cocos2d-extensions
 * https://github.com/cocos2d/cocos2d-iphone-extensions
 *
 * Copyright (c) 2010-2011 Stepan Generalov
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

static const NSTimeInterval fileDownloaderDefaultTimeout = 15.0;

@protocol SingleFileDownloaderDelegate <NSObject>

/** Called each time, when total content size changes.*/
- (void) downloadSizeUpdated;
- (void) downloadFailedWithError: (NSString *) errorDescription;
- (void) downloadFinished;

@end

/** @class SingleFileDownloader Class that uses NSURLConnection to download file from URL, 
 * that is set by concatanating source URL (i.e http://foo.com/files/ ) and file name
 * (i.e. bar.png ), so URL for this file will be http://foo.com/files/bar.png ,
 * to APP_SANDBOX/Library/Caches on iOS or to ~/Library/Caches/APP_BUNDLE_ID on Mac (According to
 * Mac OS X File System Guide ).
 *
 * At the first SingleFileDownloader creates tmp file and downloads contents into it,
 * only after downloading successfully ends - it renames tmp file to destination filename.
 *
 * SingleFileDownloader is used internally in FilesDownloader class, if you're downloading many 
 * files at time from one place - you don't need to use SingleFileDownloader - use FilesDownloader instead.
 */
@interface SingleFileDownloader : NSObject 
{
    BOOL _downloading;
    
    NSURLConnection *_connection;
    
    NSFileHandle *_fileHandle;
    
    NSString *_filename, *_sourcePath;
    
    NSObject<SingleFileDownloaderDelegate> *_delegate;
    
    NSUInteger _bytesReceived, _bytesTotal;
}

#pragma mark Init / Creation

/** Creates SingleFileDownloader with given source path, target filename & delegate.
 * 
 * @param sourcePath - path from which to download file, without filename. I.e.
 * @"http://foo.com/files/"
 *
 * @param aTargetFilename subPath that will be added to sourcePath to determine
 * full URL for a file. I.e. @"foo/bar/file.txt"
 *
 * @param aDelegate delegate for SingleFileDownloader status callbacks.
 */
+ (id) fileDownloaderWithSourcePath: (NSString *) sourcePath 
					 targetFilename: (NSString *) aTargetFilename 
						   delegate: (id<SingleFileDownloaderDelegate>) aDelegate;

/** Inits SingleFileDownloader with given source path, target filename & delegate.
 * 
 * @param sourcePath - path from which to download file, without filename. I.e.
 * @"http://foo.com/files/"
 *
 * @param aTargetFilename subPath that will be added to sourcePath to determine
 * full URL for a file. I.e. @"foo/bar/file.txt"
 *
 * @param aDelegate delegate for SingleFileDownloader status callbacks.
 */
- (id) initWithSourcePath: (NSString *) sourcePath 
		   targetFilename: (NSString *) aTargetFilename 
				 delegate: (id<SingleFileDownloaderDelegate>) aDelegate;

#pragma mark Download Controls

/** Starts downloading. */
- (void) startDownload;

/** Stops downloading. */
- (void) cancelDownload;

#pragma mark Download Info

/** Returns shared destination path part for all files
 * ~/Library/Caches/APP_BUNDLE_ID on Mac &
 * APP_SANDBOX/Library/Caches on iOS.
 */
+ (NSString *) destinationDirectoryPath;

/** Returns full target path for file, that will be downloaded
 * I.e. @"APP_SANDBOX/Library/Caches/fooBar.png" (iOS)
 * or @"~/Library/Caches/APP_BUNDLE_ID" (Mac)
 */
- (NSString *) targetPath;

/** Returns downloaded content size in bytes. */
- (NSUInteger) contentDownloaded;

/** Returns total content size in bytes. This value can be changed each.
 * Use this method in downloadSizeUpdated delegate method to determine new 
 * expected content size. */
- (NSUInteger) contentLength;

@end

