/*
 * CCMenuItemSpriteIndependent
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

#import "CCMenuItemSpriteIndependent.h"

@implementation CCMenuItemSpriteIndependent


// returns only contentSize in rect.size, cause CCMenu doesn't use origin anyway
// contentSize_ is set in init with normalImage_ content size
-(CGRect) rect
{
	return CGRectMake( 0, 0, normalImage_.contentSize.width, normalImage_.contentSize.height );	
}

// delegates point conversion to normalImage_
- (CGPoint)convertToNodeSpace:(CGPoint)worldPoint
{
	return [normalImage_ convertToNodeSpace: worldPoint];
}

// retains normal image, doesnt add it as a child
-(void) setNormalImage:(CCNode <CCRGBAProtocol>*)image
{
	if( image != normalImage_ ) 
	{
		[normalImage_ release];
		image.visible = YES;
		normalImage_ = [image retain];
	}
}

// retains selected image, doesnt add it as a child
-(void) setSelectedImage:(CCNode <CCRGBAProtocol>*)image
{
	if( image != selectedImage_ ) 
	{
		[selectedImage_ release];
		image.visible = NO;
		selectedImage_ = [image retain];
	}
}

// retains disabled image, doesnt add it as a child
-(void) setDisabledImage:(CCNode <CCRGBAProtocol>*)image
{
	if( image != disabledImage_ ) 
	{
		[disabledImage_ release];
		image.visible = NO;
		disabledImage_ = [image retain];
	}
}

- (void) dealloc
{
	[normalImage_ release];
	[selectedImage_ release];
	[disabledImage_ release];	
	
	[super dealloc];
}

@end

