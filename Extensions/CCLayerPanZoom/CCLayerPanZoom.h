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

typedef enum
{
    kCCLayerPanZoomModeScrollScale,
    kCCLayerPanZoomModeDragDrop    
} CCLayerPanZoomMode;


@class CCLayerPanZoom;
@protocol CCLayerPanZoomClickDelegate <NSObject>

/** Send to delegate each time, when click event was obtained. */
- (void) layerPanZoom: (CCLayerPanZoom *) sender 
	   clickedAtPoint: (CGPoint) aPoint;

@end


/** @class CCLayerPanZoom Class that represents the layer that can be scroll and zoom 
 with one or two fingers */
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
}

/** The maximum scale level */
@property (readwrite, assign) float maxScale;    

/** The minimum scale level */
@property (readwrite, assign) float minScale;   

/** The rectangle that use to determine the restriction of scrolling
 * Set value CGRectNull to disable restriction */
@property (readwrite, assign) CGRect panBoundsRect;   

/** The max distance that touch can be drag before click
 * If distance is greater then click will not be sent to delegate 
 * Default is 15.0f */
@property (readwrite, assign) CGFloat maxTouchDistanceToClick;   

/** Delegate for layerPanZoom:clickedAtPoint: callbacks. */
@property (readwrite, retain) id<CCLayerPanZoomClickDelegate> delegate;

@property (readwrite, assign) CCLayerPanZoomMode mode;

@end
