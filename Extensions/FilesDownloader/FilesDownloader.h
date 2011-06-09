//
//  FilesDownloader.h
//  Downloader for a group of files with shared source path
//
//  iTraceur - Parkour / Freerunning Platform Game
//
//  Created by Stepan Generalov on 03.03.11.
//  Copyright 2011 Parkour Games. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FileDownloader.h"

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


@interface FilesDownloader : NSObject <FileDownloaderDelegate>
{    
    NSArray *_filenames;
	NSString *_sourcePath;
	
    NSMutableArray *_sizeCheckers, *_fileDownloaders;
    
    FilesArrayDownloaderStatus _status;    
    int _curFile;
    
    NSMutableArray *_fileSizes;
	
	id <FilesDownloaderDelegate> _delegate;
}

@property (readwrite, copy) NSString *sourcePath;
@property (readwrite, retain) id <FilesDownloaderDelegate> delegate;

#pragma mark Init
+ (id) downloaderWithFiles: (NSArray *) files withSourcePath: (NSString *) aSourcePath;
- (id) initWithFiles: (NSArray *) files withSourcePath: (NSString *) aSourcePath;

#pragma mark Start/Stop Downloading 
- (void) start;
- (void) cancel; 

#pragma mark Download Status 
- (float) totalPercentsDone;
- (int) totalContentDownloaded;
- (int) totalContentLength;

@end

