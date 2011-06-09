//
//  FileDownloader.m
//  iTraceur - Parkour / Freerunning Platform Game
//  
//
//  Created by Stepan Generalov on 6/18/10.
//  Copyright 2010-2011 Parkour Games. All rights reserved.
//

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
	//< NSURLConnection is available in Mac OS X, so FileDownloader should work on Mac
	//< but i didn't tested it yet.

#import "FileDownloader.h"

#ifndef MYLOG
	#ifdef DEBUG
		#define MYLOG(...) NSLog(__VA_ARGS__)
	#else
		#define MYLOG(...) do {} while (0)
	#endif
#endif

@interface FileDownloader (Private)

+ (NSString *) destinationDirectoryPath;
+ (NSString *) tmpSuffix;
+ (NSFileHandle *) newFileWithName: (NSString *) newFilename; 

@end

@interface FileDownloader (NSURLConnectionDelegate) 

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;
- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response;
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;
- (void)connectionDidFinishLoading:(NSURLConnection *)connection;
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;

@end

@implementation FileDownloader

+ (NSString *) tmpSuffix
{
    return @".tmp";
}

+ (NSString *) tmpPathWithFilename: (NSString *) aFilename
{
    return [NSString stringWithFormat:@"%@/%@%@", [FileDownloader destinationDirectoryPath], aFilename, [self tmpSuffix]];
}

+ (NSString *) destinationDirectoryPath
{
    NSString *cachesDirectoryPath =
        [ NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex: 0];
    
    return cachesDirectoryPath;
}

+ (NSFileHandle *) newFileWithName: (NSString *) newFilename
{    
    //creating caches directory if needed
    NSString *cachesDirectoryPath = [FileDownloader destinationDirectoryPath];
    
    BOOL isDirectory = NO;
    BOOL exists = [ [NSFileManager defaultManager] fileExistsAtPath:cachesDirectoryPath isDirectory:&isDirectory];
    
    if ( exists && isDirectory )
    {
        MYLOG(@"FileDownloader#newFileWithName: %@ exists",cachesDirectoryPath);
    }
    else
    {
        MYLOG(@"FileDownloader#newFileWithName: %@ not exists! Creating...",cachesDirectoryPath );
        if ( [ [NSFileManager defaultManager] createDirectoryAtPath:cachesDirectoryPath withIntermediateDirectories: YES attributes: nil error: NULL] ) 
        {
            MYLOG(@"FileDownloader#newFileWithName: SUCCESSFULL creating caches directory!");
        }
        else
        {
            MYLOG(@"FileDownloader#newFileWithName: creating caches directory FAILED!");
            return nil;
        }
    }
    
    NSString * myFilePath = [FileDownloader tmpPathWithFilename: newFilename];
    
    if ( [ [NSFileManager defaultManager] createFileAtPath:myFilePath contents:nil attributes:nil] )
    {
        MYLOG(@"FileDownloader#newFileWithName: %@ created OK!", myFilePath);
    }
    else
    {
        MYLOG(@"FileDownloader#newFileWithName: %@ creation FAILED!", myFilePath);
        return nil;
    }
    
    return [NSFileHandle fileHandleForWritingAtPath: myFilePath];
}


+ (id) fileDownloaderWithSourcePath: (NSString *) sourcePath targetFilename: (NSString *) aTargetFilename delegate: (id<FileDownloaderDelegate>) aDelegate
{
    return [ [ [self alloc] initWithSourcePath:sourcePath targetFilename: aTargetFilename delegate:aDelegate ] autorelease ];
}

- (id) initWithSourcePath: (NSString *) sourcePath targetFilename: (NSString *) aTargetFilename delegate: (id<FileDownloaderDelegate>) aDelegate
{
    if ( (self = [super init]) )
    {
        _connection = nil;
        _filename = [ aTargetFilename retain];
        _sourcePath = [ sourcePath retain];
        
        _bytesReceived = 0;
        _bytesTotal = 0;
        _delegate = aDelegate;
        
        _fileHandle = [ [FileDownloader newFileWithName: _filename] retain];
    }
    
    return self;
}

- (void) dealloc
{
    MYLOG(@"FileDownloader#dealloc");
    
    if ( _downloading )
        [self cancelDownload];
    
    [_connection release];
    [_filename release];
    [_sourcePath release];
    [_fileHandle release];
    
    [super dealloc];
}

