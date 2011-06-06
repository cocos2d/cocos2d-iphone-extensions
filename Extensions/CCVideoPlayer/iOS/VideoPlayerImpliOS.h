//
//  VideoPlayerImpliOS.h
//  iTraceur for Mac
//
//  Created by Stepan Generalov on 04.01.11.
//  Copyright 2011 Parkour Games. All rights reserved.
//


#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED

#import <Foundation/Foundation.h>

@class MPMoviePlayerController;
@class VideoOverlayView;



#define VIDEO_PLAYER_IMPL_SUPER_CLASS VideoPlayerImpliOS
@interface VideoPlayerImpliOS : NSObject
{
    MPMoviePlayerController *_theMovie;
    VideoOverlayView *_videoOverlayView;	
	
	BOOL _playing;
	
	//weak ref
	id<VideoPlayerDelegate> _delegate;	
}

@property (readonly) BOOL isPlaying;
- (void)playMovieAtURL:(NSURL*)theURL;
- (void)movieFinishedCallback:(NSNotification*)aNotification;

- (void)cancelPlaying;

- (void)setDelegate: (id<VideoPlayerDelegate>) aDelegate;

- (void) updateOrientationWithOrientation: (UIDeviceOrientation) newOrientation;
- (void) updateOrientationWithOrientationNumber: (NSNumber *) newOrientationNumber;


@end

#endif
