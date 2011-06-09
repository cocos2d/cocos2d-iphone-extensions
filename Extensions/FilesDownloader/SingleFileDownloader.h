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

- (void) downloadSizeUpdated;
- (void) downloadFailedWithError: (NSString *) errorDescription;
- (void) downloadFinished;

@end

/**  SingleFileDownloader - class that uses NSURLConnection to download file from URL, 
 that is set by concatanating source URL (i.e http://foo.com/files/ ) and file name
 (i.e. bar.png ), so URL for this file will be http://foo.com/files/bar.png 
 
 to /Library/Caches . At the first SingleFileDownloader creates tmp file and downloads contents into it,
 only after downloading successfully ends - it renames tmp file to destination filename
 
 SingleFileDownloader is used internally in FilesDownloader class.
 
 Probably they should be named more different to avoid confusion ;)
 **/

@interface SingleFileDownloader : NSObject 
{
    BOOL _downloading;
    
    NSURLConnection *_connection;
    
    NSFileHandle *_fileHandle;
    
    NSString *_filename, *_sourcePath;
    
    NSObject<SingleFileDownloaderDelegate> *_delegate;
    
    NSUInteger _bytesReceived, _bytesTotal;
}

// creation
+ (id) fileDownloaderWithSourcePath: (NSString *) sourcePath 
					 targetFilename: (NSString *) aTargetFilename 
						   delegate: (id<SingleFileDownloaderDelegate>) aDelegate;

- (id) initWithSourcePath: (NSString *) sourcePath 
		   targetFilename: (NSString *) aTargetFilename 
				 delegate: (id<SingleFileDownloaderDelegate>) aDelegate;

// download controls
- (void) startDownload;
- (void) cancelDownload;

// /Library/Caches/targetFileName
- (NSString *) targetPath;

// content size in bytes downloaded
- (NSUInteger) contentDownloaded;

// content size in bytes total
- (NSUInteger) contentLength;

@end

