CCVideoPlayer
==================

Simple Video Player for Cocos2D apps.


Features
-------------

   * Universal support (iPhone + iPad + Mac)
   * Play / Cancel (by tap or key pressed on mac)
   * Plays file from Caches or Resources directory (if found) - compatible with FilesDownloader
   * Plays file from path
   * Easy to use


Limitations
---------------

1. iOS: Supported orientations are only Landscape Left & Landscape Right ( Issue #13 )


Usage
-----------------------

CustomVideoView.nib is  needed only for Mac. (Probably it's possible to remove it and load view with code only. Issue #14 )

To link it you need MediaPlayer.framework for iOS & QTKit for Mac

To play videofile foo.mp4 simply use:

	// First tries to find file in NSCachesDirectory and play it from there
	// Second tries to find file in resources directory
	// Does nothing if file not found 
    [CCVideoPlayer playMovieWithFile: @"bait.mp4"];

CCVideoPlayer ignores orientation change by itself, but you can manually change it's orientation:

    UIDeviceOrientation deviceOrientation = (UIDeviceOrientation)toInterfaceOrientation;
    [CCVideoPlayer updateOrientationWithOrientation: deviceOrientation ];

Playing video uses a lot of resources, so it's recommended to stop gpu render and other heavy tasks, while playing video.
You can do this by setting a CCVideoPlayer delegate:

    [CCVideoPlayer setDelegate: self]; 

Your delegate class should conform to CCVideoPlayerDelegate and implement these methods:

    - (void) moviePlaybackFinished
    {
        [[CCDirector sharedDirector] startAnimation];
    }

    - (void) movieStartsPlaying
    {
        [[CCDirector sharedDirector] stopAnimation];
    }

It's a weak ref, so don't forget to set CCVideoPlayer's delegate to nil in delegates dealloc or before.

Dependencies
----------------------------

1. QTKit.framework for Mac
2. MediaPlayer.framework for iOS


Supported Video Formats
----------------------------

Supported formats are the same as for MPMediaPlayer for iOS and QTMovie for Mac.
mp4 bundled with tests is compatible with both Mac & iOS