- (void) startDownload
{
    if ( [ [NSFileManager defaultManager] fileExistsAtPath: [self targetPath] ] )
    {
        MYLOG(@"FileDownloader#startDownload file already downloaded and exist at %@", [self targetPath]);
        [self cancelDownload];
        
        NSDictionary *dict = [ [NSFileManager defaultManager] attributesOfItemAtPath: [self targetPath] error: NULL];
        if (dict)
        {
            NSNumber *sizeOfFile = [dict valueForKey: NSFileSize];
            _bytesTotal = _bytesReceived = [sizeOfFile intValue];
            [_delegate downloadSizeUpdated];
        }
        else
            MYLOG(@"FileDownloader#startDownload exists, but no dict for attr!");
        
        [ _delegate downloadFinished ];
        return;
    }
    
    MYLOG(@"FileDownloader#startDownload URL=", _sourcePath);
    NSURLRequest *request = [NSURLRequest requestWithURL: [NSURL URLWithString: _sourcePath]
                                             cachePolicy: NSURLRequestUseProtocolCachePolicy
                                         timeoutInterval: fileDownloaderDefaultTimeout];
    
    _connection = [ [NSURLConnection connectionWithRequest: request delegate: self] retain];
    
    NSString *err = nil;
    
    if ( !_connection )
    {
        err = @"Can't open connection";
    } else if ( !_fileHandle)
        {
            err = @"Can't create file";
        }
    
    if ( err )
    {
        MYLOG(@"FileDownloader#startDownload download failed with error: %@!", err);
        [_delegate downloadFailedWithError: err];
        return;
    }
    
    _downloading = YES;
    MYLOG(@"FileDownloader#startDownload download started!");
    
}

- (void) cancelDownload
{
    MYLOG(@"FileDownloader#cancelDownload %@ download cancelled",_sourcePath);
    
    _downloading = NO;
    
    // close connection and file
    if (_connection)
    {
        [_connection cancel];
        [_connection release];
    }
    
    if ( _fileHandle )
        [_fileHandle closeFile];
    
    // delete tmp file
    NSString *tmpPath = [NSString stringWithFormat:@"%@/%@%@", [FileDownloader destinationDirectoryPath], _filename, [FileDownloader tmpSuffix]];
    [[NSFileManager defaultManager] removeItemAtPath: tmpPath error: NULL];
    
    _connection = nil;
    [_fileHandle release];
    _fileHandle = nil;    
    //_bytesReceived = 0;    
}

- (NSString *) targetPath
{
    return [NSString stringWithFormat:@"%@/%@", [FileDownloader destinationDirectoryPath], _filename];
}

- (NSUInteger) contentDownloaded
{
    return _bytesReceived;
}

- (NSUInteger) contentLength
{
    return _bytesTotal;
}


#pragma mark NSURLConnection Delegate Methods
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    _bytesReceived = 0;
    _bytesTotal = [response expectedContentLength];
    
    //test for free space
    NSDictionary *fsAttributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[self targetPath] error: NULL];
    unsigned long long freeSpace = [ [fsAttributes objectForKey:NSFileSystemFreeSize] unsignedLongLongValue ];
    
    if ( freeSpace && ( freeSpace <= _bytesTotal )  )
    {
        MYLOG(@"Not Enough Space detected!");
        NSString *err = @"Not enough space";
        [_delegate downloadFailedWithError: err];
        [self cancelDownload];
        return;
    }
    
    
    [_delegate downloadSizeUpdated];
    
    MYLOG(@"FileDownloader#connection: %@ didReceiveResponse: %@", connection,  response);
}


- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response
{
    MYLOG(@"FileDownloader#connection: %@ willSendRequest: %@ redirectResponse: %@", connection, request,  response );
    
    if (response)
    {
        MYLOG(@"Redirect Detected!");
        NSString *err = @"Unhandled redirect";
        [_delegate downloadFailedWithError: err ];
        [self cancelDownload];
        return nil;
    }
    
    return request;
}


- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    _bytesReceived += [data length];
    
    MYLOG(@"FileDownloader#connection:%@ did receive data: [%d] Progress: %d/%d", 
          connection,
          (int)[data length],
          (int)_bytesReceived, 
          (int)_bytesTotal     );
    

    
    [_fileHandle seekToEndOfFile];
    [_fileHandle writeData: data];
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSError *error = nil;
    
    [_fileHandle closeFile];
    
    //rename ready file
    NSString *tmpPath = [ FileDownloader tmpPathWithFilename: _filename ];
    NSString *destPath = [self targetPath];
    if ( ! [ [NSFileManager defaultManager] moveItemAtPath: tmpPath toPath: destPath error: &error] )
    {
        [self cancelDownload];
        
        MYLOG(@"FileDownloader#connectionDidFinishLoading FAILED: %@ Description: %@", 
              [error localizedFailureReason], [error localizedDescription] );
        
        NSString *errString = [error localizedDescription];
        
        [ _delegate downloadFailedWithError: errString ];
        
        return;
    }
    
    [self cancelDownload];
    [_delegate downloadFinished];
    MYLOG(@"FileDownloader#connectionDidFinishLoading: %@", connection );
}


- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    MYLOG(@"FileDownloader#connectionDidFailWithError: %@ Description: %@", [error localizedFailureReason], [error localizedDescription]);
    
    [self cancelDownload];
    
    //[_delegate downloadFailedWithError: [error localizedDescription] ];
    [_delegate downloadFailedWithError: @"Connection Error" ];
}



@end

#endif
