//
//  VideoPlayer.m
//  Simple video player singleton
//  iTraceur iPhone 2D Game based on Cocos2D Game Engine
//
//  Created by Stepan Generalov on 3/11/09.
//  Copyright 2009 Stepan Generalov
//

#import "VideoPlayer.h"

#import "VideoPlayerImplMac.h"
#import "VideoPlayerImpliOS.h"


@interface VideoPlayerImpl : VIDEO_PLAYER_IMPL_SUPER_CLASS

+ (id) newImpl;

@end

@implementation VideoPlayerImpl

+ (id) newImpl
{
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
	return [ [VideoPlayerImpliOS alloc] init ];
#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
	return [ [VideoPlayerImplMac alloc] init ];
#endif
}

@end





@interface VideoPlayer (Private)

+ (void) initialize;

+ (void) playMovieWithResourceFile: (NSString *) file; //< play movie with file located in app bundle
+ (void) playMovieWithCachesFile: (NSString *) file; //< play movide with file located in /Library/Caches

+ (void) playMovieWithName: (NSString *) name Type: (NSString *) type;

@end


//===== VideoPlayer =====
@implementation VideoPlayer

static  VideoPlayerImpl *_impl = nil;


//----- initialize -----
+ (void) initialize
{
   if (self == [VideoPlayer class])
   {
	   @synchronized( self)
	   {
		   _impl = [VideoPlayerImpl newImpl];
	   }
   }
}

//----- playMovieWithName:Type: -----
+ (void) playMovieWithName: (NSString *) name Type: (NSString *) type
{
	NSURL *movieURL;
	NSBundle *bundle = [NSBundle mainBundle];
	if (bundle) 
	{
		NSString *moviePath = [bundle pathForResource: name ofType:type];
		
		if (moviePath)
		{
			movieURL = [NSURL fileURLWithPath:moviePath];
			
			// If the current thread is the main thread,than
			// this message will be processed immediately.
			[ _impl performSelectorOnMainThread: @selector(playMovieAtURL:) 
									 withObject: movieURL
								  waitUntilDone: [NSThread isMainThread]  ];
		}
	}    
}

+ (void) playMovieWithResourceFile: (NSString *) file
{
    const char *source = [ file cStringUsingEncoding: [NSString defaultCStringEncoding] ];
    size_t length = strlen( source );
    
    char *str = malloc( sizeof( char) * (length + 1)  );
    memcpy( str, source, sizeof (char) * (length + 1) );
    
    char *type = strstr( str, "."); 
    *type = 0;
    type++; //< now we have extension in type, and name in str cStrings
    
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    NSString *sName, *sType;
	
	sName = [ NSString stringWithUTF8String: str ];
    sType = [ NSString stringWithUTF8String: type];
    [self playMovieWithName: sName Type: sType];
    
	// free str, but do not free type - it is a part of str
    free( str );
    
    [pool release];    
}

#pragma mark Interface
+ (void) playMovieWithFile: (NSString *) file
{	
    //test for file in caches - play if exists
    NSString *cachesDirectoryPath =
    [ NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex: 0];
    
    NSString *cachedVideoPath = [cachesDirectoryPath stringByAppendingPathComponent: file];
    
    if ( [[NSFileManager defaultManager] fileExistsAtPath: cachedVideoPath] )
    {
        NSURL *url = [NSURL fileURLWithPath: cachedVideoPath];
        // If the current thread is the main thread,than
		// this message will be processed immediately.
		[ _impl performSelectorOnMainThread: @selector(playMovieAtURL:) 
								 withObject: url
							  waitUntilDone: [NSThread isMainThread]  ];
        return;
    }
    
    // else play from our bundle   
    [self playMovieWithResourceFile: file];
    
}

+ (void) cancelPlaying
{
	// If the current thread is the main thread,than
	// this message will be processed immediately.
	[ _impl performSelectorOnMainThread: @selector(cancelPlaying) 
							 withObject: nil
						  waitUntilDone: [NSThread isMainThread]  ];
}

+ (void) setDelegate: (id<VideoPlayerDelegate>) aDelegate
{
	// If the current thread is the main thread,than
	// this message will be processed immediately.
	[ _impl performSelectorOnMainThread: @selector(setDelegate:) 
							 withObject: aDelegate
						  waitUntilDone: [NSThread isMainThread]  ];
}

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
+ (void) updateOrientationWithOrientation: (UIDeviceOrientation) newOrientation
{
	// If the current thread is the main thread,than
	// this message will be processed immediately.
	[ _impl performSelectorOnMainThread: @selector(updateOrientationWithOrientationNumber:) 
							 withObject: [NSNumber numberWithInt: (int)newOrientation]
						  waitUntilDone: [NSThread isMainThread]  ];
}
#endif

@end



