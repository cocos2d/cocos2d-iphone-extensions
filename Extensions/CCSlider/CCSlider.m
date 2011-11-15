/*
 * CCSlider
 *
 * cocos2d-extensions
 * https://github.com/cocos2d/cocos2d-iphone-extensions
 *
 * Copyright (c) 2011 Israel Roth 
 * http://srooltheknife.blogspot.com/
 * https://bitbucket.org/iroth_net/ccslider
 *
 * Copyright (c) 2011 Stepan Generalov 
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copi*es or substantial portions of the Software.
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

#import "CCSlider.h"

#define kThumbTag 1

@interface CCSlider(Private)
- (void) scaleProgressIndicator;
- (CCSprite *)spriteWithColor:(ccColor4F)bgColor textureSize:(CGSize)textureSize;
@end

@implementation CCSlider


+ (id) sliderWithBackgroundFile: (NSString *) bgFile thumbFile: (NSString *) thumbFile
{
	return [  [ [self alloc]  initWithBackgroundFile: bgFile 
										   thumbFile: thumbFile ]  autorelease  ];
}

+(id) sliderWithBackgroundSprite: (CCSprite *) bgSprite thumbMenuItem: (CCMenuItem *) aThumb
{
	return [  [ [self alloc]  initWithBackgroundSprite: bgSprite 
										 thumbMenuItem: aThumb ]  autorelease  ];
}

+ (id) sliderWithBackgroundFile:(NSString *)bgFile sliderProgressColor:(ccColor4F) progressColor sliderPadding:(CGSize) padding  thumbFile:(NSString *)thumbFile
{
    return [[self alloc] initWithBackgroundFile:bgFile sliderProgressColor:progressColor sliderPadding:padding thumbFile:thumbFile];
}

+(id) sliderWithBackgroundSprite: (CCSprite *) bgSprite sliderProgressColor:(ccColor4F) progressColor sliderPadding:(CGSize) padding thumbMenuItem: (CCMenuItem *) aThumb
{
    return [[[self alloc] initWithBackgroundSprite:bgSprite sliderProgressColor:progressColor sliderPadding:padding thumbMenuItem:aThumb] autorelease];
}

- (id) initWithBackgroundFile:(NSString *)bgFile sliderProgressColor:(ccColor4F) progressColor sliderPadding:(CGSize) padding  thumbFile:(NSString *)thumbFile
{
    self = [self initWithBackgroundFile:bgFile thumbFile:thumbFile];
    if(self) {
        _progressPadding = padding;
        _progress = [self spriteWithColor:progressColor textureSize:CGSizeMake(_thumb.position.x, _bg.contentSize.height - padding.height)];
        _progress.position = CGPointMake(_thumb.position.x/2 + padding.width/2, _bg.position.y);
        [self addChild:_progress z:1];
    }
    return self;
}

// Easy init
- (id) initWithBackgroundFile: (NSString *) bgFile thumbFile: (NSString *) thumbFile
{	
	// Prepare background for slider.
	CCSprite *bg = [CCSprite spriteWithFile:bgFile];
	
	// Prepare thumb (menuItem) for slider.
	CCSprite *thumbNormal = [CCSprite spriteWithFile: thumbFile];
	CCSprite *thumbSelected = [CCSprite spriteWithFile: thumbFile];
	thumbSelected.color = ccGRAY;		
	CCMenuItemSprite *thumbMenuItem = [CCMenuItemSprite itemFromNormalSprite:thumbNormal selectedSprite: thumbSelected];
	
	// Continue with designated init on successfull prepare.
	if (thumbNormal && thumbSelected && thumbMenuItem && bg)
	{
		self = [self initWithBackgroundSprite:bg thumbMenuItem: thumbMenuItem];
		return self;
	}
		
	// Don't leak & return nil on fail.
	[self release];
	return nil;
}

- (CCSprite *)spriteWithColor:(ccColor4F)bgColor textureSize:(CGSize)textureSize {
    
    CCRenderTexture *rt = [CCRenderTexture renderTextureWithWidth:textureSize.width height:textureSize.height];
    [rt beginWithClear:bgColor.r g:bgColor.g b:bgColor.b a:bgColor.a];
    [rt end];
    return [CCSprite spriteWithTexture:rt.sprite.texture];
}

- (id) initWithBackgroundSprite: (CCSprite *) bgSprite sliderProgressColor:(ccColor4F) progressColor sliderPadding:(CGSize) padding  thumbMenuItem: (CCMenuItem *) aThumb   
{
    self = [self initWithBackgroundSprite:bgSprite thumbMenuItem:aThumb];
    
    if (self) {
        _progressPadding = padding;
        _progress = [self spriteWithColor:progressColor textureSize:CGSizeMake(_thumb.position.x, _bg.contentSize.height - padding.height)];
        _progress.position = CGPointMake(_thumb.position.x/2 + padding.width/2, _bg.position.y);
        [self addChild:_progress z:1];
    }
    return self;
}

// Designated init
-(id) initWithBackgroundSprite: (CCSprite *) bgSprite thumbMenuItem: (CCMenuItem *) aThumb  
{  
	if ((self = [super init]))  
	{   
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
		self.isTouchEnabled = YES;  
#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
		self.isMouseEnabled = YES;
#endif
		value = 0;  
		
		// add the slider background  
		_bg = bgSprite; 
		[self setContentSize:[_bg contentSize]];  
		self.isRelativeAnchorPoint = YES;
		self.anchorPoint = ccp(0.5f,0.5f);
		
		_bg.position = CGPointMake([_bg contentSize].width / 2, [_bg contentSize].height / 2);  
		[self addChild:_bg];  
		
		// add the slider thumb  
		CGSize thumbSize;  
		_thumb = aThumb;
		thumbSize = [_thumb contentSize];  
		minX = thumbSize.width / 2;  
		maxX = [self contentSize].width - thumbSize.width / 2;  
		_thumb.position = CGPointMake(minX, [self contentSize].height / 2);
        [_thumb setTag:kThumbTag];
		[self addChild:_thumb z:2];  
	}  
	return self;  
}  

@dynamic value;

- (float) value
{
	return value;
}

- (void) setValue:(float) newValue
{
	// set new value with sentinel
    if (newValue < 0) 
		newValue = 0;
	
    if (newValue > 1.0) 
		newValue = 1.0;
	
    value = newValue;
	
	// update thumb position for new value
    CCMenuItem *thumb = _thumb;
    CGPoint pos = thumb.position;
    pos.x = minX + newValue * (maxX - minX);
    thumb.position = pos;
    [self scaleProgressIndicator];
}

- (void) scaleProgressIndicator
{
    if (_progress) {
        if (_progress) {
            CCSprite *progress = _progress;
            CGSize size = progress.contentSize;
            size.width = _thumb.position.x;
            progress.scaleX = size.width/progress.contentSize.width;
            progress.position = CGPointMake(_thumb.position.x/2 + _progressPadding.width/2, _bg.position.y);
        }
    }
}

- (NSInteger) mouseDelegatePriority
{
	return kCCSliderPriority;
}

-(BOOL) isTouchForMe:(CGPoint)touchLocation
{
    if (CGRectContainsPoint([_bg boundingBox], touchLocation))
		return YES;
	
	// Enlarge touch zone, when bg is thinner than thumb.
	if (CGRectContainsPoint([_thumb boundingBox], touchLocation))
		return YES;
	
	return NO;
}

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
-(void) registerWithTouchDispatcher
{
    [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:kCCSliderPriority swallowsTouches:YES];
}

-(CGPoint) locationFromTouch:(UITouch *)touch
{
    CGPoint touchLocation = [touch locationInView: [touch view]];
	touchLocation = [[CCDirector sharedDirector] convertToGL: touchLocation];
    touchLocation = [self convertToNodeSpace: touchLocation];
    return touchLocation;
}

-(BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint location = [self locationFromTouch:touch];
    bool isTouchHandled = [self isTouchForMe:location];
    if (isTouchHandled) {
        CCMenuItem *thumb = _thumb;
        [thumb selected];
		
        CGPoint pos = thumb.position;
        pos.x = location.x;
        thumb.position = pos;
    }
    return isTouchHandled; // YES for events I handle
}

-(void) ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint location = [self locationFromTouch:touch];
    if ((location.x < minX) || (location.x > maxX))
        return;
	
    CCSprite *thumb = (CCSprite *)[self getChildByTag:kThumbTag];
    CGPoint pos = thumb.position;
    pos.x = location.x;
    thumb.position = pos;
    [self scaleProgressIndicator];
}

-(void) ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    CCSprite *thumb = (CCSprite *)[self getChildByTag:kThumbTag];
    [_thumb unselected];
    self.value = (thumb.position.x - minX) / (maxX - minX);
}
#endif

#ifdef __MAC_OS_X_VERSION_MAX_ALLOWED

-(CGPoint) locationFromEvent:(NSEvent *) theEvent
{
	CGPoint location = [[CCDirector sharedDirector] convertEventToGL:theEvent];
	return [self convertToNodeSpace: location];
}

-(BOOL) ccMouseDown:(NSEvent*)event
{
	CGPoint location = [self locationFromEvent: event];
    BOOL isTouchHandled = [self isTouchForMe:location];
    
	if (isTouchHandled) 
	{
        CCMenuItem *thumb = _thumb;
        [thumb selected];
		
        CGPoint pos = thumb.position;
        pos.x = location.x;
        thumb.position = pos;
    }
    return isTouchHandled; // YES for events I handle
}

-(BOOL) ccMouseDragged:(NSEvent*)event
{
	CGPoint location = [self locationFromEvent: event];
	
	if (! _thumb.isSelected)
		return NO;
    
	if ((location.x < minX) || (location.x > maxX))
        return NO;
	
    CGPoint pos = _thumb.position;
    pos.x = MIN(location.x, maxX);
	pos.x = MAX(pos.x, minX );
    _thumb.position = pos;
	
	return YES;
}

-(BOOL) ccMouseUp:(NSEvent*)event
{
	[_thumb unselected];
    self.value = (_thumb.position.x - minX) / (maxX - minX);
    
	
	return [_thumb isSelected];
}

#endif

@end
