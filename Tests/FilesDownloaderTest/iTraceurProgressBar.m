/*
 * FilesDownloader Tests
 *
 * cocos2d-extensions
 * https://github.com/cocos2d/cocos2d-iphone-extensions
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

#import "iTraceurProgressBar.h"


@implementation iTraceurProgressBar

+ (id) progressBar
{
	return [  [ [self alloc] init] autorelease  ];
}

#if COCOS2D_VERSION >= 0x00020000
- (id) init
{
	CCSprite *sprite = [CCSprite spriteWithFile:@"iTraceurProgressBar.png"];
    
    if ( (self = [super initWithSprite:sprite]) )
 	{
        self.type = kCCProgressTimerTypeBar;
        self.midpoint = ccp(0, 0);
        //	Setup for a horizontal bar since the bar change rate is 0 for y meaning no vertical change
        self.barChangeRate = ccp(1,0);
		
		CCSprite *background = [CCSprite spriteWithFile:@"iTraceurProgressBarBackground.png"];
		CCSprite *cover = [CCSprite spriteWithFile:@"iTraceurProgressBarCover.png"];
		
		background.anchorPoint = ccp(0,0);
		cover.anchorPoint = ccp(0,0);
		
		[self addChild: background z: -1];
		[self addChild: cover z: 2];
	}
	
	return self;
}
#else
- (id) init
{
	if ( (self = [super initWithFile:@"iTraceurProgressBar.png"]) )
	{
		self.type = kCCProgressTimerTypeHorizontalBarLR;
		
		
		CCSprite *background = [CCSprite spriteWithFile:@"iTraceurProgressBarBackground.png"];
		CCSprite *cover = [CCSprite spriteWithFile:@"iTraceurProgressBarCover.png"];
		
		background.anchorPoint = ccp(0,0);
		cover.anchorPoint = ccp(0,0);
		
		[self addChild: background z: -1];
		[self addChild: cover z: 2];
		
	}
	
	return self;
}
#endif

@end
