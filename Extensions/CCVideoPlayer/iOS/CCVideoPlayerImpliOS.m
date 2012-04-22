/*
 * CCVideoPlayer
 *
 * Cocos2D-iPhone-Extensions v0.2.1
 * https://github.com/cocos2d/cocos2d-iphone-extensions
 *
 * Copyright (c) 2010-2012 Stepan Generalov
 * Copyright (c) 2011 Patrick Wolowicz
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

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED

#import "CCVideoPlayer.h"
#import "CCVideoPlayerImpliOS.h"
#import "MediaPlayer/MediaPlayer.h"
#import "videoOverlayView.h"
#import "cocos2d.h"


@implementation CCVideoPlayerImpliOS

@synthesize isPlaying = _playing;

- (id) init
{
    if ( (self = [super init]) )
    {
        _theMovie = nil;
    }
    return self;
}


- (void) setupViewAndPlay {
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];	
	
	// iOS 4.0 video player
	if ([_theMovie respondsToSelector: @selector(view)])
	{		
		[keyWindow addSubview: [_theMovie view]];				
		[ [_theMovie view] setHidden:  NO];		
		[ [_theMovie view] setFrame: CGRectMake( 0, 0, keyWindow.frame.size.height, keyWindow.frame.size.width)];				
		[ [_theMovie view] setCenter: keyWindow.center ];
        
		[self updateOrientationWithOrientation: (UIDeviceOrientation)[[UIApplication sharedApplication] statusBarOrientation]];
		
		// Movie playback is asynchronous, so this method returns immediately.
		[_theMovie play];
		
		
		CGSize winSize = [ [CCDirector sharedDirector] winSize];
		
		_videoOverlayView = [ [VideoOverlayView alloc] initWithFrame:CGRectMake(0, 0, winSize.height, winSize.width)];
		
		[keyWindow addSubview: _videoOverlayView ];
	}
	else // iPhone OS 2.2.1 video player
	{
		[_theMovie play];		
		
		// add videoOVerlayView
		NSArray *windows = [[UIApplication sharedApplication] windows];
		if ([windows count] > 1)
		{
			// Locate the movie player window
			UIWindow *moviePlayerWindow = [[UIApplication sharedApplication] keyWindow];
			// Add our overlay view to the movie player's subviews so it is 
			// displayed above it.
			
			CGSize winSize = [ [CCDirector sharedDirector] winSize];
			_videoOverlayView = [ [VideoOverlayView alloc] initWithFrame:CGRectMake(0, 0, winSize.height, winSize.width)];			
			[moviePlayerWindow addSubview: _videoOverlayView ];
		}
	}

}
//----- playMovieAtURL: ------
-(void)playMovieAtURL:(NSURL*)theURL
{
	_playing = YES;
	
    [ _delegate movieStartsPlaying];
	
    MPMoviePlayerController* theMovie = [[MPMoviePlayerController alloc] initWithContentURL:theURL];
    if (! theMovie)
		_playing = NO;
	
    _theMovie = theMovie;    	
	
	if ([theMovie respondsToSelector:@selector(setControlStyle:)])
	{
		[ theMovie setControlStyle: MPMovieControlStyleNone ];
	}
	else if ( [theMovie respondsToSelector:@selector(setMovieControlMode:)] )
	{
		[theMovie setMovieControlMode: MPMovieControlModeHidden]; 
	}	
	
    // Register for the playback finished notification.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(movieFinishedCallback:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:theMovie];
    
    if ([theMovie respondsToSelector:@selector(prepareToPlay)]) 
    {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(preparedToPlayerCallback:)
                                                     name:MPMediaPlaybackIsPreparedToPlayDidChangeNotification
                                                   object:theMovie];
        
        
        [theMovie prepareToPlay];
    } 
    else 
    {
        // Old iOS does not know how to prepareToPlay, so the flicker cannot be avoided
        [self setupViewAndPlay];
        
    }
}


//----- movieFinishedCallback -----
-(void)movieFinishedCallback:(NSNotification*)aNotification
{
    MPMoviePlayerController* theMovie = [aNotification object];
    
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMoviePlayerPlaybackDidFinishNotification
                                                  object:theMovie];
    
    
	
    // Release the movie instance created in playMovieAtURL:
    if ([theMovie respondsToSelector:@selector(view)])
    {
        [[theMovie view] removeFromSuperview];
    }
    [theMovie release];    
    _theMovie = nil;
	_playing = NO;
    
	[_videoOverlayView removeFromSuperview];
    [_videoOverlayView release];
	
    [ _delegate moviePlaybackFinished]; 
}


-(void)preparedToPlayerCallback:(NSNotification*)aNotification
{
    MPMoviePlayerController* theMovie = [aNotification object];
    
    if (theMovie.isPreparedToPlay) {
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:MPMediaPlaybackIsPreparedToPlayDidChangeNotification
                                                      object:theMovie];
        [self setupViewAndPlay];
    }

    
    
	
}

- (void) setNoSkip:(BOOL)value;
{
    noSkip=value;
}

- (void) userCancelPlaying
{
	if (!noSkip) {
		[self cancelPlaying];
	}
}

- (void) cancelPlaying
{
    if (_theMovie)
        [_theMovie stop];
    
    if ( _theMovie )
    {
		
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:MPMoviePlayerPlaybackDidFinishNotification
                                                      object:_theMovie];
        
        // Release the movie instance created in playMovieAtURL:
        if ([_theMovie respondsToSelector:@selector(view)])
        {
            [[_theMovie view] removeFromSuperview];
        }
        [_theMovie release];   
        _theMovie = nil;
        
		[_videoOverlayView removeFromSuperview];
        [_videoOverlayView release];
        
        [ _delegate moviePlaybackFinished];
    }
}

- (void)setDelegate: (id<CCVideoPlayerDelegate>) aDelegate
{
	_delegate = aDelegate;
}

- (void) updateOrientationWithOrientation: (UIDeviceOrientation) newOrientation
{
	if (!_theMovie)
		return;
	
	if (![_theMovie respondsToSelector:@selector(view)])
		return;
	
	UIDeviceOrientation orientation = newOrientation;
	
	if (orientation == UIDeviceOrientationLandscapeRight)		
		[ [_theMovie view] setTransform: CGAffineTransformMakeRotation(-M_PI_2) ];
	
	if (orientation == UIDeviceOrientationLandscapeLeft)
		[ [_theMovie view] setTransform: CGAffineTransformMakeRotation(M_PI_2) ];
}

- (void) updateOrientationWithOrientationNumber: (NSNumber *) newOrientationNumber
{
	UIDeviceOrientation orientation = (UIDeviceOrientation)[newOrientationNumber intValue];
	
	[self updateOrientationWithOrientation: orientation];
}


@end

#endif

