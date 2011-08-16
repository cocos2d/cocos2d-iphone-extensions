/* Copyright (c) 2011 Robert Blackwood
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
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

//V1.0

#import "cocos2d.h"

#define kCCPanZoomControllerHistoryCount 12

typedef struct {
    float time;
    CGPoint pt;
} CCPanZoomTimePointStamp;

@interface CCPanZoomController : NSObject<CCTargetedTouchDelegate>
{	
    //properties
    CCNode  *_node;
	
    //bounding rect
    CGPoint _tr;
    CGPoint _bl;
    
    //window rect
    CGPoint _winTr;
    CGPoint _winBl;
    
    BOOL    _centerOnPinch;
    float   _zoomRate;
    float   _zoomInLimit;
    float   _zoomOutLimit;
    float   _swipeVelocityMultiplier;
    float   _scrollDuration;
    float   _scrollDamping;
    float   _pinchDamping;
    
    //internals    
    float	_time;
    int     _timePointStampCounter;
    CCPanZoomTimePointStamp _history[kCCPanZoomControllerHistoryCount];
	
	
	//touches
	CGPoint _firstTouch;
	float   _firstLength;
	float   _oldScale;
	
    //keep track of touches in order
	NSMutableArray *_touches;
    
    //keep around swipe action to get rid of it if needed
    CCAction *_lastScrollAction;
}

@property (readwrite, assign) CGRect    boundingRect;   /*!< The max bounds you want to scroll */
@property (readwrite, assign) CGRect    windowRect;     /*!< The boundary of your window, by default uses winSize of CCDirector */
@property (readwrite, assign) BOOL      centerOnPinch;  /*!< Should zoom center on pinch pts, default is YES */
@property (readwrite, assign) float     zoomRate;       /*!< How much to zoom based on movement of pinch */
@property (readwrite, assign) float     zoomInLimit;    /*!< The smallest zoom level */
@property (readwrite, assign) float     zoomOutLimit;   /*!< The hightest zoom level */
@property (readwrite, assign) float     swipeVelocityMultiplier; /*!< The velocity factor of the swipe's scroll action */
@property (readwrite, assign) float     scrollDuration; /*!< Duration of the scroll action after a swipe */
@property (readwrite, assign) float     scrollDamping;  /*!< When scrolling around, this will dampen the movement */
@property (readwrite, assign) float     pinchDamping;   /*!< When zooming, this will dampen the zoom */

/*! Create a new control with the node you want to scroll/zoom */
+ (id) controllerWithNode:(CCNode*)node;

/*! Initialize a new control with the node you want to scroll/zoom */
- (id) initWithNode:(CCNode*)node;

/*! Scroll to position */
- (void) updatePosition:(CGPoint)pos;

/*! Center point in window view */
- (void) centerOnPoint:(CGPoint)pt;

/*! Enable touches, convenience method really */
- (void) enableWithTouchPriority:(int)priority swallowsTouches:(BOOL)swallowsTouches;

/*! Disable touches */
- (void) disable;

@end