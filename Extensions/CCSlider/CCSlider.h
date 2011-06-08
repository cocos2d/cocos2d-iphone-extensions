//
//  CCSlider.h
//  CCSliderControl from http://srooltheknife.blogspot.com/
//  https://bitbucket.org/iroth_net/ccslider
//
//  Created by Israel Roth 
//	Edited by Stepan Generalov on 23.01.11 for 
//   iTraceur - Parkour / Freerunning Platform Game
//         http://www.iTraceur.ru

#import "cocos2d.h"

static const NSInteger kCCSliderPriority = kCCMenuTouchPriority - 2;

@protocol CCSliderControlDelegate  
- (void) valueChanged: (float) value tag: (int) tag;  
@end  

@interface CCSlider : CCLayer 
{  
	float value;  
	id<CCSliderControlDelegate> delegate;  
	float minX;  
	float maxX;  
	
	// weak links to children
	CCMenuItem *_thumb;
	CCSprite *_bg;
}  

@property (nonatomic, assign) float value;  
@property (nonatomic, retain) id<CCSliderControlDelegate> delegate; 

// Creates slider with backround image filename & thumb image filename.
+ (id) sliderWithBackgroundFile: (NSString *) bgFile thumbFile: (NSString *) thumbFile;

// Creates slider with given bg sprite and menu item as a thumb.
+(id) sliderWithBackgroundSprite: (CCSprite *) bgSprite thumbMenuItem: (CCMenuItem *) aThumb;

// Easy init - filenames instead of CCSprite & CCMenuItem.
// Uses designated init inside, thumb selected image is created by copying making darker normal sprite.
- (id) initWithBackgroundFile: (NSString *) bgFile thumbFile: (NSString *) thumbFile;

// Designated init.
-(id) initWithBackgroundSprite: (CCSprite *) bgSprite thumbMenuItem: (CCMenuItem *) aThumb;

@end  
