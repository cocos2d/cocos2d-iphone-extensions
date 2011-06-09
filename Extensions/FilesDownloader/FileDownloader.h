//
//  FileDownloader.h
//  iTraceur - Parkour / Freerunning Platform Game
//  
//
//  Created by Stepan Generalov on 6/18/10.
//  Copyright 2010-2011 Parkour Games. All rights reserved.
//

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
#import <Foundation/Foundation.h>

static const NSTimeInterval fileDownloaderDefaultTimeout = 15.0;

@protocol FileDownloaderDelegate <NSObject>

- (void) downloadSizeUpdated;
- (void) downloadFailedWithError: (NSString *) errorDescription;
- (void) downloadFinished;

@end

/**  FileDownloader - class that uses NSURLConnection to download file from URL, 
 that is set by concatanating source URL (i.e http://foo.com/files/ ) and file name
 (i.e. bar.png ), so URL for this file will be http://foo.com/files/bar.png 
 
 to /Library/Caches . At the first FileDownloader creates tmp file and downloads contents into it,
 only after downloading successfully ends - it renames tmp file to destination filename
 
 FileDownloader is used internally in FilesDownloader class.
 
 Probably they should be named more different to avoid confusion ;)
 **/

@interface FileDownloader : NSObject 
{
    BOOL _downloading;
    
    NSURLConnection *_connection;
    
    NSFileHandle *_fileHandle;
    
    NSString *_filename, *_sourcePath;
    
    NSObject<FileDownloaderDelegate> *_delegate;
    
    NSUInteger _bytesReceived, _bytesTotal;
}

// creation
+ (id) fileDownloaderWithSourcePath: (NSString *) sourcePath 
					 targetFilename: (NSString *) aTargetFilename 
						   delegate: (id<FileDownloaderDelegate>) aDelegate;

- (id) initWithSourcePath: (NSString *) sourcePath 
		   targetFilename: (NSString *) aTargetFilename 
				 delegate: (id<FileDownloaderDelegate>) aDelegate;

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

#endif

