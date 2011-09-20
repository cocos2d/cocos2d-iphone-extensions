/*
 * CCVideoPlayer Tests
 *
 * cocos2d-extensions
 * https://github.com/cocos2d/cocos2d-iphone-extensions
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


// Import the interfaces
#import "CCSliderTestLayer.h"
#import "CCSlider.h"
#import "ExtensionTest.h"

SYNTHESIZE_EXTENSION_TEST(CCSliderTestLayer)

enum nodeTags
{
	kLabelTag,
	kSliderTag,
};

@implementation CCSliderTestLayer

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init])) {
		
		// Add label
		CCLabelTTF *label = [CCLabelTTF labelWithString:@"Move the slider thumb!" fontName:@"Marker Felt" fontSize:32];
		[self addChild: label z: 0 tag: kLabelTag];
		
		CCSlider *slider = [CCSlider sliderWithBackgroundFile:@"sliderBG.png" thumbFile:@"sliderThumb.png"];
		
		/*
		 //Note: if you want to customize normal/selected images of the thumb, or 
		 // use your own subclass on CCSprite for background - you can use
		 // [ CCSlider sliderWithBackgroundSprite: thumbMenuItem: ] 
		 // like this:
		 
		 // Prepare thumb (menuItem) for slider.
		 CCSprite *thumbNormal = [CCSprite spriteWithFile:@"sliderThumb.png"];
		 CCSprite *thumbSelected = [CCSprite spriteWithFile:@"sliderThumb.png"];
		 thumbSelected.color = ccGRAY;		
		 CCMenuItemSprite *thumbMenuItem = [CCMenuItemSprite itemFromNormalSprite:thumbNormal selectedSprite: thumbSelected];
		 
		 // Easy Create & Add Slider.
		 CCSlider *slider = [CCSlider sliderWithBackgroundSprite: [CCSprite spriteWithFile:@"sliderBG.png"]
		 thumbMenuItem: thumbMenuItem  ];		 
		 */
		
        [slider addObserver:self forKeyPath:@"value" options: NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld  context: nil];
        
		[self addChild:slider z: 0 tag: kSliderTag];
        
		
		[self updateForScreenReshape];
	
	}
	return self;
}

- (void) updateForScreenReshape
{
	CGSize s = [CCDirector sharedDirector].winSize;
	
	CCNode *label = [self getChildByTag: kLabelTag];
	label.anchorPoint = ccp(0.5f, -1 );
	
	CCNode *slider = [self getChildByTag: kSliderTag];
	slider.anchorPoint = ccp(0.5f, 1 );
	
	label.position = slider.position = ccp(s.width/2.0f, s.height/2.0f );
	
}
  
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([object isKindOfClass: [CCSlider class] ] && [keyPath isEqualToString: @"value"])
    {
        NSNumber *valueObject = [change objectForKey: NSKeyValueChangeNewKey];
        float value = [valueObject floatValue];
        
        NSNumber *prevValueObject = [change objectForKey: NSKeyValueChangeOldKey];
        float prevValue = [prevValueObject floatValue];
    
        // Get label.
        CCLabelTTF *label = (CCLabelTTF *)[self getChildByTag: kLabelTag];
        
        // Change value of label.
        label.string = [NSString stringWithFormat:@"Value = %f Prev = %f", value, prevValue];	
    }
}

@end


