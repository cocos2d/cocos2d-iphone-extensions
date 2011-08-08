/*
 * FilesDownloader
 *
 * cocos2d-extensions
 * https://github.com/cocos2d/cocos2d-iphone-extensions
 *
 * Copyright (c) 2010-2011 Stepan Generalov
 * Copyright (c) 2011 Todd Lee
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

#import "SingleFileDownloader.h"

#ifndef MYLOG
	#ifdef DEBUG
		#define MYLOG(...) NSLog(__VA_ARGS__)
	#else
		#define MYLOG(...) do {} while (0)
	#endif
#endif

@interface SingleFileDownloader (Private)

+ (NSString *) destinationDirectoryPath;
+ (NSString *) tmpSuffix;
+ (NSFileHandle *) newFileWithName: (NSString *) newFilename; 
+ (BOOL)checkTargetDirectory:(NSString *)targetPath;

@end

@interface SingleFileDownloader (NSURLConnectionDelegate) 

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;
- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response;
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;
- (void)connectionDidFinishLoading:(NSURLConnection *)connection;
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;

@end

@implementation SingleFileDownloader

+ (NSString *) tmpSuffix
{
    return @".tmp";
}

+ (NSString *) tmpPathWithFilename: (NSString *) aFilename
{
    return [NSString stringWithFormat:@"%@/%@%@", [self destinationDirectoryPath], aFilename, [self tmpSuffix]];
}

+ (NSString *) destinationDirectoryPath
{
	NSString *path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	
#ifdef __MAC_OS_X_VERSION_MAX_ALLOWED
	NSString *appBundleID = [[NSBundle mainBundle] bundleIdentifier];
	path = [path stringByAppendingPathComponent:appBundleID];
#endif
	
	return path;
}

+ (BOOL)checkTargetDirectory:(NSString *)targetPath
{
    BOOL isDirectory = NO;
    
    NSString *targetDirectory = [targetPath stringByDeletingLastPathComponent];
    NSArray *pathComponents = [targetDirectory pathComponents];
    NSString *currentTargetPath = @"";
    
    for (int i = 0; i < [pathComponents count]; i++)
    {
        currentTargetPath = [currentTargetPath stringByAppendingPathComponent:[pathComponents objectAtIndex:i]];
        BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:currentTargetPath isDirectory:&isDirectory];

        if (exists && isDirectory)
        {
            MYLOG(@"SingleFileDownloader#newFileWithName: %@ exists", currentTargetPath);
        }
        else
        {
            MYLOG(@"SingleFileDownloader#newFileWithName: %@ not exists! Creating...", currentTargetPath);
            if ([[NSFileManager defaultManager] createDirectoryAtPath:currentTargetPath withIntermediateDirectories: YES attributes: nil error: NULL])
            {
                MYLOG(@"SingleFileDownloader#newFileWithName: SUCCESSFULL creating directory %@!", currentTargetPath);
            }
            else
            {
                MYLOG(@"SingleFileDownloader#newFileWithName: creating directory %@ FAILED!", currentTargetPath);
                return FALSE;
            }
        }
    }
    
    return TRUE;
}

+ (NSFileHandle *) newFileWithName: (NSString *) newFilename
{
    //creating caches directory if needed
    NSString *cachesDirectoryPath = [self destinationDirectoryPath];

    // creating target directory if needed
    if (![self checkTargetDirectory:[cachesDirectoryPath stringByAppendingPathComponent:newFilename]])
    {
        return nil;
    }
    
    NSString * myFilePath = [self tmpPathWithFilename: newFilename];
    
    if ( [ [NSFileManager defaultManager] createFileAtPath:myFilePath contents:nil attributes:nil] )
    {
        MYLOG(@"SingleFileDownloader#newFileWithName: %@ created OK!", myFilePath);
    }
    else
    {
        MYLOG(@"SingleFileDownloader#newFileWithName: %@ creation FAILED!", myFilePath);
        return nil;
    }
    
    return [[NSFileHandle fileHandleForWritingAtPath: myFilePath] retain];
}


+ (id) fileDownloaderWithSourcePath: (NSString *) sourcePath targetFilename: (NSString *) aTargetFilename delegate: (id<SingleFileDownloaderDelegate>) aDelegate
{
    return [ [ [self alloc] initWithSourcePath:sourcePath targetFilename: aTargetFilename delegate:aDelegate ] autorelease ];
}

- (id) initWithSourcePath: (NSString *) sourcePath targetFilename: (NSString *) aTargetFilename delegate: (id<SingleFileDownloaderDelegate>) aDelegate
{
    if ( (self = [super init]) )
    {
        _connection = nil;
        _filename = [ aTargetFilename retain];
        _sourcePath = [ sourcePath retain];
        
        _bytesReceived = 0;
        _bytesTotal = 0;
        _delegate = aDelegate;
        
        _fileHandle = [[self class] newFileWithName: _filename];
    }
    
    return self;
}

- (void) dealloc
{
    MYLOG(@"SingleFileDownloader#dealloc");
    
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
        MYLOG(@"SingleFileDownloader#startDownload file already downloaded and exist at %@", [self targetPath]);
        [self cancelDownload];
        
        NSDictionary *dict = [ [NSFileManager defaultManager] attributesOfItemAtPath: [self targetPath] error: NULL];
        if (dict)
        {
            NSNumber *sizeOfFile = [dict valueForKey: NSFileSize];
            _bytesTotal = _bytesReceived = [sizeOfFile intValue];
            [_delegate downloadSizeUpdated];
        }
        else
            MYLOG(@"SingleFileDownloader#startDownload exists, but no dict for attr!");
        
        [ _delegate downloadFinished ];
        return;
    }
    
    MYLOG(@"SingleFileDownloader#startDownload URL= %@", _sourcePath);
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
        MYLOG(@"SingleFileDownloader#startDownload download failed with error: %@!", err);
        [_delegate downloadFailedWithError: err];
        return;
    }
    
    _downloading = YES;
    MYLOG(@"SingleFileDownloader#startDownload download started!");
    
}

- (void) cancelDownload
{
    MYLOG(@"SingleFileDownloader#cancelDownload %@ download cancelled",_sourcePath);
    
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
    NSString *tmpPath = [NSString stringWithFormat:@"%@/%@%@", [[self class] destinationDirectoryPath], _filename, [[self class] tmpSuffix]];
    [[NSFileManager defaultManager] removeItemAtPath: tmpPath error: NULL];
    
    _connection = nil;
    [_fileHandle release];
    _fileHandle = nil;    
    //_bytesReceived = 0;    
}

- (NSString *) targetPath
{
    return [NSString stringWithFormat:@"%@/%@", [[self class] destinationDirectoryPath], _filename];
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
    
    MYLOG(@"SingleFileDownloader#connection: %@ didReceiveResponse: %@", connection,  response);
}


- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response
{
    MYLOG(@"SingleFileDownloader#connection: %@ willSendRequest: %@ redirectResponse: %@", connection, request,  response );
    
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
    
    MYLOG(@"SingleFileDownloader#connection:%@ did receive data: [%d] Progress: %d/%d", 
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
    NSString *tmpPath = [ [self class] tmpPathWithFilename: _filename ];
    NSString *destPath = [self targetPath];
    if ( ! [ [NSFileManager defaultManager] moveItemAtPath: tmpPath toPath: destPath error: &error] )
    {
        [self cancelDownload];
        
        MYLOG(@"SingleFileDownloader#connectionDidFinishLoading FAILED: %@ Description: %@", 
              [error localizedFailureReason], [error localizedDescription] );
        
        NSString *errString = [error localizedDescription];
        
        [ _delegate downloadFailedWithError: errString ];
        
        return;
    }
    
    [self cancelDownload];
    [_delegate downloadFinished];
    MYLOG(@"SingleFileDownloader#connectionDidFinishLoading: %@", connection );
}


- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    MYLOG(@"SingleFileDownloader#connectionDidFailWithError: %@ Description: %@", [error localizedFailureReason], [error localizedDescription]);
    
    [self cancelDownload];
    
    //[_delegate downloadFailedWithError: [error localizedDescription] ];
    [_delegate downloadFailedWithError: @"Connection Error" ];
}



@end
