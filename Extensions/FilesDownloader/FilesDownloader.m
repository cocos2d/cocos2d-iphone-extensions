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

#import "FilesDownloader.h"

#ifndef MYLOG
	#ifdef DEBUG
		#define MYLOG(...) NSLog(__VA_ARGS__)
	#else
		#define MYLOG(...) do {} while (0)
	#endif
#endif

@interface FilesDownloader (InsideStatesSwitches)

- (void) startSizeChecking;
- (void) stopSizeChecking;
- (void) startDownloading;
- (void) stopDownloading;

@end


@implementation FilesDownloader

@synthesize sourcePath = _sourcePath;
@synthesize delegate = _delegate;

+ (id) downloaderWithFiles: (NSArray *) files withSourcePath: (NSString *) aSourcePath
{
	return [  [ [self alloc] initWithFiles:files withSourcePath: aSourcePath ]  autorelease  ];
}

- (id) initWithFiles: (NSArray *) files withSourcePath: (NSString *) aSourcePath
{
	if ( (self = [super init]) )
    {       
		_status = kDownloadStatusIdle;
		
        // prepare size checkers
        _filenames = [ files retain];
		self.sourcePath = aSourcePath;
        _fileSizes = [ [ NSMutableArray arrayWithCapacity: [_filenames count] ] retain];
        for ( int i = 0; i < [_filenames count]; ++i )
        {
            [ _fileSizes addObject: [NSNumber numberWithInt: 0] ];
        }
        
        
    }
    
    return self;
}


- (void) dealloc
{
	[self cancel];
	
	self.delegate = nil;
	self.sourcePath = nil;
    
    [_filenames release];
    [_fileDownloaders release];
    [_sizeCheckers release];
    [_fileSizes release];
    [super dealloc];
}

// own logics

- (void) startSizeChecking
{
    MYLOG(@"FilesDownloader#startSizeChecking");
    _status = kDownloadStatusSizeCheck;    
    
    _sizeCheckers = [NSMutableArray arrayWithCapacity: [_filenames count] ];
    
    for ( NSString *filename in _filenames )
    {
        NSString *sourcePath = [NSString stringWithFormat:@"%@%@", self.sourcePath, filename];
		MYLOG(@"FilesDownloader#startSizeChecking sourcePath = %@", sourcePath );
        [ _sizeCheckers addObject: [SingleFileDownloader fileDownloaderWithSourcePath: sourcePath
                                                                 targetFilename: filename
                                                                       delegate:self ] ];
    }
    
    [_sizeCheckers retain];
    
    _curFile = 0;
    
    [ [_sizeCheckers objectAtIndex: _curFile] startDownload];
}

- (void) stopSizeChecking
{
    MYLOG(@"FilesDownloader#stopSizeChecking");
    [_sizeCheckers release];
    _sizeCheckers = nil;
}

- (void) start
{
	[self startSizeChecking];
}

- (void) cancel
{
	if (  (_status == kDownloadStatusIdle)
		|| (_status == kDownloadStatusFinished) )
		return;
	
    MYLOG(@"FilesDownloader#cancel");
    if ( _status == kDownloadStatusSizeCheck )
    {
        MYLOG(@"status - size check");
        [ [_sizeCheckers objectAtIndex: _curFile] cancelDownload];
        [self stopSizeChecking];
    }
    
    if ( _status == kDownloadStatusDownload )
    {
        MYLOG(@"status - download");
        [ [_fileDownloaders objectAtIndex: _curFile] cancelDownload];
        [self stopDownloading];
    }
    
    _status = kDownloadStatusCancelled;
}

- (void) startDownloading
{
    MYLOG(@"FilesDownloader#startDownloading");
    _status = kDownloadStatusDownload;    
    
    _fileDownloaders = [NSMutableArray arrayWithCapacity: [_filenames count] ];
    
    for ( NSString *filename in _filenames )
    {
        NSString *sourcePath = [NSString stringWithFormat:@"%@%@", self.sourcePath, filename];
        [ _fileDownloaders addObject: [SingleFileDownloader fileDownloaderWithSourcePath: sourcePath
																	targetFilename: filename
																		  delegate:self ] ];
    }
    
    [_fileDownloaders retain];
    
    _curFile = 0;
    
    [ [_fileDownloaders objectAtIndex: _curFile] startDownload];
}

