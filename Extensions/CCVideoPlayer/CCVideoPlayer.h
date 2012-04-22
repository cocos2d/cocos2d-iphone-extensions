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

#import <Foundation/Foundation.h>

@protocol CCVideoPlayerDelegate <NSObject>

- (void) movieStartsPlaying;
- (void) moviePlaybackFinished;

@end

/** @class CCVideoPlayer - Simple Video Player for Cocos2D-iPhone apps.
 *
 * @version 0.2.1
 */
@interface CCVideoPlayer : NSObject
{
}

#pragma mark Properties

/** Sets new delegate (weak ref) for playback start/stop callbacs.
 *
 * ATTENTION: You need to call this method before invoking playMovieWithFile:
 * or you will not receive movieStartsPlaying callback.
 */
+ (void)setDelegate: (id<CCVideoPlayerDelegate>) aDelegate;

/** If YES - user can't skip video by mouse/key/touch event. Default is NO. 
 */
+ (void)setNoSkip:(BOOL)value;

#pragma mark Playback

/** Start playing movie at given exact path, including extension.
 * Does nothing if file not exists.
 */
+ (void)playMovieWithPath: (NSString *) path;

/** Start playing movie with given filename.
 *
 * @param file Filename, including extension, firstly file will be searched in
 * the Caches folder (compatible with Mac & iOS Caches folders path).
 * If not found in Caches - file will be used from Resources (app bundle).
 * If not found - nothing happens (use delegate methods to pause performance critical
 * tasks).
 */
+ (void)playMovieWithFile: (NSString *) file;

/** Stop playing video if it's playing.
 */
+ (void)cancelPlaying;

/** Stop playing video if it's playing and noSkip is NO.
 */
+ (void)userCancelPlaying;

/** Returns YES if video is currently playing. Otherwise returns NO.
 */
+ (BOOL)isPlaying;

#pragma mark Updates - Platform Specific

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED

/** Updates video player view transform for newOrientation.
 *
 * Supports only landscape left or landscape right, for other orientations does nothing.
 */
+ (void)updateOrientationWithOrientation: (UIDeviceOrientation) newOrientation;

#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)

/** Reattaches movie view to the Cocos Window. (Mac only)
 *
 * Call it after changing to/from fullscreen.  
 */
+ (void)reAttachView;

#endif

@end
