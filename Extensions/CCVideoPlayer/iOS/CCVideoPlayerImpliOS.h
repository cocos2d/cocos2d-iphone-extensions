/*
 * CCVideoPlayer
 *
 * Cocos2D-iPhone-Extensions v0.2.1
 * https://github.com/cocos2d/cocos2d-iphone-extensions
 *
 * Copyright (c) 2010-2012 Stepan Generalov
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

#import <Foundation/Foundation.h>

@class MPMoviePlayerController;
@class VideoOverlayView;



#define VIDEO_PLAYER_IMPL_SUPER_CLASS CCVideoPlayerImpliOS
@interface CCVideoPlayerImpliOS : NSObject
{
    MPMoviePlayerController *_theMovie;
    VideoOverlayView *_videoOverlayView;	
	
	BOOL _playing;
	BOOL noSkip;
	
	//weak ref
	id<CCVideoPlayerDelegate> _delegate;	
}

@property (readonly) BOOL isPlaying;
- (void)playMovieAtURL:(NSURL*)theURL;
- (void)movieFinishedCallback:(NSNotification*)aNotification;

- (void)setNoSkip:(BOOL)value;

- (void)userCancelPlaying;
- (void)cancelPlaying;

- (void)setDelegate: (id<CCVideoPlayerDelegate>) aDelegate;

- (void) updateOrientationWithOrientation: (UIDeviceOrientation) newOrientation;
- (void) updateOrientationWithOrientationNumber: (NSNumber *) newOrientationNumber;


@end

#endif
