/*
 * CCLayerPanZoom Tests
 *
 * cocos2d-extensions
 * https://github.com/cocos2d/cocos2d-iphone-extensions
 *
 * Copyright (c) 2011 Alexey Lang
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


#import "cocos2d.h"

#define kCCLayerPanZoomMultitouchGesturesDetectionDelay 0.05


typedef enum
{
    /** Standard mode: swipe to scroll */
    kCCLayerPanZoomModeSheet,
    /** Frame mode (i.e. drag inside objects): hold finger at edge of the screen to the sroll in this direction */
    kCCLayerPanZoomModeFrame  
} CCLayerPanZoomMode;


@class CCLayerPanZoom;
@protocol CCLayerPanZoomClickDelegate <NSObject>

/** Sent to delegate each time, when click event was obtained. 
 * Only for mode = kCCLayerPanZoomModeSheet. */
- (void) layerPanZoom: (CCLayerPanZoom *) sender 
       clickedAtPoint: (CGPoint) aPoint
             tapCount: (NSUInteger) tapCount;

/** Sent to delegate each time, when touch position was updated. */
- (void) layerPanZoom: (CCLayerPanZoom *) sender 
 touchPositionUpdated: (CGPoint) newPos;

/** Sent to delegate each time, when users drags finger on the screen.
 * This means that click event is not possible with that touch from now.
 */
- (void) layerPanZoom: (CCLayerPanZoom *) sender touchMoveBeganAtPosition: (CGPoint) aPoint;

@end


/** @class CCLayerPanZoom Class that represents the layer that can be scroll and zoom 
 * with one or two fingers */
@interface CCLayerPanZoom : CCLayer 
{
    float _maxScale;
    float _minScale;
	NSMutableArray *_touches;
	CGRect _panBoundsRect;
	CGFloat _touchDistance;
	CGFloat _maxTouchDistanceToClick;
	id<CCLayerPanZoomClickDelegate> _delegate;
    
    CCLayerPanZoomMode _mode;
    CGFloat _minSpeed;
    CGFloat _maxSpeed;
    CGFloat _topFrameMargin;
    CGFloat _bottomFrameMargin;
    CGFloat _leftFrameMargin;
    CGFloat _rightFrameMargin;
    
    CGPoint _prevSingleTouchPositionInLayer; 
    //< previous position in layer if single touch was moved.
    
    // Time when single touch has began, used to wait for possible multitouch 
    // gestures before reacting to single touch.
    NSTimeInterval _singleTouchTimestamp; 
    
    // Flag used to call touchMoveBeganAtPosition: only once for each single touch event.
    BOOL _touchMoveBegan;
    
    ccTime _ruberEdgesTime;
    CGFloat _ruberEdgesMargin;
    BOOL _ruberEdgeRecovering;
    BOOL _ruberEdgeUserZooming;
}

/** The maximum scale level
 * Default is 3.0f */
@property (readwrite, assign) float maxScale;    

/** The minimum scale level
 * Default is 0.5f */
@property (readwrite, assign) float minScale;   

/** The rectangle that use to determine the restriction of scrolling
 * Set value CGRectNull to disable restriction
 * Default is CGRectNull */
@property (readwrite, assign) CGRect panBoundsRect;   

/** The max distance that touch can be drag before click
 * If distance is greater then click will not be sent to delegate 
 * Default is 15.0f */
@property (readwrite, assign) CGFloat maxTouchDistanceToClick;   

/** Delegate for layerPanZoom:clickedAtPoint: callbacks. */
@property (readwrite, retain) id<CCLayerPanZoomClickDelegate> delegate;

/** Switch mode for pan & zoom
 * Defult is kCCLayerPanZoomModeSheet */
@property (readwrite, assign) CCLayerPanZoomMode mode;

/** Maximum speed for autosrolling in frame mode
 * Default is 1000.0f */
@property (readwrite, assign) CGFloat maxSpeed;

/** Minimum speed for autosrolling in frame mode
 * Default is 100.0f */
@property (readwrite, assign) CGFloat minSpeed;

/** Distance from top edge of panBoundingRect
 * for define top autoscrolling zone in frame mode
 * Default is 100.0f */
@property (readwrite, assign) CGFloat topFrameMargin;

/** Distance from bottom edge of panBoundingRect
 * for define bottom autoscrolling zone in frame mode
 * Default is 100.0f */
@property (readwrite, assign) CGFloat bottomFrameMargin;

/** Distance from left edge of panBoundingRect
 * for define left autoscrolling zone in frame mode
 * Default is 100.0f */
@property (readwrite, assign) CGFloat leftFrameMargin;

/** Distance from right edge of panBoundingRect
 * for define right autoscrolling zone in frame mode
 * Default is 100.0f */
@property (readwrite, assign) CGFloat rightFrameMargin;

/** Delay for recover layer position and scale 
 * for rubber edges
 * Default is 0.0f */
@property (readwrite, assign) ccTime ruberEdgesTime;

/** Distance from panBoundRect on which possible stretch layer 
 * for rubber edges
 * Default is 0.0f */
@property (readwrite, assign) CGFloat ruberEdgesMargin;

@end