- ( void ) stopDownloading
{
    MYLOG(@"FilesDownloader#stopDownloading");
    [_fileDownloaders release];
    _fileDownloaders = nil;
}

- (void) downloadComplete
{
    [_delegate downloadFinished];
}

#pragma mark Download Info

- (NSString *) destinationPathForFileWithName: (NSString *) aFilename
{
	NSString *destPath = [ SingleFileDownloader destinationDirectoryPath ];
	
	destPath = [destPath stringByAppendingPathComponent: aFilename];
	
	return destPath;
}

- (float) totalPercentsDone
{
	float totalContentLength = (float)[self totalContentLength];
	if (totalContentLength <= 0.0f)
		return 0.0f;
	
	float percentsDone = 
		100.0f * (float)[self totalContentDownloaded] / totalContentLength;
	
	return percentsDone;
}

- (int) totalContentDownloaded
{
	if (   (_status == kDownloadStatusIdle) 
		|| (_status == kDownloadStatusCancelled)
		|| (_status == kDownloadStatusSizeCheck)  )
		return 0;
	
	int bytesReady = 0;
    
    for ( int i = 0; i < [_filenames count]; ++i )
    {
        SingleFileDownloader *downloader = nil;
        if ([_fileDownloaders count] > i)
            downloader = [_fileDownloaders objectAtIndex: i ];
        
        bytesReady += [ downloader contentDownloaded];
    }
	
	return bytesReady;	
}

- (int) totalContentLength
{
	if (   (_status == kDownloadStatusIdle) 
		 || (_status == kDownloadStatusCancelled)
		 || (_status == kDownloadStatusSizeCheck)  )
		return 0;
	
	int bytesTotal = 0;
	for ( int i = 0; i < [_filenames count]; ++i )
    {
        bytesTotal += [ [_fileSizes objectAtIndex: i ] intValue];
	}
	
	return bytesTotal;
}


// delegate methods
- (void) downloadSizeUpdated
{
    MYLOG(@"FilesDownloader#downloadSizeUpdated ");
    if ( _status == kDownloadStatusCancelled )
    {
        MYLOG(@"cancelled - return");
        return;
    }
	
    
    if ( _status == kDownloadStatusSizeCheck )
    {
        int newSize = [ [_sizeCheckers objectAtIndex: _curFile] contentLength ];
        [ _fileSizes replaceObjectAtIndex: _curFile withObject: [NSNumber numberWithInt: newSize ] ];
        
        MYLOG(@" size check mission accomplished - cancel");
        [ [_sizeCheckers objectAtIndex: _curFile] cancelDownload];
        _curFile++;
        
        
        // is it last file? 
        if ( _curFile >= [_filenames count] )
        {
            MYLOG(@"it was last - stop size check start download");
            [self stopSizeChecking];
            [self startDownloading ];
        }
        else
        {
            MYLOG(@"next sizecheck from sizeUpdated");
            [ [_sizeCheckers objectAtIndex: _curFile] startDownload];
        }
        
    }
    else if (_status == kDownloadStatusDownload)
    {
        int newSize = [ [_fileDownloaders objectAtIndex: _curFile] contentLength ];
        [ _fileSizes replaceObjectAtIndex: _curFile withObject: [NSNumber numberWithInt: newSize ] ];
    }
}

- (void) downloadFinished
{
    MYLOG(@"FilesDownloader#downloadFinished  ");
    if (_status == kDownloadStatusDownload)
    {
        MYLOG(@"while kDownloadStatusDownload");
        _curFile++;
        
        
        if ( _curFile >= [_filenames count] )
        {
            _status = kDownloadStatusFinished;
            [self downloadComplete];
        }
        else
        {
            MYLOG(@"download next");
            [ [_fileDownloaders objectAtIndex: _curFile] startDownload];
        }
    }
}

- (void) downloadFailedWithError: (NSString *) errorDescription
{    
	[self cancel];
	[_delegate downloadFailedWithError: errorDescription];
}

@end
