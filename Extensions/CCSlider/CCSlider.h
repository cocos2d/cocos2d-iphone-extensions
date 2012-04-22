/*
 * CCSlider
 *
 * Cocos2D-iPhone-Extensions v0.2.1
 * https://github.com/cocos2d/cocos2d-iphone-extensions
 *
 * Copyright (c) 2011 Israel Roth 
 * http://srooltheknife.blogspot.com/
 * https://bitbucket.org/iroth_net/ccslider
 *
 * Copyright (c) 2011-2012 Stepan Generalov 
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

#if COCOS2D_VERSION >= 0x00020000
static const NSInteger kCCSliderPriority = kCCMenuHandlerPriority - 2; 
#else
static const NSInteger kCCSliderPriority = kCCMenuTouchPriority - 2; 
#endif

/** @class CCSlider Slider control for Cocos2D. 
 * Designed with SFX/Music level options in mind. 
 *
 * @version 0.2.1
 */
@interface CCSlider : CCLayer 
{  
	float value;  
	float minX;  
	float maxX;  
	
	// weak links to children
	CCMenuItem *_thumb;
	CCSprite *_bg;
    CCSprite *_progress;
    
    CGSize _progressPadding;
}  

/** Current chosen value, min is 0.0f, max is 1.0f. */
@property (nonatomic, assign) float value; 

/** Creates slider with backround image filename & thumb image filename. 
 *
 * @see initWithBackgroundFile:thumbFile: 
 */
+ (id) sliderWithBackgroundFile: (NSString *) bgFile thumbFile: (NSString *) thumbFile;

/** Creates slider with given bg sprite and menu item as a thumb. 
 *
 * @see initWithBackgroundSprite: thumbMenuItem:
 */
+(id) sliderWithBackgroundSprite: (CCSprite *) bgSprite thumbMenuItem: (CCMenuItem *) aThumb;

/** Creates slider with given bg sprite, progress color and thumb.
 * 
 * @see initWithBackgroundSprite: sliderProgressColor sliderPadding thumbMenuItem
 */
+(id) sliderWithBackgroundSprite: (CCSprite *) bgSprite sliderProgressColor:(ccColor4F) progressColor sliderPadding:(CGSize) padding thumbMenuItem: (CCMenuItem *) aThumb;

/* Creates a slider with background image filename, progress color & thumb image filename.
 *
 * @see initWithBackgroundFile: sliderProgressColor: sliderPadding: thumbFile:
 */
+ (id) sliderWithBackgroundFile:(NSString *)bgFile sliderProgressColor:(ccColor4F) progressColor sliderPadding:(CGSize) padding  thumbFile:(NSString *)thumbFile;

/** Easy init - filenames instead of CCSprite & CCMenuItem. Uses designated init inside.
 *
 * @param thumbFile Filename, that is used to create normal & selected images for
 * thumbMenuItem. Selected sprite is darker than normal sprite.
 *
 * @param bgFile Filename for background CCSprite.
 */
- (id) initWithBackgroundFile: (NSString *) bgFile thumbFile: (NSString *) thumbFile;

/** Designated init.
 *
 * @param bgSprite CCSprite, that is used as a background. It's bounding box is used
 * to determine max & min x position for a thumb menu item.
 *
 * @param aThumb MenuItem that is used as a thumb. Used without CCMenu, so CCMenuItem#activate
 * doesn't get called.
 */
-(id) initWithBackgroundSprite: (CCSprite *) bgSprite thumbMenuItem: (CCMenuItem *) aThumb;

/**
 * @param bgSprite CCSprite, that is used as a background. It's bounding box is used
 * to determine max & min x position for a thumb menu item.
 *
 * @param progressColor ccColor4F, this is used to create a sprite of a color. This will represent
 * the progress.
 *
 * @param padding CGSize, this represents the total internal padding to give for the progress. The padding
 * will be relative to the bgSprite
 *
 * @param aThumb MenuItem that is used as a thumb. Used without CCMenu, so CCMenuItem#activate
 * doesn't get called.
 */
- (id) initWithBackgroundSprite: (CCSprite *) bgSprite sliderProgressColor:(ccColor4F) progressColor sliderPadding:(CGSize) padding  thumbMenuItem: (CCMenuItem *) aThumb;

/**
 * @param bgFile Filename for background CCSprite.
 *
 * @param progressColor ccColor4F, this is used to create a sprite of a color. This will represent
 * the progress.
 *
 * @param padding CGSize, this represents the total internal padding to give for the progress. The padding
 * will be relative to the bgSprite
 *
 * @param thumbFile Filename, that is used to create normal & selected images for
 * thumbMenuItem. Selected sprite is darker than normal sprite.
 */
- (id) initWithBackgroundFile:(NSString *)bgFile sliderProgressColor:(ccColor4F) progressColor sliderPadding:(CGSize) padding  thumbFile:(NSString *)thumbFile;
@end  
